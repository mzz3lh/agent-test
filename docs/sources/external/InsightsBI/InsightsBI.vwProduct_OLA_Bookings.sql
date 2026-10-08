/***************************************************************************************************
Query Name:			OLA Bookings
Procedure:          N/A
Create Date:        2024-11-08
Author:             Alexandra Duston
Description:        This is one of the background tables that makes up the product booking report.
I need to sort out a single source of truth of products before i can 100% replicate gratiane's booking report

The goal is to have a single source of truth product catalouge

and then from that have all the bookings

all the registrations

and then at a member level - what engagement do we have

We have to do this for OLA, GTW, YooPay, 
For conferences we have to do something weird - need to look into
CE, Eventbrite, Explara, Conversions, Sponsorship, Packages in CE

****************************************************************************************************
SUMMARY OF CHANGES
Date(yyyy-mm-dd)    Author              Comments
------------------- ------------------- ------------------------------------------------------------

***************************************************************************************************/

CREATE VIEW InsightsBI.vwProduct_OLA_Bookings AS

SELECT
cpfd.title AS COURSE_NAME
,cpfd.sku AS COURSE_SHORT_NAME
,SKU AS SKU
,fprcp.type as event_type
,CAST(startdate AS DATE) AS Event_Date
,cli.order_id
,order_number
,quantity
,cli.created as order_created_date
,placed as order_placed_date
,uco.uid 
,uco.mail 
,CONVERT(DECIMAL(7,2), (commerce_total_amount/100.00))  AS LOCAL_CURRENCY_AMOUNT
,commerce_total_currency_code AS LOCAL_CURRENCY_CODE


FROM 
    drupal.commerce_line_item cli

INNER JOIN 
    drupal.commerce_order cocli 
	ON cli.order_id = cocli.order_id

LEFT JOIN Drupal.field_data_commerce_total CT
	ON CT.entity_id = cli.line_item_id

LEFT JOIN 
    sharedstore.users uco 
	ON cocli.uid = uco.uid

LEFT JOIN 
    drupal.field_data_commerce_product fdcp 
	ON cli.line_item_id = fdcp.entity_id 
	AND fdcp.entity_type = 'commerce_line_item' 
	AND fdcp.deleted = 0

LEFT JOIN 
    drupal.commerce_product cpfd 
	ON fdcp.commerce_product_product_id = cpfd.product_id

LEFT JOIN 
    sharedstore.field_data_field_country ucofc 
	ON uco.uid = ucofc.entity_id 
	AND ucofc.entity_type = 'user' 
	AND ucofc.deleted = 0

LEFT JOIN 
    drupal.countries_country cc 
	ON ucofc.field_country_iso2 = cc.iso2

LEFT JOIN 
    drupal.field_data_field_product_reference cpfd_fr 
	ON cpfd.product_id = cpfd_fr.field_product_reference_product_id

LEFT JOIN 
    drupal.node fprcp ON cpfd_fr.entity_id = fprcp.nid

LEFT JOIN 
    drupal.field_data_field_commerce_billy_i_date cocli_fdcbid 
	ON cocli.order_id = cocli_fdcbid.entity_id 
	AND cocli_fdcbid.entity_type = 'commerce_order' 
	AND cocli_fdcbid.deleted = 0

INNER JOIN 
    drupal.rics_line_items_tally t 
	ON t.n <= cli.quantity

LEFT JOIN moodle.mdl_course MC
	ON Mc.shortname = cpfd.sku

WHERE  cli.type IN ('product') 
AND cocli.status = 'invoiced'
AND lower(cpfd.title) NOT LIKE '%test%'
