SELECT * FROM "Product";

/*проверка READ UNCOMMITED на грязные чтения */
BEGIN;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT "Product_name", "Measure" 
FROM  "Product" LEFT JOIN "Measures" on "Product"."Measure_ID" = "Measures"."Measure_ID"
WHERE "Measure" = 'шт';

SELECT "Product_name", "Measure" 
FROM  "Product" LEFT JOIN "Measures" on "Product"."Measure_ID" = "Measures"."Measure_ID"
WHERE "Measure" = 'шт';

COMMIT;
/* работает также как и READ COMMITED потому что в PostreSQL реализовано так */





/* READ UNCOMMITED потерянные изменения */
BEGIN;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

DECLARE V1 INT;

SELECT V1="Measure_ID" FROM "Product" WHERE "Product_name" = 'Пассатижи';

UPDATE "Product" SET "Measure_ID" = V1+1 WHERE "Product_name" = 'Пассатижи';

SELECT "Product_name", "Measure" 
FROM  "Product" LEFT JOIN "Measures" on "Product"."Measure_ID" = "Measures"."Measure_ID";

COMMIT;





/*проверка READ COMMITED на грязные чтения и неповторяющиесы чтения */
BEGIN;
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

SELECT "Product_name", "Measure" 
FROM  "Product" LEFT JOIN "Measures" on "Product"."Measure_ID" = "Measures"."Measure_ID"
WHERE "Measure" = 'шт';

SELECT "Product_name", "Measure" 
FROM  "Product" LEFT JOIN "Measures" on "Product"."Measure_ID" = "Measures"."Measure_ID"
WHERE "Measure" = 'шт';

COMMIT;
/* мы видим что изменения которые были закоммичены мы читать можем, а те, которые не были завершены - еще не можем */
/* были продемонстрированы неповторяемое чтение и фантомное чтение */
/* грязные чтения невозможны в PostreSQL */





/*проверка REPEATABLE READ */
BEGIN;
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;

SELECT "Product_name", "Measure" 
FROM  "Product" LEFT JOIN "Measures" on "Product"."Measure_ID" = "Measures"."Measure_ID"
WHERE "Measure" = 'шт';

COMMIT;
/* фантомов и неповторяемых чтений нет */
/* неповторяемые чтения невозможны при данном уровне изоляции */
/* фантомы возможны, но PostgreSQL их не допускает */





/*проверка REPEATABLE READ на ошибку сериализации */
BEGIN;
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;

SELECT "Product_name", "Measure" 
FROM  "Product" LEFT JOIN "Measures" on "Product"."Measure_ID" = "Measures"."Measure_ID"
WHERE "Measure" = 'шт';


UPDATE "Product" SET "Product_name" = 'Отвертка плоская большая' WHERE "Product_name" = 'Отвертка плоская';


UPDATE "Product" SET "Product_name" = 'Отвертка крестовая большая' WHERE "Product_name" = 'Отвертка крестовая';
/* происходит зависание - ждем конца параллельной транзакции */
/* после коммита в параллельной транзакции мы получаем ошибку */

SELECT "Product_name", "Measure" 
FROM  "Product" LEFT JOIN "Measures" on "Product"."Measure_ID" = "Measures"."Measure_ID"
WHERE "Measure" = 'шт';

COMMIT;
/* проверка аномалии сериализации. Две транзакции меняют одну и ту же строку */
/* при откате одной из них, вторая работает как нужно */
/* при коммите одной из них - вторая завершается с ошибкой */

/* возврат к начальным условиям */
UPDATE "Product" SET "Product_name" = 'Отвертка крестовая' WHERE "Product_name" = 'Отвертка крестовая большая';





/*проверка SERIALIZABLE */
BEGIN;
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

SELECT "Product_name", "Measure" 
FROM  "Product" LEFT JOIN "Measures" on "Product"."Measure_ID" = "Measures"."Measure_ID"
WHERE "Measure" = 'шт';

COMMIT;
/* фантомов нет, так как этот уровень изоляции избавляет нас от них */