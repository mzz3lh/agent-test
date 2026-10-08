CREATE VIEW [Static].[vwCRMLapsedMembers_CE_Altered] AS

	SELECT 
	 [Contact ID]
	,[Contact No]
	,lg.apuk_localgroupid AS 'Local Group ID'
	,CAST(NULL AS uniqueidentifier) AS 'Account ID'
	,[First Name] AS 'Forename'
	,[Last Name] AS 'Surname'
	,CAST([DOB] AS DATE) AS 'DOB'
	,CAST(DATEDIFF(YY,[DOB], GETDATE()) AS int) AS 'Age'
	,[Gender]
	,CAST(NULL AS int) AS 'Ethnicity Code'
	,CAST(NULL AS NVARCHAR(350)) AS 'Ethnicity'
	,CAST(NULL AS bit) AS 'Has Disability'
	,CAST('-1' AS int) AS 'Religion Code'
	,CASE
		WHEN [Member Grade] = 'Affiliate Subscriber' THEN 200000004
		WHEN [Member Grade] = 'APC Candidate' THEN 200000000
		WHEN [Member Grade] = 'Associate Candidate' THEN 200000000
		WHEN [Member Grade] = 'Associate Member - 6 yrs' THEN 200000001
		WHEN [Member Grade] = 'Associate Member + 6 yrs' THEN 200000001
		WHEN [Member Grade] = 'Associate Member' THEN 200000001
		WHEN [Member Grade] = 'Associate Member' THEN 200000001
		WHEN [Member Grade] = 'Associate Member' THEN 200000001
		WHEN [Member Grade] = 'ATC Candidate' THEN 200000000
		WHEN [Member Grade] = 'Fellow' THEN 200000001
		WHEN [Member Grade] = 'Fellow - Invited' THEN 200000001
		WHEN [Member Grade] = 'Honorary Member' THEN 200000001
		WHEN [Member Grade] = 'Non Member' THEN 200000004
		WHEN [Member Grade] = 'Professional Member - 2 yrs' THEN 200000001
		WHEN [Member Grade] = 'Professional Member - 6 yrs' THEN 200000001
		WHEN [Member Grade] = 'Professional Member' THEN 200000001
		WHEN [Member Grade] = 'Student' THEN 200000003
		ELSE -1 END AS 'Rics_MemberGrade'
	,CAST([Lapsed Date] AS datetime) AS 'Lapsed Date'
	,CAST(CASE	
		WHEN [Lapsed Reason] = 'Removed' THEN '000000000'
		WHEN [Lapsed Reason] = 'Resigned: No Reason Given' THEN '000000000'
		WHEN [Lapsed Reason] = 'Deceased' THEN '000000000'
		WHEN [Lapsed Reason] = 'Resigned: Career Change' THEN '000000000'
		WHEN [Lapsed Reason] = 'Resigned: Ill Health' THEN '000000000'
		WHEN [Lapsed Reason] = 'Resigned: Retirement' THEN '000000000'
		WHEN [Lapsed Reason] = 'Resigned: Subs Increase' THEN '000000000'
		WHEN [Lapsed Reason] = 'Time Expired' THEN '000000000'
		WHEN [Lapsed Reason] = 'Resigned: Unable to Qualify' THEN '000000000'
		WHEN [Lapsed Reason] = 'Resigned: Economic circumstances' THEN '000000000'
		END AS int) AS 'Lapsed Code'
	,CAST(CASE
		WHEN [Lapsed Reason] = 'Removed' THEN 'Removed'
		WHEN [Lapsed Reason] = 'Resigned: No Reason Given' THEN 'Resigned'
		WHEN [Lapsed Reason] = 'Deceased' THEN 'Deceased'
		WHEN [Lapsed Reason] = 'Resigned: Career Change' THEN 'Resigned'
		WHEN [Lapsed Reason] = 'Resigned: Ill Health' THEN 'Resigned'
		WHEN [Lapsed Reason] = 'Resigned: Retirement' THEN 'Resigned'
		WHEN [Lapsed Reason] = 'Resigned: Subs Increase' THEN 'Resigned'
		WHEN [Lapsed Reason] = 'Time Expired' THEN 'Time Expired'
		WHEN [Lapsed Reason] = 'Resigned: Unable to Qualify' THEN 'Resigned'
		WHEN [Lapsed Reason] = 'Resigned: Economic circumstances' THEN 'Resigned'
		END AS nvarchar(350)) AS 'Lapsed Reason'
	,'Y' AS 'Is Lapsed'
	,CAST('No' AS nvarchar(350)) AS 'Prevent Lapse'
	,CASE
		WHEN [Member Grade] = 'Affiliate Subscriber' THEN 'Honorary'
		WHEN [Member Grade] = 'APC Candidate' THEN 'Honorary'
		WHEN [Member Grade] = 'Associate Candidate' THEN 'Honorary'
		WHEN [Member Grade] = 'Associate Member - 6 yrs' THEN 'AssocRICS'
		WHEN [Member Grade] = 'Associate Member + 6 yrs' THEN 'AssocRICS'
		WHEN [Member Grade] = 'Associate Member' THEN 'AssocRICS'
		WHEN [Member Grade] = 'Associate Member' THEN 'AssocRICS'
		WHEN [Member Grade] = 'Associate Member' THEN 'AssocRICS'
		WHEN [Member Grade] = 'ATC Candidate' THEN 'N/A'
		WHEN [Member Grade] = 'Fellow' THEN 'FRICS'
		WHEN [Member Grade] = 'Fellow - Invited' THEN 'FRICS'
		WHEN [Member Grade] = 'Honorary Member' THEN 'Honorary'
		WHEN [Member Grade] = 'Non Member' THEN 'N/A'
		WHEN [Member Grade] = 'Professional Member - 2 yrs' THEN 'FRICS'
		WHEN [Member Grade] = 'Professional Member - 6 yrs' THEN 'MRICS'
		WHEN [Member Grade] = 'Professional Member' THEN 'MRICS'
		WHEN [Member Grade] = 'Student' THEN 'N/A'
		ELSE 'N/A' END AS 'Designation'
	,CAST(PG.[Professional Group Code] AS uniqueidentifier) AS 'Professional Group Code'
	,CAST(C.[Professional Group] AS nvarchar (100)) AS 'Primary Professional Group'
	,P.[Pathway ID] AS 'Pathway (Contact) Code'
	,CAST([Date Qualified] AS datetime) AS 'Election Date'
	,CAST('Inactive' AS nvarchar (350)) AS 'State'
	,'CRM' AS 'Source'
FROM [Static].[tblCRMLapsedMembers] C
LEFT JOIN synapse_ce.apuk_localgroup lg
	ON replace(replace(replace(C.[Local Group Description], 'Local Group - ', ''), '&', 'and'), '  ', ' ') = replace(lg.apuk_name, '  ', ' ')
LEFT JOIN CE.vwProfessionalGroup PG
	ON PG.[Professional Group] = C.[Professional Group]
LEFT JOIN CE.vwPathway P
	ON P.Pathway = C.Pathway
