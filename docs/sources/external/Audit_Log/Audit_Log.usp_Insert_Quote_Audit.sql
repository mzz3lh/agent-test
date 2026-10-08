CREATE   PROCEDURE [Audit_Log].[usp_Insert_Quote_Audit]
AS
BEGIN

	INSERT INTO [Audit_Log].[tblQuoteAudit_CE]
	(
		[QuoteId]
		,[Audit_Date]
		,[ContactId]
		,[MemberGrade_AtQuote_Created]
		,[IsLocked]
	)
	SELECT
		q.[quoteid]
		,GETDATE()
		,q.[apuk_billto]
		,rr.[apuk_membergrade]
		,0 AS [IsLocked]
	FROM [synapse_ce].[quote] q
		INNER JOIN [synapse_ce].[contact] cnt
			ON q.[apuk_billto] = cnt.[contactid]
		LEFT JOIN [synapse_ce].[apuk_ricsrecord] rr
			ON cnt.[apuk_ricsrecordid] = rr.[apuk_ricsrecordid]
		LEFT JOIN [Audit_Log].[tblQuoteAudit_CE] qa
			ON q.[quoteid] = qa.[QuoteId]
	WHERE q.[apuk_campaignyear] >= 2025
		AND qa.[AuditId] IS NULL


END
