CREATE VIEW [Product_Portfolio].[vw_EB_Order] AS

	SELECT 
	 O.Order_Id
	,O.FirstName AS 'Forename'
	,O.LastName AS 'Surname'
	,O.Email
	,O.[Status]
	,O.Event_Id
	,O.Organization_Id
	,O.Link_Id
	,O.CreatedOn
	,O.ModifiedOn
	,'Other' AS 'Business Group'
	FROM EventBrite.tblOrder O
	LEFT JOIN EventBrite.tblEvent E
		ON E.Event_Id = O.Event_Id
	WHERE E.CreatedOn >= '2022-01-01'
