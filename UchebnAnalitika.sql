SET @limit = 19;			-- 3.5.2
WITH steps AS
(
    SELECT
        module_id, lesson_id, lesson_position, step_id, step_position,
        CONCAT(module_id, ' ' , module_name) AS Модуль,
        CONCAT(module_id, '.', lesson_position, ' ' , lesson_name) AS Урок,
        CONCAT(module_id, '.', lesson_position, '.', step_position, ' ' , step_name) AS Шаг
    FROM
        module
        INNER JOIN lesson USING (module_id)
        INNER JOIN step   USING (lesson_id)
    WHERE LOWER(step_name) LIKE '%вложенн% запрос%'
)
SELECT
    IF(LENGTH(Модуль) <= @limit, Модуль, CONCAT(LEFT(Модуль, @limit-3), '...')) AS Модуль,
    IF(LENGTH(Урок)   <= @limit,   Урок, CONCAT(LEFT(  Урок, @limit-3), '...')) AS Урок,
    Шаг
FROM  steps
ORDER BY module_id, lesson_position, step_position;
INSERT INTO step_keyword (step_id, keyword_id)		-- 3.5.3
SELECT DISTINCT step_id, keyword_id 
FROM step, keyword
WHERE step_name REGEXP CONCAT('\\b', keyword_name, '\\b');	-- WHERE  REGEXP_LIKE(step_name, CONCAT('\\b', keyword_name, '\\b'));
SELECT CONCAT(module_id, '.', lesson_position, IF(step_position<10, '.0', '.'), step_position, ' ', step_name) Шаг	-- 3.5.4
FROM step JOIN step_keyword USING(step_id) 
          JOIN keyword USING(keyword_id)
          JOIN lesson USING(lesson_id)
          JOIN module USING(module_id)
WHERE keyword_name IN ('MAX', 'AVG')	-- where keyword_name regexp 'min|avg'
GROUP BY 1
HAVING COUNT(step_name) > 1
ORDER BY 1;
SELECT CASE 				-- 3.5.5.
           WHEN rate < 11 THEN 'I'
           WHEN rate < 16 THEN 'II'
           WHEN rate < 28 THEN 'III'
           ELSE 'IV'
       END AS Группа, 
       CASE
           WHEN rate < 11 THEN 'от 0 до 10'
           WHEN rate < 16 THEN 'от 11 до 15'
           WHEN rate < 28 THEN 'от 16 до 27'
           ELSE 'больше 27'
       END AS Интервал,
       COUNT(*) Количество
FROM (SELECT student_id, count(*) rate
      FROM step_student
      WHERE result = 'correct'
      GROUP BY 1) t
GROUP BY 1,2
ORDER BY 1;
WITH tt AS (							-- 3.5.6
    SELECT 
       step_name,
       SUM(CASE result WHEN 'correct' THEN 1 ELSE 0 END) ans_cor,
       SUM(CASE result WHEN 'wrong' THEN 1 ELSE 0 END) ans_wro
    FROM step INNER JOIN step_student USING (step_id)
    GROUP BY step_name)
SELECT step_name Шаг,
       ROUND(ans_cor / (ans_cor + ans_wro) * 100) Успешность
FROM tt
ORDER BY 2, 1;
-- второй вариант
/*SUM(IF(result='correct',1,0)) correct, count(*) total */
SELECT step_name Шаг, ROUND(SUM(IF(result='correct',1,0))/count(*)*100) Успешность -- ROUND(AVG(IF(result='correct',1,0))*100)
FROM step JOIN step_student USING (step_id)
GROUP BY 1
ORDER BY 2, 1;
-- SET @totalqw := (SELECT COUNT(*) FROM (SELECT step_id FROM step_student GROUP BY step_id) t)

SET @totalqw := (SELECT COUNT(DISTINCT step_id) FROM step_student);			-- 3.5.7
SELECT student_name Студент, 
       ROUND(COUNT(DISTINCT step_id)/@totalqw*100) Прогресс,
       CASE
           WHEN ROUND(COUNT(DISTINCT step_id)/@totalqw*100) = 100 THEN 'Сертификат с отличием'
           WHEN ROUND(COUNT(DISTINCT step_id)/@totalqw*100) > 80 THEN 'Сертификат'
           ELSE ''
       END AS Результат
