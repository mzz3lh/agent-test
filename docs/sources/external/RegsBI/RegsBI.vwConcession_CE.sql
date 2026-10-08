CREATE   VIEW [RegsBI].[vwConcession_CE]
AS
SELECT 
	conc.[apuk_concessionid],
	conc.[apuk_name],
	conc.[apuk_concessiontypeid],
	conc.[apuk_concessiontypeid_Name],
	conc.[apuk_subscriptionyear],
	conc.[apuk_dualmembership],
	conc.[createdon],
	conc.[createdby],
	conc.[CreatedByName],
	conc.[modifiedon],
	conc.[modifiedby],
	conc.[ModifiedByName],
	conc.[ownerid],
	conc.[OwnerIdName],
	conc.[apuk_ricsrecordid],
	conc.[statecode],
	conc.[StateCode_Description],
	conc.[statuscode],
	conc.[StatusCode_Description],
	conc.[apuk_startdate],
	conc.[apuk_enddate],
	conc.[apuk_contactid],
	conc.[Rics_contactno],
	conc.[ProductId],
	conc.[Product_Number],
	conc.[apuk_perpetualnonperpetual],
	conc.[apuk_perpetualnonperpetual_description],
	conc.[apuk_discount],
	conc.[apuk_subsonlineupdate],
	conc.[overriddencreatedon],
	conc.[owningbusinessunit],
	conc.[owningbusinessunitName],
	conc.[modifiedonbehalfby],
	modby.[FullName] AS [modifiedonbehalfbyName],
	conc.[apuk_dualmembershipfirmid],
	acc.[name] AS [apuk_dualmembershipfirmidName],
	conc.[createdonbehalfby] AS [createdonbehalfbyName]

FROM [CE].[vwConcession] conc
	LEFT JOIN [synapse_ce].[SystemUser] modby
		ON conc.[modifiedonbehalfby] = modby.[SystemUserId]
	LEFT JOIN [synapse_ce].[SystemUser] createdy
		ON conc.[createdonbehalfby] = createdy.[SystemUserId]
	LEFT JOIN [synapse_ce].[Account] acc
		ON conc.[apuk_dualmembershipfirmid] = acc.[AccountId]
