/*
ALEXANDRA DURSTON
JUNE 2024

This code was written to replicate a spreadsheet managed and maintained by David Allen.
It links together information about all sales orders with the product information contained in another RTF view,
which pulls together multiple product sources.
*/

CREATE VIEW InsightsBI.vwAD_RTF_GLOBAL_SALES_DATA AS

WITH SOD AS (
    -- Extract distinct sales order details and product information
    SELECT DISTINCT
        SalesOrderId,
        GROUPID,
        GROUPNAME,
        [Product Super Group]
    FROM CE.vwSalesOrderDetail SOD
    LEFT JOIN fo.vwProduct AS P
        ON RIGHT(SOD.productnumber, LEN(SOD.productnumber) - 3) = P.PRODUCTNUMBER
    LEFT JOIN fo.vwProductGroup PG
        ON P.PRODUCTGROUPID = PG.GROUPID
)

SELECT 
    -- Format order number by removing the first three characters
    RIGHT(OrderNumber, LEN(OrderNumber) - 3) AS ORDER_NUMBER,
    SO.CreatedOn,
    A.rics_namedaccount AS COMMERCIAL_ACCOUNT_KEY,
    A.rics_namedaccountName AS COMMERCIAL_ACCOUNT_NAME,
    SO.ContactId,
    C.FullName AS CUSTOMERNAME,
    CA.OwnerId AS COMMERCIAL_ACCOUNT_OWNER,
    SO.OwnerIdName AS ORDER_OWNER,
    isocurrencycode AS CURRENCY,
    TotalLineItemAmount AS TOTALAMOUNT_EXVAT_LOCAL_CURRENCY,
    TotalLineItemAmount_Base AS TOTALAMOUNT_EXVAT_GBP,
    SOD.GROUPID AS PRODUCTGROUPID,
    SOD.GROUPNAME AS PRODUCTGROUPNAME,
    SOD.[Product Super Group] AS PRODUCTSUPERGROUPNAME,
    SO.Name AS PRODUCTNAME,
    LG.apuk_worldregionid_name AS CUSTOMERWORLDREGION,
	lg.apuk_subregion_name as CUSTOMERSUBREGION,
	LG.apuk_regionid_name AS CUSTOMERREGION,
    apuk_eventcode AS EVENTCODE,
    CEPROD.BOOKING_USER,
    CEPROD.BOOKER_NAME,
    CEPROD.EVENT_TYPE AS FORMAT,
    CEPROD.PRODUCT_GROUP AS EVENT_TYPE,
    CASE 
        -- Categorize sales channels
        WHEN SO.OwnerIdName IN ('Ayres, Richard', 'SALESPROCESSLIVE', 'WEBJOBLIVE', 'SYSTEM', 
                                'AP API LIVE', 'SL365QUOTE', 'SL365CONTACT', 'BULK2', 'BULK0', 
                                'BULK1', 'BULK3', 'BULK4', 'BULK5', 'BULK6', 'BULK7', 'BULK8', 
                                'BULK9')
        THEN 'Online/Other'
        ELSE 'CRM Order'
    END AS SALES_CHANNEL_FLAG

FROM ce.vwSalesOrder AS SO

-- Join with contact details
LEFT JOIN CE.vwContact C
    ON C.ContactId = SO.ContactId

-- Join with local group details
LEFT JOIN CE.VWLOCALGROUP AS LG
    ON LG.apuk_localgroupid = C.rics_localgroupid

-- Join with account details
LEFT JOIN CE.vwAccount A
    ON C.ACCOUNTID = A.AccountId

-- Join with commercial account details
LEFT JOIN CE.vwCommercialAccount CA
    ON CA.Commercial_Account_Key = A.rics_namedaccount

-- Join with sales order details and product information
LEFT JOIN SOD
    ON SOD.SalesOrderId = SO.SalesOrderId

-- Join with product bookings information
LEFT JOIN InsightsBI.vwAD_CE_Product_Bookings AS CEPROD
    ON CEPROD.ORDER_ID = SO.SalesOrderId

WHERE SO.CreatedOn >='2022-01-01'
