CREATE   PROCEDURE [Adobe].[usp_truncate_staging_tables]
AS
BEGIN

	TRUNCATE TABLE Staging_Adobe.[browser]
	TRUNCATE TABLE Staging_Adobe.[browser_type]
	TRUNCATE TABLE Staging_Adobe.[carrier]
	TRUNCATE TABLE Staging_Adobe.[color_depth]
	TRUNCATE TABLE Staging_Adobe.[column_headers]
	TRUNCATE TABLE Staging_Adobe.[connection_type]
	TRUNCATE TABLE Staging_Adobe.[country]
	TRUNCATE TABLE Staging_Adobe.[event]
	TRUNCATE TABLE Staging_Adobe.[hit_data]
	TRUNCATE TABLE Staging_Adobe.[javascript_version]
	TRUNCATE TABLE Staging_Adobe.[languages]
	TRUNCATE TABLE Staging_Adobe.[mobile_attributes]
	TRUNCATE TABLE Staging_Adobe.[operating_system_type]
	TRUNCATE TABLE Staging_Adobe.[operating_systems]
	TRUNCATE TABLE Staging_Adobe.[plugins]
	TRUNCATE TABLE Staging_Adobe.[referrer_type]
	TRUNCATE TABLE Staging_Adobe.[resolution]
	TRUNCATE TABLE Staging_Adobe.[search_engines]

END
