DROP SCHEMA  IF EXISTS `internet_store`;

CREATE SCHEMA `internet_store`;
use `internet_store`;

#DROP TABLE IF EXISTS `author`;
CREATE TABLE author (
      author_id INT PRIMARY KEY AUTO_INCREMENT, 
      name_author VARCHAR(50) 
      )ENGINE='InnoDB' AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
insert into author (name_author) value
('Булгаков М.А.'),
('Достоевский Ф.М.'),
('Есенин С.А.'),
('Пастернак Б.Л.'),
('Лермонтов М.Ю.'),
("Стивенсон Р.Л.");

#DROP TABLE IF EXISTS `genre`;
CREATE TABLE genre (
      genre_id INT PRIMARY KEY AUTO_INCREMENT, 
      name_genre VARCHAR(50) 
      )ENGINE='InnoDB' AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
insert into genre (name_genre) value
('Роман'),
('Поэзия'),
('Приключения');

#DROP TABLE IF EXISTS `book`;
CREATE TABLE book (
    book_id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(50),
    author_id INT,
    genre_id INT,
    price DECIMAL(8 , 2 ),
    amount INT,
    FOREIGN KEY (author_id)
        REFERENCES author (author_id)
        ON DELETE CASCADE,
    FOREIGN KEY (genre_id)
        REFERENCES genre (genre_id)
        ON DELETE SET NULL
)  ENGINE='InnoDB' AUTO_INCREMENT=1 DEFAULT CHARSET=UTF8;
insert into book (title,author_id,genre_id,price,amount) value
("Мастер и Маргарита","1","1","670.99","3"),
("Белая гвардия","1","1","540.50","12"),
("Идиот","2","1","460.00","13"),
("Братья Карамазовы","2","1","799.01","3"),
("Игрок","2","1","480.50","10"),
("Стихотворения и поэмы","3","2","650.00","15"),
("Черный человек","3","2","570.20","12"),
("Лирика","4","2","518.99","2"),
("Доктор Живаго",4,1,380.80,4),
("Стихотворения и поэмы",5,2,255.90 ,4),
("Остров сокровищ",6,3,599.99,5)  ;

CREATE TABLE city (
      city_id INT PRIMARY KEY AUTO_INCREMENT,
      name_city VARCHAR(50) ,
      days_delivery int
      )ENGINE='InnoDB' AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
insert into city (name_city,days_delivery) value
('Москва',5),
('Санкт-Петербург',3),
('Владивосток',12);

CREATE TABLE client (
    client_id INT PRIMARY KEY AUTO_INCREMENT,
    name_client VARCHAR(50),
    city_id INT,
    email VARCHAR(30),
    FOREIGN KEY (city_id)
        REFERENCES city (city_id)
        ON DELETE SET NULL
)  ENGINE=INNODB AUTO_INCREMENT=1 DEFAULT CHARSET=UTF8;
      
insert into client (name_client,city_id,email) value
("Баранов Павел",	3,	"baranov@test"),
("Абрамова Катя",	1,	"abramova@test"),
("Семенов Иван",	2,	"semenov@test"),
("Яковлева Галина",	1,	"yakovleva@test");

CREATE TABLE buy  (
      buy_id INT PRIMARY KEY AUTO_INCREMENT,
      buy_description	 VARCHAR(100) ,
      client_id int,
      FOREIGN KEY (client_id)
        REFERENCES client (client_id)
        ON DELETE SET NULL
      )ENGINE='InnoDB' AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
      
insert into buy  (buy_description,client_id) value
("Доставка только вечером",	1),
(null,	 	3),
("Упаковать каждую книгу по отдельности",	2),
(null,	 	1);

CREATE TABLE buy_book (
    buy_book_id INT PRIMARY KEY AUTO_INCREMENT,
    buy_id INT,
    book_id INT,
    amount int,
    FOREIGN KEY (buy_id)
        REFERENCES buy (buy_id)
        ON DELETE SET NULL,
    FOREIGN KEY (book_id)
        REFERENCES book (book_id)
        ON DELETE SET NULL
)  ENGINE=INNODB AUTO_INCREMENT=1 DEFAULT CHARSET=UTF8;
      
insert into buy_book  (buy_id,book_id, amount) value
(	1,	1,	1),
(	1,	7,	2),
(	2,	8,	2),
(	3,	3,	2),
(	3,	2,	1),
(	3,	1,	1),
(	4,	5,	1);

CREATE TABLE step (
    step_id INT PRIMARY KEY AUTO_INCREMENT,
    name_step varchar(30)
)  ENGINE=INNODB AUTO_INCREMENT=1 DEFAULT CHARSET=UTF8;
      
insert into step  (name_step) value
("Оплата"),
("Упаковка"),
("Транспортировка"),
("Доставка");

CREATE TABLE buy_step  (
    buy_step_id INT PRIMARY KEY AUTO_INCREMENT,
    buy_id INT,
    step_id INT,
    date_step_beg DATE,
    date_step_end DATE,
    FOREIGN KEY (buy_id)
        REFERENCES buy (buy_id)
        ON DELETE SET NULL,
    FOREIGN KEY (step_id)
        REFERENCES step (step_id)
        ON DELETE SET NULL
)  ENGINE=INNODB AUTO_INCREMENT=1 DEFAULT CHARSET=UTF8;
      
insert into buy_step   (buy_id,step_id, date_step_beg, date_step_end) value
(	1, 	1,	"2020-02-20","2020-02-20"),
(	1,	2,	"2020-02-20","2020-02-21"),
(	1,	3,	"2020-02-22","2020-03-07"),
(	1,	4,	"2020-03-08","2020-03-08"),
(	2,	1,	"2020-02-28","2020-02-28"),
(	2,	2,	"2020-02-29","2020-03-01"),
(	2,	3,	"2020-03-02",		null),
(	2,	4,			null,		null),
(	3,	1,	"2020-03-05","2020-03-05"),
(	3,	2,	"2020-03-05","2020-03-06"),
(	3,	3,	"2020-03-06","2020-03-10"),
(	3,	4,	"2020-03-11",		null),
(	4,	1,	"2020-03-20	", 		null),
(	4,	2,			null,		null),
(	4,	3,	 	 	null,		null),
(	4,	4,	 		null,		null);

CREATE TABLE buy_archive  (
    buy_archive_id INT PRIMARY KEY AUTO_INCREMENT,
    buy_id INT,
    client_id INT,
    book_id INT,
    date_payment DATE,
	price DECIMAL(8 , 2 ),
    amount INT
    )  ENGINE=INNODB AUTO_INCREMENT=1 DEFAULT CHARSET=UTF8;
insert into buy_archive  (buy_archive_id, buy_id, client_id, book_id, date_payment, price, amount) value
(	1, 2, 1, 1, "2019-02-21", 670.60, 2),
(	2, 2, 1, 3, "2019-02-21", 450.90, 1),
(	3, 1, 2, 2, "2019-02-10", 520.30, 2),
(	4, 1, 2, 4, "2019-02-10", 780.90, 3),
(	5, 1, 2, 3, "2019-02-10", 450.90, 1),
(	6, 3, 4, 4, "2019-03-05", 780.90, 4),
(	7, 3, 4, 5, "2019-03-05", 480.90, 2),
(	8, 4, 1, 6, "2019-03-12", 650.00, 1),
(	9, 5, 2, 1, "2019-03-18", 670.60, 2),
(	10, 5, 2, 4, "2019-03-18", 780.90, 1);