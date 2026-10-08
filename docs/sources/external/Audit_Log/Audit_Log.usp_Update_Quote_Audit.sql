CREATE   PROCEDURE [Audit_Log].[usp_Update_Quote_Audit]
AS
BEGIN

	UPDATE tgt SET 
		tgt.[MemberGrade_At_YearEnd] = 	rr.[apuk_membergrade]
		,tgt.[YearEnd_Audit_Run_Date] = GETDATE()
		,tgt.[IsLocked] = 1
	FROM [Audit_Log].[tblQuoteAudit_CE] tgt
		INNER JOIN [synapse_ce].[quote] q
			ON tgt.[QuoteId] = q.[quoteid]
		INNER JOIN [synapse_ce].[contact] cnt
			ON q.[apuk_billto] = cnt.[contactid]
		LEFT JOIN [synapse_ce].[apuk_ricsrecord] rr
			ON cnt.[apuk_ricsrecordid] = rr.[apuk_ricsrecordid]
	WHERE tgt.[IsLocked] = 0
END
