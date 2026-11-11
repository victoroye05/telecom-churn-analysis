SELECT COUNT(*) AS total_rows FROM telco_raw;

SELECT * FROM telco_raw LIMIT 10;

--  Duplicate customer IDs 
SELECT customerID, COUNT(*) AS cnt
FROM telco_raw
GROUP BY customerID
HAVING COUNT(*) > 1;

--  Blank or missing TotalCharges 
SELECT customerID, tenure, MonthlyCharges, TotalCharges, Churn
FROM telco_raw
WHERE TotalCharges IS NULL OR TRIM(TotalCharges) = '';

--  Baseline churn rate
SELECT Churn,
       COUNT(*) AS customers,
       ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM telco_raw), 2) AS pct
FROM telco_raw
GROUP BY Churn;

-- Checking cateory values for typos or odd entries
SELECT DISTINCT Contract FROM telco_raw;
SELECT DISTINCT InternetService FROM telco_raw;
SELECT DISTINCT PaymentMethod FROM telco_raw;

SELECT customerID, tenure, MonthlyCharges, TotalCharges, Churn
FROM telco_raw
WHERE TRIM(TotalCharges) = '';

CREATE TABLE telco_clean AS
SELECT
    customerID,
    gender,
    CASE WHEN SeniorCitizen = '1' THEN 'Yes' ELSE 'No' END AS SeniorCitizen,
    Partner,
    Dependents,
    CAST(tenure AS UNSIGNED) AS tenure,
    PhoneService,
    MultipleLines,
    InternetService,
    OnlineSecurity,
    OnlineBackup,
    DeviceProtection,
    TechSupport,
    StreamingTV,
    StreamingMovies,
    Contract,
    PaperlessBilling,
    PaymentMethod,
    CAST(MonthlyCharges AS DECIMAL(10,2)) AS MonthlyCharges,
    CASE WHEN TRIM(TotalCharges) = '' THEN 0
         ELSE CAST(TotalCharges AS DECIMAL(10,2)) END AS TotalCharges,
    Churn,
    CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END AS churn_flag
FROM telco_raw;

SELECT COUNT(*) AS total_customers,
       SUM(churn_flag) AS churned,
       ROUND(AVG(churn_flag) * 100, 2) AS churn_rate_pct,
       SUM(TotalCharges IS NULL) AS null_total_charges
FROM telco_clean;

SELECT tenure, churn_flag, COUNT(*) AS customers
FROM telco_clean
WHERE tenure = 0
GROUP BY tenure, churn_flag;

-- . Churn by contract type
SELECT Contract,
       COUNT(*) AS customers,
       SUM(churn_flag) AS churned,
       ROUND(AVG(churn_flag) * 100, 2) AS churn_rate_pct
FROM telco_clean
GROUP BY Contract
ORDER BY churn_rate_pct DESC;

-- . Churn by internet service
SELECT InternetService,
       COUNT(*) AS customers,
       SUM(churn_flag) AS churned,
       ROUND(AVG(churn_flag) * 100, 2) AS churn_rate_pct
FROM telco_clean
GROUP BY InternetService
ORDER BY churn_rate_pct DESC;

--  Churn by payment method
SELECT PaymentMethod,
       COUNT(*) AS customers,
       SUM(churn_flag) AS churned,
       ROUND(AVG(churn_flag) * 100, 2) AS churn_rate_pct
FROM telco_clean
GROUP BY PaymentMethod
ORDER BY churn_rate_pct DESC;

--  Churn by tenure bucket
SELECT CASE WHEN tenure <= 12 THEN '1. 0-12 months'
            WHEN tenure <= 24 THEN '2. 13-24 months'
            WHEN tenure <= 48 THEN '3. 25-48 months'
            ELSE '4. 49+ months' END AS tenure_group,
       COUNT(*) AS customers,
       SUM(churn_flag) AS churned,
       ROUND(AVG(churn_flag) * 100, 2) AS churn_rate_pct
FROM telco_clean
GROUP BY tenure_group
ORDER BY tenure_group;

--  Churn by tech support (a service that may protect against churn)
SELECT TechSupport,
       COUNT(*) AS customers,
       ROUND(AVG(churn_flag) * 100, 2) AS churn_rate_pct
FROM telco_clean
GROUP BY TechSupport
ORDER BY churn_rate_pct DESC;

