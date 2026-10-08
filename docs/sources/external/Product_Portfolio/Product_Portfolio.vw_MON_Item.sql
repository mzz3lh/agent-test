CREATE   VIEW [Product_Portfolio].[vw_MON_Item] AS
	
	SELECT 
	CAST(IT.ID AS NVARCHAR(15)) + '_' + CAST(IT.board_id AS NVARCHAR(15)) AS 'Item Key'
	,IT.id AS 'Item ID'
	,IT.name AS 'Item'
	,IT.board_id AS 'Board ID'
	,IT.created_at AS 'Item Created Datetime'
	,GR.title AS 'Group'

	--Keys
	,IVP.[Booking platform]
    ,COALESCE(IVP.[EV Code if applicable], '') AS 'EV Code OG'
	,CASE 
		WHEN IVP.[EV Code if applicable] = '' THEN NULL
		WHEN IVP.[EV Code if applicable] = 'N/A' THEN NULL
		ELSE IVP.[EV Code if applicable]
		END AS 'EV Code'
	,NULLIF(IVP.[SKU Code], '') AS 'SKU Code'
	--,IVP.[SKU creation date]

	--Event Details
    ,IVP.[Professional Group]
    ,IVP.[Product Group dropdown]
    ,IVP.[Format]
    ,IVP.[Sub-format]
    ,IVP.[Stage]
    ,IVP.[Project size]
    ,IVP.[Platform/Venue]
	,IVP.[Online / F2F]
	,IVP.Tags AS 'Theme'

	--Datetime
    ,IVP.[Start Date]
    ,IVP.[Start Time]
    ,IVP.[End Date]
    ,IVP.[End Time]
	,IVP.[Actual On Sale Date]
    ,IVP.[Year]
    ,IVP.[Length (Hours/Days)]
    ,IVP.[Lead time (days on sale)]

	--Regional
    ,IVP.[Language]
    ,IVP.[Region]
    ,IVP.[Country]
    --,IVP.[Create sub-items]
    --,IVP.[CSAT score]

	--Bool
	,[PB on time?]
	,[On sale on time?]

	--Staff
    ,IVP.[Delivery Lead]
    ,IVP.[Departmental owner]
	,IVP.[Project Manager]
    ,IVP.[Hosting]
    ,IVP.[PC Specialist]
	,IVP.[Annual Event Name]
    --,IVP.[PD Lead]
    --,IVP.[E Learning Specialist]

	--Unsure
    --,IVP.[1 Member/Non-Member]
    --,IVP.[2 Member/Non-Member]
    --,IVP.[3 Member/Non Member]
    --,IVP.[4 Member/Non Member]
    --,IVP.[5 Member/Non Member]
    --,IVP.[Member Engagement Planner 2024]
    --,IVP.[Member Engagement Planner 2025]
    --,IVP.[2023 Product catalogue]

	--Secondary Information
	--,IVP.[Percentage attended]
    --,IVP.[Member Price]
    --,IVP.[Non-Member Price]
    --,IVP.[Numbers Attended]
    --,IVP.[Numbers Booked]

	--Rules
	,CASE WHEN COALESCE([EV Code if applicable], '') = '' THEN 0 ELSE 1 END AS 'Has EV Code'
	,CASE WHEN COALESCE([SKU Code], '') = '' THEN 0 ELSE 1 END AS 'Has SKU Code'
	,CASE WHEN COALESCE([EV Code if applicable], '') = '' THEN 0 ELSE 1 END
		+ 
	 CASE WHEN COALESCE([SKU Code], '') = '' THEN 0 ELSE 1 END
	 AS 'SKU/EV Code Count'

	FROM MondaydotCom.Items IT
	LEFT JOIN Product_Portfolio.vw_MON_Item_Values_Pivoted IVP
		ON IVP.item_id = IT.id
		AND IT.board_id = IVP.board_id
	LEFT JOIN MondaydotCom.Groups GR
		ON GR.boardid = IT.board_id
		AND GR.id = IT.group_id
	WHERE IT.board_id <> 1150004587 /*Exclude 2021*/
	AND COALESCE([Format],'') <> 'Podcast'
	AND COALESCE([Sub-format],'') <> 'Governance Seminar'
	--AND Stage <> 'Cancelled'
