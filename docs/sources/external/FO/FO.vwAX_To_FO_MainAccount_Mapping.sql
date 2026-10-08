CREATE   VIEW [FO].[vwAX_To_FO_MainAccount_Mapping]
AS
SELECT
	[AX_To_FO_MainAccount_MappingId],
	[AX_MainAccount],
	[AX_Description],
	[FO_MainAccount],
	[FO_Description],
	[FO_PL_Line],
	[FO_AccountType],
	[FO_FixedOrVariable_Cost]
FROM [FO].[tblAX_To_FO_MainAccount_Mapping]
