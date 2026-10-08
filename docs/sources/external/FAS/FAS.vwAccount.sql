CREATE   VIEW [FAS].[vwAccount]
AS
SELECT 
	origin.Id,
	origin.SinkCreatedOn,
	origin.SinkModifiedOn,
	origin.versionnumber,
	origin.apuk_firmnumber,
	origin.apuk_officenumber,
	origin.[Name],
	origin.apuk_tradingname,
	origin.StateCode,
	origin.StatusCode,
	FASstatus.LocalizedLabel AS FASstatus,
	origin.apuk_isofficeregulated,
	FASpracticeType.LocalizedLabel AS FASpracticeType,
	origin.apuk_isheadoffice,
	origin.address1_line1,
	origin.address1_line2,
	origin.address1_line3,
	origin.address1_city,
	origin.address1_county,
	origin.address1_postalcode,
	origin.address1_country,
	country.apuk_code,
	country.apuk_name,	
	origin.WebsiteURL,
	origin.EMailAddress1,
	origin.Telephone1,
	origin.Fax
FROM synapse_ce.account as origin
	LEFT OUTER JOIN synapse_ce.apuk_country as country on country.id = origin.apuk_countryid
	LEFT OUTER JOIN synapse_ce.GlobalOptionSetMetadata as FASstatus 
		ON FASstatus.optionsetname ='apuk_fasstatus' 
		AND FASstatus.[option] = origin.apuk_FASStatus
		AND FASstatus.[EntityName] = 'account'
	LEFT OUTER JOIN synapse_ce.GlobalOptionSetMetadata as FASpracticeType 
		ON FASpracticeType.optionsetname ='apuk_practicetype' 
		AND FASpracticeType.[option] = origin.apuk_practicetype
		AND FASpracticeType.[EntityName] = 'account'
	
	WHERE apuk_fasstatus <> 200000007 --Added PS 05/06/2024 to exclude 'Pending Confirmation' accounts - U/S 57765
