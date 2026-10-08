CREATE   VIEW [GotoWebinar].[vwRegistrants]
AS
SELECT
	CAST(reg.[Webinarkey] AS NVARCHAR(20)) + '_' + CAST(reg.[registrantkey] AS NVARCHAR(20)) AS [RegistrationKey]
	,reg.[registrantKey]
	,reg.[WebinarKey]
	,reg.[firstName] AS [First Name]
	,reg.[lastName] As [Last Name]
	,reg.[email]
	,CAST(reg.[registrationDate] AS DATE) AS [Registration Date]
	,reg.[status] As [Registration Status]
	,reg.[timeZone] AS [Registration Timezone]
	
FROM [GoToWebinar].[tblRegistrants] reg
