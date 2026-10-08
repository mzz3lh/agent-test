CREATE   VIEW [CE].[vwrics_industrysector]
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
	[Statecode],
	[StateCode_Description],
	[Statuscode],
	[StatusCode_Description]
FROM [synapse_ce].[vwrics_industrysector]
