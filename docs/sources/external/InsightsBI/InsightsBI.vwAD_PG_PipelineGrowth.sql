-- Altering the view InsightsBI.vwPipelineGrowth to include enrolments, assessments, and additional contact and group information
CREATE VIEW [InsightsBI].[vwAD_PG_PipelineGrowth] AS

-- Common Table Expressions (CTEs) to pull raw data from views
WITH enrolments AS (
    SELECT 
        [ENR ID],
        [Enrolment Name],
        [Created Datetime],
        [Created Date],
        [Created By],
        [End Date],
        [Application Type ID],
        [Application Type],
        [Contact No],
        [Contact ID],
        [Election Date],
        [Enrolment Date],
        [Enrolment Year],
        [Number of Attempts],
        [Expected Final Date],
        [Enrolment Local Group ID],
        [Pathway ID],
        [Pathway],
        [Route ID],
        [Route],
        [Enrolment Type ID],
        [Enrolment Type],
        [Outcome ID],
        [Outcome],
        [State Code],
        [State],
        [Status Code],
        [Status],
        [apuk_ricsrecordid],
        [ARC Assessment Status],
        [Approved By Counsellor],
        [Competency Selection Completed Date],
        [Case Study Status],
        [Case Study Feedback],
        [Summary of Experience Status],
        [Summary of Experience Feedback],
        [Preliminary Submission Received],
        [Submission Received]
    FROM ce.vwEnrolments_Valid_First
),

LatestAssessment AS (
    SELECT 
        a.[Id],
        a.[statecode],
        a.[statuscode],
        a.[apuk_chairmanresult],
        a.[apuk_assessmentmethod],
        a.[apuk_finaloutcome],
        a.[apuk_assessmenttype],
        a.[apuk_resultapproved],
        a.[apuk_candidateid],
        a.[apuk_enrolmentid],
        a.[apuk_resultapprovedon],
        a.[apuk_assessmentid],
        a.[createdon],
        a.[apuk_dateresultissued],
        b.LocalizedLabel AS statusdesc,
        c.LocalizedLabel AS chairmanresultdesc,
        d.LocalizedLabel AS assessmentmethoddesc,
        e.LocalizedLabel AS finaloutcomedesc,
        f.LocalizedLabel AS assessmenttypedesc,
        ROW_NUMBER() OVER (PARTITION BY a.apuk_enrolmentid ORDER BY a.createdon DESC) AS rn
    FROM [synapse_ce].[apuk_assessment] AS a
    LEFT JOIN [synapse_ce].[StatusMetadata] AS b
        ON a.statuscode = b.Status
        AND b.EntityName = 'apuk_assessment'
    LEFT JOIN synapse_ce.GlobalOptionSetMetadata AS c
        ON a.apuk_chairmanresult = c.[Option]
        AND c.optionsetname = 'apuk_chairmanresult'
    LEFT JOIN synapse_ce.GlobalOptionSetMetadata AS d
        ON a.apuk_assessmentmethod = d.[Option]
        AND d.optionsetname = 'apuk_assessmentmethod'
    LEFT JOIN synapse_ce.GlobalOptionSetMetadata AS e
        ON a.apuk_finaloutcome = e.[Option]
        AND e.optionsetname = 'apuk_finaloutcome'
    LEFT JOIN synapse_ce.GlobalOptionSetMetadata AS f
        ON a.apuk_assessmenttype = f.[Option]
        AND f.optionsetname = 'apuk_assessmenttype'
),

Assessments AS (
    SELECT
        a.[Id],
        a.[statecode],
        a.[statuscode],
        a.[apuk_chairmanresult],
        a.[apuk_assessmentmethod],
        a.[apuk_finaloutcome],
        a.[apuk_assessmenttype],
        a.[apuk_resultapproved],
        a.[apuk_candidateid],
        a.[apuk_enrolmentid],
        a.[apuk_resultapprovedon],
        a.[apuk_assessmentid],
        a.[createdon] AS assessment_created_on,
        a.[apuk_dateresultissued],
        CASE 
            WHEN a.statecode = 0 THEN 'Active' 
            WHEN a.statecode = 1 THEN 'Inactive'
            ELSE NULL 
        END AS State_Desc,
        b.LocalizedLabel AS statusdesc,
        c.LocalizedLabel AS chairmanresultdesc,
        d.LocalizedLabel AS assessmentmethoddesc,
        e.LocalizedLabel AS finaloutcomedesc,
        f.LocalizedLabel AS assessmenttypedesc
    FROM LatestAssessment AS a
    LEFT JOIN [synapse_ce].[StatusMetadata] AS b
        ON a.statuscode = b.Status
        AND b.EntityName = 'apuk_assessment'
    LEFT JOIN synapse_ce.GlobalOptionSetMetadata AS c
        ON a.apuk_chairmanresult = c.[Option]
        AND c.optionsetname = 'apuk_chairmanresult'
    LEFT JOIN synapse_ce.GlobalOptionSetMetadata AS d
        ON a.apuk_assessmentmethod = d.[Option]
        AND d.optionsetname = 'apuk_assessmentmethod'
    LEFT JOIN synapse_ce.GlobalOptionSetMetadata AS e
        ON a.apuk_finaloutcome = e.[Option]
        AND e.optionsetname = 'apuk_finaloutcome'
    LEFT JOIN synapse_ce.GlobalOptionSetMetadata AS f
        ON a.apuk_assessmenttype = f.[Option]
        AND f.optionsetname = 'apuk_assessmenttype'
    WHERE a.rn = 1
)

