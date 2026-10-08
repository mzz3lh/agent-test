CREATE VIEW Product_Portfolio.vw_EB_Sub_Category AS
	SELECT 
	 Category_Id
	,SubCategory_Id
	,SubCategory_Name AS 'Sub-Category'
	FROM EventBrite.tblSubCategory
	GROUP BY 
	 Category_Id
	,SubCategory_Id
	,SubCategory_Name
