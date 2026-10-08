CREATE VIEW CE.vwEQSPassRates
AS


SELECT [apuk_assessmentid],[AssessmentDate],[Assessment Type],[final outcome],apuk_contactid,Pathway,[Route],Gender,[World Region],[Sub-Region]
FROM CE.vwEQSAssessmentStats
WHERE [Assessment Year] BETWEEN 2018 AND DATEPART(Year, GETDATE())-1
AND gendercode IN (1,2,200000000)
AND[final outcome] IN ('Pass','Refer')
