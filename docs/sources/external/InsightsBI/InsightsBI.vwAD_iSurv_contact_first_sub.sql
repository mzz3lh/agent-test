CREATE view insightsbi.vwAD_iSurv_contact_first_sub AS
WITH MINSUB  AS (select 
[Contact No.]
,min([Sub Start Date]) as first_sub_date
,month(min([Sub Start Date])) as first_sub_month
,year(min([Sub Start Date])) as first_sub_year

from isurv.vwIsurv_Subscription


group by [Contact No.])

SELECT
SUB.*
,CASE
		WHEN MINSUB.[Contact No.] IS NOT NULL THEN 1 
		ELSE 0
		END AS FIRST_SUB_FLAG
FROM isurv.vwIsurv_Subscription AS SUB
LEFT JOIN MINSUB 
ON SUB.[Contact No.] = MINSUB.[Contact No.]
AND SUB.[Sub Start Date] = MINSUB.first_sub_date
