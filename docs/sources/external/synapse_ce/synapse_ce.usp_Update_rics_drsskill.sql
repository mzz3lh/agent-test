CREATE   PROCEDURE [synapse_ce].[usp_Update_rics_drsskill]
AS
BEGIN

	UPDATE tgt SET
		tgt.[SinkCreatedOn] = stg.[SinkCreatedOn],
		tgt.[SinkModifiedOn] = stg.[SinkModifiedOn],
		tgt.[statecode] = stg.[statecode],
		tgt.[statuscode] = stg.[statuscode],
		tgt.[rics_skillcategory] = stg.[rics_skillcategory],
		tgt.[apuk_drsskillsid] = stg.[apuk_drsskillsid],
		tgt.[apuk_drsskillsid_entitytype] = stg.[apuk_drsskillsid_entitytype],
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
		tgt.[apuk_description] = stg.[apuk_description],
		tgt.[createdbyname] = stg.[createdbyname],
		tgt.[createdbyyominame] = stg.[createdbyyominame],
		tgt.[createdon] = stg.[createdon],
		tgt.[importsequencenumber] = stg.[importsequencenumber],
		tgt.[modifiedbyname] = stg.[modifiedbyname],
		tgt.[modifiedbyyominame] = stg.[modifiedbyyominame],
		tgt.[modifiedon] = stg.[modifiedon],
		tgt.[owneridname] = stg.[owneridname],
		tgt.[owneridyominame] = stg.[owneridyominame],
		tgt.[owningbusinessunitname] = stg.[owningbusinessunitname],
		tgt.[rics_drsskillid] = stg.[rics_drsskillid],
		tgt.[rics_name] = stg.[rics_name]
	FROM [synapse_ce].[rics_drsskill] tgt
		INNER JOIN [staging_ce].[rics_drsskill] stg
			ON stg.[Id] = tgt.[Id]

END
