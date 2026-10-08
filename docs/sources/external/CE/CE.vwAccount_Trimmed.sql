/* CHANGE LOG:

20/01/2022	PRoy	Added version control
20/01/2022	PRoy	Removed usr.FullName and CE.vwSystemUser INNER JOIN from [CE].[vwAccount_Trimmed] after confirming with Raj

*/

/* DROP VIEW script 

drop view if exists [CE].[vwAccount_Trimmed]

*/

CREATE   VIEW [CE].[vwAccount_Trimmed] AS
SELECT
	acc.AccountId,
	--usr.FullName AS OwnerIdName, --Not needed
	ca.OwnerId AS OwnerIdName,
	acc.Rics_NamedAccount,
	acc.rics_namedaccountName,
	ca.Sector,
	ca.Relationship_Status,
	ca.Commercial_Account_Key
FROM CE.vwAccount acc
	INNER JOIN CE.vwCommercialAccount ca
ON acc.rics_namedaccount = ca.Commercial_Account_Key
