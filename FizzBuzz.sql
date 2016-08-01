WITH CTE_Numbers AS 
(
SELECT 1 Number
  UNION ALL
  SELECT Number + 1
    FROM CTE_Numbers
   WHERE Number < 100
)
    SELECT Number, 
		   CASE	       
	       WHEN Number % 3 = 0 AND Number % 5 = 0 THEN 'FizzBuzz'
	       WHEN Number % 5 = 0 THEN 'Buzz'
	       WHEN Number % 3 = 0 THEN 'Fizz'
	       ELSE CAST(Number AS CHAR(10))
	       END AS FizzBuzzTest 
      FROM CTE_Numbers;
