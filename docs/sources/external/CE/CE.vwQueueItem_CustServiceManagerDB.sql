CREATE   VIEW [CE].[vwQueueItem_CustServiceManagerDB] 
AS 

	SELECT 
		QueueItemId
		,Created_On
		,OwnerId
		,OwnerIdType
		,QueueId
		,QueueIdName
		,ObjectId
		,ObjectIdName
		,ObjectTypeCode_Description
		,Title
		,CONVERT(DATE, EnteredOn) AS [EnteredOn]
		,Priority
		,StatusCode_Description
		,WorkerId
		,WorkerIdName
		,WorkerIdType
	FROM [CE].[vwQueueItem]
	WHERE StateCode = 0
		--AND QueueIdName IN ('Contact RICS', 'Regulation - Returns', 'Readmissions', 'Resignations', 'APC')
		AND QueueIdName IN ('UK & I Candidate Support', 'UK & I Membership Support')
