CREATE   VIEW [synapse_ce].[vwCredentialRecord]
AS
SELECT 
	crr.apuk_credentialrecordid, 
	crr.apuk_name, 
	crr.createdon, 
	crr.createdby,
	crr.createdonbehalfby, 
	crr.modifiedon, 
	crr.modifiedby, 
	crr.modifiedonbehalfby,
	crr.ownerid,
	crr.apuk_credential, 
	cr.[apuk_name] AS [apuk_credentialName],
	crr.apuk_contact, 
	crr.apuk_startdate, 
	crr.apuk_enddate, 
	crr.apuk_qualificationpacksent, 
	crr.statuscode, 
	crr.statecode, 
	crr.overriddencreatedon, 
	crr.owningbusinessunit,
	bunit.[name] AS [owningbusinessunitName]
FROM synapse_ce.apuk_credentialrecord crr
	LEFT JOIN synapse_ce.apuk_credential cr
		ON crr.[apuk_credential] = cr.[apuk_credentialid]
	LEFT JOIN synapse_ce.businessunit bunit
		ON crr.[owningbusinessunit] = bunit.[businessunitid]
	WHERE NOT EXISTS (
		SELECT contactid
		FROM CE.tblContact_Test_Records TST
		WHERE TST.contactid = crr.apuk_contact
		)
