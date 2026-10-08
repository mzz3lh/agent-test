CREATE   VIEW [synapse_ce].[vwRics_NamedAccount]
AS
SELECT 
	ca.[apuk_commercialaccountid] AS Rics_namedaccountId,
	ca.[createdby] AS [CreatedBy],
	usrcreatedby.[fullname] AS [CreatedByName],
	ca.[createdon] AS [Created_On],
	ca.[modifiedby] AS [ModifiedBy],
	usrmodifiedby.[fullname] AS [ModifiedByName],
	ca.[modifiedon] AS [Modified_On],
	ca.[ownerid] AS [OwnerId],
	ownid.[fullname] AS [OwnerIdName],
	ca.[owneridtype] AS [OwnerIdType],
	ca.[owningbusinessunit] AS [OwningBusinessUnit],
	ca.[apuk_associates] AS [Rics_Assessors],
	--Rics_Employees,
	ca.[apuk_accountstatus] AS [Rics_Grading],
	accstatus.[LocalizedLabel] AS [Rics_Grading_Description],
	ca.[apuk_professionals] AS [Rics_Members],
	ca.[apuk_name] AS [Rics_name],
	--Rics_NoofOffices,
	--Rics_number,
	--Rics_RegisteredforTraining,
	--Rics_Segment,
	--Rics_Trainees,
	ca.[apuk_nogrowth] AS [ricsv1_NoGrowth],
	ca.[apuk_sector] AS [ricsv1_Sector],
	sector.[LocalizedLabel] AS [ricsv1_Sector_Description],
	--ricsv2_APCGrowthPotential,
	--ricsv2_AssocGrowthPotential,
	ca.[apuk_bciscost1] AS [ricsv2_BCISCost],
	ca.[apuk_bcispackage1] AS [ricsv2_BCISPackage],
	ca.[apuk_bcisrenewal1] AS [ricsv2_BCISRenewal],
	ca.[apuk_clientknowledge] AS [ricsv2_ClientKnowledge],
	ca.[apuk_cohortpotential] AS [ricsv2_CohortPotential],
	ca.[apuk_cpdfcost1] AS [ricsv2_CPDFcost],
	ca.[apuk_cpdfpackage1] AS [ricsv2_CPDFPackage],
	ca.[apuk_cpdfrenewal1] AS [ricsv2_CPDFRenewal],
	--ricsv2_CPS,
	ca.[apuk_engagementfrequency] AS [ricsv2_EngagementFrequency],
	engfreq.[LocalizedLabel] AS [ricsv2_EngagementFrequency_Description],
	ca.[apuk_execengagement] AS [ricsv2_ExecEngagement],
	--ricsv2_FRICSGrowthPotential,
	ca.[apuk_isurvcost1] AS [ricsv2_isurvCost],
	ca.[apuk_isurvpackage1] AS  [ricsv2_isurvPackage],
	ca.[apuk_isurvrenewal1] AS [ricsv2_isurvRenewal],
	ca.[apuk_major] AS [ricsv2_Major],
	major.[LocalizedLabel] AS [ricsv2_Major_Description],
	ca.[apuk_ricsnextactionduedate] AS [ricsv2_NextActionDueDate],
	ca.[apuk_organisationtype] AS [ricsv2_OrganisationType],
	orgtype.[LocalizedLabel] AS [ricsv2_OrganisationType_Description],
	ca.[apuk_primarycontactid] AS [ricsv2_PrimaryContactId],
	--ricsv2_PrimaryContactIdName,
	ca.[apuk_regionid] AS [ricsv2_RegionId],
	region.[name] AS [ricsv2_RegionIdName],
	ca.[apuk_relationshipstatus] AS [ricsv2_RelationshipStatus],
	relstatus.[LocalizedLabel] AS	[ricsv2_RelationshipStatus_Descripiton],
	ca.[apuk_revenuevtarget] AS [ricsv2_RevenueagainstTarget],
	ca.[apuk_rewardbalance] AS [ricsv2_RewardBalance],
	ca.[apuk_rewardexpiration] AS [ricsv2_RewardExpiration],
	ca.[apuk_ricsfocus] AS [ricsv2_RICSFocus],
	focus.[LocalizedLabel] AS [ricsv2_RICSFocus_Description],
	ca.[apuk_riskoflosingrelationship] AS [ricsv2_RiskofLosingRelationship],
	-- ricsv2_SPAGrowthPotential,
	ca.statecode,
	stStateCode.[LocalizedLabel] AS [StateCode_Description],
	ca.statuscode,
	stStatusCode.[LocalizedLabel] AS [StatusCode_Description],
	ca.[apuk_currencyid] [TransactionCurrencyId],
	cur.[currencyname] AS [TransactionCurrencyIdName],
	ca.OwningUser,
	ca.[apuk_client12monthroadmap] AS [Twelve_Month_Road_Map],
	ca.[apuk_addressablemarketsize] AS [Addressable_Market_Size],
	ca.[apuk_clientburningissues] AS [Client_Burning_Issue],
	ca.[apuk_frequencyofcontact] AS [Frequency_Of_Contact],
	ca.[apuk_managementengagement] AS [Management_Engagement],
	ca.[modifiedonbehalfby] AS [ModifiedOnBehalfBy],
	usrmodonbehalf.[fullname] AS [ModifiedBy_Delegate],
	ca.[apuk_opportunitydiscovery] AS [Opportunity_Discovery],
	ca.[overriddencreatedon] AS [Record_CreatedOn],
	ca.[apuk_rewardvalue] AS [Reward_Value],
	ca.[apuk_standardadoption] AS [Standards_Adoption]
