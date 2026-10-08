CREATE VIEW [CE].[vwPathwaySector] AS

SELECT * FROM (
    VALUES
    (-1,  'Unknown'),
	(101, 'Construction'),
	(102, 'Building Surveying and Control'),
	(103, 'Land and Natural Resources'),
	(104, 'Commercial Property'),
	(105, 'Residential Property'),
	(106, 'Valuation'),
	(107, 'N/A')

	) AS Kasatka ([Pathway Sector Code], [Pathway Sector])
