CREATE   VIEW [dbo].[vwMemberGradeHierarchy]
AS
SELECT
	[MemberGradeCode],
	[MemberGradeDesc],
	[l1_code],
	[l1],
	[l2_code],
	[l2],
	[l3_Code],
	[l3],
	[trainee_qualified],
	[trainee_qualified_code],
	[SubsPricingGrade],
	[SubsFullPricingGrade],
	[SubsRecGrade]
FROM [Ext].[PBI02_dbo_vwMemberGradeHierarchy]
