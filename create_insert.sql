-- CREATE Statements

-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL,ALLOW_INVALID_DATES';

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------
-- -----------------------------------------------------
-- Schema newspaper_publisher
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema newspaper_publisher
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `newspaper_publisher` DEFAULT CHARACTER SET utf8 ;
USE `newspaper_publisher` ;

-- -----------------------------------------------------
-- Table `newspaper_publisher`.`employee`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `newspaper_publisher`.`employee` (
  `email` VARCHAR(63) NOT NULL,
  `firstname` VARCHAR(63) NOT NULL,
  `lastname` VARCHAR(63) NOT NULL,
  `salary` INT NOT NULL,
  `hiring_date` DATE NOT NULL,
  PRIMARY KEY (`email`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `newspaper_publisher`.`administrative`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `newspaper_publisher`.`administrative` (
  `email` VARCHAR(63) NOT NULL,
  `city` VARCHAR(63) NOT NULL,
  `street` VARCHAR(63) NOT NULL,
  `street_number` INT NOT NULL,
  `duties` ENUM('Secretary', 'Logistics') NOT NULL DEFAULT 'Secretary',
  PRIMARY KEY (`email`),
  CONSTRAINT `isa_administrative`
    FOREIGN KEY (`email`)
    REFERENCES `newspaper_publisher`.`employee` (`email`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `newspaper_publisher`.`category`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `newspaper_publisher`.`category` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(63) NOT NULL,
  `description` VARCHAR(63) NOT NULL,
  `parent_id` INT NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_category_category1_idx` (`parent_id` ASC),
  CONSTRAINT `child_category`
    FOREIGN KEY (`parent_id`)
    REFERENCES `newspaper_publisher`.`category` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `newspaper_publisher`.`journalist`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `newspaper_publisher`.`journalist` (
  `email` VARCHAR(63) NOT NULL,
  `experience` INT NOT NULL,
  `resume` LONGTEXT NOT NULL,
  PRIMARY KEY (`email`),
  INDEX `fk_table1_employee1_idx` (`email` ASC),
  CONSTRAINT `isa_journalist`
    FOREIGN KEY (`email`)
    REFERENCES `newspaper_publisher`.`employee` (`email`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `newspaper_publisher`.`newspaper`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `newspaper_publisher`.`newspaper` (
  `name` VARCHAR(63) NOT NULL,
  `publishing_frequency` ENUM('Daily', 'Weekly', 'Monthly') NOT NULL DEFAULT 'Weekly',
  `owner_email` VARCHAR(63) NOT NULL,
  `editor_in_chief_email` VARCHAR(63) NOT NULL,
  PRIMARY KEY (`name`),
  INDEX `fk_newspaper_employee1_idx` (`owner_email` ASC),
  INDEX `fk_newspaper_journalist1_idx` (`editor_in_chief_email` ASC),
  CONSTRAINT `in_chief`
    FOREIGN KEY (`editor_in_chief_email`)
    REFERENCES `newspaper_publisher`.`journalist` (`email`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `ownership`
    FOREIGN KEY (`owner_email`)
    REFERENCES `newspaper_publisher`.`employee` (`email`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `newspaper_publisher`.`paper`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `newspaper_publisher`.`paper` (
  `id` VARCHAR(63) NOT NULL,
  `number_of_pages` INT NOT NULL DEFAULT '30',
  `publishing_date` DATE NOT NULL,
  `copies` INT NOT NULL,
  `copies_sold` INT NOT NULL DEFAULT '0',
  `copies_returned` INT NOT NULL DEFAULT 0,
  `newspaper_name` VARCHAR(63) NOT NULL,
  PRIMARY KEY (`id`, `newspaper_name`),
  INDEX `fk_paper_newspaper1_idx` (`newspaper_name` ASC),
  CONSTRAINT `identifying_newspaper`
    FOREIGN KEY (`newspaper_name`)
    REFERENCES `newspaper_publisher`.`newspaper` (`name`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `newspaper_publisher`.`article`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `newspaper_publisher`.`article` (
  `path` VARCHAR(127) NOT NULL,
  `title` VARCHAR(63) NOT NULL,
  `summary` LONGTEXT NOT NULL,
  `number_of_pages` INT NOT NULL,
  `approval_date` DATE NULL DEFAULT NULL,
  `status` ENUM('accepted', 'to_be_revised', 'rejected') NULL DEFAULT 'to_be_revised',
  `comments` LONGTEXT NULL DEFAULT NULL,
  `start_page` INT NULL DEFAULT NULL,
  `paper_id` VARCHAR(63) NULL DEFAULT NULL,
  `paper_newspaper_name` VARCHAR(63) NULL DEFAULT NULL,
  `category_id` INT NOT NULL,
  PRIMARY KEY (`path`),
  INDEX `fk_article_paper1_idx` (`paper_id` ASC, `paper_newspaper_name` ASC),
  INDEX `fk_article_category1_idx` (`category_id` ASC),
  CONSTRAINT `belongs`
    FOREIGN KEY (`category_id`)
    REFERENCES `newspaper_publisher`.`category` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `publishes`
    FOREIGN KEY (`paper_id` , `paper_newspaper_name`)
    REFERENCES `newspaper_publisher`.`paper` (`id` , `newspaper_name`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `newspaper_publisher`.`keywords`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `newspaper_publisher`.`keywords` (
  `article_path` VARCHAR(127) NOT NULL,
  `keyword` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`article_path`, `keyword`),
  CONSTRAINT `keywords`
    FOREIGN KEY (`article_path`)
    REFERENCES `newspaper_publisher`.`article` (`path`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `newspaper_publisher`.`submits`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `newspaper_publisher`.`submits` (
  `journalist_email` VARCHAR(63) NOT NULL,
  `article_path` VARCHAR(127) NOT NULL,
  `submission_date` DATE NOT NULL,
  PRIMARY KEY (`journalist_email`, `article_path`),
  INDEX `fk_journalist_has_article_article1_idx` (`article_path` ASC),
  INDEX `fk_journalist_has_article_journalist1_idx` (`journalist_email` ASC),
  CONSTRAINT `article_submitted`
    FOREIGN KEY (`article_path`)
    REFERENCES `newspaper_publisher`.`article` (`path`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `journalist_author`
    FOREIGN KEY (`journalist_email`)
    REFERENCES `newspaper_publisher`.`journalist` (`email`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `newspaper_publisher`.`telephone_numbers`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `newspaper_publisher`.`telephone_numbers` (
  `administrative_email` VARCHAR(63) NOT NULL,
  `telephone_number` VARCHAR(63) NOT NULL,
  PRIMARY KEY (`administrative_email`, `telephone_number`),
  CONSTRAINT `telephone_numbers`
    FOREIGN KEY (`administrative_email`)
    REFERENCES `newspaper_publisher`.`administrative` (`email`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `newspaper_publisher`.`works`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `newspaper_publisher`.`works` (
  `newspaper_name` VARCHAR(63) NOT NULL,
  `employee_email` VARCHAR(63) NOT NULL,
  PRIMARY KEY (`newspaper_name`, `employee_email`),
  INDEX `fk_newspaper_has_employee_employee1_idx` (`employee_email` ASC),
  INDEX `fk_newspaper_has_employee_newspaper1_idx` (`newspaper_name` ASC),
  CONSTRAINT `employee_works_in`
    FOREIGN KEY (`newspaper_name`)
    REFERENCES `newspaper_publisher`.`newspaper` (`name`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `newspaper_has_workers`
    FOREIGN KEY (`employee_email`)
    REFERENCES `newspaper_publisher`.`employee` (`email`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `newspaper_publisher`.`images`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `newspaper_publisher`.`images` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `article_path` VARCHAR(127) NOT NULL,
  `image` BLOB NOT NULL,
  PRIMARY KEY (`id`, `article_path`),
  CONSTRAINT `article_images`
    FOREIGN KEY (`article_path`)
    REFERENCES `newspaper_publisher`.`article` (`path`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `newspaper_publisher`.`login`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `newspaper_publisher`.`login` (
  `email` VARCHAR(63) NOT NULL,
  `password` VARCHAR(63) NOT NULL,
  `type` ENUM('journalist', 'editor_in_chief', 'administrative', 'publisher') NOT NULL,
  PRIMARY KEY (`email`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;


-- INSERT Statements


-- -----------------------------------------------------
-- Insert `newspaper_publisher`.`article`
-- -----------------------------------------------------
INSERT INTO `employee` (`email`, `firstname`, `lastname`, `salary`, `hiring_date`) VALUES ('john@example.org', 'John', 'Smith', 1000, '2011-01-17'); -- employee
INSERT INTO `employee` (`email`, `firstname`, `lastname`, `salary`, `hiring_date`) VALUES ('maria@example.org', 'Maria', 'Jones', 1200, '2012-02-12'); -- employee
INSERT INTO `employee` (`email`, `firstname`, `lastname`, `salary`, `hiring_date`) VALUES ('michael@example.org', 'Michael', 'Johnson', 3000, '2001-01-06'); -- owner(publisher)
INSERT INTO `employee` (`email`, `firstname`, `lastname`, `salary`, `hiring_date`) VALUES ('samantha@example.org', 'Samantha', 'Lee', 3500, '2002-01-02'); -- owner(publisher)
INSERT INTO `employee` (`email`, `firstname`, `lastname`, `salary`, `hiring_date`) VALUES ('mike@example.org', 'Mike', 'Brown', 1400, '2013-03-08'); -- administrative
INSERT INTO `employee` (`email`, `firstname`, `lastname`, `salary`, `hiring_date`) VALUES ('nicole@example.org', 'Nicole', 'Williams', 1600, '2014-04-13'); -- administrative
INSERT INTO `employee` (`email`, `firstname`, `lastname`, `salary`, `hiring_date`) VALUES ('paul@example.org', 'Paul', 'Garzia', 1800, '2017-05-17'); -- journalist
INSERT INTO `employee` (`email`, `firstname`, `lastname`, `salary`, `hiring_date`) VALUES ('emma@example.org', 'Emma', 'Lopez', 2000, '2018-06-18'); -- journalist
INSERT INTO `employee` (`email`, `firstname`, `lastname`, `salary`, `hiring_date`) VALUES ('liam@example.org', 'Liam', 'Miller', 2200, '2015-06-18'); -- editor in chief
INSERT INTO `employee` (`email`, `firstname`, `lastname`, `salary`, `hiring_date`) VALUES ('mia@example.org', 'Mia', 'Wilson', 2400, '2016-06-18'); -- editor in chief



-- -----------------------------------------------------
-- Insert `newspaper_publisher`.`administrative`
-- -----------------------------------------------------
INSERT INTO `administrative` (`email`, `city`, `street`, `street_number`, `duties`) VALUES ('mike@example.org', 'Los Angeles', 'Roberts Ridge Suite', 148, 'Secretary');
INSERT INTO `administrative` (`email`, `city`, `street`, `street_number`, `duties`) VALUES ('nicole@example.org', 'Los Angeles', 'Hills Knolls', 456, 'Logistics');


-- -----------------------------------------------------
-- Insert `newspaper_publisher`.`category`
-- -----------------------------------------------------
INSERT INTO `category` (`name`, `description`, `parent_id`) VALUES ('Politics', 'All about politics', NULL);
INSERT INTO `category` (`name`, `description`, `parent_id`) VALUES ('Economics', 'All about economics', NULL);
INSERT INTO `category` (`name`, `description`, `parent_id`) VALUES ('Social', 'All about society', NULL);
INSERT INTO `category` (`name`, `description`, `parent_id`) VALUES ('Cosmics', 'All about cosmos', NULL);
INSERT INTO `category` (`name`, `description`, `parent_id`) VALUES ('Sports', 'All about sports', NULL);
INSERT INTO `category` (`name`, `description`, `parent_id`) VALUES ('National Politics', 'All about national politics', 1);
INSERT INTO `category` (`name`, `description`, `parent_id`) VALUES ('International Politics', 'All about international politics', 1);
INSERT INTO `category` (`name`, `description`, `parent_id`) VALUES ('Football', 'All about football', 5);
INSERT INTO `category` (`name`, `description`, `parent_id`) VALUES ('Basketball', 'All about basketball', 5);


-- -----------------------------------------------------
-- Insert `newspaper_publisher`.`journalist`
-- -----------------------------------------------------
INSERT INTO `journalist` (`email`, `experience`, `resume`) VALUES ('paul@example.org', 34, 'Published artciles in major newspapers'); -- journalist
INSERT INTO `journalist` (`email`, `experience`, `resume`) VALUES ('emma@example.org', 42, 'MSc in journalism'); -- journalist
INSERT INTO `journalist` (`email`, `experience`, `resume`) VALUES ('liam@example.org', 52, 'Senior position in major newspapers'); -- editor in chief
INSERT INTO `journalist` (`email`, `experience`, `resume`) VALUES ('mia@example.org', 56, 'Managed a team of journalists'); -- editor in chief



-- -----------------------------------------------------
-- Insert `newspaper_publisher`.`newspaper`
-- -----------------------------------------------------
INSERT INTO `newspaper` (`name`, `publishing_frequency`, `owner_email`, `editor_in_chief_email`) VALUES ('News Time', 'Weekly', 'michael@example.org', 'liam@example.org');
INSERT INTO `newspaper` (`name`, `publishing_frequency`, `owner_email`, `editor_in_chief_email`) VALUES ('The Informer', 'Monthly', 'samantha@example.org', 'mia@example.org');


-- -----------------------------------------------------
-- Insert `newspaper_publisher`.`paper`
-- -----------------------------------------------------
INSERT INTO `paper` (`id`, `number_of_pages`, `publishing_date`, `copies`, `copies_sold`, `copies_returned`, `newspaper_name`) VALUES ('paper321', 100, '2020-01-14', 1000, 900, 100, 'News Time');
INSERT INTO `paper` (`id`, `number_of_pages`, `publishing_date`, `copies`, `copies_sold`, `copies_returned`, `newspaper_name`) VALUES ('paper322', 50, '2020-01-19', 500, 300, 200, 'News Time');
INSERT INTO `paper` (`id`, `number_of_pages`, `publishing_date`, `copies`, `copies_sold`, `copies_returned`, `newspaper_name`) VALUES ('paper455', 200, '2020-02-23', 300, 100, 200, 'The Informer');
INSERT INTO `paper` (`id`, `number_of_pages`, `publishing_date`, `copies`, `copies_sold`, `copies_returned`, `newspaper_name`) VALUES ('paper456', 300, '2020-02-24', 800, 500, 300, 'The Informer');


-- -----------------------------------------------------
-- Insert `newspaper_publisher`.`article`
-- -----------------------------------------------------
INSERT INTO `article` (`path`, `title`, `summary`, `number_of_pages`, `approval_date`, `status`, `comments`, `start_page`, `paper_id`, `paper_newspaper_name`, `category_id`) VALUES ('/newspaper/paper/articles/oscars.doc', 'Oscars Last Night', 'Last night the oscars took place in LA', 30, NULL, 'to_be_revised', 'Correct some mistakes', NULL, NULL, NULL, 3);
INSERT INTO `article` (`path`, `title`, `summary`, `number_of_pages`, `approval_date`, `status`, `comments`, `start_page`, `paper_id`, `paper_newspaper_name`, `category_id`) VALUES ('/newspaperpaper/articles/crash.doc', 'Unexpected Crash', 'An unexpected crash happened', 20, '2020-02-04', 'accepted', NULL, 1, 'paper321', 'News Time', 3);
INSERT INTO `article` (`path`, `title`, `summary`, `number_of_pages`, `approval_date`, `status`, `comments`, `start_page`, `paper_id`, `paper_newspaper_name`, `category_id`) VALUES ('/newspaper/paper/articles/retired.doc', 'Minister Retired', 'A minister retired', 10, '2020-02-05', 'accepted', NULL, 1, 'paper322', 'News Time', 1);
INSERT INTO `article` (`path`, `title`, `summary`, `number_of_pages`, `approval_date`, `status`, `comments`, `start_page`, `paper_id`, `paper_newspaper_name`, `category_id`) VALUES ('/newspaperpaper/articles/brexit.doc', 'Brexit is real', 'UK leaves EU', 20, NULL, 'rejected', NULL, NULL, NULL, NULL, 1);
INSERT INTO `article` (`path`, `title`, `summary`, `number_of_pages`, `approval_date`, `status`, `comments`, `start_page`, `paper_id`, `paper_newspaper_name`, `category_id`) VALUES ('/newspaper/paper/articles/funny.doc', 'Funny moments', 'Top funny moments', 50, '2020-02-02', 'accepted', NULL, 1, 'paper455', 'The Informer', 3);
INSERT INTO `article` (`path`, `title`, `summary`, `number_of_pages`, `approval_date`, `status`, `comments`, `start_page`, `paper_id`, `paper_newspaper_name`, `category_id`) VALUES ('/newspaper/paper/articles/growth.doc', 'Economical Growth', 'Economical growth is apparent', 30, '2020-02-03', 'accepted', NULL, 52, 'paper455', 'The Informer', 2);
INSERT INTO `article` (`path`, `title`, `summary`, `number_of_pages`, `approval_date`, `status`, `comments`, `start_page`, `paper_id`, `paper_newspaper_name`, `category_id`) VALUES ('/newspaper/paper/articles/death.doc', 'Sudden Death', 'Unexpected death', 30, '2020-02-04', 'accepted', NULL, 1, 'paper456', 'The Informer', 3);
INSERT INTO `article` (`path`, `title`, `summary`, `number_of_pages`, `approval_date`, `status`, `comments`, `start_page`, `paper_id`, `paper_newspaper_name`, `category_id`) VALUES ('/newspaper/paper/articles/breach.doc', 'Security Breach', 'Company Compromised', 60, '2020-02-04', 'accepted', NULL, 32, 'paper456', 'The Informer', 3);


-- -----------------------------------------------------
-- Insert `newspaper_publisher`.`keywords`
-- -----------------------------------------------------
INSERT INTO `keywords` (`article_path`, `keyword`) VALUES ('/newspaper/paper/articles/oscars.doc', 'oscars');
INSERT INTO `keywords` (`article_path`, `keyword`) VALUES ('/newspaper/paper/articles/oscars.doc', 'awards');
INSERT INTO `keywords` (`article_path`, `keyword`) VALUES ('/newspaperpaper/articles/crash.doc', 'crash');
INSERT INTO `keywords` (`article_path`, `keyword`) VALUES ('/newspaperpaper/articles/crash.doc', 'fatal');
INSERT INTO `keywords` (`article_path`, `keyword`) VALUES ('/newspaper/paper/articles/retired.doc', 'retired');
INSERT INTO `keywords` (`article_path`, `keyword`) VALUES ('/newspaper/paper/articles/retired.doc', 'minister');
INSERT INTO `keywords` (`article_path`, `keyword`) VALUES ('/newspaperpaper/articles/brexit.doc', 'brexit');
INSERT INTO `keywords` (`article_path`, `keyword`) VALUES ('/newspaperpaper/articles/brexit.doc', 'europe');
INSERT INTO `keywords` (`article_path`, `keyword`) VALUES ('/newspaper/paper/articles/funny.doc', 'funny');
INSERT INTO `keywords` (`article_path`, `keyword`) VALUES ('/newspaper/paper/articles/funny.doc', 'moments');
INSERT INTO `keywords` (`article_path`, `keyword`) VALUES ('/newspaper/paper/articles/growth.doc', 'growth');
INSERT INTO `keywords` (`article_path`, `keyword`) VALUES ('/newspaper/paper/articles/growth.doc', 'economic');
INSERT INTO `keywords` (`article_path`, `keyword`) VALUES ('/newspaper/paper/articles/death.doc', 'death');
INSERT INTO `keywords` (`article_path`, `keyword`) VALUES ('/newspaper/paper/articles/death.doc', 'sudden');
INSERT INTO `keywords` (`article_path`, `keyword`) VALUES ('/newspaper/paper/articles/breach.doc', 'breach');
INSERT INTO `keywords` (`article_path`, `keyword`) VALUES ('/newspaper/paper/articles/breach.doc', 'security');


-- -----------------------------------------------------
-- Insert `newspaper_publisher`.`submits`
-- -----------------------------------------------------
INSERT INTO `submits` (`journalist_email`, `article_path`, `submission_date`) VALUES ('paul@example.org', '/newspaper/paper/articles/oscars.doc', '2020-01-03');
INSERT INTO `submits` (`journalist_email`, `article_path`, `submission_date`) VALUES ('emma@example.org', '/newspaper/paper/articles/oscars.doc', '2020-01-03');
INSERT INTO `submits` (`journalist_email`, `article_path`, `submission_date`) VALUES ('liam@example.org', '/newspaperpaper/articles/crash.doc', '2020-01-04');
INSERT INTO `submits` (`journalist_email`, `article_path`, `submission_date`) VALUES ('paul@example.org', '/newspaperpaper/articles/crash.doc', '2020-01-04');
INSERT INTO `submits` (`journalist_email`, `article_path`, `submission_date`) VALUES ('mia@example.org', '/newspaper/paper/articles/retired.doc', '2020-01-05');
INSERT INTO `submits` (`journalist_email`, `article_path`, `submission_date`) VALUES ('emma@example.org', '/newspaper/paper/articles/retired.doc', '2020-01-05');
INSERT INTO `submits` (`journalist_email`, `article_path`, `submission_date`) VALUES ('paul@example.org', '/newspaperpaper/articles/brexit.doc', '2020-01-06');
INSERT INTO `submits` (`journalist_email`, `article_path`, `submission_date`) VALUES ('emma@example.org', '/newspaperpaper/articles/brexit.doc', '2020-01-06');
INSERT INTO `submits` (`journalist_email`, `article_path`, `submission_date`) VALUES ('liam@example.org', '/newspaper/paper/articles/funny.doc', '2020-01-06');
INSERT INTO `submits` (`journalist_email`, `article_path`, `submission_date`) VALUES ('paul@example.org', '/newspaper/paper/articles/funny.doc', '2020-01-06');
INSERT INTO `submits` (`journalist_email`, `article_path`, `submission_date`) VALUES ('paul@example.org', '/newspaper/paper/articles/growth.doc', '2020-01-06');
INSERT INTO `submits` (`journalist_email`, `article_path`, `submission_date`) VALUES ('emma@example.org', '/newspaper/paper/articles/growth.doc', '2020-01-06');
INSERT INTO `submits` (`journalist_email`, `article_path`, `submission_date`) VALUES ('paul@example.org', '/newspaper/paper/articles/death.doc', '2020-01-07');
INSERT INTO `submits` (`journalist_email`, `article_path`, `submission_date`) VALUES ('emma@example.org', '/newspaper/paper/articles/death.doc', '2020-01-07');
INSERT INTO `submits` (`journalist_email`, `article_path`, `submission_date`) VALUES ('paul@example.org', '/newspaper/paper/articles/breach.doc', '2020-01-08');
INSERT INTO `submits` (`journalist_email`, `article_path`, `submission_date`) VALUES ('emma@example.org', '/newspaper/paper/articles/breach.doc', '2020-01-08');


-- -----------------------------------------------------
-- Insert `newspaper_publisher`.`telephone_numbers`
-- -----------------------------------------------------
INSERT INTO `telephone_numbers` (`administrative_email`, `telephone_number`) VALUES ('mike@example.org', '+31 6945854563');
INSERT INTO `telephone_numbers` (`administrative_email`, `telephone_number`) VALUES ('mike@example.org', '+31 6945888563');
INSERT INTO `telephone_numbers` (`administrative_email`, `telephone_number`) VALUES ('nicole@example.org', '+31 6933854563');
INSERT INTO `telephone_numbers` (`administrative_email`, `telephone_number`) VALUES ('nicole@example.org', '+31 6977888563');


-- -----------------------------------------------------
-- Insert `newspaper_publisher`.`works`
-- -----------------------------------------------------
INSERT INTO `works` (`newspaper_name`, `employee_email`) VALUES ('News Time', 'john@example.org');
INSERT INTO `works` (`newspaper_name`, `employee_email`) VALUES ('News Time', 'michael@example.org');
INSERT INTO `works` (`newspaper_name`, `employee_email`) VALUES ('News Time', 'mike@example.org');
INSERT INTO `works` (`newspaper_name`, `employee_email`) VALUES ('News Time', 'emma@example.org');
INSERT INTO `works` (`newspaper_name`, `employee_email`) VALUES ('News Time', 'liam@example.org');
INSERT INTO `works` (`newspaper_name`, `employee_email`) VALUES ('The Informer', 'maria@example.org');
INSERT INTO `works` (`newspaper_name`, `employee_email`) VALUES ('The Informer', 'samantha@example.org');
INSERT INTO `works` (`newspaper_name`, `employee_email`) VALUES ('The Informer', 'nicole@example.org');
INSERT INTO `works` (`newspaper_name`, `employee_email`) VALUES ('The Informer', 'paul@example.org');
INSERT INTO `works` (`newspaper_name`, `employee_email`) VALUES ('The Informer', 'mia@example.org');


-- -----------------------------------------------------
-- Insert `newspaper_publisher`.`images`
-- -----------------------------------------------------
INSERT INTO `images` (`article_path`, `image`) VALUES ('/newspaperpaper/articles/crash.doc', 'BlobStreamData111');
INSERT INTO `images` (`article_path`, `image`) VALUES ('/newspaper/paper/articles/breach.doc', 'BlobStreamData222');


-- -----------------------------------------------------
-- Insert `newspaper_publisher`.`login`
-- -----------------------------------------------------
INSERT INTO `login` (`email`, `password`, `type`) VALUES ('paul@example.org', 'test', 'journalist');
INSERT INTO `login` (`email`, `password`, `type`) VALUES ('emma@example.org', 'test', 'journalist');
INSERT INTO `login` (`email`, `password`, `type`) VALUES ('liam@example.org', 'test', 'editor_in_chief');
INSERT INTO `login` (`email`, `password`, `type`) VALUES ('mia@example.org', 'test', 'editor_in_chief');
INSERT INTO `login` (`email`, `password`, `type`) VALUES ('mike@example.org', 'test', 'administrative');
INSERT INTO `login` (`email`, `password`, `type`) VALUES ('nicole@example.org', 'test', 'administrative');
INSERT INTO `login` (`email`, `password`, `type`) VALUES ('michael@example.org', 'test', 'publisher');
INSERT INTO `login` (`email`, `password`, `type`) VALUES ('samantha@example.org', 'test', 'publisher');
