CREATE   PROCEDURE [ContractRegister].[usp_Insert_ContractRegister_UserInfo]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-07-18
	Description: Procedure to insert contract register user info from ContractRegister sharepoint site
*/
BEGIN

	INSERT INTO [ContractRegister].[tblContractRegister_UserInfo]
	(
		[Id],
		[Name],
		[Account],
		[EMail],
		[MobileNumber],
		[SIPAddress],
		[IsSiteAdmin],
		[Deleted],
		[Hidden],
		[Department],
		[JobTitle],
		[FirstName],
		[LastName],
		[WorkPhone],
		[UserName],
		[Office],
		[ContentType],
		[Modified],
		[Created],
		[CreatedById],
		[ModifiedById]
	)
	SELECT
		wrk.[Id],
		wrk.[Name],
		wrk.[Account],
		wrk.[EMail],
		wrk.[MobileNumber],
		wrk.[SIPAddress],
		wrk.[IsSiteAdmin],
		wrk.[Deleted],
		wrk.[Hidden],
		wrk.[Department],
		wrk.[JobTitle],
		wrk.[FirstName],
		wrk.[LastName],
		wrk.[WorkPhone],
		wrk.[UserName],
		wrk.[Office],
		wrk.[ContentType],
		wrk.[Modified],
		wrk.[Created],
		wrk.[CreatedById],
		wrk.[ModifiedById]
	FROM [Work].[tblContractRegister_UserInfo] wrk
		LEFT JOIN [ContractRegister].[tblContractRegister_UserInfo] tgt
			ON wrk.[Id] = tgt.[Id]
	WHERE tgt.[Id] IS NULL

END
