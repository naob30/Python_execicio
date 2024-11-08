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
    avg_vote,
    votes,
    metascore,
    reviews_from_users,     
    reviews_from_critics, 
    CAST(SUBSTRING_INDEX(usa_gross_income, ' ', -1) AS SIGNED) AS usa_gross_income_value,
    SUBSTRING_INDEX(usa_gross_income, ' ', 1) AS symbol_usa_gross_income,
    CAST(SUBSTRING_INDEX(worldwide_gross_income, ' ', -1) AS SIGNED) AS worldwide_gross_income,
    SUBSTRING_INDEX(worldwide_gross_income, ' ', 1) AS symbol_worldwide_gross_income,
    CAST(SUBSTRING_INDEX(budget, ' ', -1) AS SIGNED) AS budget_value,
    SUBSTRING_INDEX(budget, ' ', 1) AS symbol_budge
FROM 
    CaseSQL_movies;
    
-- select * from CaseSQL_movies_values;
-- DESC CaseSQL_movies_values;

-- ----------------------------------------------------------------------------------------------------------------------
-- VIEW para deixar apenas os últimos 10 anos ---------------------------------------------------------------------------
CREATE OR REPLACE VIEW CaseSQL_movies_minus_10 AS
	SELECT 
		*
	FROM (SELECT 
			  *,
			  ROW_NUMBER() OVER (PARTITION BY year ORDER BY metascore DESC) AS row_num
		  FROM CaseSQL_movies_values) as A
	WHERE year >= YEAR(CURDATE()) - 10
		AND row_num <= 10;

-- select * from CaseSQL_movies_minus_10;

-- ----------------------------------------------------------------------------------------------------------------------
-- Análises dos dados
-- ----------------------------------------------------------------------------------------------------------------------
-- SELECT * FROM CaseSQL_names;
-- SELECT * FROM CaseSQL_movies;
-- SELECT * FROM CaseSQL_ratings;
-- SELECT * FROM CaseSQL_title_principals;

-- EXERCÍCIO 1 ----------------------------------------------------------------------------------------------------------
/*Gerar um relatório contendo os 10 filmes mais lucrativos de todos os tempos, e identificar em qual faixa de 
idade/gênero eles foram mais bem avaliados.*/

WITH Top10Movies AS ( -- DESCOBRIR O TOP 10
	SELECT 
		A.imdb_title_id,
		A.row_num,
		A.original_title,
		CONCAT('$ ', FORMAT(A.worldwide_gross_income, 2 , 'de_DE')) AS receita_mundial
	FROM (SELECT 
				*,
				ROW_NUMBER() OVER (ORDER BY worldwide_gross_income DESC) AS row_num
		  FROM CaseSQL_movies_values) as A -- usei a view
	WHERE row_num <= 10
),
MovieRatings AS ( -- DESCOBRIR QUEM DEU A MAIOR MÉDIA DE AVALIAÇÃO
	SELECT 
		B.imdb_title_id,
		GREATEST(
			B.allgenders_0age_avg_vote,
			B.allgenders_18age_avg_vote,
			B.allgenders_30age_avg_vote,
			B.allgenders_45age_avg_vote,
			B.males_allages_avg_vote,
			B.males_0age_avg_vote,
			B.males_18age_avg_vote,
			B.males_30age_avg_vote,
			B.males_45age_avg_vote,
			B.females_allages_avg_vote,
			B.females_0age_avg_vote,
			B.females_18age_avg_vote,
			B.females_30age_avg_vote,
			B.females_45age_avg_vote
		) AS max_avg_vote,
		CASE GREATEST(
				B.allgenders_0age_avg_vote,
				B.allgenders_18age_avg_vote,
				B.allgenders_30age_avg_vote,
				B.allgenders_45age_avg_vote,
				B.males_allages_avg_vote,
				B.males_0age_avg_vote,
				B.males_18age_avg_vote,
				B.males_30age_avg_vote,
				B.males_45age_avg_vote,
				B.females_allages_avg_vote,
				B.females_0age_avg_vote,
				B.females_18age_avg_vote,
				B.females_30age_avg_vote,
				B.females_45age_avg_vote
			)
			WHEN B.allgenders_0age_avg_vote THEN 'GERAL (0-17 ANOS)'
			WHEN B.allgenders_18age_avg_vote THEN 'GERAL (18-29 ANOS)'
			WHEN B.allgenders_30age_avg_vote THEN 'GERAL (30-44 ANOS)'
			WHEN B.allgenders_45age_avg_vote THEN 'GERAL (ACIMA DE 45)'
			WHEN B.males_allages_avg_vote THEN 'MASCULINO (TODAS AS IDADES)'
			WHEN B.males_0age_avg_vote THEN 'MASCULINO (0-17 ANOS)'
			WHEN B.males_18age_avg_vote THEN 'MASCULINO (18-29 ANOS)'
			WHEN B.males_30age_avg_vote THEN 'MASCULINO (30-44 ANOS)'
			WHEN B.males_45age_avg_vote THEN 'MASCULINO (ACIMA DE 45)'
			WHEN B.females_allages_avg_vote THEN 'FEMININO (TODAS AS IDADES)'
			WHEN B.females_0age_avg_vote THEN 'FEMININO (0-17 ANOS)'
			WHEN B.females_18age_avg_vote THEN 'FEMININO (18-29 ANOS)'
			WHEN B.females_30age_avg_vote THEN 'FEMININO (30-44 ANOS)'
			WHEN B.females_45age_avg_vote THEN 'FEMININO (ACIMA DE 45)'
			END AS best_demographic
	FROM CaseSQL_ratings B
		INNER JOIN Top10Movies t10m ON B.imdb_title_id = t10m.imdb_title_id
)
SELECT  -- RESULTADOS FINAIS
	t10m.row_num AS TOP,
    UPPER(t10m.original_title) AS FILME,
    t10m.receita_mundial AS RECEITA_MUNDIAL,
    mr.max_avg_vote AS AVALIACAO_MEDIA,
    mr.best_demographic AS GRUPO_AVALIADOR
