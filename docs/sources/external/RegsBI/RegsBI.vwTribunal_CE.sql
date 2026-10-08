CREATE   VIEW [RegsBI].[vwTribunal_CE]
AS
SELECT
	tr.[apuk_tribunalid],
	tr.[apuk_name],
	tr.[createdon],
	tr.[createdby],
	tr.[CreatedByName],
	tr.[modifiedon],
	tr.[modifiedby],
	tr.[ModifiedByName],
	tr.[ownerid],
	tr.[OwnerIdName],
	tr.[apuk_witness],
	tr.[apuk_websitepublicationrequired],
	tr.[apuk_venue],
	tr.[apuk_venue_description],
	tr.[apuk_tribunaltype],
	tr.[apuk_tribunaltype_description],
	tr.[apuk_tribunalpreviouslyadjourned],
	tr.[apuk_tribunalmethod],
	tr.[apuk_tribunalmethod_description],
	tr.[apuk_tribunalmemberid],
	tr.[apuk_tribunalidnumber],
	tr.[apuk_tribunalchairid],
	tr.[apuk_translatordetails],
	tr.[apuk_totalcostsandfinesagainstrics_base],
	tr.[apuk_totalcostsandfinesagainstrics],
	tr.[apuk_totalcostsandfinesagainstregardingparty_base],
	tr.[apuk_totalcostsandfinesagainstregardingparty],
	tr.[apuk_totalcosts_base],
	tr.[apuk_totalamountoffines_base],
	tr.[apuk_synopsispublishedon],
	tr.[statuscode],
	tr.[StateCode_Description],
	tr.[statecode],
	tr.[StatusCode_Description],
	tr.[apuk_startdate],
	tr.[apuk_solicitornotified],
	tr.[apuk_slakpiinstanceid],
	tr.[slaid],
	tr.[apuk_singledecisionmakerid],
	tr.[apuk_sdmdecision],
	optsdmdecision.[LocalizedLabel] AS [apuk_sdmdecision_description],
	tr.[apuk_ricsinvestigatorid],
	tr.[apuk_rehearingrequested],
	tr.[apuk_regulatorytribunalexecutiveid],
	tr.[apuk_registrationpaneloutcome],
	tr.[apuk_registrationdecision],
	optregistrationdecision.[LocalizedLabel] AS [apuk_registrationdecision_description],
	tr.[apuk_regardingtype],
	tr.[apuk_regardingtype_description],
	tr.[apuk_regardingpartyrepresentative],
	tr.[apuk_regardingpartyid],
	tr.[apuk_regardingpartyid_description],
	tr.[apuk_regardingfirmid],
	tr.[apuk_referredtohonorarysecretary],
	tr.[overriddencreatedon],
	tr.[apuk_publicationrequestedon],
	tr.[apuk_investigationcaseid],
	tr.[apuk_solicitorid],
	tr.[apuk_partheard],
	tr.[apuk_parenttribunalid],
	tr.[apuk_panelid],
	tr.[owningbusinessunit],
	tr.[owningbusinessunitName],
	tr.[apuk_overserved],
	tr.[apuk_outsideofappealperiod],
	tr.[apuk_outcomecommunicatedon],
	tr.[apuk_observersfororalhearings],
	tr.[apuk_numberoftribunaldays],
	tr.[apuk_numberofobservers],
	tr.[apuk_noticeofservicesenton],
	tr.[apuk_moduspublicationrequired],
	tr.[apuk_legalassessorid],
	tr.[apuk_laymemberid],
	tr.[lastonholdtime],
	tr.[apuk_interimmeasuresdecision],
	optinterimmeasuresdecision.LocalizedLabel AS [apuk_interimmeasuresdecision_description],
	tr.[apuk_imposedfinesagainstrics_base],
	tr.[apuk_imposedfinesagainstrics],
	tr.[apuk_imposedfinesagainstregardingparty_base],
	tr.[apuk_imposedfinesagainstregardingparty],
	tr.[apuk_honorarysecretaryagreetoappeal],
	tr.[apuk_highprofile],
	tr.[apuk_fulldecisionreached],
	tr.[apuk_fproutcome],
	optfproutcome.localizedlabel AS [apuk_fproutcome_description],
	tr.[apuk_forthcomingnoticeurl],
	tr.[apuk_fixedpenaltyreviewer],
	tr.[apuk_finaldecisionreceivedon],
	tr.[apuk_finalbundleuploadedon],
	tr.[apuk_finalbundleuploaded],
	tr.[apuk_expertid],
	tr.[apuk_enddate],
	tr.[apuk_disciplinarydecision],
	optdisciplinarydecision.[localizedlabel] AS apuk_disciplinarydecision_description,
	tr.[apuk_decisionpublishedon],
	tr.[apuk_costsclaimed_base],
	tr.[apuk_costsawardedtorics_base],
	tr.[apuk_costsawardedagainstrics_base],
	tr.[apuk_convictionhearing],
	tr.[apuk_regulatorycontactid],
	tr.[apuk_conductcaseid],
	tr.[apuk_conductcaseidName],
	tr.[apuk_cmcrequired],
	tr.[apuk_claimedcostsagainstrics_base],
	tr.[apuk_claimedcostsagainstrics],
	tr.[apuk_costsclaimed],
	tr.[apuk_casegroupreference],
	tr.[apuk_bundleservedon],
	tr.[apuk_bundleserved],
	tr.[apuk_costsawardedagainstrics],
	tr.[apuk_costsawardedtorics],
	tr.[apuk_assignedsdmdate],
	tr.[apuk_appealed],
	tr.[apuk_appealperiodexpirydate],
	tr.[apuk_publicationdate],
	tr.[apuk_appealoutoftime],
	tr.[apuk_appealformrecdate],
	tr.[apuk_appealdecision],
	optappealdecision.[localizedlabel] AS apuk_appealdecision_description,
	tr.[apuk_appealconsideredbypresidingchair],
	tr.[apuk_approvedbyresidingchair],
	tr.[apuk_adjournmentrequestedby],
	tr.[apuk_adjournmentreason],
	optadjournmentreason.[localizedlabel] AS apuk_adjournmentreason_description,
	tr.[apuk_adjournmentstatus],
	optadjournmentstatus.[localizedlabel] AS apuk_adjournmentstatus_description
