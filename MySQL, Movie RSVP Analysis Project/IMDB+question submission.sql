USE imdb;

/* Now that you have imported the data sets, let’s explore some of the tables. 
 To begin with, it is beneficial to know the shape of the tables and whether any column has null values.
 Further in this segment, you will take a look at 'movies' and 'genre' tables.*/

/*******************************************************************************************************************
-- Segment 1:
*******************************************************************************************************************/

-- Q1. Find the total number of rows in each table of the schema?
-- Type your code below:
SELECT 'director_mapping' AS tablename,
       COUNT(*)           AS no_of_rows
FROM   director_mapping
UNION
SELECT 'genre'  AS tablename,
       COUNT(*) AS no_of_rows
FROM   genre
UNION
SELECT 'movie'  AS tablename,
       COUNT(*) AS no_of_rows
FROM   movie
UNION
SELECT 'names'  AS tablename,
       COUNT(*) AS no_of_rows
FROM   names
UNION
SELECT 'ratings' AS tablename,
       COUNT(*)  AS no_of_rows
FROM   ratings
UNION
SELECT 'role_mapping' AS tablename,
       COUNT(*)       AS no_of_rows
FROM   role_mapping; 
/* Results :
	'director_mapping',	'3867'
	'genre',			'14662'
	'movie',			'7997'
	'names',			'25735'
	'ratings',			'7997'
	'role_mapping',		'15615'
*/
/* Additional checks :
checked duplication on fact_table.
Checked duplications by title.
Although title names are duplicated, movie_is is unique by title, so it is natural and considered as non-duplicated row
*/

-- Q2. Which columns in the movie table have null values?
-- Type your code below:
WITH null_summary
     AS (SELECT 'id'            AS var_name,
                SUM(id IS NULL) AS no_of_nulls
         FROM   movie
         UNION
         SELECT 'title'            AS var_name,
                SUM(title IS NULL) AS no_of_nulls
         FROM   movie
         UNION
         SELECT 'year'            AS var_name,
                SUM(year IS NULL) AS no_of_nulls
         FROM   movie
         UNION
         SELECT 'duration'            AS var_name,
                SUM(duration IS NULL) AS no_of_nulls
         FROM   movie
         UNION
         SELECT 'country'            AS var_name,
                SUM(country IS NULL) AS no_of_nulls
         FROM   movie
         UNION
         SELECT 'worlwide_gross_income'            AS var_name,
                SUM(worlwide_gross_income IS NULL) AS no_of_nulls
         FROM   movie
         UNION
         SELECT 'languages'            AS var_name,
                SUM(languages IS NULL) AS no_of_nulls
         FROM   movie
         UNION
         SELECT 'production_company'            AS var_name,
                SUM(production_company IS NULL) AS no_of_nulls
         FROM   movie)
SELECT var_name AS null_present_columns,
       no_of_nulls
FROM   null_summary
WHERE  no_of_nulls != 0; 
/* Results : 
-- these are four column with null values
	'country'
	'worlwide_gross_income'
	'languages'
	'production_company'
*/

-- Now as you can see four columns of the movie table has null values. Let's look at the at the movies released each year. 
-- Q3. Find the total number of movies released each year? How does the trend look month wise? (Output expected)
/* Output format for the first part:
+---------------+-------------------+
| Year			|	number_of_movies|
+-------------------+----------------
|	2017		|	2134			|
|	2018		|		.			|
|	2019		|		.			|
+---------------+-------------------+
Output format for the second part of the question:
+---------------+-------------------+
|	month_num	|	number_of_movies|
+---------------+----------------
|	1			|	 134			|
|	2			|	 231			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

-- Year trend
SELECT
	year,
	COUNT(id) AS number_of_movies
FROM   movie
GROUP BY year
ORDER BY year; 
/* Results :
+---------------+-------------------+
| Year			|	number_of_movies|
+-------------------+----------------
|	2017		|	3052			|
|	2018		|	2944 			|
|	2019		|	2001 			|
+---------------+-------------------+*/

-- Month trend
SELECT 
	MONTH(date_published) AS month_num,
    COUNT(id)             AS number_of_movies
FROM movie
GROUP BY month_num
ORDER BY month_num;
/* Results :
+---------------+-------------------+
|	month_num	|	number_of_movies|
+---------------+--------------------
|	1			|	 804			|
|	2			|	 640			|
|	3			|	 824			|
|	4			|	 680			|
|	5			|	 625			|
|	6			|	 580			|
|	7			|	 493			|
|	8			|	 678			|
|	9			|	 809			|
|	10			|	 801			|
|	11			|	 625			|
|	12			|	 438			|
+---------------+-------------------+ */

/*The highest number of movies is produced in the month of March.
So, now that you have understood the month-wise trend of movies, let’s take a look at the other details in the movies table. 
We know USA and India produces huge number of movies each year. Lets find the number of movies produced by USA or India for the last year.*/

-- Q4. How many movies were produced in the USA or India in the year 2019??
-- Type your code below:

