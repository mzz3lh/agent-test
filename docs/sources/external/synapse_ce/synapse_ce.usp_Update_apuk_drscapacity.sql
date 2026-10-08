CREATE   PROCEDURE [synapse_ce].[usp_Update_apuk_drscapacity]
AS
BEGIN

	UPDATE tgt SET
		tgt.[SinkCreatedOn] = stg.[SinkCreatedOn],
		tgt.[SinkModifiedOn] = stg.[SinkModifiedOn],
		tgt.[statecode] = stg.[statecode],
		tgt.[statuscode] = stg.[statuscode],
		tgt.[createdby] = stg.[createdby],
		tgt.[createdby_entitytype] = stg.[createdby_entitytype],
		tgt.[modifiedby] = stg.[modifiedby],
		tgt.[modifiedby_entitytype] = stg.[modifiedby_entitytype],
		tgt.[owningbusinessunit] = stg.[owningbusinessunit],
		tgt.[owningbusinessunit_entitytype] = stg.[owningbusinessunit_entitytype],
		tgt.[owninguser] = stg.[owninguser],
		tgt.[owninguser_entitytype] = stg.[owninguser_entitytype],
		tgt.[ownerid] = stg.[ownerid],
		tgt.[ownerid_entitytype] = stg.[ownerid_entitytype],
		tgt.[apuk_drscapacityid] = stg.[apuk_drscapacityid],
		tgt.[apuk_name] = stg.[apuk_name],
		tgt.[createdbyname] = stg.[createdbyname],
		tgt.[createdbyyominame] = stg.[createdbyyominame],
		tgt.[createdon] = stg.[createdon],
		tgt.[importsequencenumber] = stg.[importsequencenumber],
		tgt.[modifiedbyname] = stg.[modifiedbyname],
		tgt.[modifiedbyyominame] = stg.[modifiedbyyominame],
		tgt.[modifiedon] = stg.[modifiedon],
		tgt.[owneridname] = stg.[owneridname],
		tgt.[owneridyominame] = stg.[owneridyominame],
		tgt.[owningbusinessunitname] = stg.[owningbusinessunitname]	
	FROM [synapse_ce].[apuk_drscapacity] tgt
		INNER JOIN [staging_ce].[apuk_drscapacity] stg
			ON stg.[Id] = tgt.[Id]

END
