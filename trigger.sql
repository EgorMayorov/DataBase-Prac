DROP FUNCTION IF EXISTS func_1() CASCADE;
CREATE FUNCTION func_1() RETURNS TRIGGER AS $tr$
	BEGIN
		IF NEW."Product_name" in (select "Product_name" from "Product" where "Product_name" = NEW."Product_name")
			THEN
				RAISE 'Такой продукт уже существует';
			END IF;
			RETURN NEW;
	END
$tr$ LANGUAGE plpgsql;
/* функция не позволит нам внести в таблицу название уже имеющегося продукта */

CREATE TRIGGER tr_1 BEFORE INSERT or UPDATE ON "Product" FOR EACH ROW EXECUTE FUNCTION func_1(); 

/* посмотрим какая таблица есть сейчас */
SELECT "Product_name", "Measure" 
FROM  "Product" LEFT JOIN "Measures" on "Product"."Measure_ID" = "Measures"."Measure_ID";

/* попробуем внести недопустимые с точки зрения функции изменения в таблицу */
INSERT INTO "Product" ("Product_name", "Measure_ID") VALUES ('Пассатижи', 1);
UPDATE "Product" SET "Product_name" = 'Пассатижи' WHERE "Product_name" = 'Отвертка плоская';
/* при выполнении обоих запросов мы получаем ошибку */

/* попробуем внести корректные изменения */
INSERT INTO "Product" ("Product_name", "Measure_ID") VALUES ('Саморезы кровельные', 1);
/* выполняется верно, без ошибок, триггер не срабатывает */

/*посмотрим на измененную таблицу */
SELECT "Product_name", "Measure" 
FROM  "Product" LEFT JOIN "Measures" on "Product"."Measure_ID" = "Measures"."Measure_ID";

/* удаляем лишнюю строку, чтобы вернуться к первоначальному виду таблицы */
DELETE FROM "Product" WHERE "Product_name" = 'Саморезы кровельные';

/* посмотрим на измененную таблицу */
SELECT "Product_name", "Measure" 
FROM  "Product" LEFT JOIN "Measures" on "Product"."Measure_ID" = "Measures"."Measure_ID";
