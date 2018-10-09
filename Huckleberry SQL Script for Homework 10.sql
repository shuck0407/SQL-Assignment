use sakila;

-- 1a. Display the first and last names of all actors from the table `actor`.

SELECT FIRST_NAME, LAST_NAME FROM ACTOR;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`.

SELECT CONCAT(UPPER(FIRST_NAME), UPPER(LAST_NAME)) AS 'Actor Name' FROM ACTOR;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?

SELECT ACTOR_ID, FIRST_NAME, LAST_NAME FROM ACTOR WHERE FIRST_NAME = 'JOE';

-- 2b. Find all actors whose last name contain the letters `GEN`:

SELECT * FROM ACTOR WHERE LAST_NAME LIKE '%GEN%';

-- 2c. Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order:

SELECT * FROM ACTOR WHERE LAST_NAME LIKE '%LI%' ORDER BY LAST_NAME, FIRST_NAME;

-- 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China:

SELECT COUNTRY_ID, COUNTRY FROM COUNTRY WHERE COUNTRY IN ('Afghanistan', 'Bangladesh', 'China');

-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table `actor` named `description` 
-- and use the data type `BLOB` (Make sure to research the type `BLOB`, as the difference between it and `VARCHAR` are significant).

ALTER TABLE sakila.actor 
	ADD COLUMN description BLOB NULL AFTER last_update;

desc actor;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the `description` column.

ALTER TABLE sakila.actor 
	DROP COLUMN description;

DESC actor;
     
-- 4a. List the last names of actors, as well as how many actors have that last name.    

SELECT COUNT(*), LAST_NAME FROM ACTOR GROUP BY LAST_NAME;

-- 4b. List last names of actors and the number of actors who have that last name, 
-- but only for names that are shared by at least two actors

SELECT LAST_NAME, COUNT(*)  FROM ACTOR GROUP BY LAST_NAME HAVING COUNT(*) > 1 ;

-- 4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`. 
-- Write a query to fix the record

UPDATE ACTOR SET FIRST_NAME = 'HARPO' WHERE FIRST_NAME = 'GROUCHO' AND LAST_NAME = 'WILLIAMS';

SELECT * FROM ACTOR WHERE LAST_NAME = 'WILLIAMS';

-- 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name 
-- after all! In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`.

UPDATE ACTOR SET FIRST_NAME = 'GROUCHO' WHERE FIRST_NAME = 'HARPO';

SELECT * FROM ACTOR WHERE FIRST_NAME = 'GROUCHO';

-- 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?

DROP TABLE IF EXISTS ADDRESS;

CREATE TABLE `address` (
  `address_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
  `address` varchar(50) NOT NULL,
  `address2` varchar(50) DEFAULT NULL,
  `district` varchar(20) NOT NULL,
  `city_id` smallint(5) unsigned NOT NULL,
  `postal_code` varchar(10) DEFAULT NULL,
  `phone` varchar(20) NOT NULL,
  `location` geometry NOT NULL,
  `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`address_id`),
  KEY `idx_fk_city_id` (`city_id`),
  SPATIAL KEY `idx_location` (`location`),
  CONSTRAINT `fk_address_city` FOREIGN KEY (`city_id`) REFERENCES `city` (`city_id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=606 DEFAULT CHARSET=utf8;

-- 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`:

SELECT STAFF.FIRST_NAME, STAFF.LAST_NAME, ADDRESS.ADDRESS_ID, ADDRESS.ADDRESS, ADDRESS.ADDRESS2, ADDRESS.DISTRICT, ADDRESS.CITY_ID, ADDRESS.POSTAL_CODE
	FROM STAFF, ADDRESS WHERE STAFF.ADDRESS_ID = ADDRESS.ADDRESS_ID;
    
-- 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`.

SELECT SUM(PAYMENT.AMOUNT), STAFF.STAFF_ID, STAFF.FIRST_NAME, STAFF.LAST_NAME FROM PAYMENT, STAFF WHERE PAYMENT.STAFF_ID = STAFF.STAFF_ID
	AND PAYMENT.PAYMENT_DATE >= '2005-08-01 00:00:00' AND PAYMENT.PAYMENT_DATE <= '2005-08-31 24:59:59'
    GROUP BY STAFF.STAFF_ID, STAFF.FIRST_NAME, STAFF.LAST_NAME ;

-- 6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.

SELECT COUNT(A.ACTOR_ID), A.FILM_ID, B.TITLE FROM FILM_ACTOR A, FILM B WHERE A.FILM_ID = B.FILM_ID GROUP BY A.FILM_ID, B.TITLE;

-- 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?

SELECT COUNT(A.INVENTORY_ID), B.TITLE FROM INVENTORY A, FILM B WHERE A.FILM_ID = B.FILM_ID AND B.TITLE = 'HUNCHBACK IMPOSSIBLE' GROUP BY B.TITLE;

-- 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. List the customers alphabetically by last name:

