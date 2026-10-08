CREATE   VIEW [RegsBI].[vwLocalGroup_CE]
AS

	SELECT
		[apuk_localgroupid],
		[apuk_name],
		[apuk_code],
		[apuk_regionid],
		[apuk_regionid_name],
		[apuk_worldregionid],
		[apuk_worldregionid_name],
		[apuk_countryid],
		[apuk_countryid_name],
		[apuk_reportingregion],
		[apuk_reportingregion_name],
		[apuk_subregion],
		[apuk_subregion_name],
		[apuk_reportingsubworldregion],
		[apuk_reportingsubworldregion_name],
		[statecode],
		[StateCode_Description],
		[statuscode],
		[StatusCode_Description]
	FROM [synapse_ce].[vwLocalGroup]
