CREATE   VIEW [FO].[vwProcurementManualPurchaseOrders]
AS

/*==============================================================================
 Purpose  : Summarize purchase order transactions at PO/Vendor level and return
            totals along with vendor name, currency, and PO Created Date.
 Source   : 
    - FO.vwPurchaseOrderTransactions (line-level transactions)
    - synapse_fo.PURCHTABLE          (PO header & created datetime)
    - FO.vwVendTable                 (vendor master)
 Filters  :
    - Exclude POs with PURCHSTATUS = 4 (closed/cancelled status)
    - No date filtering (full history)
 Notes    :
    - CAST() is used only to surface a DATE value from datetime.
    - This query intentionally returns results across _all time_.
==============================================================================*/

SELECT
    pot.[Purchase Order No]                      AS PurchaseOrderNo,
    pot.[Invoice Account]                        AS InvoiceAccount,
    pot.[Vendor Account]                         AS VendorAccount,
    vend.[name]                                  AS VendorName,
    SUM(pot.[Line Amount])                       AS POAmount,
    pot.[Currency Code]                          AS CurrencyCode,
    CAST(pt.CREATEDDATETIME AS date)             AS CreatedDate
FROM FO.vwPurchaseOrderTransactions AS pot
INNER JOIN synapse_fo.PURCHTABLE AS pt
    ON pot.[Purchase Order No] = pt.[PURCHID]
LEFT JOIN FO.vwVendTable AS vend
    ON pot.[Vendor Account] = vend.accountnum
WHERE
    pot.[PURCHSTATUS] <> 4                       -- keep only active/valid POs
GROUP BY
    pot.[Purchase Order No],
    pot.[Invoice Account],
    pot.[Vendor Account],
    vend.[name],
    pot.[Currency Code],
    pt.CREATEDDATETIME
