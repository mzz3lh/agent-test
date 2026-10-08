CREATE    VIEW [dbo].[vwEmails]
AS
SELECT
    ap.[ActivityId],
    ap.[Subject],
    ap.[CreatedBy],
	ap.[Created_On]
FROM vwActivityPointer ap
WHERE ActivityTypeCode = '4202'
