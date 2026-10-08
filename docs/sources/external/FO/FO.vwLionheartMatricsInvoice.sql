CREATE VIEW FO.vwLionheartMatricsInvoice
AS

WITH cteInvoice 
AS
(SELECT InvoiceNo
FROM [CE].[vwLionheartMatricsEvents])

SELECT *,
INVOICE AS InvoiceNo
--, ContactNumber,FirstName, LastName, FullName
--,Voucher,LastSettleVoucher,Currency,InvoiceTotal,ItemAmount,InvoiceType,[Transaction Text]
FROM [dbo].[vwD365MemberTransactionsWIP]
WHERE INVOICE IN (SELECT InvoiceNo FROM cteInvoice)
