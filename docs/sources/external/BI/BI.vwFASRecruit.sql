CREATE VIEW [BI].[vwFASRecruit]
AS

SELECT
	[FAS_Recruit_Id],
	[Recruit Type],
	[FAS Recruit Group],
	[Transaction Date],
	[Value NET]
FROM [Ext].[PBI02_BI_vwFASRecruit]
