CREATE     PROCEDURE [DataRep].[usp_Insert_Marketing_Source]
AS
BEGIN

	INSERT INTO [DataRep].[tblMarketingSource]
	(
		[RICS_MarketingSource_Id],
		[Marketing_Source],
		[Marketing_Team],
		[State_Code],
		[Created_On],
		[Created_By],
		[Modified_On],
		[Modified_By]
	)

	SELECT 
		wrk.[RICS_MarketingSource_Id],
		wrk.[Marketing_Source],
		'Unknown' AS [Marketing_Team],
		wrk.[StateCode_Description] AS [State_Code],
		wrk.[Created_On] AS [Created_On],
		wrk.[CreatedByName],
		wrk.[Modified_On]  AS [Modified_On],
		wrk.[ModifiedByName]
	FROM 
		(
			SELECT 
				ms.[apuk_name] AS [Marketing_Source],
				--[Marketing_Team],
				ms.[apuk_marketingsourceid] AS [RICS_MarketingSource_Id],
				ms.[statecode] AS [State_Code],
				statecode.[LocalizedLabel] AS [StateCode_Description],
				ms.[statuscode],
				statuscode.[LocalizedLabel] AS [StatusCode_Description],
				ms.[createdon] AS [Created_On],
				ms.[createdby] AS [Created_By],
				usrcreatedby.[fullname] AS [CreatedByName],
				ms.[modifiedon] AS [Modified_On],
				ms.[modifiedby] AS [Modified_By],
				usrmodifiedby.[fullname] AS [ModifiedByName]
			FROM [synapse_ce].[apuk_marketingsource] ms
				LEFT JOIN [synapse_ce].[systemuser] usrcreatedby
					ON ms.[createdby] = usrcreatedby.[systemuserid]
				LEFT JOIN [synapse_ce].[systemuser] usrmodifiedby
					ON ms.[modifiedby] = usrmodifiedby.[systemuserid]
				LEFT JOIN [synapse_ce].[StateMetadata] statecode
					ON ms.[statecode] = statecode.[State]
						AND statecode.[EntityName] = 'apuk_MarketingSource'
				LEFT JOIN [synapse_ce].[StatusMetadata] statuscode
					ON ms.[statuscode] = statuscode.[Status]
						AND statuscode.[EntityName] = 'apuk_MarketingSource'
		) wrk
		LEFT JOIN [DataRep].[tblMarketingSource] tgt
			ON wrk.[RICS_MarketingSource_Id] = tgt.[RICS_MarketingSource_Id]
	WHERE tgt.[RICS_MarketingSource_Id] IS NULL
		AND wrk.[Marketing_Source] IS NOT NULL


END
