*RFM;

proc import datafile="/folders/myfolders/RFM analysis using transactional data.xlsx"
out=work.samir
dbms=xlsx
replace;
sheet="Transactions";
run;


*splitting the data and the time part;

data split (drop=Transaction_date); 
set work.samir;
Date = datepart(Transaction_date);
Time=timepart(Transaction_date);
format Date date7.;
format Time time8.;
run;

*subsetting the data before june;
data subset;
set split;
var Date
if Date <="30JUN2015"d;
run;


*running RFM;
proc sql;
create table RFM as
   select
     Customer_id,
    min(datdif(Date,today(),'ACT/ACT')) as recency,
    count (Transaction_no) as frequency,
    sum(amount) as monetary_amount from subset
    group by customer_id;
    quit;

***Generate the recency, frequency, monetary score for each customer***;
***For each KPI, we divide our customers into 5 equal groups which
means each custoemr will be assigned a score from 1 to 5 for each
KPI***;
proc rank data= rfm out=grouping1 group=5 descending;
var recency;
ranks Group;
run;

data customer_r;
set grouping1;
recency_score = Group+1;
drop Group;
run;

proc rank data= customer_r out=temp3 group=5;
var frequency;
ranks Group2;
run;

data customer_rf;
set temp3;
frequency_score = Group2+1;
drop Group2;
run;

proc rank data= customer_rf out=temp4 group=5;
var monetary_amount;
ranks Group3;
run;

data customer_rfm;
set temp4;
monetary_score = Group3+1;
drop Group3;
run;


