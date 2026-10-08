CREATE VIEW [OCE].[vwOCECaseStudies]
AS
SELECT
	[ContactId],
	[CaseStudyTitle],
	[CandidateStatus],
	[CounsellorId],
	[LastModofiedDate],
	[LastModifiedBy],
	[Status],
	[StatusLastUpdatedDate]
FROM [OCE].[tblOCECaseStudies]
