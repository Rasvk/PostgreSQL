--4a
EXPLAIN  SELECT s.seriesid, s.maintitle, s.firstprodyear, count(e.seriesid) as episoder
  FROM series s LEFT OUTER JOIN episode e ON s.seriesid = e.seriesid,
    (SELECT max(firstprodyear) as år FROM series) fpy
      WHERE s.firstprodyear = fpy.år
       GROUP BY s.maintitle, s.firstprodyear, s.seriesid;


--                                                                                   QUERY PLAN                                                                                   
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- HashAggregate  (cost=92.53..92.88 rows=35 width=35) (actual time=2.647..2.659 rows=22 loops=1)
--   Group Key: s.maintitle, s.firstprodyear, s.seriesid
--   ->  Hash Right Join  (cost=82.04..92.18 rows=35 width=31) (actual time=2.542..2.617 rows=22 loops=1)
--         Hash Cond: (e.seriesid = s.seriesid)
--         ->  Seq Scan on episode e  (cost=0.00..8.41 rows=441 width=4) (actual time=0.012..0.127 rows=441 loops=1)
--         ->  Hash  (cost=81.60..81.60 rows=35 width=27) (actual time=2.301..2.301 rows=22 loops=1)
--               Buckets: 1024  Batches: 1  Memory Usage: 10kB
--               ->  Hash Join  (cost=40.50..81.60 rows=35 width=27) (actual time=1.345..2.277 rows=22 loops=1)
--                     Hash Cond: (s.firstprodyear = (max(series.firstprodyear)))
--                     ->  Seq Scan on series s  (cost=0.00..35.37 rows=2037 width=27) (actual time=0.017..0.450 rows=2037 loops=1)
--                     ->  Hash  (cost=40.48..40.48 rows=1 width=4) (actual time=1.145..1.146 rows=1 loops=1)
--                           Buckets: 1024  Batches: 1  Memory Usage: 9kB
--                          ->  Aggregate  (cost=40.46..40.47 rows=1 width=4) (actual time=1.135..1.136 rows=1 loops=1)
--                                 ->  Seq Scan on series  (cost=0.00..35.37 rows=2037 width=4) (actual time=0.006..0.495 rows=2037 loops=1)
-- Planning Time: 0.706 ms
-- Execution Time: 2.792 ms


-- utfører en right join på  episode og series sin series id. dvs. at den returnerer alle fra høyre tabellen som er series og alle matchene fra venstresiden epsiode.
-- utføres en sekvensiell scan av episode
-- Hasher og utfører en Hash join igjen denne gangen en inner join hvor hvor den returnerer matchene verdier i begge tabeller.
-- sekvensiell scan av series 
-- usikker på siste hash og aggregate på tabell med 1 rad -> aggregate max?
-- utfører en ny sekvensiell skan av series
-- bruker en aggregatfunksjon-> group by

--4b
-- bruke en clusterindex siden det finnes flere søkenøkler som er like indekserer firstprodyear og episoder?
-- kanskje sekunderindex
-- tynn eller tett?
-- index(firstprodyear, seriesid)?
CREATE INDEX idx_year_seriesid_series ON series (firstprodyear DESC, seriesid);

CREATE INDEX idx_seriesid_episode ON  episode USING hash (seriesid);

EXPLAIN ANALYZE SELECT s.seriesid, s.maintitle, s.firstprodyear, count(e.seriesid) as episoder 
  FROM series s LEFT OUTER JOIN episode e ON s.seriesid = e.seriesid,
    (SELECT max(firstprodyear) as år FROM series) fpy
      WHERE s.firstprodyear = fpy.år
       GROUP BY s.maintitle, s.firstprodyear, s.seriesid;


DROP INDEX idx_year_seriesid_series, idx_seriesid_episode CASCADE;

--                                                                                QUERY PLAN                                                                                
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- HashAggregate  (cost=25.06..25.41 rows=35 width=35) (actual time=0.198..0.203 rows=22 loops=1)
--   Group Key: s.maintitle, s.firstprodyear, s.seriesid
--   ->  Nested Loop Left Join  (cost=2.85..24.71 rows=35 width=31) (actual time=0.113..0.181 rows=22 loops=1)
--         ->  Nested Loop  (cost=2.85..18.66 rows=35 width=27) (actual time=0.100..0.136 rows=22 loops=1)
--               ->  Result  (cost=0.30..0.31 rows=1 width=4) (actual time=0.077..0.078 rows=1 loops=1)
--                     InitPlan 1 (returns $0)
--                       ->  Limit  (cost=0.28..0.30 rows=1 width=4) (actual time=0.071..0.073 rows=1 loops=1)
--                             ->  Index Only Scan using idx_year_seriesid_series on series  (cost=0.28..51.93 rows=2037 width=4) (actual time=0.070..0.070 rows=1 loops=1)
--                                   Index Cond: (firstprodyear IS NOT NULL)
--                                   Heap Fetches: 0
--               ->  Bitmap Heap Scan on series s  (cost=2.55..17.99 rows=35 width=27) (actual time=0.018..0.049 rows=22 loops=1)
--                     Recheck Cond: (firstprodyear = ($0))
--                     Heap Blocks: exact=13
--                     ->  Bitmap Index Scan on idx_year_seriesid_series  (cost=0.00..2.54 rows=35 width=0) (actual time=0.009..0.009 rows=22 loops=1)
--                           Index Cond: (firstprodyear = ($0))
--         ->  Index Scan using idx_seriesid_episode on episode e  (cost=0.00..0.11 rows=6 width=4) (actual time=0.001..0.001 rows=0 loops=22)
--               Index Cond: (s.seriesid = seriesid)
-- Planning Time: 0.726 ms
-- Execution Time: 0.283 ms

-- Jeg har laget en indeks på series som er (firstprodyear, seriesid) i synkende rekkefølge dette fører til at alle seriene det letes etter legger seg øverst i b-treet, b-tre ble valgt ettersom
-- det ikke er lov med hash for indekser med flere atributter, jeg har også laget en index for series id i episode av typen hash, dette gjør at = operasjonen går raskere og eksekveringstiden går ned
-- betraktelig.

--              maintitle               | firstprodyear | episoder
----------------------------------------+---------------+----------
-- Tonight Show with Conan O'Brien, The |          2009 |        0
-- Pacific War, The                     |          2009 |        0
-- Untitled Star Wars TV Series         |          2009 |        0
-- Saka no ue no kumo                   |          2009 |        0
-- Last Horseman, The                   |          2009 |        0
-- Pacific, The                         |          2009 |        0
--(6 rows)
