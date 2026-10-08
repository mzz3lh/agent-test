CREATE   PROCEDURE [synapse_ce].[usp_Insert_apuk_drscapacity]
AS
BEGIN

	INSERT INTO [synapse_ce].[apuk_drscapacity]
	(
		[Id],
		[SinkCreatedOn],
		[SinkModifiedOn],
		[statecode],
		[statuscode],
		[createdby],
		[createdby_entitytype],
		[modifiedby],
		[modifiedby_entitytype],
		[owningbusinessunit],
		[owningbusinessunit_entitytype],
		[owninguser],
		[owninguser_entitytype],
		[ownerid],
		[ownerid_entitytype],
		[apuk_drscapacityid],
		[apuk_name],
		[createdbyname],
		[createdbyyominame],
		[createdon],
		[importsequencenumber],
		[modifiedbyname],
		[modifiedbyyominame],
		[modifiedon],
		[owneridname],
		[owneridyominame],
		[owningbusinessunitname]
	)
	SELECT
		stg.[Id],
		stg.[SinkCreatedOn],
		stg.[SinkModifiedOn],
		stg.[statecode],
		stg.[statuscode],
		stg.[createdby],
		stg.[createdby_entitytype],
		stg.[modifiedby],
		stg.[modifiedby_entitytype],
		stg.[owningbusinessunit],
		stg.[owningbusinessunit_entitytype],
		stg.[owninguser],
		stg.[owninguser_entitytype],
		stg.[ownerid],
		stg.[ownerid_entitytype],
		stg.[apuk_drscapacityid],
		stg.[apuk_name],
		stg.[createdbyname],
		stg.[createdbyyominame],
		stg.[createdon],
		stg.[importsequencenumber],
		stg.[modifiedbyname],
		stg.[modifiedbyyominame],
		stg.[modifiedon],
		stg.[owneridname],
		stg.[owneridyominame],
		stg.[owningbusinessunitname]	
	FROM [staging_ce].[apuk_drscapacity] stg
		LEFT JOIN [synapse_ce].[apuk_drscapacity] tgt
			ON stg.[Id] = tgt.[Id]
	WHERE tgt.[Id] IS NULL

END
