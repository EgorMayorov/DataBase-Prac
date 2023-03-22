SELECT * FROM "Product" LEFT JOIN "Measures" on "Product"."Measure_ID" = "Measures"."Measure_ID";

/*проверка READ UNCOMMITED */
BEGIN;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

UPDATE "Product" SET "Product_name" = 'Отвертка плоская маленькая' WHERE "Product_name" = 'Отвертка плоская';

SELECT "Product_name", "Measure" 
FROM  "Product" LEFT JOIN "Measures" on "Product"."Measure_ID" = "Measures"."Measure_ID"
WHERE "Measure" = 'шт';

COMMIT;
/* тоже самое что и READ COMMITTED */

/* возврат к начальному */
UPDATE "Product" SET "Product_name" = 'Отвертка плоская' WHERE "Product_name" = 'Отвертка плоская маленькая';






/* READ UNCOMMITED потерянные изменения */
BEGIN;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
/* сделать чтобы работало */ 
DECLARE V INTEGER;

SELECT V="Measure_ID" FROM "Product" WHERE "Product_name" = 'Пассатижи';

UPDATE "Product" SET "Measure_ID" = V+1 WHERE "Product_name" = 'Пассатижи';

SELECT "Product_name", "Measure" 
FROM  "Product" LEFT JOIN "Measures" on "Product"."Measure_ID" = "Measures"."Measure_ID";

COMMIT;





/*проверка READ COMMITED */
BEGIN;
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

UPDATE "Product" SET "Product_name" = 'Отвертка крестовая маленькая' WHERE "Product_name" = 'Отвертка крестовая';
/* проверка неповторяемых чтений - можем видеть */

UPDATE "Product" SET "Measure_ID" = 3 WHERE "Product_name" = 'Отвертка крестовая маленькая';
/* можем видеть фантомы */

SELECT "Product_name", "Measure" 
FROM  "Product" LEFT JOIN "Measures" on "Product"."Measure_ID" = "Measures"."Measure_ID"
WHERE "Measure" = 'шт';

COMMIT;
/* неповторяющееся чтение и фантомное чтение */

/* возврат к начальному */
UPDATE "Product" SET "Product_name" = 'Отвертка крестовая' WHERE "Product_name" = 'Отвертка крестовая маленькая';
UPDATE "Product" SET "Measure_ID" = 2 WHERE "Product_name" = 'Отвертка крестовая';





/* проверка REPEATABLE READ на неповторяемые чтенияй */
BEGIN;
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;

UPDATE "Product" SET "Product_name" = 'Отвертка крестовая маленькая' WHERE "Product_name" = 'Отвертка крестовая';
/* проверка неповторяющихся чтений - таких нет */

SELECT "Product_name", "Measure" 
FROM  "Product" LEFT JOIN "Measures" on "Product"."Measure_ID" = "Measures"."Measure_ID"
WHERE "Measure" = 'шт';

COMMIT;





/* проверка REPEATABLE READ на фантомы */
BEGIN;
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;

UPDATE "Product" SET "Measure_ID" = 3 WHERE "Product_name" = 'Отвертка крестовая маленькая';
/* фантомов нет */

SELECT "Product_name", "Measure" 
FROM  "Product" LEFT JOIN "Measures" on "Product"."Measure_ID" = "Measures"."Measure_ID"
WHERE "Measure" = 'шт';

COMMIT;





/*проверка REPEATABLE READ на ошибку сериализации */
BEGIN;
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;

UPDATE "Product" SET "Product_name" = 'Отвертка крестовая маленькая' WHERE "Product_name" = 'Отвертка крестовая';

/* ROLLBACK; */
/* установить для второй попытки транзакций REPEATABLE READ */

UPDATE "Product" SET "Product_name" = 'Отвертка плоская маленькая' WHERE "Product_name" = 'Отвертка плоская';

SELECT "Product_name", "Measure" 
FROM  "Product" LEFT JOIN "Measures" on "Product"."Measure_ID" = "Measures"."Measure_ID"
WHERE "Measure" = 'шт';

COMMIT;
/* ошибка сериализации */





/*проверка SERIALIZABLE */
BEGIN;
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

UPDATE "Product" SET "Measure_ID" = 3 WHERE "Product_name" = 'Отвертка крестовая';

SELECT "Product_name", "Measure" 
FROM  "Product" LEFT JOIN "Measures" on "Product"."Measure_ID" = "Measures"."Measure_ID"
WHERE "Measure" = 'шт';

COMMIT;