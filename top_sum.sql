SELECT DISTINCT passenger_name AS "name", 
	count(book_ref) AS "number of bookings", 
	to_char(sum(total_amount), '999 999 999 L') AS "sum"
FROM bookings INNER JOIN Tickets USING (book_ref)
GROUP BY "name"
ORDER BY "number of bookings" DESC
LIMIT 15;

/* таблица, отражающая суммы, которые потратили на бронирования люди по именам
если считать что имена уникальны */