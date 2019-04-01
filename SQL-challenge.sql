USE sakila
-- Display the first and last names of all actors from the table actor.
SELECT first_name, last_name FROM actor;

-- Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
SELECT CONCAT( first_name, " ", last_name) AS Actor_Name FROM actor

-- You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
SELECT actor_id, first_name, last_name FROM actor WHERE first_name = "Joe";

-- Find all actors whose last name contain the letters GEN:
SELECT * FROM actor WHERE last_name LIKE "%GEN%";

-- Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
SELECT * FROM actor WHERE last_name LIKE "%LI%" ORDER BY last_name, first_name;

-- Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT country_id, country FROM country WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

-- You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table actor named description and use the data type BLOB (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).
ALTER TABLE actor ADD COLUMN description blob not null;

-- Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.
ALTER TABLE actor DROP COLUMN description;
-- SELECT * FROM actor;

-- List the last names of actors, as well as how many actors have that last name.
SELECT last_name AS 'Last Name', COUNT(last_name) AS 'Last Name Counts' FROM actor
GROUP BY last_name;

-- List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT last_name AS 'Last Name', COUNT(*) AS 'Last_Name_Count' FROM actor
GROUP BY last_name
HAVING Last_Name_Count >= 2;

-- The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
UPDATE actor SET first_name = "HARPO"
WHERE first_name = "GROUCHO" and last_name =  "WILLIAMS";
-- SELECT first_name, last_name FROM actor WHERE last_name = "WILLIAMS";

-- Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.
UPDATE actor SET first_name = "GROUCHO"
WHERE first_name = "HARPO" and last_name =  "WILLIAMS";
-- SELECT first_name, last_name FROM actor WHERE last_name = "WILLIAMS";

-- You cannot locate the schema of the address table. Which query would you use to re-create it?
-- Hint: https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html
SHOW CREATE TABLE address;

-- Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
SELECT first_name, last_name, address
FROM staff s LEFT JOIN address a ON s.address_id = a.address_id; 

-- Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
SELECT CONCAT(first_name," ",last_name) AS 'Staff Name', SUM(amount) AS "Total"
FROM payment p LEFT JOIN staff s ON p.staff_id = s.staff_id
WHERE payment_date LIKE "2005-08%"
GROUP BY s.staff_id;

-- List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
SELECT title AS "Film", COUNT(actor_id) AS "Number of Actors"
FROM film f LEFT JOIN film_actor fa ON f.film_id = fa.film_id
GROUP BY f.film_id;

-- How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT COUNT(film_id) FROM inventory
WHERE film_id = (SELECT film_id FROM film WHERE title = "Hunchback Impossible");

-- Using the tables payment and customer and the JOIN command, list the total paid by each customer. 
-- List the customers alphabetically by last name:
SELECT first_name, last_name, SUM(p.amount) AS "Total Paid"
FROM payment p JOIN customer c ON p.customer_id = c.customer_id
GROUP BY first_name, last_name
ORDER BY last_name;

-- The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters K and Q
-- have also soared in popularity. Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
SELECT title FROM film
WHERE (title LIKE "K%" OR title LIKE "Q%") AND language_id = (SELECT language_id FROM language WHERE name = 'English');

-- Use subqueries to display all actors who appear in the film Alone Trip.
SELECT first_name, last_name FROM actor 
WHERE actor_id IN (SELECT actor_id FROM film_actor 
WHERE film_id = (SELECT film_id FROM film 
WHERE title = "Alone Trip"));

-- You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. 
-- Use joins to retrieve this information.
SELECT first_name, last_name, email FROM customer cus
LEFT JOIN address a ON (cus.address_id = a.address_id) 
LEFT JOIN city c ON (a.city_id = c.city_id)
LEFT JOIN country con ON (c.country_id = con.country_id)
WHERE con.country = "Canada";

-- Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
SELECT title FROM film 
WHERE film_id in (SELECT film_id FROM film_category 
WHERE category_id = (SELECT category_id FROM category WHERE name = "Family"));

-- Display the most frequently rented movies in descending order.
SELECT title, COUNT(i.film_id) AS "Counts"
FROM film f JOIN inventory i ON (f.film_id = i.film_id) 
JOIN rental r ON (i.inventory_id=r.inventory_id)
GROUP BY title
ORDER BY Counts DESC;

-- Write a query to display how much business, in dollars, each store brought in.
SELECT s.store_id, SUM(amount)
FROM payment p JOIN staff s ON (p.staff_id = s.staff_id)
GROUP BY s.store_id; 

-- Write a query to display for each store its store ID, city, and country.
SELECT s.store_id, city, country
FROM store s LEFT JOIN address a ON (s.address_id = a.address_id)
JOIN city c ON (c.city_id = a.city_id)
JOIN country co ON (co.country_id = c.country_id);

-- List the top five genres in gross revenue in descending order.
SELECT c.name, SUM(amount) AS "Gross Revenue" 
FROM payment p JOIN rental r ON (p.rental_id = r.rental_id)
JOIN inventory i ON (r.inventory_id = i.inventory_id)
JOIN film_category fc ON (fc.film_id = i.film_id)
JOIN category c ON (c.category_id = fc.category_id)
GROUP BY c.name
ORDER BY SUM(amount) DESC
LIMIT 5;

-- In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue.
-- Use the solution from the problem above to create a view.
CREATE VIEW TOP_5 AS SELECT c.name, SUM(amount) AS "Gross Revenue" 
FROM payment p JOIN rental r ON (p.rental_id = r.rental_id)
JOIN inventory i ON (r.inventory_id = i.inventory_id)
JOIN film_category fc ON (fc.film_id = i.film_id)
JOIN category c ON (c.category_id = fc.category_id)
GROUP BY c.name
ORDER BY SUM(amount) DESC
LIMIT 5;

-- How would you display the view that you created in 8a?
SELECT * FROM TOP_5;

-- You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW TOP_5;
