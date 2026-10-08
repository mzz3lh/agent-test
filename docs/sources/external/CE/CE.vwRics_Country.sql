CREATE   VIEW [CE].[vwRics_Country]
AS 
SELECT 
	[Rics_countryId],
	[Rics_code],
	[Rics_country],
	[Created_On],
	[Modified_On],
	[OverriddenCreatedOn],
	[statecode],
	[StateCode_Description],
	[statuscode],
	[StatusCode_Description],
	[rics_currencyid],
	[rics_currencyidName],
	[Rics_RequiresPostCode],
	[Rics_RequiresPostCode_Description],
	[ricsv1_vrmandatory],
	[ricsv1_vrmandatory_Description],
	[ricsv1_regulatedmandatory],
	[ricsv1_regulatedmandatory_Description],
	[ricsv1_canapplyforclientmoney],
	[ricsv1_canapplyforclientmoney_Description],
	[ricsv1_canapplyforgima],
	[ricsv1_canapplyforgima_Description],
	[ricsv1_RegulationMandatoryDate]
FROM [synapse_ce].[vwRics_Country]
