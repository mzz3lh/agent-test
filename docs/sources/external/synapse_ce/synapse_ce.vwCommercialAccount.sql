CREATE   VIEW [synapse_ce].[vwCommercialAccount]
AS
SELECT
	acc.[apuk_commercialaccountid] AS [Commercial_Account_Key],
	acc.[apuk_name] AS [RICS_Name],
	acc.[apuk_regionid] AS [Region],
	ter.[name] AS [RegionId_Name],
	--acc.[Is_Regulated],
	ownid.[fullname] AS [OwnerId],
	acc.[apuk_accountstatus] AS [RICS_Account_Status],
	acc.[apuk_relationshipstatus] AS [Relationship_Status],
	acc.[modifiedon] AS [Modified_On],
	acc.[apuk_client12monthroadmap] AS [Twelve_Month_Road_Map],
	acc.[apuk_addressablemarketsize] AS [Addressable_Market_Size],
	--acc.[APC_Growth_Potential],
	--acc.[Associate_Growth_Potential],
	acc.[apuk_associates] AS [Associates],
	acc.[apuk_bciscost1] AS [BCIS_Cost],
	--acc.[bcis] AS [BCIS_Cost_Base],
	acc.[apuk_bcispackage1] AS [BCIS_Package],
	acc.[apuk_bcisrenewal1] AS [BCIS_Renewal_Date],
	acc.[apuk_candidates] AS [Candidates],
	--acc.[Client_Burning_Issue],
	acc.[apuk_clientknowledge] AS [Client_Knowledge],
	acc.[apuk_cohortpotential] AS [Cohort_Potential],
	--acc.[Commercial_Account_Number],
	acc.[apuk_cpdfcost1] AS [CPDF_Cost],
	--acc.[CPDF_Cost_Base],
	acc.[apuk_cpdfpackage1] AS [CPDF_Package],
	acc.[apuk_cpdfrenewal1] AS [CPDF_Renewal_Date],
	--acc.[CPS],
	usrcreatedby.[fullname] AS [CreatedBy],
	acc.[createdon] AS [Created_On],
	cur.[currencyname] AS [Currency],
	acc.[apuk_professionals] AS [Property_Professionals],
	--acc.[Registered_For_Training],
	--acc.[Employees],
	acc.[apuk_engagementfrequency] AS [Engagement_Frequency],
	--acc.[Exchange_Rate],
	acc.[apuk_execengagement] AS [Exec_Engagement],
	acc.[apuk_frequencyofcontact] AS [Frequency_Of_Contact],
	--acc.[FRICS_Growth_Potential],
	--acc.[Geographical_Focus],
	acc.[apuk_isurvcost1] AS [ISURV_Cost],
	--acc.[ISURV_Cost_Base],
	acc.[apuk_isurvpackage1] AS [ISURV_Package],
	acc.[apuk_isurvrenewal1] AS [ISURV_Renewal_Date],
	acc.[apuk_major] AS [Major],
	acc.[apuk_managementengagement] AS [Management_Engagement],
	acc.[apuk_professionals] AS [Members],
	usrmodifiedby.[fullname] AS [ModifiedBy],
	acc.[modifiedonbehalfby] AS [ModifiedBy_Delegate],
	acc.[apuk_ricsnextactionduedate] AS [Next_Action_Due_Date],
	acc.[apuk_nogrowth] AS [No_Growth],
	--acc.[No_Of_Offices],
	acc.[apuk_opportunitydiscovery] AS [Opportunity_Discovery],
	acc.[apuk_organisationtype] AS [Organisation_Type],
	orgtype.[LocalizedLabel] AS [Organisation_Type_Description],
	acc.[apuk_primarycontactid] AS [Primary_Contact],
	pcnt.[fullname] AS [PrimaryContact_Name],
	acc.[overriddencreatedon] AS [Record_Created_On],
	acc.[apuk_revenuevtarget] AS [Revenue_Against_Target],
	acc.[apuk_rewardbalance] AS [Reward_Balance],
	--acc.[Reward_Balance_Base],
	acc.[apuk_rewardexpiration] AS [Reward_Expiration_Date],
	acc.[apuk_rewardvalue] AS [Reward_Value],
	--acc.[Reward_Value_Base],
	acc.[apuk_ricsfocus] AS [RICS_Focus],
	--acc.[Main_Area_Of_Business],
	acc.[apuk_riskoflosingrelationship] AS [Risk_Of_Losing_Relationship],
	acc.[apuk_sector] AS [Sector],
	--acc.[Segment],
	--acc.[SPA_Growth_Actual],
	--acc.[SPA_Growth_Potential],
	acc.[apuk_standardadoption] AS [Standards_Adoption],
	acc.StateCode,
	stStateCode.[LocalizedLabel] AS [State_Description],
	acc.StatusCode,
	stStatusCode.[LocalizedLabel] AS [Status_Description],
	acc.apuk_regionalaccountownerid AS RegionalAccountOwnerId,
	-1 AS [SalesTeamId]--,
	--acc.[RICS_Volunteers]
FROM synapse_ce.apuk_commercialaccount acc
	LEFT JOIN synapse_ce.territory ter
		ON acc.[apuk_regionid] = ter.[territoryid]
	LEFT JOIN synapse_ce.transactioncurrency cur
		ON acc.[apuk_currencyid] = cur.[transactioncurrencyid]
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata orgtype
		ON acc.[apuk_organisationtype] = orgtype.[Option]
			AND orgtype.[OptionSetName] = 'apuk_organisationtype'
			AND orgtype.[EntityName] = 'apuk_commercialaccount'
	LEFT JOIN synapse_ce.contact pcnt
		ON acc.[apuk_primarycontactid] = pcnt.[contactid]
	LEFT JOIN synapse_ce.systemuser usrcreatedby
		ON acc.[createdby] = usrcreatedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser usrmodifiedby
		ON acc.[modifiedby] = usrmodifiedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser ownid
		ON acc.[ownerid] = ownid.[systemuserid]
	LEFT JOIN synapse_ce.StateMetadata stStateCode
		ON acc.[statecode] = stStateCode.[State]
			AND stStateCode.[EntityName] = 'apuk_commercialaccount'
	LEFT JOIN synapse_ce.StatusMetadata stStatusCode
		ON acc.[statuscode] = stStatusCode.[Status]
			AND stStatusCode.[EntityName] = 'apuk_commercialaccount'
	WHERE NOT EXISTS (
		SELECT contactid
		FROM CE.tblContact_Test_Records TST
		WHERE TST.contactid = acc.[apuk_primarycontactid]
		)
