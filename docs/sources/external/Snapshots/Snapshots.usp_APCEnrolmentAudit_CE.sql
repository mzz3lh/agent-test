CREATE   PROCEDURE [Snapshots].[usp_APCEnrolmentAudit_CE]
AS
BEGIN
	
	-- Insert into snapshot when there is a change in enrolment date
	INSERT INTO [Snapshots].[tblAPCEnrolment_CE]
	(
		[rics_apcid],
		[rics_enrolmentdate_previous],
		[rics_enrolmentdate_current],
		[modified_on],
		[ModifiedByName],
		[SnapshotDate]
	)
	SELECT
		wrk.[rics_apcid],
		tgt.[rics_enrolmentdate],
		wrk.[rics_enrolmentdate],
		wrk.[Modified_On],
		wrk.[ModifiedByName],
		GETDATE()
	FROM [Work].[tblRicsAPC_CE] wrk
		INNER JOIN [CE].[tblRicsAPC] tgt
			ON wrk.[rics_apcid] = tgt.[rics_apcid]
	WHERE ISNULL(wrk.[rics_enrolmentdate], '1900-01-01 00:00:00') <> ISNULL(tgt.[rics_enrolmentdate], '1900-01-01 00:00:00')



END