SELECT 
	COUNT(*) AS total_num_movie
FROM movie
WHERE country REGEXP 'USA|India'
   AND year = 2019;
/* Results :
-- movies produced in India/USA in 2019
   1059 */

/* USA and India produced more than a thousand movies(you know the exact number!) in the year 2019.
Exploring table Genre would be fun!! 
Let’s find out the different genres in the dataset.*/

-- Q5. Find the unique list of the genres present in the data set?
-- Type your code below:
SELECT 
	genre
FROM genre
GROUP BY genre;
/* Results:
	'Drama'
	'Fantasy'
	'Thriller'
	'Comedy'
	'Horror'
	'Family'
	'Romance'
	'Adventure'
	'Action'
	'Sci-Fi'
	'Crime'
	'Mystery'
	'Others'
*/

/* So, RSVP Movies plans to make a movie of one of these genres.
Now, wouldn’t you want to know which genre had the highest number of movies produced in the last year?
Combining both the movie and genres table can give more interesting insights. */

-- Q6.Which genre had the highest number of movies produced overall?
-- Type your code below:
WITH genre_based_movie
     AS (SELECT 
				genre,
                COUNT(*)                    		AS total_produced_movie,
                RANK() OVER(ORDER BY COUNT(*) DESC) AS row_rank
         FROM   genre
         GROUP BY genre
         ORDER BY total_produced_movie DESC)
SELECT genre,
       total_produced_movie
FROM   genre_based_movie
WHERE  row_rank = (SELECT MIN(row_rank)
                   FROM   genre_based_movie);
/* Results :
-- highest number of movies produced by genre in entire period
	'Drama','4285'
-- even in latest year(2019) Drama genre tops the number of movies produced.
*/

/* So, based on the insight that you just drew, RSVP Movies should focus on the ‘Drama’ genre. 
But wait, it is too early to decide. A movie can belong to two or more genres. 
So, let’s find out the count of movies that belong to only one genre.*/

-- Q7. How many movies belong to only one genre?
-- Type your code below:
WITH singe_movie_summary
     AS (SELECT movie_id,
                COUNT(movie_id) AS cnt
         FROM   genre
         GROUP BY movie_id
         HAVING cnt = 1)
SELECT COUNT(movie_id) AS single_genre_movie_count
FROM   singe_movie_summary;
/* Results :
-- total count of movies with only single genre
	3289*/

/* There are more than three thousand movies which has only one genre associated with them.
So, this figure appears significant. 
Now, let's find out the possible duration of RSVP Movies’ next project.*/

-- Q8.What is the average duration of movies in each genre? 
-- (Note: The same movie can belong to multiple genres.)
/* Output format:
+---------------+-------------------+
| genre			|	avg_duration	|
+-------------------+----------------
|	thriller	|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:
SELECT 
	g.genre,
    Round(AVG(m.duration), 2) AS avg_duration
FROM genre g
    INNER JOIN movie m
		ON g.movie_id = m.id
GROUP BY g.genre
ORDER BY avg_duration DESC; 

/* Results :
+---------------+-------------------+
| genre			|	avg_duration	|
+-------------------+----------------
|	Action		|		112.88		|
|	Romance		|		109.53		|
|	Crime		|		107.05		|
|	Drama		|		106.77		|
|	Fantasy		|		105.14		|
|	Comedy		|		102.62		|
|	Adventure	|		101.87		|
|	Mystery		|		101.80		|
|	Thriller	|		101.58		|
|	Family		|		100.97		|
|	Others		|		100.16		|
|	Sci-Fi		|		97.94 		|
|	Horror		|		92.72 		|
+---------------+-------------------+ */

/* Now you know, movies of genre 'Drama' (produced highest in number in 2019) has the average duration of 106.77 mins.
Lets find where the movies of genre 'thriller' on the basis of number of movies.*/

-- Q9.What is the rank of the ‘thriller’ genre of movies among all the genres in terms of number of movies produced? 
-- (Hint: Use the Rank function)

/* Output format:
+---------------+-------------------+---------------------+
| genre			|		movie_count	|		genre_rank    |	
+---------------+-------------------+---------------------+
|drama			|	2312			|			2		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:
WITH genre_summary
     AS (SELECT genre,
                COUNT(*)                    		AS movie_count,
                RANK() OVER(ORDER BY COUNT(*) DESC) AS genre_rank
         FROM genre
         GROUP BY genre)
SELECT *
FROM   genre_summary
WHERE  genre = "thriller"; 
/* Results :
+---------------+-------------------+---------------------+
| genre			|		movie_count	|		genre_rank    |	
+---------------+-------------------+---------------------+
|Thriller		|	1484			|			3		  |
+---------------+-------------------+---------------------+*/

/*Thriller movies is in top 3 among all genres in terms of number of movies
 In the previous segment, you analysed the movies and genres tables. 
 In this segment, you will analyse the ratings table as well.
To start with lets get the min and max values of different columns in the table*/

