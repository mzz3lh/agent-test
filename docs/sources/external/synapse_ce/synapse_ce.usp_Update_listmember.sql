CREATE   PROCEDURE [synapse_ce].[usp_Update_listmember]
AS
BEGIN

	UPDATE tgt SET
			tgt.[SinkCreatedOn] = stg.[SinkCreatedOn],
			tgt.[SinkModifiedOn] = stg.[SinkModifiedOn],
			tgt.[createdby] = stg.[createdby],
			tgt.[createdby_entitytype] = stg.[createdby_entitytype],
			tgt.[createdonbehalfby] = stg.[createdonbehalfby],
			tgt.[createdonbehalfby_entitytype] = stg.[createdonbehalfby_entitytype],
			tgt.[entityid] = stg.[entityid],
			tgt.[entityid_entitytype] = stg.[entityid_entitytype],
			tgt.[listid] = stg.[listid],
			tgt.[listid_entitytype] = stg.[listid_entitytype],
			tgt.[modifiedby] = stg.[modifiedby],
			tgt.[modifiedby_entitytype] = stg.[modifiedby_entitytype],
			tgt.[modifiedonbehalfby] = stg.[modifiedonbehalfby],
			tgt.[modifiedonbehalfby_entitytype] = stg.[modifiedonbehalfby_entitytype],
			tgt.[ownerid] = stg.[ownerid],
			tgt.[ownerid_entitytype] = stg.[ownerid_entitytype],
			tgt.[createdbyname] = stg.[createdbyname],
			tgt.[createdbyyominame] = stg.[createdbyyominame],
			tgt.[createdon] = stg.[createdon],
			tgt.[createdonbehalfbyname] = stg.[createdonbehalfbyname],
			tgt.[createdonbehalfbyyominame] = stg.[createdonbehalfbyyominame],
			tgt.[entityidtypecode] = stg.[entityidtypecode],
			tgt.[entitytype] = stg.[entitytype],
			tgt.[importsequencenumber] = stg.[importsequencenumber],
			tgt.[listmemberid] = stg.[listmemberid],
			tgt.[modifiedbyname] = stg.[modifiedbyname],
			tgt.[modifiedbyyominame] = stg.[modifiedbyyominame],
			tgt.[modifiedon] = stg.[modifiedon],
			tgt.[modifiedonbehalfbyname] = stg.[modifiedonbehalfbyname],
			tgt.[modifiedonbehalfbyyominame] = stg.[modifiedonbehalfbyyominame],
			tgt.[name] = stg.[name],
			tgt.[overriddencreatedon] = stg.[overriddencreatedon],
			tgt.[owneridtype] = stg.[owneridtype],
			tgt.[owningbusinessunit] = stg.[owningbusinessunit],
			tgt.[owninguser] = stg.[owninguser]
	FROM [synapse_ce].[listmember] tgt
		INNER JOIN [staging_ce].[listmember] stg
			ON tgt.[Id] = stg.[Id]


END
