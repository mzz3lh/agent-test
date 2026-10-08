CREATE   PROCEDURE [Webpay].[usp_Insert_CybersourceTransaction]
AS
BEGIN

	INSERT INTO [webpay].[tblCybersourceTransaction]
	(
		[ID],
		[request_id],
		[row_descriptor],
		[transaction_date],
		[merchant_ref_number],
		[merchant_id],
		[ics_applications],
		[auth_rcode],
		[auth_rflag],
		[auth_rmsg],
		[auth_reversal_rcode],
		[auth_reversal_rflag],
		[auth_reversal_rmsg],
		[bill_rcode],
		[bill_rflag],
		[bill_rmsg],
		[customer_firstname],
		[customer_lastname],
		[customer_email],
		[account_suffix],
		[customer_cc_expmo],
		[customer_cc_expyr],
		[customer_cc_startmo],
		[customer_cc_startyr],
		[customer_cc_issue_number],
		[payment_method],
		[currency],
		[auth_auth_avs],
		[auth_auth_code],
		[auth_cv_result],
		[payment_processor],
		[source],
		[subscription_id],
		[amount],
		[Transaction_Reference_Number]
	)
	SELECT
		src.[ID],
		src.[request_id],
		src.[row_descriptor],
		src.[transaction_date],
		src.[merchant_ref_number],
		src.[merchant_id],
		src.[ics_applications],
		src.[auth_rcode],
		src.[auth_rflag],
		src.[auth_rmsg],
		src.[auth_reversal_rcode],
		src.[auth_reversal_rflag],
		src.[auth_reversal_rmsg],
		src.[bill_rcode],
		src.[bill_rflag],
		src.[bill_rmsg],
		src.[customer_firstname],
		src.[customer_lastname],
		src.[customer_email],
		src.[account_suffix],
		src.[customer_cc_expmo],
		src.[customer_cc_expyr],
		src.[customer_cc_startmo],
		src.[customer_cc_startyr],
		src.[customer_cc_issue_number],
		src.[payment_method],
		src.[currency],
		src.[auth_auth_avs],
		src.[auth_auth_code],
		src.[auth_cv_result],
		src.[payment_processor],
		src.[source],
		src.[subscription_id],
		src.[amount],
		src.[Transaction_Reference_Number]
	FROM [Work].[tblCybersourceTransaction_Webpay] src
		LEFT JOIN [webpay].[tblCybersourceTransaction] tgt
			ON src.[ID] = tgt.[ID]
	WHERE tgt.[ID] IS NULL

END
