CREATE   VIEW [Snapshots].[vwAPCEnrolment_CE]
AS
SELECT
	[rics_apcid],
	[rics_enrolmentdate_previous],
	[rics_enrolmentdate_current],
	[modified_on],
	[ModifiedByName],
	[SnapshotDate]
FROM [Snapshots].[tblAPCEnrolment_CE]
