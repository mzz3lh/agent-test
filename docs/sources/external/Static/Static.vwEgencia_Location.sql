CREATE   VIEW [Static].[vwEgencia_Location] AS

SELECT
-- [Business Unit]
REPLACE([Company Name], 'RICS - ', '') AS 'Country Code'
,[Point of Sale Country] AS 'Country'
FROM static.tblEgenciaDemoExport
GROUP BY  
 --[Business Unit]
 [Company Name]
,[Point of Sale Country]
