CREATE VIEW [dbo].[vwProduct]
AS
SELECT 
	[ProductId],
	[Product_Name],
	[Rics_ProductGroupId],
	[RICS_ProductGroup_Name],
	[Product_Number],
	[Created_On],
	[Created_By],
	[Modified_On],
	[Modified_By],
	[Valid_From],
	[Valid_To],
	[State_Code],
	[ProductType_Code],
	[ParentProductId],
	[ParentProductIdName]
FROM [Ext].[PBI02_CRM_vwProduct]
