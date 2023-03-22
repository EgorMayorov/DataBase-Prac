DROP FUNCTION IF EXISTS get_names(date1 date, date2 date);
DROP FUNCTION IF EXISTS amount_check(int);

/* функция, возвращающая таблицу с именами людей, которые делали покупки в выбранный период */
CREATE OR REPLACE FUNCTION get_names(date1 date, date2 date) RETURNS TABLE ("name" text) AS $$
    DECLARE
        rec RECORD;
    BEGIN
        IF (SELECT "current_user"())::text != 'postgres'::text THEN
            RAISE EXCEPTION 'Функция создана для пользователя postgres';
        ELSE
            FOR rec IN EXECUTE 'SELECT "Customer_name", "Full_date"
                                FROM ("Fact" LEFT JOIN "Date" ON "Date"."Date_ID" = "Fact"."Date_ID")
                                    LEFT JOIN "Supply" ON "Fact"."Supply_ID" = "Supply"."Supply_ID";'
                LOOP
                    IF (rec."Full_date" between $1 AND $2) THEN
                        "name" = rec."Customer_name";
                        RETURN next;
                    END IF;
                end loop;
        end if;
    end;
$$ LANGUAGE plpgsql;

create role aaa LOGIN;
grant select on "Fact", "Supply", "Date" to aaa;
set role aaa;
SELECT "current_user"();
SELECT DISTINCT * FROM get_names('2020-11-01'::date, current_date);
reset role;
revoke select on "Fact", "Supply" from aaa;
drop role aaa;

/* пример работы функции */
SELECT DISTINCT * FROM get_names('2020-11-01'::date, current_date);

/*
SELECT "Customer_name", sum("Amount")
FROM "Fact" LEFT JOIN "Supply" S ON S."Supply_ID" = "Fact"."Supply_ID"
GROUP BY "Customer_name";
*/

/* пример функции с использованием курсора */
CREATE OR REPLACE FUNCTION amount_check(int) RETURNS TABLE ("name" text, "amount" int) AS $$
    DECLARE
        curs CURSOR FOR SELECT "Customer_name", sum("Amount")
                        FROM "Fact" LEFT JOIN "Supply" S ON S."Supply_ID" = "Fact"."Supply_ID"
                        GROUP BY "Customer_name";
        _name text;
        _amount int;
    BEGIN
        OPEN curs;
        LOOP
            FETCH curs INTO _name, _amount;
            EXIT WHEN NOT FOUND;
            IF _amount >= $1 THEN
                "name" = _name;
                "amount" = _amount;
                RETURN NEXT;
            END IF;
        end loop;
    end;
$$ LANGUAGE plpgsql;

SELECT * FROM amount_check(10);