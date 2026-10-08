CREATE   VIEW [synapse_ce].[vwSubjectHierarchy]
AS
WITH subject_hierarchy AS (
	  SELECT    
		subjectid,
		title,
		1 AS [Level]
	  FROM synapse_ce.subject
	  WHERE parentsubject IS NULL
 
	  UNION ALL
   
	SELECT
		sub.subjectid,
		sub.title,
		sh.Level + 1 AS [Level]
	  FROM synapse_ce.subject sub
		INNER JOIN subject_hierarchy sh
			ON sub.parentsubject = sh.subjectid
)

SELECT s.subjectid, s.title AS Subject, cte.subjectid AS Parent_SubjectId, cte.title AS Parent_Subject, cte.[Level]
FROM subject_hierarchy cte
	INNER JOIN synapse_ce.subject s
		ON s.parentsubject = cte.subjectid

UNION ALL

SELECT    
	subjectid,
	title AS Subject,
	NULL AS Parent_SubjectId,
	NULL AS Parent_Subject,
	1 AS [Level]
FROM synapse_ce.subject
WHERE parentsubject IS NULL
