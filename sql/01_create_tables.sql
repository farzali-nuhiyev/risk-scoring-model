-- ============================================================
-- Risk Scoring Portfolio Project
-- Core Oracle tables
-- Run this script once in DBeaver while connected to FREEPDB1
-- as SYSTEM.
-- ============================================================


-- ============================================================
-- 1. CUSTOMERS
-- ============================================================

CREATE TABLE RS_CUSTOMERS (
    GEN_DIM_CUST_ID                    NUMBER(18),
    CUSTOMER_NO                        VARCHAR2(35 CHAR) NOT NULL,
    PIN                                VARCHAR2(20 CHAR),
    DOCUMENT_NO                        VARCHAR2(35 CHAR),
    TAX_ID                             VARCHAR2(35 CHAR),
    CUSTOMER_TYPE                      VARCHAR2(1 CHAR),
    CUSTOMER_SUB_TYPE                  VARCHAR2(50 CHAR),
    FULL_NAME                          VARCHAR2(500 CHAR),
    FIRST_NAME                         VARCHAR2(150 CHAR),
    LAST_NAME                          VARCHAR2(150 CHAR),
    MIDDLE_NAME                        VARCHAR2(150 CHAR),
    GENDER                             VARCHAR2(20 CHAR),
    BIRTH_DT                           DATE,
    PLACE_OF_BIRTH                     VARCHAR2(150 CHAR),
    MARITAL_STATUS                     VARCHAR2(30 CHAR),
    NATIONALITY                        VARCHAR2(100 CHAR),
    OPEN_REASON                        VARCHAR2(100 CHAR),
    CREATION_DT                        DATE,
    OPENING_BRN                        VARCHAR2(35 CHAR),
    FLG_IS_COURT_ISSUE                 VARCHAR2(10 CHAR),
    OCCUPATION                         VARCHAR2(150 CHAR),
    WORKPLACE_CUSTOMER_NO              VARCHAR2(35 CHAR),
    WORKPLACE_NAME                     VARCHAR2(500 CHAR),
    FLG_IS_BLACK_LIST                  VARCHAR2(10 CHAR),
    FLG_IS_VIP                         VARCHAR2(10 CHAR),
    FLG_IS_EMPLOYEER                   VARCHAR2(10 CHAR),
    NUM_OF_EMPLOYEER                   NUMBER(10),
    RM_NAME                            VARCHAR2(255 CHAR),
    CUSTOMER_GENERATION                VARCHAR2(100 CHAR),
    FLG_IS_AFFLUENT                    VARCHAR2(10 CHAR),
    FLG_IS_SALARY                      VARCHAR2(10 CHAR),
    FLG_IS_PENSION                     VARCHAR2(10 CHAR),
    FLG_IS_EDV                         VARCHAR2(10 CHAR),
    RISK_LEVEL                         VARCHAR2(50 CHAR),
    RESIDENT_STATUS                    VARCHAR2(50 CHAR),
    RM_ID_CORP                         VARCHAR2(35 CHAR),
    GROUP_ID_CORP                      VARCHAR2(35 CHAR),
    CHECKER_DT_STAMP                   TIMESTAMP,
    MAKER_DT_STAMP                     TIMESTAMP,
    EMPL_PROPERTY_TYPE                 VARCHAR2(100 CHAR),
    SHORT_NAME                         VARCHAR2(255 CHAR),
    COUNTRY                            VARCHAR2(100 CHAR),
    DOCUMENT_NAME                      VARCHAR2(100 CHAR),
    LEGAL_GUARDIAN                     VARCHAR2(500 CHAR),
    PASSPORT_COUNTRY                   VARCHAR2(100 CHAR),
    PASSPORT_NATIONAL_ID               VARCHAR2(100 CHAR),
    PASSPORT_ISS_DT                    DATE,
    PASSPORT_EXP_DT                    DATE,
    P_ADDRESS1                         VARCHAR2(1000 CHAR),
    P_ADDRESS2                         VARCHAR2(1000 CHAR),
    P_ADDRESS3                         VARCHAR2(1000 CHAR),
    ENGLISH_FULL_NAME                  VARCHAR2(500 CHAR),
    FLG_IS_BENEFICIARY                VARCHAR2(10 CHAR),
    CUSTOMER_SINCE                     DATE,
    DIRECTOR_CUST_NO                   VARCHAR2(35 CHAR),
    FLG_IS_GREEN_CARD                  VARCHAR2(10 CHAR),
    US_BIRTH                           VARCHAR2(10 CHAR),
    FLG_IS_US_CITIZEN                  VARCHAR2(10 CHAR),
    US_PAYMENT                         VARCHAR2(10 CHAR),
    FLG_IS_US_RESIDENT_POA             VARCHAR2(10 CHAR),
    FLG_IS_US_ADDRESS                  VARCHAR2(10 CHAR),
    FLG_IS_US_LIVING                   VARCHAR2(10 CHAR),
    US_PASSPORT                        VARCHAR2(10 CHAR),
    FLG_IS_US_PHONE                    VARCHAR2(10 CHAR),
    FLG_IS_US_POA                      VARCHAR2(10 CHAR),
    FLG_IS_US_POST_BOX                 VARCHAR2(10 CHAR),
    US_RELATED_PERSON                  VARCHAR2(10 CHAR),
    FLG_IS_US_TAX_RESIDENT             VARCHAR2(10 CHAR),
    WORKPLACE_ADDRESS                  VARCHAR2(1000 CHAR),
    WORKPLACE                          VARCHAR2(500 CHAR),
    CIF_RECORD_STATUS                  VARCHAR2(30 CHAR),
    FLG_IS_FROZEN                      VARCHAR2(10 CHAR),
    INS_DTTM                           TIMESTAMP,
    TAX_TYPE                           VARCHAR2(50 CHAR),
    FLG_IS_INGROUP                     VARCHAR2(10 CHAR),
    CUST_MIS_1                         VARCHAR2(255 CHAR),
    SHORT_NAME2                        VARCHAR2(255 CHAR),
    SWIFT_CD                           VARCHAR2(30 CHAR),
    CHARGE_GROUP                       VARCHAR2(100 CHAR),
    DEFAULT_MEDIA                      VARCHAR2(100 CHAR),
    CUSTOMER_ADDRESS                   VARCHAR2(2000 CHAR),
    CORP_REGISTER_ADDRESS              VARCHAR2(2000 CHAR),
    CORP_REGISTER_COUNTRY              VARCHAR2(100 CHAR),
    CHECKER_DT                         DATE,
    FLG_IS_MILITARY_PASSPORT           VARCHAR2(10 CHAR),
    CUST_SUB_SEGMENT                   VARCHAR2(100 CHAR),
    AGRAR_PKD                          VARCHAR2(100 CHAR),
    FLG_IS_ACTIVE_CUSTOMER_QUARTERLY   VARCHAR2(10 CHAR),
    FLG_IS_REMOTE_ACC_ALLOWED          VARCHAR2(10 CHAR),
    ONLY_LAST_AND_FIRST_NAME_ENG       VARCHAR2(500 CHAR),
    EMPLOYER_ID                        VARCHAR2(35 CHAR),
    INCORP_DATE                        DATE,
    DT_QHT_GROUP                       VARCHAR2(35 CHAR),
    CUST_CLASSIFICATION                VARCHAR2(100 CHAR),
    LOAN_RESP_ID                       VARCHAR2(35 CHAR),
    ULTIMATE_BENEFICIAL_OWNER          VARCHAR2(500 CHAR),
    FLG_IS_RELATED_PERSON              VARCHAR2(10 CHAR),
    COUNTRY_DESC                       VARCHAR2(255 CHAR),
    REGISTRATION_ADDRESS               VARCHAR2(2000 CHAR),
    DOMICILE_ADDRESS                   VARCHAR2(2000 CHAR),

    CONSTRAINT PK_RS_CUSTOMERS
        PRIMARY KEY (CUSTOMER_NO)
);


