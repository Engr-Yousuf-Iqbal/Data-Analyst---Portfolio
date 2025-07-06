-------------------------------------------------------------------------------------
								/*Easy Catagory*/
-------------------------------------------------------------------------------------
-- Q1 Who is senior most employee based on jobtitle
select * from employee
order by levels desc
limit 1
--Q2 Which countries have the most invoices?
select count(*) as c, billing_country
from invoice 
group by billing_country
order by c desc
-- Q3 What are top 3 values of total invoice
select total from invoice
order by total desc
limit 3
/* Q4 Which city has the best customers? We would like to throw a promotional Music 
Festival in the city we made the most money. Write a query that returns one city that 
has the highest sum of invoice totals. Return both the city name & sum of all invoice 
totals*/
select billing_city, sum(total) as invoice_total 
from invoice
group by billing_city
order by invoice_total desc
/* Q5 Who is the best customer? The customer who has spent the most money will be 
declared the best customer. Write a query that returns the person who has spent the 
most money */
select customer.customer_id, customer.first_name,customer.last_name, sum(invoice.total) 
as total_spending from customer
join invoice on customer.customer_id=invoice.customer_id
group by customer.customer_id
order by total_spending desc
limit 1
-------------------------------------------------------------------------------------
								/*Moderate Catagory*/
-------------------------------------------------------------------------------------
/* Q1 Write query to return the email, first name, last name, & Genre of all Rock Music 
listeners. Return your list ordered alphabetically by email starting with A*/
select distinct email, first_name, last_name from customer
join invoice on customer.customer_id=invoice.customer_id
join invoice_line on invoice.invoice_id=invoice_line.invoice_id
where track_id in(select track_id from track
join genre on track.genre_id=genre.genre_id
where genre.name like 'Rock')
order by email
/* Q2 Let's invite the artists who have written the most rock music in our dataset. Write a 
query that returns the Artist name and total track count of the top 10 rock bands */
select artist.name, count(track.track_id) as totals from artist
join album on artist.artist_id=album.artist_id
join track on album.album_id=track.album_id
where genre_id='1'
group by artist.name
order by totals desc
limit 10
/* Q3 Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the 
longest songs listed first */
select name, milliseconds from track
where milliseconds > (select avg(milliseconds) as average_track_len from track)
order by milliseconds desc
-------------------------------------------------------------------------------------
								/*Advance Catagory*/
-------------------------------------------------------------------------------------
/* Q1 Find how much amount spent by each customer on artists? Write a query to return 
customer name, artist name and total spent */
with tmpt as (
select artist.artist_id,artist.name,sum(invoice_line.unit_price*invoice_line.quantity) as total_sale
from artist
join album on artist.artist_id=album.artist_id
join track on album.album_id=track.album_id
join invoice_line on track.track_id=invoice_line.track_id
group by 1
order by 3 desc
limit 1
)
-- select * from tmpt
select concat(customer.first_name, customer.last_name) as Cname, tmpt.name,
sum(invoice_line.unit_price*invoice_line.quantity) as spent
from customer
join invoice on customer.customer_id=invoice.customer_id
join invoice_line on invoice.invoice_id=invoice_line.invoice_id
join track on invoice_line.track_id=track.track_id
join album on track.album_id=album.album_id
join tmpt on album.artist_id=tmpt.artist_id
group by 1,2
order by 3 desc

/* Q2 We want to find out the most popular music Genre for each country. We determine the 
most popular genre as the genre with the highest amount of purchases. Write a query 
that returns each country along with the top Genre. For countries where the maximum 
number of purchases is shared return all Genres */
with best_sale as (
select count(invoice_line.quantity) as purchase, customer.country, genre.name, genre.genre_id,
row_number() over(partition by customer.country order by count(invoice_line.quantity) desc) as rowno
from invoice_line
join track on invoice_line.track_id=track.track_id
join genre on track.genre_id=genre.genre_id
join invoice on invoice_line.invoice_id=invoice.invoice_id
join customer on invoice.customer_id=customer.customer_id
group by 2,3,4
order by 2 Asc
)
select * from best_sale where rowno=1
-- Method 2
with recursive best_sale as (
select count(invoice_line.quantity) as purchase, customer.country, genre.name, genre.genre_id
from invoice_line
join track on invoice_line.track_id=track.track_id
join genre on track.genre_id=genre.genre_id
join invoice on invoice_line.invoice_id=invoice.invoice_id
join customer on invoice.customer_id=customer.customer_id
group by 2,3,4
order by 2 Asc
),
max_sale as ( select max(purchase) as maxsale, country
from best_sale
group by 2
order by 2
)
select best_sale.* from best_sale
join max_sale on best_sale.country=max_sale.country
where best_sale.purchase=max_sale.maxsale

/* Q3 Write a query that determines the customer that has spent the most on music for each 
country. Write a query that returns the country along with the top customer and how 
much they spent. For countries where the top amount spent is shared, provide all 
customers who spent this amount */
with recursive overall_sale as (
select customer.country, customer.first_name, sum(invoice.total) as spent
from customer
join invoice on customer.customer_id=invoice.customer_id
group by 1,2
order by 1
),
best_cust as (
select max(spent) as maxs, overall_sale.country
from overall_sale
group by 2
order by 2
)
select overall_sale.* from overall_sale
join best_cust on overall_sale.country=best_cust.country
where overall_sale.spent=best_cust.maxs
