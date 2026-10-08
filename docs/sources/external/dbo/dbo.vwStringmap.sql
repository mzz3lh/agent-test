CREATE VIEW [dbo].[vwStringmap]
AS
SELECT 
	[EntityId],
	[EntityName],
	[IsLookupTable],
	[StringMapId],
	[ObjectTypeCode],
	[AttributeName],
	[AttributeValue],
	[Value]
FROM [Ext].[PBI02_CRM_vwStringmap]
