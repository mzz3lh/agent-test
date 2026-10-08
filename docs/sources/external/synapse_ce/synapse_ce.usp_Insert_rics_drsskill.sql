CREATE   PROCEDURE [synapse_ce].[usp_Insert_rics_drsskill]
AS
BEGIN

	INSERT INTO [synapse_ce].[rics_drsskill]
	(
		[Id],
		[SinkCreatedOn],
		[SinkModifiedOn],
		[statecode],
		[statuscode],
		[rics_skillcategory],
		[apuk_drsskillsid],
		[apuk_drsskillsid_entitytype],
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
		[apuk_description],
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
		[rics_drsskillid],
		[rics_name]
	)
	SELECT
		stg.[Id],
		stg.[SinkCreatedOn],
		stg.[SinkModifiedOn],
		stg.[statecode],
		stg.[statuscode],
		stg.[rics_skillcategory],
		stg.[apuk_drsskillsid],
		stg.[apuk_drsskillsid_entitytype],
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
		stg.[apuk_description],
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
		stg.[rics_drsskillid],
		stg.[rics_name]
	FROM [staging_ce].[rics_drsskill] stg
		LEFT JOIN [synapse_ce].[rics_drsskill] tgt
			ON stg.[Id] = tgt.[Id]
	WHERE tgt.[Id] IS NULL

END