FROM student JOIN step_student USING (student_id)
WHERE result = 'correct'
GROUP BY student_name, result
ORDER BY 2 desc, 1;
SELECT student_name Студент, 						-- 3.5.8
       CONCAT(LEFT(step_name,20), '...') Шаг, 
       result Результат, 
       FROM_UNIXTIME(submission_time) Дата_отправки,
       SEC_TO_TIME(submission_time - LAG(submission_time,1,submission_time) OVER(ORDER BY FROM_UNIXTIME(submission_time))) Разница
FROM step JOIN step_student USING(step_id)
          JOIN student USING(student_id)
WHERE student_name = 'student_61'
ORDER BY 4;
WITH tt AS(											-- 3.5.9
SELECT student_id, lesson_id, SUM(submission_time - attempt_time) total_time
FROM step JOIN step_student USING(step_id)
WHERE submission_time - attempt_time<=4*3600
GROUP BY 1,2)
SELECT row_number() OVER(ORDER BY ROUND(AVG(total_time)/3600,2)) Номер,
       CONCAT(module_id, '.', lesson_position, ' ', lesson_name) Урок,
       ROUND(AVG(total_time)/3600,2) Среднее_время
FROM tt JOIN lesson USING(lesson_id)
GROUP BY lesson_id;
-- второй вариант
SELECT ROW_NUMBER() OVER(ORDER BY SUM(submission_time - attempt_time) / COUNT(DISTINCT student_id))  AS Номер,
       CONCAT(module_id, '.', lesson_position, ' ', lesson_name) AS Урок,
       ROUND(SUM(submission_time - attempt_time) / COUNT(DISTINCT student_id) / 3600, 2) AS Среднее_время
    FROM step_student
        INNER JOIN step USING(step_id)
        INNER JOIN lesson USING(lesson_id)
    WHERE submission_time - attempt_time <= 4*3600
    GROUP BY Урок;
SELECT module_id Модуль, 						-- 3.5.10
       student_name Студент, 
       COUNT(DISTINCT step_id) Пройдено_шагов, 
       ROUND(COUNT(DISTINCT step_id)/MAX(COUNT(DISTINCT step_id)) OVER (PARTITION BY module_id)*100,1) Относительный_рейтинг
FROM student INNER JOIN step_student USING(student_id)
                INNER JOIN step USING (step_id)
                INNER JOIN lesson USING (lesson_id)
WHERE result = "correct"
GROUP BY module_id, student_name
ORDER BY 1, 4 DESC, 2;
-- второй вариант
WITH get_rate_lesson(mod_id, stud, rate) 
AS
(
   SELECT module_id, student_name, COUNT(DISTINCT step_id)
   FROM student INNER JOIN step_student USING(student_id)
                INNER JOIN step USING (step_id)
                INNER JOIN lesson USING (lesson_id)
   WHERE result = "correct"
   GROUP BY module_id, student_name
)
SELECT mod_id Модуль, 
       stud Студент, 
       rate Пройдено_шагов, 
       ROUND(rate / MAX(rate) OVER (PARTITION BY mod_id) * 100, 1) Относительный_рейтинг
FROM get_rate_lesson
ORDER BY 1, 4 DESC, 2;
WITH get_lesson AS					-- 3.5.11
(SELECT CONCAT(module_id,'.', lesson_position) les, student_id, MAX(submission_time) last_time
 FROM step_student INNER JOIN step USING (step_id) INNER JOIN lesson USING (lesson_id)
 WHERE result = "correct"
 GROUP BY 1,2
 ORDER BY 1,2
),
get_stud AS
(SELECT student_id
 FROM get_lesson
 GROUP BY student_id
 HAVING COUNT(*) = 3
)
SELECT student_name Студент, les Урок , FROM_UNIXTIME(last_time) Макс_время_отправки
       , IFNULL(CEIL((last_time - LAG(last_time) OVER (PARTITION BY student_name ORDER BY last_time)) / 86400),'-') Интервал
