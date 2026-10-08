CREATE   PROCEDURE [synapse_ce].[usp_Update_apuk_drstype]
AS
BEGIN
	UPDATE tgt SET 
		tgt.[apuk_associatedproduct] = stg.[apuk_associatedproduct],
		tgt.[apuk_associatedproduct_entitytype] = stg.[apuk_associatedproduct_entitytype],
		tgt.[apuk_associatedproductname] = stg.[apuk_associatedproductname],
		tgt.[apuk_drstypeid] = stg.[apuk_drstypeid],
		tgt.[apuk_name] = stg.[apuk_name],
		tgt.[apuk_typecode] = stg.[apuk_typecode],
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
		tgt.[rics_drsgroup] = stg.[rics_drsgroup],
		tgt.[rics_drsgroup_entitytype] = stg.[rics_drsgroup_entitytype],
		tgt.[rics_drsgroupname] = stg.[rics_drsgroupname],
		tgt.[SinkCreatedOn] = stg.[SinkCreatedOn],
		tgt.[SinkModifiedOn] = stg.[SinkModifiedOn],
		tgt.[statecode] = stg.[statecode],
		tgt.[statuscode] = stg.[statuscode],
		tgt.[timezoneruleversionnumber] = stg.[timezoneruleversionnumber],
		tgt.[utcconversiontimezonecode] = stg.[utcconversiontimezonecode],
		tgt.[versionnumber] = stg.[versionnumber]
	 FROM [synapse_ce].[apuk_drstype] tgt
		INNER JOIN [staging_ce].[apuk_drstype] stg
			ON tgt.[id] = stg.[id]
END
