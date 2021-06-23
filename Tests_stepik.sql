/* Последовательность выполнения операций на сервере:
MySQL: FROM => WHERE = SELECT = GROUP BY = HAVING = ORDER BY = LIMIT.   
PostgreSQL: FROM => WHERE = GROUP BY = HAVING = SELECT = DISTINCT = ORDER BY = LIMIT
SQL: FROM => WHERE => GROUP BY => HAVING => SELECT => ORDER BY */
SHOW DATABASES;
SHOW TABLES;
DESCRIBE enrollee_achievement;
SHOW CREATE TABLE enrollee_subject;
CREATE DATABASE stepik;
USE stepik;
CREATE TABLE book(
	book_id	INT PRIMARY KEY AUTO_INCREMENT,
	title	VARCHAR(50),
	author	VARCHAR(30),
	price	DECIMAL(8, 2),
	amount	INT
);
/*---Дамп базы*/
DROP TABLE IF EXISTS `book`;
CREATE TABLE IF NOT EXISTS `book` (
  `book_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `title` varchar(50) DEFAULT NULL,
  `author` varchar(30) DEFAULT NULL,
  `price` decimal(8,2) DEFAULT NULL,
  `amount` int(11) DEFAULT NULL,
  PRIMARY KEY (`book_id`)
) ENGINE=MyISAM AUTO_INCREMENT=7 DEFAULT CHARSET=utf8;
DELETE FROM `book`;
/*!40000 ALTER TABLE `book` DISABLE KEYS */;
INSERT INTO `book` (`book_id`, `title`, `author`, `price`, `amount`) VALUES
    (1, 'Мастер и Маргарита', 'Булгаков М.А.', 670.99, 3),
    (2, 'Белая гвардия', 'Булгаков М.А.', 540.50, 5),
    (3, 'Идиот', 'Достоевский Ф.М.', 460.00, 10),
    (4, 'Братья Карамазовы', 'Достоевский Ф.М.', 799.01, 2),
    (5, 'Игрок', 'Достоевский Ф.М.', 480.50, 10),
    (6, 'Стихотворения и поэмы', 'Есенин С.А.', 650.00, 15);
/*!40000 ALTER TABLE `book` ENABLE KEYS */;

INSERT INTO book (title, author, price, amount)
VALUES ('Мастер и Маргарита', 'Булгаков М.А.', 670.99, 3);
INSERT INTO book (title, author, price, amount)
VALUES ('Белая гвардия', 'Булгаков М.А.', 540.50, 5);
INSERT INTO book (title, author, price, amount)
VALUES ('Идиот', 'Достоевский Ф.М.', 460.00, 10);
INSERT INTO book (title, author, price, amount)
VALUES ('Братья Карамазовы', 'Достоевский Ф.М.', 799.01, 2);
INSERT INTO book (title, author, price, amount)
VALUES ('Стихотворения и поэмы', 'Есенин С.А.', 650, 15);
SELECT title,
    author,
    amount,
    ROUND(price * 0.7,2) AS new_price
FROM book;
SELECT author,
    title,
    ROUND(IF(author = 'Булгаков М.А.', price * 1.1, IF(author = 'Есенин С.А.', price * 1.05, price)), 2) AS new_price
FROM book;
SELECT author, title, price
FROM book
WHERE amount < 10;
SELECT title, author, price, amount
FROM book
WHERE (price < 500 OR price > 600) AND price * amount >= 5000;
SELECT title, author
FROM book
WHERE price BETWEEN 540.50 AND 800 AND amount in (2, 3, 5, 7);
SELECT title, author
FROM book
WHERE title LIKE "%_ _%" AND author LIKE "%С.%";
SELECT author, title
FROM book
WHERE amount BETWEEN 2 AND 14
ORDER BY author DESC, title;
SELECT *, price * amount AS total_cost
FROM book
ORDER BY total_cost DESC;
SELECT author AS Автор, count(author) AS Различных_книг, sum(amount) AS Количество_экземпляров
FROM book
GROUP BY author;
SELECT author,
    SUM(price * amount) AS Стоимость,
    ROUND(SUM(price * amount) * 0.18 / 1.18,2) AS НДС,
    ROUND(SUM(price * amount) / 1.18,2) AS Стоимость_без_НДС
FROM book
GROUP BY author;
SELECT ROUND(AVG(price),2) AS Средняя_цена,
    ROUND(SUM(price * amount),2) AS Стоимость
FROM book
WHERE amount BETWEEN 5 AND 14;
SELECT author, ROUND(SUM(price * amount),2) AS Стоимость
FROM book
WHERE title NOT IN ("Идиот", "Белая гвардия")
GROUP BY author
HAVING SUM(price * amount) > 5000
ORDER BY 2 DESC;
SELECT author, title, price
FROM book
WHERE price <= (SELECT AVG(price) FROM book)
ORDER BY price DESC;
SELECT author, title, price
FROM book
WHERE (price - (SELECT MIN(price) FROM book)) <= 150
ORDER BY price;
SELECT author, title, amount
FROM book
WHERE amount IN (SELECT amount FROM book GROUP BY amount HAVING COUNT(amount) < 2);
SELECT author, title, price
FROM book
WHERE price < any(SELECT MIN(price) FROM book GROUP BY author);
SELECT title, author, amount, (SELECT MAX(amount) FROM book) - amount  AS Заказ
FROM book
HAVING Заказ > 0;
SELECT title, author, amount, (@MAX - amount) AS Заказ
  FROM book
 WHERE amount < (@MAX := (SELECT MAX(amount) FROM book));
 SELECT author, title, ROUND(price * amount / (SELECT SUM(price * amount) FROM book) * 100,2) AS Доля_от_запасов
 FROM book
 ORDER BY 3 DESC;
 
CREATE TABLE supply(
	supply_id	INT PRIMARY KEY AUTO_INCREMENT,
	title	VARCHAR(50),
	author	VARCHAR(30),
	price	DECIMAL(8, 2),
	amount	INT
    );
INSERT INTO supply (title, author, price, amount)
VALUES ('Лирика', 'Пастернак Б.Л.', 518.99, 2),
       ('Черный человек', 'Есенин С.А.', 570.20, 6),
       ('Белая гвардия', 'Булгаков М.А.', 540.50, 7),
       ('Идиот', 'Достоевский Ф.М.', 360.80, 3);

INSERT INTO book (title, author, price, amount) 
SELECT title, author, price, amount 
FROM supply
WHERE author NOT IN ('Булгаков М.А.', 'Достоевский Ф.М.');
INSERT INTO book (title, author, price, amount) 
SELECT title, author, price, amount 
FROM supply
WHERE author NOT IN (SELECT author FROM book);
UPDATE book 
SET price = 0.9 * price 
WHERE amount BETWEEN 5 AND 10;
ALTER TABLE book ADD buy INT NULL;
UPDATE book
SET buy = IF(buy > amount, amount, buy),
    price = IF(buy = 0, ROUND(price * 0.9,2), price);
SELECT amount, buy, LEAST(amount, buy)
FROM book;
UPDATE book SET buy = LEAST(amount, buy);
UPDATE book, supply 
SET book.amount = book.amount + supply.amount,
    book.price = (book.price + supply.price) / 2
WHERE book.title = supply.title AND book.author = supply.author;
DELETE FROM supply 
WHERE author IN (
       SELECT author 
       FROM book
       GROUP BY author
       HAVING SUM(amount) > 10
      );
CREATE TABLE ordering AS
SELECT author, title, 
   (
    SELECT ROUND(AVG(amount)) 
    FROM book
   ) AS amount
FROM book
WHERE amount < (SELECT ROUND(AVG(amount)) FROM book);
/* то же самое*/
CREATE TABLE ordering AS
SELECT author, title,  @AVG as amount
FROM book
WHERE amount < (@AVG := (SELECT ROUND(AVG(amount)) FROM book));
/* то же самое*/
CREATE TABLE ordering AS
SELECT author, title, (SELECT round(AVG(amount)) FROM book) AS amount
FROM book
GROUP BY author, title
HAVING SUM(amount) < amount;

UPDATE book, (SELECT MAX(amount) m FROM book) AS maxi
SET price = IF(amount = maxi.m, price * 0.95, price);
SELECT MAX(amount) FROM book;

CREATE TABLE trip
(
trip_id INT PRIMARY KEY AUTO_INCREMENT,
name VARCHAR(30),
city VARCHAR(25),
per_diem DECIMAL(8,2),
date_first DATE,
date_last DATE
);
INSERT INTO trip VALUES
(1, "Баранов П.Е.", "Москва", "700", "2020-01-12", "2020-01-17"), 
(2, "Абрамова К.А.", "Владивосток", "450", "2020-01-14", "2020-01-27"), 
(3, "Семенов И.В.", "Москва", "700", "2020-01-23", "2020-01-31"), 
(4, "Ильиных Г.Р.", "Владивосток", "450", "2020-01-12", "2020-02-02"), 
(5, "Колесов С.П.", "Москва", "700", "2020-02-01", "2020-02-06"), 
(6, "Баранов П.Е.", "Москва", "700", "2020-02-14", "2020-02-22"), 
(7, "Абрамова К.А.", "Москва", "700", "2020-02-23", "2020-03-01"), 
(8, "Лебедев Т.К.", "Москва", "700", "2020-03-03", "2020-03-06"), 
(9, "Колесов С.П.", "Новосибирск", "450", "2020-02-27", "2020-03-12"), 
(10, "Семенов И.В.", "Санкт-Петербург", "700", "2020-03-29", "2020-04-05"), 
(11, "Абрамова К.А.", "Москва", "700", "2020-04-06", "2020-04-14"), 
(12, "Баранов П.Е.", "Новосибирск", "450", "2020-04-18", "2020-05-04"), 
(13, "Лебедев Т.К.", "Томск", "450", "2020-05-20", "2020-05-31"), 
(14, "Семенов И.В.", "Санкт-Петербург", "700", "2020-06-01", "2020-06-03"), 
(15, "Абрамова К.А.", "Санкт-Петербург", "700", "2020-05-28", "2020-06-04"), 
(16, "Федорова А.Ю.", "Новосибирск", "450", "2020-05-25", "2020-06-04"), 
(17, "Колесов С.П.", "Новосибирск", "450", "2020-06-03", "2020-06-12"), 
(18, "Федорова А.Ю.", "Томск", "450", "2020-06-20", "2020-06-26"), 
(19, "Абрамова К.А.", "Владивосток", "450", "2020-07-02", "2020-07-13"), 
(20, "Баранов П.Е.", "Воронеж", "450", "2020-07-19", "2020-07-25");

SELECT name, city, per_diem, date_first, date_last
FROM trip
WHERE name LIKE "%а %"
ORDER BY date_last DESC;
SELECT city, count(*) AS Количество
FROM trip
GROUP BY city
ORDER BY 2 DESC
LIMIT 2;
SELECT name, city, DATEDIFF(date_last, date_first)+1 AS Длительность
FROM trip
WHERE city NOT IN ("Москва", "Санкт-Петербург")
ORDER BY 3 DESC, 2 DESC;
SELECT name, city, date_first, date_last  
FROM trip
WHERE DATEDIFF(date_last, date_first) = (SELECT MIN(DATEDIFF(date_last, date_first)) FROM trip);
SELECT MONTHNAME(date_first) Месяц, count(*) Количество
FROM trip
GROUP BY MONTHNAME(date_first)
ORDER BY 2 DESC, 1;
SELECT name, city, date_first, (DATEDIFF(date_last, date_first)+1)*per_diem Сумма
FROM trip
WHERE MONTH(date_first) IN (2,3)
ORDER BY 1, 4 DESC;
SELECT name, SUM((DATEDIFF(date_last, date_first)+1)*per_diem) Сумма
FROM trip
GROUP BY name
HAVING 3 < count(*)
ORDER BY 2 DESC;
CREATE TABLE fine
    (
        fine_id INT PRIMARY KEY AUTO_INCREMENT,
        name varchar(30),
        number_plate varchar(6),
        violation varchar(50),
        sum_fine decimal(8, 2),
        date_violation date,
        date_payment date
    );
INSERT INTO fine (name, number_plate, violation, sum_fine, date_violation, date_payment)
VALUES ('Баранов П.Е.', 'Р523ВТ', 'Превышение скорости(от 40 до 60)', NULL, '2020-02-14', NULL),
       ('Абрамова К.А.', 'О111АВ', 'Проезд на запрещающий сигнал', NULL, '2020-02-23', NULL),
       ('Яковлев Г.Р.', 'Т330ТТ', 'Проезд на запрещающий сигнал', NULL, '2020-03-03', NULL),
       ('Баранов П.Е.', 'Р523ВТ', 'Превышение скорости(от 40 до 60)', 500.00, '2020-01-12', '2020-01-17'),
       ('Абрамова К.А.', 'О111АВ', 'Проезд на запрещающий сигнал', 1000.00, '2020-01-14', '2020-02-27'),
       ('Яковлев Г.Р.', 'Т330ТТ', 'Превышение скорости(от 20 до 40)', 500.00, '2020-01-23', '2020-02-23'),
       ('Яковлев Г.Р.', 'М701АА', 'Превышение скорости(от 20 до 40)', NULL, '2020-01-12', NULL),
       ('Колесов С.П.', 'К892АХ', 'Превышение скорости(от 20 до 40)', NULL, '2020-02-01', NULL);
INSERT INTO fine (name, number_plate, violation, date_violation)
VALUES ('Баранов П.Е.', 'Р523ВТ', 'Превышение скорости(от 40 до 60)', '2020-02-14'),
       ('Абрамова К.А.', 'О111АВ', 'Проезд на запрещающий сигнал', '2020-02-23'),
	   ('Яковлев Г.Р.', 'Т330ТТ', 'Проезд на запрещающий сигнал', '2020-03-03');
       
UPDATE fine AS f, traffic_violation AS tv
SET f.sum_fine = tv.sum_fine
WHERE tv.violation = f.violation AND f.sum_fine IS Null;
/*второй вариант*/
UPDATE fine AS f 
SET f.sum_fine = 
                (Select tv.sum_fine 
                 from traffic_violation as tv
                 where f.violation = tv.violation)
WHERE f.sum_fine is null;
/* третий вариант*/
UPDATE fine AS f, traffic_violation AS tv
SET f.sum_fine = IF(f.sum_fine IS Null, tv.sum_fine, f.sum_fine)
WHERE tv.violation = f.violation;
SELECT * FROM fine;
SELECT name, number_plate, violation
FROM fine
GROUP BY name, number_plate, violation
HAVING count(*) > 1
ORDER BY name, number_plate, violation;
UPDATE fine, 
    (
    SELECT name, number_plate, violation
    FROM fine
    GROUP BY name, number_plate, violation
    HAVING count(*) > 1) query_in
SET fine.sum_fine = sum_fine * 2
WHERE (fine.name, fine.number_plate, fine.violation) = (query_in.name, query_in.number_plate, query_in.violation)
	   AND fine.date_payment IS Null;
-- еще вариант
WITH t AS (
    SELECT name, number_plate, violation
    FROM fine
    GROUP BY name, number_plate, violation
    HAVING COUNT(*) > 1
    )
UPDATE fine f, t
SET sum_fine = sum_fine * 2
WHERE date_payment IS NULL
	  AND t.name = f.name
	  AND t.number_plate = f.number_plate
	  AND t.violation = f.violation;
-- еще вариант
CREATE TABLE query_in -- CREATE VIEW
SELECT name, number_plate, violation
FROM fine
GROUP BY name, number_plate, violation
HAVING count(*) > 1;
UPDATE fine f, query_in q SET sum_fine = sum_fine * 2 
WHERE f.name = q.name AND f.number_plate = q.number_plate AND f.violation = q.violation AND date_payment IS Null;

UPDATE fine f, payment p
SET sum_fine = IF(DATEDIFF(p.date_payment, p.date_violation) < 21, sum_fine / 2, sum_fine),
    f.date_payment = p.date_payment
WHERE f.date_payment IS NULL
	  AND f.name = p.name
	  AND f.number_plate = p.number_plate
	  AND f.date_violation = p.date_violation;
CREATE TABLE back_payment AS
SELECT name, number_plate, violation, sum_fine, date_violation
FROM fine
WHERE ISNULL(date_payment);	-- date_payment IS Null

-- Часть 2
CREATE TABLE author (
	author_id INT PRIMARY KEY AUTO_INCREMENT,
	name_author VARCHAR(50)
	);
CREATE TABLE genre (
    genre_id INT PRIMARY KEY AUTO_INCREMENT,
    name_genre VARCHAR(30),
    FOREIGN KEY (genre_id)  REFERENCES book (genre_id)
	);
CREATE TABLE book (
    book_id INT PRIMARY KEY AUTO_INCREMENT, 
    title VARCHAR(50), 
    author_id INT NOT NULL, 
    genre_id INT,
    price DECIMAL(8,2), 
    amount INT, 
    FOREIGN KEY (author_id)  REFERENCES author (author_id) ON DELETE CASCADE,
    FOREIGN KEY (genre_id)  REFERENCES genre (genre_id) ON DELETE SET NULL
    );
SET @poetry_id = (SELECT genre_id  FROM genre  WHERE name_genre  = 'Поэзия');
SET @esenin_id = (SELECT author_id FROM author WHERE name_author = 'Есенин С.А.');
INSERT INTO book (title, author_id, genre_id, price, amount) VALUES
('Стихотворения и поэмы', @esenin_id, @poetry_id, 650.00, 15),
(       'Черный человек', @esenin_id, @poetry_id, 570.20,  6),
('Лирика', (SELECT author_id FROM author WHERE name_author = 'Пастернак Б.Л.'), @poetry_id, 518.99, 2 );

SELECT title, name_genre, price
FROM book INNER JOIN genre
ON book.genre_id = genre.genre_id
WHERE amount > 8
ORDER BY price DESC;
SELECT name_genre
FROM genre LEFT JOIN book
USING(genre_id)
WHERE title IS Null;
SELECT name_city, name_author, DATE_ADD('2020-01-01', INTERVAL FLOOR(RAND() * 365) DAY) AS Дата
FROM city, author
ORDER BY name_city,3 DESC;
SELECT name_genre, title, name_author
FROM
    author INNER JOIN  book
    ON author.author_id = book.author_id
        INNER JOIN genre
        ON genre.genre_id = book.genre_id
WHERE name_genre = 'Роман'
ORDER BY title;
-- Аналогичная структура:
/*SELECT поля_таблиц
FROM таблица_1 
[INNER] | [[LEFT | RIGHT | FULL][OUTER]] JOIN таблица_2[ JOIN таблица_n] 
    ON условие_соединения [AND условие_соединения]*/
SELECT name_genre, title, name_author 
FROM book
    INNER JOIN author JOIN genre
    ON book.author_id = author.author_id
    AND book.genre_id = genre.genre_id
WHERE name_genre LIKE '%Роман%'
ORDER BY title;
SELECT name_author, SUM(amount) AS Количество
FROM 
    author LEFT JOIN book
    on author.author_id = book.author_id
GROUP BY name_author
HAVING Количество < 10 OR COUNT(title) = 0	-- HAVING IFNULL(SUM(b.amount), 0) < 10
ORDER BY 2;
-- улучшенный вариант
SELECT name_author, SUM(IF(amount IS Null, 0, amount)) AS Количество	-- COALESCE(SUM(amount), 0) AS Количество
FROM 
    author LEFT JOIN book
    on author.author_id = book.author_id
GROUP BY name_author
HAVING Количество < 10
ORDER BY 2;
SELECT name_author FROM author 
WHERE author_id IN (SELECT author_id FROM book
                    GROUP BY author_id
                    HAVING COUNT(DISTINCT genre_id) = 1);
-- второй вариант
SELECT name_author
FROM author INNER JOIN book
ON author.author_id = book.author_id
GROUP BY name_author
HAVING COUNT(DISTINCT genre_id) = 1;
SELECT title, name_author, name_genre, price, amount	-- 2.2.8
FROM genre g
INNER JOIN book b ON b.genre_id = g.genre_id
INNER JOIN author a ON a.author_id = b.author_id
INNER JOIN 
(SELECT genre_id, SUM(amount) AS sum_amount
       FROM book
       GROUP BY genre_id
       HAVING sum_amount >= MAX(sum_amount)) max_genere
     ON max_genere.genre_id = g.genre_id
ORDER BY title;
SELECT title, name_author, name_genre, price, amount
FROM genre g INNER JOIN book b
ON g.genre_id = b.genre_id
INNER JOIN author a
ON b.author_id = a.author_id
WHERE g.genre_id IN (
					SELECT genre_id 
                    FROM book
					GROUP BY genre_id
					HAVING SUM(amount) = (SELECT sum(amount) AS sum_amount 	-- HAVING SUM(amount) >= ALL(SELECT SUM(amount) 
										 FROM book							-- FROM book 
										 GROUP BY genre_id					-- GROUP BY genre_id)
										 ORDER BY sum_amount DESC
										 LIMIT 1)
					)
ORDER BY title;
-- второй вариант
SELECT title, name_author, name_genre, price, amount
FROM author INNER JOIN book USING (author_id)
            INNER JOIN genre USING (genre_id)
            INNER JOIN (SELECT genre_id FROM book GROUP BY genre_id 
						HAVING SUM(amount) = (SELECT sum(amount) as sum_amount FROM book GROUP BY genre_id ORDER BY sum_amount DESC LIMIT 1)
                        ) AS genre_max USING (genre_id)
ORDER BY title;
-- еще вариант
SELECT title, name_author, name_genre, price, amount
FROM genre g INNER JOIN book b
ON g.genre_id = b.genre_id
INNER JOIN author a
ON b.author_id = a.author_id
WHERE b.genre_id IN 
        (/* выбираем автора, если он пишет книги в самых популярных жанрах*/
          SELECT query_in_1.genre_id
          FROM 
              ( /* выбираем код жанра и количество произведений, относящихся к нему */
                SELECT genre_id, SUM(amount) AS sum_amount
                FROM book
                GROUP BY genre_id
               )query_in_1
          INNER JOIN 
              ( /* выбираем запись, в которой указан код жанр с максимальным количеством книг */
                SELECT genre_id, SUM(amount) AS sum_amount
                FROM book
                GROUP BY genre_id
                ORDER BY sum_amount DESC
                LIMIT 1
               ) query_in_2
          ON query_in_1.sum_amount= query_in_2.sum_amount
         )
ORDER BY title;
SELECT supply.title Название, author Автор, book.amount + supply.amount Количество	-- 2.2.9
FROM author INNER JOIN book USING(author_id)
INNER JOIN supply
ON (book.title, author.name_author, book.price) = (supply.title, supply.author, supply.price);
SELECT name_author, name_genre, count(title) AS Количество	-- 2.2.10
FROM author cross join genre
        LEFT JOIN book 
        ON (author.author_id, genre.genre_id) = (book.author_id, book.genre_id)
GROUP BY name_author, name_genre
ORDER BY name_author, Количество DESC;
UPDATE book	-- 2.3.2
     INNER JOIN author ON author.author_id = book.author_id
     INNER JOIN supply ON book.title = supply.title 
                         and supply.author = author.name_author
SET book.amount = book.amount + supply.amount,
    supply.amount = 0,
    book.price = (book.price*book.amount + supply.price*supply.amount)/(book.amount + supply.amount)
WHERE book.price != supply.price;	-- условие из WHERE можно перенести в JOIN
INSERT INTO author (name_author)	-- 2.3.3
SELECT supply.author
FROM author RIGHT JOIN supply 
ON author.name_author = supply.author
WHERE name_author IS Null;

SET profiling=1;	-- !!!!!!!!!!!!!!!!!!!!!!!! выводит скорость выполнения запросов и есть SET profiling_history_size=100;
-- еще есть функция BENCHMARK(count,expr)
SELECT * FROM book
     INNER JOIN author ON author.author_id = book.author_id
     INNER JOIN supply ON book.title = supply.title 
                         and supply.author = author.name_author;
SHOW profiles;		-- !!!!!!!!!!!!!!!!!!!!!!!

INSERT INTO book (title, author_id, price, amount)	-- 2.3.4
SELECT title, author_id, price, amount
FROM 
    author 
    INNER JOIN supply ON author.name_author = supply.author
WHERE amount <> 0;
UPDATE book b	-- 2.3.5
INNER JOIN author a ON  a.author_id = b.author_id
SET b.genre_id = (
    SELECT g.genre_id
    FROM genre g
    WHERE g.name_genre = CASE
          WHEN b.title = 'Стихотворения и поэмы' AND a.name_author LIKE 'Лермонтов%' THEN 'Поэзия'
          WHEN b.title = 'Остров сокровищ' AND a.name_author LIKE 'Стивенсон%' THEN 'Приключения'
          END)
WHERE a.name_author LIKE 'Лермонтов%' OR a.name_author LIKE 'Стивенсон%';
DELETE a FROM author a	-- 2.3.6
INNER JOIN (
    SELECT author_id FROM book
    GROUP BY author_id
    HAVING SUM(amount) < 20
    ) b
ON a.author_id = b.author_id;
-- второй вариант
DELETE FROM author
WHERE author_id IN (SELECT author_id
                    FROM book
                    GROUP BY author_id
                    HAVING SUM(amount) < 20);
DELETE genre FROM genre 	-- 2.3.7
INNER JOIN (SELECT genre_id FROM book GROUP BY genre_id HAVING count(title) < 4) AS b
USING(genre_id);
DELETE FROM author	-- 2.3.8
USING author INNER JOIN book USING(author_id) INNER JOIN genre USING(genre_id)
WHERE name_genre LIKE '%поэзия%';

INSERT INTO author (name_author)	-- 2.3.9 задание Фернандес
SELECT supply.author
FROM author RIGHT JOIN supply 
ON author.name_author = supply.author
WHERE name_author IS Null;
INSERT INTO book (title, author_id, price, amount)
SELECT  supply.title, author.author_id, supply.price, supply.amount
FROM author 
    INNER JOIN supply ON author.name_author = supply.author 
    LEFT JOIN book ON book.title = supply.title AND book.author_id = author.author_id
WHERE book.title IS Null;
UPDATE book
SET genre_id = IF(book_id = 9, 1, IF(book_id = 10, 2, IF(book_id = 11, 3, genre_id)));
UPDATE /*+ NO_MERGE(discounted) */ book, 										-- UPDATE book INNER JOIN (SELECT genre_id, AVG(price) AS newprice
(SELECT genre_id, AVG(price) AS avg_price FROM book GROUP BY genre_id) AS a		-- FROM book GROUP BY genre_id) AS q USING(genre_id)
SET book.price = a.avg_price													-- SET book.price = q.newprice;			
WHERE book.genre_id = a.genre_id;															
SELECT * FROM book;

-- https://stackoverflow.com/questions/2411559/how-do-i-query-sql-for-a-latest-record-date-for-each-user/2411763#2411763
use internet_store;
SELECT * -- step_id, buy_id, date_step_beg
FROM buy_step AS t
WHERE EXISTS (
  SELECT *
  FROM buy_step AS witness
  WHERE witness.step_id = t.step_id AND witness.date_step_beg > t.date_step_beg
) and (not date_step_beg is null);
SELECT * -- step_id, buy_id, date_step_beg
FROM buy_step AS t
LEFT OUTER JOIN buy_step AS w ON t.step_id = w.step_id AND t.date_step_beg < w.date_step_beg
WHERE w.step_id IS NULL AND (not t.date_step_beg is null);

/* Как получить первую и последнюю запись из SQL-запроса?
select <some columns>
from (
    SELECT <some columns>,
           row_number() over (order by date desc) as rn,
           count(*) over () as total_count
    FROM mytable
    <maybe some joins here>
    WHERE <various conditions>
) t
where rn = 1 
   or rn = total_count
ORDER BY date DESC
второй вариант
SELECT * FROM TABLE_NAME WHERE ROWID=(SELECT MIN(ROWID) FROM TABLE_NAME) 
UNION
SELECT * FROM TABLE_NAME WHERE ROWID=(SELECT MAX(ROWID) FROM TABLE_NAME)
или
SELECT * FROM TABLE_NAME WHERE ROWID=(SELECT MIN(ROWID) FROM TABLE_NAME) 
                            OR ROWID=(SELECT MAX(ROWID) FROM TABLE_NAME)
*/
                            
SHOW DATABASES;
SHOW TABLES;
DESCRIBE enrollee_subject;
SHOW CREATE TABLE enrollee_subject;
SELECT name, city FROM trip GROUP BY city;
select * from trip right join fine on trip.name = fine.name;
SELECT SUBSTRING_INDEX(SUBSTRING_INDEX('www mysql com', ' ', 3), ' ', -1);
SELECT SUBSTRING_INDEX('www mysql com', ' ', -1);
SELECT IF('5', 'one', 'not one');
SELECT @I := @I + @J Fn_1, @J := @I + @J Fn_2
FROM (SELECT 0 dummy UNION ALL SELECT 0 UNION ALL SELECT 0)a,
     (SELECT 0 dummy UNION ALL SELECT 0 UNION ALL SELECT 0)b,
	 (SELECT @I := 1, @J := 1)IJ;
SELECT 1 X UNION ALL SELECT 2;
SELECT IF(X=1, Fn_1, Fn_2) F		-- послед Фибоначчи
FROM(
     SELECT @I := @I + @J Fn_1, @J := @I + @J Fn_2
     FROM
        (SELECT 0 dummy UNION ALL SELECT 0 UNION ALL SELECT 0)a,
		(SELECT 0 dummy UNION ALL SELECT 0 UNION ALL SELECT 0)b,
		(SELECT @I := 1, @J := 1)IJ
    )T,
	  /*Фиктивная таблица, для вывода последовательности в 1 столбец*/
	  (SELECT 1 X UNION ALL SELECT 2) X ;
      
CREATE TABLE random_int_sequence
WITH RECURSIVE sequence (n) AS
(
  SELECT 0
  UNION ALL
  SELECT n + 1 FROM sequence WHERE n + 1 < 100
)
SELECT FLOOR(65536 * RAND()) `rand_n`
FROM sequence;
SELECT * FROM random_int_sequence;
DROP TABLE random_int_sequence;
CREATE TABLE random_char_sequence
WITH RECURSIVE sequence (c) AS
(
  SELECT 'A'
  UNION ALL
  SELECT CHAR(ORD(c) + 1 USING ASCII) FROM sequence WHERE CHAR(ORD(c)  USING ASCII) < 'Z' -- ASCII вместо UTF8
)
SELECT c
FROM sequence;
SELECT * FROM random_char_sequence;
DROP TABLE random_char_sequence;
CREATE TABLE line_items(
  id INT       UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  total        DECIMAL(8,2) NOT NULL,
  sold_on      DATETIME NOT NULL,
  sold_on_date DATE AS (DATE(sold_on)),
  KEY (sold_on_date)
)
WITH RECURSIVE sequence (n) AS
(
  SELECT 0
  UNION ALL
  SELECT n + 1 FROM sequence WHERE n + 1 < 1000
)
SELECT /*+ SET_VAR(cte_max_recursion_depth = 1M) */
  CAST(20 * RAND() AS DECIMAL) `total`,
  NOW() - INTERVAL DAYOFMONTH(CURDATE()) DAY - INTERVAL (100 * RAND()) DAY `sold_on`
FROM sequence;
SELECT * FROM line_items;
DROP TABLE line_items;
SELECT @@optimizer_switch;

-- https://habr.com/ru/company/flant/blog/510686/
CREATE TABLE seats (
  id         INT AUTO_INCREMENT PRIMARY KEY,
  venue_id   INT,
  y          INT,
  x          INT,
  `row`      VARCHAR(16),
  number     INT,
  `grouping` INT,
  UNIQUE venue_id_y_x (venue_id, y, x)
);
INSERT INTO seats(venue_id, y, x, `row`, number)
WITH RECURSIVE venue_ids (id) AS
(
  SELECT 0
  UNION ALL
  SELECT id + 1 FROM venue_ids WHERE id + 1 < 100000
)
SELECT /*+ SET_VAR(cte_max_recursion_depth = 1M) */
  v.id,
  c.y, c.x,
  CHAR(ORD('A') + FLOOR(RAND() * 3) USING ASCII) `row`,
  FLOOR(RAND() * 3) `number`
FROM venue_ids v
     JOIN (
       VALUES
         ROW(0, 0),
         ROW(0, 1),
         ROW(1, 0),
         ROW(1, 2),
         ROW(2, 0)
     ) c (y, x)
;
SELECT * FROM seats WHERE venue_id = 5000;
TRUNCATE TABLE seats;
DROP TABLE seats;
SET @venue_id = 5000;
-- подход №1: оконные функции
WITH
increments (id, increment) AS
(
  SELECT
    id,
    x > LAG(x, 1, x - 1) OVER tzw + 1 OR y != LAG(y, 1, y) OVER tzw
  FROM seats
  WHERE venue_id = @venue_id
  WINDOW tzw AS (ORDER BY y, x)
)
SELECT
  s.id, y, x,
  ROW_NUMBER() OVER tzw + SUM(increment) OVER tzw `grouping`
FROM seats s
     JOIN increments i USING (id)
WINDOW tzw AS (ORDER BY y, x)
;
-- подход №2: рекурсивные CTE
-- `p_` означает `Previous` и упрощает понимание условий
WITH RECURSIVE groupings (p_id, p_venue_id, p_y, p_x, p_grouping) AS
(
  (
    SELECT id, venue_id, y, x, 1
    FROM seats
    WHERE venue_id = @venue_id
    ORDER BY y, x
    LIMIT 1
  )
  UNION ALL
  SELECT
    s.id, s.venue_id, s.y, s.x,
    p_grouping + 1 + (s.x > p_x + 1 OR s.y != p_y)
  FROM groupings, seats s WHERE s.id = (
    SELECT si.id
    FROM seats si
    WHERE si.venue_id = p_venue_id AND (si.y, si.x) > (p_y, p_x)
    ORDER BY si.venue_id, si.y, si.x
    LIMIT 1
  )
)
SELECT * FROM groupings;
-- подход №3
 SELECT id, SUM(d) OVER tzw2
 FROM
  (
    SELECT 2 - (LAG(y, 1, 0) OVER tzw = y AND LAG(x, 1, -1) OVER tzw = x - 1) AS d, y ,x ,id
    FROM seats 
    WHERE venue_id = @venue_id 
    WINDOW tzw AS (ORDER BY y, x)
   ) t WINDOW tzw2 AS (ORDER BY y, x);