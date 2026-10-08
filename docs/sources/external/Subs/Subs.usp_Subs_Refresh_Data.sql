CREATE   PROCEDURE [Subs].[usp_Subs_Refresh_Data]
AS BEGIN

EXEC Subs.usp_Refresh_SubsInvoices

EXEC Subs.usp_Refresh_SubsQuotes

EXEC Subs.usp_Refresh_SubsPayments

EXEC Subs.usp_Refresh_SubsOmni

EXEC Subs.usp_Refresh_SubsMemberStatuses

END

--EXEC Subs.usp_Subs_Refresh_Data
