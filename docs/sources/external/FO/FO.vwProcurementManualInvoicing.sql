CREATE    VIEW [FO].[vwProcurementManualInvoicing]
AS
/*==============================================================================
 Purpose  : Return vendor invoice journal rows enriched with vendor account and
            vendor name, filtered by company (DATAAREAID) and excluding negative 
            amounts. Returns full historical data (no date filters).
 Source   :
    - synapse_fo.VENDINVOICEJOUR    (journal header)
    - synapse_fo.VENDTABLE          (vendor master)
    - synapse_fo.DIRPARTYTABLE      (party name)
 Filters  :
    - DATAAREAID = 'rcs' (company identifier)
    - INVOICEAMOUNTMST >= 0
    - No date filtering (full history)
 Notes    :
    - Casting invoice date ensures consistent DATE output.
==============================================================================*/

WITH CTE_VendorInvoices AS
(
    SELECT
        CAST(T1.INVOICEDATE AS date)             AS InvoiceDate,
        T2.ACCOUNTNUM                            AS VendorAccountNumber,
        DIR.NAME                                 AS VendorName,
        T1.INVOICEAMOUNTMST                      AS InvoiceAmountMST,
		T2.LINEOFBUSINESSID						 AS LineOfBusinessId
    FROM synapse_fo.VENDINVOICEJOUR AS T1
    INNER JOIN synapse_fo.VENDTABLE AS T2
        ON T1.ORDERACCOUNT = T2.ACCOUNTNUM
       AND T1.DATAAREAID   = T2.DATAAREAID
    INNER JOIN synapse_fo.DIRPARTYTABLE AS DIR
        ON T2.PARTY = DIR.RECID
    WHERE
        T1.DATAAREAID = 'rcs'                    -- company filter only
)
SELECT
    InvoiceDate,
    VendorAccountNumber,
    VendorName,
    InvoiceAmountMST,
	LineOfBusinessId
FROM CTE_VendorInvoices
--WHERE                                            --WHERE Clause removed as per request Raj/Simon 10/03/2026
    --InvoiceAmountMST >= 0                        -- keep non-negative values
