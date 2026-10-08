CREATE VIEW [Snapshots].[vwAPCEnrolment]
AS
SELECT
	[rics_apcid],
	[rics_enrolmentdate_previous],
	[rics_enrolmentdate_current],
	[modified_on],
	[ModifiedByName],
	[SnapshotDate]
FROM [Ext].[PBI02_Snapshots_vwAPCEnrolment]
