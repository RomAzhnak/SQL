SELECT buy_id, title, price, buy_book.amount	-- 2.4.5
FROM 
    client 
    INNER JOIN buy USING(client_id)
    INNER JOIN buy_book USING(buy_id)
    INNER JOIN book USING(book_id)
WHERE name_client = 'Баранов Павел'
ORDER BY 1, 2;
SELECT name_author, title, COUNT(buy_book.amount) AS 'Количество'	-- 2.4.6
FROM author INNER JOIN book USING(author_id)
            LEFT JOIN buy_book USING (book_id)
GROUP BY name_author, title
ORDER BY name_author, title;
-- второй вариант
SELECT name_author, title, COUNT(buy_book.book_id) Количество
FROM author INNER JOIN book USING(author_id)
            LEFT JOIN buy_book ON book.book_id = buy_book.book_id
GROUP BY book.book_id
ORDER BY 1, 2;
SELECT name_city, count(*) Количество	-- 2.4.7
FROM city INNER JOIN client USING(city_id)
          INNER JOIN buy USING(client_id)
GROUP BY name_city
ORDER BY 2 DESC, 1;
SELECT buy_id, date_step_end	-- 2.4.8
FROM step INNER JOIN buy_step USING(step_id)
WHERE name_step = 'Оплата' AND date_step_end;	-- date_step_end IS NOT Null
SELECT buy_id, name_client, SUM(buy_book.amount * price) Стоимость	-- 2.4.9
FROM client INNER JOIN buy USING(client_id)
            INNER JOIN buy_book USING(buy_id)
            INNER JOIN book USING(book_id)
GROUP BY buy_id;
SELECT buy_id, name_step	-- 2.4.10
FROM step INNER JOIN buy_step USING(step_id)
WHERE date_step_beg AND date_step_end IS Null;
SELECT buy_step.buy_id, DATEDIFF(date_step_end, date_step_beg) Количество_дней,	-- 2.4.11
       GREATEST(DATEDIFF(date_step_end, date_step_beg)-days_delivery, 0) Опоздание
FROM city INNER JOIN client USING(city_id)
          INNER JOIN buy USING(client_id)
          INNER JOIN buy_step ON buy.buy_id = buy_step.buy_id AND date_step_end
          INNER JOIN step ON step.step_id = buy_step.step_id AND name_step = 'Транспортировка';
-- второй вариант
SELECT buy_id, @DaysCount := DATEDIFF(date_step_end, date_step_beg) AS Количество_дней,
         IF(@DaysCount > days_delivery, CONVERT(@DaysCount - days_delivery, DECIMAL), 0) AS Опоздание
FROM city JOIN client   USING(city_id)
		  JOIN buy      USING(client_id)
          JOIN buy_step USING(buy_id)
          JOIN step     USING(step_id)
WHERE (name_step = 'Транспортировка') AND date_step_end IS NOT Null	-- можно просто AND date_step_end
ORDER BY buy_id;
SELECT name_client	-- 2.4.12
FROM author INNER JOIN book USING(author_id)
     INNER JOIN buy_book USING(book_id)
     INNER JOIN buy USING(buy_id)
     INNER JOIN client USING(client_id)
WHERE name_author LIKE 'Достоевский%';
SELECT name_genre, SUM(buy_book.amount) Количество	-- 2.4.13
FROM genre INNER JOIN book USING(genre_id)
           INNER JOIN buy_book USING(book_id)
GROUP BY name_genre
HAVING SUM(buy_book.amount) = (													
							   SELECT SUM(buy_book.amount)
							   FROM buy_book INNER JOIN book USING(book_id) 
                               GROUP BY genre_id 
                               ORDER BY 1 DESC 
                               LIMIT 1
							  );
-- второй вариант                              
WITH qq AS (SELECT name_genre, sum(bb.amount) AS Количество
                FROM genre g
                         JOIN book b
                         USING (genre_id)
                         JOIN buy_book bb
                         USING (book_id)
               GROUP BY name_genre)
SELECT name_genre, Количество
  FROM qq
HAVING количество = (SELECT max(Количество) FROM qq);
SELECT YEAR(buy_step.date_step_end) AS Год, MONTHNAME(buy_step.date_step_end) AS Месяц, SUM(book.price*buy_book.amount) AS Сумма	-- 2.4.14
FROM book INNER JOIN buy_book USING (book_id)
          INNER JOIN buy_step USING (buy_id)
          INNER JOIN step USING(step_id)
