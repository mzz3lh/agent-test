CREATE   PROCEDURE [synapse_fo].[usp_Update_VENDPACKINGSLIPJOUR]
AS
BEGIN

	UPDATE tgt SET
		tgt.[sinkcreatedon] = src.[sinkcreatedon],
		tgt.[SinkModifiedOn] = src.[SinkModifiedOn],
		tgt.[deliverydate] = src.[deliverydate],
		tgt.[freightsliptype] = src.[freightsliptype],
		tgt.[intercompanyposted] = src.[intercompanyposted],
		tgt.[inventprofiletype_ru] = src.[inventprofiletype_ru],
		tgt.[purchasetype] = src.[purchasetype],
		tgt.[receiptlistdeviationtype_ru] = src.[receiptlistdeviationtype_ru],
		tgt.[sysdatastatecode] = src.[sysdatastatecode],
		tgt.[orderaccount] = src.[orderaccount],
		tgt.[countryregionid] = src.[countryregionid],
		tgt.[deliverytype] = src.[deliverytype],
		tgt.[deliveryname] = src.[deliveryname],
		tgt.[invoiceaccount] = src.[invoiceaccount],
		tgt.[orderbalance_ru] = src.[orderbalance_ru],
		tgt.[packingslipid] = src.[packingslipid],
		tgt.[purchid] = src.[purchid],
		tgt.[requester] = src.[requester],
		tgt.[modifiedon] = src.[modifiedon],
		tgt.[modifiedby] = src.[modifiedby],
		tgt.[createdon] = src.[createdon],
		tgt.[createdby] = src.[createdby],
		tgt.[tableid] = src.[tableid],
		tgt.[IsDelete] = src.[IsDelete]
	FROM [synapse_fo].[VENDPACKINGSLIPJOUR] tgt
		INNER JOIN [staging_fo].[VENDPACKINGSLIPJOUR] src
			ON tgt.[RecId] = src.[RecId]
			AND tgt.[DataAreaId] = src.[DataAreaId]
END
