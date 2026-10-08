CREATE VIEW insightsBI.vwAD_Member_Age_Reporting AS

WITH years AS (
    SELECT YEAR(GETDATE()) - v.n AS yr
    FROM (VALUES 
        (0),(1),(2),(3),(4),(5),(6),(7),
        (8),(9),(10),(11),(12),(13),(14)
    ) v(n)
),

base AS (
SELECT
    CON.ContactId,
    Y.yr,
    LG.Market_reporting_region,
    DATEDIFF(YEAR, CON.BirthDate, DATEFROMPARTS(Y.yr,12,31)) AS age,

    CASE
        WHEN CON.Rics_LapsedDate IS NOT NULL 
             AND YEAR(CON.Rics_LapsedDate) < Y.yr THEN 'N/A'

        WHEN ED.first_enrolment_date IS NULL 
             OR DATEFROMPARTS(Y.yr,12,31) < ED.first_enrolment_date THEN 'N/A'

        WHEN RR.apuk_datequalified IS NULL 
             OR DATEFROMPARTS(Y.yr,12,31) < RR.apuk_datequalified THEN 'Candidate'

        WHEN RD.first_retired_date IS NULL 
             OR DATEFROMPARTS(Y.yr,12,31) < RD.first_retired_date THEN 'Qualified'

        ELSE 'Retired'
    END AS status,

    ED.first_enrolment_date,
    RR.apuk_datequalified,
    CASE 
                WHEN ([Application Type] = 'Recognised Professional Qualification'
                     OR route = 'Associate RPQ')
                THEN 'RPQ Member'
        ELSE 'Non-RPQ' END AS RPQ_FLAG

FROM ce.vwContact CON

CROSS JOIN years Y

LEFT JOIN (
    SELECT [Contact ID],
           MIN([Enrolment Date]) AS first_enrolment_date
    FROM ce.vwEnrolments
    GROUP BY [Contact ID]
) ED
    ON CON.ContactId = ED.[Contact ID]

LEFT JOIN (
    SELECT 
        apuk_contactid,
        MIN(apuk_datequalified) AS apuk_datequalified
    FROM ce.vwRicsRecord
    GROUP BY apuk_contactid
) RR
    ON RR.apuk_contactid = CON.ContactId

LEFT JOIN (
    SELECT [Contact No],
           MIN(Trans_Date_Adj) AS first_retired_date
    FROM subs.vwSubsConcessions_Invoice
    WHERE [Retired Concession] = 'Retired Conc.'
    GROUP BY [Contact No]
) RD
    ON CON.Rics_contactno = RD.[Contact No]

LEFT JOIN CE.vwContact_ElectionDemo EDemo
    ON CON.ContactId = EDemo.[Contact ID]

LEFT JOIN ce.vwLocalGroup LG
    ON con.rics_localgroupid = LG.apuk_localgroupid

WHERE CON.MemberGrade_Description IN (
    'Candidate',
    'Qualified Professional',
    'Qualified Professional - 2 Years'
)
)

SELECT *,
    CASE 
        /* Respect status first */
        WHEN status = 'N/A' THEN 'N/A'
        WHEN status = 'Retired' THEN 'Retired'

        /* Candidate logic */
        WHEN status = 'Candidate' THEN 
            CASE 
                WHEN first_enrolment_date IS NOT NULL
                     AND DATEDIFF(YEAR, first_enrolment_date, DATEFROMPARTS(yr,12,31)) >= 7
                THEN 'Sleeper Candidate'
                ELSE 'Candidate'
            END

        /* Qualified logic */
        WHEN status = 'Qualified' THEN
            CASE 
                WHEN RPQ_FLAG = 'RPQ Member'
                THEN 'RPQ Member'

                WHEN DATEDIFF(YEAR, apuk_datequalified, DATEFROMPARTS(yr,12,31)) < 2
                THEN 'Qualified Member - 2 Years'

                ELSE 'Qualified Member'
            END
    END AS member_grade_sub_category,

    CASE 
        WHEN yr = MIN(CASE 
                        WHEN status IN ('Candidate','Qualified') THEN yr 
                     END) OVER (PARTITION BY ContactId)
        THEN 1 ELSE 0 
    END AS first_year_flag

FROM base;
