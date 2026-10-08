CREATE   PROCEDURE [EventBrite].[usp_Generate_Attendee_Questions]
AS
BEGIN

IF OBJECT_ID('EventBrite.tblAttendeeAnswers_Transposed', 'U') IS NOT NULL
BEGIN
	DROP TABLE [EventBrite].[tblAttendeeAnswers_Transposed]
END

DECLARE @strsql AS NVARCHAR(MAX) = ''

DECLARE @sql NVARCHAR(MAX) = ''

SELECT @sql = @sql + '[' + SUBSTRING(Question,1,128) + '],' FROM (

SELECT DISTINCT SUBSTRING(Question, 1, 140) AS Question
FROM EventBrite.tblAttendeeQuestions
--WHERE Event_Id = 000000000000
--	AND Organization_Id = 0000000000
GROUP BY Question
) tab


SET @strsql = N'
;WITH cte AS
(
SELECT Organization_Id, Event_Id, Attendee_Id, Question_Id, Question, Answer
FROM EventBrite.tblAttendeeQuestions
--WHERE Event_Id = 000000000000
--	AND Organization_Id = 0000000000
)

SELECT *
INTO [EventBrite].[tblAttendeeAnswers_Transposed]
FROM
(
    SELECT [Organization_Id],
           [Event_Id],
           [Attendee_Id],
		   [Question],
		   ISNULL([Answer],'''') AS [Answer]
    FROM [cte]
) AS SourceTable PIVOT(MAX([Answer]) FOR [Question] IN(' + SUBSTRING(@sql,1,LEN(@sql)-1) + ')) AS PivotTable;'


EXEC sp_executesql @strsql

END
