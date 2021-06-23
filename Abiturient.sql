SELECT name_enrollee	-- 3.3.2
FROM enrollee INNER JOIN program_enrollee USING(enrollee_id)
              INNER JOIN program USING(program_id)
WHERE name_program = 'Мехатроника и робототехника'
ORDER BY 1;
SELECT name_program	-- 3.3.3
FROM program INNER JOIN program_subject USING(program_id)
			 INNER JOIN subject USING(subject_id)
WHERE name_subject = 'Информатика'
ORDER BY 1 DESC;
SELECT name_subject, count(enrollee_id) Количество, MAX(result) Максимум, MIN(result) Минимум, ROUND(AVG(result),1) Среднее	-- 3.3.4
FROM subject INNER JOIN enrollee_subject USING(subject_id)
GROUP BY 1
ORDER BY 1;
SELECT name_program	-- 3.3.5
FROM program JOIN program_subject USING(program_id)
GROUP BY 1
HAVING MIN(min_result) >= 40
ORDER BY 1;
-- второй вариант
select p.name_program
from program p
where 40 <= all(
    select ps.min_result
    from program_subject ps 
    where ps.program_id = p.program_id)
order by p.name_program;
SELECT name_program, plan	-- 3.3.6
FROM program
WHERE plan = (SELECT MAX(plan) FROM program p1);
-- !!!!!!!!!!!!! ВАЖНО!!!!!!!!! ПРО RIGHT и LEFT JOIN !!!!!!!!!!!!!!!
SELECT name_enrollee, COALESCE(Бонус, 0) Бонус	-- 3.3.7	 IFNULL(Бонус, 0)
FROM enrollee LEFT JOIN (SELECT enrollee_id, SUM(bonus) Бонус
                         FROM enrollee_achievement
                         JOIN achievement USING(achievement_id)
                         GROUP BY 1) e USING(enrollee_id)
ORDER BY 1;
-- второй вариант
SELECT name_enrollee, COALESCE(SUM(bonus), 0) Бонус
FROM enrollee LEFT JOIN enrollee_achievement USING(enrollee_id)
                         LEFT JOIN achievement USING(achievement_id)
GROUP BY 1
ORDER BY 1;
-- третий вариант
SELECT name_enrollee, COALESCE(SUM(bonus), 0) Бонус
FROM achievement JOIN enrollee_achievement USING(achievement_id) 
                 RIGHT JOIN enrollee USING(enrollee_id)
GROUP BY 1
ORDER BY 1;

SELECT name_department, name_program, plan, COUNT(enrollee_id) Количество, ROUND(COUNT(enrollee_id)/plan,2) Конкурс	-- 3.3.8
FROM department INNER JOIN program USING(department_id)
                  INNER JOIN program_enrollee USING(program_id)
GROUP BY 1,2,3
ORDER BY 5 DESC;
SELECT name_program		-- 3.3.9
FROM program INNER JOIN program_subject USING(program_id)
             INNER JOIN subject USING(subject_id)
WHERE name_subject IN ('Информатика', 'Математика')
GROUP BY name_program
HAVING COUNT(name_program) > 1
ORDER BY 1;
SELECT name_program, name_enrollee, SUM(result) itog -- 3.3.10
FROM program_enrollee JOIN program USING(program_id)
                      JOIN enrollee USING(enrollee_id)
                      JOIN program_subject USING(program_id)
                      JOIN enrollee_subject ON enrollee_subject.enrollee_id = enrollee.enrollee_id
                                            AND enrollee_subject.subject_id = program_subject.subject_id
GROUP BY 1,2                      
ORDER BY 1, 3 DESC;
SELECT DISTINCT name_program, name_enrollee -- , min_result, result	 3.3.11
FROM program_enrollee JOIN program USING(program_id)
                      JOIN enrollee USING(enrollee_id)
                      JOIN program_subject USING(program_id)
                      JOIN enrollee_subject USING(enrollee_id, subject_id)
WHERE result < min_result
ORDER BY 1, 2;
CREATE TABLE applicant		-- 3.4.2
SELECT program_id, enrollee_id, SUM(result) itog
FROM program_enrollee JOIN program_subject USING (program_id)
                      JOIN enrollee_subject USING (subject_id, enrollee_id)
GROUP BY 1, 2
ORDER BY 1, 3 DESC;
DELETE FROM applicant		-- 3.4.3
USING applicant JOIN program_subject USING(program_id)
                JOIN enrollee_subject USING(enrollee_id, subject_id)
WHERE result < min_result;
-- второй вариант
DELETE FROM applicant
WHERE (program_id, enrollee_id) IN (SELECT DISTINCT program_id, enrollee_id
                                   FROM program_enrollee JOIN program_subject USING(program_id)
                                                         JOIN enrollee_subject USING(enrollee_id, subject_id)
                                   WHERE result < min_result
                                  );
UPDATE applicant INNER JOIN (		-- 3.4.4
                            SELECT enrollee_id, COALESCE(SUM(bonus), 0) bonus
                            FROM achievement JOIN enrollee_achievement USING(achievement_id)
                            GROUP BY 1
                             ) t USING(enrollee_id)
SET itog = itog + bonus;
SET @num_pr := 0;					-- 3.4.7
SET @row_num := 1;
UPDATE applicant_order INNER JOIN (SELECT program_id, enrollee_id, 
                                       if(program_id = @num_pr, @row_num := @row_num + 1, @row_num := 1) AS str_num,
                                       @num_pr := program_id AS add_var 
                                   FROM applicant_order) AS t
USING(program_id, enrollee_id)
SET str_id = str_num;
-- второй вариант
UPDATE applicant_order
-- !!!!!!!!!!!!!!!!!!!!!!!!!!!! в IF() можно использовать AND
SET str_id = if(program_id = @num_pr, @row_num := @row_num + 1, @row_num := 1 AND @num_pr := program_id); -- !!!!!!!!!!!!!!!!!!!!!!!!!!
/* или SET str_id = if(program_id = @num_pr, @row_num := @row_num + 1, @row_num := 1), program_id = @num_pr := program_id
или SET str_id = IF (@num_pr = program_id, @row_num := @row_num + 1, IF (@num_pr := program_id, @row_num := 1, @row_num := 1))*/
