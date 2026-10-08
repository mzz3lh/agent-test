CREATE   VIEW [CE].[vwrics_rics_apc_rics_country]
AS
SELECT en.rics_apcid, lg.apuk_countryid as Rics_country--, lg.apuk_name, ctry.apuk_name
FROM synapse_ce.vwRicsAPC en
	inner join synapse_ce.vwLocalGroup lg
		on en.rics_enrolmentlocalgroupid = lg.apuk_localgroupid
--	inner join CE.vwCountry ctry
--		ON lg.apuk_countryid = ctry.apuk_countryid
