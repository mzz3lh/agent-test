CREATE VIEW [Static].[vwWebEx_Employee] AS

SELECT 
     [Claimant Name]
    ,[E-mail Address]
    ,[Employee ID]
    ,[First Name]
    ,[Last Name]
	,[First Name] + ' ' + [Last Name] AS 'Claimant'
    ,[URN]
    ,[VUK Number]
FROM [Static].[tblWebExpensesDemoExport]
WHERE CAST([Date Created] AS DATE) >= '2015-08-01'
GROUP BY
	 [Claimant Name]
    ,[E-mail Address]
    ,[Employee ID]
    ,[First Name]
    ,[Last Name]
    ,[URN]
    ,[VUK Number]
