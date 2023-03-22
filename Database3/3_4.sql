EXPLAIN SELECT count(*) FROM "Fact";

/* статистика */
EXPLAIN ANALYSE
SELECT "Customer_name",
       "Fact"."Supply_ID",
       "Supply"."Address"->'street' Customer_street,
       "Supply"."Address"->'building' Customer_address,
       "Comment",
       "Full_date",
       "Store_name",
       "City",
       "Company"."Address" Store_address,
       "Product_name",
       "Measure",
       "Amount"
FROM ((("Fact" LEFT JOIN "Company" ON "Company"."Store_ID" = "Fact"."Store_ID")
    LEFT JOIN "Date" ON "Date"."Date_ID" = "Fact"."Date_ID")
    LEFT JOIN "Product" ON "Fact"."Product_ID" = "Product"."Product_ID")
    LEFT JOIN "Supply" ON "Fact"."Supply_ID" = "Supply"."Supply_ID"
WHERE "Customer_name" LIKE 'Майоров%'
    AND "Full_date" BETWEEN '2010-01-01'::date AND '2011-01-01'::date
    AND "Store_name" = 'Леруа Мерлен'
    AND "Amount" = 10
ORDER BY "Customer_name", "Supply_ID", "Store_name";

CREATE INDEX fact_supply ON "Fact" ("Supply_ID");
CREATE INDEX fact_store ON "Fact" USING HASH ("Store_ID");
CREATE INDEX fact_date ON "Fact" ("Date_ID");
CREATE INDEX fact_product ON "Fact" ("Product_ID");
DROP INDEX fact_supply, fact_store, fact_product, fact_date;
-- DROP INDEX fact_date;
/* если добавить все индексы, то запрос станет работать хуже, так как в этом запросе не нужен индекс по продукту */

CREATE INDEX text_index ON "Supply" USING gin(to_tsvector('Russian', "Comment"));
DROP INDEX text_index;
EXPLAIN ANALYSE
SELECT * FROM "Supply" WHERE "Supply"."Comment" @@ to_tsquery('Свободен');
/* полнотекстовый поиск */


CREATE INDEX text_index_2 ON "Supply" USING gin(to_tsvector('Russian', "Customer_name"));
DROP INDEX text_index_2;
EXPLAIN ANALYSE
SELECT "Customer_name",
       "Fact"."Supply_ID",
       "Supply"."Address"->'street' Customer_street,
       "Supply"."Address"->'building' Customer_address,
       "Comment",
       "Full_date",
       "Store_name",
       "City",
       "Company"."Address" Store_address,
       "Product_name",
       "Measure",
       "Amount"
FROM ((("Fact" LEFT JOIN "Company" ON "Company"."Store_ID" = "Fact"."Store_ID")
    LEFT JOIN "Date" ON "Date"."Date_ID" = "Fact"."Date_ID")
    LEFT JOIN "Product" ON "Fact"."Product_ID" = "Product"."Product_ID")
    LEFT JOIN "Supply" ON "Fact"."Supply_ID" = "Supply"."Supply_ID"
WHERE "Customer_name" @@ to_tsquery('Майоров')
    AND "Full_date" BETWEEN '2010-01-01'::date AND '2011-01-01'::date
    AND "Store_name" = 'Леруа Мерлен'
    AND "Amount" = 10
ORDER BY "Customer_name", "Supply_ID", "Store_name";
/* полнотекстовый поиск ухудшил результаты, потому что каждый раз вычисляется to_tsvector.
   Можно улучшить результаты, если создать отдельную таблицу с этим и джойнить ее, тогда будет работать быстрее,
   но менее эффективно по памяти (наверное не очень принципиально).
   Это будет работать эффективнее, если данных будет очень очень много, тогда выйдет хорошо.
*/

CREATE INDEX day_index ON "Date" ("Day");
CREATE INDEX month_index ON "Date" ("Month");
CREATE INDEX year_index ON "Date" ("Year");
DROP INDEX day_index, month_index, year_index;
CREATE INDEX amount_ind ON "Fact" ("Amount");
DROP INDEX amount_ind;

EXPLAIN ANALYSE
SELECT "Customer_name",
       "Fact"."Supply_ID",
       "Supply"."Address"->'street' Customer_street,
       "Supply"."Address"->'building' Customer_address,
       "Comment",
       "Full_date",
       "Store_name",
       "City",
       "Company"."Address" Store_address,
       "Product_name",
       "Measure",
       "Amount"
FROM ((("Fact" LEFT JOIN "Company" ON "Company"."Store_ID" = "Fact"."Store_ID")
    LEFT JOIN "Date" ON "Date"."Date_ID" = "Fact"."Date_ID")
    LEFT JOIN "Product" ON "Fact"."Product_ID" = "Product"."Product_ID")
    LEFT JOIN "Supply" ON "Fact"."Supply_ID" = "Supply"."Supply_ID"
WHERE "Customer_name" LIKE 'Майоров%'
    AND "Day" >= 1 AND "Day" <= 10
    AND "Month" = 6
    AND "Store_name" = 'Леруа Мерлен'
    AND "Amount" = 10
ORDER BY "Customer_name", "Supply_ID", "Store_name";







SET enable_seqscan TO 'off';


ANALYSE VERBOSE "Fact";

VACUUM FULL;

/* не забыть вернуть */
SET enable_seqscan TO 'on';

SELECT tablename as tab, indexname as name, indexdef as def
FROM pg_indexes WHERE schemaname = 'public' ORDER BY tablename, indexname;