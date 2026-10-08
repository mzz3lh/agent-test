CREATE VIEW Product_Portfolio.vw_EB_Category AS

	SELECT
	 Category_Id
	,Category_Name AS 'Category'
	--,Organization_Id
	FROM EventBrite.tblCategory
	GROUP BY 
	 Category_Id
	,Category_Name