/*******************************************************************************************************************
-- Segment 2:
*******************************************************************************************************************/

-- Q10.  Find the minimum and maximum values in  each column of the ratings table except the movie_id column?
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
| min_avg_rating|	max_avg_rating	|	min_total_votes   |	max_total_votes 	 |min_median_rating|min_median_rating|
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
|		0		|			5		|	       177		  |	   2000	    		 |		0	       |	8			 |
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+*/
-- Type your code below:
-- in the Output format "min_median_rating" is writted twice, so i took the liberty to change one to "max_median_rating"
SELECT MIN(avg_rating)    AS min_avg_rating,
       MAX(avg_rating)    AS max_avg_rating,
       MIN(total_votes)   AS min_total_votes,
       MAX(total_votes)   AS max_total_votes,
       MIN(median_rating) AS min_median_rating,
       MAX(median_rating) AS max_median_rating
FROM   ratings; 
/* Results :
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
| min_avg_rating|	max_avg_rating	|	min_total_votes   |	max_total_votes 	 |min_median_rating|max_median_rating|
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
|		1.0		|		10.0		|	       100		  |	   725138	  		 |		1	       |	10			 |
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+*/

/* So, the minimum and maximum values in each column of the ratings table are in the expected range. 
This implies there are no outliers in the table. 
Now, let’s find out the top 10 movies based on average rating.*/

-- Q11. Which are the top 10 movies based on average rating?
/* Output format:
+---------------+-------------------+---------------------+
| title			|		avg_rating	|		movie_rank    |
+---------------+-------------------+---------------------+
| Fan			|		9.6			|			5	  	  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:
-- It's ok if RANK() or DENSE_RANK() is used too

SELECT   m.title        AS title,
         r.avg_rating   AS avg_rating,
         rank() OVER w1 AS movie_rank
FROM     movie m
JOIN     ratings r
ON       m.id = r.movie_id window w1 AS(ORDER BY r.avg_rating DESC)
ORDER BY avg_rating DESC LIMIT 10;

/* Results :
+-----------------------------------+-------------------+---------------------+
| title			   					|		avg_rating	|		movie_rank    |
+-----------------------------------+-------------------+---------------------+
| Kirket							|		10.0		|			1 	  	  |
| Love in Kilnerry					|		10.0		|			1 	  	  |
| Gini Helida Kathe					|		9.8 		|			3 	  	  |
| Runam								|		9.7 		|			4 	  	  |
| Fan								|		9.6 		|			5 	  	  |
| Android Kunjappan Version 5.25	|		9.6 		|			5 	  	  |
| The Brighton Miracle				|		9.5 		|			7 	  	  |
| Yeh Suhaagraat Impossible			|		9.5 		|			7 	  	  |
| Safe								|		9.5 		|			7 	  	  |
| Shibu								|		9.4 		|			10	  	  |
+-----------------------------------+-------------------+---------------------+*/


/* Do you find you favourite movie FAN in the top 10 movies with an average rating of 9.6? If not, please check your code again!!
So, now that you know the top 10 movies, do you think character actors and filler actors can be from these movies?
Summarising the ratings table based on the movie counts by median rating can give an excellent insight.*/

-- Q12. Summarise the ratings table based on the movie counts by median ratings.
/* Output format:

+---------------+-------------------+
| median_rating	|	movie_count		|
+-------------------+----------------
|	1			|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:
-- Order by is good to have
SELECT median_rating,
       COUNT(movie_id) AS movie_count
FROM   ratings
GROUP BY median_rating
ORDER BY median_rating; 
/* Results :
+---------------+-------------------+
| median_rating	|	movie_count		|
+---------------+-------------------+
|	1			|		94			|
|	2			|		119			|
|	3			|		283			|
|	4			|		479			|
|	5			|		985			|
|	6			|		1975		|
|	7			|		2257		|
|	8			|		1030		|
|	9			|		429			|
|	10			|		346			|
+---------------+-------------------+ */

/* Movies with a median rating of 7 is highest in number. 
Now, let's find out the production house with which RSVP Movies can partner for its next project.*/

-- Q13. Which production house has produced the most number of hit movies (average rating > 8)??
/* Output format:
+------------------+-------------------+---------------------+
|production_company|movie_count	       |	prod_company_rank|
+------------------+-------------------+---------------------+
| The Archers	   |		1		   |			1	  	 |
+------------------+-------------------+---------------------+*/
-- Type your code below:
SELECT     m.production_company,
           COUNT(m.id)                            AS movie_count,
           RANK() OVER(ORDER BY COUNT(m.id) DESC) AS prod_company_rank
FROM       movie m
INNER JOIN ratings r
ON         m.id = r.movie_id
WHERE      r.avg_rating > 8
AND        m.production_company IS NOT NULL
GROUP BY   production_company LIMIT 1;
/* Results:
+-----------------------+------------------+------------------------+
|production_company		|	movie_count    |	prod_company_rank	|
+-----------------------+------------------+------------------------+
|Dream Warrior Pictures	|		3		   |			1	  	 	|
+-----------------------+------------------+------------------------+*/

