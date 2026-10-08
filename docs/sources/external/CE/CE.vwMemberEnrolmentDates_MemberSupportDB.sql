CREATE   VIEW [CE].[vwMemberEnrolmentDates_MemberSupportDB]
AS
SELECT rics_contactid,rics_contactno ,MIN(rics_enrolmentdate) AS first_enrolmentdate, MAX(rics_enrolmentdate) AS latest_enrolmentdate 
FROM synapse_ce.vwRicsAPC
WHERE rics_contactid IS NOT NULL
GROUP BY rics_contactid, rics_contactno
