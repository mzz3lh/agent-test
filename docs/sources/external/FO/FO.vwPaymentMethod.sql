CREATE    VIEW [FO].[vwPaymentMethod]
AS
SELECT
	[PAYMMODE] AS [PAYMMODE],
	[NAME] AS [Description]
FROM [synapse_fo].[CUSTPAYMMODETABLE]
