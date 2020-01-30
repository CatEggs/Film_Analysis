Use Sakila;

/* 1a. Display the first and last names of all actors from the table `actor`.*/
select distinct first_name, Last_name from actor;

/* 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`.*/
select distinct concat(upper(first_name), " ", upper(last_name)) as "Actor Name" from actor;

/* 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What one query would you use to obtain this information?*/
select distinct actor_id, first_name, last_name from actor where first_name = "Joe";

/* 2b. Find all actors whose last name contain the letters `GEN`:*/
select * from actor where last_name like "%GEN%";

/* 2c. Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order:*/
select * from actor where last_name like "%LI%" order by last_name, first_name;

/* 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China:*/
select country_id, country from country where country in ("Afghanistan", "Bangladesh", "China");

/* 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table `actor` named `description` and use the data type `BLOB` (Make sure to research the type `BLOB`, as the difference between it and `VARCHAR` are significant).*/
Alter table actor
Add description blob NULL;

/* 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the `description` column.*/
Alter table actor
drop column description;

/* 4a. List the last names of actors, as well as how many actors have that last name.*/
select distinct last_name, count(last_name) as last_name_count
from actor
group by last_name;

/* 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors*/
select distinct last_name, count(last_name) as last_name_count
from actor
group by last_name
having count(last_name) >= 2;

/* 4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`. Write a query to fix the record.*/
update actor
set first_name = "HARPO"
where first_name = "GROUCHO" and last_name = "WILLIAMS";

/* 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name after all! In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`.*/
update actor
set first_name = "GROUCHO"
where first_name = "HARPO" and last_name = "WILLIAMS";

/* 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?
  * Hint: [https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html](https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html)*/
SELECT COLUMN_NAME 
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = "address";

/* 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`:*/

select first_name, last_name from staff
left join address using(address_id);

/* 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`.*/
select count(a.payment_id) as "total" from payment a
right join staff using(staff_id)
where a.payment_date >= "2005-08-01" and a.payment_date <= "2005-08-31";

/* 6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.*/
select b.title, count(actor_id)  as "total actors"
from film_actor a
inner join film b using(film_id)
group by b.title;

/* 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?*/
select b.title, count(a.inventory_id)  as "total copies"
from inventory a
inner join film b using(film_id)
where b.title = "Hunchback Impossible"
group by b.title;

/* 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. List the customers alphabetically by last name:
  ![Total amount paid](Images/total_payment.png)*/
select a.last_name, sum(b.amount) as "Total Payment"
from customer a
left join payment b using (customer_id)
group by a.last_name
order by a.last_name;

/* 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters `K` and `Q` have also soared in popularity.
 Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English.*/
select sub.title, sub.language 
from
	(select a.title, b.name as "language"
	from film a
	left join language b using(language_id)
	where b.name = "English") as sub
Where sub.title like "K%" or sub.title like "Q%";

/* 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.*/
select * from actor;
select sub.fullname, film.title 
from
	(
    select a.actor_id, b.film_id, concat(a.first_name, " ", a.last_name) as "fullname"
	from actor a
	left join film_actor b using(actor_id)
    ) as sub
left join film using(film_id)
where film.title like "Alone Trip" ;
/* 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.*/
select concat(b.first_name, " ", b.last_name) as fullname, b.email
from customer b
left join address a using(address_id)
where a.city_id in 
    (
		select a.city_id
		from city a
		left join country b using(country_id)
		where country = "Canada"
    );
    
/* 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
Identify all movies categorized as _family_ films.*/
select film.title, sub.category_name
from
	(
    select b.film_id, a.category_id, a.name as "category_name"
	from category a
	left join film_category b using(category_id)
    ) as sub
left join film using(film_id)
where sub.category_name like "Family" ;


/* 7e. Display the most frequently rented movies in descending order.*/
select * from rental;
select sub.title, count(a.rental_id) as "Total Rentals"
from
	(
		select a.title, b.inventory_id
		from film a
		right join inventory b using (film_id)
	) as sub
right join rental a using(inventory_id)
group by sub.title;

/* 7f. Write a query to display how much business, in dollars, each store brought in.*/
select sub.store_id, sum(p.amount) as "Total Revenue"
from
	(
		select b.store_id, a.rental_id
		from inventory b
        left join rental a using(inventory_id)
	) as sub
left join payment p using(rental_id)
group by sub.store_id;

/* 7g. Write a query to display for each store its store ID, city, and country.*/
select b.store_id, sub2.city, sub2.country
from
	(
		select address_id, sub.city, sub.country
		from
		(
			select city_id, city, country
			from city a
			left join country b using(country_id)
		) as sub
        right join address using(city_id)
	) as sub2
right join store b using(address_id);


/* 7h. List the top five genres in gross revenue in descending order. (**Hint**: you may need to use the following tables: category, film_category, inventory, payment, and rental.)*/
select sub3.name as "Genre", sum(f.amount) as "Total Gross Amt"
from
	(
		select d.rental_id, sub2.name
		from
			(
				select c.inventory_id, sub.name
				from
				(
					select a.film_id, b.name
					from film_category a
					left join category b using(category_id)
				) as sub
				left join inventory c using(film_id)
			) as sub2
		left join rental d using(inventory_id)
	) as sub3
left join payment f using(rental_id)
group by sub3.name
order by sum(f.amount) desc
limit 5;

/* 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.*/
Create View top_five_genres as
select sub3.name as "Genre", sum(f.amount) as "Total Gross Amt"
from
	(
		select d.rental_id, sub2.name
		from
			(
				select c.inventory_id, sub.name
				from
				(
					select a.film_id, b.name
					from film_category a
					left join category b using(category_id)
				) as sub
				left join inventory c using(film_id)
			) as sub2
		left join rental d using(inventory_id)
	) as sub3
left join payment f using(rental_id)
group by sub3.name
order by sum(f.amount) desc
limit 5;


/* 8b. How would you display the view that you created in 8a?*/

Select * from top_five_genres;

/* 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.
*/ 
Drop View top_five_genres;