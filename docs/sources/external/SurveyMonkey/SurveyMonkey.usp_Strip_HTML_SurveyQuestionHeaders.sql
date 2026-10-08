CREATE   PROCEDURE [SurveyMonkey].[usp_Strip_HTML_SurveyQuestionHeaders]
AS
	/*
		Created by: Raj Maddala
		Created on: 2023-10-10
		Description: Procedure to strip HTML tags in the question heading
	*/

BEGIN

	UPDATE TGT SET Processed_Heading = REPLACE(src.Header, '||', '&') FROM SurveyMonkey.tblSurveyQuestions tgt
	INNER JOIN
	(
		SELECT SurveyQuestionId,heading,CAST(REPLACE(REPLACE(REPLACE(heading, '&', '||'), '>', '/>'), '</', '<') AS XML).value('.', 'NVARCHAR(MAX)') AS Header
		FROM SurveyMonkey.tblSurveyQuestions
	) src
	ON tgt.SurveyQuestionId = src.SurveyQuestionId



END
