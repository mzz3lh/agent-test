CREATE VIEW [CE].[vwSME_Contact] AS

	SELECT
	 ContactId
	,Rics_contactno AS 'Contact No.'
	,Rics_LapsedCode_Description 'Lasped Reason'
	,CAST(Rics_LapsedDate AS DATE) AS 'Lapsed Date'
	,COALESCE([Rics_MemberGrade], -1) AS Member_Grade_Code
	,apuk_designation_description AS 'Designation'
	,COALESCE(GenderCode_Description, 'Unknown') AS 'Gender'
	,DATEDIFF(YY,BirthDate, GETDATE()) AS 'Age'
	,rics_pathwaytomembershipid
	,apuk_professionalgroupid
	,CR.rics_accountid
	,CR.Rics_RelationshipType_Description  AS 'Relationship Type'
	FROM CE.vwContact CON
	INNER JOIN CE.vwSME_Contact_Relationship CR
		ON CR.rics_contactid = CON.ContactId