FROM [synapse_ce].[vwTribunal] tr
	LEFT JOIN synapse_ce.OptionSetMetadata optsdmdecision
		ON tr.apuk_sdmdecision = optsdmdecision.[Option]
		AND optsdmdecision.[OptionSetName] = 'apuk_sdmdecision'
		AND optsdmdecision.[EntityName] = 'apuk_tribunal'
	LEFT JOIN synapse_ce.OptionSetMetadata optregistrationdecision
		ON tr.apuk_registrationdecision = optregistrationdecision.[Option]
		AND optregistrationdecision.[OptionSetName] = 'apuk_registrationdecision'
		AND optregistrationdecision.[EntityName] = 'apuk_tribunal'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata optinterimmeasuresdecision
		ON tr.apuk_interimmeasuresdecision = optinterimmeasuresdecision.[Option]
		AND optinterimmeasuresdecision.[OptionSetName] = 'apuk_interimmeasuresdecision'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata optfproutcome
		ON tr.apuk_fproutcome = optfproutcome.[Option]
		AND optfproutcome.[OptionSetName] = 'apuk_fproutcome'
	LEFT JOIN synapse_ce.OptionSetMetadata optdisciplinarydecision
		ON tr.apuk_disciplinarydecision = optdisciplinarydecision.[Option]
		AND optdisciplinarydecision.[OptionSetName] = 'apuk_disciplinarydecision'
		AND optdisciplinarydecision.[EntityName] = 'apuk_tribunal'

	LEFT JOIN synapse_ce.OptionSetMetadata optappealdecision
		ON tr.apuk_appealdecision = optappealdecision.[Option]
		AND optappealdecision.[OptionSetName] = 'apuk_appealdecision'
		AND optappealdecision.[EntityName] = 'apuk_tribunal'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata optadjournmentreason
		ON tr.apuk_adjournmentreason = optadjournmentreason.[Option]
		AND optadjournmentreason.[OptionSetName] = 'apuk_adjournmentreason'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata optadjournmentstatus
		ON tr.apuk_adjournmentstatus = optadjournmentstatus.[Option]
		AND optadjournmentstatus.[OptionSetName] = 'apuk_adjournmentstatus'
