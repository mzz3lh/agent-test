CREATE    VIEW  [CE].[vwContact_MemDemo] AS

	WITH VALREG AS (
		SELECT 
		[Contact ID]
		FROM [RegsBI].[vwaRegulated_Schemes]
		WHERE [Scheme Type] = 'Valuer Registration'
		GROUP BY [Contact ID]
		)

	SELECT 
	 CON.[ContactId] AS 'Contact ID'
	,CON.[Rics_contactno] AS 'Contact No'
	,acc.[name] AS 'Account Name' 
	,acc.[rics_namedaccountName] AS 'Comm. Account'
	--,CURR.isocurrencycode AS 'Currency'
	,CON.[rics_localgroupid] AS 'Local Group ID'
	,CON.[AccountId] AS 'Account ID'
	,CON.[FirstName] AS 'Forename'
	,CON.[LastName] AS 'Surname'
	,CAST(CON.[BirthDate] AS DATE) AS 'DOB'
	,DATEDIFF(YY,BirthDate, GETDATE()) AS 'Age'
	,COALESCE(GenderCode_Description, 'NULL') AS 'Gender'
	,COALESCE(Rics_Ethnicity, -1) AS 'Ethnicity Code'
	,COALESCE(Rics_Ethnicity_Description, 'NULL') AS 'Ethnicity' 
	,Rics_Disability AS 'Has Disability'
	,COALESCE(apuk_religionorbelief, -1) AS 'Religion Code'
	--,CON.[StateCode]
	,COALESCE(CON.[Rics_MemberGrade], -1) AS Rics_MemberGrade
	--,CON.[MemberGrade_Description] AS 'Member Grade'
	,CAST(CON.[Rics_LapsedDate] AS DATE) AS 'Lapsed Date'
	--,CON.[Rics_LapsedCode] AS 'Lapsed Code'
	--,CON.[Rics_LapsedCode_Description] AS 'Lapsed Reason'
	--,CASE WHEN CON.Rics_LapsedCode IS NOT NULL THEN 'Y' ELSE 'N' END AS 'Is Lapsed'
	--,CON.[Rics_PaymentMethod]
	--,CON.[Rics_PaymentMethod_Description] AS 'Payment Method (Contact)'
	--,CON.[Rics_PaymentCycle]
	--,CON.[Rics_PaymentCycle_Description] AS 'Pay Cycle'
	--,CON.[Rics_PreventLapse]
	,CON.[Rics_PreventLapse_Description] AS 'Prevent Lapse'
	--,CON.[apuk_designation]
	,CON.[apuk_designation_description] AS 'Designation'
	,CON.apuk_professionalgroupid AS 'Professional Group Code'
	,CON.rics_primaryprofessionalgroupidName AS 'Primary Professional Group'
	,CON.rics_pathwaytomembershipid AS 'Pathway (Contact) Code'
	--,CON.rics_pathwaytomembershipidName AS 'Pathway (Contact)'
	,CON.Rics_ElectionDate AS 'Election Date'
	,CASE WHEN VALREG.[Contact ID] IS NOT NULL THEN 'Y' END AS 'Valuer Registered'
	--,CON.apuk_hasdisability2 AS [Has Disability2]
	,CON.apuk_hasdisability2_description AS [Has_Disability2]
	,ECL.[Corporate Enrolment]
	
	--Added Enrolment pathway, RM/2025-08-26
	,ECL.[Pathway ID] AS [Enrolment Pathway Id]
	

	FROM [synapse_ce].[tblContact_BI] CON
	LEFT JOIN VALREG VALREG
		ON VALREG.[Contact ID] = CON.ContactId
	LEFT JOIN [CE].[vwEnrolment_Candidate_Last] ECL --Added 05/11/2024 by P.S. to include corporate enrolment indicator, Requested by Amanda Smith 05/11/2024.
		ON ECL.[Contact ID] = CON.ContactId
	LEFT JOIN synapse_ce.vwAccount acc
		ON CON.AccountId = acc.AccountId
	WHERE CON.StateCode = 0 --Active
	AND CON.Rics_MemberGrade IN (200000000, 200000001, 200000002) --Candidate/Qual Pro/ Qual Pro 2
	AND Rics_LapsedCode IS NULL
	AND NOT EXISTS (
		SELECT apuk_contactnumber
		FROM Static.tblTestContacts TST
		WHERE TST.apuk_contactnumber = CON.Rics_contactno
		) --Remove Test Records
