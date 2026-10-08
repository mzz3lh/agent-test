CREATE   VIEW [FAS].[vwContactToCredentials]
AS
SELECT Source.Id,
	Source.SinkCreatedOn,
	Source.SinkModifiedOn,
	Source.StateCode,
	Source.StatusCode,
	Source.apuk_credential,
	Source.apuk_contact,
	Source.apuk_startdate,
	Source.apuk_enddate
FROM synapse_ce.apuk_credentialrecord as Source
