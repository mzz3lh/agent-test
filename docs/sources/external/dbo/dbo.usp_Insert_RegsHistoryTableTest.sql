CREATE PROCEDURE [dbo].[usp_Insert_RegsHistoryTableTest] AS
BEGIN
----------------------
------ VARIABLES -----
----------------------

DECLARE @TotalCases INT
SET @TotalCases = (
	Select COUNT(createdon) 
	from regsbi.vwCaseregulatoryaudit_CE 
	WHERE Month(createdon) = MONTH(DateAdd(month, -1, getdate()))
	AND YEAR(createdon) = 
		CASE
			WHEN MONTH(getdate()) = 1 THEN YEAR(dateadd(year, -1, getdate()))
			ELSE YEAR(getdate())
			END)

DECLARE @PSA05 Numeric(7,2)
SET @PSA05 =(Select COUNT(createdon) AS 'COUNT'
from regsbi.vwCaseregulatoryaudit_CE
where apuk_auditreportpublishedon IS NOT NULL
AND apuk_primarysubjectname LIKE ('%Support Visit%')
AND apuk_daterequiredby > apuk_auditreportpublishedon
AND apuk_cancellationdate IS NULL
AND Month(apuk_auditreportpublishedon) = MONTH(DateAdd(month, -1, getdate()))
AND YEAR(apuk_auditreportpublishedon) = CASE
WHEN MONTH(getdate()) = 1 THEN YEAR(dateadd(year, -1, getdate()))
ELSE YEAR(getdate())
END)

DECLARE @PSA05PERCENT Numeric(5,2)
SET @PSA05PERCENT = (@PSA05/@TotalCases)*100;

DECLARE @PSA06 Numeric(7,2)
SET @PSA06 =(Select COUNT(createdon) AS 'COUNT'
from regsbi.vwCaseregulatoryaudit_CE
where apuk_auditreportpublishedon IS NOT NULL
AND apuk_primarysubjectname LIKE ('%Regulatory Review%')
AND apuk_daterequiredby > apuk_auditreportpublishedon
AND apuk_cancellationdate IS NULL
AND Month(apuk_auditreportpublishedon) = MONTH(DateAdd(month, -1, getdate()))
AND YEAR(apuk_auditreportpublishedon) = CASE
WHEN MONTH(getdate()) = 1 THEN YEAR(dateadd(year, -1, getdate()))
ELSE YEAR(getdate())
END)

DECLARE @PSA06PERCENT Numeric(5,2)
SET @PSA06PERCENT = (@PSA06/@TotalCases)*100;

