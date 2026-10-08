CREATE   VIEW [CE].[vwADRProvider]
AS
SELECT
	[apuk_adrproviderid],
	[apuk_name],
	[createdon],
	[createdby],
	[CreatedByName],
	[modifiedon],
	[modifiedby],
	[ModifiedByName],
	[apuk_showforvrlist],
	[apuk_showforfirmregulation],
	[apuk_hasmessage],
	[organizationid],
	[apuk_validfrom],
	[apuk_validto],
	[apuk_messagetext],
	[statecode],
	[StateCode_Description],
	[statuscode],
	[StatusCode_Description]
FROM [synapse_ce].[vwAdrprovider]
