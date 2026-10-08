CREATE   PROCEDURE [Drupal].[usp_Insert_field_data_commerce_customer_address]
As
BEGIN

	INSERT INTO [Drupal].[field_data_commerce_customer_address]
	(
		[entity_type],
		[bundle],
		[deleted],
		[entity_id],
		[revision_id],
		[language],
		[delta],
		[commerce_customer_address_country],
		[commerce_customer_address_administrative_area],
		[commerce_customer_address_sub_administrative_area],
		[commerce_customer_address_locality],
		[commerce_customer_address_dependent_locality],
		[commerce_customer_address_postal_code],
		[commerce_customer_address_thoroughfare],
		[commerce_customer_address_premise],
		[commerce_customer_address_sub_premise],
		[commerce_customer_address_organisation_name],
		[commerce_customer_address_name_line],
		[commerce_customer_address_first_name],
		[commerce_customer_address_last_name],
		[commerce_customer_address_data]
	)
	SELECT
		src.[entity_type],
		src.[bundle],
		src.[deleted],
		src.[entity_id],
		src.[revision_id],
		src.[language],
		src.[delta],
		src.[commerce_customer_address_country],
		src.[commerce_customer_address_administrative_area],
		src.[commerce_customer_address_sub_administrative_area],
		src.[commerce_customer_address_locality],
		src.[commerce_customer_address_dependent_locality],
		src.[commerce_customer_address_postal_code],
		src.[commerce_customer_address_thoroughfare],
		src.[commerce_customer_address_premise],
		src.[commerce_customer_address_sub_premise],
		src.[commerce_customer_address_organisation_name],
		src.[commerce_customer_address_name_line],
		src.[commerce_customer_address_first_name],
		src.[commerce_customer_address_last_name],
		src.[commerce_customer_address_data]
	FROM [Work].[field_data_commerce_customer_address] src
		LEFT JOIN [Drupal].[field_data_commerce_customer_address] tgt
			ON src.[entity_type] = tgt.[entity_type]
			AND src.[deleted] = tgt.[deleted]
			AND src.[entity_id] = tgt.[entity_id]
			AND src.[language] = tgt.[language]
			AND src.[delta] = tgt.[delta]
	WHERE tgt.[entity_id] IS NULL


END
