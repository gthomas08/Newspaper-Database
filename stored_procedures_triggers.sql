-- Procedures and Triggers

-- Part A Question 3a

DROP PROCEDURE IF EXISTS showArticles;

DELIMITER $

CREATE PROCEDURE showArticles(IN paperId VARCHAR(63), IN npName VARCHAR(63))
BEGIN

    DECLARE sumArticlePages INT DEFAULT 0; 
    DECLARE articlePages INT DEFAULT 0;
    DECLARE paperPages INT DEFAULT 0;
    DECLARE n INT DEFAULT 0;
    DECLARE i INT DEFAULT 0;

    SELECT COUNT(*) 
    INTO n 
    FROM article
    WHERE paper_id = paperId AND paper_newspaper_name = npName; 

    SET i=0;

    SELECT number_of_pages
    INTO paperPages
    FROM paper
    WHERE id = paperId AND newspaper_name = npName;

    SELECT title, journalist_email, approval_date, start_page, number_of_pages
    FROM article 
    LEFT JOIN submits ON path = article_path
    WHERE paper_id = paperId AND paper_newspaper_name = npName
    ORDER BY start_page ASC;
    

    WHILE i<n DO 
        SELECT number_of_pages
        INTO articlePages
        FROM article
        WHERE paper_id = paperId AND paper_newspaper_name = npName
        LIMIT i,1;

        SET sumArticlePages = sumArticlePages + articlePages;

        SET i = i + 1;
    END WHILE;

    IF (paperPages > sumArticlePages) THEN
        SELECT "THERE ARE AVAILABLE PAGES FOR ARTICLES" AS 'MESSAGE';
    ELSE
        SELECT "THERE ARE NO AVAILABLE PAGES FOR ARTICLES" AS 'MESSAGE';
    END IF;

END$

DELIMITER ;

/*
-- Test Case:
call showArticles('paper455','The Informer');
*/



-- Part A Question 3b

DROP PROCEDURE IF EXISTS recalculateSalary;

DELIMITER $

CREATE PROCEDURE recalculateSalary(IN journalistEmail VARCHAR(63))
BEGIN

    DECLARE hiringDate DATE;
    DECLARE overallWorkExp INT DEFAULT 0;
    DECLARE workExp INT DEFAULT 0;
    DECLARE initialSalary INT DEFAULT 0;
    DECLARE newSalary INT DEFAULT 0;

    SELECT hiring_date
    INTO hiringDate
    FROM employee
    WHERE email = journalistEmail;

    SELECT experience
    INTO workExp
    FROM journalist
    WHERE email = journalistEmail;

    SELECT salary
    INTO initialSalary
    FROM employee
    WHERE email = journalistEmail;

    SET overallWorkExp = ((DATEDIFF(CURDATE(), hiringDate)) / 30) + workExp;
    SET newSalary = initialSalary + (initialSalary * 0.005 * overallWorkExp);

    SELECT newSalary AS 'New Salary';

    /*
    -- If you want to update the table:

    UPDATE employee
    SET salary = newSalary
    WHERE email = journalistEmail;
    */

END$

DELIMITER ;

/*
-- Test Case:
call recalculateSalary('emma@example.org');
*/


-- Part A Question 3c

DROP TRIGGER IF EXISTS defaultSalary;

DELIMITER $

CREATE TRIGGER defaultSalary
BEFORE INSERT ON employee
FOR EACH ROW
BEGIN
    SET NEW.salary = 650;
END$

DELIMITER ;

/*
-- Test Case:
INSERT INTO `employee` (`email`, `firstname`, `lastname`, `salary`, `hiring_date`) VALUES ('eva@example.org', 'Cleveland', 'Feil', 1100, '2019-04-17');

-- Check Result:
SELECT * FROM employee WHERE email = 'eva@example.org';

-- Delete Test Case:
DELETE FROM employee WHERE email = 'eva@example.org';
*/

