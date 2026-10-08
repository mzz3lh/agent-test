CREATE   VIEW [Expenses].[vwWebEx_Claim] 
AS

SELECT 
     [Approver Name]
    ,[Base Currency]
    ,[Claim]
    ,CAST([Claim Id] AS VARCHAR(20)) AS 'Claim ID'
    ,[Claim Notes]
    ,[Claim Status]
    ,[Claim Total Gross Amount]
    ,[Claim Total Without VAT]
    ,[Claimant Name]
    --,[Cost Centre]
	,CASE
		WHEN [Cost Centre Code] IN ('DEF', '00000', '00000') THEN [Cost Centre]
		WHEN [Cost Centre Code] = '60161m' THEN 'JOURNALS'
		WHEN CHARINDEX([Cost Centre Code] + ' - ', [Cost Centre], 0) > 0
			THEN SUBSTRING([Cost Centre], LEN([Cost Centre Code]) +4, 150)
		WHEN CHARINDEX([Cost Centre Code] + '-', [Cost Centre], 0) > 0
			THEN SUBSTRING([Cost Centre], LEN([Cost Centre Code]) +2, 150)
		WHEN CHARINDEX([Cost Centre Code] + ' ', [Cost Centre], 0) > 0
			THEN SUBSTRING([Cost Centre], LEN([Cost Centre Code]) +2, 150)
		END AS 'Cost Centre'
    ,[Cost Centre Code]
    ,[Date Approved]
    ,[Approver 1]
    ,[Approver 2]
    ,[Approver 3]
    ,[Date Created]
    ,[Date Paid]
    ,[Date Pre-approved]
    ,[Date Submitted]
    ,[Employee ID]
    ,[VUK Number]
FROM [Expenses].[tblWebExpenses_Detailed]
WHERE CAST([Date Created] AS DATE) >= '2015-08-01'
GROUP BY
	 [Approver Name]
    ,[Base Currency]
    ,[Claim]
    ,[Claim Id]
    ,[Claim Notes]
    ,[Claim Status]
    ,[Claim Total Gross Amount]
    ,[Claim Total Without VAT]
    ,[Claimant Name]
    ,[Cost Centre]
    ,[Cost Centre Code]
    ,[Date Approved]
    ,[Approver 1]
    ,[Approver 2]
    ,[Approver 3]
    ,[Date Created]
    ,[Date Paid]
    ,[Date Pre-approved]
    ,[Date Submitted]
    ,[Employee ID]
    ,[VUK Number]