-- It's ok if RANK() or DENSE_RANK() is used too
-- Answer can be Dream Warrior Pictures or National Theatre Live or both

-- Q14. How many movies released in each genre during March 2017 in the USA had more than 1,000 votes?
/* Output format:

+---------------+-------------------+
| genre			|	movie_count		|
+-------------------+----------------
|	thriller	|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:
SELECT g.genre,
       COUNT(*) AS movie_count
FROM   genre g
       INNER JOIN movie m
               ON g.movie_id = m.id
       INNER JOIN ratings r
               ON m.id = r.movie_id
WHERE  m.date_published BETWEEN '2017-03-01' AND '2017-03-31'
   AND m.country REGEXP 'USA'
   AND r.total_votes > 1000
GROUP BY g.genre
ORDER BY movie_count DESC;
/* Results :
+---------------+-------------------+
| genre			|	movie_count		|
+-------------------+----------------
|	Drama		|		24			|
|	Comedy		|		9			|
|	Action		|		8			|
|	Thriller	|		8			|
|	Sci-Fi		|		7			|
|	Crime		|		6			|
|	Horror		|		6			|
|	Mystery		|		4			|
|	Romance		|		4			|
|	Adventure	|		3			|
|	Fantasy		|		3			|
|	Family		|		1			|
+---------------+-------------------+ */

-- Lets try to analyse with a unique problem statement.
-- Q15. Find movies of each genre that start with the word ‘The’ and which have an average rating > 8?
/* Output format:
+---------------+-------------------+---------------------+
| title			|		avg_rating	|		genre	      |
+---------------+-------------------+---------------------+
| Theeran		|		8.3			|		Thriller	  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:
SELECT m.title,
       r.avg_rating,
       g.genre
FROM   movie m
       INNER JOIN ratings r
               ON m.id = r.movie_id
       INNER JOIN genre g USING (movie_id)
WHERE  m.title REGEXP '^The'
   AND r.avg_rating > 8
ORDER BY r.avg_rating DESC; 
/* Results :
+-------------------------------------------+-------------------+---------------------+
| title										|		avg_rating	|		genre	      |
+-------------------------------------------+-------------------+---------------------+
| The Brighton Miracle						|		9.5			|		Drama		  |
| The Colour of Darkness					|		9.1			|		Drama		  |
| The Blue Elephant 2						|		8.8			|		Drama		  |
| The Blue Elephant 2						|		8.8			|		Horror		  |
| The Blue Elephant 2						|		8.8			|		Mystery		  |
| The Irishman								|		8.7			|		Crime		  |
| The Irishman								|		8.7			|		Drama		  |
| The Mystery of Godliness: The Sequel		|		8.5			|		Drama		  |
| The Gambinos								|		8.4			|		Crime		  |
| The Gambinos								|		8.4			|		Drama		  |
| Theeran Adhigaaram Ondru					|		8.3			|		Action		  |
| Theeran Adhigaaram Ondru					|		8.3			|		Crime		  |
| Theeran Adhigaaram Ondru					|		8.3			|		Thriller  	  |
| The King and I							|		8.2			|		Drama		  |
| The King and I							|		8.2			|		Romance	      |
+-------------------------------------------+-------------------+---------------------+*/

-- You should also try your hand at median rating and check whether the ‘median rating’ column gives any significant insights.
-- Q16. Of the movies released between 1 April 2018 and 1 April 2019, how many were given a median rating of 8?
-- Type your code below:
SELECT COUNT(m.id) AS movies_released
FROM   movie m
       INNER JOIN ratings r
               ON m.id = r.movie_id
WHERE  ( m.date_published BETWEEN "2018-04-01" AND "2019-04-01" )
   AND r.median_rating = 8;
/* Results :
	361 */

-- Once again, try to solve the problem given below.
-- Q17. Do German movies get more votes than Italian movies? 
-- Hint: Here you have to find the total number of votes for both German and Italian movies.
-- Type your code below:
WITH language_summary AS
(
           SELECT
                      CASE
                                 WHEN m.languages regexp "German" THEN r.total_votes
                      END AS german_votes,
                      CASE
                                 WHEN m.languages regexp "Italian" THEN r.total_votes
                      END AS italian_votes
           FROM       movie m
           INNER JOIN ratings r
           ON         m.id = r.movie_id )
SELECT
       CASE
              WHEN SUM(german_votes) > SUM(italian_votes) THEN "Yes"
              ELSE "No"
       END AS is_german_votes_higher
FROM   language_summary;
/* Results :
	is_german_votes_higher? : Yes
    German : 4,421,525; Italian : 2,559,540*/

-- Answer is Yes

/* Now that you have analysed the movies, genres and ratings tables, let us now analyse another table, the names table. 
Let’s begin by searching for null values in the tables.*/

/*******************************************************************************************************************
-- Segment 3:
*******************************************************************************************************************/

