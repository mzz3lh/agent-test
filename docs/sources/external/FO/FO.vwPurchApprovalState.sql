CREATE    VIEW [FO].[vwPurchApprovalState]
AS
SELECT * FROM(VALUES
	(0, 'Draft'),
	(10, 'In Review'),
	(20, 'Rejected'),
	(30, 'Approved'),
	(35, 'In external review'),
	(40, 'Confirmed'),
	(50, 'Finalized')
) tab (ApprovalState, Description)
