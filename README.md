# Library Management System using SQL Project --P2

## Project Overview

**Project Title**: Library Management System  
**Level**: Intermediate  
**Database**: `library_dbms`

This project demonstrates the implementation of a Library Management System using SQL. It includes creating and managing tables, performing CRUD operations, and executing advanced SQL queries. The goal is to showcase skills in database design, manipulation, and querying.

![Library_project](https://github.com/DEvashishNunna0506/Library_Management_System_DBMS/blob/main/library_management.jpg)


## Objectives

1. **Set up the Library Management System Database**: Create and populate the database with tables for branches, employees, members, books, issued status, and return status.
2. **CRUD Operations**: Perform Create, Read, Update, and Delete operations on the data.
3. **CTAS (Create Table As Select)**: Utilize CTAS to create new tables based on query results.
4. **Advanced SQL Queries**: Develop complex queries to analyze and retrieve specific data.

## Project Structure

### 1. Database Setup
![ERD](https://github.com/DevashishNunna0506/Library_Management_System_DBMS/blob/main/ERD_Schema.png)

- **Database Creation**: Created a database named `library_db`.
- **Table Creation**: Created tables for branches, employees, members, books, issued status, and return status. Each table includes relevant columns and relationships.

```sql
show databases;
create database library_dbms;
USE library_dbms;
#Create table 
create table branch
(
	branch_id	varchar(10) primary key,
	manager_id	varchar(10),
	branch_address	varchar(55),
	contact_no varchar(15)
);

create table employee
(
	emp_id varchar(10) primary key,	
	emp_name varchar(25),	
	position varchar(15),	
	salary int,	
	branch_id varchar(25)
);

create table books
(
            isbn	varchar(20) primary key,
            book_title	varchar(75),
            category	varchar(10),
            rental_price	float,
            status_book	varchar(15),
            author	varchar(35),
            publisher varchar(55)
);

ALTER TABLE books
MODIFY COLUMN category VARCHAR(30);

create table members
(
            member_id	varchar(10) primary key,
            member_name	varchar(25),
            member_address	varchar(75),
            reg_date date
);
create table issued_status
(
            issued_id varchar(10) primary key,	
            issued_member_id	varchar(10),
            issued_book_name	varchar(75),
            issued_date	 date,
            issued_book_isbn  varchar(25),	
            issued_emp_id varchar(10)
);

create table return_status
(
            return_id	varchar(10) primary key,
            issued_id	varchar(10),
            return_book_name	varchar(75),
            return_date	date,
            return_book_isbn varchar(20)
);

```

### 2. CRUD Operations

- **Create**: Inserted sample records into the `books` table.
- **Read**: Retrieved and displayed data from various tables.
- **Update**: Updated records in the `employees` table.
- **Delete**: Removed records from the `members` table as needed.

**Task 1. Create a New Book Record**
-- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

```sql
select * from books limit 2;
insert into books values ('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');

```
**Task 2: Update an Existing Member's Address**

```sql
select*from members;
update members
set member_address='125 Main St'
where member_id='C101';
```

**Task 3: Delete a Record from the Issued Status Table**
-- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.

```sql
select*from issued_status;
delete from issued_status
where issued_id='IS121';
```

**Task 4: Retrieve All Books Issued by a Specific Employee**
-- Objective: Select all books issued by the employee with emp_id = 'E101'.
```sql
select * from books;
select * from issued_status where issued_emp_id='E101';
```


**Task 5: List Members Who Have Issued More Than One Book**
-- Objective: Use GROUP BY to find members who have issued more than one book.

```sql
select issued_emp_id,count(*) as No_of_Books_issued
from issued_status group by issued_emp_id
having No_of_Books_issued > 1
order by No_of_Books_issued desc;

```

### 3. CTAS (Create Table As Select)

- **Task 6: Create Summary Tables**: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**

```sql
CREATE table Books_in_Demand
AS
select isbn,book_title,count(issued_id) as No_of_Time_Book_Taken 
from
(
select * from 
books b 
left join issued_status ist on b.isbn=ist.issued_book_isbn
) as joined_table1 
group by isbn,book_title 
order by No_of_Time_Book_Taken desc;

select issued_book_isbn,count(*) as No_of_Times_book_issued from issued_status group by issued_book_isbn order by No_of_Times_book_issued desc;

```


### 4. Data Analysis & Findings

The following SQL queries were used to address specific questions:

Task 7. **Retrieve All Books in a Specific Category**:

```sql
select * from books where category='Classic';
```

8. **Task 8: Find Total Rental Income by Category**:

```sql
select category,sum(rental_price) as Total_Revenue_by_Category,count(*) as No_of_books_rented_Category from(
select * from issued_status ist left join books b on ist.issued_book_isbn=b.isbn)as derived_table2 group by category order by Total_Revenue_by_Category desc; 

```

9. **List Members Who Registered in the Last 180 Days**:
```sql
select * from members where DATEDIFF(CURRENT_DATE, reg_date) <650;

```

10. **List Employees with Their Branch Manager's Name and their branch details**:

```sql
select * from employee;
select * from branch;

select e.*,b.manager_id,e2.emp_name as manager 
from employee e 
left join branch b on e.branch_id=b.branch_id 
join employee e2 on b.manager_id=e2.emp_id;

```

Task 11. **Create a Table of Books with Rental Price Above a Certain Threshold**:
```sql
Create table Costly_Books as
select * from books where rental_price>7;
```

Task 12: **Retrieve the List of Books Not Yet Returned**
```sql
select * from return_status;
select *from issued_status;


select distinct ist.issued_book_name from issued_status ist left join return_status rst on ist.issued_id = rst.issued_id where rst.return_id IS NULL

```

## Advanced SQL Operations

**Task 13: Identify Members with Overdue Books**  
Write a query to identify members who have overdue books (assume a 30-day return period). Display the member's_id, member's name, book title, issue date, and days overdue.

```sql
select issued_book_name,issued_date,overdue,issued_member_id from(
select ist.issued_book_name,ist.issued_date,datediff(curdate(),issued_date) as overdue,rst.return_id,ist.issued_member_id 
from issued_status ist left join return_status rst on ist.issued_id=rst.issued_id)as dt4
where return_id is null and overdue > 366;

select member_name,issued_book_name as Book_Title,issued_date,overdue from(
select ist.issued_book_name,ist.issued_date,datediff(curdate(),issued_date) as overdue,rst.return_id,m1.member_name 
from issued_status ist left join return_status rst on ist.issued_id=rst.issued_id
left join members m1 on ist.issued_member_id=m1.member_id)as dt4
where return_id is null and overdue > 366;

SELECT issued_book_name, issued_date, overdue
FROM (
  SELECT
    ist.issued_book_name,
    ist.issued_date,
    DATEDIFF(CURDATE(), ist.issued_date) AS overdue,
    rst.return_id
  FROM issued_status ist
  LEFT JOIN return_status rst
    ON ist.issued_id = rst.issued_id
) AS derived_table4
WHERE return_id IS NULL
  AND overdue > 366;
```


**Task 14: Update Book Status on Return**  
Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table).


```sql

select * from books;
select * from return_status;
select * from issued_status;

#return_table<->update book (Manually, Stored Procedures)
#Method 1: Manually
select * from return_status; # see which books have been returned
select * from issued_status; #see which books are in issued_state '978-0-451-52994-2'
select * from books where isbn='978-0-451-52994-2';

UPDATE books
SET status_book='no'
WHERE isbn='978-0-451-52994-2';

select * from issued_Status where issued_book_isbn='978-0-451-52994-2';
select * from return_status where issued_id='IS130';
#So far we conformed a book with isbn 978-0-451-52994-2 is not available 
#and is not yet returned after it's been issued to a customer

#Now lets say the customer returned the book and we need to update the status to avaialble

Insert into return_status(return_id,issued_id,return_date,book_quality)
Values('RS125','IS130',CURRENT_DATE,'Good');
select* from return_status where return_id='RS125';

UPDATE BOOKS
SET status_book='yes'
WHERE isbn='978-0-451-52994-2';

###Method 2 Stored_Procedures
DELIMITER $$ 
CREATE PROCEDURE update_book_status(p_return_id varchar(10),p_issued_id varchar(10),p_book_quality varchar(15))

BEGIN
#All logic here
	declare v_isbn varchar(20);
    #Insert into return_status table based on the book entry
    INSERT INTO return_status(return_id,issued_id,return_date,book_quality)
    values(p_return_id,p_issued_id,current_date,p_book_quality);
    #Update the book status
    select issued_book_isbn into v_isbn 
    from issued_status 
    where issued_id=p_issued_id;
    
    UPDATE books 
    SET status_book='yes'
    WHERE isbn=v_isbn;
	
END$$
DELIMITER ;
CALL update_book_status('RS138','IS135','Good');


select * from books where isbn='978-0-307-58837-1';
select * from issued_status where issued_book_isbn='978-0-307-58837-1';
select * from return_status where issued_id='IS135';
#customer returned the book, so enter the record in return_status,plus change the book_status to 'yes'
CALL update_book_status('RS138','IS135','Good');


select * from issued_status where issued_book_isbn='978-0-375-41398-8';
select * from return_status where issued_id='IS134';
select * from books where isbn='978-0-375-41398-8';

call update_book_status('RS139','IS134','Bad');

```




**Task 15: Branch Performance Report**  
Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.

```sql
select * from branch;
select*from books;
select * from issued_Status;
select*from employee;
select*from return_status;
create table Branch_Report
As(
select b.branch_id as Branch_ID,b.manager_id, sum(bo.rental_price) Total_Revenue,count(ist.issued_id) as No_of_Books_Sold,count(rts.return_id) from issued_Status ist left join employee e on ist.issued_emp_id=e.emp_id left join branch b on e.branch_id=b.branch_id left join books bo on bo.isbn=ist.issued_book_isbn
left join return_status rts on rts.issued_id=ist.issued_id group by b.branch_id,b.manager_id order by Total_Revenue Desc
);

```

**Task 16: CTAS: Create a Table of Active Members**  
Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 2 months.

```sql


select * from members;
select*from issued_status;

create table active_members
as
select ist.issued_member_id,m.member_name,m.member_address,m.reg_date from issued_status ist 
left join members m on ist.issued_member_id=m.member_id where datediff(current_date,ist.issued_date)<560;

```


**Task 17: Find Employees with the Most Book Issues Processed**  
Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, and their branch.

```sql
select *from employee;
select*from issued_status;
select * from branch;
select e.emp_id,e.emp_name,b.*,count(ist.issued_id) as Books_Processed from issued_status ist 
left join employee e on e.emp_id=ist.issued_emp_id left join branch b on b.branch_id=e.branch_id group by e.emp_id order by Books_Processed Desc;
```

**Task 18: Identify Members Issuing High-Risk Books**  
Write a query to identify members who have issued books more than twice with the status "damaged" in the books table. Display the member name, book title, and the number of times they've issued damaged books.    
```sql
select issued_book_isbn,issued_book_isbn,count(issued_book_isbn) as no_of_time_book_leased from issued_status where issued_book_isbn in(
select issued_book_isbn  from issued_status where issued_id 
in (select issued_id from return_status where book_quality='Damaged'))
group by issued_book_isbn
order by no_of_time_book_leased desc;
```
**Task 19: Stored Procedure**
Objective:
Create a stored procedure to manage the status of books in a library system.
Description:
Write a stored procedure that updates the status of a book in the library based on its issuance. The procedure should function as follows:
The stored procedure should take the book_id as an input parameter.
The procedure should first check if the book is available (status = 'yes').
If the book is available, it should be issued, and the status in the books table should be updated to 'no'.
If the book is not available (status = 'no'), the procedure should return an error message indicating that the book is currently not available.

```sql


select*from books;
select * from issued_status;


DELIMITER $$
Create Procedure return_procedure(p_issued_id varchar(10),p_issued_member_id varchar(10),p_issued_book_isbn varchar(25),p_issued_emp_id varchar(10))
BEGIN
	declare v_status varchar(10);
	#-----if yes in issued status
	select status_book into v_status
	from books where isbn=p_issued_book_isbn;
    
    if v_status='yes' then
    insert into issued_status(issued_id,issued_member_id,issued_date,issued_book_isbn,issued_emp_id)
    values(p_issued_id,p_issued_member_id,current_date,p_issued_book_isbn,p_issued_emp_id);
    UPDATE books
    set status_book='no'
    where isbn=p_issued_book_isbn;
    SELECT 'Book issued successfully' AS message;

    ELSE
        SELECT 'Book is not available for issue' AS message;
    END IF;
    
    
END$$
DELIMITER ;

call return_procedure('IS155','C108','978-0-553-29698-2','E104');

call return_procedure('IS156','C108','978-0-375-41398','E104');

```


## Reports

- **Database Schema**: Detailed table structures and relationships.
- **Data Analysis**: Insights into book categories, employee salaries, member registration trends, and issued books.
- **Summary Reports**: Aggregated data on high-demand books and employee performance.

## Conclusion

This project demonstrates the application of SQL skills in creating and managing a library management system. It includes database setup, data manipulation, and advanced querying, providing a solid foundation for data management and analysis.

## How to Use

1. **Clone the Repository**: Clone this repository to your local machine.
   ```sh
   git clone https://github.com/DevashishNunna0506/Library_Management_System_DBMS.git
   ```

2. **Set Up the Database**: Execute the SQL scripts in the `Creat_table_Constraint.sql` file to create and populate the database.
3. **Run the Queries**: Use the SQL queries in the `SQL_Query_Part-1.sql` and `Advance_SQL_Queries.sql` file to perform the analysis.

## Author - Devashish Nunna
Thank you for your interest in this project!
