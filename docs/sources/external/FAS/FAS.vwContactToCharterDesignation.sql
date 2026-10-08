CREATE   VIEW [FAS].[vwContactToCharterDesignation]
AS
SELECT source.Id,
	source.SinkCreatedOn, 
	source.SinkModifiedOn,
	source.StateCode,
	source.StatusCode,
	source.apuk_chartereddesignationid,
	ricsrecord.apuk_contactId,
	source.apuk_startdate,
	source.apuk_enddate
FROM synapse_ce.apuk_memberchartereddesignation as Source
  INNER JOIN synapse_ce.apuk_ricsrecord as ricsrecord 
	ON ricsrecord.id = source.apuk_ricsrecordid 
	AND ricsrecord.statuscode = 1 and ricsrecord.apuk_name is not null
