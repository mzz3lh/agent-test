--0000000 3 election dates
CREATE VIEW CE.vwElectionTimeline
AS
WITH cteCountElections
AS
(
SELECT COUNT([Contact No]) AS [Count],[Contact No] 
FROM [CE].[vwEnrolments] ENR
WHERE [Election Date] IS NOT NULL 
AND [Application Type] <> 'Student' 
GROUP BY [Contact No]
HAVING COUNT([Contact No])>1
),
cteElections1
AS
(SELECT ENR.[Contact No],ROW_NUMBER() OVER (PARTITION BY [Contact No] ORDER BY [Election Date]) AS ElectionNo, 
ENR.[Election Date],ENR.[application type],[Route]
FROM [CE].[vwEnrolments] ENR
WHERE [Election Date] IS NOT NULL 
AND [Application Type] <> 'Student'
AND ENR.[Contact No] IN (SELECT [Contact No] FROM cteCountElections)
),
cteElections2
AS
(
SELECT *, 
LAG([application Type],1) OVER (PARTITION BY [Contact No] ORDER BY ElectionNo) AS PrevAppType,
LAG([Election Date],1) OVER (PARTITION BY [Contact No] ORDER BY ElectionNo) AS PrevElectionDate
FROM cteElections1
)
SELECT *, DATEDIFF(dd,PrevElectionDate,[Election Date]) AS DaysSincePrevElection
,DATEDIFF(yy,PrevElectionDate,[Election Date]) AS YearsSincePrevElection
FROM cteElections2
--WHERE [Contact No] = '0000000'
--WHERE ElectionNo >= 3
--ORDER BY [Contact No], ElectionNo




/****************************************WORKING QUERIES******************************************************
SELECT * FROM CE.vwRics_Route
ORDER BY Created_On DESC

SELECT DISTINCT [application Type]
FROM CE.vwEnrolments


SELECT TOP 10 * FROM [CE].[vwContact_ElectionDemo]

***************************************************************************************************************/
