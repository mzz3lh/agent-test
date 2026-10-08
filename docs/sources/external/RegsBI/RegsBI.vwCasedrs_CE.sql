CREATE    VIEW [RegsBI].[vwCasedrs_CE]
AS
SELECT 
	drs.apuk_casedrsid, 
	drs.apuk_name, 
	drs.rics_zippostcode, 
	drs.apuk_feecharged, 
	drs.rics_typeofapplication, 
	drs.rics_terminationdate, 
	drs.apuk_tenantparentorsubsidiaryorganisation, 
	drs.rics_street3, 
	drs.rics_street2, 
	drs.rics_street1, 
	drs.statuscode, 
	statuscode.[LocalizedLabel] AS [StatusCode_Description],
	drs.statecode, 
	statecode.[LocalizedLabel] AS [StateCode_Description],
	drs.apuk_specialrequirements, 
	drs.rics_specialprovisions, 
	drs.apuk_showonline, 
	drs.apuk_selectiondate, 
	drs.rics_sectiondetails, 
	drs.rics_agriculturalsection, 
	drs.rics_secondrentreviewdate, 
	drs.apuk_secondleasedate, 
	drs.rics_schemename, 
	drs.apuk_satisfactionsurveyreceiveddate, 
	drs.apuk_satisfactionsurveyreceived, 
	drs.apuk_respondingpartyfirm, 
	drs.rics_rentreviewdate, 
	drs.apuk_rentband, --apuk_drsrentbands

	drs.apuk_releasedfromholddate, 
	drs.apuk_referringpartyorganisation, 
	drs.overriddencreatedon, 
	drs.apuk_reasonedawardgiven, 
	drs.apuk_qualifyingbody, --Account
	accQualBody.[name] AS [apuk_qualifyingbody_Name],
	drs.apuk_qbrepresentative, --contact
	cntQbRep.[FullName] AS [apuk_qbrepresentative_Name],
	drs.apuk_propertydescription, 
	drs.apuk_propertybuildingname, 
	drs.apuk_presidentagentsoutcome, 
	drs.apuk_placedonholddate, 
	drs.apuk_party4tenantsrepid, --contact
	cntP4Tenantrepid.[FullName] AS [apuk_party4tenantsrepid_Name],
	drs.apuk_party4referringpartyrepid, --contact
	cntP4Refpartyid.[FullName] AS [apuk_party4referringpartyrepid_Name],
	drs.apuk_party3respondingpartyrepid, --contact 
	cntP3resppartyrepid.[FullName] AS [apuk_party3respondingpartyrepid_Name],
	drs.apuk_party3landlordsrepid, --contact 
	cntLandlordrepid.[FullName] AS [apuk_party3landlordsrepid_Name], 
	drs.apuk_party2tenant, --account 
	accP2tenant.[name] AS [apuk_party2tenant_Name],
	drs.apuk_party2respondingparty, --account
	accP2respparty.[name] AS [apuk_party2respondingparty_Name],
	drs.apuk_party1referringparty, --account
	accP1refparty.[name] AS [apuk_party1referringparty_Name],
	drs.apuk_party1landlord, --account
	accP1landlord.[name] AS [apuk_party1landlord_Name],
	drs.owningbusinessunit, --businessunit
	ownbunit.[name] AS [owningbusinessunit_Name],
	drs.ownerid, --systemuser
	ownid.[FullName] AS [ownerid_Name],
	drs.apuk_outcomedelayreason, 
	drs.apuk_otheroutcome, 
	drs.apuk_originaltenant, 
	drs.apuk_originallandlord, 
	drs.rics_onbehalfoforganisation, --account
	acconbehalforg.[name] AS [rics_onbehalfoforganisation_Name],
	drs.apuk_nonpanelmemberselection, 
	drs.apuk_nonpanelmemberreason, 
	drs.apuk_neighbourhoodplanname, 
	drs.apuk_natureofdispute, 
	drs.modifiedon, 
	drs.modifiedonbehalfby, --systemuser
	usrmodonbehalf.[FullName] AS [modifiedonbehalfby_Name],
	drs.modifiedby, --systemuser
	usrmodifiedby.[FullName] AS [modifiedby_Name],	
	drs.apuk_membernotifieddate, 
	drs.apuk_memberapprovedrejectedon, 
	drs.apuk_memberapprovedrejectedby, --systemuser
	memapprejby.[FullName] AS [apuk_memberapprovedrejectedby_Name],
	drs.apuk_memberapprovalrejectiondetails, 
	drs.apuk_lparepresentative, --contact
	cntlaprepby.[FullName] AS [apuk_lparepresentative_Name],
	drs.apuk_longitude, 
	drs.apuk_localplanningauthority, 
	drs.apuk_leasedate, 
	drs.apuk_latitude, 
	drs.apuk_landlordparentorsubsidiaryorganisation, 
	drs.apuk_invitationsentdate, 
	drs.apuk_hasfeebeenpaid, 
	drs.apuk_generalobjections, 
	drs.apuk_followupdate, 
	drs.exchangerate, 
	drs.apuk_examinationtype, 
	drs.apuk_estimatedexaminerdays, 
	drs.apuk_earlyclosurereason, 
	drs.rics_drstype, --apuk_drstype
	rics_drstype_description,
	drs.rics_drspanelmember, --contact
	cntpnlmem.[FullName] AS [rics_drspanelmember_Name],
	drs.apuk_drsnotes, 
	drs.rics_drsgroup, --rics_drsgroup

	drs.apuk_drsdivisionid, --apuk_drsdivision

	drs.apuk_caseid, 
	drs.rics_doescontractexist, 
	drs.apuk_disclosure, 
	drs.apuk_directselectionreason, 
	drs.apuk_directselection, 
	drs.apuk_dateofsubmissions, 
	drs.rics_dateofnotice, 
	drs.rics_dateofdemand, 
	drs.apuk_dateofawarddetermination, 
	drs.apuk_dateofappointment, 
	drs.apuk_dateof, 
	drs.apuk_dateexaminerrequired, 
	drs.apuk_dateapplicationreceived, 
	drs.transactioncurrencyid, 
	drs.createdon, 
	drs.createdonbehalfby,--systemuser 
	drs.createdby, --systemuser
	drs.rics_county, 	
	drs.rics_nameofcountry, 
	drs.rics_country,--apuk_country 
	cntry.[apuk_name] AS [rics_country_Name],
	drs.rics_city, 
	drs.apuk_caseoutcome, 
	drs.apuk_applicationorigin, 
	drs.apuk_casehistoryreceived, 
	drs.apuk_caseclosuredate, 
	drs.apuk_capacityrequired, 
	drs.apuk_billtoapplicant, --contact
	cntbilltoappl.[FullName] AS [apuk_billtoapplicant_Name],
	drs.apuk_areaunits, 
	drs.apuk_approximatesize, 
	drs.apuk_approvingauthority, 
	drs.apuk_appointmentrequiredby, 
	drs.apuk_agriapplicationfrom, 
	drs.apuk_applicationdetails, 
	drs.apuk_applicationdate, 
	drs.apuk_applicationid, 

	drs.apuk_applicantname, 
	drs.apuk_applicantemail, 
	drs.apuk_applicantcontactnumber, 
	drs.apuk_existingcontactid, --contact
	cntexistcontact.[FullName] AS [apuk_existingcontactid_Name],
	drs.apuk_abortivework, 
	drs.apuk_amountofpassingrent_base, 
	drs.apuk_amountofpassingrent, 
	drs.rics_agriculturalact, 
	drs.apuk_agreedorallegeddateofrentreview, 
	drs.apuk_adjudicatorrequired, 
	drs.rics_adjudicationtype, 
	drs.apuk_disputepropertyaddress, 
	drs.apuk_addresslookup, 
	drs.apuk_acknowledgementsentdate, 
	drs.apuk_2ndapplicationextensionstartdate, 
	drs.apuk_2ndapplicationextensionenddate, 
	drs.apuk_1stapplicationextensionstartdate, 
	drs.apuk_1stapplicationextensionenddate,
	IIF(q.apuk_casedrs IS NULL, 0, 1) AS [drs_quote_raised_flag]