-- ============================================================
-- 2. INTERNAL BANK CONTRACTS
-- ============================================================

CREATE TABLE RS_CONTRACTS (
    ACCOUNT_NUMBER        VARCHAR2(35 CHAR) NOT NULL,
    BRANCH_CODE           VARCHAR2(35 CHAR),
    APPLICATION_NUM       VARCHAR2(35 CHAR) NOT NULL,
    CUSTOMER_ID           VARCHAR2(35 CHAR) NOT NULL,
    PRODUCT_CODE          VARCHAR2(35 CHAR),
    PRODUCT_CATEGORY      VARCHAR2(100 CHAR),
    BOOK_DATE             DATE,
    VALUE_DATE            DATE,
    ORIGINAL_ST_DATE      DATE,
    PRIMARY_APPLICANT_ID  VARCHAR2(35 CHAR),
    ALT_ACC_NO            VARCHAR2(35 CHAR),

    CONSTRAINT PK_RS_CONTRACTS
        PRIMARY KEY (ACCOUNT_NUMBER),

    CONSTRAINT UQ_RS_CONTRACTS_APP
        UNIQUE (APPLICATION_NUM),

    CONSTRAINT FK_RS_CONTRACTS_CUSTOMER
        FOREIGN KEY (CUSTOMER_ID)
        REFERENCES RS_CUSTOMERS (CUSTOMER_NO)
);


