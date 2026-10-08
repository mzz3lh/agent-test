/***************************************************************************************************
Query Name:			Contact_Membership_Subscription_Analysis_2024_2025.sql
Procedure:          InsightsBI.vwAD_Contact_Membership_Subscription
Create Date:        2024-10-30
Author:             Alexandra Durston
Description:        The purpose of this query is to analyze which contact numbers appear in either or both datasets (members and subscriptions). It shows:
- How many sources a contact is found in.
- Whether the contact belongs to the "member demographics" group.
- Whether the contact is part of the "subscription campaign" group.
****************************************************************************************************
SUMMARY OF CHANGES
Date(yyyy-mm-dd)    Author              Comments
------------------- ------------------- ------------------------------------------------------------

***************************************************************************************************/
CREATE VIEW [InsightsBI].[vwAD_Contact_Membership_Subscription] AS

WITH PARAMS AS (
SELECT 
CAMPAIGN_YEAR = (SELECT
CampaignYear
FROM BI.vwCalendar as cal
WHERE CAST(GETDATE() AS Date) = CAL.Date),

CAMPAIGN_YEAR_LAST  = (SELECT
CampaignYear-1
FROM BI.vwCalendar as cal
WHERE CAST(GETDATE() AS Date) = CAL.Date)
),



subs_this_year AS (
    -- Retrieve distinct contact numbers from the 'Subs' view where the campaign year is 2024 or 2025
    -- The condition on 'Renewal Date Adj' ensures it only includes records where this date is 
    -- less than or equal to the maximum 'Renewal Date Adj' in the dataset.
    SELECT DISTINCT
        [Contact No.]
    FROM Subs.vwSubsMemberStatuses, params

    WHERE [Campaign Year] = 2027
    AND [Renewal Date Adj] <= (SELECT MAX([Renewal Date Adj]) FROM Subs.vwSubsMemberStatuses)
)
,
subs_last_year AS (
    -- Retrieve distinct contact numbers from the 'Subs' view where the campaign year is 2024 or 2025
    -- The condition on 'Renewal Date Adj' ensures it only includes records where this date is 
    -- less than or equal to the maximum 'Renewal Date Adj' in the dataset.
    SELECT DISTINCT
        [Contact No.]
    FROM Subs.vwSubsMemberStatuses, params

    WHERE [Campaign Year] = 2026
    AND [Renewal Date Adj] <= (SELECT MAX([Renewal Date Adj]) FROM Subs.vwSubsMemberStatuses)
)

, members AS (
    -- Retrieve distinct contact numbers from the 'Members' view where the member grade is 
    -- among certain values and has not lapsed (Rics_LapsedCode is NULL). 
    -- It also ensures the contact's state code is active (StateCode = 0).
    SELECT DISTINCT
        Rics_contactno
    FROM ce.vwContact CON
    WHERE MemberGrade_Description IN ('Candidate', 'Qualified Professional', 'Qualified Professional - 2 Years')
    AND Rics_LapsedCode IS NULL 
    AND StateCode = 0
)

-- Combine the contact numbers from both 'members' and 'subs' into one unified dataset,
-- while adding flags to indicate which source (Members or Subs) each contact number appears in.
, all_contact_nos AS (
    SELECT 
        Rics_contactno AS CONTACT_NO
        , 1 AS MEMBER_DEMOGRAPHICS -- Mark as 1 for member source
        , 0 AS SUBS_CAMPAIGN -- Mark as 0 for subs campaign (not in subs)
		, 0 AS SUBS_LAST_YEAR
    FROM members
    UNION ALL
    SELECT 
        [Contact No.] AS CONTACT_NO
        , 0 AS MEMBER_DEMOGRAPHICS -- Mark as 0 for non-member source
        , 1 AS SUBS_CAMPAIGN -- Mark as 1 for subs campaign
		, 0 AS SUBS_LAST_YEAR
    FROM subs_this_year
	UNION ALL
	   SELECT 
        [Contact No.] AS CONTACT_NO
        , 0 AS MEMBER_DEMOGRAPHICS -- Mark as 0 for non-member source
        , 0 AS SUBS_CAMPAIGN -- Mark as 1 for subs campaign
		, 1 AS SUBS_LAST_YEAR
    FROM subs_last_year

)

