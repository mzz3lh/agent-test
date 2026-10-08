/***************************************************************************************
Assessor Eligibility


****************************************************************************************/
CREATE  VIEW [synapse_ce].[vwAssessorEligibility]
AS
SELECT DISTINCT 
[First Name],
[Last Name],
[Rics No],
ContactID,
EMail,
[Start Date],
Rics_AssessorID,
[Chair Role],
[Auditor Role],
[Open Assessor Record Count],
[Ethics Compliant],
[Ethics Module LAst Taken],
Region,
AppTypeAPC,
AppTypeSPA,
AppTypeAssoc,
AppTypeFellow,
AppTypeCred,
CPDOutcome,
CPDStatus,
CPDAtRiskOfAction,
CPDExemptionType,
apuk_Lapsecode AS [Lapse Code],
Pathways,
[No Of Interviews] AS [No of Interviews last 12 Months],
[SLA Received],
[Training],
[Lists],
[Gender],--Added ref email 03/09/2024 - Wayne Grainger-Lloyd
[CurrentAge] AS Age --Added ref email 03/09/2024 - Wayne Grainger-Lloyd

FROM CE.tblAssessorEligibilityData a
WHERE NOT EXISTS (
	SELECT contactid
	FROM CE.tblContact_Test_Records TST
	WHERE TST.contactid = a.ContactID
	)
