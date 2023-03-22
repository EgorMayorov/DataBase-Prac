DROP TABLE "Company", "Supplies", "Transport", "Driver", "Race", "Race&Product", "Product", "Product_Price", "Measures";

CREATE TABLE "Company" (
    "Store_ID" SERIAL,
    "Name" text NOT NULL,
    "Address" text NOT NULL,
    PRIMARY KEY ("Store_ID")
);

CREATE TABLE "Supplies" (
    "Supply_ID" SERIAL,
    "Store_ID" int REFERENCES "Company" on delete cascade NOT NULL,
    "Delivery_address" text NOT NULL,
    "Date" date NOT NULL,
    PRIMARY KEY ("Supply_ID")
);

CREATE TABLE "Transport" (
    "Transport_ID" SERIAL,
    "Model" text NOT NULL,
    "Production_date" date NOT NULL,
    PRIMARY KEY ("Transport_ID")
);

CREATE TABLE "Driver" (
    "Driver_ID" SERIAL,
    "Surname" text NOT NULL,
    "Name" text NOT NULL,
    "Patronymic" text,
    "Birth_date" date NOT NULL,
    "License_date" date NOT NULL,
    PRIMARY KEY ("Driver_ID"),
    CONSTRAINT age_check CHECK ( "License_date" > "Birth_date" + interval'18 years')
);

CREATE TABLE "Race" (
    "Race_ID" SERIAL,
    "Supply_ID" int REFERENCES "Supplies" on delete cascade NOT NULL,
    "Transport_ID" int REFERENCES "Transport" on delete restrict NOT NULL,
    "Driver_ID" int REFERENCES "Driver" on delete restrict NOT NULL,
    "Travel_time" interval,
    PRIMARY KEY ("Race_ID")
);

CREATE TABLE "Measures" (
    "Measure_ID" SERIAL,
    "Measure" text NOT NULL UNIQUE,
    PRIMARY KEY ("Measure_ID")
);

CREATE TABLE "Product" (
    "Product_ID" SERIAL,
    "Product_name" text NOT NULL,
    "Measure_ID" int REFERENCES "Measures" on delete restrict NOT NULL,
    PRIMARY KEY ("Product_ID"),
    UNIQUE ("Product_ID", "Product_name")
);

CREATE TABLE "Race&Product" (
    "Race_ID" int REFERENCES "Race" on delete cascade NOT NULL,
    "Product_ID" int REFERENCES "Product" on delete cascade NOT NULL,
    "Amount" int NOT NULL CONSTRAINT amount_check CHECK ( "Amount" > 0 ) DEFAULT 10,
    UNIQUE ("Product_ID", "Race_ID")
);

CREATE TABLE "Product_Price" (
    "Product_ID" int REFERENCES "Product" on delete cascade NOT NULL,
    "Date" date NOT NULL CHECK ( "Date" < current_date ),
    "Price" numeric(10, 2) NOT NULL CONSTRAINT price_check CHECK ( "Price" > 0 )
);
/* написать скрипт который внесет изменения в структуру БД с изменением < на <= в 68 строке без потери данных
   написано ниже!! */

INSERT INTO "Company" ("Name", "Address") VALUES
    ('СтройлоН', 'ул. Щукина, д. 12'),
    ('СтройлоН', 'ул. Флотская, д. 14'),
    ('СтройлоН', 'ул. Крахмалева, д. 31'),
    ('СтройлоН', 'ул. Медведева, д. 55'),
    ('СтройлоН', 'ул. Авиационная, д. 18'),
    ('МегаСтрой', 'ул. Ромашина, д. 4'),
    ('МегаСтрой', 'ул. Емлютина, д. 37'),
    ('МегаСтрой', 'ул. Бурова, д. 1'),
    ('МегаСтрой', 'пр-т. Ленина, д. 97'),
    ('МегаСтрой', 'пр-т. Московский, д. 72');

/*SELECT * FROM "Company";*/

INSERT INTO "Supplies" ("Store_ID", "Delivery_address", "Date") VALUES
    (1, 'ул. Советская, д. 69', date('2019-06-26')),
    (2, 'ул. Тютчева, д. 4', date('2020-07-23')),
    (3, 'ул. Фокина, д. 116', date('2018-03-04')),
    (4, 'ул. Крахмалева, д. 53', date('2021-04-29')),
    (5, 'ул. Горбатова, д. 18', date('2022-01-01')),
    (6, 'ул. Объездная, д. 2', date('2021-06-02')),
    (7, 'пер. Пилотов, д. 6', date('2018-09-25')),
    (8, 'ул. Романа Брянского, д. 2/1', date('2020-11-14')),
    (9, 'ул. Ульянова, д. 122', date('2021-08-16')),
    (10, 'ул. Литейная, д. 30', date('2022-04-09'));

/*SELECT * FROM "Supplies";*/

INSERT INTO "Transport" ("Model", "Production_date") VALUES
    ('Mercedes_Benz Actros', date('2016-02-01')),
    ('Mercedes_Benz Actros', date('2017-04-05')),
    ('MAN TGX', date('2017-01-13')),
    ('MAN TGX', date('2016-08-15')),
    ('SCANIA S500', date('2018-05-16')),
    ('SCANIA S500', date('2017-10-28')),
    ('SCANIA S450', date('2017-05-31')),
    ('VOLVO FH16', date('2016-04-20')),
    ('VOLVO FH12', date('2017-03-23')),
    ('VOLVO VN', date('2018-04-02'));

/*SELECT * FROM "Transport";*/

