CREATE VIEW [Product_Portfolio].[vw_CE_Delegate_Booking] AS 

	SELECT 
	 DEL.[apuk_delegatebookingid] AS 'Delegate Booking ID'
	,DEL.apuk_eventbookingid AS 'Event Booking ID'
	,DEL.apuk_eventid AS 'Event ID'
	,DEL.[createdon] AS 'Created Datetime'
	,CAST(DEL.[createdon] AS DATE) AS 'Created Date'
	,STA.[LocalizedLabel] AS 'State'
	,STS.[LocalizedLabel] AS 'Status'
	,DEL.[apuk_contactid] AS 'Contact ID'
	--,DEL.apuk_contactid_entitytype --Not needed?
	,DEL.apuk_passprice AS 'Ticket Amount CUR'
	,DEL.apuk_discount AS 'Discount Amount CUR'
	,DEL.apuk_tax AS 'Tax Amount CUR'
	,DEL.apuk_total AS 'Total Amount CUR'
	,DEL.apuk_passprice_base AS 'Ticket Amount MST'
	,DEL.apuk_discount_base AS 'Discount Amount MST'
	,DEL.apuk_tax_base AS 'Tax Amount MST'
	,DEL.apuk_total_base AS 'Total Amount MST'
	FROM synapse_ce.apuk_delegatebooking DEL 
	--LEFT JOIN synapse_ce.msevtmgt_eventregistration REG --Likely Redundant
	--	ON DEL.apuk_eventregistrationid = reg.msevtmgt_eventregistrationid
	LEFT JOIN synapse_ce.StateMetadata STA
		ON DEL.statecode = STA.[State]
		AND STA.EntityName = 'apuk_delegatebooking'
	LEFT JOIN synapse_ce.StatusMetadata STS
		ON DEL.statuscode = STS.[Status]
		AND STS.EntityName = 'apuk_delegatebooking'
	WHERE NOT EXISTS (
		SELECT contactid
		FROM CE.tblContact_Test_Records TST
		WHERE TST.contactid = DEL.apuk_contactid
		)
	AND DEL.createdon >= '2022-01-01'
