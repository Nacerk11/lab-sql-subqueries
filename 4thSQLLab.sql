-- Use the Sakila database
USE sakila;

-- 1. Determine the number of copies of the film "Hunchback Impossible" in the inventory
SELECT COUNT(*) AS film_copies FROM inventory 
WHERE film_id = (SELECT film_id FROM film WHERE title = 'Hunchback Impossible');

-- 2. List all films whose length is longer than the average length of all films
SELECT title, length FROM film 
WHERE length > (SELECT AVG(length) FROM film);

-- 3. Display all actors who appear in the film "Alone Trip"
SELECT actor_id, first_name, last_name FROM actor
WHERE actor_id IN (
    SELECT actor_id FROM film_actor
    WHERE film_id = (SELECT film_id FROM film WHERE title = 'Alone Trip')
);

-- Bonus
-- 4. Identify all movies categorized as family films
SELECT title FROM film
WHERE film_id IN (
    SELECT film_id FROM film_category
    WHERE category_id = (SELECT category_id FROM category WHERE name = 'Family')
);

-- 5. Retrieve the name and email of customers from Canada using both subqueries and joins
-- Using subquery
SELECT first_name, last_name, email FROM customer
WHERE address_id IN (
    SELECT address_id FROM address
    WHERE city_id IN (
        SELECT city_id FROM city
        WHERE country_id = (SELECT country_id FROM country WHERE country = 'Canada')
    )
);

-- Using JOIN
SELECT c.first_name, c.last_name, c.email FROM customer c
JOIN address a ON c.address_id = a.address_id
JOIN city ci ON a.city_id = ci.city_id
JOIN country co ON ci.country_id = co.country_id
WHERE co.country = 'Canada';

-- 6. Determine which films were starred by the most prolific actor
WITH prolific_actor AS (
    SELECT actor_id FROM film_actor
    GROUP BY actor_id
    ORDER BY COUNT(film_id) DESC
    LIMIT 1
)
SELECT title FROM film
WHERE film_id IN (
    SELECT film_id FROM film_actor
    WHERE actor_id = (SELECT actor_id FROM prolific_actor)
);

-- 7. Find the films rented by the most profitable customer
WITH top_customer AS (
    SELECT customer_id FROM payment
    GROUP BY customer_id
    ORDER BY SUM(amount) DESC
    LIMIT 1
)
SELECT f.title FROM rental r
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON i.film_id = f.film_id
WHERE r.customer_id = (SELECT customer_id FROM top_customer);

-- 8. Retrieve the client_id and total_amount_spent for clients who spent more than the average amount
WITH total_spent AS (
    SELECT customer_id, SUM(amount) AS total_amount FROM payment
    GROUP BY customer_id
)
SELECT customer_id, total_amount FROM total_spent
WHERE total_amount > (SELECT AVG(total_amount) FROM total_spent);