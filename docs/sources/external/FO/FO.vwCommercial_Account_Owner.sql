CREATE VIEW [FO].[vwCommercial_Account_Owner] AS

	SELECT 
	 SU.systemuserid AS 'Account Owner ID'
	,SU.yomifullname 'Account Owner'
	,TMM.teamid AS 'Team ID'
	,REPLACE(TM.name, 'Strategic Partnerships', 'SP') AS 'Team'
	FROM synapse_ce.systemuser SU
	LEFT JOIN synapse_ce.teammembership TMM
		ON SU.systemuserid = TMM.systemuserid
	LEFT JOIN synapse_ce.team TM
		ON TMM.teamid = TM.teamid
	WHERE TMM.teamid IN (
	'00000000-0000-0000-0000-000000000000', --AEMEA
	'00000000-0000-0000-0000-000000000000', --Strategic Partnerships - Americas
	'00000000-0000-0000-0000-000000000000', --Strategic Partnerships - APAC
	'00000000-0000-0000-0000-000000000000', --Strategic Partnerships - Europe
	--'00000000-0000-0000-0000-000000000000', --MEA	--Depracated
	'00000000-0000-0000-0000-000000000000'  --Strategic Partnerships - UK & Ireland
	)
	AND SU.systemuserid <> '00000000-0000-0000-0000-000000000000' --Temp Fix for Tanya Khan
