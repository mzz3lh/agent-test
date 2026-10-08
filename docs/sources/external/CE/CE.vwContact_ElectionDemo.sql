CREATE          VIEW [CE].[vwContact_ElectionDemo] AS

	SELECT 
	 CON.[ContactId] AS 'Contact ID'
	,CON.[Rics_contactno] AS 'Contact No'
	--,CURR.isocurrencycode AS 'Currency'
	,CON.[rics_localgroupid] AS 'Local Group ID'
	,CON.[AccountId] AS 'Account ID'
	,CON.[FirstName] AS 'Forename'
	,CON.[LastName] AS 'Surname'
	,CAST(CON.[BirthDate] AS DATE) AS 'DOB'
	,DATEDIFF(YY,BirthDate, GETDATE()) AS 'Age'
	,COALESCE(GenderCode_Description, 'NULL') AS 'Gender'
	,COALESCE(Rics_Ethnicity, -1) AS 'Ethnicity Code'
	,COALESCE(Rics_Ethnicity_Description, 'NULL') AS 'Ethnicity' 
	,Rics_Disability AS 'Has Disability'
	,COALESCE(apuk_religionorbelief, -1) AS 'Religion Code'
	--,CON.[StateCode]
	,COALESCE([Rics_MemberGrade], -1) AS Rics_MemberGrade
	--,CON.[MemberGrade_Description] AS 'Member Grade'
	,CAST(CON.[Rics_LapsedDate] AS DATE) AS 'Lapsed Date'
	,CON.[Rics_LapsedCode] AS 'Lapsed Code'
	,CON.[Rics_LapsedCode_Description] AS 'Lapsed Reason'
	,CASE WHEN CON.Rics_LapsedCode IS NOT NULL THEN 'Y' ELSE 'N' END AS 'Is Lapsed'
	--,CON.[Rics_PaymentMethod]
	--,CON.[Rics_PaymentMethod_Description] AS 'Payment Method (Contact)'
	--,CON.[Rics_PaymentCycle]
	--,CON.[Rics_PaymentCycle_Description] AS 'Pay Cycle'
	--,CON.[Rics_PreventLapse]
	,CON.[Rics_PreventLapse_Description] AS 'Prevent Lapse'
	--,CON.[apuk_designation]
	,CON.[apuk_designation_description] AS 'Designation'
	,CON.apuk_professionalgroupid AS 'Professional Group Code'
	,CON.rics_primaryprofessionalgroupidName AS 'Primary Professional Group'
	,CON.rics_pathwaytomembershipid AS 'Pathway (Contact) Code'
	--,CON.rics_pathwaytomembershipidName AS 'Pathway (Contact)'
	,CON.Rics_ElectionDate AS 'Election Date RICSRecord'
	,CON.StateCode_Description As 'State'
	,'CE' AS 'Source'
	,E.[Application Type] --Added as per DevOps US 54173 - DBA/PS 01/03/2024
	,E.[Route]   --Added as per DevOps US 54173 - DBA/PS 01/03/2024
	,E.[Corporate Enrolment]
	,lg.[Budget_Region] + '_' + convert(varchar,DATEADD(month, DATEDIFF(month, 0, CON.[Rics_ElectionDate]), 0),112) AS [Budget_Key]
	,E.[Application Entry Type]
	,E.[Enrolment Date]
	,E.[End Date]
	,e.[Election Date]
	,e.[apuk_highestprofessionalbody]
	,e.[apuk_highestqualification]
	,e.[apuk_highestprofessionalbodylookupname]
	,e.[apuk_firstqualifiedlocalgroup]
	,e.[apuk_firstqualifiedlocalgroupname]

    ,CASE WHEN EED.[ENR ID] IS NOT NULL THEN 'New Qualified' END AS [Election Type]

	,EED.[Election Date] AS ED1

	FROM CE.vwEnrolments_ElectionDemo E 
		INNER JOIN [synapse_ce].[tblContact_BI] CON
			ON CON.[ContactId] = E.[contact ID]

		--LEFT JOIN CE.vwEnrolments_Last EED --Added to get Application Type and Route as per DevOps US 54173 - DBA/PS 01/03/2024
		--	ON E.[ENR ID] = EED.[ENR ID]


		LEFT JOIN CE.tbl_Enrolments_Last EED --RM 2025-10-29 referring the table due to bad performance
			ON E.[ENR ID] = EED.[ENR ID]

		LEFT JOIN [CE].[vwLocalGroup] lg
			ON CON.[rics_localgroupid] = lg.[apuk_localgroupid]
	WHERE 1=1
	AND Rics_ElectionDate IS NOT NULL   --RM, 2025-07-02
	AND E.[Election Date] IS NOT NULL


	--AND StateCode = 0 --Active
	--AND Rics_MemberGrade IN (000000000, 000000000, 000000000) --Candidate/Qual Pro/ Qual Pro 2
	--AND Rics_LapsedCode IS NULL

	AND NOT EXISTS (
		SELECT apuk_contactnumber
		FROM Static.tblTestContacts TST
		WHERE TST.apuk_contactnumber = CON.Rics_contactno
		) --Remove Test Records
