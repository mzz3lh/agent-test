/****** Object:  View [dbo].[vwrics_rics_otherprofessionalbody_contact]    Script Date: 06/07/2021 11:06:27 ******/
CREATE   VIEW [synapse_ce].[vwrics_rics_otherprofessionalbody_contact]
AS
SELECT 
	mem.[apuk_otherprofessionalbodymembershipid] AS [rics_rics_otherprofessionalbody_contactId],
	mem.[apuk_otherprofessionalbodyid] AS [rics_otherprofessionalbodyid],
	mem.[apuk_contactid] AS [Contactid]
FROM synapse_ce.apuk_otherprofessionalbodymembership mem
WHERE NOT EXISTS (
	SELECT contactid
	FROM CE.tblContact_Test_Records TST
	WHERE TST.contactid = mem.[apuk_contactid]
	)
--WHERE mem.[apuk_contactid] = '00000000-0000-0000-0000-000000000000'
