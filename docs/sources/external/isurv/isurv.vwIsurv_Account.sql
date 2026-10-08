CREATE   VIEW [isurv].[vwIsurv_Account] AS 

	SELECT 
	 acc.[AccountId]
	,acc.[AccountNumber] AS 'Account No.'
	,acc.[name] AS 'Account'
	,acc.[Rics_AccountSubTypeName]
	,acc.[rics_namedaccount]
	,acc.[rics_namedaccountName] AS 'Named Account'
	,acc.[ParentAccountId]
	,acc.[ParentAccountIdName] AS 'Parent Account'
	,acc.[Rics_LocalGroupId]
	FROM [synapse_ce].[vwAccount] acc
	WHERE EXISTS (
		SELECT 
		SUB.apuk_onbehalfoforganisationid
		FROM isurv.vwisurv_subscription SUB
		WHERE SUB.apuk_onbehalfoforganisationid = acc.AccountId
		)
