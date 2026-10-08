CREATE   VIEW [synapse_ce].[vwCasedrs]
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
	drs.statecode, 
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
	drs.apuk_qbrepresentative, --contact
	drs.apuk_propertydescription, 
	drs.apuk_propertybuildingname, 
	drs.apuk_presidentagentsoutcome, 
	drs.apuk_placedonholddate, 
	drs.apuk_party4tenantsrepid, --contact
	drs.apuk_party4referringpartyrepid, --contact
	drs.apuk_party3respondingpartyrepid, --contact 
	drs.apuk_party3landlordsrepid, --contact 
	drs.apuk_party2tenant, --account 
	drs.apuk_party2respondingparty, --account
	drs.apuk_party1referringparty, --account
	drs.apuk_party1landlord, --account
	drs.owningbusinessunit, --businessunit
	drs.ownerid, --systemuser
	drs.apuk_outcomedelayreason, 
	drs.apuk_otheroutcome, 
	drs.apuk_originaltenant, 
	drs.apuk_originallandlord, 
	drs.rics_onbehalfoforganisation, --account
	drs.apuk_nonpanelmemberselection, 
	drs.apuk_nonpanelmemberreason, 
	drs.apuk_neighbourhoodplanname, 
	drs.apuk_natureofdispute, 
	drs.modifiedon, 
	drs.modifiedonbehalfby, --systemuser
	drs.modifiedby, --systemuser
	drs.apuk_membernotifieddate, 
	drs.apuk_memberapprovedrejectedon, 
	drs.apuk_memberapprovedrejectedby, --systemuser
	drs.apuk_memberapprovalrejectiondetails, 
	drs.apuk_lparepresentative, --contact
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
	drstype.apuk_name AS rics_drstype_description,
	drs.rics_drspanelmember, --contact
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
	drs.rics_city, 
	drs.apuk_caseoutcome, 
	drs.apuk_applicationorigin, 
	drs.apuk_casehistoryreceived, 
	drs.apuk_caseclosuredate, 
	drs.apuk_capacityrequired, 
	drs.apuk_billtoapplicant, --contact
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
	drs.apuk_1stapplicationextensionenddate
FROM synapse_ce.apuk_casedrs drs
	LEFT JOIN synapse_ce.apuk_drstype drstype
		ON drs.rics_drstype = drstype.apuk_drstypeid
	WHERE NOT EXISTS (
		SELECT contactid
		FROM CE.tblContact_Test_Records TST
		WHERE TST.contactid = drs.apuk_qbrepresentative
		OR TST.contactid = drs.apuk_party4tenantsrepid
		OR TST.contactid = drs.apuk_party4referringpartyrepid
		OR TST.contactid = drs.apuk_party3respondingpartyrepid
		OR TST.contactid = drs.apuk_party3landlordsrepid
		OR TST.contactid = drs.apuk_lparepresentative
		OR TST.contactid = drs.rics_drspanelmember
		OR TST.contactid = drs.apuk_billtoapplicant
		OR TST.contactid = drs.apuk_applicantcontactnumber
		OR TST.contactid = drs.apuk_existingcontactid
		)
