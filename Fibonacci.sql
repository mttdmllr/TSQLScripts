WITH Fibonacci (PrevN, N) AS
(
     SELECT 0, 1
     UNION ALL
     SELECT N, PrevN + N
       FROM Fibonacci
      WHERE N < 1000000000
)
SELECT PrevN as Fibo
  FROM Fibonacci
OPTION (MAXRECURSION 0);
