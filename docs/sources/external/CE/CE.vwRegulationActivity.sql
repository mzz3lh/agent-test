CREATE   VIEW [CE].[vwRegulationActivity]
AS
SELECT 
	act.[activityid],
	act.[createdon],
	act.[createdby],
	usrCreatedBy.[FullName] AS [createdbyName],
	act.[modifiedon],
	act.[modifiedby],
	usrModifiedBy.[FullName] AS [modifiedbyName],
	act.[ownerid],
	ownid.[FullName] AS [owneridName],
	act.[createdonbehalfby],
	usrCreatedOnBehalfBy.[FullName] AS [createdonbehalfbyName],
	act.[modifiedonbehalfby],
	usrModifiedOnBehalfBy.[FullName] AS [modifiedonbehalfbyName],
	act.[apuk_claimanttype],
	claimanttype.[LocalizedLabel] AS [apuk_claimanttype_description],
	act.[apuk_timeclaimtype],
	timeclaimtype.[LocalizedLabel] AS [apuk_timeclaimtype_description],
	act.[prioritycode],
	prioritycode.[LocalizedLabel] AS [prioritycode_description],
	act.[instancetypecode],
	instancetypecode.[LocalizedLabel] AS [instancetypecode_description],
	act.[deliveryprioritycode],
	delprioritycode.[LocalizedLabel] AS [deliveryprioritycode_description],
	act.[apuk_complaintreportsensitive],
	act.[isbilled],
	act.[apuk_typeofcost],
	typeofcost.[LocalizedLabel] AS [apuk_typeofcost_description],
	act.[leftvoicemail],
	act.[ismapiprivate],
	act.[isregularactivity],
	act.[apuk_complaintreportrelevant],
	act.[apuk_complaintreportid],
	act.[sendermailboxid],
	act.[slaid],
	act.[slainvokedid],
	act.[serviceid],
	act.[customers],
	act.[partners],
	act.[resources],
	act.[from],
	act.[bcc],
	act.[to],
	act.[cc],
	act.[requiredattendees],
	act.[optionalattendees],
	act.[organizer],
	act.[regardingobjectid],
	regobject.[apuk_name] AS [regardingobjectidName],
	act.[apuk_regulatoryroleid],
	act.[apuk_regulatoryroleidName],
	act.[transactioncurrencyid],
	act.[owningteam],
	act.[owningbusinessunit],
	bunit.[name] AS [owningbusinessunitName],
	act.[scheduledstart],
	act.[scheduledend],
	act.[apuk_reasonforcreation],
	act.[activitytypecode],
	act.[onholdtime],
	act.[lastonholdtime],
	act.[apuk_activitiesfortheowner],
	act.[description],
	act.[actualstart],
	act.[actualend],
	act.[actualdurationminutes],
	act.[subject],
	act.[apuk_startdateofclaim],
	act.[apuk_totaltimecost],
	act.[apuk_totaltimecost_base],
	act.[seriesid],
	act.[traversedpath],
	act.[exchangerate],
	act.[exchangeitemid],
	act.[statecode],
	stStateCode.[LocalizedLabel] AS [statecode_description],
	act.[statuscode],
	stStatusCode.[LocalizedLabel] AS [statuscode_description],
	act.[apuk_noofunits]
FROM synapse_ce.vwRegulationActivity act
	LEFT JOIN synapse_ce.SystemUser usrCreatedBy
		ON act.[createdby] = usrCreatedBy.[SystemUserId]
	LEFT JOIN synapse_ce.SystemUser usrModifiedBy
		ON act.[modifiedby] = usrModifiedBy.[SystemUserId]
	LEFT JOIN synapse_ce.SystemUser ownid
		ON act.[ownerid] = ownid.[SystemUserId]
	LEFT JOIN synapse_ce.SystemUser usrCreatedOnBehalfBy
		ON act.[createdonbehalfby] = usrCreatedOnBehalfBy.[SystemUserId]
	LEFT JOIN synapse_ce.SystemUser usrModifiedOnBehalfBy
		ON act.[modifiedonbehalfby] = usrModifiedOnBehalfBy.[SystemUserId]
	LEFT JOIN synapse_ce.businessunit bunit
		ON act.[owningbusinessunit] = bunit.[businessunitid]
	LEFT JOIN synapse_ce.StateMetadata stStateCode
		ON act.[statecode] = stStateCode.[State]
		AND stStateCode.[EntityName] = 'apuk_regulationactivity'
	LEFT JOIN synapse_ce.StatusMetadata stStatusCode
		ON act.[statuscode] = stStatusCode.[Status]
		AND stStatusCode.[EntityName] = 'apuk_regulationactivity'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata claimanttype
		ON act.[apuk_claimanttype] = claimanttype.[Option]
		AND claimanttype.[OptionSetName] = 'apuk_claimanttype'
		AND claimanttype.[EntityName] = 'apuk_regulationactivity'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata timeclaimtype
		ON act.[apuk_timeclaimtype] = timeclaimtype.[Option]
		AND timeclaimtype.[OptionSetName] = 'apuk_timeclaimtype'
		AND timeclaimtype.[EntityName] = 'apuk_regulationactivity'
	LEFT JOIN synapse_ce.OptionSetMetadata prioritycode
		ON act.[prioritycode] = prioritycode.[Option]
		AND prioritycode.[OptionSetName] = 'prioritycode'
		AND prioritycode.[EntityName] = 'apuk_regulationactivity'
	LEFT JOIN synapse_ce.OptionSetMetadata instancetypecode
		ON act.[instancetypecode] = instancetypecode.[Option]
		AND instancetypecode.[OptionSetName] = 'instancetypecode'
		AND instancetypecode.[EntityName] = 'apuk_regulationactivity'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata delprioritycode
		ON act.[deliveryprioritycode] = delprioritycode.[Option]
		AND delprioritycode.[OptionSetName] = 'deliveryprioritycode'
		AND delprioritycode.[EntityName] = 'apuk_regulationactivity'
	LEFT JOIN synapse_ce.OptionSetMetadata typeofcost
		ON act.[apuk_typeofcost] = typeofcost.[Option]
		AND typeofcost.[OptionSetName] = 'apuk_typeofcost'
		AND typeofcost.[EntityName] = 'apuk_regulationactivity'
	LEFT JOIN synapse_ce.vwCasecompliance regobject
		ON act.[regardingobjectid] = regobject.[apuk_casecomplianceid]
