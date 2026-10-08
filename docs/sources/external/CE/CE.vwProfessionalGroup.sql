CREATE VIEW CE.vwProfessionalGroup AS

	SELECT 
	 PG.[apuk_professionalgroupid] AS 'Professional Group Code'
	,[apuk_name] AS 'Professional Group'
	,[apuk_journal] AS 'Professional Group Panel'
	,[statecode] AS 'State'
	,[statuscode] As 'Status'
	FROM [synapse_ce].[apuk_professionalgroup] PG
