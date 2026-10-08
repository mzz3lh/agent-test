CREATE VIEW [synapse_ce].[vwapuk_regulatoryreturntype] AS

	SELECT  
	 [Id]
	,[statecode]
	,[statuscode]
	,[apuk_code]
	,[apuk_id]
	,[apuk_name]
	,CASE
		WHEN Id = '00000000-0000-0000-0000-000000000000' THEN '00000000-0000-0000-0000-000000000000' --Application for Valuer Registration > Annual Return
		WHEN Id = '00000000-0000-0000-0000-000000000000' THEN '00000000-0000-0000-0000-000000000000' --Registration for Regulation > Annual Return
		WHEN Id = '00000000-0000-0000-0000-000000000000' THEN '00000000-0000-0000-0000-000000000000' --Application for Valuer Registration - old > Annual Return - old
		WHEN Id = '00000000-0000-0000-0000-000000000000' THEN '00000000-0000-0000-0000-000000000000' --Registration for Regulation > Annual Return - old
		ELSE Id
		END As apuk_returntype_grouped
	FROM [synapse_ce].[apuk_regulatoryreturntype]
