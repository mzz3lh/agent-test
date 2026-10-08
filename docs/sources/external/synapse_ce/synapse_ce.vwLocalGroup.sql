CREATE   VIEW [synapse_ce].[vwLocalGroup]
AS
SELECT 
	lg.[apuk_localgroupid],
	lg.[apuk_name],
	lg.[apuk_code],
	lg.[apuk_regionid],
	ter.[name] AS [apuk_regionid_name],
	lg.[apuk_worldregionid],
	wrg.[apuk_name] AS [apuk_worldregionid_name],
	lg.[apuk_countryid],
	cnt.[apuk_name] AS [apuk_countryid_name],
	lg.[apuk_reportingregion],
	repreg.[name] AS [apuk_reportingregion_name],
	lg.[apuk_subregion],
	subreg.[name] AS [apuk_subregion_name],
	lg.[apuk_reportingsubworldregion],
	subwrldreg.[name] AS [apuk_reportingsubworldregion_name],
	lg.[statecode],
	stStateCode.[LocalizedLabel] AS [StateCode_Description],
	lg.[statuscode],
	stStatusCode.[LocalizedLabel] AS [StatusCode_Description]
FROM synapse_ce.apuk_localgroup lg
	LEFT JOIN synapse_ce.apuk_worldregion wrg
		ON lg.[apuk_worldregionid] = wrg.[apuk_worldregionid]
	LEFT JOIN synapse_ce.apuk_country cnt
		ON lg.[apuk_countryid] = cnt.[apuk_countryid]
	LEFT JOIN synapse_ce.territory ter
		ON lg.[apuk_regionid] = ter.[territoryid]
	LEFT JOIN synapse_ce.territory repreg
		ON lg.[apuk_reportingregion] = repreg.[territoryid]
	LEFT JOIN synapse_ce.territory subreg
		ON lg.[apuk_subregion] = subreg.[territoryid]
	LEFT JOIN synapse_ce.territory subwrldreg
		ON lg.[apuk_reportingsubworldregion] = subwrldreg.[territoryid]
	LEFT JOIN synapse_ce.StateMetadata stStateCode
		ON lg.[statecode] = stStateCode.[State]
			AND stStateCode.[EntityName] = 'apuk_localgroup'
	LEFT JOIN synapse_ce.StatusMetadata stStatusCode
		ON lg.[statuscode] = stStatusCode.[Status]
			AND stStatusCode.[EntityName] = 'apuk_localgroup'
