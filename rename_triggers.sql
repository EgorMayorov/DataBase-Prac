DROP FUNCTION IF EXISTS full_rename_1() CASCADE;
DROP FUNCTION IF EXISTS full_rename_2() CASCADE;

/* Функция, изменяющая таблицу "Race&Product" при изменениии таблицы "Product&Price" */
CREATE FUNCTION full_rename_1() RETURNS TRIGGER AS $rename1$
    BEGIN
        ALTER TABLE "Race&Product" DISABLE TRIGGER rename_product_2;
        UPDATE "Race&Product" SET "Product_name" = "Product&Price"."Product_name"
            FROM "Product&Price"
            WHERE "Product&Price"."Product_ID" = "Race&Product"."Product_ID"
                AND "Race&Product"."Product_name" != "Product&Price"."Product_name";
        ALTER TABLE "Race&Product" ENABLE TRIGGER rename_product_2;
        RETURN NULL;
    END;
$rename1$ LANGUAGE plpgsql;

/* Функция, изменяющая таблицу "Product&Price" при изменениии таблицы "Race&Product" */
CREATE FUNCTION full_rename_2() RETURNS TRIGGER AS $rename2$
    BEGIN
        ALTER TABLE "Product&Price" DISABLE TRIGGER rename_product_1;
        UPDATE "Product&Price" SET "Product_name" = "Race&Product"."Product_name"
            FROM "Race&Product"
            WHERE "Product&Price"."Product_ID" = "Race&Product"."Product_ID"
                AND "Race&Product"."Product_name" != "Product&Price"."Product_name";
        ALTER TABLE "Product&Price" ENABLE TRIGGER rename_product_1;
        RETURN NULL;
    END;
$rename2$ LANGUAGE plpgsql;

/* Триггеры, срабатывающие при изменениии таблиц "Product&Price" и "Race&Product" */
CREATE TRIGGER rename_product_1 AFTER UPDATE ON "Product&Price" FOR EACH STATEMENT EXECUTE FUNCTION full_rename_1();
CREATE TRIGGER rename_product_2 AFTER UPDATE ON "Race&Product" FOR EACH STATEMENT EXECUTE FUNCTION full_rename_2();




/* Проверка работы триггеров на изменение наименования продукта */
/*
SELECT "Product_name" PrPr FROM "Product&Price" GROUP BY "Product_name" ORDER BY "Product_name";
SELECT "Product_name" RaPr FROM "Race&Product" GROUP BY "Product_name" ORDER BY "Product_name";

UPDATE "Product&Price" SET "Product_name" = "Product_name" || ' 1'::text --WHERE "Product_name" = 'Пассатижи';

SELECT "Product_name" PrPr FROM "Product&Price" GROUP BY "Product_name" ORDER BY "Product_name";
SELECT "Product_name" RaPr FROM "Race&Product" GROUP BY "Product_name" ORDER BY "Product_name";

UPDATE "Race&Product" SET "Product_name" = "Product_name" || ' 2'::text --WHERE "Product_name" = 'Пассатижи';

SELECT "Product_name" PrPr FROM "Product&Price" GROUP BY "Product_name" ORDER BY "Product_name";
SELECT "Product_name" RaPr FROM "Race&Product" GROUP BY "Product_name" ORDER BY "Product_name";
*/
