SELECT
  all_users.all_users,
  IF(adopted_users.adopted_users IS NULL, 0, 1) AS adopted
FROM
  (
  SELECT
    DISTINCT(object_id) AS all_users
  FROM
    takehome_users
  ) all_users
LEFT OUTER JOIN
  (
  SELECT
    DISTINCT(7_day_table.user_id) AS adopted_users
  FROM
  ( 
    SELECT
      A.user_id,
      A.date_stamp as date_stamp,
      COUNT(B.date_stamp) as 7_day_visits
    FROM
    (
      SELECT
        user_id AS user_id,
        DATE(time_stamp) AS date_stamp
      FROM
        takehome_user_engagement	
      GROUP BY
        user_id,
        DATE(time_stamp)
    ) 
    JOIN
    (
      SELECT
        user_id AS user_id,
        DATE(time_stamp) AS date_stamp
      FROM
      takehome_user_engagement	
      GROUP BY
      user_id,
      DATE(time_stamp)
    ) B
    ON 
    (DATEDIFF(A.date_stamp, B.date_stamp) <= 7
      AND A.date_stamp > B.date_stamp
      AND A.user_id = B.user_id)
    GROUP BY
    A.user_id,
    A.date_stamp
  ) 7_day_table
  WHERE
  7_day_table.7_day_visits >= 3
  ) adopted_users  
ON
  all_users.all_users = adopted_users.adopted_users
;
