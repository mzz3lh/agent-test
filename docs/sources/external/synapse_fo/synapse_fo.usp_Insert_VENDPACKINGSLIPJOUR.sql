CREATE   PROCEDURE [synapse_fo].[usp_Insert_VENDPACKINGSLIPJOUR]
AS
BEGIN
	
	INSERT INTO [Synapse_fo].[VENDPACKINGSLIPJOUR]
	(
		[recid],
		[sinkcreatedon],
		[SinkModifiedOn],
		[deliverydate],
		[freightsliptype],
		[intercompanyposted],
		[inventprofiletype_ru],
		[purchasetype],
		[receiptlistdeviationtype_ru],
		[sysdatastatecode],
		[orderaccount],
		[countryregionid],
		[deliverytype],
		[deliveryname],
		[invoiceaccount],
		[orderbalance_ru],
		[packingslipid],
		[purchid],
		[requester],
		[modifiedon],
		[modifiedby],
		[createdon],
		[createdby],
		[dataareaid],
		[tableid],
		[IsDelete]
	)
	SELECT
		src.[recid],
		src.[sinkcreatedon],
		src.[SinkModifiedOn],
		src.[deliverydate],
		src.[freightsliptype],
		src.[intercompanyposted],
		src.[inventprofiletype_ru],
		src.[purchasetype],
		src.[receiptlistdeviationtype_ru],
		src.[sysdatastatecode],
		src.[orderaccount],
		src.[countryregionid],
		src.[deliverytype],
		src.[deliveryname],
		src.[invoiceaccount],
		src.[orderbalance_ru],
		src.[packingslipid],
		src.[purchid],
		src.[requester],
		src.[modifiedon],
		src.[modifiedby],
		src.[createdon],
		src.[createdby],
		src.[dataareaid],
		src.[tableid],
		src.[IsDelete]
	FROM [Staging_fo].[VENDPACKINGSLIPJOUR] src
		LEFT JOIN [synapse_fo].[VENDPACKINGSLIPJOUR] tgt
			ON src.[RecId] = tgt.[RecId]
			AND src.[DataAreaId] = tgt.[DataAreaId]
	WHERE tgt.[RecId] IS NULL

END
