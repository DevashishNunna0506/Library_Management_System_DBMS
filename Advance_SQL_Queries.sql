select count(*) from books;
select count(*) from branch;
select count(*) from employee;
select count(*) from issued_status;
select count(*) from members;
select count(*) from return_status;

### Advanced SQL Operations

#Task 13: Identify Members with Overdue Books
#Write a query to identify members who have overdue books (assume a 30-day return period). 
#Display the member's name, book title, issue date, and days overdue.

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

#Task 14: Update Book Status on Return
#Write a query to update the status of books in the books table to "available" 
#when they are returned (based on entries in the return_status table).
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

#Task 15: Branch Performance Report
#Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.
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

#Task 16: CTAS: Create a Table of Active Members
#Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 6 months.
select * from members;
select*from issued_status;

create table active_members
as
select ist.issued_member_id,m.member_name,m.member_address,m.reg_date from issued_status ist 
left join members m on ist.issued_member_id=m.member_id where datediff(current_date,ist.issued_date)<560;

#Task 17: Find Employees with the Most Book Issues Processed
#Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, and their branch.
select *from employee;
select*from issued_status;
select * from branch;
select e.emp_id,e.emp_name,b.*,count(ist.issued_id) as Books_Processed from issued_status ist 
left join employee e on e.emp_id=ist.issued_emp_id left join branch b on b.branch_id=e.branch_id group by e.emp_id order by Books_Processed Desc;


#Task 18: Identify Members Issuing High-Risk Books
#Write a query to identify members who have issued books more than twice with the status "damaged" in the books table. Display the member name, book title, and the number of times they've issued damaged books.    
select * from return_status;
select * from members;
select * from issued_status;

select * from return_status rts left join issued_status ist on ist.issued_id=rts.issued_id 
left join members m on m.member_id=ist.issued_member_id where book_quality='Damaged';

select count(b.isbn) as No_Of_Time_book_Leased,b.isbn,b.book_title,its.issued_emp_id from return_status rts 
left join issued_status its on rts.issued_id=its.issued_id left join books b on b.isbn=its.issued_book_isbn
where rts.book_quality='Damaged'
group by b.isbn,
    b.book_title,
    its.issued_emp_id;
#----Answer---#
select issued_book_isbn,issued_book_isbn,count(issued_book_isbn) as no_of_time_book_leased from issued_status where issued_book_isbn in(
select issued_book_isbn  from issued_status where issued_id 
in (select issued_id from return_status where book_quality='Damaged'))
group by issued_book_isbn
order by no_of_time_book_leased desc;

#Task 19: Stored Procedure
#Objective: Create a stored procedure to manage the status of books in a library system.
    #Description: Write a stored procedure that updates the status of a book based on its issuance or return. 
    #Specifically: If a book is issued, the status should change to 'no'.
    #If a book is returned, the status should change to 'yes'.

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
#Task 20: Create Table As Select (CTAS)
#Objective: Create a CTAS (Create Table As Select) query to identify overdue books and calculate fines.

#Description: Write a CTAS query to create a new table that lists each member and the books they have issued but not returned within 30 days. The table should include:
    #The number of overdue books.
    #The total fines, with each day's fine calculated at $0.50.
    #The number of books issued by each member.
    #The resulting table should show:
    #Member ID
    #Number of overdue books
    #Total fines