WHERE name_step = 'Оплата' AND date_step_end IS NOT NULL
GROUP BY 1, 2
UNION ALL
SELECT YEAR(date_payment), MONTHNAME(date_payment), SUM(price*amount)
FROM buy_archive
GROUP BY 1, 2
ORDER BY 2, 1;
-- второй вариант
WITH Sales AS (
    SELECT  book.price * bb.amount AS cost, date_step_end AS date
    FROM    buy b
    JOIN    buy_step bs USING(buy_id)
    JOIN    step s USING(step_id)
    JOIN    buy_book bb USING(buy_id)
    JOIN    book USING(book_id)
    WHERE   (NOT date_step_end IS NULL) AND
            (name_step = 'Оплата')
    UNION ALL
    SELECT  price * amount, date_payment
    FROM    buy_archive
			   )
SELECT YEAR(date) AS Год, MONTHNAME(date) AS Месяц, SUM(cost) AS Сумма
FROM Sales
GROUP BY YEAR(date), MONTHNAME(date)
ORDER BY MONTHNAME(date), YEAR(date);
SELECT title, SUM(total.amount) Количество, SUM(total.amount * total.price) Сумма	-- 2.4.15
FROM book 
INNER JOIN (SELECT book_id, buy_book.amount, price
			FROM buy_book INNER JOIN buy_step USING(buy_id)
						  INNER JOIN book USING(book_id)
			WHERE step_id = 1 AND date_step_end
			UNION ALL
			SELECT book_id, amount, price
			FROM buy_archive) AS total
USING(book_id)
GROUP BY title
ORDER BY Сумма DESC;
INSERT INTO client (name_client, city_id, email)	-- 2.5.2
VALUES ('Попов Илья', (SELECT city_id FROM city WHERE name_city = 'Москва'), 'popov@test');
-- второй вариант
INSERT INTO client (name_client, city_id, email)
SELECT 'Попов Илья', (SELECT city_id FROM city WHERE name_city = 'Москва'), 'popov@test';
INSERT INTO buy (buy_description, client_id)	-- 2.5.3
SELECT 'Связаться со мной по вопросу доставки', (SELECT client_id FROM client WHERE name_client = 'Попов Илья');
INSERT INTO buy_book (buy_id, book_id, amount)	-- 2.5.4
VALUES (5, (SELECT book_id FROM book JOIN author USING(author_id) 
                          WHERE title = 'Лирика' AND name_author LIKE 'Пастернак%'), 2),
       (5, (SELECT book_id FROM book JOIN author USING(author_id) 
                          WHERE title = 'Белая гвардия' AND name_author LIKE 'Булгаков%'), 1);
UPDATE book JOIN buy_book USING(book_id)	-- 2.5.5
SET book.amount = book.amount - buy_book.amount
WHERE buy_book.buy_id = 5;
CREATE TABLE buy_pay	-- 2.5.6
SELECT title, name_author, price, buy_book.amount, price * buy_book.amount AS Стоимость
FROM author JOIN book USING(author_id)
            JOIN buy_book USING(book_id)
WHERE buy_id = 5
ORDER BY title;
CREATE TABLE buy_pay	-- 2.5.7
SELECT buy_id, SUM(buy_book.amount) AS Количество, SUM(price * buy_book.amount) AS Итого
FROM book JOIN buy_book USING(book_id)
WHERE buy_id = 5;
INSERT INTO buy_step (buy_id, step_id)	-- 2.5.8
SELECT 5, step_id FROM step;
-- второй вариант
INSERT INTO buy_step (buy_id, step_id)
SELECT buy_id, step_id FROM buy CROSS JOIN step	-- либо FROM buy, step
WHERE buy_id = 5;
UPDATE buy_step	-- 2.5.9
SET date_step_beg = '2020-04-12'
WHERE buy_id = 5 AND step_id = 1;
SET @sid := (SELECT step_id FROM step WHERE name_step = "Оплата");	-- 2.5.10
SET @d:='2020-04-13';
UPDATE buy_step	
SET date_step_end = IF(step_id = @sid, @d, date_step_end),
    date_step_beg = IF(step_id = @sid + 1, @d, date_step_beg)
