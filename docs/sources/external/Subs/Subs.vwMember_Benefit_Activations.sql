CREATE     VIEW [Subs].[vwMember_Benefit_Activations] AS     

	SELECT
		 MBA.apuk_ricsrecordid AS 'RICS Record ID'
   		,CON.Rics_contactno AS 'Contact No'
   		,MBA.apuk_campaignyear AS 'Campaign Year'
   		,MBA.apuk_name AS 'MB ID'
   		,MBA.statecode_description AS 'State'
   		,MBA.statuscode_description AS 'Status'
   		,MBA.apuk_suspensionreason AS 'Suspension Reason'
   		,COALESCE(MS.[Member Invoice Position], 'No Invoice') AS 'Member Invoice Position'
		,MBA.apuk_suspendedbyName AS 'Suspended By'

    FROM CE.vwapuk_memberbenefitactivation MBA     
		LEFT JOIN synapse_ce.apuk_ricsrecord REC
       		ON REC.apuk_ricsrecordid = MBA.apuk_ricsrecordid
   		LEFT JOIN synapse_ce.vwContact CON
       		ON CON.contactid = REC.apuk_contactid
   		LEFT JOIN Subs.tblSubsMemberStatuses MS
       		ON CON.Rics_contactno = MS.[Contact No.]
       		AND MBA.apuk_campaignyear = MS.[Campaign Year]
	WHERE MBA.apuk_ricsrecordid IS NOT NULL
		AND MBA.statecode = 0
		AND MBA.statuscode = 1
		AND con.apuk_directdebit = 0
