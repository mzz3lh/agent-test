CREATE   VIEW [Subs].[vwSubsContact] AS

WITH 
Mem_Stat AS (
	SELECT
		[Contact No.]
	FROM Subs.tblSubsMemberStatuses ST
	GROUP BY [Contact No.]
),
RREC AS (
	SELECT
		 apuk_contactid
		,MIN(apuk_applicationtypeid_name) AS apuk_applicationtypeid_name
	FROM CE.vwRicsRecord REC
	GROUP BY apuk_contactid
)
SELECT 
	 CON.[ContactId] AS 'Contact ID'
	,CON.[Rics_contactno] AS 'Contact No'
	,CURR.isocurrencycode AS 'Currency'
	,CON.[rics_localgroupid] AS 'Local Group ID'
	,CON.[AccountId] AS 'Account ID'
	,CON.[FirstName] AS 'First Name'
	,CON.[LastName] AS 'Surname'
	,CAST(CON.[BirthDate] AS DATE) AS 'DOB'
	,DATEDIFF(YY,BirthDate, GETDATE()) AS 'Age'
	,COALESCE(GenderCode_Description, 'NULL') AS 'Gender'
	,CON.[StateCode]
	,COALESCE([Rics_MemberGrade], -1) AS Rics_MemberGrade
	,CON.[MemberGrade_Description] AS 'Member Grade'
	,CAST(CON.[Rics_LapsedDate] AS DATE) AS 'Lapsed Date'
	,IIF(MONTH(CON.Rics_LapsedDate) >= 10, YEAR(CON.Rics_LapsedDate) + 1, YEAR(CON.Rics_LapsedDate)) AS 'Lapsed_Campaign_Year'
	,CON.[Rics_LapsedCode] AS 'Lapsed Code'
	,CON.[Rics_LapsedCode_Description] AS 'Lapsed Reason'
	,CASE WHEN CON.Rics_LapsedCode IS NOT NULL THEN 'Y' ELSE 'N' END AS 'Is Lapsed'
	,CON.[Rics_PaymentMethod]
	,CON.[Rics_PaymentMethod_Description] AS 'Payment Method (Contact)'
	,CON.[Rics_PaymentCycle]
	,CON.[Rics_PaymentCycle_Description] AS 'Pay Cycle'
	,CON.[Rics_PreventLapse]
	,CON.[Rics_PreventLapse_Description] AS 'Prevent Lapse'
	,CON.[apuk_designation]
	,CON.[apuk_designation_description] AS 'Designation'
	,EMailAddress1 AS 'Email'
	,COALESCE(CON.EMailAddress1, masked@example.invalid') AS 'isurv email'
	,CON.apuk_applicanttype_description AS 'Applicant Type'
	,RREC.apuk_applicationtypeid_name AS 'Application Type'
FROM [synapse_ce].[tblContact_BI] CON
	LEFT JOIN synapse_ce.transactioncurrency CURR
		ON CURR.transactioncurrencyid = CON.TransactionCurrencyId
	LEFT JOIN RREC RREC
		ON RREC.apuk_contactid = CON.ContactId
WHERE EXISTS (
	SELECT MS.[Contact No.]
	FROM Mem_Stat MS
	WHERE MS.[Contact No.] = CON.Rics_contactno
	) --Appears in Subs Process
