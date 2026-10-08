CREATE VIEW dbo.vwSalesOrdersWithInvoiceDetails
 AS
 
 
 
 SELECT TOP 100
				MAIN.OrderReference,
               -- Inv.INVOICEID,
               -- Inv.[Invoice Type], --Added PS 09/10/2017
               -- MAIN.[PO Number], --Added PS 09/10/2017
               -- inv.[GL Account],
               -- inv.[Cost Centre],
                MAIN.[Product number/code],
                MAIN.[ProductName],
                Main.DateFulfilled AS [Date of purchase], --Sales order date full filled
                MAIN.[Sub Start Date],
                MAIN.[Sub End Date],
                DATEDIFF(mm, MAIN.[Sub Start Date], MAIN.[Sub End Date]) AS [Months Between Sub Start/End],
				MAIN.[Net Amount], -- Changed from AX invoice data to CRM Sales Order Detail Data 11/02/2020 - DBA/PS
				MAIN.[Tax Amount], -- Changed from AX invoice data to CRM Sales Order Detail Data 11/02/2020 - DBA/PS
				MAIN.[Gross Amount], -- Changed from AX invoice data to CRM Sales Order Detail Data 11/02/2020 - DBA/PS
              --  inv.AmountCur - inv.[Tax Amount] AS [Net Amount], --Optional
             --   inv.[Tax Amount], --Optional
                --inv.[Tax Code],
             --   Inv.AMOUNTCUR AS [GROSS AMOUNT],
 --ISNULL(MAIN.[Account Country],MAIN.[Contact Country]) AS COUNTRY,
                ISNULL(MAIN.[Account CUK code], MAIN.[Contact CUK code]) AS CUK,
                [Is Evergreen],
                [Is Personal],
                [Channel],
                ISNULL(MAIN.[Account Name], '') AS [On Behalf Of Name],
                ISNULL(MAIN.[Account Address Line 1], '') AS [On Behalf Of Address Line 1],
                ISNULL(MAIN.[Account Address Line 2], '') AS [On Behalf Of Address Line 2],
                ISNULL(MAIN.[Account Address Country], '') AS [On Behalf Of Address Country],
                ISNULL(MAIN.[Account Address PostalCode], '') AS [On Behalf Of Address PostalCode],
                Main.[Account Firm Number] AS [On Behalf Of Firm Number],
                Main.[Account Office Number] AS [On Behalf Of Office Number],
                Main.[Contact Number] AS [On Behalf Of Contact Number],
                MAIN.[Payment Method],
                MAIN.[Subscription status],
                MAIN.[Purchase Type],
                MAIN.[Owner Full Name],
                MAIN.[Owner Contact Number],
                MAIN.[Owner Address1],
                MAIN.[Owner Address2],
                MAIN.[Owner Country],
                MAIN.[Owner PostCode],
                MAIN.[Subscription Name],
                MAIN.[Licences Allocated],
                MAIN.[Licences Used],
                MAIN.StateCode
         FROM
