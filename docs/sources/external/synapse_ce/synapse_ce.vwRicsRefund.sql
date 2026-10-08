/*
16/05/2022	srini.akula		Newly added fields

	ref.[apuk_refundcreditnotedate] AS Rics_refundcreditnotedate,
	ref.[apuk_refundcreditnote] AS Rics_refundcreditnote,
	crNoteRefund.LocalizedLabel AS Rics_refundcreditnoteDescription,
	
	ref.[apuk_refundcreditnotebyid] AS Rics_refundcreditnotebyid,
	usrRefundCrNoteBy.[fullname] AS [Rics_refundcreditnotebyIdName],

	ref.[apuk_quote] AS Rics_QuoteId,

	ref.[apuk_approveddeclinedbyid] AS Rics_approveddeclinedbyid,
	usrAprDeclineBy.[fullname] AS [Rics_approveddeclinedbyIdName],

	ref.[apuk_order] AS Rics_SalesOrderId,
	ref.[apuk_originalinvoicegrossamount] AS Rics_originalinvoicegrossamount,
	ref.[apuk_name] AS Rics_RefundDescription,

	ref.[apuk_creditnoteactioned] AS Rics_creditnoteactioned,
	crNoteAct.LocalizedLabel AS Rics_creditnoteactionedDescription,
	
	ref.[apuk_creditnoteactionedby] AS Rics_creditnoteactionedby,
	usrCrNoteBy.[fullname] AS [Rics_creditnoteactionedbyName],
	
	ref.[apuk_customeraccountnumber] AS Rics_customeraccountnumber,
	ref.[apuk_customersortcode]  AS Rics_customersortcode,
	ref.[apuk_creditnoteactioneddate] AS Rics_creditnoteactioneddate,

	ref.[apuk_requestedbyid] AS Rics_requestedbyid,
	usrReqBy.[fullname] AS [Rics_requestedbyIdName],

*/

CREATE   VIEW [synapse_ce].[vwRicsRefund]
AS
SELECT
	ref.[apuk_caserefundid] AS [Rics_refundId],
	ref.[CreatedBy],
	usrcreatedby.[fullname] AS [CreatedByName],
	ref.[createdon] AS [Created_On],
	ref.[ModifiedBy],
	usrmodifiedby.[fullname] AS [ModifiedByName],
	ref.[modifiedon] AS [Modified_On],
	ref.[OwnerId],
	ownid.[fullname] AS [OwnerIdName],
	ref.[apuk_customerid] AS [rics_accountnameid],
	--acc.[name] AS [rics_accountnameidName],
	ref.[apuk_departmentteamid] AS [Rics_Category], 
	--ref.[Rics_Company],
	ref.[apuk_customerid] AS [rics_contactnameid],
	--cnt.[fullname] AS [rics_contactnameidName],
	--ref.[Rics_CostCentre],
	ref.[apuk_refundcreditnoteamount] AS [Rics_CreditAmount],
	--ref.[Rics_CreditNoteCostCentreId],
	--ref.[Rics_CreditNoteCostCentreIdName],
	--ref.[Rics_CreditNoteValue],
	ref.[apuk_daterequested] AS [Rics_DateRefundRequested],
	ref.[apuk_refundcreditnoteamount] AS [Rics_DebitAmount],
	ref.[apuk_declined] AS [Rics_DeclinedbyFinance],
	ref.[apuk_declineddate] AS [Rics_DeclinedDate],
	ref.[apuk_declinedreason] AS [Rics_DeclinedReason],
	ref.[apuk_declinereason] AS [Rics_DeclineReason],
	ref.[apuk_salesorderreference] AS [Rics_EventBookingRecordId],
	--ref.[apuk_salesorderreference] AS [Rics_EventBookingRecordIdName],
	ref.[apuk_invoicenumber] AS [Rics_InvoiceReference],
	--ref.[Rics_InvoiceType],
	--ref.[Rics_PAYE],
	--ref.[Rics_Product],
	--ref.[Rics_ProductCode],
	ref.[apuk_reasonforrefundcreditnote] AS [Rics_ReasonforRefund],
	reasonforrefund.[LocalizedLabel] AS [Rics_ReasonforRefund_Description],
	ref.[apuk_requesttype] AS [Rics_Refund],
	reqtype.[LocalizedLabel] AS [Rics_Refund_Description],
	ref.[apuk_refundcreditnotedate] AS [Rics_RefundDate],
	--ref.[Rics_Refunded],
	ref.[apuk_originalpaymentmethod] AS [Rics_RefundPaymentMethod],
	paym.[LocalizedLabel] AS [Rics_RefundPaymentMethod_Description],
	ref.[apuk_detailsofrefundcreditrequest] AS [Rics_Text],
	--ref.[Rics_Type],
	ref.[statecode],
	stStateCode.[LocalizedLabel] AS [StateCode_Description],
	ref.[statuscode],
	stStatusCode.[LocalizedLabel] AS [StatusCode_Description],
	ref.[apuk_ApprovedDeclined] AS [Rics_ApprovedDeclined],
	apprdecline.[LocalizedLabel] AS [Rics_ApprovedDeclined_Description],
	ref.[apuk_approveddeclineddate] AS [Rics_ApprovedDeclinedDate],
	ref.[apuk_refundcreditnotedate] AS Rics_refundcreditnotedate,
	ref.[apuk_refundcreditnote] AS Rics_refundcreditnote,
	crNoteRefund.LocalizedLabel AS Rics_refundcreditnoteDescription,	
	ref.[apuk_refundcreditnotebyid] AS Rics_refundcreditnotebyid,
	usrRefundCrNoteBy.[fullname] AS [Rics_refundcreditnotebyIdName],
	ref.[apuk_quote] AS Rics_QuoteId,
	ref.[apuk_approveddeclinedbyid] AS Rics_approveddeclinedbyid,
	usrAprDeclineBy.[fullname] AS [Rics_approveddeclinedbyIdName],
	ref.[apuk_order] AS Rics_SalesOrderId,
	ref.[apuk_originalinvoicegrossamount] AS Rics_originalinvoicegrossamount,
	ref.[apuk_name] AS Rics_Name,
	ref.[apuk_creditnoteactioned] AS Rics_creditnoteactioned,
	crNoteAct.LocalizedLabel AS Rics_creditnoteactionedDescription,	
	ref.[apuk_creditnoteactionedby] AS Rics_creditnoteactionedby,
	usrCrNoteBy.[fullname] AS [Rics_creditnoteactionedbyName],
	ref.[apuk_requestedbyid] AS Rics_requestedbyid,
	usrReqBy.[fullname] AS [Rics_requestedbyIdName],	
	ref.[apuk_customeraccountnumber] AS Rics_customeraccountnumber,
	ref.[apuk_customersortcode]  AS Rics_customersortcode,
	ref.[apuk_creditnoteactioneddate] AS Rics_creditnoteactioneddate

