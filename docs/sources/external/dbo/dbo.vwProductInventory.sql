CREATE VIEW [dbo].[vwProductInventory]
AS

SELECT
	[Market],
	[Title],
	[ProductGroupId],
	[Product Group Description],
	[Product Group],
	[Product],
	[Delivery_StartDate],
	[Delivery_EndDate],
	[Delivery_Month_Type],
	[Lowest_Fee],
	[Highest_Fee],
	[No_Of_Target_Sales],
	[Target_Revenue],
	[Max_Capacity]
FROM [Ext].[PBI02_dbo_vwProductInventory]
