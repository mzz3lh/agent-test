CREATE VIEW CE.vwRegulatory_Return_Type AS (

	SELECT
	 [Id]
    ,[statecode]
    ,[statuscode]
    ,[apuk_code]
    ,[apuk_id]
    ,[apuk_name]
    ,[apuk_returntype_grouped]
	 FROM [synapse_ce].[vwapuk_regulatoryreturntype]
	 )
