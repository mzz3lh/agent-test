CREATE VIEW [dbo].[vwCostCentres]
AS
SELECT 
	[CostCentreId],
	[CostCentreCode],
	[CRM_CostCentre_Id],
	[State_Code],
	[CostCentre_Description],
	[ProductGroup]
FROM [Ext].[PBI02_CRM_vwCostCentres]