FROM synapse_ce.apuk_commercialaccount ca
	LEFT JOIN synapse_ce.systemuser usrcreatedby
		ON ca.[createdby] = usrcreatedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser usrmodifiedby
		ON ca.[modifiedby] = usrmodifiedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser ownid
		ON ca.[ownerid] = ownid.[systemuserid]
	LEFT JOIN synapse_ce.systemuser usrmodonbehalf
		ON ca.[modifiedonbehalfby] = usrmodonbehalf.[systemuserid]
	LEFT JOIN synapse_ce.StateMetadata stStateCode
		ON ca.[statecode] = stStateCode.[State]
			AND stStateCode.[EntityName] = 'apuk_commercialaccount'
	LEFT JOIN synapse_ce.StatusMetadata stStatusCode
		ON ca.[statuscode] = stStatusCode.[Status]
			AND stStatusCode.[EntityName] = 'apuk_commercialaccount'
	LEFT JOIN synapse_ce.transactioncurrency cur
		ON ca.[apuk_currencyid] = cur.[transactioncurrencyid]
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata accstatus
		ON ca.[apuk_accountstatus] = accstatus.[Option]
			AND accstatus.[OptionSetName] = 'apuk_accountstatus'
			AND accstatus.[EntityName] = 'apuk_commercialaccount'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata sector
		ON ca.[apuk_sector] = sector.[Option]
			AND sector.[OptionSetName] = 'apuk_sector'
			AND sector.[EntityName] = 'apuk_commercialaccount'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata engfreq
		ON ca.[apuk_engagementfrequency] = engfreq.[Option]
			AND engfreq.[OptionSetName] = 'apuk_engagementfrequency'
	LEFT JOIN synapse_ce.OptionSetMetadata major
		ON ca.[apuk_major] = major.[Option]
			AND major.[OptionSetName] = 'apuk_major'
			AND major.[EntityName] = 'apuk_commercialaccount'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata orgtype
		ON ca.[apuk_organisationtype] = orgtype.[Option]
			AND orgtype.[OptionSetName] = 'apuk_organisationtype'
			AND orgtype.[EntityName] = 'apuk_commercialaccount'
	LEFT JOIN synapse_ce.territory region
		ON ca.[apuk_regionid] = region.[territoryid]
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata relstatus
		ON ca.[apuk_relationshipstatus] = relstatus.[Option]
			AND relstatus.[OptionSetName] = 'apuk_relationshipstatus'
			AND relstatus.[EntityName] = 'apuk_commercialaccount'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata focus
		ON ca.[apuk_ricsfocus] = focus.[Option]
			AND focus.[OptionSetName] = 'apuk_ricsfocus'
			AND focus.[EntityName] = 'apuk_commercialaccount'
	WHERE NOT EXISTS (
		SELECT contactid
		FROM CE.tblContact_Test_Records TST
		WHERE TST.contactid = ca.[apuk_primarycontactid]
		)
--WHERE apuk_commercialaccountid = '00000000-0000-0000-0000-000000000000'GO
