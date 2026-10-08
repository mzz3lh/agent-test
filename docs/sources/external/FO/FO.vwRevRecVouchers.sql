CREATE     VIEW [FO].[vwRevRecVouchers]
AS
	SELECT 
		Invoice, 
		[Item Number], 
		[Recognise Date],
		[mainaccount],
		[Customer Account],
		MAX([Sales Order]) AS [Sales Order],
		--STRING_AGG(voucher + ' \ ' +  CONVERT(NVARCHAR, leaveTime, 120) + '(' + CAST(DATEDIFF(MINUTE, joinTime, leaveTime) AS NVARCHAR) + ' minutes)','; ') AS [Time in Session]
		STRING_AGG(voucher,' \ ') AS [Voucher]
	FROM FO.vwRevRecSchedule
	--WHERE Invoice = 'INV-00000000'
	--and [Recognise Date] = '2023-04-27'	
	--and MAINACCOUNT = '000000'
	GROUP BY
		Invoice, 
		[Item Number], 
		[Recognise Date],
		[mainaccount],
		[Customer Account]
