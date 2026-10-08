/****** Object:  View [dbo].[vwOtherProfessionalBody]    Script Date: 26/08/2022 10:50:32 ******/
CREATE   VIEW [FAM].[vwOtherProfessionalBody]
AS

	SELECT  
		apuk_contactid AS ContactID, 
		opb.apuk_name AS [Affiliation], 
		OPBM.id AS OPBMRecId
	FROM [synapse_ce].[apuk_otherprofessionalbodymembership] OPBM
		INNER JOIN FAM.vwMember M 
			ON M.ContactID = OPBM.apuk_contactid
		LEFT JOIN synapse_ce.apuk_otherprofessionalbody opb
			ON OPBM.apuk_otherprofessionalbodyid = opb.apuk_otherprofessionalbodyid

	WHERE apuk_contactid is not null
		AND OPBM.statecode = 0
