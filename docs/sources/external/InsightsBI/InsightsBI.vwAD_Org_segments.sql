-- Create or replace the view INSIGHTSBI.vwOrg_segments
CREATE VIEW [InsightsBI].[vwAD_Org_segments] AS 

-- Define a common table expression (CTE) for all active accounts
WITH all_accounts AS (
	SELECT 
		accountid,
		AccountNumber,
		name,
		rics_registeredname,
		rics_tradingname,
		Rics_AccountSubTypeName,
		rics_officenumber,
		Rics_LegalStatus,
		Rics_LegalStatusName,
		Rics_IsHeadoffice,
		ricsv1_tradeaccount,
		ricsv1_isregulatedoffice,
		websiteurl,
		emailaddress1,
		rics_namedaccount AS commercial_account_key,
		rics_namedaccountName AS commercial_account_name,
		rics_countryidName,
		Rics_LocalGroupId,
		Rics_LocalGroupIdName,
		ParentAccountId,
		ParentAccountIdName,
		rics_firmnumber,
		KeyAccount
	FROM ce.vwaccount
	WHERE StateCode_Description = 'Active'
),

-- Define a CTE for regulated firms based on specific criteria
regulated_firms AS (
	SELECT 
		[Firm Number],
		[Scheme ID],
		[Scheme Name],
		[Scheme Reference],
		[Scheme License Status]
	FROM [RegsBI].[vwaRegulated_Schemes]
	WHERE [scheme type] = 'Regulated by RICS'
),

-- Define a CTE to count the number of qualified employees per account
number_of_surveyors AS (
	SELECT 
		a.rics_firmnumber,
		COUNT(DISTINCT b.contactid) AS qualified_employees
	FROM ce.vwaccount AS a
	LEFT JOIN ce.vwContact AS b ON a.AccountId = b.AccountId
	WHERE b.MemberGrade_Description IN ('Qualified Professional', 'Qualified Professional - 2 years')
	  AND b.StateCode_Description = 'Active'
	  AND b.Rics_LapsedCode IS NULL
	  AND a.StateCode_Description = 'Active'
	GROUP BY a.rics_firmnumber
),

number_of_candidates AS	 (
	SELECT 
		a.rics_firmnumber,
		COUNT(DISTINCT b.contactid) AS NUMBER_OF_CANDIDATES_NON_STALLED
	FROM ce.vwaccount AS a
	LEFT JOIN ce.vwContact AS b ON a.AccountId = b.AccountId
	WHERE b.MemberGrade_Description ='Candidate'
	  AND b.StateCode_Description = 'Active'
	  AND b.Rics_LapsedCode IS NULL
	  AND a.StateCode_Description = 'Active'
	  and b.CreatedOn >= DATEADD(year,-2,GETDATE())
	GROUP BY a.rics_firmnumber
),

-- Define a CTE for UK companies
UK_companies AS (
	SELECT DISTINCT 
		AccountId,
		rics_firmnumber
	FROM ce.vwAccount 
	WHERE rics_countryidName = 'United Kingdom'
	  AND StateCode_Description = 'Active'
),

-- Define a CTE to flag if a firm has UK presence and operates internationally
uk_international_flag AS (
	SELECT
		a.rics_firmnumber,
		COUNT(DISTINCT rics_countryid) AS number_of_countries,
		MAX(CASE WHEN b.accountid IS NOT NULL THEN 1 ELSE 0 END) AS uk_presence
	FROM ce.vwAccount AS a
	LEFT JOIN UK_companies AS b ON a.rics_firmnumber = b.rics_firmnumber
	WHERE StateCode_Description = 'Active'
	GROUP BY a.rics_firmnumber
),

