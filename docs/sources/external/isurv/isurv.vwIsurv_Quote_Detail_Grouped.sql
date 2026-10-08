CREATE   VIEW [isurv].[vwIsurv_Quote_Detail_Grouped] AS

	SELECT 
	 QUOD.quoteid
	,SUM(CASE WHEN QUOD.productnumber LIKE '%isurv%' THEN QUOD.baseamount ELSE 0 END) AS 'Isurv Base Amount CUR'
	,SUM(CASE WHEN QUOD.productnumber LIKE '%isurv%' THEN QUOD.baseamount_base ELSE 0 END) AS 'Isurv Base Amount GBP'
	,SUM(CASE WHEN QUOD.productnumber LIKE '%isurv%' THEN COALESCE(QUOD.manualdiscountamount,0) ELSE 0 END) AS 'Isurv Discount Amount CUR'
	,SUM(CASE WHEN QUOD.productnumber LIKE '%isurv%' THEN COALESCE(QUOD.manualdiscountamount_base,0) ELSE 0 END) AS 'Isurv Discount Amount GBP'
	,SUM(CASE WHEN QUOD.productnumber LIKE '%isurv%' THEN COALESCE(QUOD.tax, 0) ELSE 0 END) AS 'Isurv Tax Amount CUR'
	,SUM(CASE WHEN QUOD.productnumber LIKE '%isurv%' THEN COALESCE(QUOD.tax_base, 0) ELSE 0 END) AS 'Isurv Tax Amount GBP'
	,SUM(CASE WHEN QUOD.productnumber LIKE '%isurv%' THEN QUOD.baseamount - COALESCE(QUOD.manualdiscountamount,0) + COALESCE(QUOD.tax, 0) ELSE 0 END) AS 'Isurv Amount CUR'
	,SUM(CASE WHEN QUOD.productnumber LIKE '%isurv%' THEN QUOD.baseamount_base - COALESCE(QUOD.manualdiscountamount_base,0) + COALESCE(QUOD.tax_base, 0) ELSE 0 END) AS 'Isurv Amount GBP'
	,SUM(CASE WHEN QUOD.productnumber NOT LIKE '%isurv%' THEN QUOD.baseamount - COALESCE(QUOD.manualdiscountamount,0) + COALESCE(QUOD.tax, 0) ELSE 0 END) AS 'Non-Isurv Amount CUR'
	,SUM(CASE WHEN QUOD.productnumber NOT LIKE '%isurv%' THEN QUOD.baseamount_base - COALESCE(QUOD.manualdiscountamount_base,0) + COALESCE(QUOD.tax_base, 0) ELSE 0 END) AS 'Non-Isurv Amount GBP'
	FROM synapse_ce.quotedetail QUOD
	WHERE EXISTS ( --Filter only Isurv relevant records
		SELECT 
		SQ.quoteid
		FROM Isurv.vwIsurv_Subscription_Quote SQ
		WHERE SQ.quoteid = QUOD.quoteid 
		)
	GROUP BY 
	 QUOD.quoteid
