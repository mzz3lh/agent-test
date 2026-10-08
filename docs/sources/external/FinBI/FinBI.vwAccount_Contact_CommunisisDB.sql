CREATE    VIEW [FinBI].[vwAccount_Contact_CommunisisDB]
AS
SELECT 
	acc.[AccountId] AS [MemberId],
	acc.[AccountNumber] AS [MemberNo],
	acc.[name],
	acc.[Address1_City],
	acc.[Address1_Country],
	acc.[Address1_County],
	acc.[address1_line1],
	acc.[address1_line2],
	acc.[address1_line3],
	acc.[address1_postalcode],
	acc.[donotbulkpostalmail],
	acc.[StateCode_Description] AS [Member Status]
FROM [CE].[vwAccount] acc
WHERE --acc.[StateCode] = 0
	acc.AccountNumber IS NOT NULL
	AND acc.AccountNumber <> '000000'
UNION ALL

SELECT 
	cnt.[ContactId] AS [MemberId],
	cnt.[Rics_contactno] AS [MemberNo],
	cnt.[FullName] AS [Name],
	cnt.[Address1_City],
	cnt.[Address1_Country],
	cnt.[Address1_County],
	cnt.[address1_line1],
	cnt.[address1_line2],
	cnt.[address1_line3],
	cnt.[address1_postalcode],
	CAST(NULL AS bit) AS [donotbulkpostalmail],
	cnt.[StateCode_Description] AS [Member Status]
FROM [CE].[vwContact] cnt
WHERE --cnt.[StateCode] = 0
	cnt.Rics_contactno IS NOT NULL
