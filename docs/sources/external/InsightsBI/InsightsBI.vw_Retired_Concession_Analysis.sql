CREATE VIEW InsightsBI.vw_Retired_Concession_Analysis AS

SELECT SC.[Contact ID]	
      ,SMS.[Contact No.]	
	  ,SMS.[Campaign Year]
	  ,[Retired Concession]
      ,[Movement]	
	  ,[Inv Total Amount]
	  ,[Member Invoice Position]
	  ,[Renewal Date Adj]
	  ,RR.apuk_datequalified
	  ,[First Retired Year]
	  ,DOB
	  ,	DATEDIFF(YEAR,DOB,[Renewal Date Adj]) AS AGE
	  ,[Gender]
	  ,case when RR.apuk_datequalified <= [Renewal Date Adj]  THEN 'Qualified Member'
			WHEN RR.apuk_datequalified > [Renewal Date Adj] THEN 'Candidate'
			ELSE 'Candidate'
			End as MEMBER_GRADE
	  ,[Lapsed Date]
      ,[Lapsed_Campaign_Year]	
	  ,[Lapsed Reason]
	  ,[Designation]
	  ,[Market_reporting_region]
	  ,[apuk_subregion_name]
	  ,[apuk_countryid_name]
	  ,LG.[apuk_regionid_name]
	  ,LG.[apuk_name] AS LOCAL_GROUP_NAME
	  ,[Is Lapsed (MS)]
	
  FROM [Subs].[vwSubsMemberStatuses] sms	
	
  left join subs.vwSubsContact SC	
  ON SMS.[Contact No.]= SC.[Contact No]	
	
  LEFT JOIN ce.vwLocalGroup LG	
  ON SC.[Local Group ID] = LG.apuk_localgroupid	

  LEFT JOIN ce.vwRicsRecord RR
  ON RR.apuk_contactid = sc.[Contact ID]
  	
	
  where [Member Invoice Position] IN ('Full Concession', 'Fully Paid', 'Partially Paid', 'Pre-Subs Payment')	
  --and [Campaign Year] = 2025	
  --and [Retired Concession] = 'Retired Conc.'	
  ;
