-- 01 Получите список районов Нью-Йорка, при поездке из которых суммарная оплата наличными за всё время наблюдения составила более $500000. 
--При суммировании учитывайте только положительные суммы оплаты поездки.

SELECT pickup_ntaname -- или SUM(м) AS total_cash
FROM trips
WHERE payment_type = 'CSH'
  AND total_amount > 0
GROUP BY pickup_ntaname
HAVING SUM(total_amount) > 500000


-- 02 В какое время суток предпочитают расплачиваться картой и в какое время наличными?
-- Постройте два запроса со средней суммой оплаты в зависимости от времени суток для оплат картой и наличными. 
--При суммировании учитывайте только положительные суммы оплаты поездки.

-- Картой:
SELECT 
    toHour(dropoff_datetime) AS hour_of_day,
    AVG(total_amount ) AS avg_card_payment
FROM trips
WHERE payment_type = 'CRE'
  AND total_amount  > 0
GROUP BY hour_of_day

-- Наличные:
SELECT 
    toHour(dropoff_datetime) AS hour_of_day,
    AVG(total_amount) AS avg_cash_payment
FROM trips
WHERE payment_type = 'CSH'
  AND total_amount > 0
GROUP BY hour_of_day

-- 03 Какие виды оплаты предпочитают компании из нескольких пассажиров?
-- Получите списки вариантов оплаты, используемых пассажирами, в зависимости от их количества.
-- Исключите случаи, когда число пассажиров меньше 2. Компании из скольки человек предпочитают оплату наличными?

-- Ваш код:
SELECT 
    passenger_count,
    payment_type,
    COUNT(*) AS trips_count
FROM trips
WHERE passenger_count >= 2
GROUP BY passenger_count, payment_type
ORDER BY passenger_count, trips_count DESC;


SELECT
    passenger_count,
    argMax(payment_type, trips_count) AS most_used_payment
FROM
(
    SELECT 
        passenger_count,
        payment_type,
        COUNT(*) AS trips_count
    FROM trips
    WHERE passenger_count >= 2
    GROUP BY passenger_count, payment_type
) 
GROUP BY passenger_count
ORDER BY passenger_count;


-- 04 Постройте граф поездок - в первой колонке выведите район отправления, а во второй - список районов прибытия.
-- Исключите из рассмотрения записи, в который районы отправления или прибытия не указаны. Таблицу отсортируй по убыванию длины списка прибытия.

-- Ваш код:
SELECT
    pickup_ntaname,
    groupUniqArray(dropoff_ntaname) AS dropoff_list,
    length(dropoff_list) AS destinations_count
FROM trips
WHERE pickup_ntaname != '' 
  AND dropoff_ntaname != ''
GROUP BY pickup_ntaname
ORDER BY destinations_count DESC;


-- 05 Для каждого района отправление найдите три наиболее частых района прибытия. 
-- Исключите из рассмотрения записи, в который районы отправления или прибытия не указаны. Используйте функцию topK.
-- Ваш код:
SELECT
    pickup_ntaname,
    topK(3)(dropoff_ntaname) AS top3_dropoff_areas
FROM trips
WHERE pickup_ntaname != '' 
  AND dropoff_ntaname != ''
GROUP BY pickup_ntaname
ORDER BY pickup_ntaname;


-- 06 Вычислите квантили уровней 0.25, 0.5, 0.75 и 1  для полной суммы оплаты поездки используя приближенную функцию quantiles и точную quantilesExact.
-- Используя только стандартный SQL (без расширенных возможностей ClickHouse), вычислите квантиль уровня 1.
-- Сравните результаты трёх созданных запросов. Оцените насколько приближённые квантили отличаются от точных. 
--Проанализируйте, почему это происходит. Возможно, в этом поможет изучение упорядоченных значений суммы оплаты поездки и точных квантилей вблизи единицы.

SELECT
    quantiles(0.25, 0.5, 0.75, 1)(total_amount) AS approx_quantiles
FROM trips
WHERE total_amount > 0;
-- [8.47000002861023,11.800000190734863,17.299999237060547,161.6300048828125]

SELECT
    quantilesExact(0.25, 0.5, 0.75, 1)(total_amount) AS exact_quantiles
FROM trips
WHERE total_amount > 0;

-- [8.76,11.8,17.8,107445.09]

SELECT MAX(total_amount) AS max_total_amount
FROM trips
WHERE total_amount > 0;
-- 107445.09


SELECT total_amount
FROM trips
WHERE total_amount > 0
ORDER BY total_amount DESC
LIMIT 5;

-- Ваш код:

-- 07 Создайте запрос, который вычисляет гистограмму из 10 ячеек для значений из столбца полной суммы оплаты поездки 
-- Исключите из рассмотрения отрицательные значения. Какие суммы оплаты встречаются чаще всего?
SELECT 
    histogram(10)(total_amount) AS hist
FROM trips
WHERE total_amount > 0;

-- Левая граница интервала, Правая граница интервала, Частота (кол-во поездок)

-- Ваш код:

-- 08 В поле полной суммы оплаты поездки есть отрицательные значения. 
-- Проанализируйте связь этих отрицательных значений с другими данным в таблице. 
-- Например, выясните как положительные и отрицательные оплаты связаны с временем суток поездок и районами начала и окончания.
-- Ответьте на вопрос - можно ли считать это потерями таксистов, например, вследствие ограблений, или вероятнее всего это просто ошибочные данные.

-- Ваш код:
SELECT
    CASE 
        WHEN total_amount < 0 THEN 'Отрицательные'
        ELSE 'Положительные'
    END AS type,
    toHour(pickup_datetime) AS hour,
    count() AS trip_count,
    avg(total_amount) AS avg_amount,
    median(total_amount) AS median_amount
FROM trips
WHERE total_amount != 0
GROUP BY type, hour
ORDER BY type, hour;

-- Положительные
SELECT
    pickup_ntaname,
    dropoff_ntaname,
    count() AS trip_count
FROM trips
WHERE total_amount > 0
GROUP BY pickup_ntaname, dropoff_ntaname
ORDER BY trip_count DESC
LIMIT 20;

-- Отрицательные
SELECT
    pickup_ntaname,
    dropoff_ntaname,
    count() AS trip_count
FROM trips
WHERE total_amount < 0
GROUP BY pickup_ntaname, dropoff_ntaname
ORDER BY trip_count DESC
LIMIT 20;
-- Есть пропуски



select * from trips
order by total_amount asc
LIMIT(30)
-- Есть поездки где координаты равны нулям, также типы оплаты зачастую - DIS и NOC
