CREATE VIEW [BI].[vw_Drill_PLTrans]
AS
SELECT 
	  lt.ACCOUNTNUM [GL Account]
	, lt.DIMENSION [Cost Centre]
	, lt.DATAAREAID [Entity]
	, lt.transdate
	, format(lt.transdate,'MMMM') ReportMth
	, cast(case when month(lt.transdate) in (8,9,10,11,12) then year(lt.transdate)+1 else year(lt.transdate) end as varchar) [FiscalYear]

	, case when lt.AMOUNTMSTSECOND = 0 then convert(decimal(18,2),lt.AMOUNTMST) else convert(decimal(18,2),lt.AMOUNTMSTSECOND) end [AMOUNTGBP] 

	, convert(decimal(18,2),

	   case when gh.currency = 'GBP' then 
		   case when lt.AMOUNTMSTSECOND = 0 then lt.AMOUNTMST else lt.AMOUNTMSTSECOND end 
	   when gh.currency = lt.currencycode then lt.amountcur else round(lt.amountmst/isnull(rer.ExchangeRate/100,1),2) end) [AmountReportingCur]
	, gh.Currency [ReportingCur]
	, convert(decimal(18,2),lt.AMOUNTCUR) [AmountOriginalCur]
	, lt.CURRENCYCODE [OriginalCur]
	, lt.VOUCHER
	, lt.TXT
	, vtr.ACCOUNTNUM [Vendor Account]
	, vt.NAME [Vendor Name]
	, vt.VENDGROUP
	, lt.DIMENSION2_ [Product]
	, d.DESCRIPTION
	, ct.ACCOUNTNUM [Customer Account]
	, ctb.NAME [Customer Name]
FROM AX.vwLedgerTrans lt

	LEFT JOIN AX.vwVENDTRANS vtr 
		on lt.VOUCHER = vtr.VOUCHER 
		and lt.DATAAREAID = vtr.DATAAREAID

	LEFT JOIN AX.vwVENDTABLE vt 
		on vt.ACCOUNTNUM = vtr.ACCOUNTNUM 
		and vtr.DATAAREAID = vt.DATAAREAID 

	LEFT JOIN AX.vwDimensions d 
		on lt.DIMENSION2_ = d.NUM 

		
	LEFT JOIN [AX].[tblGlobalHierarchy] gh 
		on lt.DIMENSION = gh.[Cost Centre] 
   
	LEFT JOIN AX.vwExchangeRates rer 
		ON lt.DATAAREAID = rer.DATAAREAID 
		AND lt.TRANSDATE BETWEEN rer.FROMDATE AND rer.ToDate
		AND rer.CURRENCYCODE = gh.Currency 

	LEFT JOIN AX.vwCustTrans ct 
		on lt.VOUCHER = ct.voucher 
		and lt.DATAAREAID = ct.DATAAREAID  
  
	LEFT JOIN AX.vwCustTable ctb
		on ctb.ACCOUNTNUM = ct.ACCOUNTNUM 
		and lt.DATAAREAID = ctb.DATAAREAID 

WHERE lt.ACCOUNTNUM < 60000
  and lt.TRANSDATE >= cast(year(getdate())-1 as varchar(4)) + '-08-01'