INSERT INTO "Driver" ("Surname", "Name", "Patronymic", "Birth_date", "License_date") VALUES
    ('Игнатов', 'Евгений','Романович', date('1994-08-20'), date('2016-10-19')),
    ('Лысенко', 'Виталий','Сергеевич', date('1996-07-12'), date('2016-02-01')),
    ('Иванов', 'Петр','Артемович', date('1994-09-20'), date('2017-09-09')),
    ('Резников', 'Илья','Андреевич', date('1995-10-29'), date('2017-05-17')),
    ('Рымарев', 'Роман','Олегович', date('1994-03-27'), date('2017-01-29')),
    ('Чижиков', 'Никита','Степанович', date('1996-02-25'), date('2016-04-27')),
    ('Лемешов', 'Александр','Александрович', date('1995-05-17'), date('2017-09-30')),
    ('Мирошкин', 'Макисм','Петрович', date('1994-04-24'), date('2016-01-07')),
    ('Самородский', 'Никита','Романович', date('1995-06-15'), date('2017-05-03')),
    ('Петров', 'Иван','Юрьевич', date('1996-12-13'), date('2017-03-22'));

/*SELECT * FROM "Driver";*/

INSERT INTO "Measures" ("Measure") VALUES
    ('кг'),
    ('шт'),
    ('м3'),
    ('л'),
    ('м2'),
    ('м');
/*в эту таблицу сложно добавить 10 измерений*/

/*SELECT * FROM "Measures";*/

INSERT INTO "Product" ("Product_name", "Measure_ID") VALUES
    ('ДСП', 5),
    ('Труба 50х50 металл', 6),
    ('Гвозди', 1),
    ('Краска красная по дереву', 4),
    ('Отвертка крестовая', 2),
    ('Отвертка плоская', 2),
    ('Пассатижи', 2),
    ('Уеплитель Стекловолокно', 3),
    ('Земля чернозем', 1),
    ('Фанера 9мм', 5);

/*SELECT * FROM "Product";*/

INSERT INTO "Product_Price" ("Product_ID", "Date", "Price") VALUES
    (1, date('2017-01-01'), 500),
    (2, date('2017-01-01'), 1500),
    (3, date('2017-01-01'), 1200),
    (4, date('2017-01-01'), 350),
    (5, date('2017-01-01'), 600),
    (6, date('2017-01-01'), 500),
    (7, date('2017-01-01'), 900),
    (8, date('2017-01-01'), 250),
    (9, date('2017-01-01'), 30),
    (10, date('2017-01-01'), 950);

/*SELECT * FROM "Product_Price";*/

INSERT INTO "Race" ("Supply_ID", "Transport_ID", "Driver_ID", "Travel_time") VALUES
    (1, 1, 1, interval'1:00:00'),
    (2, 2, 2, interval'2:00:00'),
    (3, 3, 3, interval'3:00:00'),
    (4, 4, 4, interval'1:30:00'),
    (5, 5, 5, interval'1:50:00'),
    (6, 6, 6, interval'2:50:00'),
    (7, 7, 7, interval'1:20:00'),
    (8, 8, 8, interval'0:40:00'),
    (9, 9, 9, interval'1:35:00'),
    (10, 10, 10, interval'0:55:00'),
    (1, 3, 6, interval'1:30:00'),
    (1, 4, 7, interval'1:00:00'),
    (2, 6, 5, interval'0:35:00'),
    (3, 7, 8, interval'2:30:00'),
    (4, 1, 9, interval'1:05:00'),
    (5, 2, 10, interval'1:15:00'),
    (6, 9, 4, interval'1:25:00'),
    (7, 8, 3, interval'0:45:00'),
    (8, 5, 2, interval'1:05:00'),
    (9, 10, 1, interval'1:20:00');

/*SELECT * FROM "Race";*/

INSERT INTO "Race&Product" ("Race_ID", "Product_ID", "Amount") VALUES
    (1, 1, 100),
    (2, 2, 40),
    (3, 3, 300),
    (4, 4, 150),
    (5, 5, 1000),
    (6, 6, 1000),
    (7, 7, 700),
    (8, 8 ,8),
    (9, 9, 1400),
    (10, 10, 130),
    (11, 1, 50),
    (12, 2, 20),
    (13, 3, 200),
    (14, 4, 120),
    (15, 5, 1000),
    (16, 6, 1000),
    (17, 7, 750),
    (18, 8, 10),
    (19, 9, 1600),
    (20, 10, 120),
    (1, 3, 330),
    (2, 4, 100),
    (3, 5, 1000),
    (4, 6, 1000),
    (5, 7, 650),
    (6, 8, 6),
    (7, 9, 1200),
    (8, 10, 115),
    (9, 1, 80),
    (10, 2, 50),
    (11, 3, 140),
    (12, 4, 140),
    (13, 5, 1000),
    (14, 6, 1000),
    (15, 7, 700),
    (16, 8, 7),
    (17, 9, 1500),
    (18, 10, 140),
    (19, 1, 75),
    (20, 2, 35);

/*SELECT * FROM "Race&Product";*/

/*
SELECT "Product_name", "Price", "Measure"
FROM ("Product" LEFT JOIN "Product_Price" PP on "Product"."Product_ID" = PP."Product_ID") LEFT JOIN "Measures" on "Product"."Measure_ID" = "Measures"."Measure_ID";
*/

/* данные по рейсам (без продуктов) */
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

/*
ALTER TABLE "Product_Price"
    DROP CONSTRAINT "Product_Price_Date_check",
    ADD CONSTRAINT date_check CHECK ( "Date" <= current_date );
*/