-- Q18. Which columns in the names table have null values??
/*Hint: You can find null values for individual columns or follow below output format
+---------------+-------------------+---------------------+----------------------+
| name_nulls	|	height_nulls	|date_of_birth_nulls  |known_for_movies_nulls|
+---------------+-------------------+---------------------+----------------------+
|		0		|			123		|	       1234		  |	   12345	    	 |
+---------------+-------------------+---------------------+----------------------+*/
-- Type your code below:
SELECT SUM(NAME IS NULL)             AS name_nulls,
       SUM(height IS NULL)           AS height_nulls,
       SUM(date_of_birth IS NULL)    AS date_of_birth_nulls,
       SUM(known_for_movies IS NULL) AS known_for_movies_nulls
FROM   names;
/*
+---------------+-------------------+---------------------+----------------------+
| name_nulls	|	height_nulls	|date_of_birth_nulls  |known_for_movies_nulls|
+---------------+-------------------+---------------------+----------------------+
|		0		|		17335		|	       13431	  |	   15226	    	 |
+---------------+-------------------+---------------------+----------------------+*/

/* There are no Null value in the column 'name'.
The director is the most important person in a movie crew. 
Let’s find out the top three directors in the top three genres who can be hired by RSVP Movies.*/

-- Q19. Who are the top three directors in the top three genres whose movies have an average rating > 8?
-- (Hint: The top three genres would have the most number of movies with an average rating > 8.)
/* Output format:

+---------------+-------------------+
| director_name	|	movie_count		|
+---------------+-------------------|
|James Mangold	|		4			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:


WITH top_3_genre AS
(
           SELECT     g.genre
           FROM       genre g
           INNER JOIN ratings r
           using      (movie_id)
           WHERE      r.avg_rating > 8
           GROUP BY   g.genre
           ORDER BY   COUNT(g.movie_id) DESC LIMIT 3 )
SELECT     n.NAME            AS director_name,
           COUNT(d.movie_id) AS movie_count
FROM       names n
INNER JOIN director_mapping d
ON         n.id = d.name_id
INNER JOIN ratings r
ON         d.movie_id = r.movie_id
INNER JOIN genre g
ON         g.movie_id = d.movie_id
INNER JOIN top_3_genre t
ON         g.genre = t.genre
WHERE      r.avg_rating > 8
GROUP BY   director_name
ORDER BY   movie_count DESC LIMIT 3;
/* Results :
+---------------+-------------------+
| director_name	|	movie_count		|
+---------------+-------------------|
|James Mangold	|		4			|
|Soubin Shahir	|		3			|
|Anthony Russo	|		3			|
+---------------+-------------------+ */


/* James Mangold can be hired as the director for RSVP's next project. Do you remeber his movies, 'Logan' and 'The Wolverine'. 
Now, let’s find out the top two actors.*/

-- Q20. Who are the top two actors whose movies have a median rating >= 8?
/* Output format:

+---------------+-------------------+
| actor_name	|	movie_count		|
+-------------------+----------------
|Christain Bale	|		10			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:
SELECT n.name            AS actor_name,
       COUNT(r.movie_id) AS movie_count
FROM   names n
       INNER JOIN role_mapping rm
               ON n.id = rm.name_id
       INNER JOIN ratings r USING (movie_id)
WHERE  r.median_rating >= 8
   AND rm.category = 'actor'
GROUP BY actor_name
ORDER BY movie_count DESC
LIMIT  2;
/* Results :
+---------------+-------------------+
| actor_name	|	movie_count		|
+-------------------+----------------
|Mammootty		|		8			|
|Mohanlal		|		5			|
+---------------+-------------------+ */

/* Have you find your favourite actor 'Mohanlal' in the list. If no, please check your code again. 
RSVP Movies plans to partner with other global production houses. 
Let’s find out the top three production houses in the world.*/

-- Q21. Which are the top three production houses based on the number of votes received by their movies?
/* Output format:
+------------------+--------------------+---------------------+
|production_company|vote_count			|		prod_comp_rank|
+------------------+--------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+*/
-- Type your code below:
SELECT   m.production_company                                 AS production_company,
         SUM(r.total_votes)                                   AS vote_count,
         ROW_NUMBER() OVER (ORDER BY SUM(r.total_votes) DESC) AS prod_comp_rank
FROM     movie m
JOIN     ratings r
ON       m.id = r.movie_id
GROUP BY m.production_company LIMIT 3;

/* Results :
+-----------------------+-------------------+---------------------+
|production_company		|vote_count			|		prod_comp_rank|
+-----------------------+-------------------+---------------------+
|Marvel Studios			|	2656967			|			1  		  |
|Twentieth Century Fox	|	2411163			|			2		  |
|Warner Bros.			|	2396057			|			3		  |
+-----------------------+-------------------+---------------------+*/

/*Yes Marvel Studios rules the movie world.
So, these are the top three production houses based on the number of votes received by the movies they have produced.

Since RSVP Movies is based out of Mumbai, India also wants to woo its local audience. 
RSVP Movies also wants to hire a few Indian actors for its upcoming project to give a regional feel. 
Let’s find who these actors could be.*/

