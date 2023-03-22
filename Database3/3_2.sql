/* проверка возможностей ролей через терминал */
-- psql -U role -d database

-- \d[S+]                 список таблиц, представлений и последовательностей
-- \ddp    [МАСКА]        список прав по умолчанию
-- \dg[S+] [МАСКА]        список ролей
-- \dt[S+] [МАСКА]        список таблиц
-- \du[S+] [МАСКА]        список ролей
-- \dv[S+] [МАСКА]        список представлений
-- \l[+]   [МАСКА]        список баз данных
-- \dn[S+] [МАСКА]        список схем
-- \dp     [МАСКА]        список прав доступа к таблицам, представлениям и последовательностям

SELECT rolname FROM pg_roles;

CREATE VIEW view1 AS SELECT "Customer_name",
    "Full_date",
    "Store_name",
    "City",
    "Product_name",
    "Amount"
FROM ((("Fact" LEFT JOIN "Company" ON "Company"."Store_ID" = "Fact"."Store_ID")
    LEFT JOIN "Date" ON "Date"."Date_ID" = "Fact"."Date_ID")
    LEFT JOIN "Product" ON "Fact"."Product_ID" = "Product"."Product_ID")
    LEFT JOIN "Supply" ON "Fact"."Supply_ID" = "Supply"."Supply_ID"
ORDER BY "Customer_name", "Store_name";

CREATE VIEW view2 AS SELECT "City", "Store_name", "Product_name", sum("Amount")
FROM ("Fact" LEFT JOIN "Company" ON "Company"."Store_ID" = "Fact"."Store_ID")
    LEFT JOIN "Product" ON "Fact"."Product_ID" = "Product"."Product_ID"
GROUP BY "Store_name", "City", "Product_name"
ORDER BY "City", "Store_name";

SELECT * FROM view1;
SELECT * FROM view2;

/* роль, имеющая различные права доступа к таблицам */
CREATE ROLE role1 LOGIN;
GRANT SELECT, INSERT, UPDATE ON TABLE "Fact" TO role1;
GRANT SELECT ("Product_ID", "Product_name"), UPDATE ("Product_ID", "Product_name") ON TABLE "Product" TO role1;
GRANT SELECT ON TABLE "Supply", "Company", "Date" TO role1;
GRANT SELECT ON view1 TO role1;

/* Роль 2 позволяет создавать новые таблицы, новые функции. Роль 3 наследует права роли 2 */
CREATE ROLE role2 LOGIN;
CREATE ROLE role3 LOGIN;
GRANT ALL ON DATABASE db3 TO role2;
GRANT USAGE ON SCHEMA public TO role2;
GRANT SELECT, UPDATE ON view1 TO role2;
GRANT role2 TO role3;
-- Команды для демонстрации роли 2 или роли 3
/*
CREATE TABLE "T" ("T" int);
INSERT INTO "T" ("T") VALUES (1), (2), (3), (4), (5), (6), (7), (8), (9), (10);
SELECT * FROM "T";
\d  -- покажет какие есть таблицы
DROP TABLE "T";
*/

-- роль, которая может модифицировать таблицу, но не может читать ее
CREATE ROLE role4 LOGIN;
GRANT UPDATE ON "Product" TO role4;
-- эта команда не сработает, так как нужно еще предоставить SELECT
-- UPDATE "Product" SET "Product_name" = "Product_name" || '1';
-- а эта сработает
-- UPDATE "Product" SET "Product_name" = '1';


-- отнимаем права у ролей и удаляем их
REVOKE ALL ON TABLE "Fact", "Product", "Supply", "Date", "Company" FROM role1;
REVOKE ALL ON view1 FROM role1;
DROP ROLE IF EXISTS role1;

REVOKE ALL ON DATABASE db3 FROM role2;
REVOKE ALL ON SCHEMA public FROM role2;
REVOKE ALL ON view1 FROM role2;
DROP ROLE IF EXISTS role2;
DROP ROLE IF EXISTS role3;

REVOKE UPDATE ON "Product" FROM role4;
DROP ROLE IF EXISTS role4;

-- удаляем представлениия
DROP VIEW IF EXISTS view1, view2;


/*
Есть пользователь, у него куча ролей (больше 100), нужно запретить ему доступ к определенной таблице, не меняя все роли.
Если решение будет давать возможность перенести скрипт на другую машину, минус штраф.
Если при добавлении новой роли этому пользователю исключается возможность предоставления доступа к таблице, то +1 балл.
*/