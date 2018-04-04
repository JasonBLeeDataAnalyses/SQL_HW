USE sakila;

-- 1a. Display first/last names of all actors from table 'actor'
SELECT first_name, last_name
FROM actor;

-- 1b. Display first/last names of each actor in a single column in UPPERCASE. Name it 'Actor Name'
SELECT concat(upper(first_name), ' ', upper(last_name)) AS `Actor Name`
FROM actor;

-- 2a. Find ID Num, first/last actor name, where first name 'Joe.'
SELECT actor_id, concat(upper(first_name), ' ', upper(last_name)) AS `Actor Name`
FROM actor
WHERE first_name like 'Joe';

-- 2b. Find all actors whose last name contain 'GEN'
SELECT concat(upper(first_name), ' ', upper(last_name)) AS `Actor Name`
FROM actor
WHERE last_name LIKE '%GEN%';

-- 2c. Find all actors with last name containing 'LI' order rows by LN then FN
SELECT concat(upper(first_name), ' ', upper(last_name)) AS `Actor Name`
FROM actor
WHERE last_name LIKE '%LI%'
ORDER BY last_name, first_name;

-- 2d. Using 'IN', display 'country_id' and 'country' cols of: Afghanistan, Bangladesh, and China
SELECT country_id, country
FROM country
WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

-- 3a. Add 'middle_name' column to table 'actor'. Position between 'first_name' & 'last_name'.
ALTER TABLE actor
ADD COLUMN middle_name varchar(45) AFTER first_name;

-- 3b. Change data type of 'middle_name' column to 'blobs'
ALTER TABLE actor
MODIFY COLUMN middle_name blob;

-- 3c. Delete 'middle_name' column
ALTER TABLE actor
DROP COLUMN middle_name;

-- 4a. List last names of actors; include how many actors have that last name
SELECT last_name, COUNT(*) AS cnt
FROM actor
GROUP BY last_name;

-- 4b. List last names of actors and # of actors with that last name,
-- but only for names shared by at least 2 actors.
SELECT last_name, COUNT(*) AS cnt
FROM actor
GROUP BY last_name
HAVING cnt > 1; 

-- 4c. Fix 'GROUCHO WILLIAMS' to 'HARPO WILLIAMS' in actor table
UPDATE actor 
SET first_name = 'HARPO' 
WHERE first_name = 'GROUCHO' AND last_name = 'WILLIAMS';

-- 4d. Fix 'HARPO' to 'GROUCHO' else change to 'MUCHO GROUCHO'
UPDATE actor
SET first_name =
CASE WHEN first_name = 'HARPO' THEN 'GROUCHO'
ELSE 'MUCHO GROUCHO' END
WHERE actor_id = 172;

-- 5a. Cannot locate schema of 'address' table. How to re-create it?
SHOW CREATE TABLE address;

-- 6a. Use 'JOIN' to display first_name, last_name, address of staff member. 
-- Use 'staff' & 'address' tables.
SELECT first_name, last_name, address
FROM staff
JOIN address
	ON staff.address_id = address.address_id;
    
-- 6b. Use 'JOIN' to show total revenue by each staff in Aug 2005. Use 'staff' & 'payment'
SELECT first_name, last_name, sum(amount)
FROM staff stff
LEFT OUTER JOIN payment pmt
	ON stff.staff_id = pmt.staff_id
WHERE payment_date BETWEEN '2005-08-01' AND '2005-08-30'
GROUP BY first_name, last_name;

-- 6c. List each film and # of actors listed per film. Use INNER JOIN 'film_actor' & 'film'
SELECT title, count(*) AS actor_count
FROM film f
INNER JOIN film_actor fa
	ON f.film_id = fa.film_id
GROUP BY title;

-- 6d. How many copies of 'Hunchback Impossible' exist in inventory system?
SELECT title, count(*) AS film_inventory
FROM film f
INNER JOIN inventory i
	ON f.film_id = i.film_id