----------------------
-- FILTERS AND DATA --
----------------------
SELECT *
INTO #TT
FROM (

	Select
	'PSA01' As 'METRIC ID',
	'Profession Support and Assurance' AS 'Regulation Team',
	CONVERT(date,GETDATE()) AS 'Export Date',
	COUNT(apuk_auditreportpublishedon) AS 'COUNT',
	'Number of cases with a Primary Subject like Support Visit' AS 'Description/Definition',
	'Number of MSVs completed' AS 'Metric',
	MONTH(DateAdd(month, -1, getdate())) As 'Month Related To',
	CASE
	WHEN MONTH(getdate()) = 1 THEN YEAR(dateadd(year, -1, getdate()))
	ELSE YEAR(getdate())
	END AS 'Year related to'
	from regsbi.vwCaseregulatoryaudit_CE
	where apuk_auditreportpublishedon IS NOT NULL
	AND apuk_primarysubjectname LIKE ('%Support Visit%')
	AND apuk_cancellationdate IS NULL
	AND Month(apuk_auditreportpublishedon) = MONTH(DateAdd(month, -1, getdate()))
	AND YEAR(apuk_auditreportpublishedon) = CASE
	WHEN MONTH(getdate()) = 1 THEN YEAR(dateadd(year, -1, getdate()))
	ELSE YEAR(getdate())
	END

	UNION ALL

	Select
	'PSA02' As 'METRIC ID',
	'Profession Support and Assurance' AS 'Regulation Team',
	CONVERT(date,GETDATE()) AS 'Export Date',
	COUNT(createdon) AS 'COUNT',
	'Number of cases with a Primary Subject like Regulatory Review' AS 'Description/Definition',
	'Number of RRVs completed' AS 'Metric',
	MONTH(DateAdd(month, -1, getdate())) As 'Month Related To',
	CASE
	WHEN MONTH(getdate()) = 1 THEN YEAR(dateadd(year, -1, getdate()))
	ELSE YEAR(getdate())
	END AS 'Year related to'
	from regsbi.vwCaseregulatoryaudit_CE
	where apuk_auditreportpublishedon IS NOT NULL
	AND apuk_cancellationdate IS NULL
	AND apuk_primarysubjectname LIKE ('%Regulatory Review%')
	AND Month(apuk_auditreportpublishedon) = MONTH(DateAdd(month, -1, getdate()))
	AND YEAR(apuk_auditreportpublishedon) = CASE
	WHEN MONTH(getdate()) = 1 THEN YEAR(dateadd(year, -1, getdate()))
	ELSE YEAR(getdate())
	END

	UNION ALL

	Select
	'PSA03 - ' + apuk_revieweridname  As 'METRIC ID',
	'Profession Support and Assurance' AS 'Regulation Team',
	CONVERT(date,GETDATE()) AS 'Export Date',
	COUNT(createdon) AS 'COUNT',
	'Number of cases with a Primary Subject like Support Visit with an Owner' AS 'Description/Definition',
	'Number of MSVs completed per reviewer' AS 'Metric',
	MONTH(DateAdd(month, -1, getdate())) As 'Month Related To',
	CASE
	WHEN MONTH(getdate()) = 1 THEN YEAR(dateadd(year, -1, getdate()))
	ELSE YEAR(getdate())
	END AS 'Year related to'
	from regsbi.vwCaseregulatoryaudit_CE
	where apuk_auditreportpublishedon IS NOT NULL
	AND apuk_cancellationdate IS NULL
	AND apuk_primarysubjectname LIKE ('%Support Visit%')
	AND Month(apuk_auditreportpublishedon) = MONTH(DateAdd(month, -1, getdate()))
	AND YEAR(apuk_auditreportpublishedon) = CASE
	WHEN MONTH(getdate()) = 1 THEN YEAR(dateadd(year, -1, getdate()))
	ELSE YEAR(getdate())
	END
	GROUP BY apuk_revieweridname

	UNION ALL

	Select
	'PSA04 - ' + apuk_revieweridname  As 'METRIC ID',
	'Profession Support and Assurance' AS 'Regulation Team',
	CONVERT(date,GETDATE()) AS 'Export Date',
	COUNT(createdon) AS 'COUNT',
	'Number of cases with a Primary Subject like Regulatory Review with an Owner' AS 'Description/Definition',
	'Number of RRVs completed per reviewer' AS 'Metric',
	MONTH(DateAdd(month, -1, getdate())) As 'Month Related To',
	CASE
	WHEN MONTH(getdate()) = 1 THEN YEAR(dateadd(year, -1, getdate()))
	ELSE YEAR(getdate())
	END AS 'Year related to'
	from regsbi.vwCaseregulatoryaudit_CE
	where apuk_auditreportpublishedon IS NOT NULL
	AND apuk_cancellationdate IS NULL
	AND apuk_primarysubjectname LIKE ('%Regulatory Review%')
	AND Month(apuk_auditreportpublishedon) = MONTH(DateAdd(month, -1, getdate()))
	AND YEAR(apuk_auditreportpublishedon) = CASE
	WHEN MONTH(getdate()) = 1 THEN YEAR(dateadd(year, -1, getdate()))
	ELSE YEAR(getdate())
	END
	GROUP BY apuk_revieweridname

	UNION ALL

	Select
	'PSA05' As 'METRIC ID',
	'Profession Support and Assurance' AS 'Regulation Team',
	CONVERT(date,GETDATE()) AS 'Export Date',
	MIN(@PSA05PERCENT) AS 'COUNT',
	'Number of cases with a report completed on date with a Primary Subject like Support Visit prior to the date required by' AS 'Description/Definition',
	'% MSVs completed before date required by' AS 'Metric',
	MONTH(DateAdd(month, -1, getdate())) As 'Month Related To',
	CASE
	WHEN MONTH(getdate()) = 1 THEN YEAR(dateadd(year, -1, getdate()))
	ELSE YEAR(getdate())
	END AS 'Year related to'
	from regsbi.vwCaseregulatoryaudit_CE

	UNION ALL

	Select
	'PSA06' As 'METRIC ID',
	'Profession Support and Assurance' AS 'Regulation Team',
	CONVERT(date,GETDATE()) AS 'Export Date',
	COUNT(createdon) AS 'COUNT',
	'Number of cases with a report completed on date with a Primary Subject like Regulatory Review prior to the date required by' AS 'Description/Definition',
	'% RRVs completed before date required by' AS 'Metric',
	MONTH(DateAdd(month, -1, getdate())) As 'Month Related To',
	CASE
	WHEN MONTH(getdate()) = 1 THEN YEAR(dateadd(year, -1, getdate()))
	ELSE YEAR(getdate())
	END AS 'Year related to'
	from regsbi.vwCaseregulatoryaudit_CE
	where apuk_auditreportpublishedon IS NOT NULL
	AND apuk_primarysubjectname LIKE ('%Regulatory Review%')
	AND apuk_daterequiredby > apuk_auditreportpublishedon
	AND apuk_cancellationdate IS NULL
	AND Month(apuk_auditreportpublishedon) = MONTH(DateAdd(month, -1, getdate()))
	AND YEAR(apuk_auditreportpublishedon) = CASE
	WHEN MONTH(getdate()) = 1 THEN YEAR(dateadd(year, -1, getdate()))
	ELSE YEAR(getdate())
	END

	UNION ALL

	Select
	'PSA07' As 'METRIC ID',
	'Profession Support and Assurance' AS 'Regulation Team',
	CONVERT(date,GETDATE()) AS 'Export Date',
	COUNT(apuk_auditreportpublishedon) AS 'COUNT',
	'Number of cases with a report completed on date with a grade of D or E' AS 'Description/Definition',
	'Reviews with a grade D/E' AS 'Metric',
	MONTH(DateAdd(month, -1, getdate())) As 'Month Related To',
	CASE
	WHEN MONTH(getdate()) = 1 THEN YEAR(dateadd(year, -1, getdate()))
	ELSE YEAR(getdate())
	END AS 'Year related to'
	from regsbi.vwCaseregulatoryaudit_CE
	where apuk_auditreportpublishedon IS NOT NULL
	AND apuk_cancellationdate IS NULL
	AND apuk_auditreportgrade_Description IN ('D','E')
	AND Month(apuk_auditreportpublishedon) = MONTH(DateAdd(month, -1, getdate()))
	AND YEAR(apuk_auditreportpublishedon) = CASE
	WHEN MONTH(getdate()) = 1 THEN YEAR(dateadd(year, -1, getdate()))
	ELSE YEAR(getdate())
	END

	UNION ALL

	Select
	'PSA08' As 'METRIC ID',
	'Profession Support and Assurance' AS 'Regulation Team',
	CONVERT(date,GETDATE()) AS 'Export Date',
	SUM(apuk_registeredvaluersatfirm) AS 'COUNT',
	'Total number of Registered Valuers that have been reviewed as part of completed reviews.' AS 'Description/Definition',
	'Registered valuers reviewed at firm' AS 'Metric',
	MONTH(DateAdd(month, -1, getdate())) As 'Month Related To',
	CASE
	WHEN MONTH(getdate()) = 1 THEN YEAR(dateadd(year, -1, getdate()))
	ELSE YEAR(getdate())
	END AS 'Year related to'
	from regsbi.vwCaseregulatoryaudit_CE
	where apuk_auditreportpublishedon IS NOT NULL
	AND apuk_cancellationdate IS NULL
	AND Month(apuk_auditreportpublishedon) = MONTH(DateAdd(month, -1, getdate()))
	AND YEAR(apuk_auditreportpublishedon) = CASE
	WHEN MONTH(getdate()) = 1 THEN YEAR(dateadd(year, -1, getdate()))
	ELSE YEAR(getdate())
	END

	UNION ALL

	Select
	'PSA09' As 'METRIC ID',
	'Profession Support and Assurance' AS 'Regulation Team',
	CONVERT(date,GETDATE()) AS 'Export Date',
	SUM(apuk_nonregisteredvaluersatfirm) AS 'COUNT',
	'Total number of Non-Registered Valuers that have been reviewed as part of completed reviews.' AS 'Description/Definition',
	'Non-Registered valuers reviewed at firm' AS 'Metric',
	MONTH(DateAdd(month, -1, getdate())) As 'Month Related To',
	CASE
	WHEN MONTH(getdate()) = 1 THEN YEAR(dateadd(year, -1, getdate()))
	ELSE YEAR(getdate())
	END AS 'Year related to'
	from regsbi.vwCaseregulatoryaudit_CE
	where apuk_auditreportpublishedon IS NOT NULL
	AND apuk_cancellationdate IS NULL
	AND Month(apuk_auditreportpublishedon) = MONTH(DateAdd(month, -1, getdate()))
	AND YEAR(apuk_auditreportpublishedon) = CASE
	WHEN MONTH(getdate()) = 1 THEN YEAR(dateadd(year, -1, getdate()))
	ELSE YEAR(getdate())
	END

	UNION ALL

	Select
	'PSA10' As 'METRIC ID',
	'Profession Support and Assurance' AS 'Regulation Team',
	CONVERT(date,GETDATE()) AS 'Export Date',
	SUM(apuk_amountofclientmoneyatfirm) AS 'COUNT',
	'Total amount of Client Money held that have been reviewed as part of completed reviews.' AS 'Description/Definition',
	'Amount of client money held by firms reviewed' AS 'Metric',
	MONTH(DateAdd(month, -1, getdate())) As 'Month Related To',
	CASE
	WHEN MONTH(getdate()) = 1 THEN YEAR(dateadd(year, -1, getdate()))
	ELSE YEAR(getdate())
	END AS 'Year related to'
	from regsbi.vwCaseregulatoryaudit_CE
	where apuk_auditreportpublishedon IS NOT NULL
	AND apuk_cancellationdate IS NULL
	AND Month(apuk_auditreportpublishedon) = MONTH(DateAdd(month, -1, getdate()))
	AND YEAR(apuk_auditreportpublishedon) = CASE
	WHEN MONTH(getdate()) = 1 THEN YEAR(dateadd(year, -1, getdate()))
	ELSE YEAR(getdate())
	END

	UNION ALL

	Select
	'PSA11' As 'METRIC ID',
	'Profession Support and Assurance' AS 'Regulation Team',
	CONVERT(date,GETDATE()) AS 'Export Date',
	COUNT(createdon) AS 'COUNT',
	'Total of MSV cases created in the last month' AS 'Description/Definition',
	'New MSVs created' AS 'Metric',
	MONTH(DateAdd(month, -1, getdate())) As 'Month Related To',
	CASE
	WHEN MONTH(getdate()) = 1 THEN YEAR(dateadd(year, -1, getdate()))
	ELSE YEAR(getdate())
	END AS 'Year related to'
	from regsbi.vwCaseregulatoryaudit_CE
	where apuk_primarysubjectname LIKE ('%Support Visit%')
	AND apuk_cancellationdate IS NULL
	AND Month(createdon) = MONTH(DateAdd(month, -1, getdate()))
	AND YEAR(createdon) = CASE
	WHEN MONTH(getdate()) = 1 THEN YEAR(dateadd(year, -1, getdate()))
	ELSE YEAR(getdate())
	END

	UNION ALL

	Select
	'PSA12' As 'METRIC ID',
	'Profession Support and Assurance' AS 'Regulation Team',
	CONVERT(date,GETDATE()) AS 'Export Date',
	COUNT(createdon) AS 'COUNT',
	'Total of RRV cases created in the last month' AS 'Description/Definition',
	'New RRVs created' AS 'Metric',
	MONTH(DateAdd(month, -1, getdate())) As 'Month Related To',
	CASE
	WHEN MONTH(getdate()) = 1 THEN YEAR(dateadd(year, -1, getdate()))
	ELSE YEAR(getdate())
	END AS 'Year related to'
	from regsbi.vwCaseregulatoryaudit_CE
	where apuk_primarysubjectname LIKE ('%Regulatory Review%')
	AND apuk_cancellationdate IS NULL
	AND Month(createdon) = MONTH(DateAdd(month, -1, getdate()))
	AND YEAR(createdon) = CASE
	WHEN MONTH(getdate()) = 1 THEN YEAR(dateadd(year, -1, getdate()))
	ELSE YEAR(getdate())
	END

	UNION ALL

	Select
	'PSA13' As 'METRIC ID',
	'Profession Support and Assurance' AS 'Regulation Team',
	CONVERT(date,GETDATE()) AS 'Export Date',
	COUNT(apuk_proposeddate) AS 'COUNT',
	'Total of MSV cases proposed in the last month' AS 'Description/Definition',
	'New MSVs Proposed' AS 'Metric',
	MONTH(DateAdd(month, -1, getdate())) As 'Month Related To',
	CASE
	WHEN MONTH(getdate()) = 1 THEN YEAR(dateadd(year, -1, getdate()))
	ELSE YEAR(getdate())
	END AS 'Year related to'
	from regsbi.vwCaseregulatoryaudit_CE
	where apuk_primarysubjectname LIKE ('%Support Visit%')
	AND apuk_cancellationdate IS NULL
	AND Month(apuk_proposeddate) = MONTH(DateAdd(month, -1, getdate()))
	AND YEAR(apuk_proposeddate) = CASE
	WHEN MONTH(getdate()) = 1 THEN YEAR(dateadd(year, -1, getdate()))
	ELSE YEAR(getdate())
	END


	UNION ALL

	Select
	'PSA14' As 'METRIC ID',
	'Profession Support and Assurance' AS 'Regulation Team',
	CONVERT(date,GETDATE()) AS 'Export Date',
	COUNT(apuk_proposeddate) AS 'COUNT',
	'Total of RRV cases proposed in the last month' AS 'Description/Definition',
	'New RRVs Proposed' AS 'Metric',
	MONTH(DateAdd(month, -1, getdate())) As 'Month Related To',
	CASE
	WHEN MONTH(getdate()) = 1 THEN YEAR(dateadd(year, -1, getdate()))
	ELSE YEAR(getdate())
	END AS 'Year related to'
	from regsbi.vwCaseregulatoryaudit_CE
	where apuk_primarysubjectname LIKE ('%Regulatory Review%')
	AND apuk_cancellationdate IS NULL
	AND Month(apuk_proposeddate) = MONTH(DateAdd(month, -1, getdate()))
	AND YEAR(apuk_proposeddate) = CASE
	WHEN MONTH(getdate()) = 1 THEN YEAR(dateadd(year, -1, getdate()))
	ELSE YEAR(getdate())
	END

	UNION ALL

	Select
	'PSA15' As 'METRIC ID',
	'Profession Support and Assurance' AS 'Regulation Team',
	CONVERT(date,GETDATE()) AS 'Export Date',
	COUNT(apuk_confirmeddate) AS 'COUNT',
	'Total of MSV cases confirmed in the last month' AS 'Description/Definition',
	'New MSVs Confirmed' AS 'Metric',
	MONTH(DateAdd(month, -1, getdate())) As 'Month Related To',
	CASE
	WHEN MONTH(getdate()) = 1 THEN YEAR(dateadd(year, -1, getdate()))
	ELSE YEAR(getdate())
	END AS 'Year related to'
	from regsbi.vwCaseregulatoryaudit_CE
	where apuk_primarysubjectname LIKE ('%Support Visit%')
	AND apuk_cancellationdate IS NULL
	AND Month(apuk_confirmeddate) = MONTH(DateAdd(month, -1, getdate()))
	AND YEAR(apuk_confirmeddate) = CASE
	WHEN MONTH(getdate()) = 1 THEN YEAR(dateadd(year, -1, getdate()))
	ELSE YEAR(getdate())
	END

	UNION ALL

	Select
	'PSA16' As 'METRIC ID',
	'Profession Support and Assurance' AS 'Regulation Team',
	CONVERT(date,GETDATE()) AS 'Export Date',
	COUNT(apuk_confirmeddate) AS 'COUNT',
	'Total of RRV cases confirmed in the last month' AS 'Description/Definition',
	'New RRVs Confirmed' AS 'Metric',
	MONTH(DateAdd(month, -1, getdate())) As 'Month Related To',
	CASE
	WHEN MONTH(getdate()) = 1 THEN YEAR(dateadd(year, -1, getdate()))
	ELSE YEAR(getdate())
	END AS 'Year related to'
	from regsbi.vwCaseregulatoryaudit_CE
	where apuk_primarysubjectname LIKE ('%Regulatory Review%')
	AND apuk_cancellationdate IS NULL
	AND Month(apuk_confirmeddate) = MONTH(DateAdd(month, -1, getdate()))
	AND YEAR(apuk_confirmeddate) = CASE
	WHEN MONTH(getdate()) = 1 THEN YEAR(dateadd(year, -1, getdate()))
	ELSE YEAR(getdate())
	END

	UNION ALL

	Select
	'PSA17' As 'METRIC ID',
	'Profession Support and Assurance' AS 'Regulation Team',
	CONVERT(date,GETDATE()) AS 'Export Date',
	COUNT(createdon) AS 'COUNT',
	'Total of MSV cases with no report date' AS 'Description/Definition',
	'Total MSV WIPs' AS 'Metric',
	MONTH(DateAdd(month, -1, getdate())) As 'Month Related To',
	CASE
	WHEN MONTH(getdate()) = 1 THEN YEAR(dateadd(year, -1, getdate()))
	ELSE YEAR(getdate())
	END AS 'Year related to'
	from regsbi.vwCaseregulatoryaudit_CE
	where apuk_primarysubjectname LIKE ('%Support Visit%')
	AND apuk_cancellationdate IS NULL
	AND apuk_auditreportpublishedon IS NULL


	UNION ALL

	Select
	'PSA18' As 'METRIC ID',
	'Profession Support and Assurance' AS 'Regulation Team',
	CONVERT(date,GETDATE()) AS 'Export Date',
	COUNT(createdon) AS 'COUNT',
	'Total of RRV cases with no Report date' AS 'Description/Definition',
	'Total RRV WIPs' AS 'Metric',
	MONTH(DateAdd(month, -1, getdate())) As 'Month Related To',
	CASE
	WHEN MONTH(getdate()) = 1 THEN YEAR(dateadd(year, -1, getdate()))
	ELSE YEAR(getdate())
	END AS 'Year related to'
	from regsbi.vwCaseregulatoryaudit_CE
	where apuk_primarysubjectname LIKE ('%Regulatory Review%')
	AND apuk_cancellationdate IS NULL
	AND apuk_auditreportpublishedon IS NULL

	UNION ALL

	Select
	'PSA18' As 'METRIC ID',
	'Profession Support and Assurance' AS 'Regulation Team',
	CONVERT(date,GETDATE()) AS 'Export Date',
	COUNT(createdon) AS 'COUNT',
	'Total cases with no Report date' AS 'Description/Definition',
	'Total WIPs' AS 'Metric',
	MONTH(DateAdd(month, -1, getdate())) As 'Month Related To',
	CASE
	WHEN MONTH(getdate()) = 1 THEN YEAR(dateadd(year, -1, getdate()))
	ELSE YEAR(getdate())
	END AS 'Year related to'
	from regsbi.vwCaseregulatoryaudit_CE
	WHERE apuk_cancellationdate IS NULL
	AND apuk_auditreportpublishedon IS NULL
	
) AS Src;

	INSERT INTO [dbo].[tblRegsHistoryTableTest] (
		 [METRIC ID]
		,[Regulation Team]
		,[Export Date]
		,[COUNT]
		,[Description/Definition]
		,[Metric]
		,[Month Related To]
		,[Year related to]
		)
	SELECT 
		 [METRIC ID]
		,[Regulation Team]
		,[Export Date]
		,[COUNT]
		,[Description/Definition]
		,[Metric]
		,[Month Related To]
		,[Year related to]
	FROM #TT

	--TRUNCATE TABLE [dbo].[tblRegsHistoryTableTest]
	--SELECT * FROM [dbo].[tblRegsHistoryTableTest]

END
