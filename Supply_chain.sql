CREATE DATABASE supply_chain;
USE supply_chain;
CREATE TABLE orders (
    Order_ID INT PRIMARY KEY,
    Order_Date DATE,
    Product_ID VARCHAR(10),
    Warehouse_ID VARCHAR(10),
    Supplier_ID VARCHAR(10),
    Customer_City VARCHAR(50),
    Category VARCHAR(50),
    Product_Name VARCHAR(100),
    Quantity INT,
    Unit_Price DECIMAL(10,2),
    Revenue DECIMAL(12,2),
    Shipping_Cost DECIMAL(10,2),
    Delivery_Days INT,
    Order_Status VARCHAR(20),
    Payment_Method VARCHAR(30)
);

CREATE TABLE inventory (
    Product_ID VARCHAR(10),
    Warehouse_ID VARCHAR(10),
    Supplier_Name VARCHAR(100),
    Stock_Available INT,
    Reorder_Level INT,
    Lead_Time_Days INT,
    Unit_Cost DECIMAL(10,2),
    Inventory_Value DECIMAL(12,2),
    Lead_time_outliers VARCHAR(20),
    stock_outlier VARCHAR(20),
    PRIMARY KEY (Product_ID)
);

LOAD DATA LOCAL INFILE 'E:\\Mock\\Supply chain\\SQL\\Supply chain - Orders.csv'
INTO TABLE orders
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'E:/Mock/Supply chain/SQL/Supply chain - Inventory.csv'
INTO TABLE inventory
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;


#Warehouse Performance Analysis
select Warehouse_ID,sum(Revenue) as Total_revenue
from orders
group by Warehouse_ID
order by Total_revenue desc
limit 3;

#Inventory Replenishment Analysis
select Product_ID
from inventory
where Stock_Available < Reorder_Level;

#Supplier Performance
select Supplier_Name,sum(Inventory_Value) as Total_inventory_value
from inventory
group by Supplier_Name
order by Total_inventory_value desc;

#Customer Delivery Analysis
select Customer_City,avg(Delivery_Days) as average_delivery_days
from orders
group by Customer_City
order by average_delivery_days desc;

#Top 5 selling products
select Product_ID,sum(Revenue) as total_revenue
from orders 
group by Product_ID
order by total_revenue desc
limit 5;

#Warehouse Revenue Ranking
select Warehouse_ID,sum(Revenue) as total_revnue,rank()
over(order by sum(Revenue) desc) as rnk
from orders
group by Warehouse_ID;

#Top Products in Each Warehouse
select Warehouse_ID,Product_ID,Revenue,row_number()
over(partition by Warehouse_ID order by Revenue desc) as rnk
from orders;

#Executive Supply Chain Report
with supply_chain_report as (
select	i.Warehouse_ID,sum(w.Revenue) as warehouse_revenue,avg(w.Delivery_Days) as average_delivery_days
from inventory i
join orders w
on i.Warehouse_ID=w.Warehouse_ID
group by i.Warehouse_ID)
select Warehouse_ID,warehouse_revenue,average_delivery_days,rank() over(order by warehouse_revenue desc) as rnk from supply_chain_report;


