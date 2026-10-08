CREATE   PROCEDURE [synapse_ce].[usp_Update_subject]
AS
BEGIN
	UPDATE tgt SET 
		tgt.[createdby] = stg.[createdby],
		tgt.[createdby_entitytype] = stg.[createdby_entitytype],
		tgt.[createdbyexternalparty] = stg.[createdbyexternalparty],
		tgt.[createdbyexternalparty_entitytype] = stg.[createdbyexternalparty_entitytype],
		tgt.[createdbyexternalpartyname] = stg.[createdbyexternalpartyname],
		tgt.[createdbyexternalpartyyominame] = stg.[createdbyexternalpartyyominame],
		tgt.[createdbyname] = stg.[createdbyname],
		tgt.[createdbyyominame] = stg.[createdbyyominame],
		tgt.[createdon] = stg.[createdon],
		tgt.[createdonbehalfby] = stg.[createdonbehalfby],
		tgt.[createdonbehalfby_entitytype] = stg.[createdonbehalfby_entitytype],
		tgt.[createdonbehalfbyname] = stg.[createdonbehalfbyname],
		tgt.[createdonbehalfbyyominame] = stg.[createdonbehalfbyyominame],
		tgt.[description] = stg.[description],
		tgt.[featuremask] = stg.[featuremask],
		tgt.[importsequencenumber] = stg.[importsequencenumber],
		tgt.[modifiedby] = stg.[modifiedby],
		tgt.[modifiedby_entitytype] = stg.[modifiedby_entitytype],
		tgt.[modifiedbyexternalparty] = stg.[modifiedbyexternalparty],
		tgt.[modifiedbyexternalparty_entitytype] = stg.[modifiedbyexternalparty_entitytype],
		tgt.[modifiedbyexternalpartyname] = stg.[modifiedbyexternalpartyname],
		tgt.[modifiedbyexternalpartyyominame] = stg.[modifiedbyexternalpartyyominame],
		tgt.[modifiedbyname] = stg.[modifiedbyname],
		tgt.[modifiedbyyominame] = stg.[modifiedbyyominame],
		tgt.[modifiedon] = stg.[modifiedon],
		tgt.[modifiedonbehalfby] = stg.[modifiedonbehalfby],
		tgt.[modifiedonbehalfby_entitytype] = stg.[modifiedonbehalfby_entitytype],
		tgt.[modifiedonbehalfbyname] = stg.[modifiedonbehalfbyname],
		tgt.[modifiedonbehalfbyyominame] = stg.[modifiedonbehalfbyyominame],
		tgt.[organizationid] = stg.[organizationid],
		tgt.[organizationid_entitytype] = stg.[organizationid_entitytype],
		tgt.[organizationidname] = stg.[organizationidname],
		tgt.[overriddencreatedon] = stg.[overriddencreatedon],
		tgt.[parentsubject] = stg.[parentsubject],
		tgt.[parentsubject_entitytype] = stg.[parentsubject_entitytype],
		tgt.[parentsubjectname] = stg.[parentsubjectname],
		tgt.[SinkCreatedOn] = stg.[SinkCreatedOn],
		tgt.[SinkModifiedOn] = stg.[SinkModifiedOn],
		tgt.[subjectid] = stg.[subjectid],
		tgt.[title] = stg.[title],
		tgt.[versionnumber] = stg.[versionnumber]
	 FROM [synapse_ce].[subject] tgt
		INNER JOIN [staging_ce].[subject] stg
			ON tgt.[id] = stg.[id]
END
