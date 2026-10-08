CREATE   VIEW [CE].[vwCaseregulatorychange]
AS
SELECT 
	regchg.[apuk_caseregulatorychangeid],
	regchg.[apuk_name],
	regchg.[createdon],
	regchg.[createdby],
	regchg.[CreatedByName],
	regchg.[modifiedon],
	regchg.[modifiedby],
	regchg.[ModifiedByName],
	regchg.[ownerid],
	regchg.[OwnerIdName],
	regchg.[apuk_regardingtype],
	regchg.[apuk_regardingtype_description],
	regchg.[apuk_status],
	regchg.[apuk_status_description],
	regchg.[apuk_showonline],
	regchg.[apuk_escalationlevel],
	regchg.[apuk_origin],
	regchg.[apuk_origin_description],
	regchg.[apuk_ruleofconduct2],
	regchg.[apuk_regulatedscheme],
	regchg.[apuk_regulatorycontactid],
	cntRegContact.[FullName] AS [apuk_regulatorycontactidName],
	regchg.[apuk_responsibleprincipal],
	cntRespPpl.[FullName] AS [apuk_responsibleprincipalName],
	regchg.[apuk_areaofpractice],
	ap.[Rics_name] AS [apuk_areaofpracticeName],
	regchg.[apuk_areaofbreach],
	regchg.[apuk_regulatedfirm],
	regfirm.[name] AS [apuk_regulatedfirmName],
	regchg.[owningbusinessunit],
	regchg.[owningbusinessunitName],
	regchg.[apuk_regulatedindividual],
	cntRegInd.[FullName] AS [apuk_regulatedindividualName],
	regchg.[apuk_areaofbreach2],
	regchg.[apuk_areaofbreach3],
	regchg.[createdonbehalfby],
	regchg.[modifiedonbehalfby],
	regchg.[owninguser],
	regchg.[owninguserName],
	regchg.[apuk_subject],
	regchg.[apuk_subject_title],
	regchg.[apuk_subject_description],
	regchg.[apuk_customerid],
	ISNULL(cntcustid.[FullName], acccustid.[Name]) AS [apuk_customeridName],
	regchg.[apuk_caseclosuredate],
	regchg.[apuk_casegroupreference],
	regchg.[apuk_ageofcase],
	regchg.[overriddencreatedon],
	regchg.[apuk_description],
	regchg.[statecode],
	regchg.[StateCode_Description],
	regchg.[statuscode],
	regchg.[StatusCode_Description]
FROM [synapse_ce].[vwCaseregulatorychange] regchg
	LEFT JOIN [synapse_ce].[tblContact_BI] cntRespPpl
		ON regchg.[apuk_responsibleprincipal] = cntRespPpl.[ContactId]
	LEFT JOIN [synapse_ce].[tblContact_BI] cntRegContact
		ON regchg.[apuk_regulatorycontactid] = cntRegContact.[ContactId]
	LEFT JOIN [synapse_ce].[vwRics_areaofpractice] ap
		ON regchg.[apuk_areaofpractice] = ap.[Rics_areaofpracticeId]
	LEFT JOIN [synapse_ce].[Account] regfirm
		ON regchg.[apuk_regulatedfirm] = regfirm.[AccountId]
	LEFT JOIN [synapse_ce].[tblContact_BI] cntRegInd
		ON regchg.[apuk_regulatedindividual] = cntRegInd.[ContactId]
	LEFT JOIN [synapse_ce].[Account] acccustid
		ON regchg.[apuk_customerid] = acccustid.[AccountId]
	LEFT JOIN [synapse_ce].[tblContact_BI] cntcustid
		ON regchg.[apuk_customerid] = cntcustid.[ContactId]
