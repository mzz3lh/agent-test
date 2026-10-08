CREATE   PROCEDURE [ContractRegister].[usp_Insert_ContractRegister]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-07-18
	Description: Procedure to insert contract register from ContractRegister sharepoint site
*/
BEGIN

	INSERT INTO [ContractRegister].[tblContractRegister]
	(
			[id],
			[Title],
			[OldContractOwner],
			[ContractTitle],
			[SupplierName],
			[Description],
			[ContractTypeValue],
			[ContractStatusValue],
			[ContractStartDate],
			[ContractEndDate],
			[ReviewDate],
			[NoticePeriodDays],
			[ContractOwnerId],
			[ContractOwnerDept],
			[ProcurementManagerId],
			[BudgetCode],
			[ProcurementCategoryCodesValue],
			[UnitOfCurrencyValue],
			[AnnualSpend],
			[TotalContractSpend],
			[PreviousContractValue],
			[SupplierContactName],
			[SupplierMobile],
			[SupplierOfficeTel],
			[SupplierEmailAddress],
			[ContractComments],
			[PaymentFrequencyValue],
			[ContractTypeLegalValue],
			[ContentType],
			[Modified],
			[Created],
			[CreatedById],
			[ModifiedById]
	)
	SELECT
			wrk.[id],
			wrk.[Title],
			wrk.[OldContractOwner],
			wrk.[ContractTitle],
			wrk.[SupplierName],
			wrk.[Description],
			wrk.[ContractTypeValue],
			wrk.[ContractStatusValue],
			wrk.[ContractStartDate],
			wrk.[ContractEndDate],
			wrk.[ReviewDate],
			wrk.[NoticePeriodDays],
			wrk.[ContractOwnerId],
			wrk.[ContractOwnerDept],
			wrk.[ProcurementManagerId],
			wrk.[BudgetCode],
			wrk.[ProcurementCategoryCodesValue],
			wrk.[UnitOfCurrencyValue],
			wrk.[AnnualSpend],
			wrk.[TotalContractSpend],
			wrk.[PreviousContractValue],
			wrk.[SupplierContactName],
			wrk.[SupplierMobile],
			wrk.[SupplierOfficeTel],
			wrk.[SupplierEmailAddress],
			wrk.[ContractComments],
			wrk.[PaymentFrequencyValue],
			wrk.[ContractTypeLegalValue],
			wrk.[ContentType],
			wrk.[Modified],
			wrk.[Created],
			wrk.[CreatedById],
			wrk.[ModifiedById]
	FROM [Work].[tblContractRegister] wrk
		LEFT JOIN [ContractRegister].[tblContractRegister] tgt
			ON wrk.[Id] = tgt.[Id]
	WHERE tgt.[Id] IS NULL

END
