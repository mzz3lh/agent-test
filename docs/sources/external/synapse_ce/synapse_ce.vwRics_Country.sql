/****** Object:  View [dbo].[vwRics_Country]    Script Date: 06/07/2021 11:06:27 ******/
CREATE   VIEW [synapse_ce].[vwRics_Country]
AS
SELECT 
	cnt.[apuk_countryid] AS [Rics_countryId],
	cnt.[apuk_code] AS [Rics_code],
	cnt.[apuk_name] AS [Rics_country],
	cnt.[createdon] AS [Created_On],
	cnt.[modifiedon] AS [Modified_On],
	--NULL AS [OrganizationId], 
	--NULL AS [OrganizationIdName],
	cnt.[OverriddenCreatedOn],
	cnt.[statecode],
	stStateCode.[LocalizedLabel] AS [StateCode_Description],
	cnt.[statuscode],
	stStatusCode.[LocalizedLabel] AS [StatusCode_Description],
	cnt.[transactioncurrencyid] AS [rics_currencyid],
	curr.[currencyname] AS [rics_currencyidName],
	cnt.[apuk_postcodemandatory] AS [Rics_RequiresPostCode],
	postcodemand.[LocalizedLabel] AS [Rics_RequiresPostCode_Description],
	--NULL AS [Rics_FetchControl],
	--NULL AS [Rics_RegulatedAreaId],
	--NULL AS [Rics_RegulatedAreaIdName],
	--NULL AS [ricsv1_AssessmentMarketId],
	--NULL AS [ricsv1_AssessmentMarketIdName],
	--NULL AS [ricsv2_RICSOfficeEmail],
	--NULL AS [ricsv2_RICSOfficeName],
	--NULL AS [ricsv2_RICSOfficeNumber],
	cnt.[apuk_isvrmandatory] AS [ricsv1_vrmandatory],
	isurvmand.[LocalizedLabel] AS [ricsv1_vrmandatory_Description],
	cnt.[apuk_isregulationmandatory] AS [ricsv1_regulatedmandatory],
	regmand.[LocalizedLabel] AS [ricsv1_regulatedmandatory_Description],
	cnt.[apuk_canapplyforcm] AS [ricsv1_canapplyforclientmoney],
	canapplycm.[LocalizedLabel] AS [ricsv1_canapplyforclientmoney_Description],
	cnt.[apuk_canapplyforgida] AS [ricsv1_canapplyforgima],
	canapplygida.[LocalizedLabel] AS [ricsv1_canapplyforgima_Description],
	cnt.[apuk_regulationmandatorydate] AS [ricsv1_RegulationMandatoryDate]--,
	--NULL AS [ricsv1_VRMandatoryDate]
FROM [synapse_ce].[apuk_country] cnt
	LEFT JOIN synapse_ce.transactioncurrency curr
		ON cnt.[apuk_currencyid] = curr.[transactioncurrencyid]
	LEFT JOIN synapse_ce.OptionSetMetadata postcodemand
		ON cnt.[apuk_postcodemandatory] = postcodemand.[Option]
			AND postcodemand.[EntityName] = 'apuk_country'
			AND postcodemand.[OptionSetName] = 'apuk_postcodemandatory'
	LEFT JOIN synapse_ce.OptionSetMetadata isurvmand
		ON cnt.[apuk_isvrmandatory] = isurvmand.[Option]
			AND isurvmand.[EntityName] = 'apuk_country'
			AND isurvmand.[OptionSetName] = 'apuk_isvrmandatory'
	LEFT JOIN synapse_ce.OptionSetMetadata regmand
		ON cnt.[apuk_isregulationmandatory] = regmand.[Option]
			AND regmand.[EntityName] = 'apuk_country'
			AND regmand.[OptionSetName] = 'apuk_isregulationmandatory'
	LEFT JOIN synapse_ce.OptionSetMetadata canapplycm
		ON cnt.[apuk_canapplyforcm] = canapplycm.[Option]
			AND canapplycm.[EntityName] = 'apuk_country'
			AND canapplycm.[OptionSetName] = 'apuk_canapplyforcm'
	LEFT JOIN synapse_ce.OptionSetMetadata canapplygida
		ON cnt.[apuk_canapplyforgida] = canapplygida.[Option]
			AND canapplygida.[EntityName] = 'apuk_country'
			AND canapplygida.[OptionSetName] = 'apuk_canapplyforgida'
	LEFT JOIN synapse_ce.StateMetadata stStateCode
		ON cnt.[statecode] = stStateCode.[State]
			AND stStateCode.[EntityName] = 'apuk_country'
	LEFT JOIN synapse_ce.StatusMetadata stStatusCode
		ON cnt.[statuscode] = stStatusCode.[Status]
			AND stStatusCode.[EntityName] = 'apuk_country'
