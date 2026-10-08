CREATE    VIEW [Subs].[vwCorpContact] AS

	SELECT 
	 CON.ContactId AS 'Contact ID'
	,CON.Rics_contactno AS 'Contact No'
	,CURR.isocurrencycode AS 'Currency'
	,CON.rics_localgroupid AS 'Local Group ID'
	,CON.AccountId AS 'Account ID'
	,CON.FirstName AS 'First Name'
	,CON.LastName AS 'Surname'
	,CAST(CON.BirthDate AS DATE) AS 'DOB'
	,DATEDIFF(YY,BirthDate, GETDATE()) AS 'Age'
	,CON.StateCode
	,CON.Rics_MemberGrade
	,CON.MemberGrade_Description AS 'Member Grade'
	,CAST(CON.Rics_LapsedDate AS DATE) AS 'Lapsed Date'
	,CON.Rics_LapsedCode AS 'Lapsed Code'
	,CON.Rics_LapsedCode_Description AS 'Lapsed Reason'
	,CASE WHEN CON.Rics_LapsedCode IS NOT NULL THEN 'Y' ELSE 'N' END AS 'Is Lapsed'
	,CON.Rics_PaymentMethod
	,CON.Rics_PaymentMethod_Description AS 'Payment Method (Contact)'
	,CON.Rics_PaymentCycle
	,CON.Rics_PaymentCycle_Description AS 'Pay Cycle'
	,CON.Rics_PreventLapse
	,CON.Rics_PreventLapse_Description AS 'Prevent Lapse'
	,CON.apuk_designation
	,CON.apuk_designation_description AS 'Designation'
	,CON.Rics_Donotchase_Description AS 'DNC'
	,EMailAddress1 AS 'Email'
	FROM [synapse_ce].[tblContact_BI] CON
		LEFT JOIN synapse_ce.TransactionCurrency CURR
			ON CURR.transactioncurrencyid = CON.TransactionCurrencyId
	WHERE 
		NOT EXISTS (
			SELECT apuk_contactnumber
			FROM Static.tblTestContacts TST
			WHERE TST.apuk_contactnumber = CON.Rics_contactno
			) --Remove Test Records
		AND EXISTS (
			SELECT CVC.[Contact No]
			FROM Subs.tblCorpValidContacts CVC
			WHERE CVC.[Contact No] = CON.Rics_contactno
			) --Appears in Corp Process
