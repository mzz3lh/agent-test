CREATE VIEW Product_Portfolio.vw_EB_Organisation AS

	SELECT
	 organization_id
	,Organization AS 'Organisation'
	FROM EventBrite.vwOrganization
