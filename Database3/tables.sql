DROP TABLE IF EXISTS "Customer", "Supply", "Product", "Company", "Date", "Fact";

CREATE TABLE "Supply" (
  "Supply_ID" serial,
  "Customer_name" text NOT NULL,
  "Address" json NOT NULL,
  "Comment" text DEFAULT NULL,
  PRIMARY KEY ("Supply_ID")
);

DROP TYPE IF EXISTS measure;
CREATE TYPE measure AS ENUM ('кг', 'м3', 'л', 'шт', 'м2', 'м', 'не установлено');

CREATE TABLE "Product" (
  "Product_ID" serial,
  "Product_name" text NOT NULL,
  "Measure" measure DEFAULT 'не установлено' NOT NULL,
  PRIMARY KEY ("Product_ID")
);

CREATE TABLE "Company" (
  "Store_ID" serial,
  "Store_name" text NOT NULL,
  "City" text NOT NULL DEFAULT 'Москва',
  "Address" json NOT NULL,
  PRIMARY KEY ("Store_ID")
);

CREATE TABLE "Date" (
  "Date_ID" serial,
  "Full_date" date NOT NULL UNIQUE ,
  "Year" int NOT NULL,
  "Quarter" int NOT NULL,
  "Month" int NOT NULL,
  "Day" int NOT NULL,
  PRIMARY KEY ("Date_ID")
);

CREATE TABLE "Fact" (
  "Store_ID" int REFERENCES "Company" ON DELETE RESTRICT,
  "Supply_ID" int REFERENCES "Supply" ON DELETE RESTRICT,
  "Product_ID" int REFERENCES "Product" ON DELETE RESTRICT,
  "Date_ID" int REFERENCES "Date" ON DELETE RESTRICT,
  "Amount" int CONSTRAINT amount_check CHECK ("Amount" > 0) DEFAULT 1,
  UNIQUE ("Store_ID", "Supply_ID", "Product_ID", "Date_ID")
);

