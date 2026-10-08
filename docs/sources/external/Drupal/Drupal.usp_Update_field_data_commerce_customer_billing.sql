CREATE   PROCEDURE [Drupal].[usp_Update_field_data_commerce_customer_billing]
As

BEGIN

	UPDATE tgt SET 
		tgt.[bundle] = src.[bundle],
		tgt.[revision_id] = src.[revision_id],
		tgt.[commerce_customer_billing_profile_id] = src.[commerce_customer_billing_profile_id]
	FROM [Drupal].[field_data_commerce_customer_billing] tgt
		INNER JOIN [Work].[field_data_commerce_customer_billing] src
			ON src.[entity_type] = tgt.[entity_type]
			AND src.[deleted] = tgt.[deleted]
			AND src.[entity_id] = tgt.[entity_id]
			AND src.[language] = tgt.[language]
			AND src.[delta] = tgt.[delta]

END
