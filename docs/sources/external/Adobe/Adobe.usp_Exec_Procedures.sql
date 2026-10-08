CREATE   PROCEDURE [Adobe].[usp_Exec_Procedures]
AS
BEGIN

	EXEC [Adobe].[usp_Upsert_browser]
	EXEC [Adobe].[usp_Upsert_browser_type]
	--EXEC [Adobe].[usp_Upsert_carrier]
	EXEC [Adobe].[usp_Upsert_color_depth]
	EXEC [Adobe].[usp_Upsert_column_headers]
	EXEC [Adobe].[usp_Upsert_connection_type]
	EXEC [Adobe].[usp_Upsert_country]
	EXEC [Adobe].[usp_Upsert_event]
	EXEC [Adobe].[usp_Upsert_hit_data]
	EXEC [Adobe].[usp_Upsert_javascript_version]
	EXEC [Adobe].[usp_Upsert_languages]
	EXEC [Adobe].[usp_Upsert_mobile_attributes]
	EXEC [Adobe].[usp_Upsert_operating_system_type]
	EXEC [Adobe].[usp_Upsert_operating_systems]
	EXEC [Adobe].[usp_Upsert_plugins]
	EXEC [Adobe].[usp_Upsert_referrer_type]
	EXEC [Adobe].[usp_Upsert_resolution]
	EXEC [Adobe].[usp_Upsert_search_engines]

	EXEC [Adobe].[usp_truncate_staging_tables]
END