WHERE title = 'HUNCHBACK IMPOSSIBLE'
GROUP BY title;

-- 6e. Using tables 'payment' and 'customer' and 'JOIN' command,
-- list total paid by each customer, order by customer last name.
SELECT cust.last_name, cust.first_name, sum(pmt.amount) AS tot_payment
FROM customer cust
JOIN payment pmt
	ON cust.customer_id = pmt.customer_id
GROUP BY last_name, first_name
ORDER BY last_name, first_name;

-- 7a. Use subqueries to display the titles of movies starting with 'K' and 'Q' language is English.
SELECT f.title
FROM film f
WHERE f.language_id = (SELECT language_id FROM language WHERE name = 'English')
	AND (f.title LIKE 'K%' OR f.title LIKE 'Q%');
    
-- 7b. Use subqueries to show all actors who appear in 'Alone Trip'
SELECT a.first_name, a.last_name
FROM actor a
JOIN (SELECT fa.actor_id FROM film_actor fa WHERE fa.film_id	= 
		(SELECT f.film_id FROM film f WHERE f.title = 'ALONE TRIP')
	) b
    ON a.actor_id = b.actor_id;
    
-- 7c. Retrieve names & e-mail of all Canadian customers.
SELECT first_name, last_name, email
FROM customer a
JOIN (SELECT address_id FROM address WHERE city_id IN
		(SELECT city_id FROM city WHERE country_id = 
			(SELECT country_id FROM country WHERE country = 'Canada')
		)
	) b
    ON a.address_id = b.address_id;

-- 7d. Identify all movies categorized as family films.
SELECT film.film_id, title, release_year
FROM film
JOIN (SELECT film_id FROM film_category 
					WHERE category_id = (SELECT category_id FROM category WHERE name = 'Family')) categ
	ON film.film_id = categ.film_id;

-- 7e. Display most freq rented movies in desc order.
SELECT title, count(*) AS rental_cnt
FROM film a 
JOIN inventory b
	ON a.film_id = b.film_id
JOIN rental c
	ON b.inventory_id = c.inventory_id
GROUP BY title
ORDER BY rental_cnt DESC;

-- 7f. Total revenue per store
SELECT a.store_id, addr.address, sum(d.amount) tot_revenue
FROM store a
JOIN address addr
	ON a.address_id = addr.address_id
JOIN staff c
	ON c.store_id = a.store_id
JOIN payment d
	ON c.staff_id = d.staff_id
GROUP BY store_id, address;

-- 7g. Display for each store its store ID, city and Country
SELECT a.store_id, addr.address, b.city, c.country
FROM store a
JOIN address addr
	ON a.address_id = addr.address_id
JOIN city b
	ON addr.city_id = b.city_id
JOIN country c
	ON b.country_id = c.country_id;
 
 -- 7h. List top 5 genres in gross revenue in desc order.
SELECT e.name genre, sum(a.amount) gross_revenue
FROM payment a
JOIN rental b
	ON a.rental_id = b.rental_id
JOIN inventory c
	ON b.inventory_id = c.inventory_id
JOIN film_category d
	ON c.film_id = d.film_id
JOIN category e
	ON d.category_id = e.category_id
GROUP BY e.name
ORDER BY gross_revenue DESC
LIMIT 5;

-- 8a. Create a view of the table above
CREATE VIEW top_five_genres AS
SELECT e.name genre, sum(a.amount) gross_revenue
FROM payment a
JOIN rental b
	ON a.rental_id = b.rental_id
JOIN inventory c
	ON b.inventory_id = c.inventory_id
JOIN film_category d
	ON c.film_id = d.film_id
JOIN category e
	ON d.category_id = e.category_id
GROUP BY e.name
ORDER BY gross_revenue DESC
LIMIT 5;

-- 8b. Display above view
SELECT * FROM top_five_genres;

-- 8c. Delete view
DROP VIEW top_five_genres;