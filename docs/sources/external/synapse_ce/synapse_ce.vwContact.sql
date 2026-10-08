/*
		Modification History
		09/05/2022  Raj Maddala	Added fields
				[address1_longitude],
				[address2_longitude],
				[address3_longitude]
				[apuk_sexualorientation], 
				[apuk_genderidentity], 
				[apuk_religionorbelief], 
				[apuk_ethnicityother], 
				[apuk_disabilities], 



		17/03/2022	srini.akula			Added fields

				cnt.[apuk_addresspreference] AS [Rics_AddressPreference],
				addPref.[LocalizedLabel] AS [Rics_AddressPreference_Description],

				cnt.[apuk_phonepreference] AS [Rics_PhonePreference],
				PhPref.[LocalizedLabel] AS [Rics_PhonePreference_Description],
	   

		07/06/2022	Raj Maddala		Added fields
			cnt.[apuk_preferredaddresscompanyname],
			cnt.[apuk_preferredaddresscountryid]

		29/09/2022	Raj Maddala		Added fields
			cnt.[apuk_twitterurl],
			cnt.[apuk_linkedinurl]


	*/


CREATE      VIEW [synapse_ce].[vwContact]
AS
SELECT 
	cnt.[ContactId],
	cnt.[apuk_personaladdresscountryid] AS rics_countryid,
	ctry.[apuk_name] AS [rics_countryidName],
	cnt.[CreatedOn],
	cnt.[CreatedBy],
	usrcreatedby.[fullname] AS [CreatedByName],
	cnt.[ModifiedOn],
	cnt.[ModifiedBy],
	usrmodifiedby.[fullname] AS [ModifiedByName],
	cnt.[TransactionCurrencyId],
	transcur.[currencyname] AS  [TransactionCurrencyIdName],
	--NULL AS [cclregs_regulatoryreturngroupid],
	--NULL AS [cclregs_regulatoryreturngroupidName],
	cnt.[MasterId],
	cnt.[MasterContactIdName],
	rec.[apuk_firstqualifiedlocalgroup] AS [Rics_FirstQualifiedLocalGroupId], -- apuk_ricsrecord(apuk_firstqualifiedlocalgroup)
	rec.[apuk_firstqualifiedlocalgroupname] AS [Rics_FirstQualifiedLocalGroupIdName],
	--NULL AS [rics_nationalityid], -- Not required in CE
	--NULL AS [rics_nationalityidName],
	rec.apuk_pathwayid AS [rics_pathwaytomembershipid], --And also in apuk_ricsrecord
	pth.[apuk_name]  AS [rics_pathwaytomembershipidName],
	--NULL AS [Rics_CorporateSchemeNameId],
	--NULL AS [Rics_CorporateSchemeNameIdName],
	cnt.apuk_localgroupid AS [rics_localgroupid],
	lg.[apuk_name] AS [rics_localgroupidName],
	cnt.[Address1_City],
	cnt.[Address1_Country],
	cnt.[address1_Line1],
	cnt.[Address1_Line2],
	cnt.[Address1_Line3],
	cnt.[Address1_PostalCode],
    cnt.[Address1_County],
    cnt.[Telephone1],
	cnt.[OwnerId],
	ownid.[fullname] AS [OwnerIdName],
	cnt.[parentcustomerid] AS [AccountId],
	cnt.[AccountIdName],
	cnt.[CustomerSizeCode],
	custSizeCode.[LocalizedLabel] AS [CustomerSizeCode_Description],
	cnt.[CustomerTypeCode],
	custTypeCode.[LocalizedLabel] AS [CustomerTypeCode_Description],
	cnt.[LeadSourceCode],
	leadSourceCode.[LocalizedLabel] AS [LeadSourceCode_Description],
	cnt.[OriginatingLeadId],
	cnt.[OriginatingLeadIdName],
	cnt.[Salutation],
	cnt.[JobTitle],
	cnt.[FirstName],
	cnt.[MiddleName],
	cnt.[LastName],
	cnt.[FullName],
	cnt.[BirthDate],
	cnt.[GenderCode],
	genderCode.[LocalizedLabel] AS [GenderCode_Description],
	cnt.[TerritoryCode],
	tercode.[LOcalizedLabel] AS [TerritoryCode_Description],
	cnt.[IsPrivate],
	cnt.[CreditOnHold],
	cnt.[CreditLimit],
	cnt.[Aging30],
	cnt.[StateCode],
	stStateCode.[LocalizedLabel] AS [StateCode_Description],
	cnt.[StatusCode],
	stStatusCode.[LocalizedLabel] AS [StatusCode_Description],
	cnt.[Aging60],
	cnt.[Aging90],
	cnt.[ParentCustomerId],
	cnt.[ParentCustomerIdName],
	cnt.[ParentCustomerIdType],
	cnt.[Merged],
	rec.[apuk_includedinglobalrenewalscampaign] AS [Rics_Renewals],
	--NULL AS [Rics_FinanceReference],
	--NULL AS [Rics_AlertExpiry], -- in apuk_alert(apuk_expirydate)
	rec.[apuk_datequalified] AS [Rics_ElectionDate], -- in apuk_ricsrecord(apuk_datequalified)
	--NULL AS [Rics_RelationshipType],
	cnt.[apuk_honours] AS [Rics_Honours],
	cnt.[apuk_contactnumber] AS [Rics_contactno],
	rec.[apuk_membergrade] AS [Rics_MemberGrade],
	memgrade.[LocalizedLabel] AS [MemberGrade_Description],
	--rec.[apuk_regionid],
	lg.[apuk_regionid],
	ter.[name] AS [Rics_Region], --apuk_ricsrecord(apuk_regionid)
	--NULL AS [Rics_Affiliates],
	rec.[apuk_lapseddate] AS [Rics_LapsedDate], -- apuk_ricsrecord(apuk_lapseddate)
	rec.[apuk_lapsecode] AS [Rics_LapsedCode], -- apuk_ricsrecord(apuk_lapsecode)
	lapsecode.[localizedlabel] AS [Rics_LapsedCode_Description],
	--NULL AS [Rics_RICSMembership],
	--NULL AS [Cclregs_memberofregscheme],
	cnt.[apuk_paymentmethod] AS [Rics_PaymentMethod],
	paymethod.[LocalizedLabel] AS [Rics_PaymentMethod_Description],
	
	'00000000-0000-0000-0000-000000000000' AS [Rics_ConcessionCode],
	'' AS [Rics_ConcessionCode_Descritpion],
	/*  Raj: 2024-08-01, Commented as these fields are not related to contact, they are concession based entity */
	--conc.[apuk_concessionid] AS [Rics_ConcessionCode], --In CRM, this is INT but in CE is GUID
	--conc.[apuk_name] AS [Rics_ConcessionCode_Descritpion],	
	
	--NULL AS [Rics_ConcessionCode], -- apuk_concession(apuk_concession)
	rec.[apuk_donotchase] AS [Rics_Donotchase], --apuk_ricsrecord(apuk_donotchase)
	donotchase.[LocalizedLabel] AS [Rics_Donotchase_Description],
	cnt.[MobilePhone],
	cnt.[apuk_localname] AS [Rics_MailName],
	cnt.[EMailAddress1],
	cnt.[apuk_preferredaddresscountryid] AS [Rics_corespadd_country],
	cnt.[apuk_paymentcycle] AS [Rics_PaymentCycle],
	paycycle.[LocalizedLabel] AS [Rics_PaymentCycle_Description],
	rec.[apuk_preventlapse] AS [Rics_PreventLapse], --apuk_ricsrecord(apuk_preventlapse)
	prevlapse.[LocalizedLabel] AS [Rics_PreventLapse_Description],
	rec.[apuk_membershipstatus] AS [Rics_PendingRemoval], --apuk_ricsrecord(apuk_membershipstatus)
	rec.[apuk_pendingremovaldate] AS [Rics_PendingRemovalDate], --apuk_ricsrecord(apuk_pendingremovaldate)
	--cnt.[apuk_subscriptioninformation] AS [Rics_HardcopySubs],
	rec.[apuk_hardcopysubsrenewal] AS [Rics_HardcopySubs],
	--NULL AS [CurrentAge],
	--NULL AS [AdjustedAge],
	cnt.[apuk_hasdisability] AS Rics_Disability,
	cnt.[apuk_ethnicity] AS Rics_Ethnicity,
	ethnicity.[LocalizedLabel] AS [Rics_Ethnicity_Description],
	rec.[apuk_primaryprofessionalgroupid] AS [rics_primaryprofessionalgroupid], --apuk_ricsrecord(apuk_primaryprofessionalgroupid)
	pg.[apuk_name] AS [rics_primaryprofessionalgroupidName],
	--NULL AS Rics_Title, --picklist
	0 AS [Rics_DualMembership], --apuk_concession(apuk_concession)
	'' AS [Rics_DualMembership_Description],

	/*** Raj: 2024-08-01, Not required in contact entity  */
	--conc.[apuk_dualmembership] AS [Rics_DualMembership], --apuk_concession(apuk_concession)
	--dualmem.[LocalizedLabel] AS [Rics_DualMembership_Description],
	cnt.[apuk_contacttype] AS [Rics_ContactType],
	contacttype.[LocalizedLabel] AS [Rics_ContactType_Description],
	cnt.[apuk_counsellor] AS [ricsv1_Counsellor],
	cnt.[apuk_moreinformation] AS [rics_receiveenewsletter], 
	--NULL AS [rics_donotmarketingemail], 
	cnt.[address1_city] AS [rics_corespadd_city], 
	--NULL AS [rics_registeredonmyrics],
	--alrt.[apuk_name] AS [rics_alerttext], -- apuk_alert(apuk_name)
    cnt.[EmailAddress2],
    cnt.[EmailAddress3],
    cnt.[Telephone3],
	rec.[apuk_assessorauditor] AS [Rics_AssessorAuditor],
	rec.[apuk_assessorchairperson] AS [Rics_AssessorChairman],
	cnt.[apuk_emailpreference] AS [Rics_EmailPreference],
	emailpref.[LocalizedLabel] AS [Rics_EmailPreference_Description],

    cnt.[apuk_addresspreference] AS [Rics_AddressPreference],
	addPref.[LocalizedLabel] AS [Rics_AddressPreference_Description],

    cnt.[apuk_phonepreference] AS [Rics_PhonePreference],
	PhPref.[LocalizedLabel] AS [Rics_PhonePreference_Description],

	cnt.[apuk_disabilitiesdetails],
	rec.[apuk_eminentmember],
	cnt.[apuk_ricsrecordid],
	rec.[apuk_applicanttype],
	aptype.[LocalizedLabel] AS [apuk_applicanttype_description],
	rec.[apuk_designation],
	desig.[LocalizedLabel] AS [apuk_designation_description],
	cnt.[apuk_giftaid],
	cnt.[apuk_declinelionheart],
	cnt.[address2_line1],
	cnt.[address2_postalcode],
	cnt.[address2_country],
	cnt.[apuk_personaladdresscountryid],
	personaladdresscountry.[apuk_name] AS [apuk_personaladdresscountryidName],
	cnt.[address1_longitude],
	cnt.[address2_longitude],
	cnt.[address3_longitude],
	cnt.[address1_latitude],
	cnt.[address2_latitude],
	cnt.[address3_latitude],
	cnt.[apuk_preferredaddresscompanyname],
	cnt.[apuk_preferredaddresscountryid],
	cnt.[apuk_sexualorientation], 
	cnt.[apuk_genderidentity], 
	cnt.[apuk_religionorbelief], 
	--cnt.apuk_ethnicity, 
	cnt.[apuk_ethnicityother], 
	--cnt.apuk_hasdisability,
	cnt.[apuk_disabilities],
	cnt.[apuk_twitterurl],
	cnt.[apuk_linkedinurl],
	memgp.[apuk_professionalgroupid],
	cnt.[apuk_ethicsmodulelasttaken],
	cnt.[apuk_directdebit],
    --NULL AS [ricsv1_ExcludeFromBetaTesting]
	cnt.[apuk_hasdisability2],
	hasdisability2.[LocalizedLabel] AS [apuk_hasdisability2_description],
	cnt.apuk_drsdisputeresolver,
	cnt.apuk_drspanelenddate,
	cnt.apuk_drspanelmemberonhold,
	cnt.[address2_line2],
	cnt.[address2_line3],
	cnt.[address2_city],
	cnt.[address2_county],
	cnt.[apuk_firstvisitconsentcentre],
	cnt.[apuk_consentupdated],
	cnt.[apuk_acssoftoptin]