-- Q22. Rank actors with movies released in India based on their average ratings. Which actor is at the top of the list?
-- Note: The actor should have acted in at least five Indian movies. 
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actor_name	|	total_votes		|	movie_count		  |	actor_avg_rating 	 |actor_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Yogi Babu	|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:
SELECT     n.NAME                                                                                  AS actor_name,
           SUM(total_votes)                                                                        AS total_votes,
           COUNT(r.movie_id)                                                                       AS movie_count,
           Round(SUM(r.avg_rating*r.total_votes)/SUM(r.total_votes),2)                             AS actor_avg_rating,
           RANK() OVER (ORDER BY Round(SUM(r.avg_rating*r.total_votes)/SUM(r.total_votes),2) DESC) AS actor_rank
FROM       names n
INNER JOIN role_mapping rm
ON         n.id = rm.name_id
INNER JOIN ratings r
using      (movie_id)
INNER JOIN movie m
ON         r.movie_id = m.id
WHERE      m.country regexp "India"
AND        rm.category = "actor"
GROUP BY   actor_name
HAVING     movie_count >= 5;
/* Results :
actor_name			total_votes	movie_count	actor_avg_rating	actor_rank
Vijay Sethupathi	23114		5			8.42				1
Fahadh Faasil		13557		5			7.99				2
Yogi Babu			8500		11			7.83				3
Joju George			3926		5			7.58				4
Ammy Virk			2504		6			7.55				5
.					.			.			.					.
*/


-- Top actor is Vijay Sethupathi

-- Q23.Find out the top five actresses in Hindi movies released in India based on their average ratings? 
-- Note: The actresses should have acted in at least three Indian movies. 
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |	actress_avg_rating 	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Tabu		|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:
SELECT     n.NAME                                                                                  AS actress_name,
           SUM(total_votes)                                                                        AS total_votes,
           COUNT(r.movie_id)                                                                       AS movie_count,
           Round(SUM(r.avg_rating*r.total_votes)/SUM(r.total_votes),2)                             AS actress_avg_rating,
           RANK() OVER (ORDER BY Round(SUM(r.avg_rating*r.total_votes)/SUM(r.total_votes),2) DESC) AS actress_rank
FROM       names n
INNER JOIN role_mapping rm
ON         n.id = rm.name_id
INNER JOIN ratings r
using      (movie_id)
INNER JOIN movie m
ON         r.movie_id = m.id
WHERE      m.country regexp "India"
AND        m.languages regexp "Hindi"
AND        rm.category = "actress"
GROUP BY   actress_name
HAVING     movie_count >= 3;
/*Results :
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |	actress_avg_rating 	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|Taapsee Pannu	|		18061		|	      3			  |	   7.74    			 |		1	       |
|Kriti Sanon			21967 		|	      3			  |	   7.05   	 		 |		2	       |
|Divya Dutta	|		8579		|	      3			  |	   6.88    			 |		3	       |
|Shraddha Kapoor|		26779		|	      3			  |	   6.63    			 |		4	       |
|Kriti Kharbanda|		2549 		|	      3			  |	   4.80    			 |		5	       |
|Sonakshi Sinha	|		4025 		|	      4			  |	   4.18    			 |		6	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/

/* Taapsee Pannu tops with average rating 7.74. 
Now let us divide all the thriller movies in the following categories and find out their numbers.*/

/* Q24. Select thriller movies as per avg rating and classify them in the following category: 

			Rating > 8: Superhit movies
			Rating between 7 and 8: Hit movies
			Rating between 5 and 7: One-time-watch movies
			Rating < 5: Flop movies
--------------------------------------------------------------------------------------------*/
-- Type your code below:
SELECT CASE
         WHEN avg_rating > 8 THEN "superhit movies"
         WHEN avg_rating BETWEEN 7 AND 8 THEN "hit movies"
         WHEN avg_rating BETWEEN 5 AND 7 THEN "one-time-watch movies"
         ELSE "flop movies"
       END      AS thriller_genre_category,
       COUNT(*) AS movie_count
FROM   ratings r
       INNER JOIN genre g using (movie_id)
WHERE  g.genre = "thriller"
GROUP BY thriller_genre_category
ORDER BY movie_count DESC;
/* Results :
'Hit movies',			'166'
'Flop movies',			'493'
'One-time-watch movies','786'
'Superhit movies',		'39'
*/

/* Until now, you have analysed various tables of the data set. 
Now, you will perform some tasks that will give you a broader understanding of the data in this segment.*/

/*******************************************************************************************************************
-- Segment 4:
*******************************************************************************************************************/

