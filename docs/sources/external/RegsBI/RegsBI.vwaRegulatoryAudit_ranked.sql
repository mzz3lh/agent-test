CREATE VIEW [RegsBI].[vwaRegulatoryAudit_ranked] AS 

WITH CTE AS(
SELECT*, CASE WHEN [apuk_primarysubjectName] IN ('Client Money Audit - Non Residential - Key Account - L1','Client Money Audit - Non Residential - L1','Client Money Audit – Non residential – L1 (Failure L2)','Client Money Audit - Non Residential - L2','Client Money Audit - Residential - L1','Client Money Audit – Residential – L1 (Failure L2)','Client Money Audit - Residential - L2','CM Non-residential','CM Residential','CM Support Visit','CMPS','Concerns surrounding Clients’ Money handling') 
		THEN 'CM'
		WHEN [apuk_primarysubjectName] IN ('Valuer Registration Audit - Key Account - L1','Valuer Registration Audit - SCSI - L1','Valuer Registration Audit - Sponsoring Firm - L1','Valuer Registration Audit - Sponsoring Firm - L1 (APAC)',	'Valuer Registration Audit - Sponsoring Firm - L1 (EMEA)','Valuer Registration Audit – Sponsoring Firm – L1 (Failure L2) – UK','Valuer Registration Audit - Sponsoring Firm - L2','Valuer Registration Audit - Unsponsored Member - L1','Valuer Registration Audit - Unsponsored Member - L1 (APAC)','Valuer Registration Audit - Unsponsored Member - L1 (EMEA)','Valuer Registration Audit – Unsponsored Member – L1 (Failure L2) – UK','Valuer Registration Audit - Unsponsored Member - L2','Valuer Registration Audit - Unsponsored Member - L2 (APAC)','Valuer Registration Audit - Unsponsored Member - L2 (EMEA)','VR Member Support Visit	VR Regulatory Review')
		THEN 'VR'
		WHEN [apuk_primarysubjectName] IN ('DPB','DPB Support Visit','GIDA Audit - L1','Regs DPB')
		THEN 'DPB'
		END AS [Review area],
		CASE WHEN [apuk_audittype_Description]='Individual' THEN [apuk_regulatedindividualid] WHEN [apuk_audittype_Description]='Firm' THEN [apuk_regulatedfirmid] ELSE NULL END AS [Reg Entity]
		FROM [RegsBI].[vwCaseregulatoryaudit_CE])
		
SELECT*,
		RANK() OVER (PARTITION BY [Reg Entity],[Review area] ORDER BY [apuk_auditreportpublishedon] DESC) AS [Audit Rank (by type)]
		FROM CTE;
