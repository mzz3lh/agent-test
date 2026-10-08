CREATE VIEW [Product_Portfolio].[vw_SS_User] AS

	WITH CTE AS (
		SELECT 
		O.[uid]
		FROM Drupal.commerce_order O
		WHERE O.created >= '2022-01-01'
		GROUP BY [uid]
		)

	SELECT
	 U.[uid] AS 'User ID'
	,U.[name] AS 'User Name' --is it though?
	,U.mail AS 'User Email'
	,U.created AS 'Created Datetime'
	--,access]
	--,[login]
	,U.status AS 'Status'
	--,[timezone]
	--,[language]
	--,[init]
	--,[rh_action]
	--,[rh_redirect]
	--,[rh_redirect_response]
	--,[lr_raas_uid]
	--,[changed]
	FROM [Sharedstore].[users] U
	WHERE EXISTS (
		SELECT 
		CTE.[uid]
		FROM CTE CTE
		WHERE CTE.[uid] = U.[uid]
		)
