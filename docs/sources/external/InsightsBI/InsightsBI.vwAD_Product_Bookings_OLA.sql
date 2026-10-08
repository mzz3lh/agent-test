CREATE VIEW InsightsBI.vwAD_Product_Bookings_OLA
AS
select
distinct 
'OLA' AS SOURCE_PLATFORM
,fdcp.bundle AS PRODUCT_TYPE
--,NULL AS PRODUCT_GROUP
,cp.type AS EVENT_TYPE
,cp.title AS COURSE_NAME
,CAST(cp.product_id AS nvarchar(40)) AS EVENT_ID
--,NULL AS RICS_EVENTCODE
,CAST(cp.sku AS NVARCHAR(40)) AS SKU_CODE
,CAST(mc.startdate AS DATE) EVENT_START_DATE
,mc.enddate AS EVENT_END_DATE
--CPD_HOURS
--EVENT_COUNTRY
--EVENT_REGION
--MAX_CAPACITY
--FUTURE_EVENT
,cocli.created AS BOOKING_DATE
,CAST(cocli.uid AS nvarchar(40)) AS BOOKING_USER_LOCAL_ID
,cocli.mail AS BOOKING_USER_EMAIL
,BOOKER.Rics_contactno AS BOOKING_USER_RICS_MEMBER_NO
,BOOKER.FullName AS BOOKER_NAME
--,mu.id as ATTENDEE_USER_LOCAL_ID
--,mu.email AS ATTENDEE_EMAIL
--, attendee.ContactId AS ATTENDEE_CONTACT_ID
--, attendee.FullName AS ATTENDEE_NAME
--, attendee.Rics_contactno AS ATTENDEE_MEMBER_NUMBER
--, attendee.MemberGrade_Description AS ATTENDEE_MEMBER_GRADE
--, attendee.Rics_ContactType_Description AS ATTENDEE_CONTACT_TYPE
--, attendee.rics_pathwaytomembershipidName AS ATTENDEE_PATHWAY
--, attendee.CurrentAge AS ATTENDEE_AGE
--, attendee.apuk_designation_description AS ATTENDEE_RICS_DESIGNATION
--, attendee.GenderCode_Description AS ATTENDEE_GENDER
--, attendee.Rics_Region AS ATTENDEE_REGION
--, attendee.rics_countryidName AS ATTENDEE_COUNTRY
-- AS ATTENDEE_YEARS_QUALIFIED
,cli.quantity as  TOTAL_QUANTITY_BOOKED
,ct.commerce_total_amount*0.01 AS TOTAL_COST_LOCAL_CURRENCY
--NET_COST_LOCAL_CURRENCY
--TAX_COST_LOCAL_CURRENCY
--FEES_COST_LOCAL_CURRENCY
,ct.commerce_total_currency_code AS CURRENCY
--TOTAL_COST_GBP
--NET_COST_GBO
--TAX_COST_GBP
--FEES_COST_GBP
, cocli.order_number AS ORDER_ID
--BOOKING_ID
--CAMPAIGN_RESPONSE_KEY
--NAME_DATE_KEY

from Drupal.commerce_product cp


LEFT JOIN 
    drupal.field_data_commerce_product fdcp
	ON fdcp.commerce_product_product_id = cp.product_id

LEFT JOIN drupal.commerce_line_item cli
	ON cli.line_item_id = fdcp.entity_id 
	AND fdcp.entity_type = 'commerce_line_item' 
	AND fdcp.deleted = 0

INNER JOIN 
    drupal.commerce_order cocli 
	ON cli.order_id = cocli.order_id

INNER JOIN 
    drupal.field_data_commerce_total AS ct 
	ON ct.entity_id = cli.line_item_id 
    AND ct.entity_type = 'commerce_line_item'

LEFT JOIN Moodle.mdl_course mc
	ON cp.sku = mc.shortname

LEFT JOIN Ce.vwContact BOOKER 
	ON cocli.mail = BOOKER.emailaddress1


--LEFT JOIN Moodle.mdl_user mu
--	ON cocli.mail = mu.email

--LEFT JOIN Moodle.mdl_user_enrolments mue
--	ON mu.id = mue.userid
	

--LEFT JOIN Moodle.mdl_enrol me
--	ON mc.id = me.courseid
--	AND mue.enrolid = me.id

--LEFT JOIN ce.vwContact ATTENDEE 
--	ON mu.email = ATTENDEE.EMailAddress1


and cocli.status = 'invoiced'
