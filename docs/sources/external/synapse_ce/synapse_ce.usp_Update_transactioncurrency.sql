CREATE   PROCEDURE [synapse_ce].[usp_Update_transactioncurrency]
AS
BEGIN
	UPDATE tgt SET 
		tgt.[createdby] = stg.[createdby],
		tgt.[createdby_entitytype] = stg.[createdby_entitytype],
		tgt.[createdbyname] = stg.[createdbyname],
		tgt.[createdbyyominame] = stg.[createdbyyominame],
		tgt.[createdon] = stg.[createdon],
		tgt.[createdonbehalfby] = stg.[createdonbehalfby],
		tgt.[createdonbehalfby_entitytype] = stg.[createdonbehalfby_entitytype],
		tgt.[createdonbehalfbyname] = stg.[createdonbehalfbyname],
		tgt.[createdonbehalfbyyominame] = stg.[createdonbehalfbyyominame],
		tgt.[currencyname] = stg.[currencyname],
		tgt.[currencyprecision] = stg.[currencyprecision],
		tgt.[currencysymbol] = stg.[currencysymbol],
		tgt.[entityimage_timestamp] = stg.[entityimage_timestamp],
		tgt.[entityimage_url] = stg.[entityimage_url],
		tgt.[entityimageid] = stg.[entityimageid],
		tgt.[exchangerate] = stg.[exchangerate],
		tgt.[importsequencenumber] = stg.[importsequencenumber],
		tgt.[isocurrencycode] = stg.[isocurrencycode],
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
		tgt.[overriddencreatedon] = stg.[overriddencreatedon],
		tgt.[SinkCreatedOn] = stg.[SinkCreatedOn],
		tgt.[SinkModifiedOn] = stg.[SinkModifiedOn],
		tgt.[statecode] = stg.[statecode],
		tgt.[statuscode] = stg.[statuscode],
		tgt.[transactioncurrencyid] = stg.[transactioncurrencyid],
		tgt.[uniquedscid] = stg.[uniquedscid],
		tgt.[versionnumber] = stg.[versionnumber]
	 FROM [synapse_ce].[transactioncurrency] tgt
		INNER JOIN [staging_ce].[transactioncurrency] stg
			ON tgt.[id] = stg.[id]
END