, RES AS (
    -- Final query: For each distinct contact number, count how many sources it appears in (either members or subs),
    -- and sum up whether it appears in MEMBER_DEMOGRAPHICS and/or SUBS_CAMPAIGN.
    SELECT
        CONTACT_NO -- Unique contact number
        , SUM(MEMBER_DEMOGRAPHICS)+ SUM(SUBS_CAMPAIGN) AS THIS_YEAR_SOURCES -- Count how many sources the contact number appears in
        , SUM(MEMBER_DEMOGRAPHICS) AS MEMBER_DEMOGRAPHICS -- Sum the member flag (1 or 0)
        , SUM(SUBS_CAMPAIGN) AS SUBS_CAMPAIGN -- Sum the subs campaign flag (1 or 0)
		, SUM(SUBS_LAST_YEAR) AS SUBS_LAST_YEAR
    FROM all_contact_nos AS ACN

    GROUP BY CONTACT_NO

)
,
FINAL AS (
    SELECT
        RES.CONTACT_NO 
        , RES.THIS_YEAR_SOURCES 
        , RES.MEMBER_DEMOGRAPHICS 
        , RES.SUBS_CAMPAIGN 
		, RES.SUBS_LAST_YEAR
		, C.StateCode_Description as MEMBER_CONTACT_STATUS
		, C.MemberGrade_Description AS MEMBER_GRADE_DESCRIPTION
		, C.apuk_designation_description AS MEMBER_DESIGNATION
		, C.Rics_LapsedCode_Description AS LAPSED_CODE
		, C.Rics_PreventLapse_Description AS PREVENT_LAPSE_DESCRIPTION
		, EL.[Application Type]
		,CASE WHEN SMS.[Quote Count] >0 
			THEN 'Y' 
			ELSE 'N'
			END AS [Has Quote]
		,CASE WHEN SMS.[Quote Won Count]>0 
			THEN 'Y' 
			ELSE 'N'
			END AS [Has Won Quote]
		,CASE WHEN SMS.[Invoice Count] >0 
			THEN 'Y' 
			ELSE 'N'
			END AS [Has Invoice]
		,CASE WHEN SMS.[Inv Fully Credited Count] >0 
			THEN 'Y' 
			ELSE 'N'
			END AS [Invoice Fully Credited]
		,CASE WHEN SMS.[Inv Zero Value Invoice Count] >0 
			THEN 'Y' 
			ELSE 'N'
			END AS [Zero Value Invoice]
		,CASE WHEN SMS.[Inv Fully Paid Count] >0 
			THEN 'Y' 
			ELSE 'N'
			END AS [Invoice Fully Paid]
		,CON.apuk_name AS CONCESSION_TYPE
    FROM RES 
	
	INNER JOIN params ON 1=1

    LEFT JOIN CE.vwContact AS C
    ON RES.CONTACT_NO = C.Rics_contactno

    LEFT JOIN Subs.vwSubsMemberStatuses SMS
    ON RES.CONTACT_NO = SMS.[Contact No.]
    AND SMS.[Campaign Year] = 2027

	LEFT JOIN CE.vwEnrolments_Last AS EL
	ON RES.CONTACT_NO = EL.[Contact No]

	LEFT JOIN CE.vwConcession AS CON
	ON CON.Rics_contactno = RES.CONTACT_NO
	AND CON.apuk_subscriptionyear = 2027
	)
	
SELECT
*
--SUM(MEMBER_DEMOGRAPHICS)
--,SUM(SUBS_CAMPAIGN)
--,SUM(SUBS_LAST_YEAR)
FROM FINAL
