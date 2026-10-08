CREATE   VIEW [CE].[vwrics_otherprofessionalbody]
AS 
SELECT 
	[Rics_OtherProfessionalBodyId],
	[Rics_Code],
	[Rics_Name],
	[Created_On],
	[CreatedBy],
	[CreatedByName],
	[Modified_On],
	[ModifiedBy],
	[ModifiedByName],
	[statecode],
	[StateCode_Description],
	[statuscode],
	[StatusCode_Description]
FROM [synapse_ce].[vwrics_otherprofessionalbody]
