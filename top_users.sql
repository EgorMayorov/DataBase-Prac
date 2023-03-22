SELECT DISTINCT passenger_name, count(*) AS "number of bookings"
FROM Tickets
WHERE passenger_name LIKE 'EGOR%'
GROUP BY passenger_name
ORDER BY "number of bookings" DESC
LIMIT 25;

/* топ 25 пользователей с именем EGOR по количеству купленных билетов
тут считаем, что имена у каждого пользователя сервисом уникальные */