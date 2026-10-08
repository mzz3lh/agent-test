CREATE   VIEW [CE].[vwPathway] AS
WITH ContactMin AS (
	SELECT
	rics_pathwaytomembershipid
	FROM CE.vwContact
	GROUP BY rics_pathwaytomembershipid
	)

	SELECT 
	 [apuk_pathwayid] AS 'Pathway ID'
	,[apuk_name] AS 'Pathway'
	,[statecode] AS 'State'
	,[statuscode] AS 'Status'
	--,[apuk_pathwaygroup]
	,[apuk_code] AS 'Pathway Code'
	,[apuk_currentversion] AS 'Current Version'
	,[apuk_pathwaytype] AS 'Pathway Type'
	,CASE 
		WHEN apuk_pathwayid IN (
		'00000000-0000-0000-0000-000000000000',	--Built Infrastructure - Pre July 2018
		'00000000-0000-0000-0000-000000000000',	--Infrastructure
		'00000000-0000-0000-0000-000000000000',	--Project Management
		'00000000-0000-0000-0000-000000000000',	--Project Management - Pre July 2018
		'00000000-0000-0000-0000-000000000000',	--Project Management (Associate)
		'00000000-0000-0000-0000-000000000000',	--Quantity Surveying & Construction
		'00000000-0000-0000-0000-000000000000',	--Quantity Surveying & Construction - Pre July 2018
		'00000000-0000-0000-0000-000000000000'	--Quantity Surveying & Construction (Associate)
		) THEN 101
		WHEN apuk_pathwayid IN (
		'00000000-0000-0000-0000-000000000000',	--Building Control
		'00000000-0000-0000-0000-000000000000',	--Building Control - Pre July 2018
		'00000000-0000-0000-0000-000000000000',	--Building control (Associate)
		'00000000-0000-0000-0000-000000000000',	--Building Surveying
		'00000000-0000-0000-0000-000000000000',	--Building Surveying - Pre July 2018
		'00000000-0000-0000-0000-000000000000'	--Building Surveying (Associate)
		) THEN 102
		WHEN apuk_pathwayid IN (
		'00000000-0000-0000-0000-000000000000',	--Environment - Pre July 2018
		'00000000-0000-0000-0000-000000000000',	--Environmental Surveying
		'00000000-0000-0000-0000-000000000000',	--Geomatics
		'00000000-0000-0000-0000-000000000000',	--Geomatics - Pre July 2018
		'00000000-0000-0000-0000-000000000000',	--Geospatial Surveying (Associate)
		'00000000-0000-0000-0000-000000000000',	--Minerals and Waste Management
		'00000000-0000-0000-0000-000000000000',	--Minerals and Waste Management - Pre July 2018
		'00000000-0000-0000-0000-000000000000',	--Planning & Development
		'00000000-0000-0000-0000-000000000000',	--Planning & Development - Pre July 2018
		'00000000-0000-0000-0000-000000000000',	--Rural
		'00000000-0000-0000-0000-000000000000',	--Rural - Pre July 2018
		'00000000-0000-0000-0000-000000000000',	--Hydrographic surveying (Associate)
		'00000000-0000-0000-0000-000000000000',	--Land (Associate)
		'00000000-0000-0000-0000-000000000000'	--Land and Resources
		) THEN 103
		WHEN apuk_pathwayid IN (
		'00000000-0000-0000-0000-000000000000',	--Arts and Antiques - Pre July 2018
		'00000000-0000-0000-0000-000000000000',	--Commercial Property - Pre July 2018
		'00000000-0000-0000-0000-000000000000',	--Commercial property (Associate)
		'00000000-0000-0000-0000-000000000000',	--Commercial Real Estate
		'00000000-0000-0000-0000-000000000000',	--Corporate Real Estate
		'00000000-0000-0000-0000-000000000000',	--Facilities Management
		'00000000-0000-0000-0000-000000000000',	--Facilities Management - Pre July 2018
		'00000000-0000-0000-0000-000000000000',	--Facilities Management (Associate)
		'00000000-0000-0000-0000-000000000000',	--Management Consultancy
		'00000000-0000-0000-0000-000000000000',	--Management Consultancy - Pre July 2018
		'00000000-0000-0000-0000-000000000000',	--Personal Property / Arts and Antiques
		'00000000-0000-0000-0000-000000000000',	--Property Finance and Investment
		'00000000-0000-0000-0000-000000000000'	--Property Finance and Investment - Pre July 2018
--		'00000000-0000-0000-0000-000000000000'	--Real Estate Agency (Associate)
		) THEN 104
		WHEN apuk_pathwayid IN (
		'00000000-0000-0000-0000-000000000000',	--Residential
		'00000000-0000-0000-0000-000000000000',	--Residential - Pre July 2018
		'00000000-0000-0000-0000-000000000000',	--Residential Property Management (Associate)
		'00000000-0000-0000-0000-000000000000',	--Residential Survey & Valuation (Associate)
		'00000000-0000-0000-0000-000000000000'	--Real Estate Agency (Associate)
		) THEN 105
		WHEN apuk_pathwayid IN (
		'00000000-0000-0000-0000-000000000000',	--Taxation Allowances
		'00000000-0000-0000-0000-000000000000',	--Taxation Allowances - Pre July 2018
		'00000000-0000-0000-0000-000000000000',	--Valuation
		'00000000-0000-0000-0000-000000000000',	--Valuation - Pre July 2018
		'00000000-0000-0000-0000-000000000000',	--Valuation (Associate)
		'00000000-0000-0000-0000-000000000000',	--Valuation of Businesses and Intangible Assets
		'00000000-0000-0000-0000-000000000000'	--Valuation of Businesses and Intangible Assets - Pre July 2018
		) THEN 106
		WHEN apuk_pathwayid IN (
		'00000000-0000-0000-0000-000000000000',	--Research
		'00000000-0000-0000-0000-000000000000'	--Research - Pre July 2018
		) THEN 107
		ELSE -1 END AS 'Pathway Group'
	,CASE WHEN CM.rics_pathwaytomembershipid IS NULL THEN 'N' ELSE 'Y' END AS 'Appears on Contact'
	FROM [synapse_ce].[apuk_pathway] PTH
	LEFT JOIN ContactMin CM 
		ON CM.rics_pathwaytomembershipid = PTH.apuk_pathwayid
