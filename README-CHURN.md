# Telecom Customer Churn and Retention Analysis

An end-to-end analysis of why telecom customers leave, how much revenue it costs, and which active customers the company should contact first. Built with **MySQL** and **Power BI**.

## Business problem

Customer churn is expensive: replacing a lost customer costs more than keeping one. This project answers four questions:

1. How many customers are leaving, and how much revenue does that cost?
2. What do the customers who leave have in common?
3. Which active customers are most likely to leave next?
4. What should the company do about it?

## Dataset

[Telco Customer Churn](https://www.kaggle.com/datasets/blastchar/telco-customer-churn) on Kaggle (based on IBM sample data): 7,043 customers and 21 columns covering demographics, services, contract, billing, and a `Churn` Yes/No label.

The raw CSV is not included in this repository. Download it from the link above to reproduce the analysis.

## Tools

- **MySQL 8**: data cleaning, exploratory analysis, risk scoring
- **Power BI Desktop**: 3-page interactive dashboard

## Method

1. **Loaded** the CSV into MySQL as text columns (`telco_raw`), so blank values would not break the import.
2. **Audited** the data: no duplicate customer IDs, consistent category values, and 11 blank `TotalCharges` values.
3. **Cleaned** it into `telco_clean`: converted numeric columns from text, replaced the blank `TotalCharges` values with 0, standardised `SeniorCitizen` to Yes/No, and added a `churn_flag` column (1 = churned).
4. **Explored** churn rates by contract, tenure, internet service, payment method, and tech support.
5. **Scored** every customer with a rule-based risk score and grouped them into High, Medium, and Low tiers (`telco_risk`).
6. **Built** the Power BI dashboard on the results, plus a separate table of active High-risk customers (`telco_at_risk`).

## Key findings

**Baseline:** I  discovered  1,869 of 7,043 customers churned, a **26.54%** churn rate. Churned customers paid **$139,131 per month**, which is **30.5%** of all monthly revenue. That is higher than the customer churn rate because the customers who leave tend to pay more than those who stay.

| Driver | Highest-churn group | Churn rate | Comparison |
|---|---|---|---|
| Contract | Month-to-month | 42.71% | Two-year: 2.83% |
| Tenure | 0-12 months | 47.44% | 49+ months: 9.51% |
| Payment method | Electronic check | 45.29% | Credit card (automatic): 15.24% |
| Internet service | Fiber optic | 41.89% | DSL: 18.96% |
| Tech support | No tech support | 41.64% | With tech support: 15.17% |

Month-to-month customers are 55% of the customer base but account for about 89% of all churned customers (1,655 of 1,869).

## Churn risk score

Each customer receives points for risk factors, up to a maximum of 8:

| Risk factor | Points |
|---|---|
| Month-to-month contract | 2 |
| Tenure of 12 months or less | 2 |
| Fiber optic internet | 1 |
| Pays by electronic check | 1 |
| No tech support | 1 |
| No online security | 1 |

Tiers: **High** (6 or more), **Medium** (4 to 5), **Low** (3 or less).

| Tier | Customers | Churn rate | Active customers | Monthly revenue of active customers |
|---|---|---|---|---|
| High | 1,856 | 60.34% | 736 | $52,209 |
| Medium | 1,726 | 29.66% | 1,214 | $74,552 |
| Low | 3,461 | 6.85% | 3,224 | $190,225 |

The High tier churns almost nine times as often as the Low tier. The **736 active High-risk customers pay $52,209 per month (about $626,000 per year)**, which makes them the priority group for retention offers.

**Limitation:** the rules were chosen after looking at this same data and tested on it, so the separation between tiers is somewhat optimistic. On new customers, expect weaker results. The score is a tool for prioritising who to contact, not a guarantee.

## Dashboard

**Page 1: Overview**
![Overview](images/page1.png)

**Page 2: Churn drivers**
![Churn drivers](images/page2.png)

**Page 3: At-risk customers**
![At-risk customers](images/page3.png)

A PDF export of the dashboard is in `dashboard.pdf`.

## Recommendations

1. **Move customers off month-to-month contracts.** Offer a discount for switching to a one- or two-year plan. This is the strongest lever in the data.
2. **Protect the first year.** i   recommend   Adding a welcome call and check-ins at months 2 and 6, because nearly half of customers who leave do so within 12 months.
3. **Encourage automatic payment.** Offer a small bill credit to customers paying by electronic check, who churn at about three times the rate of automatic payers.
4. **Trial tech support.** Offer a free 3-month tech support trial to customers without it.
5. **Investigate fiber optic.** A premium product with more than double the churn of DSL points to a pricing or service quality problem worth looking into.

### Illustrative cost and benefit

These figures are assumptions for scenario planning, not results.

If a retention campaign keeps 20% of the 736 active High-risk customers (about 147 customers):

- Revenue saved: about **$10,400 per month**
- Cost, if all 736 receive a 10% discount: about **$5,200 per month**
- Net gain: about **$5,200 per month**, before counting revenue beyond the first month

## What I would do next

- Test the risk score on a newer set of customers to see how well it holds up.
- Run a small pilot of the retention offers with a control group, to measure whether they actually reduce churn.
- Look at why fiber optic customers leave, using billing and support data if available.

## Repository contents

```
telecom-churn-analysis/
  telecom_churn_analysis.sql        MySQL script: load, clean, analyse, score
  telecom_churn_dashboard.pbix      Power BI dashboard
  dashboard.pdf                     PDF export of the dashboard
  images/                           Dashboard screenshots
  README-CHURN.md
```

## Author

[OYEDIRAN  OLUWASEYI] | [Telecom Customer Churn and Retention Analysis

An end-to-end analysis of why telecom customers leave, how much revenue it costs, and which active customers the company should contact first. Built with MySQL and Power BI.

Business problem

Customer churn is expensive: replacing a lost customer costs more than keeping one. This project answers four questions:

How many customers are leaving, and how much revenue does that cost?
What do the customers who leave have in common?
Which active customers are most likely to leave next?
What should the company do about it?
Dataset

Telco Customer Churn on Kaggle (based on IBM sample data): 7,043 customers and 21 columns covering demographics, services, contract, billing, and a Churn Yes/No label.

The raw CSV is not included in this repository. Download it from the link above to reproduce the analysis.

Tools
MySQL 8: data cleaning, exploratory analysis, risk scoring
Power BI Desktop: 3-page interactive dashboard
Method
Loaded the CSV into MySQL as text columns (telco_raw), so blank values would not break the import.
Audited the data: no duplicate customer IDs, consistent category values, and 11 blank TotalCharges values.
Cleaned it into telco_clean: converted numeric columns from text, replaced the blank TotalCharges values with 0, standardised SeniorCitizen to Yes/No, and added a churn_flag column (1 = churned).
Explored churn rates by contract, tenure, internet service, payment method, and tech support.
Scored every customer with a rule-based risk score and grouped them into High, Medium, and Low tiers (telco_risk).
Built the Power BI dashboard on the results, plus a separate table of active High-risk customers (telco_at_risk).
Key findings

Baseline: 1,869 of 7,043 customers churned, a 26.54% churn rate. Churned customers paid $139,131 per month, which is 30.5% of all monthly revenue. That is higher than the customer churn rate because the customers who leave tend to pay more than those who stay.

Driver	Highest-churn group	Churn rate	Comparison
Contract	Month-to-month	42.71%	Two-year: 2.83%
Tenure	0-12 months	47.44%	49+ months: 9.51%
Payment method	Electronic check	45.29%	Credit card (automatic): 15.24%
Internet service	Fiber optic	41.89%	DSL: 18.96%
Tech support	No tech support	41.64%	With tech support: 15.17%

Month-to-month customers are 55% of the customer base but account for about 89% of all churned customers (1,655 of 1,869).

Churn risk score

Each customer receives points for risk factors, up to a maximum of 8:

Risk factor	Points
Month-to-month contract	2
Tenure of 12 months or less	2
Fiber optic internet	1
Pays by electronic check	1
No tech support	1
No online security	1

Tiers: High (6 or more), Medium (4 to 5), Low (3 or less).

Tier	Customers	Churn rate	Active customers	Monthly revenue of active customers
High	1,856	60.34%	736	$52,209
Medium	1,726	29.66%	1,214	$74,552
Low	3,461	6.85%	3,224	$190,225

The High tier churns almost nine times as often as the Low tier. The 736 active High-risk customers pay $52,209 per month (about $626,000 per year), which makes them the priority group for retention offers.

Limitation: the rules were chosen after looking at this same data and tested on it, so the separation between tiers is somewhat optimistic. On new customers, expect weaker results. The score is a tool for prioritising who to contact, not a guarantee.

Dashboard

Page 1: Overview Overview

Page 2: Churn drivers Churn drivers

Page 3: At-risk customers At-risk customers

A PDF export of the dashboard is in dashboard.pdf.

Recommendations
Move customers off month-to-month contracts. Offer a discount for switching to a one- or two-year plan. This is the strongest lever in the data.
Protect the first year. Add a welcome call and check-ins at months 2 and 6, because nearly half of customers who leave do so within 12 months.
Encourage automatic payment. Offer a small bill credit to customers paying by electronic check, who churn at about three times the rate of automatic payers.
Trial tech support. Offer a free 3-month tech support trial to customers without it.
Investigate fiber optic. A premium product with more than double the churn of DSL points to a pricing or service quality problem worth looking into.
Illustrative cost and benefit

These figures are assumptions for scenario planning, not results.

If a retention campaign keeps 20% of the 736 active High-risk customers (about 147 customers):

Revenue saved: about $10,400 per month
Cost, if all 736 receive a 10% discount: about $5,200 per month
Net gain: about $5,200 per month, before counting revenue beyond the first month
What I would do next
Test the risk score on a newer set of customers to see how well it holds up.
Run a small pilot of the retention offers with a control group, to measure whether they actually reduce churn.
Look at why fiber optic customers leave, using billing and support data if available.
Repository contents
telecom-churn-analysis/
  telecom_churn_analysis.sql        MySQL script: load, clean, analyse, score
  telecom_churn_dashboard.pbix      Power BI dashboard
  dashboard.pdf                     PDF export of the dashboard
  images/                           Dashboard screenshots
  README.md
Author

[Your name] | [Telecom Customer Churn and Retention Analysis

An end-to-end analysis of why telecom customers leave, how much revenue it costs, and which active customers the company should contact first. Built with MySQL and Power BI.

Business problem

Customer churn is expensive: replacing a lost customer costs more than keeping one. This project answers four questions:

How many customers are leaving, and how much revenue does that cost?
What do the customers who leave have in common?
Which active customers are most likely to leave next?
What should the company do about it?
Dataset

Telco Customer Churn on Kaggle (based on IBM sample data): 7,043 customers and 21 columns covering demographics, services, contract, billing, and a Churn Yes/No label.

The raw CSV is not included in this repository. Download it from the link above to reproduce the analysis.

Tools
MySQL 8: data cleaning, exploratory analysis, risk scoring
Power BI Desktop: 3-page interactive dashboard
Method
Loaded the CSV into MySQL as text columns (telco_raw), so blank values would not break the import.
Audited the data: no duplicate customer IDs, consistent category values, and 11 blank TotalCharges values.
Cleaned it into telco_clean: converted numeric columns from text, replaced the blank TotalCharges values with 0, standardised SeniorCitizen to Yes/No, and added a churn_flag column (1 = churned).
Explored churn rates by contract, tenure, internet service, payment method, and tech support.
Scored every customer with a rule-based risk score and grouped them into High, Medium, and Low tiers (telco_risk).
Built the Power BI dashboard on the results, plus a separate table of active High-risk customers (telco_at_risk).
Key findings

Baseline: 1,869 of 7,043 customers churned, a 26.54% churn rate. Churned customers paid $139,131 per month, which is 30.5% of all monthly revenue. That is higher than the customer churn rate because the customers who leave tend to pay more than those who stay.

Driver	Highest-churn group	Churn rate	Comparison
Contract	Month-to-month	42.71%	Two-year: 2.83%
Tenure	0-12 months	47.44%	49+ months: 9.51%
Payment method	Electronic check	45.29%	Credit card (automatic): 15.24%
Internet service	Fiber optic	41.89%	DSL: 18.96%
Tech support	No tech support	41.64%	With tech support: 15.17%

Month-to-month customers are 55% of the customer base but account for about 89% of all churned customers (1,655 of 1,869).

Churn risk score

Each customer receives points for risk factors, up to a maximum of 8:

Risk factor	Points
Month-to-month contract	2
Tenure of 12 months or less	2
Fiber optic internet	1
Pays by electronic check	1
No tech support	1
No online security	1

Tiers: High (6 or more), Medium (4 to 5), Low (3 or less).

Tier	Customers	Churn rate	Active customers	Monthly revenue of active customers
High	1,856	60.34%	736	$52,209
Medium	1,726	29.66%	1,214	$74,552
Low	3,461	6.85%	3,224	$190,225

The High tier churns almost nine times as often as the Low tier. The 736 active High-risk customers pay $52,209 per month (about $626,000 per year), which makes them the priority group for retention offers.

Limitation: the rules were chosen after looking at this same data and tested on it, so the separation between tiers is somewhat optimistic. On new customers, expect weaker results. The score is a tool for prioritising who to contact, not a guarantee.

Dashboard

Page 1: Overview Overview

Page 2: Churn drivers Churn drivers

Page 3: At-risk customers At-risk customers

A PDF export of the dashboard is in dashboard.pdf.

Recommendations
Move customers off month-to-month contracts. Offer a discount for switching to a one- or two-year plan. This is the strongest lever in the data.
Protect the first year. Add a welcome call and check-ins at months 2 and 6, because nearly half of customers who leave do so within 12 months.
Encourage automatic payment. Offer a small bill credit to customers paying by electronic check, who churn at about three times the rate of automatic payers.
Trial tech support. Offer a free 3-month tech support trial to customers without it.
Investigate fiber optic. A premium product with more than double the churn of DSL points to a pricing or service quality problem worth looking into.
Illustrative cost and benefit

These figures are assumptions for scenario planning, not results.

If a retention campaign keeps 20% of the 736 active High-risk customers (about 147 customers):

Revenue saved: about $10,400 per month
Cost, if all 736 receive a 10% discount: about $5,200 per month
Net gain: about $5,200 per month, before counting revenue beyond the first month
What I would do next
Test the risk score on a newer set of customers to see how well it holds up.
Run a small pilot of the retention offers with a control group, to measure whether they actually reduce churn.
Look at why fiber optic customers leave, using billing and support data if available.
Repository contents
telecom-churn-analysis/
  telecom_churn_analysis.sql        MySQL script: load, clean, analyse, score
  telecom_churn_dashboard.pbix      Power BI dashboard
  dashboard.pdf                     PDF export of the dashboard
  images/                           Dashboard screenshots
  README.md
Author

[OYEDIRAN  OLUWASEYI] | [https://www.linkedin.com/in/oluwaseyi-oyediran-b8299a185?utm_source=share_via&utm_content=profile&utm_medium=member_android]
