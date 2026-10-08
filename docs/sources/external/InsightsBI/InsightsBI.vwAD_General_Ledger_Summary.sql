/*Writer = Alexandra Durston
Date = April 2024
Purpose = We cannot use the general ledger semantic model in the 
"Measure what matters" project so we need a summary table which 
is as anonymised as possible

*/
    -- Select relevant fields with aggregations and transformations
CREATE   VIEW [InsightsBI].[vwAD_General_Ledger_Summary]
AS
    SELECT
		a.[Accounting Date],
		a.[Acc. Amount],
		b.[TB Category],
		b.[TB Category Group],
		b.[TB Subcategory Group],
		c.country as country_name,
		c.[Sub Region],
		c.[World Region],
		c.[Fin Market],
		c.[Fin Region],
		c.[Fin World Region],
		d.FY,
		d.FinYear,
		d.[Fiscal Year],
		d.SubsCampaignYear

    -- Specify the primary table for transaction data
    FROM fo.vwLedgerTrans_Aliased AS a

    -- Join with categories table to filter transactions relevant to 'P&L' (Profit & Loss)
    LEFT JOIN fo.vwTrialBalanceCategories AS b
        ON a.[TB Category Code] = b.[TB Category Code]       -- Join condition on category code
        

    -- Join with the country codes table to align country data
    LEFT JOIN ce.vwLocalGroup_Grouped AS c
        ON a.[Country Code] = c.country_three_char_code           -- Join condition on country code

    -- Join with the calendar table to ensure dates align properly
    LEFT JOIN bi.vwCalendar AS d
        ON a.[Accounting Date] = d.Date                       -- Join condition on the accounting date

WHERE  b.[TB Category Group] = 'P&L'                  -- Filter to include only P&L transactions
AND b.[TB Category Type]  NOT IN ('Strategic Investments','Reserves Movement')
