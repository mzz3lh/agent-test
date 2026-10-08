CREATE    VIEW [synapse_ce].[vwRicsRecord]
AS
SELECT 
	rec.[apuk_ricsrecordid],
	rec.[apuk_name],
	rec.[createdon],
	rec.[createdby],
	usrcreatedby.[fullname] AS [CreatedByName],
	rec.[modifiedon],
	rec.[modifiedby],
	usrmodifiedby.[fullname] AS [ModifiedByName],
	rec.[ownerid],
	rec.[apuk_membergrade],
	memgrade.[LocalizedLabel] AS [apuk_membergrade_description],
	rec.[apuk_membershipstatus],
	memstatus.[LocalizedLabel] AS [apuk_membershipstatus_description],
	rec.[apuk_designation],
	desig.[LocalizedLabel] AS [apuk_designation_description],
	rec.[apuk_applicanttype],
	appltype.[LocalizedLabel] AS [apuk_applicanttype_description],
	rec.[apuk_lapsecode],
	lapsecode.[LocalizedLabel] AS [apuk_lapsecode_description],
	rec.[apuk_lapseddate],
	rec.[apuk_preventlapse],
	rec.[apuk_assessorauditor],
	rec.[apuk_assessorchairperson],
	rec.[apuk_eminentmember],
	rec.[apuk_pathwayid],
	pth.[apuk_code] AS [Pathway_Code],
	pth.[apuk_name] AS [apuk_pathwayid_name],
	rec.[apuk_applicationtypeid],
	aptype.[apuk_name] AS [apuk_applicationtypeid_name],
	rec.[apuk_contactid],
	rec.[apuk_ricsmembershipnumber],
	rec.[apuk_routeid],
	rec.[apuk_regionid],
	region.[name] AS [apuk_regionid_name],
	rec.[apuk_pendingremovaldate],
	rec.[apuk_counsellorstartdate],
	rec.[apuk_firstqualifiedlocalgroup],
	rec.[apuk_datequalified],
	rec.[apuk_counsellortrainingcomplete],
	rec.[apuk_studentenrolmentdate],
	rec.[apuk_billtoid],
	rec.[apuk_billtoidyominame],
	rec.[statecode],
	statecode.[LocalizedLabel] AS [statecode_description],
	rec.[statuscode],
	statuscode.[LocalizedLabel] AS [statuscode_description],
	rec.[apuk_primaryprofessionalgroupid],
	profgp.[apuk_name] AS [apuk_primaryprofessionalgroupid_name],
	profgp.[apuk_professionalgroupid],
	rec.[apuk_lastrecordedethicalcpd],
	rec.[apuk_donotchase],
	donotchase.[LocalizedLabel] AS [apuk_donotchase_description],
	rec.[apuk_apprentice]
FROM synapse_ce.apuk_ricsrecord rec
	LEFT JOIN synapse_ce.systemuser usrcreatedby
		ON rec.[createdby] = usrcreatedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser usrmodifiedby
		ON rec.[modifiedby] = usrmodifiedby.[systemuserid]

	LEFT JOIN synapse_ce.GlobalOptionSetMetadata memstatus
		ON rec.[apuk_membershipstatus] = memstatus.[Option]
		AND memstatus.[OptionSetName] = 'apuk_membershipstatus'
		AND memstatus.[EntityName] = 'apuk_ricsrecord'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata desig
		ON rec.[apuk_designation] = desig.[Option]
		AND desig.[OptionSetName] = 'apuk_designation'
		AND desig.[EntityName] = 'apuk_ricsrecord'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata appltype
		ON rec.[apuk_applicanttype] = appltype.[Option]
		AND appltype.[OptionSetName] = 'apuk_applicanttype'
		AND appltype.[EntityName] = 'apuk_ricsrecord'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata lapsecode
		ON rec.[apuk_lapsecode] = lapsecode.[Option]
		AND lapsecode.[OptionSetName] = 'apuk_lapsecode'
		AND lapsecode.[EntityName] = 'apuk_ricsrecord'
	LEFT JOIN synapse_ce.apuk_pathway pth
		ON rec.[apuk_pathwayid] = pth.[apuk_pathwayid]
	LEFT JOIN synapse_ce.apuk_applicationtype aptype
		ON rec.[apuk_applicationtypeid] = aptype.[apuk_applicationtypeid]
	LEFT JOIN synapse_ce.territory region
		ON rec.[apuk_regionid] = region.[territoryid]
	LEFT JOIN synapse_ce.StateMetadata statecode
		ON rec.[statecode] = statecode.[State]
		AND statecode.[EntityName] = 'apuk_ricsrecord'
	LEFT JOIN synapse_ce.StatusMetadata statuscode
		ON rec.[statuscode] = statuscode.[Status]
		AND statuscode.[EntityName] = 'apuk_ricsrecord'
	LEFT JOIN synapse_ce.apuk_membersprofessionalgroup profgp
		ON rec.[apuk_primaryprofessionalgroupid] = profgp.[apuk_membersprofessionalgroupid]
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata memgrade
		ON rec.[apuk_membergrade] = memgrade.[Option]
		AND memgrade.[OptionSetName] = 'apuk_membergrade'
		AND memgrade.[EntityName] = 'apuk_ricsrecord'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata donotchase
		ON rec.[apuk_donotchase] = donotchase.[Option]
		AND donotchase.[OptionSetName] = 'apuk_donotchase'
		AND donotchase.[EntityName] = 'apuk_ricsrecord'

	WHERE NOT EXISTS (
		SELECT contactid
		FROM CE.tblContact_Test_Records TST
		WHERE TST.contactid = rec.[apuk_contactid]
		)
