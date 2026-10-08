CREATE    VIEW [synapse_ce].[vwSalesOrder]
AS
SELECT 
	so.SalesOrderId,
	--NULL AS ricsv1_SubscriptionProduct, --Not required, Old Data
	IIF(so.customerid_entitytype='account', so.customerid, null) AS AccountId,
	so.customerid AS ContactId,
	so.OpportunityId,
	--NULL AS ricsv1_financialcostid, --Not required, old data
	so.apuk_productsubscriptionid AS ricsv1_isrenewalofsubscription, -- If this SO is for a subscription renewal, this field points to the subscription owner record that will be renewed. For BI purposes.
	curr.[currencyname] AS [TransactionCurrencyIdName],
	curr.[isocurrencycode],
	--NULL AS Rics_OrderAccountId, -- Not required, old data
	--NULL AS Rics_OrderAccountIdName, --Not required, old data
	so.apuk_paymentrequestid AS ricsv1_TransactionId,
	so.OrderNumber,
	so.msdyn_salesordernumber, 
	so.ModifiedBy,
	usrmodifiedby.[fullname] AS ModifiedByName,
	so.ModifiedOnBehalfBy,
	so.ModifiedOnBehalfByName,
	so.CreatedBy,
	usrcreatedby.[fullname] AS CreatedByName,
	so.customerid AS ricsv1_ProductOwner,
	acc.[name] AS ricsv1_ProductOwnerName,	-- N/A
	so.OwnerId,
	ownid.[fullname] AS OwnerIdName,	
	so.[Name],
	so.[Description],
	so.DiscountAmount,
	so.DiscountAmount_Base,
	so.FreightAmount,
	so.FreightAmount_Base,
	so.TotalAmount,
	so.TotalAmount_Base,
	so.TotalLineItemAmount,
	so.TotalLineItemAmount_Base,
	so.TotalLineItemDiscountAmount,
	so.TotalLineItemDiscountAmount_Base,
	so.TotalAmountLessFreight,
	so.TotalAmountLessFreight_Base,
	so.TotalDiscountAmount,
	so.TotalDiscountAmount_Base,
	so.TotalTax,
	so.TotalTax_Base,
	so.apuk_lionheartdonation,
	so.apuk_lionheartdonation_base,
	so.ExchangeRate,
	so.apuk_paymentmethod AS ricsv1_PaymentMethod, 
	optpaym.[LocalizedLabel] AS [PaymentMethod_Description],
	--NULL AS ricsv1_OnBehalfOfOrganisation, -- NOt required, old data
	so.apuk_subscriptionproducttype AS ricsv1_SubscriptionRenewal,	
	subprdtype.[LocalizedLabel] AS ricsv1_SubscriptionRenewal_Description,
	so.CreatedOn,
	so.ModifiedOn,
	so.StateCode,
	smStatecode.[LocalizedLabel] AS [StateCode_Description],
	so.StatusCode,
	smStatuscode.[LocalizedLabel] AS [StatusCode_Description],
	so.customerid,
	acc.[name] AS CustomerIdName,
	so.CustomerIdType,
	so.DateFulfilled,
	--NULL AS ricsv1_source,	-- Not required, old data
	so.apuk_eventcode,
	so.campaignid,
	so.quoteid,
	rec.[apuk_firmreinbursessubs],
	so.apuk_billto,
	so.billto_line1,
	so.billto_line2,
	so.billto_line3,
	so.billto_city,
	so.billto_stateorprovince,
	so.billto_postalcode,
	so.billto_country,
	so.msdyn_invoicecustomerid AS Invoice_CustomerId

FROM [synapse_ce].[salesorder] so
	LEFT JOIN synapse_ce.apuk_ricsrecord rec
		ON so.[apuk_ricsrecordid] = rec.[apuk_ricsrecordid]
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata optpaym
		ON so.[apuk_paymentmethod] = optpaym.[Option]
			AND optpaym.[OptionSetName] = 'apuk_paymentmethod'
			AND optpaym.[EntityName] = 'salesorder'
	LEFT JOIN synapse_ce.StateMetadata smStatecode
		ON so.[statecode] = smStatecode.[State]
			AND smStatecode.[EntityName] = 'salesorder'
	LEFT JOIN synapse_ce.StatusMetadata smStatuscode
		ON so.[statuscode] = smStatuscode.[Status]
			AND smStatuscode.[EntityName] = 'salesorder'
	LEFT JOIN synapse_ce.systemuser usrcreatedby
		ON so.[createdby] = usrcreatedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser usrmodifiedby
		ON so.[modifiedby] = usrmodifiedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser ownid
		ON so.[ownerid] = ownid.[systemuserid]
	LEFT JOIN synapse_ce.account acc
		ON so.[customerid] = acc.[accountid]
	LEFT JOIN synapse_ce.transactioncurrency curr
		ON so.[transactioncurrencyid] = curr.[transactioncurrencyid]
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata subprdtype
		ON so.[apuk_subscriptionproducttype] = subprdtype.[Option]
			AND subprdtype.[OptionSetName] = 'apuk_subscriptionproducttype'
			AND subprdtype.[EntityName] = 'salesorder'
	WHERE so.[createdon] >= '2021-08-18'
	AND NOT EXISTS (
		SELECT contactid
		FROM CE.tblContact_Test_Records TST
		WHERE TST.contactid = so.customerid
		)
--WHERE so.salesorderid = '00000000-0000-0000-0000-000000000000'--WHERE so.salesorderid = '00000000-0000-0000-0000-000000000000'
