##############################################################################################################
-- CASE 1
-- Version 2.0
-- Nayara de Oliveira Brabo
-- 25-05-2024
-- JumpStart - Jump Label 
##############################################################################################################

USE CASE_JUMP_4;

-- ----------------------------------------------------------------------------------------------------------------------
-- Organização dos Dados
-- ----------------------------------------------------------------------------------------------------------------------

-- VIEW para arrumar os valores com os símbolos -------------------------------------------------------------------------
CREATE OR REPLACE VIEW CaseSQL_movies_values AS
SELECT 
	imdb_title_id,
    original_title,
    CAST(year AS FLOAT) year,
    genre,
    duration,
    director,
    avg_vote,
    metascore,
    reviews_from_users,     
    reviews_from_critics, 
    CAST(SUBSTRING_INDEX(usa_gross_income, ' ', -1) AS SIGNED) AS usa_gross_income_value,
    SUBSTRING_INDEX(usa_gross_income, ' ', 1) AS symbol_usa_gross_income,
    CAST(SUBSTRING_INDEX(worldwide_gross_income, ' ', -1) AS SIGNED) AS worldwide_gross_income,
    SUBSTRING_INDEX(worldwide_gross_income, ' ', 1) AS symbol_worldwide_gross_income,
    CAST(SUBSTRING_INDEX(budget, ' ', -1) AS SIGNED) AS budget_value,
    SUBSTRING_INDEX(budget, ' ', 1) AS symbol_budge,
    (worldwide_gross_income - budget_value) AS profit
FROM 
    CaseSQL_movies;
    
-- select * from CaseSQL_movies_values;
-- DESC CaseSQL_movies_values;