-- Q25. What is the genre-wise running total and moving average of the average movie duration? 
-- (Note: You need to show the output table in the question.) 
/* Output format:
+---------------+-------------------+---------------------+----------------------+
| genre			|	avg_duration	|running_total_duration|moving_avg_duration  |
+---------------+-------------------+---------------------+----------------------+
|	comdy		|			145		|	       106.2	  |	   128.42	    	 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
+---------------+-------------------+---------------------+----------------------+*/
-- Type your code below:
WITH movie_summery
     AS (SELECT g.genre                   AS genre,
                ROUND(AVG(m.duration), 2) AS avg_duration,
                SUM(m.duration)           AS running_total_duration,
                m.date_published          AS date_published
         FROM   movie m
                INNER JOIN genre g
                  ON m.id = g.movie_id
         GROUP BY genre,
                  date_published
         ORDER BY 3 DESC)
SELECT genre,
       avg_duration,
       running_total_duration,
       ROUND(AVG(avg_duration)
               OVER (ORDER BY date_published ROWS UNBOUNDED PRECEDING), 2) AS moving_avg_duration
FROM   movie_summery;


-- Round is good to have and not a must have; Same thing applies to sorting

-- Let us find top 5 movies of each year with top 3 genres.

-- Q26. Which are the five highest-grossing movies of each year that belong to the top three genres? 
-- (Note: The top 3 genres would have the most number of movies.)

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| genre			|	year			|	movie_name		  |worldwide_gross_income|movie_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	comedy		|			2017	|	       indian	  |	   $103244842	     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:
-- Top 3 Genres based on most number of movies


-- Method 1 : REPLACE $ & INR in gross income column and convert to numeric (no currency conversion is applied)
WITH top3_genre AS
(
         SELECT   g.genre AS genre
         FROM     movie   AS m
         JOIN     genre   AS g
         ON       m.id = g.movie_id
         GROUP BY 1
         ORDER BY COUNT(*) DESC LIMIT 3 ), movie_rank_table AS
(
         SELECT   g.genre AS genre,
                  m.year  AS year,
                  m.title AS movie_name,
                  CASE
                           WHEN worlwide_gross_income LIKE '%$%' THEN Cast(Replace(worlwide_gross_income, '$', '') AS SIGNED)
                           ELSE Cast(Replace(worlwide_gross_income, 'INR', '') AS SIGNED)
                  END                                                                                                                               AS worldwide_gross_income,
                  ROW_NUMBER() OVER (partition BY m.year ORDER BY Cast(Replace(Replace(worlwide_gross_income, '$', ''), "INR", '') AS SIGNED) DESC) AS movie_rank
         FROM     movie m
         JOIN     genre g
         ON       m.id = g.movie_id
         WHERE    g.genre IN
                  (
                         SELECT *
                         FROM   top3_genre) )
SELECT *
FROM   movie_rank_table
WHERE  movie_rank <= 5;

-- Method 2 : Applied REPLACE but showing currency symbols as is in data, as the Output format table shows $ sybmol in it 
WITH top3_genre AS
(
         SELECT   g.genre AS genre
         FROM     movie m
         JOIN     genre g
         ON       m.id = g.movie_id
         GROUP BY 1
         ORDER BY COUNT(*) DESC LIMIT 3 ), movie_rank_table AS
(
         SELECT   g.genre                                                                                                                           AS genre,
                  m.year                                                                                                                            AS year,
                  m.title                                                                                                                           AS movie_name,
                  worlwide_gross_income                                                                                                             AS worldwide_gross_income,
                  ROW_NUMBER() OVER (partition BY m.year ORDER BY Cast(Replace(Replace(worlwide_gross_income, '$', ''), "INR", '') AS SIGNED) DESC) AS movie_rank
         FROM     movie m
         JOIN     genre g
         ON       m.id = g.movie_id
         WHERE    g.genre IN
                  (
                         SELECT *
                         FROM   top3_genre) )
SELECT *
FROM   movie_rank_table
WHERE  movie_rank <= 5;

-- Finally, let’s find out the names of the top two production houses that have produced the highest number of hits among multilingual movies.
-- Q27.  Which are the top two production houses that have produced the highest number of hits (median rating >= 8) among multilingual movies?
/* Output format:
+-------------------+-------------------+---------------------+
|production_company |movie_count		|		prod_comp_rank|
+-------------------+-------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+*/
-- Type your code below:
SELECT     m.production_company,
           COUNT(*)                            AS movie_count,
           RANK() OVER(ORDER BY COUNT(*) DESC) AS prod_comp_rank
FROM       movie m
INNER JOIN ratings r
ON         m.id = r.movie_id
WHERE      position(',' IN m.languages)>0
AND        m.production_company IS NOT NULL
AND        r.median_rating >= 8
GROUP BY   m.production_company LIMIT 2;
/*
+-----------------------+-------------------+-------------------+
|production_company 	|	movie_count		|	prod_comp_rank	|
+-----------------------+-------------------+-------------------+
|Star Cinema			|		7			|		1	  		|
|Twentieth Century Fox	|		4			|		2			|
+-------------------+-------------------+-----------------------+*/

-- Multilingual is the important piece in the above question. It was created using POSITION(',' IN languages)>0 logic
-- If there is a comma, that means the movie is of more than one language

