CREATE VIEW CE.vwAssessment
AS
select

A.apuk_assessmentid
,A.apuk_assessmentmethod AS ASSESSMENT_METHOD_ID
,M_assessmentmethod.LocalizedLabel AS ASSESSMENT_METHOD
,A.apuk_assessmenttype AS ASSESSMENT_TYPE_ID
,M_apuk_assessmenttype.LocalizedLabel AS ASSESSMENT_TYPE
,A.apuk_datetime 
,A.apuk_finaloutcome AS FINAL_OUTCOME_ID
,M_apuk_finaloutcome.LocalizedLabel AS FINAL_OUTCOME
,A.apuk_dateresultissued AS DATE_RESULT_ISSUED
,A.createdon
,A.createdby as CREATEDBY_ID
,A.apuk_chairmanresultsreceiveddate
,A.apuk_resultlastupdatedbyid
,A.apuk_resultapprovedon
,A.apuk_resultapprovedby
,A.apuk_chairmanid
,E.apuk_contactid
,E.apuk_routeid
,E.apuk_pathwayid
,E.apuk_applicationtypeid
,E.apuk_ricsrecordid
,E.apuk_enrolmentenddate
,E.apuk_enrolmentdate
,E.apuk_electiondate
,C.lastname
,C.firstname
,C.apuk_membergrade
,C.apuk_contactnumber
,C.apuk_localgroupid
,C.gendercode
,C.apuk_genderidentity
,C.apuk_preferredaddresscountryid
,C.apuk_region

from [synapse_ce].[apuk_assessment] A

left join synapse_ce.apuk_enrolment E
ON A.apuk_enrolmentid = E.apuk_enrolmentid

left join synapse_ce.contact C
ON C.contactid = A.apuk_candidateid

left join synapse_ce.globaloptionsetmetadata M_assessmentmethod
ON M_assessmentmethod.GlobalOptionSetName = 'apuk_assessmentmethod'
and M_assessmentmethod.EntityName = 'apuk_assessment'
AND M_assessmentmethod.[Option] = A.apuk_assessmentmethod

left join synapse_ce.globaloptionsetmetadata M_apuk_assessmenttype
ON M_apuk_assessmenttype.OptionSetName = 'apuk_assessmenttype'
and M_apuk_assessmenttype.EntityName = 'apuk_assessment'
AND M_apuk_assessmenttype.[Option] = A.apuk_assessmenttype

left join synapse_ce.globaloptionsetmetadata M_apuk_finaloutcome
ON M_apuk_finaloutcome.OptionSetName = 'apuk_finaloutcome'
and M_apuk_finaloutcome.EntityName = 'apuk_assessment'
AND M_apuk_finaloutcome.[Option] = A.apuk_finaloutcome


where A.statecode = 0
and A.apuk_assessmentmethod <> 200000003
and A.apuk_assessmentmethod <> 200000004
and A.apuk_assessmenttype IN (200000000, 200000008, 200000006)
and E.apuk_applicationtypeid <> '00000000-0000-0000-0000-000000000000'
and E.apuk_applicationtypeid <> '00000000-0000-0000-0000-000000000000'
and E.apuk_applicationtypeid <> '00000000-0000-0000-0000-000000000000'
and E.apuk_routeid <> '00000000-0000-0000-0000-000000000000'
--and year(a.apuk_datetime) = 2024
--and a.apuk_datetime between '2024-01-01' and '2024-06-30'
