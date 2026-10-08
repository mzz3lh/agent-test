/***************************************************************************************************
Query Name:			All Product Catalogue
Procedure:          InsightsBI.vwProduct_Catalogue
Create Date:        2024-11-11
Author:             Alexandra Duston
Description:        The goal is to have a single source of truth product catalouge

and then from that have all the bookings

all the registrations

and then at a member level - what engagement do we have

We have to do this for OLA, GTW, YooPay, 
For conferences we have to do something weird - need to look into
CE, Eventbrite, Explara, Conversions, Sponsorship, Packages in CE

For this piece of code, I want to replicate as much of the Monday.com board as I can to build a single source of truth product catalogue

****************************************************************************************************
SUMMARY OF CHANGES
Date(yyyy-mm-dd)    Author              Comments
------------------- ------------------- ------------------------------------------------------------

***************************************************************************************************/

CREATE VIEW InsightsBI.vwProduct_Catalogue AS

select
Sku
,title
,'OLA' AS booking_platform
,type as product_type
from Drupal.commerce_product
