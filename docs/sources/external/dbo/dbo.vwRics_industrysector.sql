CREATE VIEW [dbo].[vwRics_industrysector]
AS
SELECT
	[Rics_industrysectorId],
	[Rics_name],
	[Created_On],
	[CreatedBy],
	[CreatedByName],
	[Modified_On],
	[ModifiedBy],
	[ModifiedByName],
	[OwnerId],
	[statecode],
	[StateCode_Description],
	[statuscode],
	[StatusCode_Description]
FROM [Ext].[PBI02_CRM_vwRics_industrysector]
