/****** Object:  View [dbo].[vwSalesOrderDetail]    Script Date: 06/07/2021 11:06:27 ******/
CREATE   VIEW [synapse_ce].[vwSalesOrderDetail]
AS
SELECT 
	sod.[SalesOrderDetailId],
	--sod.[SalesOrderIdName],
	sod.[SalesOrderId],
	--sod.[ricsv1_bookingrecordid], --(In SalesOrder)Need to join with apuk_salesorder_apuk_eventbooking
	--sod.[ricsv1_eventid], -- (In SalesOrder) apuk_eventcode
	sod.msdyn_linedescription AS [ricsv1_eventidName],
	--sod.[ricsv1_eventidtext], (In SalesOrder) description
	--sod.[ricsv1_costcentreid], Not in CE
	--sod.[ricsv1_campaignresponseid], (In apuk_delegatebooking\sod.salesorderdetailid -> apuk_salesorderlineid
	ISNULL(sod.[OwnerId], '00000000-0000-0000-0000-000000000000') AS [OwnerId],
	ownid.[fullname] AS [OwnerIdName],
	sod.[salesorderstatecode] AS [SalesOrderStateCode],
	smStateCode.[LocalizedLabel] AS [Statecode_Description],
	sod.[OwningBusinessUnit],
	sod.[SalesOrderIsPriceLocked],
	sod.[OwningUser],
	ISNULL(sod.[ProductId], '00000000-0000-0000-0000-000000000000') AS [ProductId],
	sod.productnumber,
	sod.[ProductTypeCode] AS [Order_ProductTypeCode],
	optPrdTypeCode.[LocalizedLabel] AS [Order_ProductTypeCode_Description],
	--prd.[name] AS [Product_Name],
	--prdtypecode.[LocalizedLabel] AS [ProductTypeCode],
	--pg.[ProductGroup] AS [RICS_ProductGroup_Name],
	ISNULL(prd.[apuk_productgroup], '00000000-0000-0000-0000-000000000000') AS [RICS_ProductGroupId],	
	curr.[currencyname] AS [TransactionCurrencyIdName],
	curr.[isocurrencycode],
	--sod.[ricsv1_glaccountid], --Not in CE
	--sod.[ricsv1_SubscriptionProduct], --(In SalesOrder) apuk_productsubscriptionid
	sod.[CreatedBy],
	usrcreatedby.[fullname] AS [CreatedByName],
	sod.[createdon] AS [Created_On],
	sod.[ModifiedBy],
	usrmodifiedby.[fullname] AS [ModifiedByName],
	sod.[modifiedon] AS [Modified_On],
	--sod.[ricsv1_attendeeidName], --Not in CE
	sod.[IsProductOverridden],
	sod.[IsPriceOverridden],
	sod.[QuantityShipped],
	sod.[LineItemNumber],
	sod.[QuantityBackordered],
	sod.[QuantityCancelled],
	sod.[Quantity],
	sod.[PricePerUnit],
	sod.[BaseAmount],
	sod.[ExtendedAmount],
	sod.[Tax],
	sod.[ManualDiscountAmount],
	sod.[VolumeDiscountAmount],
	--sod.[Rics_ClaimAmount], Not in CE
	sod.[ExchangeRate],
	sod.[SequenceNumber],
	sod.[apuk_subscriptionnoofmonths] AS [Rics_LengthofSubscription],
	--sod.[Rics_LicenceNo], Not in CE
	--sod.[Rics_RICSInvoiceNo], Not in CE
	sod.[apuk_salesorderlinestatus] AS [Rics_Status],
	optLineStatus.[LocalizedLabel] AS [RICS_Status_Description],
	sod.[apuk_subscriptionstartdate] AS [ricsv1_StartDate],
	sod.[apuk_subscriptionenddate] AS [ricsv1_EndDate],
	--sod.[ricsv1_optinautorenew], Not in CE
	sod.[apuk_marketingcode] AS [ricsv2_MarketingCode],
	--sod.[paym] AS [ricsv1_paymentmethod], (In SalesOrder) apuk_paymentmethod
	--sod.[PaymentMethod_Description],
	--sod.[ricsv1_registrationnumber], Not in CE
	sod.[ExtendedAmount_Base],
	sod.[BaseAmount_Base],
	sod.[Tax_Base]
FROM synapse_ce.salesorderdetail sod
	--LEFT JOIN synapse_ce.apuk_delegatebooking del
	--	ON sod.salesorderdetailid = del.apuk_salesorderlineid
	LEFT JOIN synapse_ce.StateMetadata smStateCode
		ON sod.[salesorderstatecode] = smStateCode.[State]
			AND smStateCode.[EntityName] = 'salesorder'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata optPrdTypeCode
		ON sod.[producttypecode] = optPrdTypeCode.[Option]
			AND optPrdTypeCode.[OptionSetName] = 'producttypecode'
			AND optPrdTypeCode.[EntityName] = 'salesorderdetail'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata optLineStatus
		ON sod.[apuk_salesorderlinestatus] = optLineStatus.[Option]
			AND optLineStatus.[OptionSetName] = 'apuk_salesorderlinestatus'
			AND optLineStatus.[EntityName] = 'salesorderdetail'
	LEFT JOIN synapse_ce.systemuser usrcreatedby
		ON sod.[createdby] = usrcreatedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser usrmodifiedby
		ON sod.[modifiedby] = usrmodifiedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser ownid
		ON sod.[ownerid] = ownid.[systemuserid]
	LEFT JOIN synapse_ce.product prd
		ON sod.[productid] = prd.[productid]
	--LEFT JOIN synapse_ce.GlobalOptionSetMetadata prdtypecode
	--	ON prd.[producttypecode] = prdtypecode.[Option]
	--		AND prdtypecode.[OptionSetName] = 'producttypecode'
	--LEFT JOIN vwProductGroup pg
	--	ON prd.[apuk_productgroup] = pg.[RICS_ProductGroupId]
	LEFT JOIN synapse_ce.transactioncurrency curr
		ON sod.[transactioncurrencyid] = curr.[transactioncurrencyid]
	LEFT JOIN synapse_ce.salesorder so
		ON sod.salesorderid = so.salesorderid
--WHERE so.createdon >= '2021-08-18'
AND EXISTS (
	SELECT salesorderid
	FROM synapse_ce.vwSalesOrder VSO
	WHERE VSO.salesorderid = so.salesorderid
	)
--WHERE sod.salesorderid = '00000000-0000-0000-0000-000000000000'
