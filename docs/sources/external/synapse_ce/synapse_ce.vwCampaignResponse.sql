CREATE   VIEW [synapse_ce].[vwCampaignResponse]
AS
SELECT 
	cr.[apuk_delegatebookingid] AS [CampaignResponse_Key],
	cr.[createdon] AS [Created_On],
	--regst.[LocalizedLabel] AS [Registration_Status],
	stStatusCode.[LocalizedLabel] AS [Registration_Status],
	camp.[BusinessArea_Descritpion] AS [Business_Area],
	camp.[EventType_Description] AS [Event_Type],
	cr.[apuk_passprice] AS [Net_Value],
	cr.[apuk_total] AS [Cclevent_Valuegross],
	camp.[CostCentreId],
	camp.[CostCentreCode] AS [CostCentreCode],
	--cr.[Product_Group], --Based on CostCentre
	--cr.[CostCentre_Description],
	cr.[apuk_eventbookingid] AS [Booking_User], 
	--cr.[Sales_Type],
	--cr.[SalesTeamId],
	cr.[OwnerId],
	ownid.[fullname] AS [Owner],
	--cr.[Sales_Team],
	--cr.[Subject],
	cr.[apuk_eventid] AS [RegardingObjectId],
	camp.[Name] AS [Event_Name],
	camp.[Cclevent_eventid] AS [Event_Id],
	usrcreatedby.[fullname] AS [Created_By],
	usrmodifiedby.[fullname] AS [Modified_By],
	cr.[modifiedon] AS [Modified_On],
	cr.[apuk_eventbookingid] AS [cclevent_bookingrecordid],
	--cr.[Booking_Record], --Need to identify eventbookingid_entitype and join
	--cr.[Email],
	--cr.[Membership_Type], -- Retrieve through contact and ricsrecord
	--cr.[Parent_Account_Id],
	book.[apuk_bookingorganisationname] AS [Organisation],
	cr.[createdon] AS [Registered_On],
	--cr.[Registration_Channel],
	--cr.[Registration_Number],
	--cr.[Subscription_User],
	--cr.[Where_Heard_Of_Event],
	--cr.[Attendee_Member_Grade], --Need to get from Contact and ricsrecord
	--cr.[Attendee_Primary_Professional_Group], --need to get from contact, ricsrecord(apuk_primaryprofessionalgroupid)
	--cr.[Attendee_Region], --Need to get from contact
	--cr.[cclrv3_subscriptionuserid], --Need to get from contact
	--cr.[Response_Code],--Need to get from contact
	--cr.[Last_Name],--Need to get from contact
	--cr.[First_Name],--Need to get from contact
	--cr.[Postal_Code],--Need to get from contact
	--cr.[City],--Need to get from contact
	--cr.[Email_Address3],--Need to get from contact
	--cr.[RICS_ContactNo],--Need to get from contact
	--cr.[Email_Address2],--Need to get from contact
	--cr.[Email_Preference],--Need to get from contact
	--cr.[Campaign_Code],
	--cr.[Event_Product],
	--cr.[Subscription],
	cr.[StateCode],
	stStateCode.[LocalizedLabel] AS [StateCode_Description],
	cr.[StatusCode],
	stStatusCode.[LocalizedLabel] AS [StatusCode_Description],
	--cr.[Ccl_EventFee],
	--cr.[Cclevent_BaseFee],
	--cr.[Cclevent_AccommodationFee],
	camp.[ActualStart] AS [ActualStart],
	camp.[ActualEnd] AS [ActualEnd],
	--cr.[ReceivedOn],
	--cr.[Cclevent_checkin],
	--cr.[Cclevent_checkout],
	--cr.[ScheduledStart],
	--cr.[ScheduledEnd],
	cr.[apuk_contactid] AS [cclrv2_attendeecontactid],
	--cr.[cclrv2_attendeecontactidName], --Need to get from contact
	--vch.[valu] AS [Cclevent_VoucherDiscount],
	book.[apuk_earlybirddiscountapplied] AS [cclrv2_EarlyBirdDiscount],
	book.[apuk_groupdiscountapplied] AS [cclrv2_GroupDiscount],
	cr.[apuk_eventbookingid],
	book.[apuk_salesorderid],
	camp.[apuk_format],
	camp.[apuk_format_description],
	camp.[Cclevent_eventid] AS [EventId]

FROM synapse_ce.apuk_delegatebooking cr 
	LEFT JOIN synapse_ce.vwCampaign camp
		ON cr.[apuk_eventid] = camp.[CampaignId]
	LEFT JOIN synapse_ce.apuk_eventbooking book
		ON cr.[apuk_eventbookingid] = book.[apuk_eventbookingid]
	LEFT JOIN synapse_ce.apuk_voucher vch
		ON book.[apuk_voucherid] = vch.[apuk_voucherid]
	LEFT JOIN synapse_ce.msevtmgt_eventregistration reg
		ON cr.[apuk_eventregistrationid] = reg.[msevtmgt_eventregistrationid]
	--LEFT JOIN synapse_ce.OptionSetMetadata regst
	--	ON reg.[msevtmgt_registrationstatus] = regst.[Option]
	--		AND regst.[EntityName] = 'msevtmgt_eventregistration'
	--		AND regst.[OptionSetName] = 'msevtmgt_internalregistrationstatus'
	LEFT JOIN synapse_ce.systemuser usrcreatedby
		ON cr.[createdby] = usrcreatedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser usrmodifiedby
		ON cr.[modifiedby] = usrmodifiedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser ownid
		ON cr.[ownerid] = ownid.[systemuserid]
	LEFT JOIN synapse_ce.StateMetadata stStateCode
		ON cr.[statecode] = stStateCode.[State]
			AND stStateCode.[EntityName] = 'apuk_delegatebooking'
	LEFT JOIN synapse_ce.StatusMetadata stStatusCode
		ON cr.[statuscode] = stStatusCode.[Status]
			AND stStatusCode.[EntityName] = 'apuk_delegatebooking'
	WHERE NOT EXISTS (
		SELECT contactid
		FROM CE.tblContact_Test_Records TST
		WHERE TST.contactid = cr.[apuk_contactid]
		)
