/*
Alexandra Durston - June 2024
What does this code do?
Date range all events since 01/01/2023

*/

CREATE VIEW insightsbi.vwAD_RTF_ALL_PRODUCT_BOOKINGS AS

/*
Columns:
Source Platform (eg OLA, CE)
Product Type (eg Webinar, Training course)
Product Group (eg DRS, Regs)
Event Type (eg Face to Face, Online)
Course Name
EVENT ID
SKU
Event Start Date
Event End Date
Event Length
Event country
Event Region
Max Capacity
Future event?
Booking Date
Booker ID
Booker Member number
Booker email
Booker Member Grade
Booker Member Pathway
Booker Segment
Booker Account number
Booker Firm number
Booker Org Segment
Booker local group
Booker country
Booker Region
BOOKED_ON_BEHALF_OF_SELF
BOOKED_ON_BEHALF_OF_OTHER
Attendee ID
Attendee member number
Attendee email
Attendee Member Grade
Attendee Member Pathway
Attendee Segment
Attendee Account number
Attendee Firm number
Attendee Org Segment
Attendee Local group
Attendee Country
Attendee Region
TOTAL_COST_LOCAL_CURRENCY
NET_COST_LOCAL_CURRENCY
TAX_COST_LOCAL_CURRENCY
CURRENCY
TOTAL_COST_GBP
NET_COST_GBP
TAX_COST_GBP
*/


--OLA data is not reliable yet - we need to get it out of Jadu to trust it


--MASSIVE UNION OF ALL THE DATA SOURCES
--Events that are in CE but sold through Eventbrite
WITH CE_AND_EVENTBRITE_EVENTS AS (
SELECT
		CampaignId
		,NAME 
		,Cclevent_eventid AS CE_EVENTID
		,EventKey
		,[Event Id] AS EB_EVENTID
		,[Start Date]
		,Cclevent_cpdhours
FROM CE.vwCampaign AS C

INNER JOIN EventBrite.vwEvent E
ON CAST(E.[Event Name] AS VARCHAR(124)) = C.Name
AND CAST(C.ActualStart AS DATE) = E.[Start Date]

WHERE StateCode = 0

)

--CE only events

	SELECT 
	CE.*

	FROM InsightsBI.vwAD_CE_Product_Bookings AS CE
	
	LEFT JOIN CE_AND_EVENTBRITE_EVENTS CE_EB
	ON CE.EVENT_ID = CE_EB.CE_EVENTID
	WHERE CE_EB.CE_EVENTID IS NULL
	
--GTW

--Yoopay


UNION ALL
--eventbrite only events
SELECT 
		[SOURCE_PLATFORM]
      ,[PRODUCT_TYPE]
      ,[PRODUCT_GROUP]
      ,[EVENT_TYPE]
      ,[COURSE_NAME]
      ,[EVENT_ID]
	  ,CE_EB.CE_EVENTID AS RICS_EVENTCODE
      ,[SKU_CODE]
      ,[EVENT_START_DATE]
      ,[EVENT_END_DATE]
      ,[EVENT_LENGTH]
      ,CE_EB.Cclevent_cpdhours AS [CPD_HOURS]
      ,[EVENT_COUNTRY]
      ,[EVENT_REGION]
      ,[MAX_CAPACITY]
      ,[FUTURE_EVENT]
      ,[BOOKING_DATE]
      ,[Booking_User]
      ,[BOOKER_NAME]
      ,[ATTENDEE_CONTACT_ID]
      ,[ATTENDEE_EMAIL]
      ,[ATTENDEE_NAME]
      ,[ATTENDEE_MEMBER_NUMBER]
      ,[ATTENDEE_MEMBER_GRADE]
      ,[ATTENDEE_CONTACT_TYPE]
      ,[ATTENDEE_PATHWAY]
      ,[ATTENDEE_AGE]
      ,[ATTENDEE_RICS_DESIGNATION]
      ,[ATTENDEE_GENDER]
      ,[ATTENDEE_REGION]
      ,[ATTENDEE_COUNTRY]
      ,[ATTENDEE_YEARS_QUALIFIED]
      ,[TOTAL_COST_LOCAL_CURRENCY]
      ,[NET_COST_LOCAL_CURRENCY]
      ,[TAX_COST_LOCAL_CURRENCY]
      ,[FEES_COST_LOCAL_CURRENCY]
      ,[CURRENCY]
      ,[TOTAL_COST_GBP]
      ,[NET_COST_GBP]
      ,[TAX_COST_GBP]
      ,[FEES_COST_GBP]
      ,[ORDER_ID]
      ,[ORDER_NUMBER]
      ,[BOOKING_ID]
      ,[CAMPAIGN_RESPONSE_KEY]
      ,[name_date_key]

FROM InsightsBI.vwAD_PRODUCT_BOOKINGS_EVENTBRITE AS EB
LEFT JOIN CE_AND_EVENTBRITE_EVENTS CE_EB
	ON EB.EVENT_ID = CE_EB.EB_EVENTID
	

--explara

--sponsorship

--account details
