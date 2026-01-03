select * from book;
select * from branch;
select * from employee;
select * from issued_status;
select * from members;
select * from return_status;


##Project Question or Business Problems

#1> CRUD Operation (Creat,Read,Update,Delete)
#Task 1. Create a New Book Record
#Objective "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"
select * from books limit 2;
insert into books values ('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');

#Task 2: Update an Existing Member's Address

select*from members;
update members
set member_address='125 Main St'
where member_id='C101';

#Task 3: Delete a Record from the Issued Status Table
#Objective: Delete the record with issued_id = 'IS104' from the issued_status table.
select*from issued_status;
delete from issued_status
where issued_id='IS121';

#Task 4: Retrieve All Books Issued by a Specific Employee
#Objective: Select all books issued by the employee with emp_id = 'E101'.
select * from books;
select * from issued_status where issued_emp_id='E101';

#Task 5: List Members Who Have Issued More Than One Book
#Objective: Use GROUP BY to find members who have issued more than one book.
select issued_emp_id,count(*) as No_of_Books_issued from issued_status group by issued_emp_id having No_of_Books_issued > 1 order by No_of_Books_issued desc;

##CTAS (Create Tables as select)
#Task 6: Create Summary Tables**: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt
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

##Data analysis and Finding:
#Task 7. **Retrieve All Books in a Specific Category:
select * from books where category='Classic';

#Task 8: Find Total Rental Income by Category:
select category,sum(rental_price) as Total_Revenue_by_Category,count(*) as No_of_books_rented_Category from(
select * from issued_status ist left join books b on ist.issued_book_isbn=b.isbn)as derived_table2 group by category order by Total_Revenue_by_Category desc; 

#Task 9. **List Members Who Registered in the Last 180 Days**:
select * from members where DATEDIFF(CURRENT_DATE, reg_date) <650;


#Task 10: List Employees with Their Branch Manager's Name and their branch details**:
select * from employee;
select * from branch;

select e.*,b.manager_id,e2.emp_name as manager 
from employee e 
left join branch b on e.branch_id=b.branch_id 
join employee e2 on b.manager_id=e2.emp_id;

#Task 11. Create a Table of Books with Rental Price Above a Certain Threshold
Create table Costly_Books as
select * from books where rental_price>7;


#Task 12: Retrieve the List of Books Not Yet Returned
select * from return_status;
select *from issued_status;


select distinct ist.issued_book_name from issued_status ist left join return_status rst on ist.issued_id = rst.issued_id where rst.return_id IS NULL