SELECT B.FIRST_NAME, B.LAST_NAME, SUM(A.AMOUNT) AS 'Total Amount Paid'  FROM PAYMENT A, CUSTOMER B WHERE A.CUSTOMER_ID = B.CUSTOMER_ID GROUP BY B.LAST_NAME ORDER BY B.LAST_NAME;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters `K` and `Q` have also soared in popularity. Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English.

SELECT A.TITLE FROM FILM A WHERE (A.TITLE LIKE 'K%' OR A.TITLE LIKE 'Q%') AND A.LANGUAGE_ID = (SELECT B.LANGUAGE_ID FROM LANGUAGE B WHERE B.NAME = 'ENGLISH');

-- 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.

SELECT A.FIRST_NAME, A.LAST_NAME FROM ACTOR A WHERE A.ACTOR_ID IN (SELECT B.ACTOR_ID FROM FILM_ACTOR B, FILM C WHERE B.FILM_ID = C.FILM_ID AND C.TITLE = 'ALONE TRIP');

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.

SELECT CUST.FIRST_NAME, CUST.LAST_NAME, CUST.EMAIL FROM CUSTOMER CUST
 JOIN ADDRESS ADDR ON CUST.ADDRESS_ID = ADDR.ADDRESS_ID
	JOIN CITY ON ADDR.CITY_ID = CITY.CITY_ID
    JOIN COUNTRY ON CITY.COUNTRY_ID = COUNTRY.COUNTRY_ID
    WHERE COUNTRY.COUNTRY = 'CANADA';


-- 7d. Sales have been lagging among young familiesSJK, and you wish to target all family movies for a promotion. Identify all movies categorized as _family_ films.

SELECT FILM.FILM_ID, FILM.TITLE, CATEGORY.NAME FROM FILM JOIN FILM_CATEGORY ON FILM.FILM_ID = FILM_CATEGORY.FILM_ID
	JOIN CATEGORY ON FILM_CATEGORY.CATEGORY_ID = CATEGORY.CATEGORY_ID
    WHERE CATEGORY.NAME = 'Family'
    ORDER BY FILM.TITLE;


-- 7e. Display the most frequently rented movies in descending order.

SELECT COUNT(A.RENTAL_ID), C.FILM_ID, C.TITLE FROM RENTAL A, INVENTORY B, FILM C
	WHERE A.INVENTORY_ID = B.INVENTORY_ID AND B.FILM_ID = C.FILM_ID 
    GROUP BY C.FILM_ID, C.TITLE
    ORDER BY COUNT(RENTAL_ID) DESC;


-- 7f. Write a query to display how much business, in dollars, each store brought in.

SELECT SUM(A.AMOUNT) as 'Total Sales', D.STORE_ID, F.CITY, G.COUNTRY FROM PAYMENT A, RENTAL B, INVENTORY C, 
	STORE D, ADDRESS E, CITY F, COUNTRY G
		WHERE A.RENTAL_ID = B.RENTAL_ID AND B.INVENTORY_ID = C.INVENTORY_ID AND C.STORE_ID = D.STORE_ID
		AND D.ADDRESS_ID = E.ADDRESS_ID AND E.CITY_ID = F.CITY_ID AND F.COUNTRY_ID = G.COUNTRY_ID
		GROUP BY D.STORE_ID, F.CITY, G.COUNTRY;


-- 7g. Write a query to display for each store its store ID, city, and country.

SELECT A.STORE_ID, C.CITY, D.COUNTRY
	FROM STORE A, ADDRESS B, CITY C, COUNTRY D
		WHERE A.ADDRESS_ID = B.ADDRESS_ID
			AND B.CITY_ID = C.CITY_ID
            AND C.COUNTRY_ID = D.COUNTRY_ID;


-- 7h. List the top five genres in gross revenue in descending order. (**Hint**: you may need to use the following tables: category, film_category, inventory, payment, and rental.)

SELECT SUM(A.AMOUNT) AS 'Gross Revenue', E.NAME
	FROM PAYMENT A, RENTAL B, INVENTORY C, FILM_CATEGORY D, CATEGORY E
		WHERE A.RENTAL_ID = B.RENTAL_ID AND B.INVENTORY_ID = C.INVENTORY_ID
			AND C.FILM_ID = D.FILM_ID AND D.CATEGORY_ID = E.CATEGORY_ID
				GROUP BY E.NAME ORDER BY SUM(A.AMOUNT) DESC LIMIT 5;


-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. 
-- If you haven't solved 7h, you can substitute another query to create a view.

CREATE VIEW top_5_revenue AS
	SELECT SUM(A.AMOUNT) gross_revenue, E.NAME genre
	FROM PAYMENT A, RENTAL B, INVENTORY C, FILM_CATEGORY D, CATEGORY E
		WHERE A.RENTAL_ID = B.RENTAL_ID AND B.INVENTORY_ID = C.INVENTORY_ID
			AND C.FILM_ID = D.FILM_ID AND D.CATEGORY_ID = E.CATEGORY_ID
				GROUP BY E.NAME ORDER BY SUM(A.AMOUNT) DESC LIMIT 5;

-- 8b. How would you display the view that you created in 8a?

select * from top_5_revenue;

-- 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.

DROP VIEW top_5_revenue;

