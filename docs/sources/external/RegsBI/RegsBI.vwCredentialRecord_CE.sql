CREATE   VIEW [RegsBI].[vwCredentialRecord_CE]
AS

SELECT 
	cr.[apuk_credentialrecordid],
	cr.[apuk_name],
	cr.[createdon],
	cr.[createdby],
	cr.[CreatedByName],
	cr.[createdonbehalfby],
	cr.[createdonbehalfbyName],
	cr.[modifiedon],
	cr.[modifiedby],
	cr.[modifiedbyName],
	cr.[modifiedonbehalfby],
	cr.[modifiedonbehalfbyName],
	cr.[ownerid],
	cr.[owneridName],
	cr.[apuk_credential],
	cr.[apuk_credentialName],
	cr.[apuk_contact],
	cr.[apuk_contactName],
	cr.[apuk_startdate],
	cr.[apuk_enddate],
	cr.[apuk_qualificationpacksent],
	cr.[statuscode],
	cr.[StatusCode_Description],
	cr.[statecode],
	cr.[StateCode_Description],
	cr.[overriddencreatedon],
	cr.[owningbusinessunit],
	cr.[owningbusinessunitName]
FROM [CE].[vwCredentialRecord] cr
