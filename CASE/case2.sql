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
		CONCAT('$ ', FORMAT((worldwide_gross_income - budget_value), 2 , 'de_DE')) AS lucratividade
	FROM (SELECT 
				*,
				ROW_NUMBER() OVER (ORDER BY (worldwide_gross_income - budget_value) DESC) AS row_num
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
    t10m.lucratividade AS LUCRO,
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

SELECT -- OS NOMES DOS FILMES TOP 10 DE CADA ANO (ULTIMOS 10 ANOS)
    'Avaliação da Crítica' AS '#',
    MAX(CASE WHEN row_num = 1 THEN original_title ELSE NULL END) AS Top1,
    MAX(CASE WHEN row_num = 1 THEN CONCAT('$', FORMAT(budget_value, 2 , 'de_DE')) END) AS Orcamento,
    MAX(CASE WHEN row_num = 2 THEN original_title ELSE NULL END) AS Top2,
	MAX(CASE WHEN row_num = 2 THEN CONCAT('$', FORMAT(budget_value, 2 , 'de_DE')) END) AS Orcamento,
    MAX(CASE WHEN row_num = 3 THEN original_title ELSE NULL END) AS Top3,
	MAX(CASE WHEN row_num = 3 THEN CONCAT('$', FORMAT(budget_value, 2 , 'de_DE')) END) AS Orcamento,
    MAX(CASE WHEN row_num = 4 THEN original_title ELSE NULL END) AS Top4,
	MAX(CASE WHEN row_num = 4 THEN CONCAT('$', FORMAT(budget_value, 2 , 'de_DE')) END) AS Orcamento,
    MAX(CASE WHEN row_num = 5 THEN original_title ELSE NULL END) AS Top5,
	MAX(CASE WHEN row_num = 5 THEN CONCAT('$', FORMAT(budget_value, 2 , 'de_DE')) END) AS Orcamento,
    MAX(CASE WHEN row_num = 6 THEN original_title ELSE NULL END) AS Top6,
	MAX(CASE WHEN row_num = 6 THEN CONCAT('$', FORMAT(budget_value, 2 , 'de_DE')) END) AS Orcamento,
    MAX(CASE WHEN row_num = 7 THEN original_title ELSE NULL END) AS Top7,
	MAX(CASE WHEN row_num = 7 THEN CONCAT('$', FORMAT(budget_value, 2 , 'de_DE')) END) AS Orcamento,
    MAX(CASE WHEN row_num = 8 THEN original_title ELSE NULL END) AS Top8,
	MAX(CASE WHEN row_num = 8 THEN CONCAT('$', FORMAT(budget_value, 2 , 'de_DE')) END) AS Orcamento,
    MAX(CASE WHEN row_num = 9 THEN original_title ELSE NULL END) AS Top9,
	MAX(CASE WHEN row_num = 9 THEN CONCAT('$', FORMAT(budget_value, 2 , 'de_DE')) END) AS Orcamento,
    MAX(CASE WHEN row_num = 10 THEN original_title ELSE NULL END) AS Top10,
	MAX(CASE WHEN row_num = 10 THEN CONCAT('$', FORMAT(budget_value, 2 , 'de_DE')) END) AS Orcamento
FROM (SELECT
		  *,
		  ROW_NUMBER() OVER (ORDER BY reviews_from_critics DESC) AS row_num
	  FROM CaseSQL_movies_values
      WHERE budget_value != '') AS av_critics
UNION ALL
	SELECT -- OS NOMES DOS FILMES TOP 10 DE CADA ANO (ULTIMOS 10 ANOS)
		'Avaliação dos Usuários' AS '#',
		MAX(CASE WHEN row_num = 1 THEN original_title ELSE NULL END) AS Top1,
		MAX(CASE WHEN row_num = 1 THEN CONCAT('$', FORMAT(budget_value, 2 , 'de_DE')) END) AS Orcamento,
		MAX(CASE WHEN row_num = 2 THEN original_title ELSE NULL END) AS Top2,
		MAX(CASE WHEN row_num = 2 THEN CONCAT('$', FORMAT(budget_value, 2 , 'de_DE')) END) AS Orcamento,
		MAX(CASE WHEN row_num = 3 THEN original_title ELSE NULL END) AS Top3,
		MAX(CASE WHEN row_num = 3 THEN CONCAT('$', FORMAT(budget_value, 2 , 'de_DE')) END) AS Orcamento,
		MAX(CASE WHEN row_num = 4 THEN original_title ELSE NULL END) AS Top4,
		MAX(CASE WHEN row_num = 4 THEN CONCAT('$', FORMAT(budget_value, 2 , 'de_DE')) END) AS Orcamento,
		MAX(CASE WHEN row_num = 5 THEN original_title ELSE NULL END) AS Top5,
		MAX(CASE WHEN row_num = 5 THEN CONCAT('$', FORMAT(budget_value, 2 , 'de_DE')) END) AS Orcamento,
		MAX(CASE WHEN row_num = 6 THEN original_title ELSE NULL END) AS Top6,
		MAX(CASE WHEN row_num = 6 THEN CONCAT('$', FORMAT(budget_value, 2 , 'de_DE')) END) AS Orcamento,
		MAX(CASE WHEN row_num = 7 THEN original_title ELSE NULL END) AS Top7,
		MAX(CASE WHEN row_num = 7 THEN CONCAT('$', FORMAT(budget_value, 2 , 'de_DE')) END) AS Orcamento,
		MAX(CASE WHEN row_num = 8 THEN original_title ELSE NULL END) AS Top8,
		MAX(CASE WHEN row_num = 8 THEN CONCAT('$', FORMAT(budget_value, 2 , 'de_DE')) END) AS Orcamento,
		MAX(CASE WHEN row_num = 9 THEN original_title ELSE NULL END) AS Top9,
		MAX(CASE WHEN row_num = 9 THEN CONCAT('$', FORMAT(budget_value, 2 , 'de_DE')) END) AS Orcamento,
		MAX(CASE WHEN row_num = 10 THEN original_title ELSE NULL END) AS Top10,
		MAX(CASE WHEN row_num = 10 THEN CONCAT('$', FORMAT(budget_value, 2 , 'de_DE')) END) AS Orcamento
	FROM (SELECT
			  *,
			  ROW_NUMBER() OVER (ORDER BY reviews_from_users DESC) AS row_num
		  FROM CaseSQL_movies_values
		  WHERE budget_value != '') AS av_users;

-- EXERCÍCIO 6 ----------------------------------------------------------------------------------------------------------
/*Gerar um relatório contendo a duração média de 5 gêneros a sua escolha.*/

-- SELECT duration FROM CaseSQL_movies_values;

SELECT 
	UPPER(genre) AS GÊNERO,
	CONCAT(LPAD(FLOOR(AVG(duration) /60),2,'0') ,':', LPAD(MOD(AVG(duration) , 60),2,'0'), ' h') as DURACAO_MEDIA
FROM CaseSQL_movies_values
WHERE genre IN ('Drama', 'Comedy', 'Action', 'Animation, Adventure, Comedy', 'Comedy, Drama, Romance')
	GROUP BY genre
	ORDER BY genre;
  

-- EXERCÍCIO 7 ----------------------------------------------------------------------------------------------------------
/*Gerar um relatório sobre os 5 filmes mais lucrativos de um ator/atriz(que podemos filtrar), trazendo o nome, 
ano de exibição, e Lucro obtido. Considerar apenas valores em dólar($).*/

-- SELECT name FROM CaseSQL_names;

WITH ActorMovies AS (-- Obter filmes de um ator/atriz específico e limpar os valores de budget e income
	SELECT 
		m.imdb_title_id, 
        -- n.name,
		m.original_title, 
		m.year, 
		m.budget_value AS budget_value, 
		m.worldwide_gross_income AS income_value
	FROM CaseSQL_movies_values m
	INNER JOIN CaseSQL_title_principals p 
		ON m.imdb_title_id = p.imdb_title_id
	INNER JOIN CaseSQL_names n 
		ON p.imdb_name_id = n.imdb_name_id
	WHERE n.name = 'Anne Hathaway' -- ----------------------------> SUBSTITUA AQUI PELO NOME DO AUTOR/ATRZ DESEJADO
		AND m.symbol_budge = '$'
		AND m.symbol_worldwide_gross_income = '$'
),
	MovieProfits AS ( -- CTE para calcular o lucro de cada filme
		SELECT 
			-- name,
			row_num,
			imdb_title_id, 
			original_title, 
			year, 
			income_value - budget_value AS profit
		FROM (SELECT 
				  *,
				  ROW_NUMBER() OVER (ORDER BY (income_value - budget_value) DESC) AS row_num
			  FROM ActorMovies) AS AM
)
	SELECT  -- Selecionar os 5 filmes mais lucrativos
		-- name,
		row_num AS TOP,
		original_title AS FILME, 
		year AS ANO_EXIBICAO, 
		CONCAT('$ ', FORMAT(profit, 2 , 'de_DE')) AS LUCRO
	FROM MovieProfits
	WHERE row_num <= 5;


-- EXERCÍCIO 8 ----------------------------------------------------------------------------------------------------------
/*Baseado em um filme que iremos selecionar, trazer um relatório contendo quais os atores/atrizes participantes, 
e pra cada ator trazer um campo com a média de avaliação da crítica dos últimos 5 filmes em que esse 
ator/atriz participou.*/


WITH SelectedMovieActors AS ( -- filtro da escolha do filme pelo ano, mas precisa do ano, pois existem varios filmes com o mesmo nome.
	SELECT 
		p.imdb_name_id, 
		n.name,
        REPLACE(REPLACE(REPLACE(p.characters, '[',''), '"', ''), ']', '') AS characters
	FROM CaseSQL_title_principals p
	LEFT JOIN CaseSQL_names n 
		ON p.imdb_name_id = n.imdb_name_id
	LEFT JOIN CaseSQL_movies_values mv 
		ON p.imdb_title_id = mv.imdb_title_id
	WHERE mv.original_title = 'Sherlock Holmes' -- ----------------------------> SUBSTITUA AQUI PELO NOME DO FILME DESEJADO
		AND mv.year = '2009' -- ------> SUBSTITUA AQUI PELO ANO DO FILME
),
	ActorLastFiveMovies AS ( -- filtrar os ultimos 5 filmes
		SELECT 
			p.imdb_name_id,
			mv.imdb_title_id,
			mv.original_title,
			mv.year,
			mv.reviews_from_critics,
			ROW_NUMBER() OVER (PARTITION BY p.imdb_name_id ORDER BY mv.year DESC) AS row_num
		FROM CaseSQL_title_principals p
		INNER JOIN CaseSQL_movies_values mv 
			ON p.imdb_title_id = mv.imdb_title_id
		WHERE p.imdb_name_id IN (SELECT 
									 imdb_name_id 
								 FROM SelectedMovieActors)
	),
	ActorMoviesReviews AS (
		SELECT
			imdb_name_id,
			reviews_from_critics
	FROM ActorLastFiveMovies
	WHERE row_num <= 5
)
	SELECT 
		a.name AS ATOR_ATRIZ, 
		REPLACE(characters, ',', ', ') AS PERSONAGEM,
		ROUND(AVG(ar.reviews_from_critics),2) AS MEDIA_AV_CRITICA
	FROM SelectedMovieActors a
	INNER JOIN ActorMoviesReviews ar 
		ON a.imdb_name_id = ar.imdb_name_id
	GROUP BY a.name
	ORDER BY MEDIA_AV_CRITICA DESC;


-- EXERCÍCIO 9 ----------------------------------------------------------------------------------------------------------
/*Gerar mais duas análises a sua escolha, baseado nessas tabelas (em uma delas deve incluir a análise exploratória 
de dois campos, um quantitativo e um qualitativo, respectivamente).*/

/*OBJETIVO:
Gerar um relatório que lista os filmes de um diretor específico, juntamente com seu gênero, duração, avaliação da critica e usuarios e se cada filme 
foi lucrativo ou não. Ele fornece uma visão geral da lucratividade dos filmes desse diretor.*/

WITH DirectorMovies AS (     -- Selecionar todos os filmes do diretor escolhido
    SELECT 
        original_title,
        genre,
        year,
        duration,
        metascore,
        avg_vote,
        budget_value,
        worldwide_gross_income,
        (worldwide_gross_income - budget_value) AS profitability
    FROM CaseSQL_movies_values
    WHERE director = 'Tim Burton' -- ----------------------------> SUBSTITUA AQUI PELO NOME DO DIRETOR DESEJADO  / James Cameron  / Anthony Russo, Joe Russo  / Tim Burton
        AND worldwide_gross_income != ''
        AND budget_value != ''
)
SELECT -- Seleção final dos dados formatados
    original_title AS FILME,
    year AS LANCAMENTO,
    genre AS GENERO,
	CONCAT(LPAD(FLOOR(duration /60),2,'0') ,':', LPAD(MOD(duration, 60),2,'0'), ' h') AS DURACAO,
    metascore AS AV_CRITICA,
	avg_vote AS AV_USUARIO,
    CONCAT('$ ', FORMAT(profitability, 2, 'de_DE')) AS LUCRATIVIDADE,
    CASE 
        WHEN profitability > 0 THEN 'Lucro'
        ELSE 'Prejuízo'
    END AS STATUS
FROM DirectorMovies
ORDER BY profitability DESC;


-- --------------------------------------------------------------------------------------------------------------------------------------------
/*Objetivo:
Explorar como diferentes gêneros de filmes são avaliados por usuários e críticos, para entender se há gêneros que tendem a ser mais apreciados por 
um grupo em comparação com o outro.*/

WITH GenreReviews AS ( -- Análise da influência dos gêneros nas avaliações dos críticos e usuários
    SELECT  -- Selecionar gêneros e avaliações dos críticos e usuários
        genre,
        metascore/10 AS critics_review,
        avg_vote AS users_review
    FROM CaseSQL_movies_values
    WHERE genre != ''
        AND metascore != ''
        AND avg_vote != ''
),
CriticsGenreAvg AS ( -- Calcular as médias das avaliações dos críticos para cada gênero
    SELECT 
        genre,
        ROUND(AVG(critics_review),2) AS avg_critics_review
    FROM GenreReviews
    GROUP BY genre
),
UsersGenreAvg AS (  -- Calcular as médias das avaliações dos usuários para cada gênero
    SELECT 
        genre,
        ROUND(AVG(users_review), 2) AS avg_users_review
    FROM GenreReviews
    GROUP BY genre
)
SELECT -- Combinar as médias das avaliações dos críticos e dos usuários para cada gênero
    c.genre AS GENERO,
    c.avg_critics_review AS MEDIA_AVALIACOES_CRITICOS,
    u.avg_users_review AS MEDIA_AVALIACOES_USUARIOS,
    ROUND(c.avg_critics_review - u.avg_users_review, 2) AS DIFERENCA_AVALIACOES,
    CASE 
		WHEN ROUND(c.avg_critics_review - u.avg_users_review, 2) > 0 THEN 'Aval. Crítica positiva'
        WHEN ROUND(c.avg_critics_review - u.avg_users_review, 2) < 0 THEN 'Aval. Usuário positiva'
        ELSE 'EMPATE'
	END status
FROM CriticsGenreAvg c
INNER JOIN UsersGenreAvg u
    ON c.genre = u.genre
ORDER BY DIFERENCA_AVALIACOES ASC;

-- ----------------------------------------------------------------------------------------------------------------------------------------



