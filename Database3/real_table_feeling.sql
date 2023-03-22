/* Заполнение таблиц большим количеством данных */

copy "Supply" from '/home/egor/PracDB/Supply.txt';
select * from "Supply";
select count(*) from "Supply";

copy "Product" from '/home/egor/PracDB/Product.txt';
select * from "Product";
select count(*) from "Product";

copy "Date" from '/home/egor/PracDB/Date.txt';
select * from "Date";
select count(*) from "Date";

copy "Company" from '/home/egor/PracDB/Company.txt';
select * from "Company";
select count(*) from "Company";

/* на 58 миллионах строк закончилась память (было съедено 5,8Гб) */
/* таблица будет на 40 миллионов строк */
copy "Fact" from '/home/egor/PracDB/Fact.txt';
select * from "Fact";
select count(*) from "Fact";
/* Только эта таблица заняла примерно 3,3Гб памяти */
/* 40,000,000 rows affected in 1 h 16 m 13 s 575 ms - (с внешним ключем и ограничением уникальноости) */

-- vacuum full;
vacuum analyse;
