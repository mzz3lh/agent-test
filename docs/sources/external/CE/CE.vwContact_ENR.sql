CREATE   VIEW [CE].[vwContact_ENR] AS

	WITH ENR AS (
		SELECT
		[Contact ID]
		,MIN(CAST([Election Date] AS DATE)) AS 'Election Date'
		FROM CE.vwEnrolments
		GROUP BY [Contact ID]
	)

	SELECT 
	 CON.[ContactId] AS 'Contact ID'
	,CON.[Rics_contactno] AS 'Contact No'
	--,CURR.isocurrencycode AS 'Currency'
	,CON.[rics_localgroupid] AS 'Local Group ID'
	,CON.[AccountId] AS 'Account ID'
	,CON.[FirstName] AS 'Forename'
	,CON.[LastName] AS 'Surname'
	,CAST(CON.[BirthDate] AS DATE) AS 'DOB'
	,DATEDIFF(YY,BirthDate, GETDATE()) AS 'Age'
	,COALESCE(GenderCode_Description, 'NULL') AS 'Gender'
	,COALESCE(Rics_Ethnicity_Description, 'NULL') AS 'Ethnicity'
	,Rics_Disability AS 'Has Disability'
	,COALESCE(CON.apuk_religionorbelief, -1) AS 'Religion Code'
	,CON.[StateCode]
	,COALESCE([Rics_MemberGrade], -1) AS Rics_MemberGrade
	--,CON.[MemberGrade_Description] AS 'Member Grade'
	,CAST(CON.[Rics_LapsedDate] AS DATE) AS 'Lapsed Date'
	,CON.[Rics_LapsedCode] AS 'Lapsed Code'
	,CON.[Rics_LapsedCode_Description] AS 'Lapsed Reason'
	,CASE WHEN CON.Rics_LapsedCode IS NOT NULL THEN 'Y' ELSE 'N' END AS 'Is Lapsed'
	--,CON.[Rics_PaymentMethod]
	--,CON.[Rics_PaymentMethod_Description] AS 'Payment Method (Contact)'
	--,CON.[Rics_PaymentCycle]
	--,CON.[Rics_PaymentCycle_Description] AS 'Pay Cycle'
	--,CON.[Rics_PreventLapse]
	,CON.[Rics_PreventLapse_Description] AS 'Prevent Lapse'
	--,CON.[apuk_designation]
	,CON.[apuk_designation_description] AS 'Designation'
	--,CON.rics_primaryprofessionalgroupid
	,CON.rics_primaryprofessionalgroupidName AS 'Primary Professional Group'
	,CON.apuk_professionalgroupid
	,CON.rics_pathwaytomembershipidName AS 'Pathway (Contact)'
	,CON.Rics_ElectionDate AS 'Election Date'
	--,CON.apuk_hasdisability2
	,CON.apuk_hasdisability2_description AS [Has Disability2]
	,CASE ISNULL(RR.apuk_apprentice,0) --Added DBA/PS 05/11/2024 for U/S 66020 to enable 'Apprentice' flag filter
		WHEN 'True' THEN 'Yes'
		WHEN 'False' THEN 'No'
		ELSE 'No'
	END AS Apprentice
	,A.AccountNumber AS [Account No] --Added DBA/PS 05/11/2024 for U/S 66020
	,A.name AS [Account Name] --Added DBA/PS 05/11/2024 for U/S 66020


	FROM [synapse_ce].[tblContact_BI] CON
	LEFT JOIN ENR 
		ON ENR.[Contact ID] = CON.ContactId
	LEFT JOIN  synapse_ce.vwRicsRecord RR  --Added DBA/PS 05/11/2024 for U/S 66020 to enable 'Apprentice' flag filter
		ON CON.[ContactID] = RR.apuk_contactid
		AND RR.[apuk_ricsrecordid] = CON.apuk_ricsrecordid
	LEFT JOIN [synapse_ce].[vwAccount] A  --Added DBA/PS 05/11/2024 for U/S 66020
		ON A.AccountId = CON.ParentCustomerId
	WHERE ENR.[Contact ID] IS NOT NULL --Limit CON table to only Enrolment relevant records