-- Final select statement combining enrolments, assessments, and additional information from contact and local group tables
SELECT 
    e.[ENR ID],
    e.[Enrolment Name],
    e.[Created Datetime],
    e.[Created Date],
    e.[Created By],
    e.[End Date],
    e.[Application Type ID],
    e.[Application Type],
    e.[Contact No],
    e.[Contact ID],
    e.[Election Date],
    e.[Enrolment Date],
    e.[Enrolment Year],
    e.[Number of Attempts],
    e.[Expected Final Date],
    e.[Enrolment Local Group ID],
    e.[Pathway ID],
    e.[Pathway],
    e.[Route ID],
    e.[Route],
    e.[Enrolment Type ID],
    e.[Enrolment Type],
    e.[Outcome ID],
    e.[Outcome],
    e.[State Code],
    e.[State],
    e.[Status Code],
    e.[Status],
    e.[apuk_ricsrecordid],
    e.[ARC Assessment Status],
    e.[Approved By Counsellor],
    e.[Competency Selection Completed Date],
    e.[Case Study Status],
    e.[Case Study Feedback],
    e.[Summary of Experience Status],
    e.[Summary of Experience Feedback],
    e.[Preliminary Submission Received],
    e.[Submission Received],
    YEAR(e.[Election Date]) AS Election_Year,
    MONTH(e.[Election Date]) AS Election_Month,
    MONTH(e.[Enrolment Date]) AS Enrolment_Month,
    CASE WHEN e.[Election Date] IS NOT NULL THEN 1 ELSE 0 END AS Elected_Flag,
    CASE WHEN e.[Submission Received] IS NOT NULL THEN 1 ELSE 0 END AS Submission_Flag,
    YEAR(e.[Submission Received]) AS Submission_Year,
    MONTH(e.[Submission Received]) AS Submission_Month,
    a.[Id] AS Assessment_Id,
    a.[statecode] AS Assessment_Statecode,
    a.State_Desc AS Assessment_State_Desc,
    a.[statuscode] AS Assessment_Statuscode,
    a.statusdesc AS Assessment_Status_Desc,
    a.[apuk_chairmanresult] AS Assessment_Chairmanresult,
    a.chairmanresultdesc AS Assessment_Chairmanresultdesc,
    a.[apuk_assessmentmethod] AS Assessment_Assessmentmethod,
    a.assessmentmethoddesc AS Assessment_Assessmentmethoddesc,
    a.[apuk_finaloutcome] AS Assessment_Finaloutcome,
    a.finaloutcomedesc AS Assessment_Finaloutcomedesc,
    a.[apuk_assessmenttype] AS Assessment_Assessmenttype,
    a.assessmenttypedesc AS Assessment_Assessmenttypedesc,
    a.[apuk_resultapproved] AS Assessment_Resultapproved,
    a.[apuk_candidateid] AS Assessment_Candidateid,
    a.[apuk_enrolmentid] AS Assessment_Enrolmentid,
    a.[apuk_resultapprovedon] AS Assessment_Resultapprovedon,
    a.[apuk_assessmentid] AS Assessment_Assessmentid,
    a.assessment_created_on AS Assessment_Created_on,
    a.[apuk_dateresultissued] AS Assessment_Dateresultissued,
    c.Rics_LapsedDate,
    lg.apuk_regionid_name AS region,
    lg.apuk_worldregionid_name AS world_region,
    lg.apuk_countryid_name AS country,
    lg.apuk_name AS local_group
FROM enrolments AS e
LEFT JOIN Assessments AS a
    ON e.[ENR ID] = a.apuk_enrolmentid
LEFT JOIN ce.vwContact AS c
    ON e.[Contact ID] = c.contactid
LEFT JOIN [synapse_ce].[vwLocalGroup] AS lg
    ON e.[Enrolment Local Group ID] = lg.apuk_localgroupid