-- ============================================================
-- 3. MKR MASTER: ALL-BANK CREDIT-BUREAU SEARCHES
-- ============================================================

CREATE TABLE RS_MKR_MASTER (
    SEARCH_ID       VARCHAR2(30 CHAR) NOT NULL,
    PIN_CODE        VARCHAR2(20 CHAR),
    BALANCE         NUMBER(18, 2),
    REPORTID        VARCHAR2(35 CHAR),
    REPORTINGDATE   DATE,
    INSERT_DATE     DATE,
    DOCUMENT_NO     VARCHAR2(35 CHAR),

    CONSTRAINT PK_RS_MKR_MASTER
        PRIMARY KEY (SEARCH_ID)
);


-- ============================================================
-- 4. INTERNAL LOAN APPLICATIONS
-- ============================================================

CREATE TABLE RS_APPLICATIONS (
    APPLICATION_ID          VARCHAR2(30 CHAR) NOT NULL,
    APPLICATION_NUM         VARCHAR2(35 CHAR) NOT NULL,
    ACCOUNT_NUMBER          VARCHAR2(35 CHAR) NOT NULL,
    CUSTOMER_ID             VARCHAR2(35 CHAR) NOT NULL,
    CUSTOMER_TYPE           VARCHAR2(1 CHAR),
    APPLICATION_DATE        DATE,
    DECISION_DATE           DATE,
    VALUE_DATE              DATE,
    MKR_SEARCH_ID           VARCHAR2(30 CHAR) NOT NULL,
    PRODUCT_CODE            VARCHAR2(35 CHAR),
    PRODUCT_CATEGORY        VARCHAR2(100 CHAR),
    BRANCH_CODE             VARCHAR2(35 CHAR),
    REQUESTED_AMOUNT        NUMBER(18, 2),
    APPROVED_AMOUNT         NUMBER(18, 2),
    REQUESTED_TERM_MONTHS   NUMBER(5),
    APPROVED_TERM_MONTHS    NUMBER(5),
    INTEREST_RATE_OFFERED   NUMBER(10, 4),
    APPLICATION_CHANNEL     VARCHAR2(50 CHAR),
    DECISION                VARCHAR2(50 CHAR),
    APPLICATION_STATUS      VARCHAR2(50 CHAR),
    APPLICATION_REASON      VARCHAR2(100 CHAR),
    SOURCE_SYSTEM           VARCHAR2(50 CHAR),

    CONSTRAINT PK_RS_APPLICATIONS
        PRIMARY KEY (APPLICATION_ID),

    CONSTRAINT UQ_RS_APPLICATIONS_ACC
        UNIQUE (ACCOUNT_NUMBER),

    CONSTRAINT UQ_RS_APPLICATIONS_MKR
        UNIQUE (MKR_SEARCH_ID),

    CONSTRAINT FK_RS_APPS_CONTRACT
        FOREIGN KEY (ACCOUNT_NUMBER)
        REFERENCES RS_CONTRACTS (ACCOUNT_NUMBER),

    CONSTRAINT FK_RS_APPS_CUSTOMER
        FOREIGN KEY (CUSTOMER_ID)
        REFERENCES RS_CUSTOMERS (CUSTOMER_NO),

    CONSTRAINT FK_RS_APPS_MKR
        FOREIGN KEY (MKR_SEARCH_ID)
        REFERENCES RS_MKR_MASTER (SEARCH_ID)
);


-- ============================================================
-- 5. MKR LIABILITIES
-- BANKID 1000 = INTERNAL
-- BANKID 1001–1020 = EXTERNAL
-- ============================================================

