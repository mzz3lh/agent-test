CREATE      VIEW [FO].[vwTrialBalanceCategories] AS

SELECT * FROM (
	VALUES
(10001, 'Subscription Income', 'Revenue', 1, 'P&L', 1, 'Gross Margin', 1),
(10002, 'Elections & Enrolments', 'Revenue', 1, 'P&L', 1, 'Gross Margin', 1),
(10003, 'Commercial Income', 'Revenue', 1, 'P&L', 1, 'Gross Margin', 1),
(10004, 'Regulation Income', 'Revenue', 1, 'P&L', 1, 'Gross Margin', 1),
(10005, 'Readmission Fees', 'Revenue', 1, 'P&L', 1, 'Gross Margin', 1),
(10006, 'Surcharges', 'Revenue', 1, 'P&L', 1, 'Gross Margin', 1),
(10007, 'SBE Income', 'Revenue', 1, 'P&L', 1, 'Gross Margin', 1),
(10008, 'GGS Restaurant Income', 'Revenue', 1, 'P&L', 1, 'Gross Margin', 1),
(10009, 'Tenancy Deposit Scheme', 'Revenue', 1, 'P&L', 1, 'Gross Margin', 1),

(10101, 'Commercial (CoS)', 'Cost of Sales', 2, 'P&L', 1, 'Gross Margin', 1),
(10102, 'Elections & Enrolments (CoS)', 'Cost of Sales', 2, 'P&L', 1, 'Gross Margin', 1),
(10103, 'Standards & Regulation', 'Cost of Sales', 2, 'P&L', 1, 'Gross Margin', 1),
(10104, 'Credit Cards', 'Cost of Sales', 2, 'P&L', 1, 'Gross Margin', 1),
(10105, 'Bad Debt Provision', 'Cost of Sales', 2, 'P&L', 1, 'Gross Margin', 1),
(10201, 'Payroll Costs', 'People Costs', 3, 'P&L', 1, 'Total Costs', 2),
(10202, 'Temp/Contractors', 'People Costs', 3, 'P&L', 1, 'Total Costs', 2),
(10203, 'Staff Travel and Team Building', 'People Costs', 3, 'P&L', 1, 'Total Costs', 2),
(10204, 'Staff Development/Wellbeing', 'People Costs', 3, 'P&L', 1, 'Total Costs', 2),
(10205, 'Bonus Provision', 'People Costs', 3, 'P&L', 1, 'Total Costs', 2),
(10206, 'Recruitment Costs', 'People Costs', 3, 'P&L', 1, 'Total Costs', 2),
(10301, 'IT Costs', 'Other Operating Costs', 4, 'P&L', 1, 'Total Costs', 2),
(10302, 'Office & Property Costs', 'Other Operating Costs', 4, 'P&L', 1, 'Total Costs', 2),
(10303, 'Insurance', 'Other Operating Costs', 4, 'P&L', 1, 'Total Costs', 2),
(10304, 'Professional / Consultancy Fees', 'Other Operating Costs', 4, 'P&L', 1, 'Total Costs', 2),
(10305, 'Marketing', 'Other Operating Costs', 4, 'P&L', 1, 'Total Costs', 2),
(10306, 'Corporate Subscriptions', 'Other Operating Costs', 4, 'P&L', 1, 'Total Costs', 2),
(10307, 'Legal Fees', 'Other Operating Costs', 4, 'P&L', 1, 'Total Costs', 2),
(10308, 'Audit, Tax & Financial Compliance', 'Other Operating Costs', 4, 'P&L', 1, 'Total Costs', 2),
(10309, 'Research', 'Other Operating Costs', 4, 'P&L', 1, 'Total Costs', 2),
(10310, 'Sponsorship', 'Other Operating Costs', 4, 'P&L', 1, 'Total Costs', 2),
(10311, 'Catering', 'Other Operating Costs', 4, 'P&L', 1, 'Total Costs', 2),
(10312, 'Other Costs', 'Other Operating Costs', 4, 'P&L', 1, 'Total Costs', 2),
(10313, 'WRB Engagement', 'Other Operating Costs', 4, 'P&L', 1, 'Total Costs', 2),
(10314, 'Depreciation & Amortisation', 'Other Operating Costs', 4, 'P&L', 1, 'Total Costs', 2),
(10315, 'IFMA Service Fee', 'Other Operating Costs', 4, 'P&L', 1, 'Total Costs', 2),
(10316, 'Events', 'Other Operating Costs', 4, 'P&L', 1, 'Total Costs', 2),


(10401, 'Member Costs', 'Governance Costs', 5, 'P&L', 1, 'Total Costs', 2),
(10402, 'External Conferences', 'Governance Costs', 5, 'P&L', 1, 'Total Costs', 2),
(10403, 'Non Exec Fees', 'Governance Costs', 5, 'P&L', 1, 'Total Costs', 2),
(10404, 'Governance Consultancy', 'Governance Costs', 5, 'P&L', 1, 'Total Costs', 2),

(10501, 'Projects', 'Projects', 6, 'P&L', 1, 'Total Costs', 2),

(10601, 'Bank Charges', 'Financial Costs', 7, 'P&L', 1, 'Total Costs', 2),
(10602, 'Interest', 'Financial Costs', 7, 'P&L', 1, 'Total Costs', 2),
(10603, 'Taxation', 'Financial Costs', 7, 'P&L', 1, 'Total Costs', 2),
(10604, 'FX Transaction', 'Financial Costs', 7, 'P&L', 1, 'Total Costs', 2),

/*
(10701, 'D365 Project', 'Strategic Investments', 8, 'P&L', 1, 'Exceptional Items', 3),
(10702, 'D365 Depreciation', 'Strategic Investments', 8, 'P&L', 1, 'Exceptional Items', 3),
(10703, 'Bichard Implementation', 'Strategic Investments', 8, 'P&L', 1, 'Exceptional Items', 3),
(10704, 'Post Review Costs', 'Strategic Investments', 8, 'P&L', 1, 'Exceptional Items', 3),
(10705, 'Other', 'Strategic Investments', 8, 'P&L', 1, 'Exceptional Items', 3),
*/


--Raj Maddala, 2025-01-09 15:30 as requested by Adrian Whelan
(10701, 'Clean D365', 'Strategic Investments', 8, 'P&L', 1, 'Exceptional Items', 3),
(10702, 'Strategic Depreciation', 'Strategic Investments', 8, 'P&L', 1, 'Exceptional Items', 3),
(10703, 'Data Enablement', 'Strategic Investments', 8, 'P&L', 1, 'Exceptional Items', 3),
(10704, 'Business Process Management', 'Strategic Investments', 8, 'P&L', 1, 'Exceptional Items', 3),
(10706, 'Other', 'Strategic Investments', 8, 'P&L', 1, 'Exceptional Items', 3),
(10705, 'Commercialisation', 'Strategic Investments', 8, 'P&L', 1, 'Exceptional Items', 3),
(10707, 'Market & Strategy', 'Strategic Investments', 8, 'P&L', 1, 'Exceptional Items', 3),
(10708, 'Customer Service Experience', 'Strategic Investments', 8, 'P&L', 1, 'Exceptional Items', 3),
(10709, 'Organisational Design', 'Strategic Investments', 8, 'P&L', 1, 'Exceptional Items', 3),
(10710, 'Pipeline Growth', 'Strategic Investments', 8, 'P&L', 1, 'Exceptional Items', 3),
(10711, 'Member Experience', 'Strategic Investments', 8, 'P&L', 1, 'Exceptional Items', 3),
(10712, 'Dynamic Working', 'Strategic Investments', 8, 'P&L', 1, 'Exceptional Items', 3),
(10713, 'Sustainability', 'Strategic Investments', 8, 'P&L', 1, 'Exceptional Items', 3),
(10714, 'Governance', 'Strategic Investments', 8, 'P&L', 1, 'Exceptional Items', 3),
(10715, 'Transformation Delivery', 'Strategic Investments', 8, 'P&L', 1, 'Exceptional Items', 3),
(10716, 'Post Review Costs', 'Strategic Investments', 8, 'P&L', 1, 'Exceptional Items', 3),
(10717, 'Other Projects', 'Strategic Investments', 8, 'P&L', 1, 'Exceptional Items', 3),


(10802, 'Net Investments', 'Reserves Movement', 9, 'P&L', 1, 'Exceptional Items', 3),
(10803, '(Profit)/Loss on disposal of Investments', 'Reserves Movement', 9, 'P&L', 1, 'Exceptional Items', 3),
(10804, 'Intercompany Recharges', 'Reserves Movement', 9, 'P&L', 1, 'Exceptional Items', 3),

(20001, 'Intangible Assets', 'Non-Current Assets', 10, 'Balance Sheet', 2, 'N/A', 4),
(20002, 'Property, Plant & Equipment', 'Non-Current Assets', 10, 'Balance Sheet', 2, 'N/A', 4),
(20003, 'ROU Assets', 'Non-Current Assets', 10, 'Balance Sheet', 2, 'N/A', 4),
(20004, 'Investments in Subsides & Assocs', 'Non-Current Assets', 10, 'Balance Sheet', 2, 'N/A', 4),
(20005, 'Deferred Tax Asset', 'Non-Current Assets', 10, 'Balance Sheet', 2, 'N/A', 4),
(20006, 'Pension Asset', 'Non-Current Assets', 10, 'Balance Sheet', 2, 'N/A', 4),
(20101, 'Inventories', 'Current Assets', 11, 'Balance Sheet', 2, 'N/A', 4),
(20102, 'Available for Sale Investments', 'Current Assets', 11, 'Balance Sheet', 2, 'N/A', 4),
(20103, 'Trade & Other Recievables', 'Current Assets', 11, 'Balance Sheet', 2, 'N/A', 4),
(20104, 'Cash & Cash Equivalents', 'Current Assets', 11, 'Balance Sheet', 2, 'N/A', 4),
(20201, 'Current Tax Liabilities', 'Current Liabilities', 12, 'Balance Sheet', 2, 'N/A', 4),
(20202, 'Trade & Other Payables', 'Current Liabilities', 12, 'Balance Sheet', 2, 'N/A', 4),
(20203, 'ROU Liabilty', 'Current Liabilities', 12, 'Balance Sheet', 2, 'N/A', 4),
(20301, 'Deferred Tax', 'Non Current Liabilities', 13, 'Balance Sheet', 2, 'N/A', 4),
(20302, 'Provisions', 'Non Current Liabilities', 13, 'Balance Sheet', 2, 'N/A', 4),
(20401, 'Revaluation Reserves', 'Reserves', 14, 'Balance Sheet', 2, 'N/A', 4),
(20402, 'Investment Reserves', 'Reserves', 14, 'Balance Sheet', 2, 'N/A', 4),
(20403, 'Other Reserves', 'Reserves', 14, 'Balance Sheet', 2, 'N/A', 4),
(20406, 'Revenue Reserves', 'Reserves', 14, 'Balance Sheet', 2, 'N/A', 4)


	) AS M (
	 [TB Category Code]
	,[TB Category]
	,[TB Category Type]
	,[TB Category Type Sort]
	,[TB Category Group]
	,[TB Category Group Sort]
	,[TB Subcategory Group]
	,[TB Subcategory Group Sort]
	)
