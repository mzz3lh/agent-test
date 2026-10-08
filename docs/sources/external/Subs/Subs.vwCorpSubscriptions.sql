CREATE VIEW [Subs].[vwCorpSubscriptions] AS 

	SELECT
	 SUBUSER.contactnumber AS 'Contact No'
	,SUBUSER.ricsv2_Contact AS 'Contact ID'
	,SUB.ricsv2_SubscriptionNo AS 'Scheme No'
	,REPLACE(SUB.ricsv2_SubscriptionsIdName, 'Corporate - ', '') AS 'Scheme Name'
	,CAST(SUB.ricsv2_StartDate AS DATE) AS 'Sub Start Date'
	,CAST(SUB.ricsv2_EndDate AS DATE) AS 'Sub End Date'
	,SUB.StateCode_Description AS 'Sub State'
	,SUB.StatusCode_Description AS 'Sub Status'
	,CAST(SUB.apuk_licensekey AS INT) AS 'Sub Campaign Year'
	,SUBUSER.apuk_licencekey AS 'Round'
	,SUBUSER.StateCode_Description AS 'Sub User State'
	,SUBUSER.StatusCode_Description AS 'Sub User Status'
	,CAST(SUBUSER.Created_On AS DATE) AS 'Sub User Created Date'
	,CASE 
		WHEN CON.Rics_MemberGrade IS NULL 
		OR CON.Rics_MemberGrade NOT IN (200000000, 200000001, 200000002)
		THEN 'Y' ELSE 'N' END AS 'Invalid Member Grade'
	,CASE WHEN CON.Rics_LapsedDate IS NOT NULL THEN 'Y' ELSE 'N' END AS 'Is Lapsed'
	,CASE WHEN SUBUSER.statecode = 1 THEN 'Y' ELSE 'N' END AS 'Inactive SU Status'
	,CASE 
		WHEN CON.Rics_MemberGrade IS NULL 
		OR CON.Rics_MemberGrade NOT IN (200000000, 200000001, 200000002)
		OR CON.Rics_LapsedDate IS NOT NULL
		OR SUBUSER.statecode = 1 --Inactive SU State
		THEN 'N' ELSE 'Y' END AS 'Quote Expected'
	FROM CE.vwRicsv2Subscription SUB
	INNER JOIN CE.vwSubscriptionUser SUBUSER
		ON SUBUSER.ricsv2_SubscriptionId = SUB.ricsv2_subscriptionId
	LEFT JOIN synapse_ce.tblContact_BI CON
		ON CON.ContactId = SUBUSER.ricsv2_Contact
	WHERE SUB.ricsv1_SubscriptionProduct = '00000000-0000-0000-0000-000000000000' --Corporate Subs Membership Product