CREATE TABLE RS_MKR_LIABILITIES (
    SEARCH_ID                    VARCHAR2(30 CHAR) NOT NULL,
    PIN_CODE                     VARCHAR2(20 CHAR),
    ACCOUNTNO                    VARCHAR2(35 CHAR),
    BANKID                       VARCHAR2(10 CHAR),
    BANKNAME                     VARCHAR2(20 CHAR),
    COLLATERALANYINFO            VARCHAR2(2000 CHAR),
    COLLATERALCODE               VARCHAR2(50 CHAR),
    COLLATERALMARKETVALUE        NUMBER(18, 2),
    COLLATERALREGISTRYAGENCY     VARCHAR2(255 CHAR),
    COLLATERALREGISTRYDATE       DATE,
    COLLATERALREGISTRYNO         VARCHAR2(100 CHAR),
    COLLATERALTYPENAME           VARCHAR2(255 CHAR),
    CREDITPURPOSE                VARCHAR2(20 CHAR),
    CREDITPURPOSENAME            VARCHAR2(255 CHAR),
    CREDITSTATUS                 VARCHAR2(20 CHAR),
    CREDITSTATUSCLOSEDATE        DATE,
    CREDITSTATUSNAME             VARCHAR2(100 CHAR),
    CREDITTYPE                   VARCHAR2(20 CHAR),
    CREDITTYPENAME               VARCHAR2(255 CHAR),
    CURRENCY                     VARCHAR2(3 CHAR),
    CURRENCYNAME                 VARCHAR2(100 CHAR),
    DAYSINTERESTOVERDUE          NUMBER(10),
    DAYSMAINSUMOVERDUE           NUMBER(10),
    GRANTEDON                    DATE,
    ID                           NUMBER(12) NOT NULL,
    INITIALAMOUNT                NUMBER(18, 2),
    INTERESTRATE                 NUMBER(10, 4),
    LASTPAYMENTDATE              DATE,
    LASTUPDATEDDATE              DATE,
    LINEAMOUNT                   NUMBER(18, 2),
    MKRID                        VARCHAR2(35 CHAR),
    MONTHLYPAYMENTAMOUNT         NUMBER(18, 2),
    ORGIDTYPE                    VARCHAR2(20 CHAR),
    OUTSTANDINGDEBTINTEREST      NUMBER(18, 2),
    OUTSTANDINGDEBTMAIN          NUMBER(18, 2),
    PROLONGATIONS                NUMBER(10),
    CONTRACTDUEON                DATE,
    INS_DTTM                     TIMESTAMP,

    CONSTRAINT PK_RS_MKR_LIABILITIES
        PRIMARY KEY (ID),

    CONSTRAINT UQ_RS_MKR_LIAB_SEARCH_ID
        UNIQUE (SEARCH_ID, ID),

    CONSTRAINT FK_RS_LIAB_MASTER
        FOREIGN KEY (SEARCH_ID)
        REFERENCES RS_MKR_MASTER (SEARCH_ID),

    CONSTRAINT CK_RS_LIAB_BANK_NAME
        CHECK (BANKNAME IN ('INTERNAL', 'EXTERNAL'))
);


-- ============================================================
-- 6. MKR LIABILITY HISTORY
-- ============================================================

CREATE TABLE RS_MKR_LIABILITY_HISTORY (
    SEARCH_ID           VARCHAR2(30 CHAR) NOT NULL,
    PIN_CODE            VARCHAR2(20 CHAR),
    LIABILITY_ID        NUMBER(12) NOT NULL,
    OVERDUEDAYS         NUMBER(10),
    REPORTINGPERIOD     DATE,
    CREDIT_STATUS       VARCHAR2(20 CHAR),
    INS_DTTM            TIMESTAMP,

    CONSTRAINT PK_RS_MKR_LIAB_HISTORY
        PRIMARY KEY (SEARCH_ID, LIABILITY_ID),

    CONSTRAINT FK_RS_LIAB_HIST_LIAB
        FOREIGN KEY (SEARCH_ID, LIABILITY_ID)
        REFERENCES RS_MKR_LIABILITIES (SEARCH_ID, ID)
);


-- ============================================================
-- 7. MKR INQUIRY HISTORY
-- Oracle creates INQUIRY_HISTORY_ID automatically.
-- It does not exist in the CSV and will not be loaded from CSV.
-- ============================================================

