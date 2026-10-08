CREATE    VIEW [CE].[vwD365CandidateData]
AS

	Select  
		cnt,
		[Member Grade],  
		[Contact Number], 
		[Full Name],
		[EMail Address],
		[Last Login Date],
		[Pathway],
		[Route],
		[Status],
		[Exected Final Date],
		[Application Enrolment Date],
		[Application Election Date],
		[Region],
		[Country],
		[Local Group],
		[World Region],    
		[Reporting World Region],
		[Competency Selection],
		[Approved Summary of Experience],
		[Not Approved Summary of Experience],
		[Case Study Status],
		contactid
		
		FROM CE.tblD365CandidateData
