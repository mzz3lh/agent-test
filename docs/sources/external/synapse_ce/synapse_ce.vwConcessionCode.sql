CREATE   VIEW [synapse_ce].[vwConcessionCode]
AS
SELECT 
	conc.[ConcessionCodeId],
	conc.[ConcessionCode_Name]
FROM [DataRep].[tblConcessionCode] conc