FROM get_stud JOIN get_lesson USING(student_id) JOIN student USING(student_id)
ORDER BY 1, 3;
SET @aver_time := (SELECT ROUND(AVG(submission_time - attempt_time))		-- 3.5.12
                 FROM step_student JOIN student USING(student_id)
                 WHERE student_name = 'student_59' AND (submission_time - attempt_time)/3600 < 1);
SELECT student_name Студент,
       CONCAT(module_id, '.', lesson_position, '.', step_position) Шаг,
       ROW_NUMBER() OVER (PARTITION BY CONCAT(module_id, '.', lesson_position, '.', step_position) ORDER BY submission_time) Номер_попытки,
       result Результат,
       SEC_TO_TIME(IF((submission_time - attempt_time)>3600, @aver_time, submission_time - attempt_time)) Время_попытки,
       ROUND((IF((submission_time - attempt_time)>3600, @aver_time, submission_time - attempt_time)) * 100 / SUM(IF((submission_time - attempt_time)>3600, @aver_time, submission_time - attempt_time)) OVER (PARTITION BY CONCAT(module_id, '.', lesson_position, '.', step_position)),2) Относительное_время
--       FROM_UNIXTIME(submission_time)
FROM step_student JOIN student USING(student_id)
                  JOIN step USING(step_id)
                  JOIN lesson USING(lesson_id)
WHERE student_name = 'student_59'
ORDER BY step_id, 3;
WITH prev_res (student_name, step_id, submission_time, result, previ) AS		 3.5.13
(
SELECT student_name, step_id, submission_time, result, 
       LAG(result) OVER(PARTITION BY step_id, student_name ORDER BY submission_time)
FROM student JOIN step_student USING(student_id)
ORDER BY student_name, step_id, submission_time
)

(SELECT 'I' Группа, student_name Студент, COUNT(*) Количество_шагов 
FROM prev_res
WHERE previ = 'correct' AND result = 'wrong'
GROUP BY student_name)
UNION
(SELECT 'II' Группа, student_name Студент, COUNT(*) Количество_шагов 
FROM (
      SELECT student_id, step_id, COUNT(*) FROM step_student
      WHERE result = 'correct'
      GROUP BY student_id, step_id
      HAVING COUNT(*) > 1) tt2 JOIN student USING(student_id)
GROUP BY student_name)
UNION
(SELECT 'III' Группа, student_name Студент, COUNT(DISTINCT step_id) Количество_шагов 
FROM (SELECT * FROM step_student p1
WHERE NOT EXISTS (SELECT 1
                  FROM step_student p2
                  WHERE p2.student_id = p1.student_id AND p2.step_id = p1.step_id AND result = 'correct')) tt3
     JOIN student USING(student_id)
GROUP BY student_name)
ORDER BY 1, 3 DESC, 2;
/* второй вариант подсчета III группы (студентов со всеми неверными попытками по какому-то шагу) ИЛИ можно Количество_правильных_ответов = 0
SELECT 'III' Группа, student_id Студент, COUNT(DISTINCT step_id) Количество_шагов 
FROM (SELECT student_id, step_id, SUM(IF(result='wrong',1,0)), COUNT(result)
FROM step_student
GROUP BY student_id, step_id
HAVING SUM(IF(result='wrong',1,0)) = COUNT(result)) tt4
GROUP BY student_id;*/
-- второй вариант
WITH q1 AS
(
SELECT student_name, step_id, 
       SUM(IF(result = 'correct', 1, 0)) OVER(PARTITION BY student_name, step_id) AS count_cor,
        (LAG(result) OVER(PARTITION BY student_name, step_id ORDER BY submission_time)) = 'correct' 
                AND result = 'wrong' AS is_first
FROM student 
    INNER JOIN step_student USING(student_id)
)

SELECT CASE
            WHEN is_first = 1 THEN 'I'
            WHEN count_cor >= 2 THEN 'II'
            WHEN count_cor = 0 THEN 'III'
        END AS 'Группа',
        student_name AS 'Студент',
        COUNT(DISTINCT step_id) AS Количество_шагов
FROM q1
GROUP BY 1, 2
HAVING Группа IS NOT NULL
ORDER BY 1, 3 DESC, 2;
