SELECT flight_no, count(*) AS num FROM flights
WHERE scheduled_departure BETWEEN make_date(2017, 06, 01) AND make_date(2017, 06, 30)
GROUP BY flight_no
ORDER BY num DESC
LIMIT 50;

-- вывести топ 50 номеров рейса по количеству вылетов в июне 2017 года