-- Part A Question 3d

DROP TRIGGER IF EXISTS editorInChiefCheck;

DELIMITER $

CREATE TRIGGER editorInChiefCheck
AFTER INSERT ON submits
FOR EACH ROW
BEGIN
    DECLARE result VARCHAR(63) DEFAULT NULL;

    SELECT name
    INTO result
    FROM newspaper
    INNER JOIN journalist ON editor_in_chief_email = email
    WHERE editor_in_chief_email = NEW.journalist_email;

    IF (result IS NOT NULL) THEN
        UPDATE journalist
        INNER JOIN submits ON journalist_email = email
        INNER JOIN article ON path = article_path
        SET status = 'accepted'
        WHERE journalist_email = NEW.journalist_email AND path = NEW.article_path;
    END IF;
END$

DELIMITER ;


/*
-- Test Case:
INSERT INTO `article` (`path`, `title`, `summary`, `number_of_pages`, `approval_date`, `status`, `comments`, `start_page`, `paper_id`, `paper_newspaper_name`, `category_id`) VALUES ('/newspaper/paper/articles/test.doc', 'Test Case', 'A test case', 10, NULL, 'to_be_revised', NULL, NULL, NULL, NULL, 3);
INSERT INTO `submits` (`journalist_email`, `article_path`, `submission_date`) VALUES ('liam@example.org', '/newspaper/paper/articles/test.doc', '2020-01-11');

-- Check Result:
SELECT * FROM `article` WHERE path = '/newspaper/paper/articles/test.doc';

-- Delete Test Case:
DELETE FROM `article` WHERE path = '/newspaper/paper/articles/test.doc';
*/



-- Part A Question 3e

DROP TRIGGER IF EXISTS spaceForArticle;

DELIMITER $

CREATE TRIGGER spaceForArticle
BEFORE INSERT ON article
FOR EACH ROW
BEGIN
    DECLARE sumArticlePages INT DEFAULT 0; 
    DECLARE articlePages INT DEFAULT 0;
    DECLARE paperPages INT DEFAULT NULL;
    DECLARE freeSpace INT DEFAULT 0;
    DECLARE n INT DEFAULT 0;
    DECLARE i INT DEFAULT 0;

    SELECT COUNT(*) 
    INTO n 
    FROM article
    WHERE paper_id = NEW.paper_id AND paper_newspaper_name = NEW.paper_newspaper_name; 

    SET i=0;

    SELECT number_of_pages
    INTO paperPages
    FROM paper
    WHERE id = NEW.paper_id AND newspaper_name = NEW.paper_newspaper_name;

    WHILE i<n DO 
        SELECT number_of_pages
        INTO articlePages
        FROM article
        WHERE paper_id = NEW.paper_id AND paper_newspaper_name = NEW.paper_newspaper_name
        LIMIT i,1;

        SET sumArticlePages = sumArticlePages + articlePages;

        SET i = i + 1;
    END WHILE;

    SET freeSpace = paperPages - sumArticlePages;

    IF (paperPages IS NOT NULL AND freeSpace < NEW.number_of_pages) THEN
        SIGNAL SQLSTATE VALUE '45000'
        SET MESSAGE_TEXT = 'INSUFFICIENT SPACE FOR ARTICLE IN THE PAPER';
    END IF;

END$

DELIMITER ;


/*
-- Check Test Paper number_of_pages:
SELECT * FROM paper WHERE id = 'paper322';

-- Test Case:
INSERT INTO `article` (`path`, `title`, `summary`, `number_of_pages`, `approval_date`, `status`, `comments`, `start_page`, `paper_id`, `paper_newspaper_name`, `category_id`) VALUES ('/newspaper/paper/articles/test.pdf', 'Test Case', 'Error will occur', 500, '2020-02-09', 'accepted', NULL, 40, 'paper322', 'News Time', 3);
*/
