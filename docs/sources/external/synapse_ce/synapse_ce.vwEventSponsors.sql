CREATE   VIEW [synapse_ce].[vwEventSponsors]
AS
SELECT 
	sp.[msevtmgt_sponsorshipid] AS [MSA_eventsponsorId],
	sp.[msevtmgt_name] AS [MSA_name],
	sp.[msevtmgt_event] AS [msa_campaign_eventsponsorid],
	ev.[msevtmgt_name] AS [msa_campaign_eventsponsoridName],
	sp.[CreatedBy],
	usrcreatedby.[fullname] AS [CreatedByName],
	sp.[createdon] AS [Created_On],
	sp.[ModifiedBy],
	usrmodifiedby.[fullname] AS [ModifiedByName],
	sp.[modifiedon] AS [Modified_On],
	--NULL AS [cclevent_invoicemessageid], --Not in CE
	--NULL AS [cclevent_invoicemessageidName], -- NOt in CE
	sp.[TransactionCurrencyId],
	curr.[currencyname] AS [TransactionCurrencyName],
	sp.[OwnerId],
	ownid.[fullname] AS [OwnerIdName],
	-1 AS [SalesTeamId], --Need to get surrogate key
	--NULL AS [CclEvent_ApprovedOn], --Not in CE
	--NULL AS [CclEvent_TaxValue], --Not in CE
	sp.[ExchangeRate],
	--NULL AS [CclEvent_ValueGross], --Not in CE
	--NULL AS [CclEvent_ValueNET], --Not in CE
	sp.[msevtmgt_sponsorshipamount] AS [MSA_SponsorshipAmount],
	sp.[msevtmgt_sponsorshiptype] AS [MSA_SponsorshipType],
	sptype.[LocalizedLabel] AS [SponsorshipType], --Need to check optionsets
	sp.[statecode],
	stStateCode.[LocalizedLabel] AS [StateCode_Description],
	sp.[statuscode],
	stStatusCode.[LocalizedLabel] AS [StatusCode_Description]--,
	--NULL AS [cclrv2_InvoiceType], --Not in CE
	--NULL AS [InvoiceType_Description] --Not in CE
FROM synapse_ce.msevtmgt_sponsorship sp
	LEFT JOIN [synapse_ce].[msevtmgt_event] ev
		ON sp.[msevtmgt_event] = ev.[msevtmgt_eventid]
	LEFT JOIN [synapse_ce].[StatusMetadata] stStatusCode
		ON sp.[statuscode] = stStatusCode.[Status]
			AND stStatusCode.[EntityName] = 'msevtmgt_sponsorship'
	LEFT JOIN [synapse_ce].[StateMetadata] stStateCode
		ON sp.[statecode] = stStateCode.[State]
			AND stStateCode.[EntityName] = 'msevtmgt_sponsorship'
	LEFT JOIN synapse_ce.systemuser usrcreatedby
		ON sp.[createdby] = usrcreatedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser usrmodifiedby
		ON sp.[modifiedby] = usrmodifiedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser ownid
		ON sp.[ownerid] = ownid.[systemuserid]
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata sptype
		ON sp.[msevtmgt_sponsorshiptype] = sptype.[Option]
			AND sptype.[OptionSetName] = 'msevtmgt_sponsorshiptype'
			AND sptype.[EntityName] = 'msevtmgt_sponsorship'
	LEFT JOIN synapse_ce.transactioncurrency curr
		ON sp.[transactioncurrencyid] = curr.[transactioncurrencyid]
--WHERE sp.msevtmgt_sponsorshipid = '00000000-0000-0000-0000-000000000000'