--  Monthly revenue lost to churn
SELECT ROUND(SUM(MonthlyCharges), 2) AS total_monthly_revenue,
       ROUND(SUM(CASE WHEN churn_flag = 1 THEN MonthlyCharges END), 2) AS monthly_revenue_lost,
       ROUND(SUM(CASE WHEN churn_flag = 1 THEN MonthlyCharges END) * 100.0
             / SUM(MonthlyCharges), 2) AS pct_revenue_lost
FROM telco_clean;

--  Rule-based churn risk score (one point per risk factor, 0 to 8)
CREATE TABLE telco_risk AS
SELECT *,
       (Contract = 'Month-to-month') * 2
     + (tenure <= 12) * 2
     + (InternetService = 'Fiber optic')
     + (PaymentMethod = 'Electronic check')
     + (TechSupport = 'No')
     + (OnlineSecurity = 'No') AS risk_score
FROM telco_clean;

ALTER TABLE telco_risk ADD COLUMN risk_tier VARCHAR(10);

UPDATE telco_risk
SET risk_tier = CASE WHEN risk_score >= 6 THEN 'High'
                     WHEN risk_score >= 4 THEN 'Medium'
                     ELSE 'Low' END;
                     
                     SET SQL_SAFE_UPDATES = 0;

UPDATE telco_risk
SET risk_tier = CASE WHEN risk_score >= 6 THEN 'High'
                     WHEN risk_score >= 4 THEN 'Medium'
                     ELSE 'Low' END;

SET SQL_SAFE_UPDATES = 1;

SELECT risk_tier,
       COUNT(*) AS customers,
       ROUND(AVG(churn_flag) * 100, 2) AS churn_rate_pct
FROM telco_risk
GROUP BY risk_tier
ORDER BY FIELD(risk_tier, 'High', 'Medium', 'Low');

SELECT risk_tier,
       COUNT(*) AS active_customers,
       ROUND(SUM(MonthlyCharges), 2) AS monthly_revenue_at_risk
FROM telco_risk
WHERE churn_flag = 0
GROUP BY risk_tier
ORDER BY FIELD(risk_tier, 'High', 'Medium', 'Low');

SET SQL_SAFE_UPDATES = 0;


UPDATE telco_risk
SET risk_tier = CASE WHEN risk_score >= 6 THEN 'High'
                     WHEN risk_score >= 4 THEN 'Medium'
                     ELSE 'Low' END;
                     
                     SET SQL_SAFE_UPDATES = 1;
                     
                     SELECT risk_tier,
       COUNT(*) AS customers,
       ROUND(AVG(churn_flag) * 100, 2) AS churn_rate_pct
FROM telco_risk
GROUP BY risk_tier
ORDER BY FIELD(risk_tier, 'High', 'Medium', 'Low');

SELECT risk_tier,
       COUNT(*) AS active_customers,
       ROUND(SUM(MonthlyCharges), 2) AS monthly_revenue_at_risk
FROM telco_risk
WHERE churn_flag = 0
GROUP BY risk_tier
ORDER BY FIELD(risk_tier, 'High', 'Medium', 'Low');

SELECT ROUND(SUM(MonthlyCharges), 2) AS total_monthly_revenue,
       ROUND(SUM(CASE WHEN churn_flag = 1 THEN MonthlyCharges END), 2) AS monthly_revenue_lost,
       ROUND(SUM(CASE WHEN churn_flag = 1 THEN MonthlyCharges END) * 100.0
             / SUM(MonthlyCharges), 2) AS pct_revenue_lost
FROM telco_clean;

CREATE TABLE telco_dashboard AS
SELECT *,
       CASE WHEN tenure <= 12 THEN '1. 0-12 months'
            WHEN tenure <= 24 THEN '2. 13-24 months'
            WHEN tenure <= 48 THEN '3. 25-48 months'
            ELSE '4. 49+ months' END AS tenure_group
FROM telco_risk;

SELECT COUNT(*) FROM telco_dashboard;


CREATE TABLE telco_at_risk AS
SELECT customerID, risk_tier, Contract, tenure, PaymentMethod, MonthlyCharges
FROM telco_risk
WHERE churn_flag = 0 AND risk_tier = 'High'
ORDER BY MonthlyCharges DESC;

SELECT COUNT(*) AS customers, ROUND(SUM(MonthlyCharges), 2) AS revenue_at_risk
FROM telco_at_risk;