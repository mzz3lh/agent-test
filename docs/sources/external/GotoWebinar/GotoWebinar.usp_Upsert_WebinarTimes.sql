CREATE    PROCEDURE [GoToWebinar].[usp_Upsert_WebinarTimes]
AS
BEGIN

	MERGE [GotoWebinar].[tblWebinarTimes] as tgt
		USING 
		(
			SELECT t1.[_LinkId], t1.[WebinarAccount], t1.[webinarId], t2.[startTime], t2.[endTime], REPLACE(REPLACE(REPLACE(CONVERT(NVARCHAR, t2.startTime,20), ':',''),'-',''),' ','') AS [startTimeKey]
			FROM [Work].[tblWebinars_GotoWebinar] t1
				INNER JOIN  [Work].[tblWebinarTimes_GotoWebinar] t2
					ON t1._LinkId = t2.[_LinkId]
					AND t1.[WebinarAccount] = t2.[WebinarAccount]
		) AS src
			ON tgt.[_LinkId] = src.[_LinkId]
			AND tgt.[WebinarId] = src.[WebinarId]
			AND tgt.[WebinarAccount] = src.[WebinarAccount]
			AND tgt.[startTimeKey] = src.[startTimeKey]
	WHEN MATCHED THEN UPDATE SET
		tgt.[startTime] = src.[startTime],
		tgt.[endTime] = src.[endTime]
	WHEN NOT MATCHED BY TARGET THEN INSERT
	(
		[_LinkId],
		[WebinarAccount],
		[WebinarId],
		[startTime],
		[endTime],
		[startTimeKey]
	)
	VALUES
	(
		src.[_LinkId],
		src.[WebinarAccount],
		src.[WebinarId],
		src.[startTime],
		src.[endTime],
		REPLACE(REPLACE(REPLACE(CONVERT(NVARCHAR, src.startTime,20), ':',''),'-',''),' ','')
	);

END