FROM Top10Movies t10m
INNER JOIN MovieRatings mr 
	ON t10m.imdb_title_id = mr.imdb_title_id
ORDER BY row_num;
    
    
    
-- EXERCÍCIO 2 ----------------------------------------------------------------------------------------------------------
/*Quais os gêneros que mais aparecem entre os Top 10 filmes mais bem avaliados de cada ano, nos últimos 10 anos.*/

SELECT -- OS NOMES DOS FILMES TOP 10 DE CADA ANO (ULTIMOS 10 ANOS)
    year,
    MAX(CASE WHEN row_num = 1 THEN original_title ELSE NULL END) AS Top1,
    MAX(CASE WHEN row_num = 2 THEN original_title ELSE NULL END) AS Top2,
    MAX(CASE WHEN row_num = 3 THEN original_title ELSE NULL END) AS Top3,
    MAX(CASE WHEN row_num = 4 THEN original_title ELSE NULL END) AS Top4,
    MAX(CASE WHEN row_num = 5 THEN original_title ELSE NULL END) AS Top5,
    MAX(CASE WHEN row_num = 6 THEN original_title ELSE NULL END) AS Top6,
    MAX(CASE WHEN row_num = 7 THEN original_title ELSE NULL END) AS Top7,
    MAX(CASE WHEN row_num = 8 THEN original_title ELSE NULL END) AS Top8,
    MAX(CASE WHEN row_num = 9 THEN original_title ELSE NULL END) AS Top9,
    MAX(CASE WHEN row_num = 10 THEN original_title ELSE NULL END) AS Top10
FROM CaseSQL_movies_minus_10
	GROUP BY year
	ORDER BY year;


-- Cria uma visualização com os Top 10 filmes mais bem avaliados de cada ano nos últimos 10 anos
CREATE OR REPLACE VIEW Top10MoviesPerYear AS
	SELECT 
		row_num,
		year,
		genre,
		original_title,
		metascore
		-- ROW_NUMBER() OVER (PARTITION BY m.year ORDER BY metascore DESC) AS row_num
	FROM CaseSQL_movies_minus_10;
-- Seleciona os gêneros dos Top 10 filmes mais bem avaliados de cada ano e conta as ocorrências de cada gênero
SELECT 
    genre,
    COUNT(*) AS count
FROM Top10MoviesPerYear
GROUP BY 
    genre
ORDER BY 
    count DESC;


-- EXERCÍCIO 3 ----------------------------------------------------------------------------------------------------------
/*Quais os 50 filmes com menor lucratividade ou que deram prejuízo, nos últimos 30 anos. 
Considerar apenas valores em dólar ($).*/


select * from CaseSQL_movies_values;

SELECT 
	row_num as TOP,
	year AS ano_lancamento,
	original_title AS filme,
    CONCAT('$ ', FORMAT(budget_value, 2 , 'de_DE')) AS orcamento,
	CONCAT('$ ', FORMAT(worldwide_gross_income, 2 , 'de_DE')) AS receita_mundial,
	CONCAT('$ ', FORMAT((worldwide_gross_income - budget_value), 2 , 'de_DE')) AS lucro_prejuizo,
    CASE
		WHEN (budget_value - worldwide_gross_income) > 0 THEN 'PREJUÍZO'
		WHEN (budget_value - worldwide_gross_income) < 0 THEN 'LUCRO'
		ELSE 'EMPATE'
    END AS status
FROM (SELECT 
			  *,
			  ROW_NUMBER() OVER (ORDER BY (worldwide_gross_income - budget_value) ASC) AS row_num
		  FROM CaseSQL_movies_values
          WHERE symbol_worldwide_gross_income LIKE '%$%'
			AND symbol_budge LIKE '%$%') as A
WHERE year >= YEAR(CURDATE()) - 30
	AND row_num <= 50;

