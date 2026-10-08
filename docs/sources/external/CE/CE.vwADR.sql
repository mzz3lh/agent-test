CREATE   VIEW [CE].[vwADR]
AS
SELECT
	adr.[apuk_adrid],
	adr.[apuk_name],
	adr.[createdon],
	adr.[createdby],
	adr.[CreatedByName],
	adr.[modifiedon],
	adr.[modifiedby],
	adr.[ModifiedByName],
	adr.[ownerid],
	adr.[OwnerIdName],
	adr.[owningbusinessunit],
	adr.[OwningBusinessUnitName],
	adr.[apuk_regulatedschemeid],
	regsch.[apuk_name] AS [apuk_regulatedschemeidName],
	adr.[overriddencreatedon],
	adr.[apuk_adrproviderid],
	adrp.[apuk_name] AS [apuk_provideridName],
	adr.[apuk_countryid],
	cntry.[apuk_name] AS [apuk_countryidName],
	adr.[statecode],
	adr.[StateCode_Description],
	adr.[statuscode],
	adr.[StatusCode_Description]
FROM [synapse_ce].[vwadr] adr
	LEFT JOIN [synapse_ce].[vwRegulatedscheme] regsch
		ON adr.[apuk_regulatedschemeid] = regsch.[apuk_regulatedschemeid]
	LEFT JOIN [synapse_ce].[vwADRProvider] adrp
		ON adr.[apuk_adrproviderid] = adrp.[apuk_adrproviderid]
	LEFT JOIN [synapse_ce].[vwCountry] cntry
		ON adr.[apuk_countryid] = cntry.[apuk_countryid]
