SELECT DISTINCT make_date(
	date_part('year', scheduled_departure)::int, 
	date_part('month', scheduled_departure)::int, 
	date_part('day', scheduled_departure)::int
) AS "date_departue",
make_date(
	date_part('year', scheduled_arrival)::int, 
	date_part('month', scheduled_arrival)::int, 
	date_part('day', scheduled_arrival)::int
) AS "date_arrival"
FROM Flights
ORDER BY "date_departue", "date_arrival";

--узнать какие были даты вылета и прилета отсортированные по порядку, группированные по дням