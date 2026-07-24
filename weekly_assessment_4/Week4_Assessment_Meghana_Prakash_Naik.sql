
-- THE UNLOX ACADEMY (Weekly Assessment 4)
-- Joins, Subqueries,Windows & CTEs

-- Section A - Theory

-- A1.  b) INNER JOIN returns only matched rows; LEFT JOIN returns all left-table rows with NULL for non-matches
-- A2. c) Restarts the aggregate calculation for each department while keeping all input rows
-- A3. c) It silently joins on ALL columns with matching names — behaviour can change unexpectedly when the schema is modified
-- A4. b) When the two queries cannot produce overlapping rows, OR when performance matters more than deduplication
-- A5. b) If the subquery inside NOT IN returns any NULL value, the entire NOT IN silently returns zero rows.
-- A6. b) The inner query references a column from the outer query, causing it to re-execute for each outer row
-- A7. b) WHERE runs BEFORE window functions are calculated, so the alias doesn't exist yet
-- A8. b) A named temporary result set defined with the WITH clause, existing only for the duration of the query

-- Section B - Output Prediction

-- B1. How many rows does this query return?
SELECT * FROM books b
INNER JOIN authors a ON b.author_id = a.author_id;
-- answer: Twenty-Five(25) rows

-- B2. How many rows does this query return?
SELECT a.name FROM authors a
LEFT JOIN books b ON a.author_id = b.author_id
WHERE b.book_id IS NULL;
-- answer: zero(0) rows

-- B3. How many rows does this self-join return, and who are they?
SELECT a.name AS author, m.name AS mentor
FROM authors a
JOIN authors m ON a.mentor_id = m.author_id;
-- answer: Three(3) rows

-- B4. How many rows does this UNION return?
SELECT name FROM authors WHERE country = 'India'
UNION
SELECT a.name FROM authors a
JOIN books b ON a.author_id = b.author_id
WHERE b.genre = 'Mythology';
-- answer: Five(5) rows

-- B5. What single value does this query return?
SELECT COUNT(*) FROM books
WHERE price > (SELECT AVG(price) FROM books);
-- answer: 13

-- B6. How many rows does this query return?
SELECT * FROM books b
WHERE NOT EXISTS (
SELECT 1 FROM sales s WHERE s.book_id = b.book_id);
-- answer: Fifteen(15) rows

-- B7. What is the total_qty of the top-selling book (first row)?
SELECT b.title, SUM(s.quantity) AS total_qty
FROM sales s JOIN books b ON s.book_id = b.book_id
GROUP BY b.book_id
ORDER BY total_qty DESC
LIMIT 1;
-- answer: Thirty(30) quantity of the top-selling book which is 'Atomic Habits'

-- B8. What does this query output for Business genre books?
SELECT title, price,
RANK() OVER (PARTITION BY genre ORDER BY price DESC) AS rank_in_genre
FROM books WHERE genre = 'Business';
-- answer: It returns all the business genre books with the rankings of price by descending order 

-- ======================================Section C - Applied SQL======================

-- C1 - Basic Joins (INNER, LEFT, aggregate)

-- C1. Write a query using INNER JOIN to display each book's title alongside its author's name.
-- Your query:
SELECT bk.title AS book_title, au.name AS writer
FROM authors AS au
JOIN books AS bk
ON au.author_id = bk.author_id;

-- C2. Write a LEFT JOIN query listing every author's name and every book they've written.Authors with no books should still appear (once) with NULL for book columns.
-- Your query:
SELECT a.name AS author, b.title AS book_title
FROM authors AS a
LEFT OUTER JOIN books AS b
ON a.author_id = b.author_id;

-- C3. Write a query to compute total revenue (sum of quantity × price) per genre. Sort by revenue descending.
-- Your query:
SELECT b.genre, SUM(b.price * s.quantity) AS total_revenue
FROM books AS b
JOIN sales AS s
USING (book_id)
GROUP BY b.genre
ORDER BY total_revenue DESC;

-- C4. Write a query to find the single city that has generated the most revenue.
-- Your query:
SELECT s.city, SUM(s.quantity * b.price) AS revenue
FROM sales AS s
JOIN books AS b
USING (book_id)
GROUP BY s.city
ORDER BY revenue DESC
LIMIT 1;

