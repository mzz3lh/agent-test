CREATE   VIEW [CE].[vwOpenOpps_CustServiceManagerDB] 
AS 

	SELECT 
		opp.[Opportunity_Key],
		CONVERT(DATE, opp.[Created_On]) AS [Created_On],
		--st.[SalesPerson] AS [Owner],
		opp.[Opportunity_Owner] AS [Owner],
		mktsrc.[Marketing_Source] AS [Marketing_Source_Description]
	FROM [CE].[vwOpportunities] opp
		LEFT JOIN [CE].[vwMarketingSource] mktsrc
			ON opp.[MarketingSourceId] = mktsrc.[RICS_MarketingSource_Id]
	WHERE opp.Opportunity_State = 'Open'
		AND mktsrc.Marketing_Source IN ('Readmissions', 'Resignations')
