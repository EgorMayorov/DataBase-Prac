INSERT INTO "Product_Price" ("Product_ID", "Date", "Price") VALUES
    (1, date('2017-10-01'), 100000); /* добавление нового значения */

SELECT * FROM "Product_Price";

UPDATE "Product_Price" SET "Price" = 150 WHERE "Price" = 100000; /* изменение цены */

UPDATE "Product_Price" SET "Price" = "Price"*10; /* изменение всех значений в таблице */

UPDATE "Product_Price" SET "Price" = "Price"/10; /* изменение всех значений в таблице */

UPDATE "Product_Price" SET "Date" = '2017-11-01', "Price" = 200 WHERE "Price" = 150; /* обновление двух столбцов */

DELETE FROM "Product_Price" WHERE "Price" = 200; /* обновление цены */

UPDATE "Product_Price" SET "Price" = NULL WHERE "Price" = 200; /* ошбика из-за ограничения check */

/* таблица с кучей данных */
SELECT "Company"."Name" as "Company name",
       "Address" as "Compsny address",
       "Delivery_address",
       "Date" as "Supply date",
       "Race_ID",
       "Travel_time",
       "Model" as "Transport Model",
       "Production_date" as "Transport production date",
       "Surname" as "Driver surname",
       "Driver"."Name" as "Driver name",
       "Patronymic" as "Driver patonymic",
       "Birth_date" as "Driver birth date",
       "License_date" as "Driver license date"
FROM (((("Race" LEFT JOIN "Transport" on "Race"."Transport_ID" = "Transport"."Transport_ID") LEFT JOIN "Driver" on "Race"."Driver_ID" = "Driver"."Driver_ID")
LEFT JOIN "Supplies" on "Race"."Supply_ID" = "Supplies"."Supply_ID") LEFT JOIN "Company" on "Company"."Store_ID" = "Supplies"."Store_ID");


DELETE FROM "Company" WHERE "Address" = 'ул. Бурова, д. 1'; /* удаление с delete cascade */
SELECT * FROM "Company";
SELECT * FROM "Supplies";
SELECT * FROM "Race";
SELECT * FROM "Race&Product";
SELECT "Company"."Store_ID", "Company"."Name", "Company"."Address", "Supply_ID","Delivery_address"
FROM "Company" RIGHT JOIN "Supplies" S on "Company"."Store_ID" = S."Store_ID";
/* таблицы, которые изменятся */

DELETE FROM "Measures" WHERE "Measure" = 'кг'; /* нельзя удалить из-за delete restrict */
SELECT "Product_name", "Price", "Measure"
FROM ("Product" LEFT JOIN "Product_Price" PP on "Product"."Product_ID" = PP."Product_ID") LEFT JOIN "Measures" on "Product"."Measure_ID" = "Measures"."Measure_ID";

UPDATE "Measures" SET "Measure" = NULL WHERE "Measure" = 'кг'; /* нельзя обновить из-за NOT NULL */
SELECT * FROM "Measures";

UPDATE "Company" SET "Store_ID" = 1 WHERE "Store_ID" = 2; /* нарушение Primary Key */
SELECT * FROM "Company";

/* выбор последней цены среди всех данных о ценах */
SELECT PP.*
FROM    "Product_Price" PP
    INNER JOIN(
        SELECT  "Product_ID", MAX("Date") mdate
        FROM    "Product_Price"
        GROUP   BY "Product_ID"
    ) PPmd ON PP."Product_ID" = PPmd."Product_ID"
        AND PP."Date" = PPmd.mdate;

/* вывести продукты, цена которых неизвестна */
INSERT INTO "Product" ("Product_name", "Measure_ID") VALUES ('Пропитка наружняя для деревянных домов', 4);
DELETE FROM "Product" WHERE "Product_name" = 'Пропитка наружняя для деревянных домов';
/* SELECT * FROM "Product";
SELECT * FROM "Product_Price"; */
SELECT "Product_name", "Price"
FROM "Product" LEFT JOIN "Product_Price" PP on "Product"."Product_ID" = PP."Product_ID"
EXCEPT
SELECT "Product_name", "Price"
FROM "Product" INNER JOIN "Product_Price" PP on "Product"."Product_ID" = PP."Product_ID";

/* вывести стоимость продуктов в выбранном рейсе */
SELECT "R&P"."Race_ID", sum("Amount" * "Price")
FROM (("Race" RIGHT JOIN "Race&Product" "R&P" on "Race"."Race_ID" = "R&P"."Race_ID")
    LEFT JOIN "Product" on "R&P"."Product_ID" = "Product"."Product_ID")
    LEFT JOIN "Product_Price" on "R&P"."Product_ID" = "Product_Price"."Product_ID"
/* WHERE "R&P"."Race_ID" = 1 */
GROUP BY "R&P"."Race_ID"
ORDER BY "Race_ID";

/* вывод данных о количестве и стоимости продуктов в каждом рейсе */
SELECT "R&P"."Race_ID", "Product_name", "Amount", "Price"
FROM (("Race" RIGHT JOIN "Race&Product" "R&P" on "Race"."Race_ID" = "R&P"."Race_ID")
    LEFT JOIN "Product" on "R&P"."Product_ID" = "Product"."Product_ID")
    LEFT JOIN "Product_Price" on "R&P"."Product_ID" = "Product_Price"."Product_ID"
ORDER BY "Race_ID";