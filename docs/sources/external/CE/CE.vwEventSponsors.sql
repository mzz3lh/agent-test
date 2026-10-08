CREATE   VIEW [CE].[vwEventSponsors]
AS 
SELECT 
	[MSA_eventsponsorId],
	[MSA_name],
	[msa_campaign_eventsponsorid],
	[msa_campaign_eventsponsoridName],
	[CreatedBy],
	[CreatedByName],
	[Created_On],
	[ModifiedBy],
	[ModifiedByName],
	[Modified_On],
	[TransactionCurrencyId],
	[TransactionCurrencyName],
	[OwnerId],
	[OwnerIdName],
	[SalesTeamId],
	[ExchangeRate],
	[MSA_SponsorshipAmount],
	[MSA_SponsorshipType],
	[SponsorshipType],
	[statecode],
	[StateCode_Description],
	[statuscode],
	[StatusCode_Description]
FROM [synapse_ce].[vwEventSponsors]
