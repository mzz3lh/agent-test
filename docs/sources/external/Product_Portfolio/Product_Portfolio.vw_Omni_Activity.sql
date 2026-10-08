CREATE VIEW [Product_Portfolio].[vw_Omni_Activity] AS 
 
    SELECT
     [Email Address] AS 'Customer Email'
    ,CAST([Event ID]AS varchar(50)) AS 'Activity ID'
    ,[Event Start Date] AS 'Activity Date'
    ,EV.[Created Date] AS 'Order Date'
    ,'CE' AS 'Platform'
    ,[Total Amount MST] AS 'Amount'
    ,1 AS 'Quantity'
    ,CAST([Event Code] AS VARCHAR(50)) AS 'Product Code'
    ,[Event Name] AS 'Product'
    ,[Business Group] AS 'Business Group'
    ,CONCAT(CAST([Event Code] AS VARCHAR(50)),' - ', [Event Name]) AS 'Product Full Name'
    FROM [Product_Portfolio].[vw_Omni_CE_Event] EV

    UNION ALL

    SELECT
     [User Email]
    ,CAST([Order ID] AS VARCHAR(50))
    ,[Order Created Date]
    ,[Order Created Date]
    ,'OLA'
    ,[Sales Amount MST]
    ,Quantity
    ,CAST(O.[Product ID] AS VARCHAR(50))
    ,P.[Product]
    ,[Business Group]
    ,CONCAT(CAST(O.[Product ID] AS VARCHAR(50)),' - ', P.[Product])
    FROM [Product_Portfolio].[vw_Omni_OLA_Order] O
    LEFT JOIN [Product_Portfolio].[vw_DR_Product] P
        ON P.SKU = O.[Product ID]
    UNION ALL

    SELECT 
     Email
    ,CAST(Event_Id AS VARCHAR(50))
    ,[Start Date]
    ,EB.[Order Date]
    ,'EB'
    ,ManualTotal
    ,1
    ,CAST(Event_Id AS VARCHAR(50))
    ,[Event Name]
    ,[Business Group] 
    ,CONCAT(CAST(Event_Id AS VARCHAR(50)),' - ', [Event Name])
    FROM [Product_Portfolio].[vw_Omni_EB_Event] EB
