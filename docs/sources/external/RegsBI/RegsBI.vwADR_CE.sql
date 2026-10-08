CREATE   VIEW [RegsBI].[vwADR_CE]
AS
SELECT 
	[apuk_adrid],
	[apuk_name],
	[createdon],
	[createdby],
	[CreatedByName],
	[modifiedon],
	[modifiedby],
	[ModifiedByName],
	[ownerid],
	[OwnerIdName],
	[owningbusinessunit],
	[OwningBusinessUnitName],
	[apuk_regulatedschemeid],
	[apuk_regulatedschemeidName],
	[overriddencreatedon],
	[apuk_adrproviderid],
	[apuk_provideridName],
	[apuk_countryid],
	[apuk_countryidName],
	[statecode],
	[StateCode_Description],
	[statuscode],
	[StatusCode_Description]
FROM [CE].[vwADR]