FROM synapse_ce.apuk_caserefund ref
	--LEFT JOIN synapse_ce.contact cnt
	--	ON ref.apuk_customerid = cnt.contactid
	--LEFT JOIN synapse_ce.account acc
	--	ON cnt.accountid = acc.accountid
	LEFT JOIN synapse_ce.systemuser usrRefundCrNoteBy
		ON ref.[apuk_refundcreditnotebyid] = usrRefundCrNoteBy.[systemuserid]
	LEFT JOIN synapse_ce.systemuser usrAprDeclineBy
		ON ref.[apuk_approveddeclinedbyid] = usrAprDeclineBy.[systemuserid]
	LEFT JOIN synapse_ce.systemuser usrCrNoteBy
		ON ref.[apuk_creditnoteactionedby] = usrCrNoteBy.[systemuserid]
	LEFT JOIN synapse_ce.systemuser usrReqBy
		ON ref.[apuk_requestedbyid] = usrReqBy.[systemuserid]
	LEFT JOIN synapse_ce.StateMetadata stStateCode
		ON ref.[statecode] = stStateCode.[State]
			AND stStateCode.[EntityName] = 'apuk_caserefund'
	LEFT JOIN synapse_ce.OptionSetMetadata crNoteAct
		ON ref.[apuk_creditnoteactioned] = crNoteAct.[Option]
			AND crNoteAct.[OptionSetName] = 'apuk_creditnoteactioned'
	LEFT JOIN synapse_ce.OptionSetMetadata crNoteRefund
		ON ref.[apuk_refundcreditnote] = crNoteRefund.[Option]
			AND crNoteRefund.[OptionSetName] = 'apuk_refundcreditnote'
	LEFT JOIN synapse_ce.StateMetadata stStatusCode
		ON ref.[statuscode] = stStatusCode.[State]
			AND stStatusCode.[EntityName] = 'apuk_caserefund'
	LEFT JOIN synapse_ce.systemuser usrcreatedby
		ON ref.[createdby] = usrcreatedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser usrmodifiedby
		ON ref.[modifiedby] = usrmodifiedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser ownid
		ON ref.[ownerid] = ownid.[systemuserid]
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata reasonforrefund
		ON ref.[apuk_reasonforrefundcreditnote] = reasonforrefund.[Option]
			AND reasonforrefund.[OptionSetName] = 'apuk_reasonforrefundcreditnote'
			AND reasonforrefund.[EntityName] = 'apuk_caserefund'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata reqtype
		ON ref.[apuk_requesttype] = reqtype.[Option]
			AND reqtype.[OptionSetName] = 'apuk_requesttype'
			AND reqtype.[EntityName] = 'apuk_caserefund'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata paym
		ON ref.[apuk_originalpaymentmethod] = paym.[Option]
			AND paym.[OptionSetName] = 'apuk_originalpaymentmethod'
			AND paym.[EntityName] = 'apuk_caserefund'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata apprdecline
		ON ref.[apuk_approveddeclined] = apprdecline.[Option]
			AND apprdecline.[OptionSetName] = 'apuk_approveddeclined'
			AND apprdecline.[EntityName] = 'apuk_caserefund'
	WHERE NOT EXISTS (
		SELECT contactid
		FROM CE.tblContact_Test_Records TST
		WHERE TST.contactid = ref.[apuk_customerid]
		)
