CREATE   VIEW [FinBI].[vwD365LionHeartPayments]

AS

WITH cteCusttrans
AS
(
	Select 
		ct.ACCOUNTNUM,
		ct.INVOICE AS [Invoice No],
		'Subs' + CAST((CASE WHEN DATEPART(MONTH, ct.[TRANSDATE]) >= 10 THEN DATEPART(YYYY, ct.[TRANSDATE])+1 ELSE DATEPART(YYYY, ct.[TRANSDATE]) END) AS NVARCHAR) AS [Subs Year],
		ct.CURRENCYCODE AS [Currency Code],
		ct.AMOUNTCUR AS [Invoice amount],
		--ct.SETTLEAMOUNTCUR AS [Paid amount],
		CASE WHEN DATEPART(YYYY, ct.[CLOSED]) > 1900 OR ct.[SETTLEAMOUNTCUR] >= 25 THEN ct.AMOUNTCUR ELSE [SETTLEAMOUNTCUR] END AS [Paid amount],  --changed from AMOUNTCUR --PS 04/04/2022
		ct.AMOUNTMST  as 'GBP Invoice amount',
		--ct.SETTLEAMOUNTMST as 'GBP Paid amount',
		CASE WHEN DATEPART(YYYY, ct.[CLOSED]) > 1900 OR ct.[SETTLEAMOUNTMST] >= 25 THEN ct.AMOUNTMST ELSE [SETTLEAMOUNTMST] END AS [GBP Paid amount],  --Changed from AMOUNTMST - PS 04/04/2022
		ct.LASTSETTLEDATE as 'Payment Date',
		ct.PAYMMODE AS PayMode
		--CASE ct.RICEXTERNALINVOICEREF 
		--WHEN '' THEN 'Not Specified'
		--WHEN '2020' THEN 'Subs0000'
		--ELSE ct.RICEXTERNALINVOICEREF
		--END AS [Subs Year],
		
	FROM FO.vwCUSTTRANS ct
		where ct.RICINVOICETYPE='LHL'
			  and ct.AMOUNTCUR >0
			  and ct.SETTLEAMOUNTCUR >0
			  --and RICEXTERNALINVOICEREF=@SubsYear
			  and (ct.LASTSETTLEVOUCHER not like 'REV%'
			  OR ct.LASTSETTLEVOUCHER not like 'MWF%'
			  OR ct.LASTSETTLEVOUCHER not like '%CR'
			  OR ct.LASTSETTLEVOUCHER not like '%GV')
)
	SELECT ct.* ,
		c.rics_contactNo as 'Contact No', 
		LEFT(c.rics_mailname,charindex(' ',c.rics_mailname)) as 'Title',
		c.Rics_MailName,
		c.firstname AS FirstName,
		c.lastname AS LastName,
		c.rics_mailname AS MailName,
		c.BirthDate As 'Date of Birth',
		CASE c.apuk_giftaid
			WHEN 1 THEN 'Yes'
			ELSE 'No'
			END 
		AS GiftAid, --TO BE ADDED TO vwContact
		ISNULL(A.rics_registeredname,'') AS CompanyName,--was ISNULL(c.ParentCustomerIDName,'') AS [Company Name] - C.parentcustomeridname not being populated --PS 04/04/2022
		ISNULL(c.address1_line1,'') as 'Correspondence Address: Line 1', 
		ISNULL(c.address1_line2,'') as 'Correspondence Address: Line 2', 
		ISNULL(c.address1_line3,'') as 'Correspondence Address: Line 3', 
		ISNULL(c.address1_city,'') as 'Correspondence Address: City', 
		--'' as 'Correspondence Address: County', --TO BE ADDED TO vwContact
		ISNULL(c.address1_postalcode,'') as 'Correspondence Address: Postcode', 
		c.address1_country AS Country,
		c.Rics_Region AS Region,
		RG.Rics_WorldRegion AS WorldRegion,
		--LTRIM(RTRIM(SUBSTRING(c.rics_LocalGroupIDName,14,LEN(LTRIM(RTRIM(c.rics_LocalGroupIDName)))-13)))  AS LocalGroup,
		c.rics_localgroupidName as LocalGroup,
		ISNULL(c.emailaddress1,'') as 'Preferred E-mail', 
		c.salutation AS Salutation

	FROM cteCusttrans ct
		INNER JOIN  CE.vwContact c ON ct.Accountnum = c.Rics_contactno
		LEFT OUTER JOIN CE.vwRicsGroup RG 
		ON RG.Rics_Name = c.rics_LocalGroupIDName 
		AND RG.statecode = 0
		LEFT JOIN CE.vwAccount A  --added to get company name . C.parentcustomeridname not being populated --PS 04/04/2022
		ON A.Accountid = C.ParentCustomerId

		--WHERE c.rics_contactNo ='0000000'
		----'0000000'
