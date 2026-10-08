CREATE VIEW FO.vwLionheartMatricsSettlement
AS
WITH cteVoucher
AS
(
SELECT LASTSETTLEVOUCHER FROM FO.vwLionheartMatricsInvoice --WHERE ContactNumber = '0000000'
)
SELECT  Voucher,Amountcur,Currency,LastSettleDate,LastSettleVoucher,PaymentType,Paymreference  
FROM [dbo].[vwD365MemberTransactionsSettlementsWIP]
WHERE LASTSETTLEVOUCHER IN (SELECT LASTSETTLEVOUCHER FROM cteVoucher)
