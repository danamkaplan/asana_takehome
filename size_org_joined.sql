SELECT 
  t1.object_id,
  COUNT(t2.object_id) AS org_size
FROM
  takehome_users t1
JOIN 
  takehome_users t2
ON
  (t1.org_id = t2.org_id
  AND t1.creation_time > t2.creation_time)
GROUP BY
  t1.object_id
;
