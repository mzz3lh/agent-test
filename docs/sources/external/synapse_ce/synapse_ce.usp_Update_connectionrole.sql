CREATE   PROCEDURE [synapse_ce].[usp_Update_connectionrole]
AS
BEGIN
	UPDATE tgt SET 
		tgt.[category] = stg.[category],
		tgt.[componentstate] = stg.[componentstate],
		tgt.[connectionroleid] = stg.[connectionroleid],
		tgt.[connectionroleidunique] = stg.[connectionroleidunique],
		tgt.[createdby] = stg.[createdby],
		tgt.[createdby_entitytype] = stg.[createdby_entitytype],
		tgt.[createdbyname] = stg.[createdbyname],
		tgt.[createdbyyominame] = stg.[createdbyyominame],
		tgt.[createdon] = stg.[createdon],
		tgt.[createdonbehalfby] = stg.[createdonbehalfby],
		tgt.[createdonbehalfby_entitytype] = stg.[createdonbehalfby_entitytype],
		tgt.[createdonbehalfbyname] = stg.[createdonbehalfbyname],
		tgt.[createdonbehalfbyyominame] = stg.[createdonbehalfbyyominame],
		tgt.[description] = stg.[description],
		tgt.[importsequencenumber] = stg.[importsequencenumber],
		tgt.[introducedversion] = stg.[introducedversion],
		tgt.[iscustomizable] = stg.[iscustomizable],
		tgt.[ismanaged] = stg.[ismanaged],
		tgt.[modifiedby] = stg.[modifiedby],
		tgt.[modifiedby_entitytype] = stg.[modifiedby_entitytype],
		tgt.[modifiedbyname] = stg.[modifiedbyname],
		tgt.[modifiedbyyominame] = stg.[modifiedbyyominame],
		tgt.[modifiedon] = stg.[modifiedon],
		tgt.[modifiedonbehalfby] = stg.[modifiedonbehalfby],
		tgt.[modifiedonbehalfby_entitytype] = stg.[modifiedonbehalfby_entitytype],
		tgt.[modifiedonbehalfbyname] = stg.[modifiedonbehalfbyname],
		tgt.[modifiedonbehalfbyyominame] = stg.[modifiedonbehalfbyyominame],
		tgt.[name] = stg.[name],
		tgt.[organizationid] = stg.[organizationid],
		tgt.[organizationid_entitytype] = stg.[organizationid_entitytype],
		tgt.[organizationidname] = stg.[organizationidname],
		tgt.[overwritetime] = stg.[overwritetime],
		tgt.[SinkCreatedOn] = stg.[SinkCreatedOn],
		tgt.[SinkModifiedOn] = stg.[SinkModifiedOn],
		tgt.[solutionid] = stg.[solutionid],
		tgt.[statecode] = stg.[statecode],
		tgt.[statuscode] = stg.[statuscode],
		tgt.[supportingsolutionid] = stg.[supportingsolutionid],
		tgt.[versionnumber] = stg.[versionnumber]
	 FROM [synapse_ce].[connectionrole] tgt
		INNER JOIN [staging_ce].[connectionrole] stg
			ON tgt.[id] = stg.[id]
END
