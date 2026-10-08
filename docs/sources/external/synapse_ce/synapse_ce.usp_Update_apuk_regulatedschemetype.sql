CREATE   PROCEDURE [synapse_ce].[usp_Update_apuk_regulatedschemetype]
AS
BEGIN
	UPDATE tgt SET 
		tgt.[apuk_code] = stg.[apuk_code],
		tgt.[apuk_issponsorship] = stg.[apuk_issponsorship],
		tgt.[apuk_licencetype] = stg.[apuk_licencetype],
		tgt.[apuk_name] = stg.[apuk_name],
		tgt.[apuk_parentschemetypeid] = stg.[apuk_parentschemetypeid],
		tgt.[apuk_parentschemetypeid_entitytype] = stg.[apuk_parentschemetypeid_entitytype],
		tgt.[apuk_parentschemetypeidname] = stg.[apuk_parentschemetypeidname],
		tgt.[apuk_regulatedschemetypeid] = stg.[apuk_regulatedschemetypeid],
		tgt.[createdby] = stg.[createdby],
		tgt.[createdby_entitytype] = stg.[createdby_entitytype],
		tgt.[createdbyname] = stg.[createdbyname],
		tgt.[createdbyyominame] = stg.[createdbyyominame],
		tgt.[createdon] = stg.[createdon],
		tgt.[createdonbehalfby] = stg.[createdonbehalfby],
		tgt.[createdonbehalfby_entitytype] = stg.[createdonbehalfby_entitytype],
		tgt.[createdonbehalfbyname] = stg.[createdonbehalfbyname],
		tgt.[createdonbehalfbyyominame] = stg.[createdonbehalfbyyominame],
		tgt.[importsequencenumber] = stg.[importsequencenumber],
		tgt.[modifiedby] = stg.[modifiedby],
		tgt.[modifiedby_entitytype] = stg.[modifiedby_entitytype],
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
		tgt.[SinkCreatedOn] = stg.[SinkCreatedOn],
		tgt.[SinkModifiedOn] = stg.[SinkModifiedOn],
		tgt.[statecode] = stg.[statecode],
		tgt.[statuscode] = stg.[statuscode],
		tgt.[timezoneruleversionnumber] = stg.[timezoneruleversionnumber],
		tgt.[utcconversiontimezonecode] = stg.[utcconversiontimezonecode],
		tgt.[versionnumber] = stg.[versionnumber]
	 FROM [synapse_ce].[apuk_regulatedschemetype] tgt
		INNER JOIN [staging_ce].[apuk_regulatedschemetype] stg
			ON tgt.[id] = stg.[id]
END
