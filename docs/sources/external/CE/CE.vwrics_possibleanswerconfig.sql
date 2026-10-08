CREATE   VIEW [CE].[vwrics_possibleanswerconfig]
AS
SELECT 
	[rics_possibleanswerconfigid],
	[rics_name],
	[rics_possibleanswer],
	[rics_question],
	[rics_order],
	[createdon],
	[createdby],
	[CreatedByName],
	[createdonbehalfby],
	[CreatedOnbehalfByName],
	[modifiedon],
	[modifiedby],
	[ModifiedByName],
	[modifiedonbehalfby],
	[ModifiedOnbehalfByName],
	[ownerid],
	[OwnerIdName],
	[statecode],
	[StateCode_Description],
	[statuscode],
	[StatusCode_Description]
FROM [synapse_ce].[vwrics_possibleanswerconfig]
