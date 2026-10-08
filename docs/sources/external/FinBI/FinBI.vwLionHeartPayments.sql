CREATE VIEW [FinBI].[vwLionHeartPayments]

AS

WITH cteCusttrans
AS
(
select 
ct.ACCOUNTNUM,
ct.INVOICE AS [Invoice No],
ct.CURRENCYCODE AS [Currency Code],
ct.AMOUNTCUR AS [Invoice amount],
ct.SETTLEAMOUNTCUR AS [Paid amount],
ct.AMOUNTMST  as 'GBP Invoice amount',
ct.SETTLEAMOUNTMST as 'GBP Paid amount',
ct.LASTSETTLEDATE as 'Payment Date',
ct.PAYMMODE AS PayMode,
CASE ct.RICEXTERNALINVOICEREF 
WHEN '' THEN 'Not Specified'
WHEN '2020' THEN 'Subs0000'
ELSE ct.RICEXTERNALINVOICEREF
END AS [Subs Year],
--CASE c.Rics_GiftAid 
--	WHEN 1 THEN 'Yes'
--	ELSE 'No'
--END 
'' AS GiftAid --TO BE ADDED TO vwContact
FROM AX.vwCUSTTRANS ct
where ct.RICINVOICETYPE='LHL'
and ct.AMOUNTCUR >0
and ct.SETTLEAMOUNTCUR >0
--and RICEXTERNALINVOICEREF=@SubsYear
and (ct.LASTSETTLEVOUCHER not like 'REV%'
OR ct.LASTSETTLEVOUCHER not like 'MWF%'
OR ct.LASTSETTLEVOUCHER not like '%CR' --CRE%
OR ct.LASTSETTLEVOUCHER not like '%GV')  --Check Voucher in CE matching invoice No's in AX - may be  able to use main account (ex.LH)
)


SELECT ct.* ,
c.rics_contactNo as 'Contact No', 
LEFT(c.rics_mailname,charindex(' ',c.rics_mailname)) as 'Title',
c.firstname AS FirstName
,c.lastname AS LastName
,c.rics_mailname AS MailName
,c.BirthDate As 'Date of Birth' 
, ISNULL(c.ParentCustomerIDName,'') AS [Company Name]
,ISNULL(c.address1_line1,'') as 'Correspondence Address: Line 1', 
ISNULL(c.address1_line2,'') as 'Correspondence Address: Line 2', 
ISNULL(c.address1_line3,'') as 'Correspondence Address: Line 3', 
ISNULL(c.address1_city,'') as 'Correspondence Address: City', 
'' as 'Correspondence Address: County', --TO BE ADDED TO vwContact
ISNULL(c.address1_postalcode,'') as 'Correspondence Address: Postcode', 
c.address1_country AS Country,
c.Rics_Region AS Region,
RG.Rics_WorldRegion AS WorldRegion,
LTRIM(RTRIM(SUBSTRING(c.rics_LocalGroupIDName,14,LEN(LTRIM(RTRIM(c.rics_LocalGroupIDName)))-13)))  AS LocalGroup,
ISNULL(c.emailaddress1,'') as 'Preferred E-mail', 
c.salutation AS Salutation


FROM cteCusttrans ct
INNER JOIN  [dbo].vwContact c ON ct.Accountnum = c.rics_financereference
LEFT OUTER JOIN dbo.vwRicsGroup RG 
ON RG.Rics_Name = c.rics_LocalGroupIDName 
AND RG.statecode = 0
