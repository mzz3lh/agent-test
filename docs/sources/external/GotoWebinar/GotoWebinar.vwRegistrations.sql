CREATE   VIEW [GotoWebinar].[vwRegistrations]
AS
SELECT 
	web.[webinarId],
	web.[webinarKey],
	web.[subject] AS [Title],
	reg.[RegistrantKey],
	reg.[firstName] AS [First Name],
	reg.[lastName] AS [Last Name],
	reg.[email] AS [Email],
	reg.[phone] AS [Phone],
	reg.[zipCode] AS [Zip Code],
	reg.[registrationDate] AS [Registration Date],
	reg.[country] AS [Country],
	reg.[organization] AS [Organization],
	reg.[status] AS [Registration Status],
	reg.[jobTitle] AS [Job Title],
	reg.[unsubscribed] AS [Unsubscribed],
	reg.[source] AS [Source],
	reg.[employeeCount] AS [Employee Count],
	reg.[industry] AS [Industry],
	reg.[implementationTimeFrame] AS [Implementation Time Frame],
	reg.[numberOfEmployees] AS [Number of Employees],
	reg.[type] AS [Type],	
	regresp.[question] AS [Question],
	regresp.[answer] AS [Answer]
FROM [GoToWebinar].[tblWebinars] web
	INNER JOIN [GoToWebinar].[tblRegistrantDetails] reg
		ON web.[webinarKey] = reg.[WebinarKey]
	LEFT JOIN [GoToWebinar].[tblRegistrantResponses] regresp
		ON reg.[WebinarKey] = regresp.[WebinarKey]
		AND reg.[RegistrantKey] = regresp.[RegistrantKey]
--WHERE t1.firstName = 'Martyna'
--	AND t1.lastName = 'Stach'
