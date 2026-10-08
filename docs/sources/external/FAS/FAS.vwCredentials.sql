CREATE   VIEW [FAS].[vwCredentials]
AS
SELECT Source.Id,
	Source.SinkCreatedOn,
	Source.SinkModifiedOn,
	Source.StateCode,
	Source.StatusCode,
	Source.apuk_name
FROM synapse_ce.apuk_credential as Source
