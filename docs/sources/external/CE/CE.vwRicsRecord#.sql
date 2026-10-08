CREATE   VIEW [CE].[vwRicsRecord#]
AS
SELECT 
	rec.[apuk_ricsrecordid],
	rec.[apuk_name],
	rec.[createdon],
	rec.[createdby],
	rec.[CreatedByName],
	rec.[modifiedon],
	rec.[modifiedby],
	rec.[ModifiedByName],
	rec.[ownerid],
	ownid.[FullName] AS [OwnerIdName],
	rec.[apuk_membergrade],
	rec.[apuk_membershipstatus],
	rec.[apuk_membershipstatus_description],
	rec.[apuk_designation],
	rec.[apuk_designation_description],
	rec.[apuk_applicanttype],
	--rec.[apuk_applicationtype_description],
	rec.[apuk_applicanttype_description],
	rec.[apuk_lapsecode],
	rec.[apuk_lapsecode_description],
	rec.[apuk_lapseddate],
	rec.[apuk_preventlapse],
	rec.[apuk_assessorauditor],
	rec.[apuk_assessorchairperson],
	rec.[apuk_eminentmember],
	rec.[apuk_pathwayid],
	rec.[Pathway_Code],
	rec.[apuk_pathwayid_name],
	rec.[apuk_applicationtypeid],
	rec.[apuk_applicationtypeid_name],
	rec.[apuk_contactid],
	rec.[apuk_ricsmembershipnumber],
	EL.[Route ID],
	EL.[Route] AS [apuk_routeid_name],
	rec.[apuk_regionid],
	rec.[apuk_regionid_name],
	rec.[apuk_pendingremovaldate],
	rec.[apuk_counsellorstartdate],
	rec.[apuk_firstqualifiedlocalgroup],
	rec.[apuk_datequalified],
	rec.[apuk_counsellortrainingcomplete],
	rec.[apuk_studentenrolmentdate],
	rec.[apuk_billtoid],
	rec.[apuk_billtoidyominame],
	rec.[statecode],
	rec.[statecode_description],
	rec.[statuscode],
	rec.[statuscode_description],
	rec.[apuk_lastrecordedethicalcpd],
	rec.apuk_apprentice
FROM [synapse_ce].[vwRicsRecord] rec
	LEFT JOIN [synapse_ce].[vwSystemUser] ownid
		ON rec.[ownerid] = ownid.[SystemUserId]
	LEFT JOIN CE.vwEnrolments_Valid_Last EL
		ON EL.[Contact ID] = rec.apuk_contactid
	--LEFT JOIN [synapse_ce].[vwRics_Route] rt
		--ON rec.[apuk_routeid] = rt.[Rics_routeId]
--WHERE EL.[Route ID] IS NOT NULL
