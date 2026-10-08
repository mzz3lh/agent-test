CREATE VIEW InsightsBI.vwAD_PRODUCT_BOOKINGS_EVENTBRITE AS 

SELECT 
		'Eventbrite' AS SOURCE_PLATFORM
		, case  WHEN a.[Event Name] LIKE '%Award%' then 'Awards'
		else 'Conference' end AS PRODUCT_TYPE
		, CAST(NULL AS NVARCHAR(124)) AS PRODUCT_GROUP
		, CASE WHEN A.[Is Online Event] = 'Yes' THEN 'Online'
			
			ELSE 'Face to Face'
			END AS EVENT_TYPE
		, CAST(A.[Event Name] AS nvarchar(124)) AS COURSE_NAME 
		, CAST(A.[Event Id] AS nvarchar) AS EVENT_ID 
		,'' AS RICS_EVENTCODE
		, CAST(NULL AS nvarchar(40)) AS SKU_CODE
		, A.[Start Date] AS EVENT_START_DATE
		, A.[End Date] AS EVENT_END_DATE
		, DATEDIFF(DAY, A.[Start Date], A.[End Date])+1  AS EVENT_LENGTH
		,NULL as CPD_HOURS
		, COUNTRY.apuk_name AS EVENT_COUNTRY
		, c.Organization AS EVENT_REGION
		, a.Capacity AS MAX_CAPACITY
		, CASE WHEN A.[Start Date] > GETDATE() THEN 1 ELSE 0 END AS FUTURE_EVENT
		, d.Createdon AS BOOKING_DATE

		,cast(d.Attendee_Id AS Nvarchar(40)) AS BOOKING_USER_LOCAL_ID
		,d.[Profile Email] as BOOKING_USER_EMAIL
		, BOOKER_CONTACT.ContactId AS BOOKING_USER
		,BOOKER_CONTACT.FullName AS BOOKER_NAME
		,BOOKER_CONTACT.Rics_contactno AS BOOKING_USER_RICS_MEMBER_NO

		,ATTENDEE_CONTACT.ContactId AS ATTENDEE_CONTACT_ID
		, d.[Profile Email] AS ATTENDEE_EMAIL
		,d.[Profile Name] AS ATTENDEE_NAME
		,ATTENDEE_CONTACT.Rics_contactno AS ATTENDEE_MEMBER_NUMBER
		,ATTENDEE_CONTACT.MemberGrade_Description AS ATTENDEE_MEMBER_GRADE
		,ATTENDEE_CONTACT.Rics_ContactType_Description AS ATTENDEE_CONTACT_TYPE
		,ATTENDEE_CONTACT.rics_pathwaytomembershipidName AS ATTENDEE_PATHWAY
		,d.[Profile Age] as ATTENDEE_AGE
		,ATTENDEE_CONTACT.apuk_designation_description AS ATTENDEE_RICS_DESIGNATION
		,d.[Profile Gender] as ATTENDEE_GENDER
		,ATTENDEE_CONTACT.Rics_Region AS ATTENDEE_REGION
		,ATTENDEE_CONTACT.rics_countryidName AS ATTENDEE_COUNTRY
		,DATEDIFF(YEAR,ATTENDEE_CONTACT.Rics_ElectionDate,GETDATE()) AS ATTENDEE_YEARS_QUALIFIED

		,1 as QUANTITY
		, D.[Cost Gross Fee] AS TOTAL_COST_LOCAL_CURRENCY
		, D.[Cost Base Fee] AS NET_COST_LOCAL_CURRENCY
		, D.[Cost Tax Fee] AS TAX_COST_LOCAL_CURRENCY
		, D.[Cost Eventbrite Fee] AS  FEES_COST_LOCAL_CURRENCY
		
		, D.[Cost Base Currency Code] AS CURRENCY


		, D.[Cost Gross Fee GBP] AS TOTAL_COST_GBP
		, D.[Cost Base Fee GBP] AS NET_COST_GBP
		, D.[Cost Tax Fee GBP] AS TAX_COST_GBP
		, D.[Cost Eventbrite Fee GBP] AS  FEES_COST_GBP
		
		, CAST(d.Order_Id AS nvarchar(124)) as ORDER_ID
		,'' AS ORDER_NUMBER
		, CAST(D.Order_Id AS nvarchar(124)) as BOOKING_ID
		, CONCAT(D.AttendeeKey,D.OrderKey) AS CAMPAIGN_RESPONSE_KEY
		,concat(a.[Event Name],[Start Date]) as name_date_key
  
  FROM [EventBrite].[vwEvent] as a

  left join  EventBrite.vwCategory as b
  on a.CategoryKey = b.categorykey

  left join  [EventBrite].[vwEventTicketReport] as c
  on CAST(a.[Event Name] AS VARCHAR) = c.[Event Name]

  INNER JOIN EventBrite.vwAttendee AS D
  ON A.EventKey = D.EventKey
  AND D.[Is Cancelled] = 'No'

  left join EventBrite.vwVenue AS V
  ON A.Venue_Id = V.Venue_Id

  LEFT JOIN CE.vwCountry AS COUNTRY 
  ON V.Country = COUNTRY.apuk_code



    	LEFT JOIN CE.vwContact AS BOOKER_CONTACT
	ON  d.[Profile Email] = BOOKER_CONTACT.EMailAddress1
	AND BOOKER_CONTACT.StateCode = 0
	AND BOOKER_CONTACT.Rics_LapsedCode IS NULL 

	LEFT JOIN CE.vwContact AS ATTENDEE_CONTACT
	ON d.[Profile Email] = ATTENDEE_CONTACT.EMailAddress1
	AND ATTENDEE_CONTACT.StateCode = 0
	AND ATTENDEE_CONTACT.Rics_LapsedCode IS NULL

	  WHERE [Start Date] >= '2020-01-01'
	  and d.[Profile Email] is not null
