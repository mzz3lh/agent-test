CREATE VIEW [Product_Portfolio].[vw_CE_Delegate_Booking_Contact] AS 

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
	--,CON.apuk_hasdisability2 AS [Has Disability2]
	,CON.apuk_hasdisability2_description AS [Has_Disability2]
	FROM [synapse_ce].[tblContact_BI] CON
	WHERE NOT EXISTS (
		SELECT apuk_contactnumber
		FROM Static.tblTestContacts TST
		WHERE TST.apuk_contactnumber = CON.Rics_contactno
		) --Remove Test Records
	AND EXISTS (
		SELECT
		DEL.apuk_contactid
		FROM synapse_ce.apuk_delegatebooking DEL
		WHERE DEL.apuk_contactid = CON.ContactId
		AND DEL.createdon >= '2022-01-01'
		)
