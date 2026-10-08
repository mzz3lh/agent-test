CREATE   VIEW [CE].[vwConcession]
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
	cnt.[Rics_contactno],
	conc.[ProductId],
	prd.[Product_Number],
	conc.[apuk_perpetualnonperpetual],
	conc.[apuk_perpetualnonperpetual_description],
	conc.[apuk_discount],
	conc.[apuk_subsonlineupdate],
	conc.[overriddencreatedon],
	conc.[owningbusinessunit],  
	conc.[owningbusinessunitName],
	conc.[modifiedonbehalfby],
	conc.[apuk_dualmembershipfirmid], 
	conc.[createdonbehalfby]
FROM [synapse_ce].[vwConcession] conc
	INNER JOIN synapse_ce.tblContact_BI cnt
		ON conc.[apuk_contactid] = cnt.[ContactId] 
	LEFT JOIN [synapse_ce].[vwProduct] prd
		ON conc.[ProductId] = prd.[ProductId]
