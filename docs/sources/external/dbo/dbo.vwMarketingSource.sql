CREATE VIEW [dbo].[vwMarketingSource]
AS
SELECT 
	[Marketing_Source_Id],
	[Marketing_Source],
	[Marketing_Team],
	[CRM_MarketingSource_Id],
	[State_Code]
FROM [Ext].[PBI02_CRM_vwMarketingSource]