FROM synapse_ce.contact cnt WITH (NOLOCK)
	LEFT JOIN [synapse_ce].[apuk_country] ctry
		ON cnt.[apuk_personaladdresscountryid] = ctry.[apuk_countryid]
	LEFT JOIN synapse_ce.systemuser usrcreatedby
		ON cnt.[createdby] = usrcreatedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser usrmodifiedby
		ON cnt.[modifiedby] = usrmodifiedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser ownid
		ON cnt.[ownerid] = ownid.[systemuserid]
	LEFT JOIN synapse_ce.transactioncurrency transcur
		ON cnt.[transactioncurrencyid] = transcur.[transactioncurrencyid]
	LEFT JOIN [synapse_ce].[apuk_ricsrecord] rec
		ON cnt.[apuk_ricsrecordid] = rec.[apuk_ricsrecordid]
/*** Raj: 2024-08-01, Not required in contact entity  */
	--LEFT JOIN synapse_ce.apuk_concession conc
	--	ON rec.apuk_ricsrecordid = conc.apuk_ricsrecordid
	--		AND conc.[apuk_dualmembership] = 0 --There is an issue. " records exist in concession table for each ricsrecordid and every where dualmembership = 0 and 1
	--		AND CASE WHEN MONTH(getdate()) >= 8 THEN YEAR(getdate()) ELSE YEAR(getdate())-1 END = apuk_subscriptionyear
	--		AND conc.[statecode] = 0
	--		AND conc.apuk_concessionid <> '00000000-0000-0000-0000-000000000000'
	LEFT JOIN synapse_ce.apuk_localgroup lg
		ON cnt.[apuk_localgroupid] = lg.[apuk_localgroupid]
	LEFT JOIN synapse_ce.territory ter
		ON lg.apuk_regionid = ter.territoryid
	LEFT JOIN synapse_ce.apuk_pathway pth
		ON rec.apuk_pathwayid = pth.apuk_pathwayid
	--Need to check this to get alertexpiry. IT IS 1->* relationship between contact and alert
	--LEFT JOIN synapse_ce.apuk_alert alrt
	--	ON cnt.contactid = alrt.apuk_contactid
	LEFT JOIN synapse_ce.apuk_membersprofessionalgroup memgp
		ON rec.[apuk_primaryprofessionalgroupid] = memgp.[apuk_membersprofessionalgroupid]
	LEFT JOIN synapse_ce.apuk_professionalgroup pg
		ON memgp.[apuk_professionalgroupid] = pg.[apuk_professionalgroupid]
	LEFT JOIN synapse_ce.OptionSetMetadata prevlapse
		ON rec.[apuk_preventlapse] = prevlapse.[Option]
			AND prevlapse.[OptionSetName] = 'apuk_preventlapse'
			AND prevlapse.[EntityName] = 'apuk_ricsrecord'
	/*** Raj: 2024-08-01, Not required in contact entity  */
	--LEFT JOIN synapse_ce.OptionSetMetadata dualmem
	--	ON conc.[apuk_dualmembership] = dualmem.[Option]
	--		AND dualmem.[OptionSetName] = 'apuk_dualmembership'
	--		AND dualmem.[EntityName] = 'apuk_concession'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata donotchase
		ON rec.[apuk_donotchase] = donotchase.[Option]
			AND donotchase.[OptionSetName] = 'apuk_donotchase'
			AND donotchase.[EntityName] = 'apuk_ricsrecord'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata paymethod
		ON cnt.[apuk_paymentmethod] = paymethod.[Option]
			AND paymethod.[OptionSetName] = 'apuk_paymentmethod'
			AND paymethod.[EntityName] = 'contact'
	LEFT JOIN synapse_ce.OptionSetMetadata paycycle
		ON cnt.[apuk_paymentcycle] = paycycle.[Option]
			AND paycycle.[OptionSetName] = 'apuk_paymentcycle'
			AND paycycle.[EntityName] = 'contact'
	LEFT JOIN synapse_ce.OptionSetMetadata custSizeCode
		ON cnt.[customersizecode] = custSizeCode.[Option]
			AND custSizeCode.[OptionSetName] = 'CustomerSizeCode'
			AND custSizeCode.[EntityName] = 'Contact'
	LEFT JOIN synapse_ce.OptionSetMetadata custTypeCode
		ON cnt.[customertypecode] = custTypeCode.[Option]
			AND custTypeCode.[OptionSetName] = 'CustomerTypeCode'
			AND custTypeCode.[EntityName] = 'Contact'
	LEFT JOIN synapse_ce.OptionSetMetadata leadSourceCode
		ON cnt.[leadsourcecode] = leadSourceCode.[Option]
			AND leadSourceCode.[OptionSetName] = 'LeadSourceCode'
			AND leadSourceCode.[EntityName] = 'Contact'
	LEFT JOIN synapse_ce.OptionSetMetadata genderCode
		ON cnt.[gendercode] = genderCode.[Option]
			AND genderCode.[OptionSetName] = 'GenderCode'
			AND genderCode.[EntityName] = 'Contact'
	LEFT JOIN synapse_ce.OptionSetMetadata tercode
		ON cnt.[territorycode] = tercode.[Option]
			AND tercode.[OptionSetName] = 'TerritoryCode'
			AND tercode.[EntityName] = 'Contact'
	LEFT JOIN synapse_ce.StateMetadata stStateCode
		ON cnt.[statecode] = stStateCode.[State]
			AND stStateCode.[EntityName] = 'contact'
	LEFT JOIN synapse_ce.StatusMetadata stStatusCode
		ON cnt.[statuscode] = stStatusCode.[Status]
			AND stStatusCode.[EntityName] = 'contact'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata memgrade
		ON rec.[apuk_membergrade] = memgrade.[Option]
			AND memgrade.[OptionSetName] = 'apuk_membergrade'
			AND memgrade.[EntityName] = 'apuk_ricsrecord'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata lapsecode
		ON rec.[apuk_lapsecode] = lapsecode.[Option]
			AND lapsecode.[OptionSetName] = 'apuk_lapsecode'
			AND lapsecode.[EntityName] = 'apuk_ricsrecord'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata contacttype
		ON cnt.[apuk_contacttype] = contacttype.[Option]
			AND contacttype.[OptionSetName] = 'apuk_contacttype'
			AND contacttype.[EntityName] = 'contact'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata emailpref
		ON cnt.[apuk_emailpreference] = emailpref.[Option]
			AND emailpref.[OptionSetName] = 'apuk_emailpreference'
			AND emailpref.[EntityName] = 'contact'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata addPref
		ON cnt.[apuk_addresspreference] = addPref.[Option]
			AND addPref.[OptionSetName] = 'apuk_addresspreference'
			AND addPref.[EntityName] = 'contact'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata PhPref
		ON cnt.[apuk_phonepreference] = PhPref.[Option]
			AND PhPref.[OptionSetName] = 'apuk_phonepreference'
			AND PhPref.[EntityName] = 'contact'

	LEFT JOIN synapse_ce.GlobalOptionSetMetadata aptype
		ON rec.[apuk_applicanttype] = aptype.[Option]
			AND aptype.[OptionSetName] = 'apuk_applicanttype'
			AND aptype.[EntityName] = 'apuk_ricsrecord'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata desig
		ON rec.[apuk_designation] = desig.[Option]
			AND desig.[OptionSetName] = 'apuk_designation'
			AND desig.[EntityName] = 'apuk_ricsrecord'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata ethnicity
		ON cnt.[apuk_ethnicity] = ethnicity.[Option]
			AND ethnicity.[OptionSetName] = 'apuk_ethnicity'
			AND ethnicity.[EntityName] = 'contact'
	LEFT JOIN synapse_ce.OptionSetMetadata hasdisability2
		ON cnt.[apuk_hasdisability2] = hasdisability2.[Option]
			AND hasdisability2.[OptionSetName] = 'apuk_hasdisability2'
			AND hasdisability2.[EntityName] = 'contact'

	LEFT JOIN synapse_ce.apuk_country personaladdresscountry
		ON cnt.[apuk_personaladdresscountryid] = personaladdresscountry.[apuk_countryid]
	WHERE apuk_directdebit = 0 --Remove Test Records

--WHERE --cnt.[contactid] = '00000000-0000-0000-0000-000000000000'
--	conc.apuk_concessionid <> '00000000-0000-0000-0000-000000000000'
