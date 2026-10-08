CREATE VIEW [Product_Portfolio].[vw_Omni_Customer] AS

WITH OLAUNIQUE AS (
		SELECT 
		O.[uid]
		FROM Drupal.commerce_order O
		WHERE O.created >= '2022-01-01'
		GROUP BY [uid]
		)

,OLAUSER AS (
	SELECT 
	 U.mail AS 'Email_Address'
	FROM [Sharedstore].[users] U
	WHERE EXISTS (
		SELECT 
		CTE.[uid]
		FROM OLAUNIQUE CTE
		WHERE CTE.[uid] = U.[uid]
		)
	GROUP BY U.mail
	)

,OLA_MAX AS (
	SELECT 
	 U.mail AS 'Email_Address'
	,MAX(O.created) AS 'Max_Order_Date'
	FROM Drupal.commerce_order O
	INNER JOIN [Sharedstore].[users] U
		ON U.[uid] = O.[uid]
	WHERE O.created >= '2022-01-01'
	GROUP BY U.mail
)

,EBUSER AS (
	SELECT 
	Profile_Email
	FROM EventBrite.tblAttendee
	WHERE CreatedOn >= '2022-01-01'
	GROUP BY Profile_Email
	)

,EB_MAX AS (
	SELECT 
	Profile_Email AS 'Email_Address'
	,MAX(CreatedOn) AS 'Max_Attend_Date'
	FROM EventBrite.tblAttendee
	WHERE CreatedOn >= '2022-01-01'
	GROUP BY Profile_Email
)

,CEUNIQUE AS (
	SELECT
	 EMailAddress1
	,MIN(ContactId) AS ContactId
	FROM [synapse_ce].[tblContact_BI] CON
	WHERE EXISTS (
		SELECT 
		DEL.apuk_contactid
		FROM synapse_ce.apuk_delegatebooking DEL
		WHERE DEL.apuk_contactid = CON.ContactId
		AND DEL.createdon >= '2022-01-01'
		)
	GROUP BY EMailAddress1
	)

,CEUSER AS (
	SELECT 
	CON.EMailAddress1 
	FROM synapse_ce.apuk_delegatebooking DEL 
	LEFT JOIN CEUNIQUE CON
		ON CON.ContactId = DEL.apuk_contactid
	WHERE NOT EXISTS (
		SELECT contactid
		FROM CE.tblContact_Test_Records TST
		WHERE TST.contactid = DEL.apuk_contactid
		)
	AND DEL.createdon >= '2022-01-01'
	GROUP BY CON.EMailAddress1 
	)

,CE_MAX AS (
	SELECT 
	CON.EMailAddress1 AS 'Email_Address'
	,MAX(DEL.createdon) AS 'Max_CE_Booking_Date'
	FROM synapse_ce.apuk_delegatebooking DEL
	INNER JOIN synapse_ce.tblContact_BI CON
		ON CON.ContactId = DEL.apuk_contactid
	LEFT JOIN CE.tblContact_Test_Records TST
		ON TST.contactid = DEL.apuk_contactid
	WHERE NOT EXISTS (
		SELECT contactid
		FROM CE.tblContact_Test_Records TST
		WHERE TST.contactid = DEL.apuk_contactid
		)
	AND DEL.createdon >= '2022-01-01'
	GROUP BY CON.EMailAddress1
)

--HASHBYTES('SHA2_256', mail) AS EmailHash
,OMNI AS (
	SELECT * FROM OLAUSER
	UNION
	SELECT * FROM EBUSER
	UNION
	SELECT * FROM CEUSER
	)

,CEUNIQUETWO AS (
	SELECT
	 EMailAddress1
	,MIN(Rics_contactno) AS Rics_contactno
	FROM [synapse_ce].[tblContact_BI] CON
	GROUP BY EMailAddress1
	)

,CEUNIQUETHREE AS (
	SELECT
	 Rics_contactno
	,CASE
		WHEN CON.StateCode = 0 --Active
		AND CON.Rics_MemberGrade IN (200000000, 200000001, 200000002) --Candidate/Qual Pro/ Qual Pro 2
		AND Rics_LapsedCode IS NULL
		THEN 1 ELSE 0 
		END AS 'Is_Member'
	FROM [synapse_ce].[tblContact_BI] CON
	)

,HASHITUP AS (
	SELECT 
	OMNI.Email_Address
	,HASHBYTES('SHA2_256', OMNI.Email_Address) AS 'Email_Hash'
	,ROW_NUMBER() OVER (ORDER BY OMNI.Email_Address ASC) + 99999 AS 'Customer_ID'
	,CON2.Rics_contactno AS 'CE_Contact_Number'
	,CASE WHEN CON2.Rics_contactno IS NOT NULL THEN 1 ELSE 0 END AS 'Has_CE_Match'
	,OM.Max_Order_Date
	,EB.Max_Attend_Date
	,CE.Max_CE_Booking_Date
	,CASE 
		WHEN Max_Order_Date >= COALESCE(Max_Attend_Date, '00000000')
		AND Max_Order_Date >= COALESCE(Max_CE_Booking_Date, '00000000')
		THEN Max_Order_Date

		WHEN Max_Attend_Date >= COALESCE(Max_Order_Date, '00000000')
		AND Max_Attend_Date >= COALESCE(Max_CE_Booking_Date, '00000000')
		THEN Max_Attend_Date

		WHEN Max_CE_Booking_Date >= COALESCE(Max_Order_Date, '00000000')
		AND Max_CE_Booking_Date >= COALESCE(Max_Attend_Date, '00000000')
		THEN Max_CE_Booking_Date

		ELSE NULL END AS 'Max_Activity_Date'

		,CASE
			WHEN CON3.[Is_Member] IS NULL THEN 'Not On CE'
			WHEN CON3.[Is_Member] = 1 THEN 'Member'
			WHEN CON3.[Is_Member] = 0 THEN 'Non-Member'
			ELSE 'NK'
			END AS 'Is Member (Customer)'

	FROM OMNI
	LEFT JOIN CEUNIQUETWO CON2
		ON CON2.EMailAddress1 = OMNI.Email_Address
	LEFT JOIN OLA_MAX OM
		ON OM.Email_Address = OMNI.Email_Address
	LEFT JOIN EB_MAX EB
		ON EB.Email_Address = OMNI.Email_Address
	LEFT JOIN CE_MAX CE
		ON CE.Email_Address = OMNI.Email_Address
	LEFT JOIN CEUNIQUETHREE CON3
		ON CON3.Rics_contactno = CON2.Rics_contactno
	)

	SELECT 
	--CONVERT(VARCHAR(64), EmailHash, 2) AS EmailHashHex
	 Email_Hash AS 'Email Hash'
	,Customer_ID AS 'Customer ID'
	,Email_Address AS 'Email Address'
	,CE_Contact_Number AS 'CE Contact No.'
	,Has_CE_Match AS 'Has CE Match'
	,Max_Order_Date AS 'Max OLA Date'
	,Max_Attend_Date AS 'Max EB Date'
	,Max_CE_Booking_Date AS 'Max CE Date'
	,Max_Activity_Date AS 'Max Activity Date'
	,[Is Member (Customer)]
	FROM HASHITUP
	WHERE Email_Address IS NOT NULL
	AND Email_Address <> ''
	;
