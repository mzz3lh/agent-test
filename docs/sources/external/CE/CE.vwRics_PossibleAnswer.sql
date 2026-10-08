CREATE   VIEW [CE].[vwRics_PossibleAnswer]
AS
SELECT 
	[rics_possibleanswerid],
	[rics_name],
	[rics_requiresvalue],
	[rics_subquestion],
	[rics_answertext],
	[rics_score],
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
FROM [synapse_ce].[vwRics_PossibleAnswer]