CREATE TABLE RS_MKR_INQUIRY_HISTORY (
    INQUIRY_HISTORY_ID   NUMBER GENERATED BY DEFAULT AS IDENTITY,
    SEARCH_ID            VARCHAR2(30 CHAR) NOT NULL,
    PIN_CODE             VARCHAR2(20 CHAR),
    INQBANKID            VARCHAR2(10 CHAR),
    INQBANKNAME          VARCHAR2(20 CHAR),
    INQDATE              DATE,
    INQORGIDTYPE         VARCHAR2(20 CHAR),
    INQPURPOSEID         VARCHAR2(20 CHAR),
    INQPURPOSENAME       VARCHAR2(255 CHAR),
    INS_DTTM             TIMESTAMP,
    DOCUMENTNO           VARCHAR2(35 CHAR),
    REPORTINGDATE        DATE,

    CONSTRAINT PK_RS_MKR_INQ_HISTORY
        PRIMARY KEY (INQUIRY_HISTORY_ID),

    CONSTRAINT FK_RS_INQ_MASTER
        FOREIGN KEY (SEARCH_ID)
        REFERENCES RS_MKR_MASTER (SEARCH_ID),

    CONSTRAINT CK_RS_INQ_BANK_NAME
        CHECK (INQBANKNAME IN ('INTERNAL', 'EXTERNAL'))
);


-- ============================================================
-- 8. CONTRACT CURRENT SNAPSHOT
-- One final snapshot row per internal-bank contract.
-- ============================================================

CREATE TABLE RS_CONTRACT_CURRENT (
    TRN_DT                      DATE,
    ACCOUNT_NUMBER              VARCHAR2(35 CHAR) NOT NULL,
    BRANCH_CODE                 VARCHAR2(35 CHAR),
    START_DATE_P                DATE,
    START_DATE_I                DATE,
    NEXT_PAYMENT_DATE           DATE,
    CURR_PAYMENT_RECD           NUMBER(18, 2),
    S_PRINCIPAL_OUT_BAL_ACY     NUMBER(18, 2),
    EOP_CURR_PRIN_BAL           NUMBER(18, 2),
    EOP_CURR_MAIN_BAL           NUMBER(18, 2),
    EOP_PREV_PRIN_BAL           NUMBER(18, 2),
    EOP_BAL                     NUMBER(18, 2),
    S_PRINCIPAL_OVERDUE         NUMBER(18, 2),
    S_MAIN_OVERDUE              NUMBER(18, 2),
    S_DELINQUENT_DAYS           NUMBER(10),
    NUMB_INSTAL_PRIN            NUMBER(10),
    S_OVERDUE_DAYS_PRIN         NUMBER(10),
    S_OVERDUE_DAYS_INT          NUMBER(10),
    S_DELQ_LIFE_TIMES           NUMBER(10),
    S_DELQ_YEAR_TIMES           NUMBER(10),
    DELQ_HISTORY                VARCHAR2(255 CHAR),
    REMAIN_NO_OF_PMTS           NUMBER(10),
    ORIG_NEXT_PAYMENT_DATE      DATE,
    EFF_MATURITY_DATE           DATE,
    S_MAX_LIFETIME_DPD          NUMBER(10),
    S_LAST_DELINQUENT_DATE      DATE,
    S_INTEREST_OUT_BAL_ACY      NUMBER(18, 2),
    M_ACCOUNT_NUMBER            VARCHAR2(35 CHAR),
    M_BRANCH_CODE               VARCHAR2(35 CHAR),
    M_CUSTOMER_ID               VARCHAR2(35 CHAR),
    M_PRODUCT_CODE              VARCHAR2(35 CHAR),
    M_VALUE_DATE                DATE,
    M_MATURITY_DATE             DATE,
    M_AMOUNT_FINANCED           NUMBER(18, 2),
    M_PRODUCT_CATEGORY          VARCHAR2(100 CHAR),
    M_CURRENCY                  VARCHAR2(3 CHAR),
    M_ORIGINAL_ST_DATE          DATE,
    M_TENOR                     NUMBER(10),
    M_CURR_DATE                 DATE,
    M_ACCOUNT_STATUS            VARCHAR2(1 CHAR),
    M_CUSTOMER_TYPE             VARCHAR2(1 CHAR),
    M_RATE                      NUMBER(10, 4),
    AM_PRN_LAST_PMNT_AMT        NUMBER(18, 2),
    AM_INT_LAST_PMNT_DATE       DATE,
    AM_INT_LAST_PMNT_AMT        NUMBER(18, 2),
    S_LAST_PMNT_VALUE_DATE      DATE,
    A_TERM                      NUMBER(10),
    A_ORIG_AMT                  NUMBER(18, 2),
    A_EMI                       NUMBER(18, 2),
    A_PERIODS_PASSED            NUMBER(10),
    A_OVERDUE_DAYS              NUMBER(10),
    A_OVERDUE_AMNT              NUMBER(18, 2),
    A_OVERDUE_MON               NUMBER(10),
    CS_REPAYMENT_TYPE           VARCHAR2(100 CHAR),
    CLOSE_DATE                  DATE,
    INS_DTTM                    DATE,

    CONSTRAINT PK_RS_CONTRACT_CURRENT
        PRIMARY KEY (ACCOUNT_NUMBER),

    CONSTRAINT FK_RS_CURRENT_CONTRACT
        FOREIGN KEY (ACCOUNT_NUMBER)
        REFERENCES RS_CONTRACTS (ACCOUNT_NUMBER),

    CONSTRAINT CK_RS_CURRENT_STATUS
        CHECK (M_ACCOUNT_STATUS IN ('A', 'L'))
);


