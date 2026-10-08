CREATE VIEW [DQ].[vwDQ_Dimensions]
AS 

/*=============================================
	Author:			srini.akula
	Create date:	14.01.2022
	Description:	Returns DQ Dimensions 
					
===============================================================================*/

	SELECT 
	 DimensionName AS 'Dimension'
	,Seq AS 'Dimension Order'
	FROM [DQ].[Dimension]
	WHERE DimensionName <> 'Uniqueness'
