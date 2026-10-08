CREATE   VIEW [synapse_ce].[vwCounsellorRelationship]
AS
SELECT 
	cr.[apuk_counsellorrelationshipid],
	cr.[apuk_name],
	cr.[createdon],
	cr.[createdby],
	usrcreatedby.[fullname] AS [CreatedByName],
	cr.[modifiedon],
	cr.[modifiedby],
	usrmodifiedby.[fullname] AS [ModifiedByName],
	cr.[ownerid],
	ownid.[fullname] AS [OwnerIdName],
	cr.[apuk_counsellorid],
	cr.[apuk_enrolmentid],
	cr.[apuk_contactid],
	cr.[apuk_startdate],
	cr.[apuk_enddate],
	cr.[statecode],
	stStateCode.[LocalizedLabel] AS [StateCode_Description],
	cr.[statuscode],
	stStatusCode.[LocalizedLabel] AS [StatusCode_Description],
	cr.[apuk_counsellormembernumber]
FROM synapse_ce.apuk_counsellorrelationship cr
	LEFT JOIN synapse_ce.systemuser usrcreatedby
		ON cr.[createdby] = usrcreatedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser usrmodifiedby
		ON cr.[modifiedby] = usrmodifiedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser ownid
		ON cr.[ownerid] = ownid.[systemuserid]
	LEFT JOIN synapse_ce.StateMetadata stStateCode
		ON cr.[statecode] = stStateCode.[State]
			AND stStateCode.[EntityName] = 'apuk_counsellorrelationship'
	LEFT JOIN synapse_ce.StatusMetadata stStatusCode
		ON cr.[statuscode] = stStatusCode.[Status]
			AND stStatusCode.[EntityName] = 'apuk_counsellorrelationship'
WHERE NOT EXISTS (
		SELECT contactid
		FROM CE.tblContact_Test_Records TST
		WHERE TST.contactid = cr.[apuk_contactid]
		)