-- Combine all data from previous CTEs into one CTE
all_data AS (
	SELECT 
		a.accountid,
		a.AccountNumber,
		a.name,
		a.rics_registeredname,
		a.rics_tradingname,
		a.Rics_AccountSubTypeName,
		a.rics_officenumber,
		a.Rics_LegalStatus,
		a.Rics_LegalStatusName,
		a.Rics_IsHeadoffice,
		a.ricsv1_tradeaccount,
		a.ricsv1_isregulatedoffice,
		websiteurl,
		emailaddress1,
		a.commercial_account_key,
		a.commercial_account_name,
		a.rics_countryidName,
		a.Rics_LocalGroupId,
		a.Rics_LocalGroupIdName,
		LG.apuk_regionid_name,
		lg.apuk_worldregionid_name,
		a.ParentAccountId,
		a.ParentAccountIdName,
		a.rics_firmnumber,
		a.KeyAccount,
		CASE WHEN b.[Scheme ID] IS NOT NULL THEN 1 ELSE 0 END AS regulated_firm_flag,
		c.qualified_employees,
		NOC.NUMBER_OF_CANDIDATES_NON_STALLED,
		CASE WHEN d.number_of_countries = 1 AND d.uk_presence = 1 THEN 1 ELSE 0 END AS UK_Only_Flag,
		CASE 
			WHEN (Rics_AccountSubTypeName = 'Statutory Body/University ' AND name LIKE '%University%') THEN 1
			WHEN (Rics_AccountSubTypeName = 'Statutory Body/University ' AND rics_tradingname LIKE '%University%') THEN 1
			WHEN (Rics_AccountSubTypeName = 'Statutory Body/University ' AND rics_registeredname LIKE '%University%') THEN 1
			WHEN (Rics_AccountSubTypeName = 'Statutory Body/University ' AND commercial_account_name LIKE '%University%') THEN 1
			WHEN (Rics_AccountSubTypeName = 'Statutory Body/University ' AND ParentAccountIdName LIKE '%University%') THEN 1
			WHEN (Rics_AccountSubTypeName = 'Statutory Body/University ' AND websiteurl LIKE '%.ac.uk%') THEN 1
			WHEN (Rics_AccountSubTypeName = 'Statutory Body/University ' AND websiteurl LIKE '%.edu%') THEN 1
			WHEN (Rics_AccountSubTypeName = 'Statutory Body/University ' AND emailaddress1 LIKE '%.ac.uk%') THEN 1
			WHEN (Rics_AccountSubTypeName = 'Statutory Body/University ' AND emailaddress1 LIKE '%.edu%') THEN 1
			ELSE 0 
		END AS University_flag,
		CASE 
			WHEN commercial_account_key IS NOT NULL THEN 1 
			ELSE 0 
		END AS commercial_account_flag
	FROM all_accounts AS a
	LEFT JOIN regulated_firms AS b ON a.rics_firmnumber = b.[Firm Number]
	LEFT JOIN number_of_surveyors AS c ON a.rics_firmnumber = c.rics_firmnumber
	LEFT JOIN number_of_candidates AS NOC ON A.rics_firmnumber = NOC.rics_firmnumber
	LEFT JOIN uk_international_flag AS d ON a.rics_firmnumber = d.rics_firmnumber 

	LEFT JOIN CE.vwLocalGroup LG
	ON A.Rics_LocalGroupId = LG.apuk_localgroupid
),

-- Define the final CTE to segment organizations based on specific criteria
segments AS (
	SELECT 
		accountid,
		AccountNumber,
		name,
		rics_registeredname,
		rics_tradingname,
		Rics_AccountSubTypeName,
		rics_officenumber,
		Rics_LegalStatus,
		Rics_LegalStatusName,
		Rics_IsHeadoffice,
		ricsv1_tradeaccount,
		ricsv1_isregulatedoffice,
		commercial_account_key,
		commercial_account_name,
		rics_countryidName,
		Rics_LocalGroupId,
		Rics_LocalGroupIdName,
		apuk_regionid_name,
		apuk_worldregionid_name,
		ParentAccountId,
		ParentAccountIdName,
		rics_firmnumber,
		regulated_firm_flag,
		University_flag,
		KeyAccount,
		qualified_employees,
		NUMBER_OF_CANDIDATES_NON_STALLED,
		UK_Only_Flag,
		-- Define the organizational segment based on various conditions
		CASE	
			WHEN (regulated_firm_flag = 1 AND qualified_employees >= 50)
				THEN 'Regulated Large Firm'
			WHEN (regulated_firm_flag = 1 AND qualified_employees > 1)
				THEN 'Regulated SME'
			WHEN (regulated_firm_flag = 1 AND qualified_employees = 1)
				THEN 'Regulated Single Member Firm'
			WHEN (regulated_firm_flag = 0 AND University_flag = 1) 
				THEN 'Educational Facility'
			WHEN (regulated_firm_flag = 0 AND Rics_AccountSubTypeName = 'Education')
				THEN 'Educational Facility'
			WHEN (regulated_firm_flag = 0 AND Rics_AccountSubTypeName IN ('Local Authority', 'Central Government', 'Public Sector/Other'))
				THEN 'Public Sector'
			WHEN (regulated_firm_flag = 0 AND Rics_AccountSubTypeName = 'Statutory Body/University' AND University_flag = 0)
				THEN 'Public Sector'
			WHEN (regulated_firm_flag = 0 AND qualified_employees > 0)
				THEN 'Non-regulated member Firm'
			WHEN (regulated_firm_flag = 0 AND commercial_account_flag = 1)
				THEN 'Commercial Account Stakeholder'
			ELSE 'Business Stakeholder' 
		END AS AD_Organisation_segment
	FROM all_data
)

-- Select all data from the segments CTE
SELECT *
FROM segments;
