/*
		Modification History
		09/05/2022  Raj Maddala	Added fields
				[address1_longitude],
				[address2_longitude],

		07/06/2022		Raj Maddala		Added fields
			acc.[apuk_fasstatus]
	   
	*/


CREATE        VIEW [synapse_ce].[vwAccount]
AS

SELECT
	acc.[AccountId],
	acc.[apuk_tradingname] AS [rics_tradingname],
	acc.[apuk_registeredname] AS [rics_registeredname],
	acc.[name],
	acc.[apuk_practicetype] AS [Rics_AccountSubType],
	practype.[LocalizedLabel] AS [Rics_AccountSubTypeName],
	acc.[address1_postalcode],
	acc.[Address1_City],
	acc.[Address1_County],
	acc.[Address1_Country],
	acc.[address1_addresstypecode],
	acc.[address1_composite],
	acc.[address1_telephone1],
	acc.[address1_line3],
	acc.[address1_line2],
	acc.[address1_line1],
	--acc.[rics_accounttype],   Not in CE
	--acc.[Cclregs_TotalNumberofPrincipals],  Not in CE
	acc.[apuk_officenumber]	 AS [rics_officenumber],
	acc.[apuk_legalstatus] AS [Rics_LegalStatus],
	legstat.[LocalizedLabel] AS [Rics_LegalStatusName],
	--acc.[Rics_RegulatedArea],   Not in CE
	acc.[apuk_isheadoffice] AS [Rics_IsHeadoffice],
	acc.[apuk_firmnumber] AS [rics_firmnumber],
	acc.[StatusCode],
	statuscode.[LocalizedLabel] AS [StatusCode_Description],
	acc.[StateCode],
	statecode.[LocalizedLabel] AS [StateCode_Description],
	acc.[apuk_commercialacountid] AS [rics_namedaccount],
	cac.[apuk_name] AS  [rics_namedaccountName], --Need to join with apuk_commercialaccount
	cac.owneridname AS [Commercial_Account_Owner],
	acc.[CreatedBy],
	acc.[CreatedByName],
	acc.[createdon] AS [Created_On],
	acc.[ModifiedBy],
	acc.[ModifiedByName],
	acc.[modifiedon] AS [Modified_On],
	acc.[OwnerId],
	acc.[OwnerIdName],
	acc.[apuk_countryid] AS [rics_countryid],
	acc.[apuk_countryidname] AS [rics_countryidName],
	acc.[PrimaryContactId],
	acc.[PrimaryContactIdName],
	acc.[Telephone1],
	acc.[ParentAccountId],
	acc.[ParentAccountIdName],
	--acc.[Rics_KeyAccount],  Not in CE
	acc.[AccountNumber],
	acc.[apuk_armareference] AS [ricsv2_armareference],
	acc.[apuk_yearestablished] AS [rics_yearestablished],
	acc.[websiteurl],
	acc.[apuk_vatregnumber] AS [rics_vatregnumber],
	acc.[apuk_vatgstregnumberrequired],
	acc.[apuk_companyregnorequired],
	acc.[apuk_companyregistrationnumber],
	acc.[msdyn_salestaxgroup],

	-- [rics_trainees],   Not in CE
	acc.[apuk_tradeaccount] AS [ricsv1_tradeaccount],
	--acc.[ccl_tradeaccountreference],
	--acc.[cclregs_regulatoryreturngroupid],
	--acc.[cclregs_regulatoryreturngroupidName],
	--acc.[rics_partnerdircount],
	--acc.[rics_parentkeyaccountflag],
	--acc.[cclregs_numberofprincipalsnonmembers],
	--acc.[cclregs_numberofprincipalsmembers],
	acc.[numberofemployees],
	--acc.[rics_noofoffices],
	--acc.[rics_members],
	acc.[apuk_isofficeregulated] AS [ricsv1_isregulatedoffice],
	--acc.[rics_employees],
	acc.[emailaddress1],
	--acc.[rics_dpblicense],
	acc.[donotphone],
	acc.[donotpostalmail],
	acc.[donotfax],
	acc.[donotemail],
	acc.[donotbulkpostalmail],
	acc.[donotbulkemail],
	--acc.[rics_corporateschemenameid],
	--acc.[Rics_CorporateSchemeNameIdName],
	acc.[apuk_corporatepayer] AS [rics_corporatepayer],
	--acc.[rics_assessors],
	--acc.[cclregs_percentageofmemberstononmembersprincipals],
	acc.[apuk_localgroupid] AS [Rics_LocalGroupId],
	acc.[apuk_localgroupidname] AS [Rics_LocalGroupIdName],
	acc.[msdyn_invoiceaddress],
	invaddress.[LocalizedLabel] AS [msdyn_invoiceaddress_description],
	acc.[address1_longitude],
	acc.[address2_longitude],
	acc.[address1_latitude],
	acc.[address2_latitude],
	acc.[apuk_fasstatus],
	fasstatus.[LocalizedLabel] AS [apuk_fasstatus_description],
	acc.[msdyn_customerpaymentmethodname] AS [Customer_Payment_Method]
	--IIF(regsch.apuk_licensedfirmid IS NOT NULL AND conn.record1id IS NOT NULL, 1, 0) AS [KeyAccount],
	--conn.[Key Account Manager]

 FROM synapse_ce.account acc
	LEFT JOIN synapse_ce.apuk_commercialaccount cac
		ON acc.apuk_commercialacountid = cac.apuk_commercialaccountid
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata practype
		ON acc.[apuk_practicetype] = practype.[Option]
			AND practype.[OptionSetName] = 'apuk_practicetype'
			AND practype.[EntityName] = 'account'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata legstat
		ON acc.[apuk_legalstatus] = legstat.[Option]
			AND legstat.[OptionSetName] = 'apuk_legalstatus'
			AND legstat.[EntityName] = 'account'
	LEFT JOIN synapse_ce.StateMetadata statecode
		ON acc.[statecode] = statecode.[State]
			AND statecode.[EntityName] = 'account'
	LEFT JOIN synapse_ce.StatusMetadata statuscode
		ON acc.[statuscode] = statuscode.[Status]
			AND statuscode.[EntityName] = 'account'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata invaddress
		ON acc.[msdyn_invoiceaddress] = invaddress.[Option]
			AND invaddress.[OptionSetName] = 'msdyn_invoiceaddress'
			AND invaddress.[EntityName] = 'account'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata fasstatus
		ON acc.[apuk_fasstatus] = fasstatus.[Option]
			AND fasstatus.[OptionSetName] = 'apuk_fasstatus'
			AND fasstatus.[EntityName] = 'account'
