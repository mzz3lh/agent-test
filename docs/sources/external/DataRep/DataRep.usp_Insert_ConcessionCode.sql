CREATE     PROCEDURE [DataRep].[usp_Insert_ConcessionCode]
AS
BEGIN
	INSERT INTO [DataRep].[tblConcessionCode]
	(
		[ConcessionCode_Name]
	)
	SELECT 
		conc.[apuk_name]
	FROM (SELECT apuk_name FROM synapse_ce.apuk_concession WHERE statecode = 0 GROUP BY apuk_name) conc
		LEFT JOIN [DataRep].[tblConcessionCode] tgt
			ON conc.[apuk_name] = tgt.[ConcessionCode_Name]
	WHERE tgt.[ConcessionCode_Name] IS NULL
		AND ISNULL(conc.[apuk_name], '') <> ''

END
