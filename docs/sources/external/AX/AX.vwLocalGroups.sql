CREATE VIEW [AX].[vwLocalGroups]
AS

SELECT
	[Rics_groupId],
	[Rics_name],
	[rics_rlg],
	[rics_reportinglocalgroup],
	[rics_region],
	[rics_countryidname],
	[CountryCode],
	[CostCentre],
	[country_rn],
	[rics_reportingsubregion],
	[rics_reportingregionidname],
	[rics_reportingsubworldregion],
	[rics_worldregion],
	[WRUKSplit]
FROM [Ext].[PBI02_AX_vwLocalGroups]
