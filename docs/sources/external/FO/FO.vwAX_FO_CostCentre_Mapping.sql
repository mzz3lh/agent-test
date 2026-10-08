CREATE   VIEW [FO].[vwAX_FO_CostCentre_Mapping]
AS
SELECT
	[AX_CostCentreCode],
	[AX_CC_Description],
	[FO_CostCentreCode],
	[FO_CC_Description],
	[CC_Owner],
	[Default_Country]
FROM [FO].[tblAX_FO_CostCentre_Mapping]
