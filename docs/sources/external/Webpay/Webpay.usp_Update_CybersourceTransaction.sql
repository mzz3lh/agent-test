CREATE   PROCEDURE [Webpay].[usp_Update_CybersourceTransaction]
AS
BEGIN

	UPDATE tgt SET
		tgt.[request_id] = src.[request_id],
		tgt.[row_descriptor] = src.[row_descriptor],
		tgt.[transaction_date] = src.[transaction_date],
		tgt.[merchant_ref_number] = src.[merchant_ref_number],
		tgt.[merchant_id] = src.[merchant_id],
		tgt.[ics_applications] = src.[ics_applications],
		tgt.[auth_rcode] = src.[auth_rcode],
		tgt.[auth_rflag] = src.[auth_rflag],
		tgt.[auth_rmsg] = src.[auth_rmsg],
		tgt.[auth_reversal_rcode] = src.[auth_reversal_rcode],
		tgt.[auth_reversal_rflag] = src.[auth_reversal_rflag],
		tgt.[auth_reversal_rmsg] = src.[auth_reversal_rmsg],
		tgt.[bill_rcode] = src.[bill_rcode],
		tgt.[bill_rflag] = src.[bill_rflag],
		tgt.[bill_rmsg] = src.[bill_rmsg],
		tgt.[customer_firstname] = src.[customer_firstname],
		tgt.[customer_lastname] = src.[customer_lastname],
		tgt.[customer_email] = src.[customer_email],
		tgt.[account_suffix] = src.[account_suffix],
		tgt.[customer_cc_expmo] = src.[customer_cc_expmo],
		tgt.[customer_cc_expyr] = src.[customer_cc_expyr],
		tgt.[customer_cc_startmo] = src.[customer_cc_startmo],
		tgt.[customer_cc_startyr] = src.[customer_cc_startyr],
		tgt.[customer_cc_issue_number] = src.[customer_cc_issue_number],
		tgt.[payment_method] = src.[payment_method],
		tgt.[currency] = src.[currency],
		tgt.[auth_auth_avs] = src.[auth_auth_avs],
		tgt.[auth_auth_code] = src.[auth_auth_code],
		tgt.[auth_cv_result] = src.[auth_cv_result],
		tgt.[payment_processor] = src.[payment_processor],
		tgt.[source] = src.[source],
		tgt.[subscription_id] = src.[subscription_id],
		tgt.[amount] = src.[amount],
		tgt.[Transaction_Reference_Number] = src.[Transaction_Reference_Number]
	FROM [Work].[tblCybersourceTransaction_Webpay] tgt
		INNER JOIN [webpay].[tblCybersourceTransaction] src
			ON tgt.[id] = src.[ID]


END
