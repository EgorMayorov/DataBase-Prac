-- пары городов, которые наиболее хорошо соединены авиалиниями (между которыми чаще всего летали самолеты)

SELECT airports.city AS "departure_airport", arr.city AS arrival_airport, count(flight_no) AS num
FROM (flights LEFT JOIN Airports AS arr ON flights.arrival_airport = arr.airport_code)
	LEFT JOIN airports ON flights.departure_airport = airports.airport_code
WHERE scheduled_departure BETWEEN make_date(2017, 06, 01) AND make_date(2017, 06, 30)
GROUP BY airports.city, arr.city
ORDER BY num DESC
LIMIT 10;