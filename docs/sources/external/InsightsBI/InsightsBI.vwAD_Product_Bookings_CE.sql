CREATE VIEW InsightsBI.vwAD_Product_Bookings_CE AS 

SELECT 

    'CE' AS SOURCE_PLATFORM,
     case  WHEN b.Name LIKE '%Award%' then 'Awards' 
	 else b.apuk_format_description end AS PRODUCT_TYPE,
    b.BusinessArea_Descritpion AS PRODUCT_GROUP,
    b.EventType_Description AS EVENT_TYPE,
    b.name AS COURSE_NAME,
    CAST(b.Cclevent_eventid  AS Nvarchar(40)) AS EVENT_ID,
	CAST(b.Cclevent_eventid AS nvarchar(40)) RICS_EVENTCODE,
    CAST ('' AS nvarchar) AS SKU_CODE,
    cast(b.ActualStart AS date) AS EVENT_START_DATE,
    CAST(b.ActualEnd AS DATE) AS EVENT_END_DATE,
    DATEDIFF(DAY, b.ActualStart, b.ActualEnd)+1 AS EVENT_LENGTH,
	b.Cclevent_cpdhours as CPD_HOURS,
    B.cclevent_countryidName AS EVENT_COUNTRY,
    B.rics_regionidName AS EVENT_REGION,
    B.Cclevent_MaximumCapacity AS MAX_CAPACITY,
    CASE WHEN b.ActualStart > GETDATE() THEN 1 ELSE 0 END AS FUTURE_EVENT,
    A.Created_On AS BOOKING_DATE,
	CAST(EB.apuk_bookerid  AS nvarchar(40)) AS  [BOOKING_USER_LOCAL_ID]
	,BC.EMailAddress1 as BOOKING_USER_EMAIL
	,EB.BookerName AS BOOKER_NAME
	,BC.Rics_contactno AS BOOKING_USER_RICS_MEMBER_NO


    ,A.cclrv2_attendeecontactid AS ATTENDEE_CONTACT_ID
    	,ATTENDEE_CONTACT.EMailAddress1 AS ATTENDEE_EMAIL
		,ATTENDEE_CONTACT.FullName AS ATTENDEE_NAME
		,ATTENDEE_CONTACT.Rics_contactno AS ATTENDEE_MEMBER_NUMBER
		,ATTENDEE_CONTACT.MemberGrade_Description AS ATTENDEE_MEMBER_GRADE
		,ATTENDEE_CONTACT.Rics_ContactType_Description AS ATTENDEE_CONTACT_TYPE
		,ATTENDEE_CONTACT.rics_pathwaytomembershipidName AS ATTENDEE_PATHWAY
		,ATTENDEE_CONTACT.CurrentAge AS ATTENDEE_AGE
		,ATTENDEE_CONTACT.apuk_designation_description AS ATTENDEE_RICS_DESIGNATION
		,ATTENDEE_CONTACT.GenderCode_Description AS ATTENDEE_GENDER
		,ATTENDEE_CONTACT.Rics_Region AS ATTENDEE_REGION
		,ATTENDEE_CONTACT.rics_countryidName AS ATTENDEE_COUNTRY
		,DATEDIFF(YEAR,ATTENDEE_CONTACT.Rics_ElectionDate,GETDATE()) AS ATTENDEE_YEARS_QUALIFIED

	,1 as QUANTITY
    ,Cclevent_Valuegross AS TOTAL_COST_LOCAL_CURRENCY,
    Net_Value AS NET_COST_LOCAL_CURRENCY,
    (Cclevent_Valuegross-Net_Value) AS TAX_COST_LOCAL_CURRENCY,
	0 as FEES_COST_LOCAL_CURRENCY,
    'GBP' AS CURRENCY,
    Cclevent_Valuegross AS TOTAL_COST_GBP,
    Net_Value AS NET_COST_GBP,
    (Cclevent_Valuegross-Net_Value) AS TAX_COST_GBP,
	0 as FEES_COST_GBP,
    CAST(a.apuk_salesorderid AS nvarchar(124)) AS ORDER_ID
	,right(SO.OrderNumber,len(SO.OrderNumber)-3) AS ORDER_NUMBER
    ,CAST(a.apuk_eventbookingid AS nvarchar(124)) AS BOOKING_ID,
    CAST(A.CampaignResponse_Key AS nvarchar(124)) AS CAMPAIGN_RESPONSE_KEY
	,concat(B.name,cast(b.ActualStart AS date)) as name_date_key

FROM CE.vwCampaign AS B

LEFT JOIN  [CE].[vwCampaignResponse] AS A 
ON B.CampaignId = A.RegardingObjectId
and A.Registration_Status = 'Confirmed'

INNER JOIN CE.vwEventBooking AS EB
ON A.apuk_eventbookingid = EB.apuk_eventbookingid

LEFT join ce.vwSalesOrder AS SO
ON A.apuk_salesorderid = SO.SalesOrderId


LEFT JOIN CE.vwContact AS ATTENDEE_CONTACT
ON A.cclrv2_attendeecontactid = ATTENDEE_CONTACT.ContactId
AND ATTENDEE_CONTACT.StateCode = 0
AND ATTENDEE_CONTACT.Rics_LapsedCode IS NULL

LEFT JOIN CE.vwContact AS BC
ON EB.apuk_bookerid = BC.ContactId
AND BC.StateCode = 0
AND BC.Rics_LapsedCode IS NULL


left join ce.vwAccount as ACCOUNT
on ATTENDEE_CONTACT.AccountId = ACCOUNT.AccountId

WHERE b.ActualStart >= '2020-01-01';
