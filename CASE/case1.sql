#########################################################################################################################
-- CASE 1
-- Version 1.0
-- Nayara de Oliveira Brabo
-- 25-05-2024
-- JumpStart - Jump Label 
#########################################################################################################################

-- -----------------------------------------------------------------------------------------------------------------------
-- Configurações das variaveis de ambiente
-- -----------------------------------------------------------------------------------------------------------------------
SET NAMES utf8mb4;
SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL';
 
DROP SCHEMA IF EXISTS CASE_JUMP_4;
CREATE SCHEMA CASE_JUMP_4;
USE CASE_JUMP_4;



-- --------------------------------------------------------------------------------------------------------------------
-- Criando as tabelas e adicionando os dados
-- --------------------------------------------------------------------------------------------------------------------

-- CRIANDO A TABELA CaseSQL_names --------------------------------
DROP TABLE IF EXISTS CaseSQL_names;
CREATE TABLE CaseSQL_names (
	imdb_name_id VARCHAR (50),
    name VARCHAR (250),
    birth_name VARCHAR(400),
    height VARCHAR(150),
    bio TEXT,
    birth_details TEXT,
    date_of_birth VARCHAR(150),
    place_of_birth VARCHAR(250),
    death_details TEXT,
    date_of_death VARCHAR(100),
    place_of_death VARCHAR(150),
    reason_of_death TEXT,
    spouses_string TEXT,
    spouses INT,
    divorces INT,
    spouses_with_children INT,
    children INT
);
 
LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/CaseSQL_names.csv"
INTO TABLE CaseSQL_names
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- SELECT * FROM CaseSQL_names;
-- SELECT COUNT(*) FROM CaseSQL_names;


-- CRIANDO A TABELA CaseSQL_movies -------------------------------

DROP TABLE IF EXISTS CaseSQL_movies;
CREATE TABLE CaseSQL_movies (
    imdb_title_id VARCHAR(50),
    title VARCHAR(250),
    original_title VARCHAR(250),
    year VARCHAR (50),
    date_published VARCHAR (50),
    genre VARCHAR(250),
    duration VARCHAR (50),
    country VARCHAR(250),
    language VARCHAR(250),
    director VARCHAR(250),
    writer VARCHAR(250),
    production_company VARCHAR(250),
    actors TEXT,
    description TEXT,
    avg_vote VARCHAR (50),
    votes VARCHAR (50),
    budget VARCHAR(100),
    usa_gross_income VARCHAR(100),
    worldwide_gross_income VARCHAR(100),
    metascore VARCHAR(100),
    reviews_from_users VARCHAR(70),
    reviews_from_critics VARCHAR(70)
);


LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/CaseSQL_movies.csv'
INTO TABLE CaseSQL_movies
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


-- CRIANDO A TABELA CaseSQL_ratings ------------------------------

DROP TABLE IF EXISTS CaseSQL_ratings;
CREATE TABLE CaseSQL_ratings (
    imdb_title_id VARCHAR(20),
    weighted_average_vote DECIMAL(10,2),
    total_votes INT,
    mean_vote DECIMAL(10,2),
    median_vote DECIMAL(10,2),
    votes_10 INT,
    votes_9 INT,
    votes_8 INT,
    votes_7 INT,
    votes_6 INT,
    votes_5 INT,
    votes_4 INT,
    votes_3 INT,
    votes_2 INT,
    votes_1 INT,
    allgenders_0age_avg_vote DECIMAL(10,2),
    allgenders_0age_votes INT,
    allgenders_18age_avg_vote DECIMAL(10,2),
    allgenders_18age_votes INT,
    allgenders_30age_avg_vote DECIMAL(10,2),
    allgenders_30age_votes INT,
    allgenders_45age_avg_vote DECIMAL(10,2),
    allgenders_45age_votes INT,
    males_allages_avg_vote DECIMAL(10,2),
    males_allages_votes INT,
    males_0age_avg_vote DECIMAL(10,2),
    males_0age_votes INT,
    males_18age_avg_vote DECIMAL(10,2),
    males_18age_votes INT,
    males_30age_avg_vote DECIMAL(10,2),
    males_30age_votes INT,
    males_45age_avg_vote DECIMAL(10,2),
    males_45age_votes INT,
    females_allages_avg_vote DECIMAL(10,2),
    females_allages_votes INT,
    females_0age_avg_vote DECIMAL(10,2),
    females_0age_votes INT,
    females_18age_avg_vote DECIMAL(10,2),
    females_18age_votes INT,
    females_30age_avg_vote DECIMAL(10,2),
    females_30age_votes INT,
    females_45age_avg_vote DECIMAL(10,2),
    females_45age_votes INT,
    top1000_voters_rating DECIMAL(10,2),
    top1000_voters_votes INT,
    us_voters_rating DECIMAL(10,2),
    us_voters_votes DECIMAL(10,2),
    non_us_voters_rating DECIMAL(10,2),
    non_us_voters_votes DECIMAL(10,2)
);


LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/CaseSQL_ratings.csv'
INTO TABLE CaseSQL_ratings
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    imdb_title_id,
    @weighted_average_vote,
    @total_votes,
    @mean_vote,
    @median_vote,
    @votes_10,
    @votes_9,
    @votes_8,
    @votes_7,
    @votes_6,
    @votes_5,
    @votes_4,
    @votes_3,
    @votes_2,
    @votes_1,
    @allgenders_0age_avg_vote,
    @allgenders_0age_votes,
    @allgenders_18age_avg_vote,
    @allgenders_18age_votes,
    @allgenders_30age_avg_vote,
    @allgenders_30age_votes,
    @allgenders_45age_avg_vote,
    @allgenders_45age_votes,
    @males_allages_avg_vote,
    @males_allages_votes,
    @males_0age_avg_vote,
    @males_0age_votes,
    @males_18age_avg_vote,
    @males_18age_votes,
    @males_30age_avg_vote,
    @males_30age_votes,
    @males_45age_avg_vote,
    @males_45age_votes,
    @females_allages_avg_vote,
    @females_allages_votes,
    @females_0age_avg_vote,
    @females_0age_votes,
    @females_18age_avg_vote,
    @females_18age_votes,
    @females_30age_avg_vote,
    @females_30age_votes,
    @females_45age_avg_vote,
    @females_45age_votes,
    @top1000_voters_rating,
    @top1000_voters_votes,
    @us_voters_rating,
    @us_voters_votes,
    @non_us_voters_rating,
    @non_us_voters_votes
)
SET
    weighted_average_vote = IFNULL(NULLIF(@weighted_average_vote, ''), 0.0),
    total_votes = IFNULL(NULLIF(@total_votes, ''), 0.0),
    mean_vote = IFNULL(NULLIF(@mean_vote, ''), 0.0),
    median_vote = IFNULL(NULLIF(@median_vote, ''), 0.0),
    votes_10 = IFNULL(NULLIF(@votes_10, ''), 0.0),
    votes_9 = IFNULL(NULLIF(@votes_9, ''), 0.0),
    votes_8 = IFNULL(NULLIF(@votes_8, ''), 0.0),
    votes_7 = IFNULL(NULLIF(@votes_7, ''), 0.0),
    votes_6 = IFNULL(NULLIF(@votes_6, ''), 0.0),
    votes_5 = IFNULL(NULLIF(@votes_5, ''), 0.0),
    votes_4 = IFNULL(NULLIF(@votes_4, ''), 0.0),
    votes_3 = IFNULL(NULLIF(@votes_3, ''), 0.0),
    votes_2 = IFNULL(NULLIF(@votes_2, ''), 0.0),
    votes_1 = IFNULL(NULLIF(@votes_1, ''), 0.0),
    allgenders_0age_avg_vote = IFNULL(NULLIF(@allgenders_0age_avg_vote, ''), 0.0),
    allgenders_0age_votes = IFNULL(NULLIF(@allgenders_0age_votes, ''), 0.0),
    allgenders_18age_avg_vote = IFNULL(NULLIF(@allgenders_18age_avg_vote, ''), 0.0),
    allgenders_18age_votes = IFNULL(NULLIF(@allgenders_18age_votes, ''), 0.0),
    allgenders_30age_avg_vote = IFNULL(NULLIF(@allgenders_30age_avg_vote, ''), 0.0),
    allgenders_30age_votes = IFNULL(NULLIF(@allgenders_30age_votes, ''), 0.0),
    allgenders_45age_avg_vote = IFNULL(NULLIF(@allgenders_45age_avg_vote, ''), 0.0),
    allgenders_45age_votes = IFNULL(NULLIF(@allgenders_45age_votes, ''), 0.0),
    males_allages_avg_vote = IFNULL(NULLIF(@males_allages_avg_vote, ''), 0.0),
    males_allages_votes = IFNULL(NULLIF(@males_allages_votes, ''), 0.0),
    males_0age_avg_vote = IFNULL(NULLIF(@males_0age_avg_vote, ''), 0.0),
    males_0age_votes = IFNULL(NULLIF(@males_0age_votes, ''), 0.0),
    males_18age_avg_vote = IFNULL(NULLIF(@males_18age_avg_vote, ''), 0.0),
    males_18age_votes = IFNULL(NULLIF(@males_18age_votes, ''), 0.0),
    males_30age_avg_vote = IFNULL(NULLIF(@males_30age_avg_vote, ''), 0.0),
    males_30age_votes = IFNULL(NULLIF(@males_30age_votes, ''), 0.0),
    males_45age_avg_vote = IFNULL(NULLIF(@males_45age_avg_vote, ''), 0.0),
    males_45age_votes = IFNULL(NULLIF(@males_45age_votes, ''), 0.0),
    females_allages_avg_vote = IFNULL(NULLIF(@females_allages_avg_vote, ''), 0.0),
    females_allages_votes = IFNULL(NULLIF(@females_allages_votes, ''), 0.0),
    females_0age_avg_vote = IFNULL(NULLIF(@females_0age_avg_vote, ''), 0.0),
    females_0age_votes = IFNULL(NULLIF(@females_0age_votes, ''), 0.0),
    females_18age_avg_vote = IFNULL(NULLIF(@females_18age_avg_vote, ''), 0.0),
    females_18age_votes = IFNULL(NULLIF(@females_18age_votes, ''), 0.0),
    females_30age_avg_vote = IFNULL(NULLIF(@females_30age_avg_vote, ''), 0.0),
    females_30age_votes = IFNULL(NULLIF(@females_30age_votes, ''), 0.0),
    females_45age_avg_vote = IFNULL(NULLIF(@females_45age_avg_vote, ''), 0.0),
    females_45age_votes = IFNULL(NULLIF(@females_45age_votes, ''), 0.0),
    top1000_voters_rating = IFNULL(NULLIF(@top1000_voters_rating, ''), 0.0),
    top1000_voters_votes = IFNULL(NULLIF(@top1000_voters_votes, ''), 0.0),
    us_voters_rating = IFNULL(NULLIF(@us_voters_rating, ''), 0.0),
    us_voters_votes = IFNULL(NULLIF(@us_voters_votes, ''), 0.0),
    non_us_voters_rating = IFNULL(NULLIF(@non_us_voters_rating, ''), 0.0),
    non_us_voters_votes = IFNULL(NULLIF(@non_us_voters_votes, ''), 0.0);
    
-- SELECT * FROM CaseSQL_ratings;
-- SELECT COUNT(*) FROM CaseSQL_ratings;


-- CRIANDO A TABELA CaseSQL_title_principals ---------------------
DROP TABLE IF EXISTS CaseSQL_title_principals;
CREATE TABLE CaseSQL_title_principals (
    imdb_title_id VARCHAR(50),
    ordering INT,
    imdb_name_id VARCHAR(50),
    category VARCHAR(50),
    job VARCHAR(100),
    characters VARCHAR(250)
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/CaseSQL_title_principals.csv'
INTO TABLE CaseSQL_title_principals
character set 'UTF8MB4'
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
ESCAPED BY ''
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(imdb_title_id, ordering, imdb_name_id, category, job, @characters)
SET characters = @characters;

-- SELECT * FROM CaseSQL_title_principals;
-- SELECT COUNT(*) FROM CaseSQL_title_principals;


