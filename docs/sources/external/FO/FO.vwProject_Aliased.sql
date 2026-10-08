CREATE VIEW FO.vwProject_Aliased AS
--Some Projects have multiple Data Areas but this dimension is currently being used as a simple Project LU for Project Names only

	SELECT 
	 [PROJID] AS 'Project ID'
	,MAX([NAME]) AS 'Project'
	--,UPPER([DATAAREAID]) AS 'DATAAREAID'
	,[PARTITION]
	FROM [synapse_fo].[PROJTABLE]
	GROUP BY 
	 PROJID
	,PARTITION
