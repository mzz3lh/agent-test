CREATE VIEW [dbo].[vwCPDSummary]
AS

SELECT
	[Rics_contactno],
	[FullName],
	[rics_firmnumber],
	[AccountIdName],
	[Rics_OfficeNumber],
	[Rics_RelationshipType],
	[Cpd Complete],
	[CpdCompleteDate],
	[Total Completed Hrs],
	[Completed Formal Hrs],
	[CPDYear]
FROM [Ext].[PBI02_dbo_vwCPDSummary]
