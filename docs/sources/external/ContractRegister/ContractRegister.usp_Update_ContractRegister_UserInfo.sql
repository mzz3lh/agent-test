CREATE   PROCEDURE [ContractRegister].[usp_Update_ContractRegister_UserInfo]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-07-18
	Description: Procedure to update contract register user info from ContractRegister sharepoint site
*/
BEGIN

	UPDATE tgt SET
		tgt.[Name] = wrk.[Name],
		tgt.[Account] = wrk.[Account],
		tgt.[EMail] = wrk.[EMail],
		tgt.[MobileNumber] = wrk.[MobileNumber],
		tgt.[SIPAddress] = wrk.[SIPAddress],
		tgt.[IsSiteAdmin] = wrk.[IsSiteAdmin],
		tgt.[Deleted] = wrk.[Deleted],
		tgt.[Hidden] = wrk.[Hidden],
		tgt.[Department] = wrk.[Department],
		tgt.[JobTitle] = wrk.[JobTitle],
		tgt.[FirstName] = wrk.[FirstName],
		tgt.[LastName] = wrk.[LastName],
		tgt.[WorkPhone] = wrk.[WorkPhone],
		tgt.[UserName] = wrk.[UserName],
		tgt.[Office] = wrk.[Office],
		tgt.[ContentType] = wrk.[ContentType],
		tgt.[Modified] = wrk.[Modified],
		tgt.[Created] = wrk.[Created],
		tgt.[CreatedById] = wrk.[CreatedById],
		tgt.[ModifiedById] = wrk.[ModifiedById]	
	FROM [ContractRegister].[tblContractRegister_UserInfo] tgt
		INNER JOIN [Work].[tblContractRegister_UserInfo] wrk
			ON wrk.[Id] = tgt.[Id]

END
