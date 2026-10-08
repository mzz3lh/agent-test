CREATE   PROCEDURE [GotoWebinar].[usp_Upsert_Sessions]
AS
BEGIN

	MERGE [GotoWebinar].[tblSessions] as tgt
		USING [work].[tblSessions_GotoWebinar] AS src
			ON tgt.[sessionKey] = src.[sessionKey]
			AND tgt.[webinarKey] = src.[webinarKey]
	WHEN MATCHED THEN UPDATE SET
		tgt.[accountKey] = src.[accountKey],
		tgt.[buildNumber] = src.[buildNumber],
		tgt.[creatingOrganizerKey] = src.[creatingOrganizerKey],
		tgt.[creatingOrganizerName] = src.[creatingOrganizerName],
		tgt.[endTime] = src.[endTime],
		tgt.[experienceType] = src.[experienceType],
		tgt.[includeCertificate] = src.[includeCertificate],
		tgt.[numOpenedInvitations] = src.[numOpenedInvitations],
		tgt.[numRegLinkClicks] = src.[numRegLinkClicks],
		tgt.[registrantCount] = src.[registrantCount],
		tgt.[registrantsAttended] = src.[registrantsAttended],
		tgt.[startingOrganizerKey] = src.[startingOrganizerKey],
		tgt.[startingOrganizerName] = src.[startingOrganizerName],
		tgt.[startTime] = src.[startTime],
		tgt.[timeZone] = src.[timeZone],
		tgt.[totalPollCount] = src.[totalPollCount],
		tgt.[webinarID] = src.[webinarID],
		tgt.[webinarName] = src.[webinarName],
		tgt.[webinarType] = src.[webinarType],
		tgt.[HasImportedAttendees] = 0
	WHEN NOT MATCHED BY TARGET THEN INSERT
	(
		[webinarKey],
		[sessionKey],
		[accountKey],
		[buildNumber],
		[creatingOrganizerKey],
		[creatingOrganizerName],
		[endTime],
		[experienceType],
		[includeCertificate],
		[numOpenedInvitations],
		[numRegLinkClicks],
		[registrantCount],
		[registrantsAttended],
		[startingOrganizerKey],
		[startingOrganizerName],
		[startTime],
		[timeZone],
		[totalPollCount],
		[webinarID],
		[webinarName],
		[webinarType],
		[HasImportedAttendees]
	)
	VALUES
	(
		src.[webinarKey],
		src.[sessionKey],
		src.[accountKey],
		src.[buildNumber],
		src.[creatingOrganizerKey],
		src.[creatingOrganizerName],
		src.[endTime],
		src.[experienceType],
		src.[includeCertificate],
		src.[numOpenedInvitations],
		src.[numRegLinkClicks],
		src.[registrantCount],
		src.[registrantsAttended],
		src.[startingOrganizerKey],
		src.[startingOrganizerName],
		src.[startTime],
		src.[timeZone],
		src.[totalPollCount],
		src.[webinarID],
		src.[webinarName],
		src.[webinarType],
		0
	);

END
