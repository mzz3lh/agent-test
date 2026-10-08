CREATE VIEW [Product_Portfolio].[vw_MON_Product_Bridge] AS
 
    SELECT 
    [EV Code] AS 'Product Code'
    ,'CE' AS 'Platform'
    FROM [Product_Portfolio].[vw_MON_Item]
    WHERE [EV Code] IS NOT NULL
    GROUP BY [EV Code]

    UNION

    SELECT 
     [SKU Code]
    ,'OLA'
    FROM [Product_Portfolio].[vw_MON_Item]
    WHERE [SKU Code] IS NOT NULL
    AND [Item ID] <> 2730058520
    GROUP BY [SKU Code]
