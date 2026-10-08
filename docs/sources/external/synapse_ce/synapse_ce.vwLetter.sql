CREATE   VIEW [synapse_ce].[vwLetter]
AS
SELECT 
	lt.[activityid],
	lt.[description],
	lt.[createdon],
	lt.[createdby],
	lt.[modifiedon],
	lt.[modifiedby],
	lt.[ownerid],
	lt.[owningbusinessunit],
	lt.[owninguser],
	lt.[transactioncurrencyid],
	lt.[regardingobjectid],
	lt.[actualstart],
	lt.[actualend],
	lt.[actualdurationminutes],
	lt.[category],
	lt.[subcategory],
	lt.[prioritycode],
	lt.[isregularactivity],
	lt.[directioncode],
	lt.[subject],
	lt.[createdonbehalfby],
	lt.[modifiedonbehalfby],
	lt.[statecode],
	lt.[statuscode]
FROM synapse_ce.letter lt
