CREATE TABLE person
(person_id SMALLINT UNSIGNED,
fname VARCHAR(20),
lname VARCHAR(20),
gender ENUM('M','F'),
birth_date DATE,
street VARCHAR(30),
city VARCHAR(20),
state VARCHAR(20),
country VARCHAR(20),
postal_code VARCHAR(20),
CONSTRAINT pk_person PRIMARY KEY (person_id)
 );
 
CREATE TABLE favorite_food
(person_id SMALLINT UNSIGNED,
food VARCHAR(20),
CONSTRAINT pk_favorite_food PRIMARY KEY (person_id, food),
CONSTRAINT fk_fav_food_person_id FOREIGN KEY (person_id)
REFERENCES person (person_id)
);

set foreign_key_checks=0;
ALTER TABLE person MODIFY person_id SMALLINT UNSIGNED AUTO_INCREMENT;
set foreign_key_checks=1;
INSERT INTO person
(person_id, fname, lname, gender, birth_date)
VALUES (null, 'William','Turner', 'M', '1972-05-27');
SELECT person_id, fname, lname, birth_date
FROM person;
SELECT person_id, fname, lname, birth_date
FROM person
WHERE lname = 'Turner';
INSERT INTO favorite_food (person_id, food)
VALUES (1, 'pizza');
INSERT INTO favorite_food (person_id, food)
VALUES (1, 'cookies');
INSERT INTO favorite_food (person_id, food)
VALUES (1, 'nachos');
SELECT food
FROM favorite_food
WHERE person_id = 1
ORDER BY food DESC;
INSERT INTO person
(person_id, fname, lname, gender, birth_date,
street, city, state, country, postal_code)
VALUES (null, 'Susan','Smith', 'F', '1975-11-02',
'23 Maple St.', 'Arlington', 'VA', 'USA', '20220');
UPDATE person
SET street = '1225 Tremont St.',
city = 'Boston',
state = 'MA',
country = 'USA',
postal_code = '02138'
WHERE person_id = 1;
select * from person;
DELETE FROM person
WHERE person_id = 2;

use bank;
select * from customer;
SELECT pt.name product_type, p.name product
 FROM product p INNER JOIN product_type pt
 ON p.product_type_cd = pt.product_type_cd
 WHERE pt.name != 'Customer Accounts';
SELECT *
FROM employee
WHERE YEAR(start_date) = 2002;
DESC employee;
SELECT MAX(avail_balance) max_balance,
    MIN(avail_balance) min_balance,
    AVG(avail_balance) avg_balance,
    SUM(avail_balance) tot_balance,
    COUNT(*) num_accounts
FROM account
 WHERE product_cd = 'CHK';
SELECT product_cd, open_branch_id, SUM(avail_balance) tot_balance
FROM account
GROUP BY product_cd , open_branch_id
HAVING COUNT(*) > 1
ORDER BY 3 DESC;
SELECT cust_id, COUNT(*)
FROM account
GROUP BY cust_id
HAVING COUNT(*) >= 2;
SELECT account_id, product_cd, cust_id, avail_balance
 FROM account
WHERE account_id = (SELECT MAX(account_id) FROM account);
SELECT e.emp_id
FROM employee e INNER JOIN branch b
 ON e.assigned_branch_id = b.branch_id
WHERE e.title = 'Head Teller' AND b.city = 'Woburn';

SELECT e.emp_id, e.fname, e.lname, levels.name
FROM employee e INNER JOIN (
	SELECT 'trainee' name, 1 srt, '2004-01-01' start_dt, '2005-12-31' end_dt
UNION ALL
SELECT 'worker' name, 2 srt, '2002-01-01' start_dt, '2003-12-31' end_dt
UNION ALL
SELECT 'mentor' name, 3 srt, '2000-01-01' start_dt, '2001-12-31' end_dt) levels
 ON e.start_date BETWEEN levels.start_dt AND levels.end_dt
ORDER BY srt, emp_id;

 SELECT all_prods.product, all_prods.branch,
	all_prods.name, all_prods.tot_deposits
FROM
	(SELECT
		(SELECT p.name FROM product p
		WHERE p.product_cd = a.product_cd
			AND p.product_type_cd = 'ACCOUNT') product,
		(SELECT b.name FROM branch b
		WHERE b.branch_id = a.open_branch_id) branch,
		(SELECT CONCAT(e.fname, ' ', e.lname) FROM employee e
		WHERE e.emp_id = a.open_emp_id) name,
		SUM(a.avail_balance) tot_deposits
		FROM account a
		GROUP BY a.product_cd, a.open_branch_id, a.open_emp_id
		) all_prods
		WHERE all_prods.product IS NOT NULL
ORDER BY 1,2;

select *
from employee
order by field(emp_id, 5);
select field(emp_id, 5)
from employee;

SELECT emp.emp_id, CONCAT(emp.fname, ' ', emp.lname) emp_name,
(SELECT CONCAT(boss.fname, ' ', boss.lname)
FROM employee boss
WHERE boss.emp_id = emp.superior_emp_id) boss_name
FROM employee emp
WHERE emp.superior_emp_id IS NOT NULL
ORDER BY (SELECT boss.lname FROM employee boss
WHERE boss.emp_id = emp.superior_emp_id), emp.lname;
SELECT e.emp_id, CONCAT(e.fname, ' ', e.lname) emp_name,
	(SELECT d.name FROM department d WHERE d.dept_id = e.dept_id) department,
    (SELECT b.name FROM branch b WHERE b.branch_id = e.assigned_branch_id) branch
FROM employee e;
