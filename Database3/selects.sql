/* Полная таблица по доставкам */
SELECT "Customer_name",
       "Fact"."Supply_ID",
       "Supply"."Address"->'street' Customer_street,
       "Supply"."Address"->'building' Customer_address,
       "Comment",
       "Full_date",
       "Store_name",
       "City",
       "Company"."Address" Store_address,
       "Product_name",
       "Measure",
       "Amount"
FROM ((("Fact" LEFT JOIN "Company" ON "Company"."Store_ID" = "Fact"."Store_ID")
    LEFT JOIN "Date" ON "Date"."Date_ID" = "Fact"."Date_ID")
    LEFT JOIN "Product" ON "Fact"."Product_ID" = "Product"."Product_ID")
    LEFT JOIN "Supply" ON "Fact"."Supply_ID" = "Supply"."Supply_ID"
ORDER BY "Customer_name", "Supply_ID", "Store_name"
LIMIT 150;
/* работает 1 минуту 40 секунд - 2 минуты без индекса */

-- SELECT * FROM "Supply" WHERE "Customer_name" LIKE 'Майоров%';

SELECT "Customer_name", "Full_date"
FROM ("Fact" LEFT JOIN "Date" ON "Date"."Date_ID" = "Fact"."Date_ID")
    LEFT JOIN "Supply" ON "Fact"."Supply_ID" = "Supply"."Supply_ID";

