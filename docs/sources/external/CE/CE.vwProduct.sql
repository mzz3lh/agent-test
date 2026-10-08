CREATE   VIEW [CE].[vwProduct]
AS 
SELECT 
	[ProductId],
	[Product_Name],
	[Rics_ProductGroupId],
	[RICS_ProductGroup_Name],
	[Product_Number],
	[Created_On],
	[Created_By],
	[CreatedByName],
	[Modified_On],
	[Modified_By],
	[ModifiedByName],
	[Valid_From],
	[Valid_To],
	[State_Code],
	[StateCode_Description],
	[statuscode],
	[StatusCode_Description],
	[ProductType_Code],
	[ProductTypeCode_Description],
	[ParentProductId],
	[ParentProductIdName]
FROM [synapse_ce].[vwProduct]
