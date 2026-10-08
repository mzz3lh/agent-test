CREATE     VIEW [FO].[vwSupplierCategoryHierarchy]
AS
WITH supplier_category_hierarchy AS (
	  SELECT    
		RECID,
		[Name],
		1 AS [Level],
		CAST([NAME] + ' -> ' AS nvarchar(2000)) AS [Category Hierarchy]
	  FROM synapse_fo.ECORESCATEGORY
	  WHERE PARENTCATEGORY = 0
 
	  UNION ALL
   
	SELECT
		cat.RECID,
		cat.[NAME],
		sh.Level + 1 AS [Level],
		CAST(sh.[Category Hierarchy] + cat.[NAME] + ' -> ' AS nvarchar(2000)) AS [Category Hierarchy]
	  FROM synapse_fo.ECORESCATEGORY cat
		INNER JOIN supplier_category_hierarchy sh
			ON cat.PARENTCATEGORY = sh.RECID
)

SELECT 
	cat.RECID, 
	cat.[NAME] AS [Supplier Category], 
	cte.RECID AS [Parent CategoryId], 
	cte.[NAME] AS [Parent Category], 
	cte.[Level],
	cte.[Category Hierarchy]
FROM supplier_category_hierarchy cte
	INNER JOIN synapse_fo.ECORESCATEGORY cat
		ON cat.PARENTCATEGORY = cte.RECID

UNION ALL

SELECT    
	RECID,
	[NAME] AS [Supplier Category],
	NULL AS [Parent CategoryId],
	NULL AS [Parent Category],
	1 AS [Level],
	CAST([NAME] + ' -> ' AS nvarchar(2000)) AS [Category Hierarchy]
FROM synapse_fo.ECORESCATEGORY
WHERE PARENTCATEGORY = 0
