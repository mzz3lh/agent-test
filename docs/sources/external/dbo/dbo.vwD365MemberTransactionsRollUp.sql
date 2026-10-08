CREATE VIEW [dbo].[vwD365MemberTransactionsRollUp]
AS

SELECT AD.ContactNo AS [Contact Number],
AD.Invoice AS [Invoice],
AD.InvType AS [Invoice Type],
AD.TransDate AS [Invoice Date],
AD.Duedate AS [Due Date],
AD.VOUCHER AS Voucher,
AD.Currency,
AD.LineAmountCUR AS [Invoice Item Amount],
CASE WHEN AD.Closed = '01-JAN-1900'
			THEN AD.LineAmountCUR
			ELSE 0.00
END AS [Item Balance],
CASE WHEN AD.Closed = '01-JAN-1900'
			THEN NULL
			ELSE AD.Closed
END AS [Closed Date],
--AD.BalanceCUR AS [Item Balance],
AD.TXT AS [Transaction Text],
AD.TotalDebtStatus AS [Total Invoice Status]


FROM FO.tblFOAgedDebt AD
--WHERE AD.[ContactNo] = '0000000'