(
    SELECT DISTINCT
           SO.customerid,
          -- SO.ContactIdYomiName,
           --SO.AccountIdYomiName,
           SO.ricsv1_TransactionId,
           SO.DateFulfilled,

		   SOD.BaseAmount AS [Net Amount], -- Changed from AX invoice data to CRM Sales Order Detail Data 11/02/2020 - DBA/PS
		   SOD.Tax AS [Tax Amount], -- Changed from AX invoice data to CRM Sales Order Detail Data 11/02/2020 - DBA/PS
		   SOD.BaseAmount + SOD.Tax AS [Gross Amount], -- Changed from AX invoice data to CRM Sales Order Detail Data 11/02/2020 - DBA/PS

           PRD.Product_Number AS [Product number/code],
           PRD.[Product_Name] AS ProductName,
           SUB.ricsv2_startdate AS [Sub Start Date],
           SUB.ricsv2_enddate AS [Sub End Date],
           sm5.Value AS [Subscription status],
           GA.Rics_groupId AS AccountGroupId,
           GA.rics_countryidName AS [Account Country],
           GC.Rics_groupId AS ContactGroupId,
           GC.rics_countryidName AS [Contact Country],
           A.Ccl_tradeaccountreference AS [Account CUK code],
           A.AccountNumber AS [Account ID],
           A.Rics_TradingName AS [Account Name],
           A.Rics_FirmNumber AS [Account Firm Number],
           A.Rics_OfficeNumber AS [Account Office Number],
           A.Address1_Line1 AS [Account Address Line 1],
           A.Address1_Line2 AS [Account Address Line 2],
           A.Address1_Country AS [Account Address Country],
           A.Address1_PostalCode AS [Account Address PostalCode],
           C.Rics_FinanceReference AS [Contact CUK code],
           C.ContactId AS [Contact ID],
           C.FullName AS [Contact Name],
           C.Rics_contactno AS [Contact Number],
           C.Address1_Line1 AS [Contact Address Line 1],
           C.Address1_Line2 AS [Contact Address Line 2],
           C.Address1_Country AS [Contact Address Country],
           C.Address1_PostalCode AS [Contact Address PostalCode],
           SO.accountid,
           SO.contactid,
  --SM1.Value AS [Subscription Status],
           SM2.Value AS [Payment Method],
           SM3.Value AS [Is Evergreen],
           SM4.Value AS [Channel],
           CASE
               WHEN C.ContactId IS NOT NULL
               THEN 'Personal'
               ELSE 'Organisation'
           END AS [Is Personal],
           CASE
               WHEN SUB.ricsv2_name LIKE 'Initial%'
               THEN 'New Purchase'
               WHEN SUB.ricsv2_name LIKE 'Additional%'
               THEN 'Add On Purchase'
               WHEN SUB.ricsv2_name LIKE 'Renewal%'
               THEN 'Renewal'
               ELSE ''
           END AS [Purchase Type],
           OwnerContact.FullName AS [Owner Full Name],
           OwnerContact.Rics_contactno AS [Owner Contact Number],
           OwnerContact.[Address1_Line1] AS [Owner Address1],
           OwnerContact.[Address1_Line2] AS [Owner Address2],
           OwnerContact.[Address1_Country] AS [Owner Country],
           OwnerContact.[Address1_PostalCode] AS [Owner PostCode],
           SUB.ricsv2_name AS [Subscription Name],
           --SO.ricsv1_PurchaseOrderNumber AS [PO Number],
           SUB.ricsv2_NumberofLicences AS [Licences Allocated], --Added PS 09/10/2017
           SUB.ricsv1_licencesused AS [Licences Used], --Added PS 09/10/2017
           SO.statecode,
		   SUBSTRING(REPLACE(ordernumber, '-', ''),4,10) AS OrderReference --replaced the code below. now 6 digits in the middle numbers in the order id DBA/PS 09/12/2019
           --LEFT(RIGHT(REPLACE(ordernumber, '-', ''), 11), 10) AS OrderReference
    FROM dbo.vwSalesOrder SO 
         LEFT JOIN dbo.vwricsv2subscription AS SUB ON SO.SalesOrderId = SUB.ricsv1_SalesOrderId 
         LEFT JOIN dbo.vwSalesOrderDetail AS SOD ON SO.SalesOrderId = SOD.SalesOrderId
         LEFT JOIN dbo.vwProduct AS PRD ON SOD.ProductId = PRD.ProductId
         LEFT JOIN dbo.vwAccount AS A ON SO.customerid = A.AccountId
         LEFT JOIN dbo.vwContact AS C ON SO.customerid = C.ContactId
         LEFT JOIN dbo.vwContact AS OwnerContact ON SO.ricsv1_ProductOwner = OwnerContact.ContactId
         LEFT JOIN dbo.vwRicsGroup AS GA ON A.rics_localgroupid = GA.Rics_groupId
         LEFT JOIN dbo.vwRicsGroup AS GC ON C.rics_localgroupid = GC.Rics_groupId
         LEFT JOIN dbo.vwSubscriptionOwner AS SUBO ON SUB.ricsv2_subscriptionsid = SUBO.subscriptionownerid
         LEFT JOIN dbo.vwStringMap AS SM1 ON SUB.statuscode = SM1.AttributeValue
                                                      AND SM1.AttributeName = 'statuscode'
                                                      AND SM1.ObjectTypeCode = '00000'
         LEFT JOIN dbo.vwStringMap AS SM2 ON SO.ricsv1_PaymentMethod = SM2.AttributeValue
                                                      AND SM2.AttributeName = 'ricsv1_PaymentMethod'
                                                      AND SM2.ObjectTypeCode = '1088'
         LEFT JOIN dbo.vwStringmap AS SM3 ON SUBO.ricsv2_DoNotAutoRenew = SM3.AttributeValue
                                                      AND SM3.AttributeName = 'ricsv2_DoNotAutoRenew'
                                                      AND SM3.ObjectTypeCode = '00000'
         LEFT JOIN dbo.vwStringMap AS SM4 ON SUBO.ricsv2_Channel = SM4.AttributeValue
                                                      AND SM4.AttributeName = 'ricsv2_Channel'
                                                      AND SM4.ObjectTypeCode = '00000'
         LEFT JOIN dbo.vwStringMap AS SM5 ON SUBO.statuscode = SM5.AttributeValue
                                                      AND SM5.AttributeName = 'statuscode'
                                                      AND SM5.ObjectTypeCode = '00000'
    WHERE so.StateCode = 3 --fulfilled
) MAIN
--OUTER APPLY
--(
--    SELECT *
--    FROM DBADB.DBO.InvoicesAX AS iax
--    WHERE iax.RICEXTERNALINVOICEREF = MAIN.OrderReference COLLATE SQL_Latin1_General_CP1_CI_AS
--) Inv



/********************************************************WORKING QUERIES AND NOTES*********************************************************
SELECT TOP 10 * FROM dbo.vwSubscriptionOwner



****************************************************************************************************************************************************/
