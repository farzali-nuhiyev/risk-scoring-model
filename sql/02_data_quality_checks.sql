-- ============================================================
-- Risk Scoring Portfolio Project
-- Data-quality and relationship validation checks
-- These queries only read data. They do not change anything.
-- ============================================================


-- ============================================================
-- 1. ROW-COUNT CHECK
-- Expected counts come from the CSV files loaded into Oracle.
-- ============================================================

SELECT 'RS_CUSTOMERS' AS TABLE_NAME, 15000 AS EXPECTED_ROWS, COUNT(*) AS ACTUAL_ROWS
FROM RS_CUSTOMERS

UNION ALL

SELECT 'RS_CONTRACTS', 20000, COUNT(*)
FROM RS_CONTRACTS

UNION ALL

SELECT 'RS_MKR_MASTER', 60000, COUNT(*)
FROM RS_MKR_MASTER

UNION ALL

SELECT 'RS_APPLICATIONS', 20000, COUNT(*)
FROM RS_APPLICATIONS

UNION ALL

SELECT 'RS_MKR_LIABILITIES', 98474, COUNT(*)
FROM RS_MKR_LIABILITIES

UNION ALL

SELECT 'RS_MKR_LIABILITY_HISTORY', 98474, COUNT(*)
FROM RS_MKR_LIABILITY_HISTORY

UNION ALL

SELECT 'RS_MKR_INQUIRY_HISTORY', 121581, COUNT(*)
FROM RS_MKR_INQUIRY_HISTORY

UNION ALL

SELECT 'RS_CONTRACT_CURRENT', 20000, COUNT(*)
FROM RS_CONTRACT_CURRENT

UNION ALL

SELECT 'RS_CONTRACT_PERFORMANCE_OUTCOME', 20000, COUNT(*)
FROM RS_CONTRACT_PERFORMANCE_OUTCOME

ORDER BY TABLE_NAME;


-- ============================================================
-- 2. ORPHAN-RECORD CHECKS
-- Every result should be zero.
-- ============================================================

SELECT 'CONTRACTS_WITHOUT_CUSTOMER' AS CHECK_NAME, COUNT(*) AS INVALID_ROWS
FROM RS_CONTRACTS C
LEFT JOIN RS_CUSTOMERS CU
    ON C.CUSTOMER_ID = CU.CUSTOMER_NO
WHERE CU.CUSTOMER_NO IS NULL

UNION ALL

SELECT 'APPLICATIONS_WITHOUT_CONTRACT', COUNT(*)
FROM RS_APPLICATIONS A
LEFT JOIN RS_CONTRACTS C
    ON A.ACCOUNT_NUMBER = C.ACCOUNT_NUMBER
WHERE C.ACCOUNT_NUMBER IS NULL

UNION ALL

SELECT 'APPLICATIONS_WITHOUT_MKR_SEARCH', COUNT(*)
FROM RS_APPLICATIONS A
LEFT JOIN RS_MKR_MASTER M
    ON A.MKR_SEARCH_ID = M.SEARCH_ID
WHERE M.SEARCH_ID IS NULL

UNION ALL

SELECT 'LIABILITIES_WITHOUT_MKR_MASTER', COUNT(*)
FROM RS_MKR_LIABILITIES L
LEFT JOIN RS_MKR_MASTER M
    ON L.SEARCH_ID = M.SEARCH_ID
WHERE M.SEARCH_ID IS NULL

UNION ALL

SELECT 'LIABILITY_HISTORY_WITHOUT_LIABILITY', COUNT(*)
FROM RS_MKR_LIABILITY_HISTORY H
LEFT JOIN RS_MKR_LIABILITIES L
    ON H.SEARCH_ID = L.SEARCH_ID
   AND H.LIABILITY_ID = L.ID
WHERE L.ID IS NULL

UNION ALL

SELECT 'INQUIRIES_WITHOUT_MKR_MASTER', COUNT(*)
FROM RS_MKR_INQUIRY_HISTORY I
LEFT JOIN RS_MKR_MASTER M
    ON I.SEARCH_ID = M.SEARCH_ID
WHERE M.SEARCH_ID IS NULL

UNION ALL

SELECT 'CURRENT_SNAPSHOTS_WITHOUT_CONTRACT', COUNT(*)
FROM RS_CONTRACT_CURRENT CC
LEFT JOIN RS_CONTRACTS C
    ON CC.ACCOUNT_NUMBER = C.ACCOUNT_NUMBER
WHERE C.ACCOUNT_NUMBER IS NULL

UNION ALL

SELECT 'OUTCOMES_WITHOUT_CONTRACT', COUNT(*)
FROM RS_CONTRACT_PERFORMANCE_OUTCOME O
LEFT JOIN RS_CONTRACTS C
    ON O.ACCOUNT_NUMBER = C.ACCOUNT_NUMBER
WHERE C.ACCOUNT_NUMBER IS NULL

ORDER BY CHECK_NAME;


-- ============================================================
-- 3. APPLICATION AND MKR TIMING CHECK
-- Valid rule:
-- APPLICATION_DATE <= DECISION_DATE <= VALUE_DATE
-- MKR report date = application date
-- Application date is 0–7 days before VALUE_DATE.
-- ============================================================