-- Q28. Who are the top 3 actresses based on number of Super Hit movies (average rating >8) in drama genre?
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |actress_avg_rating	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Laura Dern	|			1016	|	       1		  |	   9.60			     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:
SELECT     n.name                                                               AS actress_name,
           SUM(r.total_votes)                                                   AS total_votes,
           COUNT(m.id)                                                          AS movie_count,
           AVG(r.avg_rating)                                                    AS actress_avg_rating,
           ROW_NUMBER() OVER (ORDER BY COUNT(m.id) DESC, SUM(total_votes) DESC) AS actress_rank
           /* why I use total votes as 2nd metric is because number of vote are far more larger than others actress, if we sort by avg_ranking, could
			due to sample size neither nor equivalent or similar, and result could be misleading & biased. Actually I don't even need
			2nd metric as the result will be the same if I only need top3, however, given scenario of real world practice, I see it is neccesary
			to use 2nd metric, or even more*/
FROM       movie m
INNER JOIN genre g
ON         m.id = g.movie_id
INNER JOIN role_mapping rm
ON         m.id = rm.movie_id
INNER JOIN names n
ON         rm.name_id = n.id
INNER JOIN ratings r
ON         m.id = r.movie_id
WHERE      (
                      rm.category = 'actress')
AND        (
                      r.avg_rating > 8)
AND        (
                      g.genre = 'Drama')
GROUP BY   1 LIMIT 3;
/* Results :
+-------------------+-------------------+---------------------+----------------------+-----------------+
| actress_name		|	total_votes		|	movie_count		  |actress_avg_rating	 |actress_rank	   |
+-------------------+-------------------+---------------------+----------------------+-----------------+
|Parvathy Thiruvothu|		4974		|	       2		  |	   8.20				 |		1	       |
|Susan Brown		|		656 		|	       2		  |	   8.95    			 |		1	       |
|Amanda Lawrence	|		656 		|	       2		  |	   8.95    			 |		1	       |
+-------------------+-------------------+---------------------+----------------------+-----------------+*/

/* Q29. Get the following details for top 9 directors (based on number of movies)
Director id
Name
Number of movies
Average inter movie duration in days
Average movie ratings
Total votes
Min rating
Max rating
total movie durations

Format:
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
| director_id	|	director_name	|	number_of_movies  |	avg_inter_movie_days |	avg_rating	| total_votes  | min_rating	| max_rating | total_duration |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
|nm1777967		|	A.L. Vijay		|			5		  |	       177			 |	   5.65	    |	1754	   |	3.7		|	6.9		 |		613		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+

--------------------------------------------------------------------------------------------*/
-- Type you code below:
WITH top9_director AS
(
         SELECT   n.id                                                        AS director_id,
                  n.NAME                                                      AS director_name,
                  COUNT(m.id)                                                 AS number_of_movies,
                  Round(SUM(r.avg_rating*r.total_votes)/SUM(r.total_votes),2) AS avg_rating,
                  SUM(r.total_votes)                                          AS total_votes,
                  MIN(r.avg_rating)                                           AS min_rating,
                  MAX(r.avg_rating)                                           AS max_rating,
                  SUM(m.duration)                                             AS total_duration
         FROM     movie m
         INNER JOIN director_mapping dm
				 ON m.id = dm.movie_id
         INNER JOIN names n
				 ON dm.name_id = n.id
         INNER JOIN ratings r
				 ON m.id = r.movie_id
         GROUP BY 1
         ORDER BY 3 DESC LIMIT 9), top9_nameid AS
(
       SELECT director_id
       FROM   top9_director ), top9_director_date_published AS
(
         SELECT   title,
                  dm.name_id,
                  date_published
         FROM     movie m
         INNER JOIN director_mapping dm
				 ON m.id = dm.movie_id
         INNER JOIN names n
				 ON dm.name_id = n.id
         WHERE    name_id IN
                  (
                         SELECT *
                         FROM   top9_nameid)
         ORDER BY 2,
                  3 ), interval_days AS
(
         SELECT   *,
                  Datediff(date_published, LEAD(date_published,1) OVER (ORDER BY name_id, date_published)) AS interval_day
         FROM     top9_director_date_published ), top9_director_invertal_day AS
(
         SELECT   name_id,
                  Abs(Round(AVG(interval_day))) AS avg_inter_movie_days
         FROM     interval_days
         WHERE    interval_day < 0 -- filter out the e.g. director A's last published date substract director B's first published date
         GROUP BY 1 )
SELECT t9_id.director_id,
       t9_id.director_name,
       t9_id.number_of_movies,
       t9_inter.avg_inter_movie_days,
       t9_id.avg_rating,
       t9_id.total_votes,
       t9_id.min_rating,
       t9_id.max_rating,
       t9_id.total_duration
FROM   top9_director t9_id
INNER JOIN top9_director_invertal_day t9_inter
		ON t9_id.director_id = t9_inter.name_id;

/********************************************* END *******************************************************/






