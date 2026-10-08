CREATE   VIEW [Product_Portfolio].[vw_MON_Item_Bridge] AS
 
    SELECT 
	[Item ID]
	,[Item Key]
    ,[EV Code] AS 'Product Code'
    ,'CE' AS 'Platform'
    FROM [Product_Portfolio].[vw_MON_Item]
    WHERE [EV Code] IS NOT NULL and [SKU Code] IS NULL

    UNION ALL

    SELECT 
	[Item ID]
   	,[Item Key]
	,[SKU Code]
    ,'OLA'
    FROM [Product_Portfolio].[vw_MON_Item]
    WHERE [EV Code] IS NULL and [SKU Code] IS NOT NULL

    
    UNION ALL

    SELECT 
    [Item ID]
   	,[Item Key]
	,[EV Code]
    ,'CE'
    FROM [Product_Portfolio].[vw_MON_Item]
    WHERE [EV Code] IS NOT NULL and [SKU Code] IS NOT NULL

    UNION ALL

    SELECT 
    [Item ID]
   	,[Item Key]
	,[SKU Code]
    ,'OLA'
    FROM [Product_Portfolio].[vw_MON_Item]
    WHERE [EV Code] IS NOT NULL and [SKU Code] IS NOT NULL
