create view [InsightsBI].[vwAD_Subscription_Renewal_Summary] as

select 
[Contact No.],
[Campaign Year],
[Renewal Date Adj],
Movement,
b.rics_localgroupidName,
b.Rics_Region,
d.country,
d.[Fin Market],
d.[Fin Region],
d.[Fin World Region],
d.[Sub Region],
d.[World Region]

fROM [Subs].[vwSubsMemberStatuses] as a 


left join ce.vwContact as b
on a.[Contact No.] =b.Rics_contactno

left join ce.vwLocalGroup as c
on b.rics_localgroupid= c.apuk_localgroupid

left join ce.vwLocalGroup_Grouped as d 
on c.apuk_countryid = d.apuk_countryid
