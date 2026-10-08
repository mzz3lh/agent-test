CREATE   PROCEDURE [ContractRegister].[usp_Update_ContractRegister]
AS
/*
	Created by: Raj Maddala
	Created on: 2023-07-18
	Description: Procedure to update contract register from ContractRegister sharepoint site
*/
BEGIN

	UPDATE tgt SET
			tgt.[Title] = wrk.[Title],
			tgt.[OldContractOwner] = wrk.[OldContractOwner],
			tgt.[ContractTitle] = wrk.[ContractTitle],
			tgt.[SupplierName] = wrk.[SupplierName],
			tgt.[Description] = wrk.[Description],
			tgt.[ContractTypeValue] = wrk.[ContractTypeValue],
			tgt.[ContractStatusValue] = wrk.[ContractStatusValue],
			tgt.[ContractStartDate] = wrk.[ContractStartDate],
			tgt.[ContractEndDate] = wrk.[ContractEndDate],
			tgt.[ReviewDate] = wrk.[ReviewDate],
			tgt.[NoticePeriodDays] = wrk.[NoticePeriodDays],
			tgt.[ContractOwnerId] = wrk.[ContractOwnerId],
			tgt.[ContractOwnerDept] = wrk.[ContractOwnerDept],
			tgt.[ProcurementManagerId] = wrk.[ProcurementManagerId],
			tgt.[BudgetCode] = wrk.[BudgetCode],
			tgt.[ProcurementCategoryCodesValue] = wrk.[ProcurementCategoryCodesValue],
			tgt.[UnitOfCurrencyValue] = wrk.[UnitOfCurrencyValue],
			tgt.[AnnualSpend] = wrk.[AnnualSpend],
			tgt.[TotalContractSpend] = wrk.[TotalContractSpend],
			tgt.[PreviousContractValue] = wrk.[PreviousContractValue],
			tgt.[SupplierContactName] = wrk.[SupplierContactName],
			tgt.[SupplierMobile] = wrk.[SupplierMobile],
			tgt.[SupplierOfficeTel] = wrk.[SupplierOfficeTel],
			tgt.[SupplierEmailAddress] = wrk.[SupplierEmailAddress],
			tgt.[ContractComments] = wrk.[ContractComments],
			tgt.[PaymentFrequencyValue] = wrk.[PaymentFrequencyValue],
			tgt.[ContractTypeLegalValue] = wrk.[ContractTypeLegalValue],
			tgt.[ContentType] = wrk.[ContentType],
			tgt.[Modified] = wrk.[Modified],
			tgt.[Created] = wrk.[Created],
			tgt.[CreatedById] = wrk.[CreatedById],
			tgt.[ModifiedById] = wrk.[ModifiedById]
	FROM [ContractRegister].[tblContractRegister] tgt
		INNER JOIN [Work].[tblContractRegister] wrk
			ON wrk.[Id] = tgt.[Id]

END
