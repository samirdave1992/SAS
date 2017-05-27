

proc import datafile=/** Import an XLSX file.  **/

PROC IMPORT DATAFILE="/folders/myfolders/Copy of Retail_Loan1.xlsx"
		    OUT=WORK.Bank
		    DBMS=XLSX
		    REPLACE;
		    
		    sheet="Application";
RUN;

/*1*/
proc sql;
	SELECT COUNT( Customer_ID)
	FROM work.bank;
quit;

/*2*/
proc sql;
SELECT MONTH(App_date) as Month, sum(loan_amount) as Monthly_Total_Loan_Amount, 
			Sum(loan_amount) / Count(app_id) as Mothnly_Average_Loan_Amount
	FROM work.bank
	GROUP BY month;
quit;


/*3*/

proc sql;
select app_id, customer_id, loan_amount,loan_type, count(1) as customerloan_details
from work.bank
group by customer_id
having count(1)>1;
quit;



/*4*/
proc sql;
select distinct customer_id, (loan_amount/asset_value) as LTV_ratio,
       (loan_amount/asset_value)*100 as Average_LTV_ratio
from work.bank;
quit;

/*5*/
proc sql;
select city, count(1) as loansby_different_cities
from work.bank
group by city
order by loansby_different_cities desc;
quit;



/*6*/
proc sql;
select city,sum(loan_amount) as amount_of_loan
from work.bank
group by city
order by amount_of_loan desc; 
quit;


/*7*/
proc sql;
select city, avg(int((today()-dob)/365.25)) as avg_customer_age format=comma10.2
from work.bank
group by city;
quit;

/*8*/
proc sql;
select loan_type,
	   min(Emplymnt_Length_yrs) as minimum_employment_rate,
	   max(Emplymnt_Length_yrs) as maximun_employment_rate,
	   avg(Emplymnt_Length_yrs) as average_rate format=comma10.2
	   from work.bank
	   group by loan_type;


quit;


/*task 2*/

PROC IMPORT DATAFILE="/folders/myfolders/Copy of Retail_Loan1.xlsx"
		    OUT=WORK.Bank
		    DBMS=XLSX
		    REPLACE;
		    
		    sheet="Application";
RUN;
proc import out= work.doc1
    datafile ="/folders/myfolders/Copy of Retail_Loan1.xlsx"
    dbms = xlsx;
    sheet = 'doc_track';
    getnames = yes;
    run;
    
    
    
proc import out= work.doc2
    datafile ="/folders/myfolders/Copy of Retail_Loan1.xlsx"
    dbms = xlsx;
    sheet = 'doc_ref';
    getnames = yes;
    run;    

/*1*/
proc sql;
select count(distinct customer_id)
from work.doc1 a
inner join work.doc2 b
ON b.doc_code=a.doc_code;
quit;

/*2*/

proc sql;
select Customer_id, a.doc_Code, count(2) as documentcount
from work.doc1 a
inner join work.doc2 b 
on b.doc_code=a.doc_code
group by customer_id
having count(2)>1;

quit;

/*3*/
proc sql;
select distinct customer_id from work.doc1 a
inner join work.doc2 b
on b.doc_code=a.doc_code
where (a.doc_code= 'AP1' or a.doc_code= 'AP2') and 
(a.doc_code= 'IP1' or a.doc_code= 'IP2' or a.doc_code= 'IP3');
quit;

/*4*/
proc sql;
select customer_id from work.doc1 where doc_code in
(
select Doc_code from work.doc2
where document_description='Passport' or document_description='Pay stub');
quit;


/*5*/
proc sql;
select Customer_id, First_Name, City from work.bank
where First_Name like '%J' and (City='Trenton' or City='Jersey') IN 
SELECT customer_id
		FROM work.doc1
		WHERE doc_code IN
			(
				SELECT doc_code
				FROM work.doc2
				WHERE Doc_type = 'Income proof' OR Doc_type = 'Identity proof'
			);

quit;


/*6*/
proc sql;
select customer_id, max(doc_submitted_day) as lastday_submission format=date9.,
min(doc_submitted_day) as firstday format=date9. ,
min(doc_submitted_day)-max(doc_submitted_day) as timelag
from work.doc1
group by customer_id;
quit;

/*7*/
proc sql;
select customer_id, max(doc_submitted_day) as lastday_submission format=date9.,
min(doc_submitted_day) as firstday format=date9. ,
min(doc_submitted_day)-max(doc_submitted_day) as timelag
from work.doc1
group by customer_id;
quit;


/*8*/
proc sql;
select distinct a.Customer_id, App_date as Application_Date format=date9.,
min(doc_Submitted_day) as firstsubmission format=date9.,
(min(doc_submitted_day)-App_date) as number_of_Days from work.bank as a
inner join work.doc1 as b on b.customer_id=a.customer_id
group by a.Customer_id;
quit; 
 
/*9*/
PROC SQL;
	SELECT DISTINCT city, app_date as ApplicationDate Format = date9.,
			MIN(Doc_Submitted_Day) as FirstProofDate Format = date9.,
			(MIN(Doc_Submitted_Day) - app_date) as NumberofDays
	FROM work.bank as a
	INNER JOIN doctrack as b ON b.customer_id = a.customer_id
	GROUP BY city;
QUIT;


/*section 3*/
proc import out= work.doc3
    datafile ="/folders/myfolders/Copy of Retail_Loan1.xlsx"
    dbms = xlsx;
    sheet = 'bank_transactions';
    getnames = yes;
    run;
/*1*/

proc sql;
select customer_id,min(Transaction_date) as Start_date format date9.,
	    max(Transaction_date) as End_date format date9.
from work.doc3
group by Customer_id;

quit;

/*3*/

proc sql;
select distinct customer_id, avg(amount) as Average_amount
from work.doc3
group by customer_id
order by Customer_id;

quit;

/*4*/
proc sql;
select distinct Customer_id, Transaction_date format date9.,
(sum(min(amount),max(amount)/2)) as average from work.doc3;
order by Customer_id;
quit;

/*doubt in 4th and 2nd*/

/*5*/

proc sql;
select distinct customer_id,
				month(transaction_date) as monthlyDate,
				week(transaction_date) as weeklydate,
                count(1) as numberofCount
                from work.doc3 
                where transaction_type='Withdrawl'
                group by customer_id, month(transaction_date)
                ;              
quit;


/*6*/

proc sql;
select distinct customer_id,
				month(transaction_date) as monthlyDate,
				week(transaction_date) as weeklydate,
                count(1) as numberofCount
                from work.doc3 
                where transaction_type='Deposit'
                group by customer_id, month(transaction_date)
                ;              
quit;

/*7*/
proc sql;
select distinct customer_id,
	   month(transaction_date) as monthlydate,
	  sum(amount) as total_amount format dollar8.
	  from work.doc3
	  where transaction_type='Withdrawl'
	  group by customer_id, month(Transaction_date)
      order by customer_id, month(Transaction_date);
quit;













