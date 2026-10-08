CREATE   VIEW [EventBrite].[vwExchangeRates]
AS

SELECT CAST(tab.[Currency] AS NVARCHAR(3)) AS [CurrencyCode], CAST(tab.[ExchangeRate] AS money) AS [ExchangeRate] FROM (VALUES
('EUR',	1.16),
('CNY',	0.11),
('INR',	0.0098),
('HKD',	0.1),
('AUD',	0.52),
('USD',	0.82),
('NZD',	0.48),
('SGD',	0.6),
('GBP', 1.0),
('DKK', 8.70),
('HUF', 460.50),
('PLN', 5.02),
('SEK', 13.27)
) tab ([Currency], [ExchangeRate])
