CREATE VIEW [BI].[vwClosedOpps]
AS

SELECT
	[Opportunity_Key],
	[SalesCycleStage],
	[Product Group Description],
	[ProductGroupId],
	[Product Group],
	[Marketing Source],
	[Marketing Team],
	[Transaction Date],
	[Actual Close Date],
	[Topic],
	[Owner],
	[SalesTeam],
	[Potential_Customer],
	[Commercial_Account],
	[Potential Customer],
	[Close_Probability],
	[Created_By],
	[Created_On],
	[Modified_On],
	[Modified_By],
	[Description],
	[Territory],
	[rics_grading],
	[Opportunity_State],
	[Opportunity_Status],
	[ricsv1_OpportunitySource],
	[OpportunitySource_Description],
	[Actual Revenue],
	[Estimated Revenue]
FROM [Ext].[PBI02_BI_vwClosedOpps]
