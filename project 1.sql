--Section 1: DML (Data Manipulation Language) – 5 Questions

--1. Insert a New Customer Record:Insert a new customer with appropriate details (e.g., first name, last name, email, address, city) into the customer table.

--To insert the new customer country

INSERT INTO country(country,last_update)
VALUES('richmond','now()')

--To insert the new customer city

INSERT INTO city(city,country_id,last_update)
VALUES('richmond',110,'now()')

--To check the new customer city inserted
SELECT *
FROM city
WHERE city_id = 604

--To insert the new customer adress

INSERT INTO address(address,address2,district,city_id,postal_code,phone,last_update)
VALUES('1983single leaf rd','null','virginia',604,16208,7032033333,'now()')

--To check the new customer address inserted

SELECT *
FROM address
WHERE address_id = 607

--To insert the new customer information

Insert Into customer(store_id,first_name,last_name,email,address_id,activebool,create_date,last_update,active)
values(1,'Nahom','Tome','nahom12@gmail.com',607,'true','now()','now()',1);

--To check the new customer inserted
SELECT *
FROM customer
WHERE customer_id =609


--2. Update Customer Email: Update the email address of an existing customer by their customer ID.

--To update the email

UPDATE customer
SET email ='Nahome.24@gmail.com'
WHERE customer_id=609;

--To check the updated email

SELECT *
FROM customer
WHERE customer_id =609

--3. Delete a Rental Record: Delete a rental record from the rental table by specifying the rental ID.

--To delete rental record using rental_id

DELETE FROM rental
WHERE rental_id = 10

--4.Increase Film Rental Duration: Update the rental duration of a specific film in the film table, increasing it by 2 days.

-- To update the rental duration of 'Academy Dinosaur' by 2 days.

UPDATE film
SET rental_duration =rental_duration + 2
WHERE title = 'Academy Dinosaur';

--To check the rental duration of 'Academy Dinosaur'is updated

SELECT *
FROM film
WHERE title='Academy Dinosaur'

--5.Insert a New Film Record: Insert a new film with appropriate details (e.g., title, description, rental rate, length) into the film table.

--To retrives all columns from film table.

SELECT *
FROM film

--To insert a film record of 'Fekere Eskamkaber' with all details.

INSERT INTO film(film_id,title,description,release_year,language_id,rental_duration,rental_rate,length,replacement_cost,rating,last_update,special_features,fulltext)
VALUES(1001,'Fekere Eskamkaber','Romantic love stories',1994,1,5,2.99,120,15.99,'G','Now()','{Trailer,Commentaries}','null');

--To check the new film title 'Fekere Eskamkaber' using its film_id.

SELECT *
FROM film
WHERE film_id =1001

--Section 2: DQL (Data Query Language or Querying for Analysis) – 15 Questions

--1. List All Films: Retrieve a list of all films with their titles, release year, and rental rates.

--To retrive all columns from film table.

SELECT *
FROM film

--To retrive the specific lists of columns from film table.

SELECT title,release_year,rental_rate
FROM film

--2.Find the Most Rented Film: Write a query to find the film that has been rented the most times.

SELECT f.film_id,f.title,count(r.rental_id)AS most_rented  --Counts the number of times each film has been rented.
FROM film f
	JOIN inventory i ON f.film_id =i.film_id
	JOIN rental r ON i.inventory_id =r.inventory_id
GROUP BY f.film_id,f.title
ORDER BY most_rented DESC
LIMIT 1

--3.Find Customers Who Have Never Rented a Movie: Retrieve the list of customers who have never rented any movie.


SELECT c.customer_id,c.first_name,c.last_name, count(r.rental_id) AS never_rented
FROM customer c
LEFT JOIN rental r ON c.customer_id =r.customer_id
WHERE rental_id IS NULL
GROUP BY c.customer_id,c.first_name,c.last_name

--4.Top 5 Actors by Film Count: List the top 5 actors who have appeared in the most films.


 SELECT ac.actor_id,ac.first_name,ac.last_name,count(f.film_id) AS appeared_most
 FROM actor ac
	 JOIN film_actor fa ON ac.actor_id=fa.actor_id
	 JOIN film f ON fa.film_id =f.film_id
 GROUP BY ac.actor_id, ac.first_name,ac.last_name
 ORDER BY appeared_most DESC
 LIMIT 5
 
--5.Total Revenue by Film: Calculate the total revenue generated by each film based on its rental rates and rental history.

SELECT f.film_id,
	f.title ,
	SUM(amount) AS total_revenue
FROM film f
	JOIN inventory inv ON f.film_id =inv.film_id
	JOIN rental re ON inv.inventory_id = re.inventory_id
	JOIN payment pa ON re.rental_id = pa.rental_id
GROUP BY f.film_id,f.title
ORDER BY total_revenue DESC;

--6.Average Rental Duration per Category: Find the average rental duration for films in each category.

