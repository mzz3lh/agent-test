CREATE   PROCEDURE [synapse_ce].[usp_Update_adobe_emailsend]
AS
BEGIN

	UPDATE tgt SET
		tgt.[SinkCreatedOn] = src.[SinkCreatedOn],
		tgt.[SinkModifiedOn] = src.[SinkModifiedOn],
		tgt.[statecode] = src.[statecode],
		tgt.[statuscode] = src.[statuscode],
		tgt.[deliveryprioritycode] = src.[deliveryprioritycode],
		tgt.[instancetypecode] = src.[instancetypecode],
		tgt.[prioritycode] = src.[prioritycode],
		tgt.[isbilled] = src.[isbilled],
		tgt.[ismapiprivate] = src.[ismapiprivate],
		tgt.[isregularactivity] = src.[isregularactivity],
		tgt.[isworkflowcreated] = src.[isworkflowcreated],
		tgt.[leftvoicemail] = src.[leftvoicemail],
		tgt.[createdby] = src.[createdby],
		tgt.[createdby_entitytype] = src.[createdby_entitytype],
		tgt.[modifiedby] = src.[modifiedby],
		tgt.[modifiedby_entitytype] = src.[modifiedby_entitytype],
		tgt.[modifiedonbehalfby] = src.[modifiedonbehalfby],
		tgt.[modifiedonbehalfby_entitytype] = src.[modifiedonbehalfby_entitytype],
		tgt.[owningbusinessunit] = src.[owningbusinessunit],
		tgt.[owningbusinessunit_entitytype] = src.[owningbusinessunit_entitytype],
		tgt.[owninguser] = src.[owninguser],
		tgt.[owninguser_entitytype] = src.[owninguser_entitytype],
		tgt.[regardingobjectid] = src.[regardingobjectid],
		tgt.[regardingobjectid_entitytype] = src.[regardingobjectid_entitytype],
		tgt.[ownerid] = src.[ownerid],
		tgt.[ownerid_entitytype] = src.[ownerid_entitytype],
		tgt.[activityid] = src.[activityid],
		tgt.[activitytypecode] = src.[activitytypecode],
		tgt.[adobe_campaignname] = src.[adobe_campaignname],
		tgt.[adobe_deliveryname] = src.[adobe_deliveryname],
		tgt.[adobe_mirrorpageurl] = src.[adobe_mirrorpageurl],
		tgt.[adobe_senton] = src.[adobe_senton],
		tgt.[createdbyname] = src.[createdbyname],
		tgt.[createdbyyominame] = src.[createdbyyominame],
		tgt.[createdon] = src.[createdon],
		tgt.[modifiedbyname] = src.[modifiedbyname],
		tgt.[modifiedbyyominame] = src.[modifiedbyyominame],
		tgt.[modifiedon] = src.[modifiedon],
		tgt.[modifiedonbehalfbyname] = src.[modifiedonbehalfbyname],
		tgt.[modifiedonbehalfbyyominame] = src.[modifiedonbehalfbyyominame],
		tgt.[owneridname] = src.[owneridname],
		tgt.[owneridyominame] = src.[owneridyominame],
		tgt.[owningbusinessunitname] = src.[owningbusinessunitname],
		tgt.[regardingobjectidname] = src.[regardingobjectidname],
		tgt.[subject] = src.[subject]
	FROM [synapse_ce].[adobe_emailsend] tgt
		INNER JOIN [staging_ce].[adobe_emailsend] src
			ON tgt.[Id] = src.[id]

END
