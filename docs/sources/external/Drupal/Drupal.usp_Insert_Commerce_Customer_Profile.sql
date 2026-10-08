/************** NEW Drupal Procedures ***************/

CREATE   PROCEDURE [Drupal].[usp_Insert_Commerce_Customer_Profile]
As
BEGIN

	INSERT INTO [Drupal].[commerce_customer_profile]
	(
		[profile_id],
		[revision_id],
		[type],
		[uid],
		[status],
		[created],
		[changed]
	)
	SELECT
		src.[profile_id],
		src.[revision_id],
		src.[type],
		src.[uid],
		src.[status],
		src.[created],
		src.[changed]
	FROM [Work].[commerce_customer_profile] src
		LEFT JOIN [Drupal].[commerce_customer_profile] tgt
			ON src.[profile_id] = tgt.[profile_id]
	WHERE tgt.[profile_id] IS NULL


END
