/****** Object:  View [dbo].[vwRicsGroup]    Script Date: 06/07/2021 11:06:27 ******/
CREATE   VIEW [synapse_ce].[vwRicsGroup]
AS
SELECT
	lg.[apuk_localgroupid] AS [Rics_groupId],
	lg.[createdon] AS [Created_On],
	lg.[CreatedBy],
	usrcreatedby.[fullname] AS [CreatedByName],
	lg.[modifiedon] AS [Modified_On],
	lg.[ModifiedBy],
	usrmodifiedby.[fullname] AS [ModifiedByName],
	lg.[OverriddenCreatedOn],
	--lg.[ricsv2_ReportingWorldRegionId],
	--lg.[ricsv2_ReportingWorldRegionIdName],
	lg.[apuk_worldregionid] AS [Rics_WorldRegionId],
	wregion.[apuk_name] AS [Rics_WorldRegion],
	lg.[apuk_reportingsubworldregion] AS [Rics_ReportingSubWorldRegionId], 
	subwrldregion.[name] AS [Rics_ReportingSubWorldRegion],
	--[ricsv2_ReportingSubRegionIdName],
	lg.[apuk_countryid] AS [rics_countryid],
	cntry.[apuk_name] AS [rics_countryidName],
	--lg.[Rics_ReportingRegionId],
	--lg.[Rics_ReportingRegionIdName],
	--lg.[OwnerId],
	--lg.[OwnerIdName],
	lg.[apuk_code] AS [Rics_Code],
	--lg.[Rics_Details],
	--lg.[Rics_GroupType],
	--lg.[RICS_GroupType_Description],
	lg.[apuk_name] AS [Rics_name],
	lg.[apuk_regionid] AS [Rics_RegionId],
	ter.[name] AS [Rics_Region],
	lg.[statecode],
	stStateCode.[LocalizedLabel] AS [StateCode_Description],
	lg.[statuscode],
	stStatusCode.[LocalizedLabel] AS [StatusCode_Description],
	lg.[apuk_name] AS [Rics_ReportingLocalGroup], 
	--lg.[rics_quarterlyperformancereport],
	--lg.[rics_postalcodeprefix],
	lg.[CreatedOnBehalfByName],
	lg.[ModifiedOnBehalfByName],
	--lg.[rics_fetchcontrol],
	cntry.[apuk_name] AS [Country_Name]
FROM synapse_ce.apuk_localgroup lg 
	LEFT JOIN synapse_ce.systemuser usrcreatedby
		ON lg.[createdby] = usrcreatedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser usrmodifiedby
		ON lg.[modifiedby] = usrmodifiedby.[systemuserid]
	LEFT JOIN synapse_ce.StateMetadata stStateCode
		ON lg.[statecode] = stStateCode.[State]
			AND stStateCode.[EntityName] = 'apuk_localgroup'
	LEFT JOIN synapse_ce.StatusMetadata stStatusCode
		ON lg.[statuscode] = stStatusCode.[Status]
			AND stStatusCode.[EntityName] = 'apuk_localgroup'
	LEFT JOIN synapse_ce.apuk_worldregion wregion
		ON lg.[apuk_worldregionid] = wregion.[apuk_worldregionid]
	LEFT JOIN synapse_ce.apuk_country cntry
		ON lg.[apuk_countryid] = cntry.[apuk_countryid]
	LEFT JOIN synapse_ce.territory ter
		ON lg.[apuk_regionid] = ter.[territoryid]
	LEFT JOIN synapse_ce.territory subwrldregion
		ON lg.[apuk_reportingsubworldregion] = subwrldregion.[territoryid]
