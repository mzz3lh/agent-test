CREATE   PROCEDURE [Work].[usp_Insert_Contact_Audit_CE]
AS
BEGIN


	--Insert from AX as one off snapshot
/*
	;with cteax as
	(
		SELECT rics_contactno, PaymentMethod_Derived, SettlementDate
		FROM SubsRep_BI.vwSubsPayments
		WHERE SubsCampaign = 'Subs0000'
			AND PaymentMethod_Derived = 'Corporate'
		GROUP BY rics_contactno, PaymentMethod_Derived, SettlementDate
	), ctefo as
	(
		SELECT rics_contactno, PaymentMethod_Derived, SettlementDate
		FROM SubsRep_BI.vwSubsPayments_FO
		WHERE SubsCampaign = 'Subs0000'
		GROUP BY rics_contactno, PaymentMethod_Derived, SettlementDate
	)


	INSERT INTO [Snapshots].[tblContact_Audit_CE]
	(
		[ContactId],
		[SnapshotDate],
		[Rics_LapsedCode_Prev],
		[Rics_LapsedCode_Current],
		[Rics_PaymentMethod_Description_Prev],
		[Rics_PaymentMethod_Description_Current],
		[Modified_On],
		[ModifiedByName]
	)

	SELECT 
		cnt.[ContactId],
		--ax.[rics_contactno],
		'2021-08-20' AS [SnapshotDate],
		NULL AS [Rics_LapsedCode_Prev],
		NULL AS [Rics_LapsedCode_Current],
		NULL AS [Rics_PaymentMethod_Description_Prev],
		ax.[PaymentMethod_Derived] AS [Rics_PaymentMethod_Description_Current],
		'2021-08-01' AS Modified_On,
		'BIUser'
	FROM cteax ax
		LEFT JOIN ctefo fo
			ON ax.rics_contactno = fo.rics_contactno
			AND ax.SettlementDate = fo.SettlementDate
		LEFT JOIN dbo.vwContact cnt
			ON ax.[rics_contactno] = cnt.[Rics_contactno]
*/

	INSERT INTO [Snapshots].[tblContact_Audit_CE]
	(
		[ContactId],
		[SnapshotDate],
		[Rics_LapsedCode_Prev],
		[Rics_LapsedCode_Current],
		[Rics_PaymentMethod_Description_Prev],
		[Rics_PaymentMethod_Description_Current],
		[Modified_On],
		[ModifiedByName]
	)
	SELECT
		wrk.[ContactId],
		GETDATE(),
		CASE WHEN ISNULL(wrk.[Rics_LapsedCode], '') <> ISNULL(tgt.[Rics_LapsedCode], '') THEN tgt.[Rics_LapsedCode] END,
		CASE WHEN ISNULL(wrk.[Rics_LapsedCode], '') <> ISNULL(tgt.[Rics_LapsedCode], '') THEN wrk.[Rics_LapsedCode] END,
		CASE WHEN ISNULL(wrk.[Rics_PaymentMethod_Description], '') <> ISNULL(tgt.[Rics_PaymentMethod_Description], '') THEN tgt.[Rics_PaymentMethod_Description] END,
		CASE WHEN ISNULL(wrk.[Rics_PaymentMethod_Description], '') <> ISNULL(tgt.[Rics_PaymentMethod_Description], '') THEN wrk.[Rics_PaymentMethod_Description] END,
		wrk.[ModifiedOn],
		wrk.[ModifiedByName]
	FROM [Work].[tblContact_CE] wrk
		INNER JOIN [CE].[tblContact] tgt
			ON wrk.[ContactId] = tgt.[ContactId]
	WHERE 
		(
			ISNULL(wrk.[Rics_LapsedCode], '') <> ISNULL(tgt.[Rics_LapsedCode], '') 
			OR ISNULL(wrk.[Rics_PaymentMethod_Description], 'temp') <> ISNULL(tgt.[Rics_PaymentMethod_Description], 'temp') --Test GUID to avoid NULL comparison
		)

END
