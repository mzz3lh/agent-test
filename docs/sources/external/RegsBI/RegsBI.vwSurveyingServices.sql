CREATE VIEW RegsBI.vwSurveyingServices

AS 

SELECT 
DISTINCT LEFT([rics_answer], CHARINDEX(':', [rics_answer]) - 1) AS surveying_service,
CASE WHEN LEFT([rics_answer], CHARINDEX(':', [rics_answer]) - 1) IN
('Insolvency and corporate recovery (including fixed charge receivership)',
'Insolvency and recovery',
'Property Finance and Funding Advice',
'Property Finance & Funding Advice', -- ADDED IN
'Property Investment and Fund Management',
'Property Investment & Fund Management', -- ADDED IN
'Property taxation (advice/assessment)',
'Rating Advice and Review',
'Rent Review', -- ADDED IN
'Valuation - Agricultural',
'Valuation - Business and intangible assets',
'Valuation - Businesses',
'Valuation - Commercial',
'Valuation – Commercial', -- ADDED IN
'Valuation – Commercial Real Estate ',
'Valuation - Commercial real estate (inc other non-residential)',
'Valuation - Intangible Assets',
'Valuation - Machinery and Business Assets',
'Valuation - Machinery & Business Assets', -- ADDED IN
'Valuation - Natural resources',
'Valuation - Personal Property/Arts and Antiques',
'Valuation - Personal Property/Arts & Antiques', -- ADDED IN
'Valuation - Residential',
'Valuation – Residential', -- ADDED IN
'Valuation - Residential real estate')
THEN 'Valuation'
WHEN LEFT([rics_answer], CHARINDEX(':', [rics_answer]) - 1) IN
('Anti money laundering, bribery and corruption controls',
'Customer care, complaint handling and resolution ',
'Data control and protection',
'Financial resource management/controls',
'Professional indemnity and liability')
THEN 'Business Compliance'

WHEN LEFT([rics_answer], CHARINDEX(':', [rics_answer]) - 1) IN
('Operational facilities management services',
'Commercial real estate letting ',
'Commercial real estate management',
'Commercial real estate purchase/sales',
'Property & Estate Management – Commercial', --ADDED IN
'Strategic corporate real estate (occupier) advisory',
'Commercial / Residential Real Estate Letting ',
'Commercial / Residential Real Estate Purchase/Sales–',
'Commercial real estate letting',
'Facilities Management',
'Facilities management services',
'Management Consultancy & Strategic Property Advice',
'Property Lettings - Agricultural',
'Property Lettings - Commercial',
'Property Sales - Agricultural',
'Property Sales - Commercial')
THEN 'Commercial Real Estate'

WHEN LEFT([rics_answer], CHARINDEX(':', [rics_answer]) - 1) IN
('Building control - Advice',
'Building control',
'Building control - Inspection/assessment',
'Building design',
'Building design ',
'Approved Inspector',
'Auctioneering',
'Auctioneering (Livestock)',
'Building pathology ',
'Building surveys', 'Asset Management',
'Building survey',
'Contamination (including asbestos inspections)', -- ADDED IN
'Infrastructure cost management ',
'Infrastructure project/programme management',
'Construction contract procurement/management ',
'Quantity Surveying',
'Construction cost management (excluding infrastructure)',
'Construction project/programme management (excluding infrastructure)',
'Construction taxation advice ',
'Digital construction advice',
'Dilapidations advice ',
'Architectural Services',
'Fire safety advice ',
'Project Management',
'Contract Management',
'Planned maintenance advice ',
'Planning & Development',
'Planning and development')
THEN 'Construction'

WHEN LEFT([rics_answer], CHARINDEX(':', [rics_answer]) - 1) IN
('Compulsory purchase and land acquisition (advice/assessment)',
'Environmental assessment/management',
'Geospatial surveying',
'Land remediation',
'Natural resources management ',
'Neighbour disputes',
'Party wall',
'Party wall advice',
'Planning, Development and regeneration advice ',
'Rural estate management ',
'Waste management',
'Minerals & Waste Management Consultancy', -- ADDED IN
'Compulsory Purchase',
'Environmental Consultancy',
'Geomatics',
'Minerals and Waste Management Consultancy',
'Natural resources management',
'Planning, Development and regeneration advice',
'Property and Estate Management - Agricultural',
'Property and Estate Management – Commercial',
'Rural estate management and Sales',
'Property & Estate Management - Agricultural') -- ADDED IN
THEN 'Land and Natural Resources'

WHEN LEFT([rics_answer], CHARINDEX(':', [rics_answer]) - 1) IN
('Home condition reporting and certification',
'Leasehold advisory',
'Residential real estate letting',
'Home Survey',
'Residential real estate management',
'Property & Estate Management - Residential', -- ADDED IN
'Property and Estate Management – Residential',
'Property Lettings - Residential',
'Property Sales - Residential',
'Residential real estate sales',
'Residential real estate sales ')
THEN 'Residential Real Estate'

WHEN LEFT([rics_answer], CHARINDEX(':', [rics_answer]) - 1) = 'Dispute Resolution (including Expert Witness)'
THEN 'Cross Sector'

ELSE LEFT([rics_answer], CHARINDEX(':', [rics_answer]) - 1)

END AS 'Sector'
FROM [RegsBI].[vwSurveyAnswer_CE]
WHERE rics_questionName = 'JRFields'
