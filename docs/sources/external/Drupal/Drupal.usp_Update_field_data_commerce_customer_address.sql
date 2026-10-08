CREATE   PROCEDURE [Drupal].[usp_Update_field_data_commerce_customer_address]
As

BEGIN

	UPDATE tgt SET 
		tgt.[bundle] = src.[bundle],
		tgt.[revision_id] = src.[revision_id],
		tgt.[commerce_customer_address_country] = src.[commerce_customer_address_country],
		tgt.[commerce_customer_address_administrative_area] = src.[commerce_customer_address_administrative_area],
		tgt.[commerce_customer_address_sub_administrative_area] = src.[commerce_customer_address_sub_administrative_area],
		tgt.[commerce_customer_address_locality] = src.[commerce_customer_address_locality],
		tgt.[commerce_customer_address_dependent_locality] = src.[commerce_customer_address_dependent_locality],
		tgt.[commerce_customer_address_postal_code] = src.[commerce_customer_address_postal_code],
		tgt.[commerce_customer_address_thoroughfare] = src.[commerce_customer_address_thoroughfare],
		tgt.[commerce_customer_address_premise] = src.[commerce_customer_address_premise],
		tgt.[commerce_customer_address_sub_premise] = src.[commerce_customer_address_sub_premise],
		tgt.[commerce_customer_address_organisation_name] = src.[commerce_customer_address_organisation_name],
		tgt.[commerce_customer_address_name_line] = src.[commerce_customer_address_name_line],
		tgt.[commerce_customer_address_first_name] = src.[commerce_customer_address_first_name],
		tgt.[commerce_customer_address_last_name] = src.[commerce_customer_address_last_name],
		tgt.[commerce_customer_address_data] = src.[commerce_customer_address_data]
	FROM [Drupal].[field_data_commerce_customer_address] tgt
		INNER JOIN [Work].[field_data_commerce_customer_address] src
			ON src.[entity_type] = tgt.[entity_type]
			AND src.[deleted] = tgt.[deleted]
			AND src.[entity_id] = tgt.[entity_id]
			AND src.[language] = tgt.[language]
			AND src.[delta] = tgt.[delta]

END