-- EXERCÍCIO 4 ----------------------------------------------------------------------------------------------------------
/*Selecionar os top 10 filmes baseados nas avaliações dos usuários, para cada ano, nos últimos 20 anos.*/

CREATE OR REPLACE VIEW CaseSQL_movies_minus_20 AS
	SELECT 
		*
	FROM (SELECT 
			  *,
			  ROW_NUMBER() OVER (PARTITION BY year ORDER BY reviews_from_users DESC) AS row_num
		  FROM CaseSQL_movies_values) as A
	WHERE year >= YEAR(CURDATE()) - 20
		AND row_num <= 10;


SELECT -- OS NOMES DOS FILMES TOP 10 DE CADA ANO (ULTIMOS 20 ANOS)
    year,
    MAX(CASE WHEN row_num = 1 THEN original_title ELSE NULL END) AS Top1,
    MAX(CASE WHEN row_num = 2 THEN original_title ELSE NULL END) AS Top2,
    MAX(CASE WHEN row_num = 3 THEN original_title ELSE NULL END) AS Top3,
    MAX(CASE WHEN row_num = 4 THEN original_title ELSE NULL END) AS Top4,
    MAX(CASE WHEN row_num = 5 THEN original_title ELSE NULL END) AS Top5,
    MAX(CASE WHEN row_num = 6 THEN original_title ELSE NULL END) AS Top6,
    MAX(CASE WHEN row_num = 7 THEN original_title ELSE NULL END) AS Top7,
    MAX(CASE WHEN row_num = 8 THEN original_title ELSE NULL END) AS Top8,
    MAX(CASE WHEN row_num = 9 THEN original_title ELSE NULL END) AS Top9,
    MAX(CASE WHEN row_num = 10 THEN original_title ELSE NULL END) AS Top10
FROM CaseSQL_movies_minus_20
	GROUP BY year
	ORDER BY year;

-- EXERCÍCIO 5 ----------------------------------------------------------------------------------------------------------
/*Gerar um relatório com os top 10 filmes mais bem avaliados pela crítica e os top 10 pela avaliação de usuário, 
contendo também o budget dos filmes.*/



-- EXERCÍCIO 6 ----------------------------------------------------------------------------------------------------------
/*Gerar um relatório contendo a duração média de 5 gêneros a sua escolha.*/


SELECT 
  genre,
  AVG(CAST(duration AS UNSIGNED)) AS average_duration
FROM 
  CaseSQL_movies
WHERE 
  genre IN ('Drama', 'Comedy', 'Action', 'Horror', 'Science Fiction')
GROUP BY 
  genre;
  

-- EXERCÍCIO 7 ----------------------------------------------------------------------------------------------------------
/*Gerar um relatório sobre os 5 filmes mais lucrativos de um ator/atriz(que podemos filtrar), trazendo o nome, 
ano de exibição, e Lucro obtido. Considerar apenas valores em dólar($).*/


WITH ActorMovies AS (
	SELECT	
		M.imdb_title_id, 
		M.original_title, 
		M.year, 
		M.budget_value, 
		M.worldwide_gross_income
	FROM (SELECT 
				*,
				ROW_NUMBER() OVER (ORDER BY (worldwide_gross_income - budget_value) DESC) AS row_num
		  FROM CaseSQL_movies_values
		  WHERE M.symbol_worldwide_gross_income = '$'
		  	AND M.symbol_budge = '$') AS M
	INNER JOIN CaseSQL_title_principals P 
		ON M.imdb_title_id = P.imdb_title_id
	INNER JOIN CaseSQL_names N 
		ON P.imdb_name_id = n.imdb_name_id
	WHERE N.name = 'Robert Downey Jr.' -- SUBSTITUA AQUI PELO NOME DO ATOR/ATRIZ DESEJADO
),

    /*WITH ActorMovies AS (
		SELECT	
			M.imdb_title_id, 
			M.original_title, 
			M.year, 
			M.budget_value,
			M.worldwide_gross_income
		FROM CaseSQL_movies_values M
		INNER JOIN CaseSQL_title_principals P 
			ON M.imdb_title_id = P.imdb_title_id
		INNER JOIN CaseSQL_names N 
			ON P.imdb_name_id = N.imdb_name_id
		WHERE N.name = 'Robert Downey Jr.' -- SUBSTITUA AQUI PELO NOME DO ATOR/ATRIZ DESEJADO
),*/



-- EXERCÍCIO 8 ----------------------------------------------------------------------------------------------------------
/*Baseado em um filme que iremos selecionar, trazer um relatório contendo quais os atores/atrizes participantes, 
e pra cada ator trazer um campo com a média de avaliação da crítica dos últimos 5 filmes em que esse 
ator/atriz participou.*/


-- EXERCÍCIO 9 ----------------------------------------------------------------------------------------------------------
/*Gerar mais duas análises a sua escolha, baseado nessas tabelas (em uma delas deve incluir a análise exploratória 
de dois campos, um quantitativo e um qualitativo, respectivamente).*/

