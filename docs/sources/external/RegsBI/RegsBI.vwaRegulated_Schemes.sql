CREATE   VIEW [RegsBI].[vwaRegulated_Schemes]
AS
	WITH

	RS AS --Regulated Firm/Account Scheme
	(SELECT
	[apuk_regulatedschemeid] AS [Scheme ID],
	CAST(apuk_licensedfirmid AS VARCHAR(100)) AS [Firm ID],
	CAST([apuk_regulatedindividualid] AS VARCHAR(100)) AS [Contact ID],
	CAST([apuk_contactofficerid] AS VARCHAR(100)) AS [Contact Officer ID],
	CAST([apuk_responsibleprincipalid] AS VARCHAR(100)) AS [Responsible Principal ID],
	VR.AccountId AS [Valuer Primary Employment ID],
	VR.[Rics_contactno] AS [Valuer Contact No],
	VR.[FullName] AS [Valuer Full Name],
	VR.[Membership Type] AS [Valuer Membership Type],
	VR.[AccountIdName] AS [Valuer Primary Employment Name],
	[apuk_vrssponsorshipcode] AS [VRS Sponsorship Code],
	[vwRegulatedscheme_CE].[apuk_name] AS [Scheme Name],
	[apuk_approvalconditions] AS [Approval Conditions],
	[apuk_renewalsubmitteddate] AS [Latest Renewal],
	[vwRegulatedscheme_CE].[StatusCode_Description] AS [Scheme License Status],
	[apuk_regulatedschemetypeidName] AS [Scheme Type],
	[apuk_clientmoneytype_Description] AS [Client Money Type],
	[apuk_regulatedschemenumber] AS [Scheme Reference],
	CAST([apuk_numberofmemberdirectorprincipals] AS Numeric) AS [Member Principals],
	CAST([apuk_numberofdirectorprincipals] AS Numeric) AS [Total Principals],
	CASE WHEN [apuk_numberofmemberdirectorprincipals]='0' OR [apuk_numberofdirectorprincipals]='0' THEN '' 
	ELSE CAST((CAST([apuk_numberofmemberdirectorprincipals] AS Numeric) / CAST([apuk_numberofdirectorprincipals] AS Numeric))*100 AS INT) 
	END AS [Member Director %],
	[apuk_isrobustregistration_Description] AS [Is Robust Registration],
	[apuk_inclusionreason_Description] AS [Reason for Registration],
	CAST([apuk_approvaldate] AS DATE) AS [Approval Date],
	DATEDIFF(day, [apuk_approvaldate], getdate()) AS [Days Active],
	[rics_firmnumber] AS [Firm Number],
	[rics_officenumber] AS [Office Number],
	[name] AS [Account Name],
	[rics_tradingname] AS [Trading Name],
	[rics_registeredname] AS [Registered Name],
	[ricsv1_isregulatedoffice] AS [Is Regulated Office],
	[Rics_IsHeadoffice] AS [Is Head Office],
	[apuk_regulatedorganisationtype_Description] AS [Legal status],
	CO.[Rics_contactno] AS [Contact Officer No.],
	CO.[FullName] AS [Contact Officer Name],
	CO.[Salutation] AS [Contact Officer Salutation],
	CO.EMailAddress1 AS [Contact Officer Email],
	RP.[Rics_contactno] AS [Resp. Principal No.],
	RP.[FullName] AS [Resp. Principal Name],
	RP.[EMailAddress1] AS [Resp. Principal Email],
	RP.[Salutation] AS [Resp. Principal Salutation],
	[apuk_localgroupid] AS [Local Group ID],
    LG.[apuk_name] AS [Local Group],
	Acct.[Address1_PostalCode] AS [Post Code],
	[apuk_regionid_name] AS [Region],
	[apuk_countryid_name] AS [Country],
	[apuk_reportingsubworldregion_name] AS [Sub World Region],
	[apuk_worldregionid_name] AS [World Region]

	FROM [RegsBI].[vwRegulatedscheme_CE] 
	LEFT JOIN [RegsBI].[vwAccount_CE] Acct ON AccountId = apuk_licensedfirmid -- Accounts
	LEFT JOIN [RegsBI].[vwContact_CE] VR ON [apuk_regulatedindividualid] = [ContactId] -- Valuers
	LEFT JOIN [RegsBI].[vwContact_CE] CO ON [apuk_contactofficerid] = CO.[ContactId] -- Contact officers
	LEFT JOIN [RegsBI].[vwContact_CE] RP ON [apuk_responsibleprincipalid] = RP.[ContactId] --Responsible Principals
	LEFT JOIN [RegsBI].[vwLocalGroup_CE] LG ON LG.[apuk_localgroupid] = Acct.[Rics_LocalGroupId] OR LG.[apuk_localgroupid] = VR.rics_localgroupid
	WHERE [apuk_schemeenddate] IS NULL
	AND [vwRegulatedscheme_CE].[StateCode_Description] = 'Active'
	AND [vwRegulatedscheme_CE].[StatusCode_Description] IN ('Licence Approved', 'Licence Approved with Conditions','Deregistration in Progress','Deregistration Deferred', 'Deregistration Requested'))

	SELECT * FROM RS