WHERE buy_id = 5;
-- второй вариант
UPDATE buy_step INNER JOIN step USING(step_id)
SET date_step_end = '2020-04-13'
WHERE name_step = 'Оплата' AND buy_id = 5;
UPDATE buy_step
SET date_step_beg = '2020-04-13'
WHERE (step_id = (SELECT step_id+1 FROM step WHERE name_step = 'Оплата')) AND buy_id = 5;
-- третий вариант
UPDATE buy_step bs1 INNER JOIN buy_step bs2 USING(buy_id)
SET bs1.date_step_end = '2020-04-13',
    bs2.date_step_beg = '2020-04-13'
WHERE bs1.buy_id = 5
      AND bs1.step_id = (SELECT step_id FROM step WHERE name_step = 'Оплата')
      AND bs2.step_id = bs1.step_id + 1;
UPDATE client INNER JOIN buy USING(client_id)	-- 2.5.11
              INNER JOIN buy_book USING(buy_id)
              INNER JOIN book USING(book_id)
              INNER JOIN author USING(author_id)
SET name_client = CONCAT_WS('-', LEFT(name_author,3), name_client)
WHERE name_author LIKE 'Булгаков%';


CREATE TABLE t1 (id int, v varchar(1));
CREATE TABLE t2 (id int, v varchar(1));
INSERT INTO t1
values
(1, 'a'),
(null, 'b'),
(1, 'c'),
(6, 'd'),
(5, 'e'),
(null, 'f');
INSERT INTO t2
VALUES
(1, 'a'),
(1, 'b'),
(2, 'c'),
(null, 'd'),
(3, 'e'),
(5, 'f'),
(null, 'g');
SELECT t1.id, t2.id
FROM t1 
    LEFT JOIN t2
            ON t1.id = t2.id;
SELECT t1.v, t2.v
FROM t1 
    LEFT JOIN t2
            ON t1.id = t2.id;
SELECT 2 FROM t2;
select * from (select id FROM t1) t;

DROP TABLE IF EXISTS `t1`;
CREATE TABLE t1 (f1 INT NOT NULL, f2 INT NOT NULL, PRIMARY KEY(f1, f2));
INSERT INTO t1 VALUES
  (1,1), (1,2), (1,3), (1,4), (1,5),
  (2,1), (2,2), (2,3), (2,4), (2,5);
INSERT INTO t1 SELECT f1, f2 + 5 FROM t1;
INSERT INTO t1 SELECT f1, f2 + 10 FROM t1;
INSERT INTO t1 SELECT f1, f2 + 20 FROM t1;
INSERT INTO t1 SELECT f1, f2 + 40 FROM t1;
ANALYZE TABLE t1;

EXPLAIN SELECT f1, f2 FROM t1 WHERE f2 > 40;

SELECT name_student, date_attempt, result	-- 3.1.2
FROM subject INNER JOIN attempt USING(subject_id)
             INNER JOIN student USING(student_id)
WHERE name_subject LIKE 'Основы баз данных'
ORDER BY 3 DESC;
SELECT name_subject, COUNT(result) AS Количество, ROUND(AVG(result), 2) AS Среднее	-- 3.1.3
FROM subject LEFT JOIN attempt USING(subject_id)
GROUP BY name_subject
ORDER BY AVG(result) DESC;
SELECT name_student, result	-- 3.1.4
FROM student INNER JOIN attempt USING(student_id)
WHERE result = (SELECT MAX(result) FROM attempt)
ORDER BY name_student;
SELECT name_student, name_subject, DATEDIFF(MAX(date_attempt), MIN(date_attempt)) AS Интервал	-- 3.1.5
FROM student JOIN attempt USING(student_id)
             JOIN subject USING(subject_id)
GROUP BY name_student, name_subject
HAVING COUNT(name_student)>1
ORDER BY 3;
SELECT name_subject, COUNT(DISTINCT student_id) AS Количество	-- 3.1.6
FROM subject LEFT JOIN attempt USING(subject_id)
GROUP BY 1
ORDER BY 2 DESC, 1;
SELECT question_id, name_question	-- 3.1.7
FROM subject INNER JOIN question USING(subject_id)
WHERE name_subject = 'Основы баз данных'
ORDER BY RAND()
LIMIT 3;
SELECT name_question, name_answer, IF(is_correct, 'Верно','Неверно') AS 'Результат'	-- 3.1.8
FROM answer JOIN testing ON answer.answer_id = testing.answer_id
            JOIN question ON question.question_id = testing.question_id
