CREATE   VIEW [ContractRegister].[vwContractRegister]
AS
SELECT 
	CR.[id],
	CR.[Title],
	CR.[OldContractOwner],
	CR.[ContractTitle],
	CR.[SupplierName],
	CR.[Description],
	CR.[ContractTypeValue],
	CR.[ContractStatusValue],
	CR.[ContractStartDate],
	CR.[ContractEndDate],
	CR.[ReviewDate],
	CR.[NoticePeriodDays],
	CR.[ContractOwnerId],
	CROwner.[Name] AS [ContractOwner],
	CR.[ContractOwnerDept],
	CR.[ProcurementManagerId],
	CRProcMgr.[Name] AS [ProcurementManager],
	CR.[BudgetCode],
	CR.[ProcurementCategoryCodesValue],
	CR.[UnitOfCurrencyValue],
	CR.[AnnualSpend],
	CR.[TotalContractSpend],
	CR.[PreviousContractValue],
	CR.[SupplierContactName],
	CR.[SupplierMobile],
	CR.[SupplierOfficeTel],
	CR.[SupplierEmailAddress],
	CR.[ContractComments],
	CR.[PaymentFrequencyValue],
	CR.[ContractTypeLegalValue],
	CR.[ContentType],
	CR.[Modified],
	CR.[Created],
	CR.[CreatedById],
	CRCreatedBy.[Name] AS [CreatedBy],
	CR.[ModifiedById],
	CRModifiedBy.[Name] AS [ModifiedBy]
FROM [ContractRegister].[tblContractRegister] CR
	LEFT JOIN [ContractRegister].[tblContractRegister_UserInfo] CROwner
		ON CR.[ContractOwnerId] = CROwner.[Id]
	LEFT JOIN [ContractRegister].[tblContractRegister_UserInfo]  CRProcMgr
		ON CR.[ProcurementManagerId] = CRProcMgr.[Id]
	LEFT JOIN [ContractRegister].[tblContractRegister_UserInfo]  CRCreatedBy
		ON CR.[ProcurementManagerId] = CRCreatedBy.[Id]
	LEFT JOIN [ContractRegister].[tblContractRegister_UserInfo]  CRModifiedBy
		ON CR.[ProcurementManagerId] = CRModifiedBy.[Id]
