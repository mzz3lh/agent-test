CREATE VIEW [Product_Portfolio].[vw_MON_Group] AS 

	SELECT 
	title AS 'Group'
	FROM MondaydotCom.Groups
	GROUP BY 
	title
