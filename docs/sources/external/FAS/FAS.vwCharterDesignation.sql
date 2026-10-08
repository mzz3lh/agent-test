CREATE   VIEW [FAS].[vwCharterDesignation]
AS
SELECT Source.Id,
	Source.SinkCreatedOn,
	Source.SinkModifiedOn,
	Source.StateCode,
	Source.StatusCode,
	Source.apuk_name
FROM  synapse_ce.apuk_chartereddesignation as Source
