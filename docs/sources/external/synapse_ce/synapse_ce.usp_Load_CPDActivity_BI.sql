CREATE   PROCEDURE [synapse_ce].[usp_Load_CPDActivity_BI]
	@FullLoad BIT
AS
BEGIN

	--Get LastModifiedOn
	DECLARE @lastmodifiedon date
	
	IF @FullLoad = 1
		
		SET @lastmodifiedon = '1990-01-01'

	ELSE
		BEGIN
			SELECT @lastmodifiedon = MAX(modified_on) FROM synapse_ce.vwRics_cpdactivity
			SET @lastmodifiedon = DATEADD(DAY, -1, @lastmodifiedon)
		END


	--Update existing
	UPDATE tgt SET 
			  tgt.	Rics_name	=	src.	Rics_name
			,tgt.	Created_On	=	src.	Created_On
			,tgt.	CreatedBy	=	src.	CreatedBy
			,tgt.	CreatedByName	=	src.	CreatedByName
			,tgt.	Modified_On	=	src.	Modified_On
			,tgt.	ModifiedBy	=	src.	ModifiedBy
			,tgt.	ModifiedByName	=	src.	ModifiedByName
			,tgt.	rics_cpdannualsummaryid	=	src.	rics_cpdannualsummaryid
			,tgt.	rics_activitytypeid	=	src.	rics_activitytypeid
			,tgt.	rics_activitytypeidName	=	src.	rics_activitytypeidName
			,tgt.	rics_contactid	=	src.	rics_contactid
			,tgt.	OwnerId	=	src.	OwnerId
			,tgt.	OwnerIdName	=	src.	OwnerIdName
			,tgt.	Rics_Date	=	src.	Rics_Date
			,tgt.	Rics_Description	=	src.	Rics_Description
			,tgt.	OverriddenCreatedOn	=	src.	OverriddenCreatedOn
			,tgt.	Rics_Reflection	=	src.	Rics_Reflection
			,tgt.	Rics_Hours	=	src.	Rics_Hours
			,tgt.	Rics_OtherDescription	=	src.	Rics_OtherDescription
			,tgt.	Rics_Formal	=	src.	Rics_Formal
			,tgt.	Rics_Formal_Description	=	src.	Rics_Formal_Description
			,tgt.	Rics_Ethics	=	src.	Rics_Ethics
			,tgt.	Rics_EthicsDescription	=	src.	Rics_EthicsDescription
			,tgt.	ricsv1_EligibleFlag	=	src.	ricsv1_EligibleFlag
			,tgt.	Rics_Status	=	src.	Rics_Status
			,tgt.	Rics_Source	=	src.	Rics_Source
			,tgt.	Rics_Source_Description	=	src.	Rics_Source_Description
			,tgt.	StateCode	=	src.	StateCode
			,tgt.	StateCode_Description	=	src.	StateCode_Description
			,tgt.	StatusCode	=	src.	StatusCode
			,tgt.	StatusCode_Description	=	src.	StatusCode_Description
			,tgt.apuk_eventregistrationid = src.apuk_eventregistrationid
		-- select count(*)
	FROM synapse_ce.tblcpdactivity_BI tgt
		INNER JOIN  synapse_ce.vwRics_cpdactivity as src
				ON tgt.Rics_cpdactivityId = src.Rics_cpdactivityId
	WHERE src.[Modified_On] >= @lastmodifiedon



	--Insert New
	INSERT INTO synapse_ce.tblcpdactivity_BI
	(
		Rics_cpdactivityId	,
		Rics_name	,
		Created_On	,
		CreatedBy	,
		CreatedByName	,
		Modified_On	,
		ModifiedBy	,
		ModifiedByName	,
		rics_cpdannualsummaryid	,
		rics_activitytypeid	,
		rics_activitytypeidName	,
		rics_contactid	,
		OwnerId	,
		OwnerIdName	,
		Rics_Date	,
		Rics_Description	,
		OverriddenCreatedOn	,
		Rics_Reflection	,
		Rics_Hours	,
		Rics_OtherDescription	,
		Rics_Formal	,
		Rics_Formal_Description	,
		Rics_Ethics	,
		Rics_EthicsDescription	,
		ricsv1_EligibleFlag	,
		Rics_Status	,
		Rics_Source	,
		Rics_Source_Description	,
		StateCode	,
		StateCode_Description	,
		StatusCode	,
		StatusCode_Description	 ,
		apuk_eventregistrationid 
	)

	SELECT 
		wrk.	Rics_cpdactivityId
		,wrk.	Rics_name
		,wrk.	Created_On
		,wrk.	CreatedBy
		,wrk.	CreatedByName
		,wrk.	Modified_On
		,wrk.	ModifiedBy
		,wrk.	ModifiedByName
		,wrk.	rics_cpdannualsummaryid
		,wrk.	rics_activitytypeid
		,wrk.	rics_activitytypeidName
		,wrk.	rics_contactid
		,wrk.	OwnerId
		,wrk.	OwnerIdName
		,wrk.	Rics_Date
		,wrk.	Rics_Description
		,wrk.	OverriddenCreatedOn
		,wrk.	Rics_Reflection
		,wrk.	Rics_Hours
		,wrk.	Rics_OtherDescription
		,wrk.	Rics_Formal
		,wrk.	Rics_Formal_Description
		,wrk.	Rics_Ethics
		,wrk.	Rics_EthicsDescription
		,wrk.	ricsv1_EligibleFlag
		,wrk.	Rics_Status
		,wrk.	Rics_Source
		,wrk.	Rics_Source_Description
		,wrk.	StateCode
		,wrk.	StateCode_Description
		,wrk.	StatusCode
		,wrk.	StatusCode_Description
		,wrk.apuk_eventregistrationid 
		  -- select top 100 *
	FROM synapse_ce.vwRics_cpdactivity wrk  
		LEFT JOIN synapse_ce.tblcpdactivity_BI tgt
			ON wrk.Rics_cpdactivityId = tgt.Rics_cpdactivityId
	WHERE tgt.Rics_cpdactivityId IS NULL
		AND wrk.[Modified_On] >= @lastmodifiedon
	--Delete from target not in source

	IF @FullLoad = 1 
	BEGIN
	  DELETE tgt FROM synapse_ce.tblcpdactivity_BI tgt
		LEFT JOIN  synapse_ce.vwrics_cpdactivity wrk
			ON tgt.Rics_cpdactivityId = wrk.Rics_cpdactivityId
		WHERE wrk.Rics_cpdactivityId IS NULL
	END

END
