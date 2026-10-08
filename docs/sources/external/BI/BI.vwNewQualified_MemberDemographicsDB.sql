CREATE   VIEW [BI].[vwNewQualified_MemberDemographicsDB]
AS


SELECT c.rics_contactno [contactno],
      [fullname],
		-- c.rics_electiondate
		--dbo.fn_UTCtoUKtime(c.rics_electiondate) [FirstQualifiedDate],
      c.rics_electiondate [FirstQualifiedDate], -- disable this line if line above is re-enabled.
	  cast(case when month(c.rics_electiondate) >=8 then 
			right(year(c.rics_electiondate),2) + '/' + right(year(c.rics_electiondate)+1,2)
			else right(year(c.rics_electiondate)-1,2) + '/' + right(year(c.rics_electiondate),2) end as varchar(5)) Fiscal,

      c.[MemberGrade_Description] [MemberGrade],
      replace(c.Rics_FirstQualifiedLocalGroupIdName,'Local Group - ','') [FQ_LocalGroup],
      --c.PrimaryProfessionalGroup,
      c.rics_pathwaytomembershipidName,
      c.rics_ethnicity,
      c.rics_disability,
      c.gendercode,
	  c.GenderCode_Description as Gender,
	  c.Rics_FirstQualifiedLocalGroupId as FQ_LocalGroupID,
	  c.rics_localgroupid
     -- c.[contactCount]
      --a.rics_routeidname
      --a.rics_applicationtypeidname

FROM [CE].[vwContact] c
		 --left join bi.Apcsingleapp a on c.contactid = a.rics_contactid
		 WHERE
 
		  -- and rics_lapsedcode is null /*Take these out for Aug 2015 onwards*/
		  -- and statuscode = 1 /*Take these out for Aug 2015 onwards*/
   
		   c.rics_electiondate is not null
		  -- and dbo.fn_UTCtoUKtime(c.rics_electiondate) is not null
		   --and c.rics_membergrade <> '000000000' --Exclude HonRICS
		   and c.rics_electiondate between cast(year(getdate())-2 as varchar(4)) + '-08-01' and getdate()
