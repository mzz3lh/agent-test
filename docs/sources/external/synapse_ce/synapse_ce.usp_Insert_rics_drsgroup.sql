CREATE   PROCEDURE [synapse_ce].[usp_Insert_rics_drsgroup]
AS
BEGIN

	INSERT INTO [synapse_ce].[rics_drsgroup]
	(
		[Id],
		[SinkCreatedOn],
		[SinkModifiedOn],
		[statecode],
		[statuscode],
		[createdonbehalfby],
		[createdonbehalfby_entitytype],
		[modifiedby],
		[modifiedby_entitytype],
		[owningbusinessunit],
		[owningbusinessunit_entitytype],
		[owninguser],
		[owninguser_entitytype],
		[ownerid],
		[ownerid_entitytype],
		[createdbyname],
		[createdbyyominame],
		[createdon],
		[importsequencenumber],
		[modifiedbyname],
		[modifiedbyyominame],
		[modifiedon],
		[owneridname],
		[owneridyominame],
		[owningbusinessunitname],
		[rics_drsgroupid],
		[rics_name]
	)
	SELECT
		stg.[Id],
		stg.[SinkCreatedOn],
		stg.[SinkModifiedOn],
		stg.[statecode],
		stg.[statuscode],
		stg.[createdonbehalfby],
		stg.[createdonbehalfby_entitytype],
		stg.[modifiedby],
		stg.[modifiedby_entitytype],
		stg.[owningbusinessunit],
		stg.[owningbusinessunit_entitytype],
		stg.[owninguser],
		stg.[owninguser_entitytype],
		stg.[ownerid],
		stg.[ownerid_entitytype],
		stg.[createdbyname],
		stg.[createdbyyominame],
		stg.[createdon],
		stg.[importsequencenumber],
		stg.[modifiedbyname],
		stg.[modifiedbyyominame],
		stg.[modifiedon],
		stg.[owneridname],
		stg.[owneridyominame],
		stg.[owningbusinessunitname],
		stg.[rics_drsgroupid],
		stg.[rics_name]
	FROM [staging_ce].[rics_drsgroup] stg
		LEFT JOIN [synapse_ce].[rics_drsgroup] tgt
			ON stg.[Id] = tgt.[Id]
	WHERE tgt.[Id] IS NULL

END