SELECT COUNT(*) AS INVALID_APPLICATION_TIMING_ROWS
FROM RS_APPLICATIONS A
JOIN RS_MKR_MASTER M
    ON A.MKR_SEARCH_ID = M.SEARCH_ID
WHERE A.APPLICATION_DATE > A.DECISION_DATE
   OR A.DECISION_DATE > A.VALUE_DATE
   OR A.APPLICATION_DATE <> M.REPORTINGDATE
   OR A.VALUE_DATE - A.APPLICATION_DATE NOT BETWEEN 0 AND 7;


-- ============================================================
-- 4. MKR PARENT-CHILD BALANCE RECONCILIATION
-- Sum of liability principal + interest must equal
-- the MKR master BALANCE for every SEARCH_ID.
-- This query should return zero rows.
-- ============================================================

SELECT
    M.SEARCH_ID,
    M.BALANCE AS MASTER_BALANCE,
    NVL(
        SUM(
            NVL(L.OUTSTANDINGDEBTMAIN, 0)
            + NVL(L.OUTSTANDINGDEBTINTEREST, 0)
        ),
        0
    ) AS LIABILITY_BALANCE
FROM RS_MKR_MASTER M
LEFT JOIN RS_MKR_LIABILITIES L
    ON M.SEARCH_ID = L.SEARCH_ID
GROUP BY
    M.SEARCH_ID,
    M.BALANCE
HAVING ABS(
    NVL(
        SUM(
            NVL(L.OUTSTANDINGDEBTMAIN, 0)
            + NVL(L.OUTSTANDINGDEBTINTEREST, 0)
        ),
        0
    ) - NVL(M.BALANCE, 0)
) > 0.01;


-- ============================================================
-- 5. LIABILITY HISTORY COMPLETENESS
-- Every liability must have exactly one history snapshot.
-- This query should return zero rows.
-- ============================================================

SELECT
    L.SEARCH_ID,
    L.ID AS LIABILITY_ID,
    COUNT(H.LIABILITY_ID) AS HISTORY_ROW_COUNT
FROM RS_MKR_LIABILITIES L
LEFT JOIN RS_MKR_LIABILITY_HISTORY H
    ON L.SEARCH_ID = H.SEARCH_ID
   AND L.ID = H.LIABILITY_ID
GROUP BY
    L.SEARCH_ID,
    L.ID
HAVING COUNT(H.LIABILITY_ID) <> 1;


-- ============================================================
-- 6. INTERNAL / EXTERNAL MASKING VALIDATION
-- 1000 = INTERNAL
-- 1001–1020 = EXTERNAL
-- Each result should be zero.
-- ============================================================

SELECT 'LIABILITIES' AS SOURCE_TABLE, COUNT(*) AS INVALID_ROWS
FROM RS_MKR_LIABILITIES
WHERE NOT (
    (BANKNAME = 'INTERNAL' AND BANKID = '1000')
    OR
    (
        BANKNAME = 'EXTERNAL'
        AND REGEXP_LIKE(BANKID, '^10(0[1-9]|1[0-9]|20)$')
    )
)

UNION ALL

SELECT 'INQUIRY_HISTORY', COUNT(*)
FROM RS_MKR_INQUIRY_HISTORY
WHERE NOT (
    (INQBANKNAME = 'INTERNAL' AND INQBANKID = '1000')
    OR
    (
        INQBANKNAME = 'EXTERNAL'
        AND REGEXP_LIKE(INQBANKID, '^10(0[1-9]|1[0-9]|20)$')
    )
);


-- ============================================================
-- 7. CONTRACT-SNAPSHOT RULE
-- Active: snapshot date must be 2026-06-01 and CLOSE_DATE blank.
-- Closed: snapshot date must equal CLOSE_DATE.
-- This query should return zero rows.
-- ============================================================

SELECT COUNT(*) AS INVALID_SNAPSHOT_ROWS
FROM RS_CONTRACT_CURRENT
WHERE
    (
        M_ACCOUNT_STATUS = 'A'
        AND (
            TRN_DT <> DATE '2026-06-01'
            OR CLOSE_DATE IS NOT NULL
        )
    )
    OR
    (
        M_ACCOUNT_STATUS = 'L'
        AND (
            CLOSE_DATE IS NULL
            OR TRN_DT <> CLOSE_DATE
        )
    );


-- ============================================================
-- 8. CANDIDATE OUTCOME CONSISTENCY
-- BAD_12M_FLAG is only a candidate target for now.
-- This query should return zero rows.
-- ============================================================

SELECT COUNT(*) AS INVALID_CANDIDATE_OUTCOME_ROWS
FROM RS_CONTRACT_PERFORMANCE_OUTCOME
WHERE
    (
        BAD_12M_FLAG = '1'
        AND FIRST_90_DPD_DATE IS NULL
    )
    OR
    (
        BAD_12M_FLAG = '0'
        AND FULL_12M_OBSERVED_FLAG <> '1'
    )
    OR
    (
        FIRST_90_DPD_DATE > VALUE_DATE + 365
    );