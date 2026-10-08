CREATE     PROCEDURE [DataRep].[usp_Insert_Sales_Team]
AS
BEGIN

	INSERT INTO [DataRep].[tblSalesTeam]
	(
		[SalesPerson],
		[SalesTeam],
		[SystemUserId]
	)
	SELECT 
		LTRIM(RTRIM(lkup.[FullName])) AS [SalesPerson], 
		'Unknown' AS [SalesTeam], 
		lkup.[SystemUserId]
	FROM synapse_ce.vwSystemUser lkup
		LEFT JOIN [DataRep].[tblSalesTeam] tgt
			ON lkup.[SystemUserId] = tgt.[SystemUserId]
	WHERE tgt.[SystemUserId] IS NULL
		AND ISNULL(lkup.[FullName], '') <> ''

END