-- C2 - Extended Joins (RIGHT, FULL OUTER, SELF)

-- C5. Write a RIGHT JOIN query showing every book (via RIGHT JOIN from authors) alongside its author. Explain briefly why the result count matches INNER JOIN here.
-- Your query:
SELECT a.name AS author_name, b.title
FROM authors AS a
RIGHT JOIN books AS b
USING (author_id);

-- C6. Write a FULL OUTER JOIN of authors and books using the UNION trick (since MySQL doesn't support FULL OUTER directly).
-- Your query:
SELECT a.author_id, a.name, b.title
FROM authors AS a
LEFT JOIN books AS b
       USING (author_id)
UNION
SELECT a.author_id, a.name, b.title
FROM books AS b
RIGHT JOIN authors AS a
USING (author_id);

-- C7. Write a SELF JOIN query showing the name of every mentored author alongside their mentor's name.
-- Your query:
SELECT a1.name AS author, a2.name AS mentor
FROM authors AS a1
JOIN authors AS a2
ON a1.mentor_id = a2.author_id;

-- C3 - Set Operations (CROSS, UNION, anti-join)

-- C8. Write a CROSS JOIN query generating every possible combination of city and customer_type from the sales table (use SELECT DISTINCT subqueries).
-- Your query:
SELECT c.city, ct.customer_type
FROM
(
    SELECT DISTINCT city
    FROM sales
) AS c
CROSS JOIN
(
    SELECT DISTINCT customer_type
    FROM sales
) AS ct;

-- C9. Write a UNION query combining: (a) all Indian authors, (b) all authors born after 1970.Result should be deduplicated.
-- Your query:
SELECT a.name
FROM authors AS a
WHERE a.country = 'India'
UNION
SELECT a.name
FROM authors AS a
WHERE YEAR(a.born_year) > 1970;

-- C10. Write an anti-join query using LEFT JOIN + IS NULL to find all books that have NEVER been sold.
-- Your query:
SELECT b.title
FROM books AS b
LEFT JOIN sales AS s
ON b.book_id = s.book_id
WHERE s.sale_id IS NULL;

-- C4 - Subqueries (scalar, IN, ANY/ALL, correlated)

-- C11. Write a scalar subquery to find all books priced above the overall average book price.
-- Your query:
SELECT title, price
FROM books
WHERE price >
(
    SELECT AVG(price)
    FROM books
);
            
-- C12. Write a query using IN with a subquery to show all sales of books whose genre is either 'History' or 'Mythology'.
-- Your query:
SELECT *
FROM sales AS s
WHERE s.book_id IN
(
    SELECT b.book_id
    FROM books AS b
    WHERE b.genre IN ('History','Mythology')
);

-- C13. Write a query using > ALL to find books priced higher than every single Fiction book.
-- Your query:
SELECT b.title, b.price
FROM books AS b
WHERE b.price > ALL
(
    SELECT price
    FROM books
    WHERE genre = 'Fiction'
);

-- C14. Write a correlated subquery to find books priced above their genre's average price.
-- Your query:
SELECT b1.title, b1.genre, b1.price
FROM books AS b1
WHERE b1.price >
(
    SELECT AVG(b2.price)
    FROM books AS b2
    WHERE b2.genre = b1.genre
);

-- C5 - EXISTS / NOT EXISTS

-- C15. Write an EXISTS query to find all authors who have written at least one book published after 2018.
-- Your query:
SELECT a.name
FROM authors AS a
WHERE EXISTS
(
    SELECT 1
    FROM books AS b
    WHERE b.author_id = a.author_id
      AND YEAR(b.published_year) > 2018
);

-- C16. Write a NOT EXISTS query to find all authors who have never written a book in the 'Business' genre.
-- Your query:
SELECT a.name
FROM authors AS a
WHERE NOT EXISTS
(
    SELECT 1
    FROM books AS b
    WHERE b.author_id = a.author_id
      AND b.genre = 'Business'
);

-- C17. Write a query using IN with a subquery to find all sales made for books written by Indian authors.
-- Your query:
SELECT * FROM sales
WHERE book_id IN
(
    SELECT b.book_id
    FROM books b
    JOIN authors a
    ON b.author_id = a.author_id
    WHERE a.country = 'India'
);

-- C6 - Window Functions (PARTITION, ROW_NUMBER, LAG, running total)

-- C18. Write a query showing every book alongside its genre's average price (using AVG OVER PARTITION BY) - all 25 rows should appear.
-- Your query:
SELECT b.title, b.genre, b.price,
    AVG(b.price) OVER (
        PARTITION BY b.genre
    ) AS genre_avg_price
FROM books AS b;

-- C19. Write a query using ROW_NUMBER to find the top 2 highest-priced books in each genre.
-- Your query:
WITH ranked_books AS
(
    SELECT b.title, b.genre, b.price,
        ROW_NUMBER() OVER
        (
            PARTITION BY b.genre
            ORDER BY b.price DESC
        ) AS row_num
    FROM books AS b
)

SELECT title, genre,price
FROM ranked_books
WHERE row_num <= 2
ORDER BY genre, price DESC;

-- C20. Using LAG, write a query showing each sale of book_id 115 (Atomic Habits) alongside the quantity of the previous sale (sorted by sale_date). 
-- The first sale should show NULL for previous quantity.
-- Your query:
SELECT s.sale_id, s.sale_date, s.quantity,
    LAG(s.quantity) OVER
    (
        ORDER BY s.sale_date
    ) AS previous_quantity
FROM sales AS s
WHERE s.book_id = 115
ORDER BY s.sale_date;

-- C21. Write a query using SUM() OVER (ORDER BY sale_date) to compute a running total of quantity across all sales.
-- Your query:
SELECT s.sale_id, s.sale_date, s.quantity,
    SUM(s.quantity) OVER
    (
        ORDER BY s.sale_date
    ) AS running_quantity
FROM sales AS s
ORDER BY s.sale_date;

-- C7 - CTEs & Synthesis

-- C22. Rewrite this query using a CTE (WITH clause) for readability. Compute total quantity sold per book, then join to book details showing title and total.
-- Your query:
WITH book_totals AS
(
    SELECT s.book_id, SUM(s.quantity) AS total_qty
    FROM sales AS s
    GROUP BY s.book_id
)

SELECT b.title, bt.total_qty
FROM books AS b
INNER JOIN book_totals AS bt
ON b.book_id = bt.book_id;

-- C23. Write a multi-CTE query: first CTE computes revenue per genre, second CTE ranks genres by revenue using RANK(). Final SELECT shows genre, revenue, and rank.
-- Your query:
WITH genre_sales AS
(
    SELECT b.genre, SUM(s.quantity * b.price) AS revenue
    FROM books AS b
    INNER JOIN sales AS s
	ON b.book_id = s.book_id
    GROUP BY b.genre
),

genre_rank AS
(
    SELECT genre, revenue,
	RANK() OVER
	(
		ORDER BY revenue DESC
	) AS revenue_rank
    FROM genre_sales
)

SELECT genre, revenue, revenue_rank
FROM genre_rank;

-- C24. Write a comprehensive query: for each genre, show the top-selling book (by total quantity sold), its author's name, its total quantity, and the genre's
-- total revenue. Use CTEs + window functions + joins. Sort by genre revenue descending.
-- Your query:
WITH book_sales AS
(
    SELECT b.book_id, b.title, b.genre, a.name AS author_name,
	SUM(s.quantity) AS total_qty,
	SUM(s.quantity * b.price) AS book_revenue
    FROM books AS b
    INNER JOIN authors AS a
	ON b.author_id = a.author_id
    INNER JOIN sales AS s
	ON b.book_id = s.book_id
    GROUP BY b.book_id, b.title, b.genre, a.name
),

genre_totals AS
(
    SELECT genre,
	SUM(book_revenue) AS total_genre_revenue
    FROM book_sales
    GROUP BY genre
),

ranked_books AS
(
    SELECT *,
	ROW_NUMBER() OVER
	(
		PARTITION BY genre
		ORDER BY total_qty DESC
	) AS row_num
    FROM book_sales
)

SELECT rb.genre, rb.title, rb.author_name, rb.total_qty, gt.total_genre_revenue
FROM ranked_books AS rb
INNER JOIN genre_totals AS gt
ON rb.genre = gt.genre
WHERE rb.row_num = 1
ORDER BY gt.total_genre_revenue DESC;
