CREATE VIEW [Product_Portfolio].[vw_MON_Board] AS

	SELECT
	 id AS 'Board ID'
	,[name] AS 'Board'
	,LEFT([name], 12) AS 'Board Abv.'
	FROM MondaydotCom.Boards
	WHERE id <> 1150004587 /*Exclude 2021*/
