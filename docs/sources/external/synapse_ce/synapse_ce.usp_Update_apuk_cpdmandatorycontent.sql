CREATE   PROCEDURE [synapse_ce].[usp_Update_apuk_cpdmandatorycontent]
AS
BEGIN

	UPDATE tgt SET
		tgt.[SinkCreatedOn] = src.[SinkCreatedOn],
		tgt.[SinkModifiedOn] = src.[SinkModifiedOn],
		tgt.[statecode] = src.[statecode],
		tgt.[statuscode] = src.[statuscode],
		tgt.[apuk_contactid] = src.[apuk_contactid],
		tgt.[apuk_contactid_entitytype] = src.[apuk_contactid_entitytype],
		tgt.[apuk_cpdactivityid] = src.[apuk_cpdactivityid],
		tgt.[apuk_cpdactivityid_entitytype] = src.[apuk_cpdactivityid_entitytype],
		tgt.[apuk_mandatorysubjectid] = src.[apuk_mandatorysubjectid],
		tgt.[apuk_mandatorysubjectid_entitytype] = src.[apuk_mandatorysubjectid_entitytype],
		tgt.[createdby] = src.[createdby],
		tgt.[createdby_entitytype] = src.[createdby_entitytype],
		tgt.[createdonbehalfby] = src.[createdonbehalfby],
		tgt.[createdonbehalfby_entitytype] = src.[createdonbehalfby_entitytype],
		tgt.[modifiedby] = src.[modifiedby],
		tgt.[modifiedby_entitytype] = src.[modifiedby_entitytype],
		tgt.[modifiedonbehalfby] = src.[modifiedonbehalfby],
		tgt.[modifiedonbehalfby_entitytype] = src.[modifiedonbehalfby_entitytype],
		tgt.[owningbusinessunit] = src.[owningbusinessunit],
		tgt.[owningbusinessunit_entitytype] = src.[owningbusinessunit_entitytype],
		tgt.[owningteam] = src.[owningteam],
		tgt.[owningteam_entitytype] = src.[owningteam_entitytype],
		tgt.[owninguser] = src.[owninguser],
		tgt.[owninguser_entitytype] = src.[owninguser_entitytype],
		tgt.[ownerid] = src.[ownerid],
		tgt.[ownerid_entitytype] = src.[ownerid_entitytype],
		tgt.[apuk_contactidname] = src.[apuk_contactidname],
		tgt.[apuk_contactidyominame] = src.[apuk_contactidyominame],
		tgt.[apuk_content] = src.[apuk_content],
		tgt.[apuk_cpdactivityidname] = src.[apuk_cpdactivityidname],
		tgt.[apuk_cpdmandatorycontentid] = src.[apuk_cpdmandatorycontentid],
		tgt.[apuk_mandatorysubjectidname] = src.[apuk_mandatorysubjectidname],
		tgt.[apuk_name] = src.[apuk_name],
		tgt.[createdbyname] = src.[createdbyname],
		tgt.[createdbyyominame] = src.[createdbyyominame],
		tgt.[createdon] = src.[createdon],
		tgt.[createdonbehalfbyname] = src.[createdonbehalfbyname],
		tgt.[createdonbehalfbyyominame] = src.[createdonbehalfbyyominame],
		tgt.[importsequencenumber] = src.[importsequencenumber],
		tgt.[modifiedbyname] = src.[modifiedbyname],
		tgt.[modifiedbyyominame] = src.[modifiedbyyominame],
		tgt.[modifiedon] = src.[modifiedon],
		tgt.[modifiedonbehalfbyname] = src.[modifiedonbehalfbyname],
		tgt.[modifiedonbehalfbyyominame] = src.[modifiedonbehalfbyyominame],
		tgt.[overriddencreatedon] = src.[overriddencreatedon],
		tgt.[owneridname] = src.[owneridname],
		tgt.[owneridtype] = src.[owneridtype],
		tgt.[owneridyominame] = src.[owneridyominame],
		tgt.[owningbusinessunitname] = src.[owningbusinessunitname]

	FROM [synapse_ce].[apuk_cpdmandatorycontent] tgt
		INNER JOIN [staging_ce].[apuk_cpdmandatorycontent] src
			ON src.[Id] = tgt.[Id]

END