FROM synapse_ce.vwCasedrs drs
	LEFT JOIN synapse_ce.Account accQualBody
		ON drs.apuk_qualifyingbody = accQualBody.AccountId
	LEFT JOIN synapse_ce.Contact cntQbRep
		ON drs.apuk_qbrepresentative = cntQbRep.[ContactId]
	LEFT JOIN synapse_ce.Contact cntP4Tenantrepid
		ON drs.[apuk_party4tenantsrepid] = cntP4Tenantrepid.[ContactId]
	LEFT JOIN synapse_ce.Contact cntP4Refpartyid
		ON drs.[apuk_party4referringpartyrepid] = cntP4Refpartyid.[ContactId]
	LEFT JOIN synapse_ce.Contact cntP3resppartyrepid
		ON drs.[apuk_party3respondingpartyrepid] = cntP3resppartyrepid.[ContactId]
	LEFT JOIN synapse_ce.Contact cntLandlordrepid
		ON drs.[apuk_party3landlordsrepid] = cntLandlordrepid.[ContactId]
	LEFT JOIN synapse_ce.Account accP2tenant
		ON drs.[apuk_party2tenant] = accP2tenant.[AccountId]
	LEFT JOIN synapse_ce.Account accP2respparty
		ON drs.[apuk_party2respondingparty] = accP2respparty.[AccountId]
	LEFT JOIN synapse_ce.Account accP1refparty 
		ON drs.[apuk_party1referringparty] = accP1refparty.[AccountId]
	LEFT JOIN synapse_ce.Account accP1landlord
		ON drs.[apuk_party1landlord] = accP1landlord.[AccountId]
	LEFT JOIN synapse_ce.businessunit ownbunit
		ON drs.[owningbusinessunit] = ownbunit.[businessunitid]
	LEFT JOIN synapse_ce.SystemUser ownid
		ON drs.[ownerid] = ownid.[SystemUserId]
	LEFT JOIN synapse_ce.Account acconbehalforg
		ON drs.[rics_onbehalfoforganisation] = acconbehalforg.[AccountId]
	LEFT JOIN synapse_ce.SystemUser usrmodonbehalf
		ON drs.[modifiedonbehalfby] = usrmodonbehalf.[SystemUserId]
	LEFT JOIN synapse_ce.SystemUser usrmodifiedby
		ON drs.[modifiedby] = usrmodifiedby.[SystemUserId]
	LEFT JOIN synapse_ce.SystemUser memapprejby
		ON drs.[apuk_memberapprovedrejectedby] = memapprejby.[SystemUserId]
	LEFT JOIN synapse_ce.Contact cntlaprepby
		ON drs.[apuk_lparepresentative] = cntlaprepby.[ContactId]
	LEFT JOIN synapse_ce.Contact cntpnlmem
		ON drs.[rics_drspanelmember] = cntpnlmem.[ContactId]
	LEFT JOIN synapse_ce.vwCountry cntry
		ON drs.[rics_country] = cntry.[apuk_countryid]
	LEFT JOIN synapse_ce.Contact cntbilltoappl
		ON drs.[apuk_billtoapplicant] = cntbilltoappl.[ContactId]
	LEFT JOIN synapse_ce.Contact cntexistcontact
		ON drs.[apuk_existingcontactid] = cntexistcontact.[ContactId]
	LEFT JOIN (SELECT q.apuk_casedrs FROM synapse_ce.quote q WHERE q.apuk_casedrs IS NOT NULL GROUP BY q.apuk_casedrs) q
		ON drs.apuk_casedrsid = q.apuk_casedrs
	LEFT JOIN synapse_ce.StateMetadata statecode
		ON drs.statecode = statecode.[State]
		AND statecode.EntityName = 'apuk_casedrs'
	LEFT JOIN synapse_ce.StatusMetadata statuscode
		ON drs.statuscode = statuscode.[Status]
		AND statuscode.EntityName = 'apuk_casedrs'
