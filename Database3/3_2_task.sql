SELECT rolname FROM pg_roles;

/* создание пользователя */
create role usr1 LOGIN;
drop role usr1;

/* выдаем пользователю какие-то роли */
grant role1 to usr1;
grant role2 to usr1;
grant role3 to usr1;
grant role4 to usr1;


/* запрос, показывающий какие роли принадлежат пользователю usr1 */
select unnest(ARRAY(select b.rolname
    from pg_catalog.pg_auth_members m
    join pg_catalog.pg_roles b on (m.roleid = b.oid)
    where m.member = r.oid)) as memberof
from pg_catalog.pg_roles r
where r.rolname = 'usr1';

/* покажет какие права есть у роли, кроме прав в требуемой таблице "Product" */
SELECT table_name, privilege_type
FROM information_schema.table_privileges
WHERE grantee = 'role1'
AND table_name != 'Product';

/* запрос, показывающие какие права есть у пользователя usr1 (кроме требуемой таблицы "Product") */
SELECT DISTINCT table_name as tn, privilege_type as pt
FROM information_schema.table_privileges
WHERE grantee = any(select
    unnest(ARRAY(
        select b.rolname
        from pg_catalog.pg_auth_members m
        join pg_catalog.pg_roles b on (m.roleid = b.oid)
        where m.member = r.oid)) as memberof
    from pg_catalog.pg_roles r
    where r.rolname = 'usr1')
AND table_name != 'Product';



/* Функция, создающая новую роль с нужными правами для выбранного пользователя */
/* аругменты функции - имя пользователя, имя новой роли для него, имя таблицы */
CREATE OR REPLACE FUNCTION deny_table(text, text, text) RETURNS void AS $$
    DECLARE
        str RECORD;
    BEGIN
        IF $2 IN (select unnest(ARRAY(select b.rolname
                        from pg_catalog.pg_auth_members m
                        join pg_catalog.pg_roles b on (m.roleid = b.oid)
                        where m.member = r.oid)) as memberof
                    from pg_catalog.pg_roles r
                    where r.rolname = $1) THEN
            RAISE EXCEPTION 'You have to rename new role';
        END IF;
        EXECUTE format('create role %s login;', $2);
        FOR str IN (SELECT DISTINCT table_name as tn, privilege_type as pt
                    FROM information_schema.table_privileges
                    WHERE grantee = any(select
                        unnest(ARRAY(
                            select b.rolname
                            from pg_catalog.pg_auth_members m
                            join pg_catalog.pg_roles b on (m.roleid = b.oid)
                            where m.member = r.oid)) as memberof
                        from pg_catalog.pg_roles r
                        where r.rolname = $1)
                    AND table_name != $3)
            LOOP
                EXECUTE format('grant %s on %I to %s;', str.pt, str.tn, $2);
            END LOOP;
        FOR str IN (select unnest(ARRAY(select b.rolname
                        from pg_catalog.pg_auth_members m
                        join pg_catalog.pg_roles b on (m.roleid = b.oid)
                        where m.member = r.oid)) as memberof
                    from pg_catalog.pg_roles r
                    where r.rolname = $1)
            LOOP
                EXECUTE format('revoke %s from %s;', str.memberof, $1);
            END LOOP;
        EXECUTE format('grant %s to %s;', $2, $1);
    END;
$$ LANGUAGE plpgsql;

SELECT deny_table('usr1', 'usr1_new_role', 'Product');

/* можно забрать права у новой роли и удалить ее (например, для тестирования) */
revoke all on table "Fact", "Company", "Supply", "Date" from usr1_new_role;
drop role usr1_new_role;


/* event trigger для обработки команды grant */
/* можно попробовать использовать его вместе с функцией выше */
/* но он не срабатывает при присваивании пользователю новой роли */
CREATE OR REPLACE FUNCTION no_access() RETURNS event_trigger AS $$
    BEGIN
        IF "current_user"() = 'postgres' THEN
            -- SELECT * FROM pg_event_trigger_ddl_commands();
            RAISE EXCEPTION 'event:%, command:%', tg_event, tg_tag;
        END IF;
    END;
$$ LANGUAGE plpgsql;

CREATE EVENT TRIGGER no_access_tr ON ddl_command_start
    WHEN TAG IN ('GRANT') EXECUTE PROCEDURE no_access();

DROP EVENT TRIGGER no_access_tr;
DROP FUNCTION no_access();




create role aaa;
/* триггер не сработает */
GRANT aaa to usr1;
/* триггер сработает */
GRANT SELECT ON "Product" to aaa;

revoke  select on "Product" from aaa;
drop role aaa;









/* триггер на изменение системной таблицы с пользователями и ролями */

SELECT has_table_privilege('usr1', '"Product"', 'SELECT, UPDATE, INSERT, TRUNCATE');

SELECT * FROM pg_auth_members;
SELECT * FROM pg_roles;

/* oid пользователя */
select distinct oid
from pg_catalog.pg_auth_members m
    join pg_catalog.pg_roles b on (m.member = b.oid)
WHERE rolname = 'usr1';

/* мя роли по roleid */
select rolname
from pg_catalog.pg_roles
WHERE oid = 50498;

/* таблицы к которым имеет доступ пользователь с выбранным roleid */
SELECT distinct table_name
FROM information_schema.table_privileges
WHERE grantee = (select rolname
                    from pg_catalog.pg_roles
                    WHERE oid = 50489);

/*
SELECT 'Product' IN (SELECT DISTINCT table_name
FROM information_schema.table_privileges
WHERE grantee = any(select
    unnest(ARRAY(
        select b.rolname
        from pg_catalog.pg_auth_members m
        join pg_catalog.pg_roles b on (m.roleid = b.oid)
        where m.member = r.oid)) as memberof
    from pg_catalog.pg_roles r
    where r.rolname = 'usr1'));
*/

CREATE OR REPLACE FUNCTION f() RETURNS TRIGGER AS $$
    BEGIN
        IF (NEW.member = (select distinct oid
                            from pg_catalog.pg_auth_members m
                                join pg_catalog.pg_roles b on (m.member = b.oid)
                            WHERE rolname = 'usr1'))
            AND (SELECT 'Product' IN (SELECT distinct table_name
                                        FROM information_schema.table_privileges
                                        WHERE grantee = (select rolname
                                                            from pg_catalog.pg_roles
                                                            WHERE oid = NEW.roleid)))
            THEN
                --RETURN NULL;
                RAISE EXCEPTION 'You cannot give such role';
        ELSE
            RETURN NEW;
        END IF;
    END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER try_to_avoid_table BEFORE INSERT OR UPDATE ON pg_auth_members
    FOR EACH ROW EXECUTE FUNCTION f();

DROP TRIGGER IF EXISTS try_to_avoid_table;

CREATE VIEW role_view AS
    select unnest(ARRAY(select b.rolname
        from pg_catalog.pg_auth_members m
        join pg_catalog.pg_roles b on (m.roleid = b.oid)
        where m.member = r.oid)) as memberof
    from pg_catalog.pg_roles r
    where r.rolname = 'usr1';

SELECT * FROM role_view;

DROP VIEW role_view;

CREATE OR REPLACE RULE deny_access_to_usr AS ON SELECT
TO "Product" WHERE ("current_user"() = 'usr1')
DO INSTEAD SELECT NULL;

SELECT * FROM "Product";
