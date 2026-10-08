CREATE VIEW [Snapshots].[vwContact_Audit]
AS
SELECT
		ca.[ContactId],
		ca.[SnapshotDate],
		ca.[Rics_ConcessionCode_Prev],
		ca.[Rics_ConcessionCode_Current],
		ca.[Rics_LapsedCode_Prev],
		ca.[Rics_LapsedCode_Current],
		ca.[Rics_CorporateSchemeNameIdName_Prev],
		ca.[Rics_CorporateSchemeNameIdName_Current],
		ca.[Modified_On],
		ca.[ModifiedByName]
FROM [Ext].[PBI02_Snapshots_vwContact_Audit] ca