-- ============================================================
-- 9. CONTRACT PERFORMANCE OUTCOME
-- Candidate model-target ingredients only.
-- Final target will be selected later.
-- ============================================================

CREATE TABLE RS_CONTRACT_PERFORMANCE_OUTCOME (
    ACCOUNT_NUMBER                 VARCHAR2(35 CHAR) NOT NULL,
    VALUE_DATE                     DATE,
    SNAPSHOT_DATE                  DATE,
    OBSERVATION_END_DATE           DATE,
    FULL_12M_OBSERVED_FLAG         VARCHAR2(1 CHAR),
    MAX_DPD_OBSERVED               NUMBER(10),
    FIRST_30_DPD_DATE              DATE,
    FIRST_90_DPD_DATE              DATE,
    BAD_12M_FLAG                   VARCHAR2(1 CHAR),
    FINAL_ACCOUNT_STATUS           VARCHAR2(1 CHAR),
    CLOSE_DATE                     DATE,

    CONSTRAINT PK_RS_CONTRACT_OUTCOME
        PRIMARY KEY (ACCOUNT_NUMBER),

    CONSTRAINT FK_RS_OUTCOME_CONTRACT
        FOREIGN KEY (ACCOUNT_NUMBER)
        REFERENCES RS_CONTRACTS (ACCOUNT_NUMBER),

    CONSTRAINT CK_RS_OUTCOME_STATUS
        CHECK (FINAL_ACCOUNT_STATUS IN ('A', 'L'))
);


-- ============================================================
-- INDEXES FOR COMMON JOIN/FILTER COLUMNS
-- ============================================================

CREATE INDEX IX_RS_CONTRACTS_CUSTOMER
    ON RS_CONTRACTS (CUSTOMER_ID);

CREATE INDEX IX_RS_APPS_CUSTOMER
    ON RS_APPLICATIONS (CUSTOMER_ID);

-- CREATE INDEX IX_RS_APPS_MKR_SEARCH
--     ON RS_APPLICATIONS (MKR_SEARCH_ID);

CREATE INDEX IX_RS_LIAB_SEARCH
    ON RS_MKR_LIABILITIES (SEARCH_ID);

CREATE INDEX IX_RS_LIAB_BANK
    ON RS_MKR_LIABILITIES (BANKID);

CREATE INDEX IX_RS_LIAB_HISTORY_SEARCH
    ON RS_MKR_LIABILITY_HISTORY (SEARCH_ID);

CREATE INDEX IX_RS_INQ_SEARCH
    ON RS_MKR_INQUIRY_HISTORY (SEARCH_ID);

CREATE INDEX IX_RS_CURRENT_CUSTOMER
    ON RS_CONTRACT_CURRENT (M_CUSTOMER_ID);

CREATE INDEX IX_RS_OUTCOME_BAD_FLAG
    ON RS_CONTRACT_PERFORMANCE_OUTCOME (BAD_12M_FLAG);