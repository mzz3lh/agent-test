CREATE   VIEW [FO].[vwMemberGradeHierarchy]
AS
SELECT 
	tab.MemberGradeCode,
	tab.MemberGradeDesc, 
	tab.l3_Code, 
	tab.l3, 
	tab.trainee_qualified, 
	tab.trainee_qualified_code, 
	tab.SubsPricingGrade, 
	tab.SubsFullPricingGrade, 
	tab.SubsRecGrade
	FROM (VALUES

		('000000000', 'Qualified Professional - 2 years', '000000000', 'FRICS', 'Qualified', 'TQ01', 'MRICS', 'Professional Member', 'ProfMember'),
		('000000000', 'Student', '000000000', 'Honorary', 'Other', 'TQ03', 'NULL', 'NULL', 'NULL'),
		('000000000', 'Non-Member', '000000000', 'N/A', 'Other', 'TQ03', 'NULL', 'NULL', 'NULL'),
		('000000000', 'Candidate', '000000000', 'AssocRICS', 'Trainee', 'TQ02', 'APC Candidate', ' APC Candidate', 'APCCandidate'),
		('000000000', 'Qualified Professional', '000000000', 'MRICS', 'Qualified', 'TQ01', 'MRICS', 'Professional Member', 'ProfMember')
	) tab (MemberGradeCode, MemberGradeDesc, l3_Code, l3, trainee_qualified, trainee_qualified_code, SubsPricingGrade, SubsFullPricingGrade, SubsRecGrade)
