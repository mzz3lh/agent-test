CREATE   VIEW [synapse_ce].[vwProductGroup]
AS
SELECT 
	[ProductGroupId],
	[ProductGroup],
	[TargetGroup],
	[RICS_ProductGroupId],
	[State_Code],
	[Created_On],
	[Created_By],
	[Modified_On],
	[Modified_By],
	[GlobalProductGroup],
	[Ricsv2_Type],
	[Ricsv2_Type_Description]
FROM [DataRep].[tblProductGroup]