WHERE attempt_id = 7;
SELECT name_student, name_subject, date_attempt, ROUND(SUM(is_correct) / 3 * 100, 2) AS 'Результат'	-- 3.1.9
FROM student INNER JOIN attempt ON student.student_id = attempt.student_id
             INNER JOIN testing ON attempt.attempt_id = testing.attempt_id
             INNER JOIN subject ON subject.subject_id = attempt.subject_id
             INNER JOIN answer ON answer.answer_id = testing.answer_id
GROUP BY name_student, name_subject, date_attempt	-- GROUP BY attempt_id
ORDER BY name_student, date_attempt DESC;
SELECT name_subject, CONCAT(LEFT(name_question,30),'...') Вопрос, 
	   COUNT(testing.answer_id) Всего_ответов, ROUND(AVG(is_correct)*100,2) Успешность	-- 3.1.10
FROM subject INNER JOIN question ON subject.subject_id = question.subject_id
             INNER JOIN testing ON question.question_id = testing.question_id
             INNER JOIN answer ON answer.answer_id = testing.answer_id
GROUP BY 2, 1
ORDER BY 1, 4 DESC, 2;
SELECT name_subject, CONCAT(LEFT(name_question,30),'...') AS Вопрос, Complexity	-- 3.1.11 вопрос Фернандес (лучше с WITH или сначала создать таблицу с макс и мин сложностью)
FROM subject INNER JOIN question ON subject.subject_id = question.subject_id
             INNER JOIN 
((SELECT testing.question_id, ROUND(SUM(answer.is_correct)/COUNT(answer.is_correct)*100, 2), 
        'Самый сложный' AS Complexity
FROM testing INNER JOIN answer ON testing.answer_id = answer.answer_id
GROUP BY testing.question_id
ORDER BY 2
LIMIT 1)
UNION
(SELECT testing.question_id, ROUND(SUM(answer.is_correct)/COUNT(answer.is_correct)*100, 2), 
 'Самый легкий' AS Complexity
FROM testing INNER JOIN answer ON testing.answer_id = answer.answer_id
GROUP BY testing.question_id
ORDER BY 2 DESC
LIMIT 1)) AS tmp ON question.question_id = tmp.question_id;
INSERT INTO attempt (student_id, subject_id, date_attempt)	-- 3.2.2
SELECT student_id, subject_id, NOW()
FROM student, subject
WHERE name_student = 'Баранов Павел' AND name_subject = 'Основы баз данных';
-- второй вариант
INSERT INTO attempt (student_id, subject_id, date_attempt) 
VALUES(   
	(SELECT student_id FROM student WHERE name_student = 'Баранов Павел'),
    (SELECT subject_id FROM subject WHERE name_subject = 'Основы баз данных'),
    NOW()
    );
INSERT INTO testing (attempt_id, question_id)	-- 3.2.3
SELECT attempt_id, question_id
FROM  question INNER JOIN attempt USING (subject_id)
WHERE attempt_id = (SELECT MAX(attempt_id) FROM attempt)
ORDER BY RAND()
LIMIT 3;
-- второй вариант
INSERT INTO testing (attempt_id, question_id)
SELECT attempt_id, question_id
FROM question JOIN attempt USING (subject_id)
ORDER BY attempt_id DESC, RAND()
LIMIT 3;
UPDATE attempt 	-- 3.2.4
SET result = (SELECT ROUND(SUM(is_correct)/3*100)
              FROM testing INNER JOIN answer USING(answer_id) 
              WHERE attempt_id = 8)
WHERE attempt_id = 8;
DELETE FROM attempt	-- 3.2.5
WHERE date_attempt < '2020-05-01';
INSERT INTO attempt (student_id, subject_id, date_attempt)	-- 3.2.6 задание Фернандес
SELECT student_id, subject_id, NOW()
FROM (SELECT student_id, subject_id, COUNT(*) Numb, AVG(result) Av
      FROM attempt
      GROUP BY 1,2) t
WHERE Numb < 3 AND Av < 60;