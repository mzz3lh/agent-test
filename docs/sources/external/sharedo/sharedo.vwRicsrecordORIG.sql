CREATE   VIEW [sharedo].[vwRicsrecordORIG]
AS
SELECT
	rr.apuk_ricsrecordid
	,rr.apuk_counsellorstartdate
	,rr.apuk_counsellortrainingcomplete
	,rr.apuk_designation
	,optdesig.LocalizedLabel as apuk_designationname
	,rr.apuk_eminentmember
	,opteminent.LocalizedLabel as apuk_eminentmembername
	,rr.apuk_expulsionalerttobedisplayed
	,rr.apuk_lapsecode
	,optlapsecode.LocalizedLabel as apuk_lapsecodename
	,rr.apuk_lapseddate
	,rr.apuk_membergrade
	,optmemgrade.LocalizedLabel as apuk_membergradename
	,rr.apuk_membershipstatus
	,optmemstatus.LocalizedLabel as apuk_membershipstatusname
	,rr.apuk_pathwayid
	,rr.apuk_pathwayidname
	,rr.apuk_pendingremovaldate
	,rr.apuk_preventlapse
	,rr.apuk_preventlapselastupdatedbyid
	,rr.apuk_preventlapselastupdatedbyidname
	,rr.apuk_preventlapselastupdatedon
	,rr.apuk_preventlapseownerid
	,rr.apuk_preventlapseowneridname
	,rr.apuk_removalapprovedbyid
	,rr.apuk_removalapprovedbyidname
	,rr.apuk_removalapproveddate
	,rr.apuk_retirementdate
	,rr.apuk_ricsmembershipnumber
	,rr.apuk_studentenrolmentdate
	,rr.apuk_suspensionexpirydate
	,rr.apuk_suspensionreviewdate
	,rr.apuk_contactid
	,rr.statecode
	,statecode.LocalizedLabel as statecodename	
	,rr.statuscode
	,statuscode.[LocalizedLabel] as statuscodename
	,rr.createdon
	,rr.createdby
	,rr.createdbyname
	,rr.createdbyyominame
	,rr.createdonbehalfby
	,rr.createdonbehalfbyname
	,rr.createdonbehalfbyyominame
	,rr.modifiedon
	,rr.modifiedby
	,rr.modifiedbyname
	,rr.modifiedbyyominame
	,rr.modifiedonbehalfby
	,rr.modifiedonbehalfbyname
	,rr.modifiedonbehalfbyyominame
	,rr.ownerid
	,rr.owneridname
FROM synapse_ce.apuk_ricsrecord rr
	LEFT JOIN synapse_ce.StateMetadata statecode
		ON rr.statecode = statecode.[State]
		AND statecode.[EntityName] = 'apuk_ricsrecord'
	LEFT JOIN synapse_ce.StatusMetadata statuscode
		ON rr.statuscode = statuscode.[Status]
		AND statuscode.[EntityName] = 'apuk_ricsrecord'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata optdesig
		ON rr.apuk_designation = optdesig.[Option]
		AND optdesig.[OptionSetName] = 'apuk_designation'
		AND optdesig.[EntityName] = 'apuk_ricsrecord'
	LEFT JOIN synapse_ce.OptionSetMetadata opteminent
		ON rr.apuk_eminentmember = opteminent.[Option]
		AND opteminent.[OptionSetName] = 'apuk_eminentmember'
		AND opteminent.[EntityName] = 'apuk_ricsrecord'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata optlapsecode
		ON rr.apuk_lapsecode = optlapsecode.[Option]
		AND optlapsecode.[OptionSetName] = 'apuk_lapsecode'
		AND optlapsecode.[EntityName] = 'apuk_ricsrecord'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata optmemgrade
		ON rr.apuk_membergrade = optmemgrade.[Option]
		AND optmemgrade.[OptionSetName] = 'apuk_membergrade'
		AND optmemgrade.[EntityName] = 'apuk_ricsrecord'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata optmemstatus
		ON rr.apuk_membershipstatus = optmemstatus.[Option]
		AND optmemstatus.[OptionSetName] = 'apuk_membershipstatus'
		AND optmemstatus.[EntityName] = 'apuk_ricsrecord'
