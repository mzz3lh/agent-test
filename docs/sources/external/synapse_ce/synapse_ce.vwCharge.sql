CREATE   VIEW [synapse_ce].[vwCharge]
AS

SELECT 
	chg.apuk_chargeid
	, chg.apuk_name
 	, chg.createdon
	, chg.createdby
	,usrcreatedby.[fullname] AS [CreatedByName]
	,chg.modifiedon
	,chg.modifiedby
	,usrmodifiedby.[fullname] AS [ModifiedByName]
	,chg.ownerid
	,ownid.[fullname] AS [OwnerIdName]
	, chg.apuk_rulebreachstatus
	,rulbrstatus.[LocalizedLabel] AS apuk_rulebreachstatus_description
	, chg.apuk_ricsrecordid
	, chg.apuk_reheard
	, chg.apuk_regulatedscheme
	, chg.apuk_regardingtype
	,regtype.LocalizedLabel AS apuk_regardingtype_Description
	, chg.overriddencreatedon
	, chg.apuk_reasonfordecision
	, chg.apuk_proposerid
	, chg.owningbusinessunit
	,bunit.[name] AS owningbusinessunit_Name
	, chg.apuk_numberofchargeamendments
	, chg.apuk_liability
	, liability.LocalizedLabel AS apuk_liability_Description
	, chg.apuk_fixedpenaltyreviewstatus
	,fixedpenreviewstatus.LocalizedLabel AS apuk_fixedpenaltyreviewstatus_Description
	, chg.apuk_fixedpenaltyreviewoutcome
	,fixedpenoutcome.LocalizedLabel AS apuk_fixedpenaltyreviewoutcome_Description
	, chg.apuk_fixedpenaltyreview
	, chg.apuk_evidencefordecision
	, chg.apuk_disciplinarymeasuretype
	,dspmeasuretype.LocalizedLabel AS apuk_disciplinarymeasuretype_Description
	, chg.apuk_decision
	,decision.LocalizedLabel AS apuk_decision_Description
	, chg.apuk_dateproposed
	, chg.apuk_dateagreed
	, chg.apuk_cpdbreachnumber
	, chg.apuk_cpdannualsummaryid
	, chg.apuk_conductpaneloutcome
	,cndpnloutcome.LocalizedLabel AS apuk_conductpaneloutcome_Description
	, chg.apuk_conductcaseid
	,cnd.[apuk_name] AS apuk_conductcaseidName
	, chg.apuk_chargestatus
	,chargestatus.LocalizedLabel AS apuk_chargestatus_Description
	, chg.apuk_chargeresponse
	,chgresponse.LocalizedLabel AS apuk_chargeresponse_Description
	, chg.apuk_chargepartyfirmid  --Account
	, chg.apuk_chargepartyid  --Contact
	, chg.apuk_chargeidnumber
	, chg.apuk_chargedetails
	, chg.apuk_appealedon
	, chg.apuk_appealedby
	, chg.apuk_appealed
	, chg.apuk_appealstatus
	,appstatus.LocalizedLabel AS apuk_appealstatus_Description
	, chg.apuk_appealoutcome
	,appoutcome.LocalizedLabel AS apuk_appealoutcome_Description
	, chg.statuscode
	,stStateCode.[LocalizedLabel] AS [StateCode_Description]
	, chg.statecode
	,stStatusCode.[LocalizedLabel] AS [StatusCode_Description]
FROM synapse_ce.apuk_charge chg
	LEFT JOIN synapse_ce.apuk_caseconduct cnd
		ON chg.[apuk_conductcaseid] = cnd.[apuk_caseconductid]
	LEFT JOIN synapse_ce.systemuser usrcreatedby
		ON chg.[createdby] = usrcreatedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser usrmodifiedby
		ON chg.[modifiedby] = usrmodifiedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser ownid
		ON chg.[ownerid] = ownid.[systemuserid]
	LEFT JOIN synapse_ce.StateMetadata stStateCode
		ON chg.[statecode] = stStateCode.[State]
			AND stStateCode.[EntityName] = 'apuk_charge'
	LEFT JOIN synapse_ce.StatusMetadata stStatusCode
		ON chg.[statuscode] = stStatusCode.[Status]
			AND stStatusCode.[EntityName] = 'apuk_charge'
	LEFT JOIN synapse_ce.businessunit bunit
		ON chg.[owningbusinessunit] = bunit.[businessunitid]
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata rulbrstatus
		ON chg.[apuk_rulebreachstatus] = rulbrstatus.[Option]
		AND rulbrstatus.[OptionSetName] = 'apuk_rulebreachstatus'
		AND rulbrstatus.[EntityName] = 'apuk_charge'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata regtype
		ON chg.[apuk_regardingtype] = regtype.[Option]
		AND regtype.[OptionSetName] = 'apuk_rulebreachstatus'
		AND regtype.[EntityName] = 'apuk_charge'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata fixedpenreviewstatus
		ON chg.[apuk_fixedpenaltyreviewstatus] = fixedpenreviewstatus.[Option]
		AND fixedpenreviewstatus.[OptionSetName] = 'apuk_fixedpenaltyreviewstatus'
		AND fixedpenreviewstatus.[EntityName] = 'apuk_charge'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata fixedpenoutcome
		ON chg.[apuk_fixedpenaltyreviewoutcome] = fixedpenoutcome.[Option]
		AND fixedpenoutcome.[OptionSetName] = 'apuk_fixedpenaltyreviewoutcome'
		AND fixedpenoutcome.[EntityName] = 'apuk_charge'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata dspmeasuretype
		ON chg.[apuk_disciplinarymeasuretype] = dspmeasuretype.[Option]
		AND dspmeasuretype.[OptionSetName] = 'apuk_disciplinarymeasuretype'
		AND dspmeasuretype.[EntityName] = 'apuk_charge'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata liability
		ON chg.[apuk_liability] = liability.[Option]
		AND liability.[OptionSetName] = 'apuk_liability'
		AND liability.[EntityName] = 'apuk_charge'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata decision
		ON chg.[apuk_decision] = decision.[Option]
		AND decision.[OptionSetName] = 'apuk_decision'
		AND decision.[EntityName] = 'apuk_charge'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata chargestatus
		ON chg.[apuk_chargestatus] = chargestatus.[Option]
		AND chargestatus.[OptionSetName] = 'apuk_chargestatus'
		AND chargestatus.[EntityName] = 'apuk_charge'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata cndpnloutcome
		ON chg.[apuk_conductpaneloutcome] = cndpnloutcome.[Option]
		AND cndpnloutcome.[OptionSetName] = 'apuk_conductpaneloutcome'
		AND cndpnloutcome.[EntityName] = 'apuk_charge'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata chgresponse
		ON chg.[apuk_chargeresponse] = chgresponse.[Option]
		AND chgresponse.[OptionSetName] = 'apuk_chargeresponse'
		AND chgresponse.[EntityName] = 'apuk_charge'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata appstatus
		ON chg.[apuk_appealstatus] = appstatus.[Option]
		AND appstatus.[OptionSetName] = 'apuk_appealstatus'
		AND appstatus.[EntityName] = 'apuk_charge'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata appoutcome
		ON chg.[apuk_appealoutcome] = appoutcome.[Option]
		AND appoutcome.[OptionSetName] = 'apuk_appealoutcome'
		AND appoutcome.[EntityName] = 'apuk_charge'
	WHERE NOT EXISTS (
		SELECT contactid
		FROM CE.tblContact_Test_Records TST
		WHERE TST.contactid = chg.apuk_chargepartyid
		)