SELECT ca.name,round(AVG(rental_duration),2) AS AVG_rental_duration
FROM category ca
JOIN film_category fc ON ca.category_id =fc.category_id
JOIN film f ON fc.film_id = f.film_id
GROUP BY ca.name
ORDER BY AVG_rental_duration DESC;


--7.Customers with Most Rentals: Retrieve the top 10 customers who have rented the most films.

SELECT c.customer_id,c.first_name,c.last_name, COUNT(r.rental_id) AS most_rentals
FROM customer c
JOIN rental r ON c.customer_id =r.customer_id
GROUP BY c.customer_id,c.first_name,c.last_name
ORDER BY most_rentals DESC
LIMIT 10


--8.Films Not Rented in the Last 6 Months: List all films that have not been rented in the last 6 months.

--To retrieve the most recent rental date from the rental table

SELECT MAX(rental_date)
FROM rental

-- To retrieves films and their rental dates that haven't been rented in the past six months or were never rented.

SELECT DISTINCT f.film_id, f.title,r.rental_date
FROM film f
JOIN inventory inv ON f.film_id = inv.film_id
LEFT JOIN rental r ON inv.inventory_id = r.inventory_id
WHERE r.rental_date <= (SELECT MAX(rental_date) FROM rental) - INTERVAL '6 MONTH' 
      OR r.rental_id IS NULL;

-- Or to add the 'time_since_last_rental' column with age function.

SELECT DISTINCT f.film_id, f.title,r.rental_date,
AGE((SELECT MAX(rental_date) FROM rental), r.rental_date) AS time_since_last_rental--calculates the interval between the last rental date and each film’s rental_date.
FROM film f
     JOIN inventory inv ON f.film_id = inv.film_id
     LEFT JOIN rental r ON inv.inventory_id = r.inventory_id
WHERE AGE((SELECT MAX(rental_date) FROM rental), r.rental_date) >= INTERVAL '6 months' OR r.rental_id IS NULL; --to ensure it's within 6 months of the last rental date and films that haven’t been rented at all.


--9.Revenue by Store: Calculate the total rental revenue generated by each store.

SELECT s.store_id,SUM(pa.amount)AS total_rental_revenue
FROM store s
    JOIN staff st ON s.store_id =st.store_id
    JOIN payment pa ON st.staff_id =pa.staff_id
GROUP BY s.store_id;

--10.Longest Rental Period: Find the longest rental period for any film.

SELECT MAX(return_date -rental_date)AS longest_rental_period
FROM rental r
JOIN inventory inv ON r.inventory_id =inv.inventory_id


--11.Customers Renting in Multiple Stores: List customers who have rented from both store locations.

SELECT cu.customer_id,cu.first_name,cu.last_name, COUNT(DISTINCT s.store_id)AS rented_both_stores
FROM customer cu
	JOIN rental r ON cu.customer_id = r.customer_id
	JOIN inventory inv ON r.inventory_id = inv.inventory_id
	JOIN staff st ON r.staff_id = st.staff_id
	JOIN store s ON st.store_id = s.store_id
GROUP BY cu.customer_id,cu.first_name,cu.last_name
HAVING COUNT(DISTINCT s.store_id)>1


--12.Films Rented More Than 5 Times: Retrieve a list of films that have been rented more than 5 times.

SELECT f.film_id,f.title, COUNT(r.rental_id) AS total_rentals
FROM film f
JOIN inventory inv ON f.film_id = inv.film_id
JOIN rental r ON inv.inventory_id =r.inventory_id
GROUP BY f.film_id,f.title
HAVING COUNT(r.rental_id) >5
ORDER BY total_rentals DESC

--13.Total Number of Rentals per Category: For each film category, count the total number of rentals.

SELECT ca.category_id,ca.name,COUNT(r.rental_id) AS total_rentals
FROM category ca
JOIN film_category fc ON ca.category_id = fc.category_id
JOIN film f ON fc.film_id =f.film_id
JOIN inventory inv ON f.film_id =inv.film_id
JOIN rental r ON inv.inventory_id =r.inventory_id
GROUP BY ca.category_id,ca.name
ORDER BY total_rentals DESC


--14.Customers Renting the Same Film Multiple Times: Find customers who have rented the same film more than once.

SELECT cu.customer_id,f.title, cu.first_name,cu.last_name,COUNT(r.rental_id) AS renting_multiple_times
FROM customer cu
	JOIN rental r ON cu.customer_id = r.customer_id
	JOIN inventory inv ON r.inventory_id =inv.inventory_id
	JOIN film f ON inv.film_id = f.film_id
GROUP BY cu.customer_id,f.title, cu.first_name,cu.last_name
HAVING COUNT(r.rental_id)>1
ORDER BY renting_multiple_times  


--15.Actors Who Have Not Appeared in Any Film: List actors from the actor table who have not appeared in any film.

SELECT ac.actor_id,ac.first_name, ac.last_name
FROM actor ac
LEFT JOIN film_actor fa ON ac.actor_id = fa.actor_id
WHERE fa.actor_id IS NULL
