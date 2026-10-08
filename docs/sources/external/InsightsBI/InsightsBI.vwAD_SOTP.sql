/***************************************************************************************************
Query Name:			SOTP Data
Procedure:          InsightsBI.vwMWM_SOTP
Create Date:        2024-11-08
Author:             Alexandra Duston
Description:        
****************************************************************************************************
SUMMARY OF CHANGES
Date(yyyy-mm-dd)    Author              Comments
------------------- ------------------- ------------------------------------------------------------

***************************************************************************************************/


-- Create or Alter View to Aggregate SOTP KPI Data
CREATE VIEW [InsightsBI].vwAD_SOTP AS

-- Common Table Expression (CTE) for SOTP Waves
WITH all_sotp_waves AS (

 SELECT 
        2024 AS Year,
        'Wave 25' AS Wave,
        responseid,
        RespondentId AS respondentid,
        NULL AS date_filled_in,
        S1New AS Sector,
        s2 AS org_size,
        s3 AS experience,
        s4 AS gender,
        [Local group],
		[World region],
		Country,
        [member grade] AS member_grade_description,

		Q6_3 AS INFLUENCE_ECONOMICS_MARKET_ANALYSIS,
		Q6_2 AS INFLUENCE_RESEARCH_INSIGHTS,
		Q6_4 AS INFLUENCE_SUSTAINABILITY,
		Q6_1 AS INFLUENCE_DIVERSITY_INCLUSION,
		Q6_8 AS INFLUENCE_DATA_TECH,
		Q5_1 AS INFLUENCE_RECOGNITION_ADOPTION,
		Q5_3 AS INFLUENCE_EXPERT_ADVICE,
		Q5_2 AS INFLUENCE_PUBLIC_POLICY,

		Q6_6 AS TRUST_REGULATION_PROFESSIONALISM,
		Q6_5 AS TRUST_REGULATION_PUBLIC_TRUST,
		Q6_7 AS TRUST_PROFESSION_STATUS_RECOGNITION,
		Q5_4 AS TRUST_MAINTAINING_QUALIFICATIONS_STANDARDS,
		Q5_5 AS TRUST_ASSURANCE_STANDARDS,
		Q5_6 AS TRUST_PROFESSIONAL_DEVELOPMENT,

		Q13 AS CSAT_Rating

    FROM sotp.tblsotp_answers_2024_w25

	UNION ALL

	 SELECT 
        2024 AS Year,
        'Wave 26' AS Wave,
        responseid,
        RespondentId AS respondentid,
        NULL AS date_filled_in,
        S1New AS Sector,
        s2 AS org_size,
        s3 AS experience,
        s4 AS gender,
        DummyMarket AS [Local group],
		DUMMYWORLDREGION AS [World region],
		Panel_respondent_data_1 as Country,
        QDUMMYMemberGrade AS member_grade_description,

		Q6_3 AS INFLUENCE_ECONOMICS_MARKET_ANALYSIS,
		Q6_2 AS INFLUENCE_RESEARCH_INSIGHTS,
		Q6_4 AS INFLUENCE_SUSTAINABILITY,
		Q6_1 AS INFLUENCE_DIVERSITY_INCLUSION,
		Q6_8 AS INFLUENCE_DATA_TECH,
		Q5_1 AS INFLUENCE_RECOGNITION_ADOPTION,
		Q5_3 AS INFLUENCE_EXPERT_ADVICE,
		Q5_2 AS INFLUENCE_PUBLIC_POLICY,

		Q6_6 AS TRUST_REGULATION_PROFESSIONALISM,
		Q6_5 AS TRUST_REGULATION_PUBLIC_TRUST,
		Q6_7 AS TRUST_PROFESSION_STATUS_RECOGNITION,
		Q5_4 AS TRUST_MAINTAINING_QUALIFICATIONS_STANDARDS,
		Q5_5 AS TRUST_ASSURANCE_STANDARDS,
		Q5_6 AS TRUST_PROFESSIONAL_DEVELOPMENT,

		Q13 AS CSAT_Rating

    FROM sotp.tblsotp_answers_2024_w26

),

-- Additional processing logic for all waves
res AS (
    SELECT 
        [year],
        [wave],
        [responseid],
        [respondentid],
        [date_filled_in],
        [sector],
        [org_size],
        [experience],
        [gender],
        [Local group],
		[World region],
		Country,

        CASE
            WHEN [member_grade_description] = 'APC Candidate' THEN 'Candidate'
            WHEN [member_grade_description] = 'Associate Candidate' THEN 'Candidate'
            WHEN [member_grade_description] = 'Associate Member' THEN 'Qualified Professional'
            WHEN [member_grade_description] = 'Fellow' THEN 'Qualified Professional'
            WHEN [member_grade_description] = 'Fellow - Invited' THEN 'Qualified Professional'
            WHEN [member_grade_description] = 'Honorary Member' THEN 'Qualified Professional'
            WHEN [member_grade_description] = 'Professional Member' THEN 'Qualified Professional'
            WHEN [member_grade_description] = 'Professional Member - 2 yrs' THEN 'Qualified Professional - 2 years'
            WHEN [member_grade_description] = 'Professional Member MRICS' THEN 'Qualified Professional'
            ELSE NULL
        END AS [member_grade_description],

        CASE
            WHEN [member_grade_description] = 'APC Candidate' THEN 'Candidate'
            WHEN [member_grade_description] = 'Associate Candidate' THEN 'Candidate'
            WHEN [member_grade_description] = 'Associate Member' THEN 'AssocRICS'
            WHEN [member_grade_description] = 'Fellow' THEN 'FRICS'
            WHEN [member_grade_description] = 'Fellow - Invited' THEN 'FRICS'
            WHEN [member_grade_description] = 'Honorary Member' THEN 'HRICS'
            WHEN [member_grade_description] = 'Professional Member' THEN 'MRICS'
            WHEN [member_grade_description] = 'Professional Member - 2 yrs' THEN 'MRICS'
            WHEN [member_grade_description] = 'Professional Member MRICS' THEN 'MRICS'
            ELSE NULL
        END AS Designation,

		INFLUENCE_ECONOMICS_MARKET_ANALYSIS,
		INFLUENCE_RESEARCH_INSIGHTS,
		INFLUENCE_SUSTAINABILITY,
		INFLUENCE_DIVERSITY_INCLUSION,
		INFLUENCE_DATA_TECH,
		INFLUENCE_RECOGNITION_ADOPTION,
		INFLUENCE_EXPERT_ADVICE,
		INFLUENCE_PUBLIC_POLICY,

		TRUST_REGULATION_PROFESSIONALISM,
		TRUST_REGULATION_PUBLIC_TRUST,
		TRUST_PROFESSION_STATUS_RECOGNITION,
		TRUST_MAINTAINING_QUALIFICATIONS_STANDARDS,
		TRUST_ASSURANCE_STANDARDS,
		TRUST_PROFESSIONAL_DEVELOPMENT,

		CSAT_Rating


 FROM all_sotp_waves
)
SELECT *
FROM res;
