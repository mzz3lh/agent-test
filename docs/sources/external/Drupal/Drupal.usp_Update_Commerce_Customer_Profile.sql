CREATE   PROCEDURE [Drupal].[usp_Update_Commerce_Customer_Profile]
As

BEGIN

	UPDATE tgt SET 
		tgt.[revision_id] = src.[revision_id],
		tgt.[type] = src.[type],
		tgt.[uid] = src.[uid],
		tgt.[status] = src.[status],
		tgt.[created] = src.[created],
		tgt.[changed] = src.[changed]
	FROM [Drupal].[commerce_customer_profile] tgt
		INNER JOIN [Work].[commerce_customer_profile] src
			ON tgt.[profile_id] = src.[profile_id]

END
