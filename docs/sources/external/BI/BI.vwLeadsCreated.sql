CREATE VIEW [BI].[vwLeadsCreated]
AS

SELECT
	[Lead_Key],
	[ProductGroupId],
	[Product Group Description],
	[Product Group],
	[Marketing Source Description],
	[Marketing Source],
	[Owner],
	[Team],
	[Transaction Date],
	[Created_On],
	[Created_By],
	[Modified_On],
	[Modified_By],
	[Est. Revenue],
	[Status Reason],
	[State Code],
	[Region],
	[Territory],
	[Rating],
	[ContactIDName],
	[CompanyName],
	[Topic]
FROM [Ext].[PBI02_BI_vwLeadsCreated]
