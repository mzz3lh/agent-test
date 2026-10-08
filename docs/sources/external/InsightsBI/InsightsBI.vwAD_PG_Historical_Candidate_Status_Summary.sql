-- Altering the view InsightsBI.vwHistorical_Candidate_Status_Summary to include enrolments, elections, and lapses
CREATE VIEW InsightsBI.vwAD_PG_Historical_Candidate_Status_Summary AS

-- Common Table Expression (CTE) to pull all necessary data from PipelineGrowth view
WITH aggregated_data AS (
    SELECT
        [ENR ID],
        [Application Type],
        Pathway,
        region,
        world_region,
        country,
        local_group,
        [Enrolment Date],
        [Election Date],
        Rics_LapsedDate
    FROM InsightsBI.vwAD_PG_PipelineGrowth
)

-- Final select statement to join the data with the calendar and perform aggregation
SELECT
    a.[Date],  -- Calendar date
    b.[Application Type],  -- Application type
    b.Pathway,  -- Pathway
    b.region,  -- Region
    b.world_region,  -- World region
    b.country,  -- Country
    b.local_group,  -- Local group
    COUNT(DISTINCT CASE WHEN b.[Enrolment Date] = a.[Date] THEN b.[ENR ID] END) AS enrolments,  -- Count distinct enrolments by date
    COUNT(DISTINCT CASE WHEN b.[Election Date] = a.[Date] THEN b.[ENR ID] END) AS elections,  -- Count distinct elections by date
    COUNT(DISTINCT CASE WHEN b.Rics_LapsedDate = a.[Date] THEN b.[ENR ID] END) AS lapses  -- Count distinct lapses by date
FROM bi.vwCalendarFull AS a  -- Full calendar view
LEFT JOIN aggregated_data AS b
    ON a.[Date] = b.[Enrolment Date]
    OR a.[Date] = b.[Election Date]
    OR a.[Date] = b.Rics_LapsedDate
GROUP BY 
    a.[Date],
    b.[Application Type],
    b.Pathway,
    b.region,
    b.world_region,
    b.country,
    b.local_group
