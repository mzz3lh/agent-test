CREATE   PROCEDURE [GotoWebinar].[usp_Upsert_RegistrantDetails]
AS
BEGIN

	MERGE [GotoWebinar].[tblRegistrantDetails] as tgt
		USING [work].[tblRegistrantDetails_GotoWebinar] AS src
			ON tgt.[registrantkey] = src.[registrantkey]
			AND tgt.[webinarKey] = src.[webinarKey]
	WHEN MATCHED THEN UPDATE SET
		tgt.[_LinkId] = src.[_LinkId],
		tgt.[email] = src.[email],
		tgt.[firstName] = src.[firstName],
		tgt.[lastName] = src.[lastName],
		tgt.[registrationDate] = src.[registrationDate],
		tgt.[status] = src.[status],
		tgt.[timeZone] = src.[timeZone],
		tgt.[city] = src.[city],
		tgt.[country] = src.[country],
		tgt.[employeeCount] = src.[employeeCount],
		tgt.[implementationTimeFrame] = src.[implementationTimeFrame],
		tgt.[industry] = src.[industry],
		tgt.[jobTitle] = src.[jobTitle],
		tgt.[numberOfEmployees] = src.[numberOfEmployees],
		tgt.[organization] = src.[organization],
		tgt.[phone] = src.[phone],
		tgt.[questionsAndComments] = src.[questionsAndComments],
		tgt.[source] = src.[source],
		tgt.[state] = src.[state],
		tgt.[type] = src.[type],
		tgt.[unsubscribed] = src.[unsubscribed],
		tgt.[zipCode] = src.[zipCode]
	WHEN NOT MATCHED BY TARGET THEN INSERT
	(
		[WebinarKey],
		[RegistrantKey],
		[_LinkId],
		[email],
		[firstName],
		[lastName],
		[registrationDate],
		[status],
		[timeZone],
		[city],
		[country],
		[employeeCount],
		[implementationTimeFrame],
		[industry],
		[jobTitle],
		[numberOfEmployees],
		[organization],
		[phone],
		[questionsAndComments],
		[source],
		[state],
		[type],
		[unsubscribed],
		[zipCode]
	)
	VALUES
	(
		src.[WebinarKey],
		src.[RegistrantKey],
		src.[_LinkId],
		src.[email],
		src.[firstName],
		src.[lastName],
		src.[registrationDate],
		src.[status],
		src.[timeZone],
		src.[city],
		src.[country],
		src.[employeeCount],
		src.[implementationTimeFrame],
		src.[industry],
		src.[jobTitle],
		src.[numberOfEmployees],
		src.[organization],
		src.[phone],
		src.[questionsAndComments],
		src.[source],
		src.[state],
		src.[type],
		src.[unsubscribed],
		src.[zipCode]
	);

END
