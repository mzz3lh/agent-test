CREATE    VIEW [synapse_ce].[vwEnrolments] AS

	SELECT
	 enr.[apuk_enrolmentid] AS 'ENR ID'
	,enr.[apuk_name] AS 'Enrolment Name'
	,enr.[createdon] AS 'Created Datetime'
	,CAST(enr.[createdon] AS DATE) AS 'Created Date'
	,usrcreatedby.[fullname] AS 'Created By'
	--,enr.[modifiedon] AS [Modified_On]
	--,enr.[ModifiedBy]
	--,usrmodifiedby.[fullname] AS [ModifiedByName]
	,CAST(enr.[apuk_enrolmentenddate] AS DATE) AS 'End Date'
	,enr.[apuk_ApplicationTypeId] AS 'Application Type ID'
	,apt.[apuk_name] AS 'Application Type'
	,cnt.[apuk_contactnumber] AS 'Contact No'
	,enr.[apuk_contactid] AS 'Contact ID'
	,CAST(enr.[apuk_electiondate] AS DATE) AS 'Election Date'
	,CAST(enr.[apuk_enrolmentdate] AS DATE) AS 'Enrolment Date'
	,apuk_expectedfinaldate AS 'expected_final_date'
	,enr.[apuk_numberofattempts] AS 'Number of Attempts'
	,enr.[apuk_enrolmentlocalgroupid] AS 'Enrolment Local Group ID'
	,enr.[apuk_PathwayId] AS 'Pathway ID'
	,patw.[apuk_name] AS 'Pathway'
	,enr.[apuk_RouteId] AS 'Route ID'
	,rt.[apuk_name] AS 'Route'
	,rt.apuk_enrolmenttype AS 'Enrolment Type ID'
	,entype.[LocalizedLabel] AS 'Enrolment Type'
	,enr.[apuk_outcome] AS 'Outcome ID' 
	,outc.[LocalizedLabel] AS 'Outcome'
	,enr.[statecode] AS 'State Code'
	,stStateCode.[LocalizedLabel] AS 'State'
	,enr.[statuscode] AS 'Status Code'
	,stStatusCode.[LocalizedLabel] AS 'Status'
	,apuk_arclastloggedin AS 'ARC Last Logged In' --Added by PS 12/01/2024 for Candidate Support
	,enr.[apuk_ricsrecordid]
	,enr.apuk_arcassessmentstatus AS 'ARC Assessment Status'--Added by PS 15/03/2024 for Candidate Support - U/S 56058
	,enr.[apuk_approvedbycounsellor] AS 'Approved By Counsellor'--Added by PS 15/03/2024 for Candidate Support - U/S 56058
	,enr.[apuk_competencyselectioncompleteddate] AS 'Competency Selection Completed Date' --Added by PS 15/03/2024 for Candidate Support - U/S 56058
	,enr.[apuk_casestudystatus] AS 'Case Study Status' --Added by PS 15/03/2024 for Candidate Support - U/S 56058
	,enr.[apuk_casestudyfeedback] AS 'Case Study Feedback' --Added by PS 15/03/2024 for Candidate Support - U/S 56058
	,enr.[apuk_summaryofexperiencestatus] AS 'Summary of Experience Status' --Added by PS 15/03/2024 for Candidate Support - U/S 56058
	,enr.[apuk_summaryofexperiencefeedback] AS 'Summary of Experience Feedback' --Added by PS 15/03/2024 for Candidate Support - U/S 56058
	,enr.[apuk_preliminarysubmissionreceived] AS 'Preliminary Submission Received' --Added by PS 15/03/2024 for Candidate Support - U/S 56058
	,enr.[apuk_submissionreceived] AS 'Submission Received' --Added by PS 15/03/2024 for Candidate Support - U/S 56058
	,enr.[apuk_corporateenrolment] --Added by PS 31/10/2024 - for Assesments (and Candidate Support seperately requested 30/10/2024) - U/S 66020
	,enr.[apuk_otherdetails]--Added by PS 31/10/2024 - request from Enrolments Team via Amanda Smith 30/10/2024 (RISE indicator)
	
	--Added PS 21/02/2025 ref U/S 72092
	,enr.apuk_graduatediarystartdate AS 'Graduate Diary Start Date'
	,enr.apuk_counselloridname AS 'Councellor'
	,enr.apuk_proposeridname AS 'Proposer'
	,enr.apuk_proposerapproveddate AS 'Proposer Approved Date'
	,enr.apuk_seconder1idname AS 'Seconder 1'
	,enr.apuk_seconder1approveddate AS 'Seconder 1 Approved Date'
	,enr.apuk_seconder2idname AS 'Seconder 2'
	,enr.apuk_seconder2approveddate AS 'Seconder 2 Approved Date'
	,enr.apuk_arcdeclarationaccepted AS 'ARC Declaration Accepted'
	,enr.apuk_ethicstestcompletiondate AS 'Ethics Module Last Taken'
	,enr.apuk_highestprofessionalbody
	,enr.apuk_highestqualification
	,enr.[apuk_highestprofessionalbodylookup]
	,enr.[apuk_highestprofessionalbodylookup_entitytype]
	,enr.[apuk_highestprofessionalbodylookupname]
	,rr.apuk_firstqualifiedlocalgroup
	,rr.apuk_firstqualifiedlocalgroupname
	,enr.[apuk_applicationreceiveddate]
	,enr.[apuk_enrolmentdeclarationaccepted]
	,enr.apuk_iscounsellorunknown 
	,enr.apuk_requestedcounsellor 
	,enr.apuk_requestedcounsellornotified 
	,enr.apuk_requestedcounselloraccepted 
	,enr.apuk_candidatenotifiedofcounsellordecision


	FROM synapse_ce.apuk_enrolment enr
	LEFT JOIN synapse_ce.contact cnt
		ON enr.apuk_contactid = cnt.contactid
	LEFT JOIN synapse_ce.StateMetadata stStateCode
		ON enr.[statecode] = stStateCode.[State]
			AND stStateCode.[EntityName] = 'apuk_enrolment'
	LEFT JOIN synapse_ce.StatusMetadata stStatusCode
		ON enr.[statuscode] = stStatusCode.[Status]
			AND stStatusCode.[EntityName] = 'apuk_enrolment'
	LEFT JOIN synapse_ce.systemuser usrcreatedby
		ON enr.[createdby] = usrcreatedby.[systemuserid]
	--LEFT JOIN synapse_ce.systemuser usrmodifiedby
	--	ON enr.[modifiedby] = usrmodifiedby.[systemuserid]
	LEFT JOIN synapse_ce.apuk_applicationtype apt
		ON enr.[apuk_applicationtypeid] = apt.[apuk_applicationtypeid]
	LEFT JOIN synapse_ce.apuk_pathway patw
		ON enr.[apuk_pathwayid] = patw.[apuk_pathwayid]
	LEFT JOIN synapse_ce.apuk_route rt
		ON enr.[apuk_routeid] = rt.[apuk_routeid]
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata outc
		ON enr.[apuk_outcome] = outc.[Option]
			AND outc.[OptionSetName] = 'apuk_outcome'
			AND outc.[EntityName] = 'apuk_enrolment'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata entype
		ON rt.[apuk_enrolmenttype] = entype.[Option]
			AND entype.[OptionSetName] = 'apuk_enrolmenttype'
	LEFT JOIN synapse_ce.apuk_ricsrecord rr
		ON enr.apuk_ricsrecordid = rr.apuk_ricsrecordid
	WHERE NOT EXISTS (
		SELECT contactid
		FROM CE.tblContact_Test_Records TST
		WHERE TST.contactid = enr.[apuk_contactid]
		)
