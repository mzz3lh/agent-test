CREATE VIEW [Product_Portfolio].[vw_Omni_CE_Contact] AS 

	WITH CTE AS (
		SELECT 
		[CE Contact No.]
		FROM [Product_Portfolio].[vw_Omni_Customer] OC
		WHERE [CE Contact No.] IS NOT NULL
		GROUP BY [CE Contact No.]
		)

	SELECT 
	[ContactId]
	,[Rics_contactno] AS 'Contact No.'
	,[rics_countryid]
	,[Rics_FirstQualifiedLocalGroupId]
	,[rics_pathwaytomembershipid]
	,rics_pathwaytomembershipidName
	,[rics_localgroupid]
	,[Address1_City]
	,[Address1_Country]
	,[address1_Line1]
	,[Address1_Line2]
	,[Address1_Line3]
	,[Address1_PostalCode]
	,[Address1_County]
	,[Telephone1]
	,[OwnerId]
	,[OwnerIdName]
	,[AccountId]
	,[AccountIdName]
	,[CustomerSizeCode]
	,[CustomerSizeCode_Description]
	,[CustomerTypeCode]
	,[CustomerTypeCode_Description]
	,[JobTitle]
	,[FirstName]
	,[LastName]
	,[FullName]
	,[BirthDate]
	,[GenderCode]
	,[GenderCode_Description]
	,[StateCode]
	,[StateCode_Description]
	,[StatusCode]
	,[StatusCode_Description]
	,[Rics_ElectionDate]
	,[Rics_Honours]
	,COALESCE([Rics_MemberGrade], -1) AS Rics_MemberGrade
	,[MemberGrade_Description]
	,[Rics_LapsedDate]
	,[Rics_LapsedCode]
	,[Rics_LapsedCode_Description]
	,[EMailAddress1]
	,[Rics_corespadd_country]
	,[Rics_PaymentCycle]
	,[Rics_PaymentCycle_Description]
	,[Rics_Disability]
	,[Rics_Ethnicity]
	,[Rics_Ethnicity_Description]
	,[rics_primaryprofessionalgroupid]
	,[rics_primaryprofessionalgroupidName]
	,apuk_professionalgroupid
	,[Rics_ContactType]
	,[Rics_ContactType_Description]
	,[EmailAddress2]
	,[EmailAddress3]
	,[apuk_disabilitiesdetails]
	,[apuk_eminentmember]
	,[apuk_ricsrecordid]
	,[apuk_applicanttype]
	,[apuk_applicanttype_description]
	,[apuk_designation]
	,[apuk_designation_description]
	--[apuk_sexualorientation] 
	--[apuk_genderidentity] 
	--[apuk_religionorbelief] 
	--[apuk_ethnicityother]
	,CASE
		WHEN CON.StateCode = 0 --Active
		AND CON.Rics_MemberGrade IN (200000000, 200000001, 200000002) --Candidate/Qual Pro/ Qual Pro 2
		AND Rics_LapsedCode IS NULL
		THEN 1 ELSE 0 END AS 'Is Member'
	,CASE 
		WHEN CAST(ISNULL([BirthDate],'1900-01-01') AS DATE) = '1900-01-01' OR DATEDIFF(YY,[BirthDate], GETDATE()) < 16 OR [BirthDate] >= GETDATE() THEN NULL 
		ELSE DATEDIFF(YY,[BirthDate], GETDATE())
	END [Age]
	FROM [synapse_ce].[tblContact_BI] CON
	/*WHERE EXISTS (
		SELECT
		1 
		FROM CTE
		WHERE CTE.[CE Contact No.] = CON.Rics_contactno
		)
		*/
	LEFT JOIN CTE
		ON CTE.[CE Contact No.] = CON.Rics_contactno
	WHERE 
		(CTE.[CE Contact No.] IS NOT NULL)
		OR
		(
		CON.StateCode = 0 --Active
		AND CON.Rics_MemberGrade IN (200000000, 200000001, 200000002) --Candidate/Qual Pro/ Qual Pro 2
		AND Rics_LapsedCode IS NULL
		)
