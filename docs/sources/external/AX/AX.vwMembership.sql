CREATE VIEW [AX].[vwMembership]
AS

SELECT
	[Rics_contactno],
	[Rics_MemberGrade],
	[MemberGradeDesc],
	[trainee_qualified],
	[SubsPricingGrade],
	[grade],
	[Rics_LocalGroup],
	[GenderCode],
	[Rics_Disability],
	[rics_ethnicity],
	[primaryProfessionalGroup],
	[Rics_PathwayToMembership],
	[StateCode],
	[StateCode_Description],
	[StatusCode],
	[StatusCode_Description],
	[BirthDate],
	[CurrentAge],
	[Rics_ConcessionCode],
	[Rics_ConcessionCode_Descritpion],
	[Rics_ElectionDate],
	[Rics_DoNotChase],
	[Rics_DoNotChase_Description],
	[Rics_DualMembership],
	[rics_localgroupid],
	[rics_countryidname]
FROM [Ext].[PBI02_AX_vwMembership]
