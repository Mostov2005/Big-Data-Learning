-- База данных sakila - учебна база от разработчиков mysql. Она описывает работу вымышленного магазина проката DVD-дисков. Структура базы описана в файле sakila-en.a4.pdf.
SELECT * FROM actor

-- 01 Получите список актёров, чьи фамилии - 'WILLIAMS' или 'DAVIS',
-- а затем найдите в нём имя, начинающиеся на 'J'. Запишите имя и фамилию этого актёра.
-- Ваш код:
SELECT *
FROM actor
WHERE (actor.last_name = 'WILLIAMS'
OR actor.last_name = 'DAVIS')
AND actor.first_name LIKE 'J%'

-- 02 Получите список выдачи дисков в прокат (таблица rental) от 5 июля 2005 года.
-- Чтобы игнорировать время выдачи, можно использовать функцию date().
-- Определите, какой заказ из этого списка был возвращён самым последним.
--  Запишите дату.
-- Ваш код:
SELECT *
FROM rental
WHERE  date(rental_date) >= DATE '2005-07-05'
ORDER BY return_date DESC

-- 03 Создайте запрос, который находит всех клиентов, начальные буквы фамилий которых находятся между 'AN' и AT'. Отсортируйте вывод по именам.
-- Ваш код:
SELECT *
FROM customer c 
WHERE LEFT(c.last_name, 2) BETWEEN 'AN' AND 'AT'
ORDER BY c.first_name 

-- 04 Создайте запрос, который находит всех клиентов, в фамилиях которых содержатся буква А во второй позиции и буква W — в любом месте после А.
-- Отсортируйте результат по фамилиям. Если не знаете как это сделать, ищите информацию об использовании в запросах подстановочных знаков.
-- Ваш код:
SELECT *
FROM customer c 
WHERE c.last_name LIKE('_A%W%')
ORDER BY c.last_name 

-- 05 Используя таблицы rental и customer среди клиентов,
-- вернувших заказ 7 июля 2005 года найдите электронную почту того, кто продержал заказ дольше всех.
-- Ваш код:
SELECT c.email, r.return_date - r.rental_date AS duration
FROM customer c 
JOIN rental r ON c.customer_id = r.customer_id 
WHERE date(r.return_date) = DATE '2005-07-07'
ORDER BY (r.return_date - r.rental_date) DESC
LIMIT 1

-- 06 Среди клиентов, разовый платёж которых за заказ был более 11 долларов и менее 12 найдите имя того, чья фамилия 'GILBERT'
-- Ваш код:
SELECT *
FROM customer c 
JOIN payment p ON c.customer_id = p.customer_id 
WHERE c.last_name = 'GILBERT'
AND p.amount > 11 
AND p.amount < 12

-- 07 Постройте объединение таблиц customer, address и city и найдите имя, адрес и город клиента с фамилией 'JOHNSTON' из Калифорнии.
-- Ваш код:
SELECT c.first_name, a.address, city.city
FROM customer c 
JOIN address a ON c.address_id = a.address_id 
JOIN city ON city.city_id = a.city_id 
WHERE c.last_name = 'JOHNSTON'
AND a.district = 'California'

-- 08 Напишите запрос, который выводил бы названия всех фильмов, начинающиеся с буквы 'B', в которых играл актер с именем KARL.
-- Ваш код:
SELECT f.title
FROM film f 
JOIN film_actor fa ON f.film_id = fa.film_id 
JOIN actor a ON a.actor_id = fa.actor_id 
WHERE a.first_name = 'KARL'
AND LEFT (f.title, 1) = 'B'

-- 09 Используя таблицы rental и customer и функцию extract() найдите фамилию клиентки по имени JANET,
-- которая в брала диски в августе и вернула в сентябре.
-- Возможно для проверки и сравнения месяцев потребуется задействовать секцию having.
-- Ваш код:
SELECT c.last_name 
FROM customer c 
JOIN rental r USING(customer_id)
WHERE c.first_name = 'janet'
GROUP BY c.customer_id, c.last_name
HAVING SUM(CASE WHEN EXTRACT(MONTH FROM r.rental_date) = 8 THEN 1 ELSE 0 END) > 0
AND SUM(CASE WHEN EXTRACT(MONTH FROM r.return_date ) = 9 THEN 1 ELSE 0 END) > 0

-- 10 Используя таблицу payment, подсчитайте количество платежей, которые сделал каждый клиент и общую уплаченную каждым клиентом сумму.
-- Выполните упорядочивание результатов запроса по убыванию уплаченной суммы и ограничьте вывод тремя первыми записями.
-- Ваш код:
SELECT p.customer_id, COUNT(p.customer_id), SUM(p.amount)
FROM payment p 
GROUP BY p.customer_id 
ORDER BY SUM(p.amount) DESC
LIMIT 3 

-- 11 Модифицируйте предыдущий запрос так, чтобы он дополнительно выдавал имена и фамилии трёх клиентов с наибольшими суммарными платежами.
-- Ваш код:
SELECT p.customer_id, c.first_name, c.last_name, COUNT(p.customer_id), SUM(p.amount)
FROM payment p 
JOIN customer c ON p.customer_id = c.customer_id 
GROUP BY p.customer_id, c.first_name, c.last_name  
ORDER BY SUM(p.amount) DESC
LIMIT 3 


SELECT @@sql_mode;




























