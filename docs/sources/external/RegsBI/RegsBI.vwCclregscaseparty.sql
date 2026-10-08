CREATE VIEW [RegsBI].[vwCclregscaseparty]
AS
SELECT 
	[cclregs_casepartyid],
	[cclregs_name],
	[cclregs_regulationcaseidName],
	[cclregs_partytypeidName],
	[cclregs_useridName],
	[cclregs_partyidName],
	[rics_contactno]
FROM [Ext].[PBI02_RegsBI_vwCclregscaseparty]