--	AND Rics_ElectionDate IS NOT NULL

	UNION

	  SELECT 
	   CRM.[Contact ID]
      ,CRM.[Contact No]
      ,[Local Group ID]
      ,[Account ID]
      ,[Forename]
      ,[Surname]
      ,[DOB]
      ,[Age]
      ,[Gender]
      ,[Ethnicity Code]
      ,[Ethnicity]
      ,[Has Disability]
      ,[Religion Code]
      ,[Rics_MemberGrade]
      ,[Lapsed Date]
      ,[Lapsed Code]
      ,[Lapsed Reason]
      ,[Is Lapsed]
      ,[Prevent Lapse]
      ,[Designation]
      ,[Professional Group Code]
      ,[Primary Professional Group]
      ,[Pathway (Contact) Code]
      ,CRM.[Election Date] AS [Election Date RICSRecord]
      ,CRM.[State]
	  ,[Source]
	  ,E.[Application Type]  --Added as per DevOps US 54173 - DBA/PS 01/03/2024
	  ,E.[Route] --Added as per DevOps US 54173 - DBA/PS 01/03/2024
	  ,E.[Corporate Enrolment]
   	  ,lg.[Budget_Region] + '_' + convert(varchar,DATEADD(month, DATEDIFF(month, 0, crm.[Election Date]), 0),112) AS [Budget_Key]
	  ,E.[Application Entry Type]
	  ,E.[Enrolment Date]
	  ,E.[End Date]
	  ,E.[Election Date]
	  ,E.[apuk_highestprofessionalbody]
	  ,E.[apuk_highestqualification]
	  ,E.apuk_highestprofessionalbodylookupname
	  ,E.[apuk_firstqualifiedlocalgroup]
	  ,E.[apuk_firstqualifiedlocalgroupname]
 	  
	  ,'New Qualified' AS [Election Type]

	  ,E.[Election Date] AS ED1
  FROM [Static].[vwCRMLapsedMembers_CE_Altered] CRM
  --	LEFT JOIN CE.vwEnrolments_Last E  --Added to get Application Type and Route as per DevOps US 54173 - DBA/PS 01/03/2024
		--ON CRM.[Contact ID] = E.[Contact ID]
  	LEFT JOIN CE.tbl_Enrolments_Last E  --Added to get Application Type and Route as per DevOps US 54173 - DBA/PS 01/03/2024
		ON CRM.[Contact ID] = E.[Contact ID]

	LEFT JOIN [CE].[vwLocalGroup] lg
		ON crm.[Local Group ID] = lg.[apuk_localgroupid]
  WHERE CRM.[Election Date] IS NOT NULL
