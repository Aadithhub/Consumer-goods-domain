--  Provide the list of markets in which customer  "Atliq  Exclusive"  operates its business in the  APAC  region. --
 Select market from dim_customer where customer="Atliq Exclusive" and region="APAC";
 
 -- What is the percentage of unique product increase in 2021 vs. 2020? The 
-- final output contains these fields, 
-- unique_products_2020 
-- unique_products_2021 
-- percentage_chg  
with cte1 as(
	Select count(distinct product_code) as unique_products_2021 from fact_sales_monthly where fiscal_year=2021),
    cte2 as(
    Select count(distinct product_code) as unique_products_2020 from fact_sales_monthly where fiscal_year=2020)
    
    Select unique_products_2021,unique_products_2020,(unique_products_2021-unique_products_2020)*100/unique_products_2020 as pct_chg 
    from cte1 cross join  cte2; 
    
 -- Provide a report with all the unique product counts for each  segment  and 
-- sort them in descending order of product counts. The final output contains 
-- 2 fields, 
-- segment 
-- product_count
select segment,count(distinct product_code) as product_count from dim_product 
group by segment order by product_count desc; 

-- Follow-up: Which segment had the most increase in unique products in 
-- 2021 vs 2020? The final output contains these fields, 
-- segment 
-- product_count_2020 
-- product_count_2021 
-- difference 
with unique_product_2021 as(
select  p.segment,count(distinct p.product_code) as product_count_2021 from dim_product p join 
fact_sales_monthly s on p.product_code=s.product_code
where fiscal_year=2021 group by p.segment),
unique_product_2020 as (
select p.segment,count(distinct p.product_code) as product_count_2020 from dim_product p join 
fact_sales_monthly s on p.product_code=s.product_code
where fiscal_year=2020 group by p.segment)
Select u21.segment,product_count_2021,product_count_2020,(product_count_2021-product_count_2020) as difference  from unique_product_2021 u21 join 
unique_product_2020 u20 on u21.segment=u20.segment order by difference desc;

  -- Get the products that have the highest and lowest manufacturing costs. 
-- The final output should contain these fields, 
-- product_code 
-- product 
-- manufacturing_cost
(Select m.product_code,p.product,sum(m.manufacturing_cost) as manufacturing_cost from fact_manufacturing_cost m join 
dim_product p on m.product_code=p.product_code group by m.product_code,p.product order by manufacturing_cost desc limit 1)
union
(Select m.product_code,p.product,sum(m.manufacturing_cost) as manufacturing_cost from fact_manufacturing_cost m join 
dim_product p on m.product_code=p.product_code group by m.product_code,p.product order by manufacturing_cost  limit 1);

-- Generate a report which contains the top 5 customers who received an 
-- average high  pre_invoice_discount_pct  for the  fiscal  year 2021  and in the 
-- Indian  market. The final output contains these fields, 
-- customer_code 
-- customer 
-- average_discount_percentage 
select pre.customer_code,c.customer,Round(avg(pre.pre_invoice_discount_pct)*100,2) as avg_discount_pct from dim_customer c join
fact_pre_invoice_deductions pre on c.customer_code=pre.customer_code where pre.fiscal_year=2021 and c.market="India"
group by pre.customer_code,c.customer order by avg_discount_pct desc limit 5;

 -- Get the complete report of the Gross sales amount for the customer  “Atliq 
-- Exclusive”  for each month  .  This analysis helps to  get an idea of low and 
-- high-performing months and take strategic decisions. 
-- The final report contains these columns: 
-- Month 
-- Year 
-- Gross sales Amount
Select MonthName(s.date) as Month,s.fiscal_year as Year,sum(g.gross_price*s.sold_quantity) as Gross_sales_amt from fact_sales_monthly s join
dim_customer c on s.customer_code=c.customer_code join
fact_gross_price g on s.product_code=g.product_code and s.fiscal_year=g.fiscal_year
where c.customer="Atliq Exclusive" group by Month,Year order by Year asc;

 -- In which quarter of 2020, got the maximum total_sold_quantity? The final 
-- output contains these fields sorted by the total_sold_quantity, 
-- Quarter 
-- total_sold_quantity 
select get_fiscal_quarter(date),sum(sold_quantity) as total_qty from fact_sales_monthly
where fiscal_year=2020 group by get_fiscal_quarter(date) order by total_qty desc ;

-- Which channel helped to bring more gross sales in the fiscal year 2021 
-- and the percentage of contribution?  The final output  contains these fields, 
-- channel 
-- gross_sales_mln 
-- percentage
with cte1 as(
Select c.channel, Round((sum(s.sold_quantity*g.gross_price))/1000000,2) as Gross_sales_mln
from fact_sales_monthly s join dim_customer c on c.customer_code=s.customer_code join
fact_gross_price g on s.product_code=g.product_code /*and s.fiscal_year=g.fiscal_year*/
where s.fiscal_year=2021 group by c.channel)

Select *, Gross_sales_mln *100/sum(Gross_sales_mln) over() as percentage from cte1 order by percentage desc;


-- Get the Top 3 products in each division that have a high 
-- total_sold_quantity in the fiscal_year 2021? The final output contains these 
-- fields, 
-- division 
-- product_code 
-- product 
-- total_sold_quantity 
-- rank_order
with cte1 as (
select p.division,s.product_code,concat(p.product,"(",p.variant,")") as product,sum(s.sold_quantity) as total_sold_qty ,
rank() over(partition by division order by sum(s.sold_quantity) desc) as rank_order
from dim_product p join fact_sales_monthly s on p.product_code=s.product_code
 where s.fiscal_year=2021 group by p.division,s.product_code,p.product)
 
 Select * from cte1 where rank_order in(1,2,3) order by division,rank_order;
