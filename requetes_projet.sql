USE mintclassics;

--- products sold ---
select p.productCode, p.productName, p.quantityInStock, SUM(od.quantityOrdered) as totalSales 
from products as p
join orderdetails as od on od.productCode = p.productCode
group by p.productCode, p.productName, p.quantityInStock;

--- Inventory in stock after sales --- 
select productCode, productName, quantityInStock, SUM(quantityInStock - totalSales) as inventoryRemaining
from 
     (select p.productCode, p.productName, p.quantityInStock, SUM(od.quantityOrdered) as totalSales 
      from products as p
      join orderdetails as od on od.productCode = p.productCode
      group by p.productCode, p.productName, p.quantityInStock
     ) as inventory
where (quantityInStock - totalSales) > 0
group by productCode, productName, quantityInStock
order by inventoryremaining desc;

--- operations in warehouses

select w.warehouseCode, w.warehouseName, SUM(p.quantityInStock) as unitsStored
from warehouses as w
join products as p on p.warehouseCode = w.warehouseCode
group by w.warehouseCode, w.warehouseName
order by unitsStored desc;

select p.productName, w.warehouseName, SUM(p.quantityInStock) as unitsStored
from products as p
join warehouses as w on w.warehouseCode = p.warehouseCode
group by quantityInStock
order by unitsStored;

--- customer Payment and credit limit ---
select ct.customerNumber, ct.creditLimit, sum(amount) as totalAmount 
from payments as py
join customers as ct on ct.customerNumber = py.customerNumber
group by ct.customerNumber, ct.creditLimit;

--
select *,
       case 
           when totalAmount > creditLimit then 'risky'
           else 'Good'
       end as credit_risk
from (
      select ct.customerNumber, ct.creditLimit, sum(amount) as totalAmount 
      from payments as py
      join customers as ct on ct.customerNumber = py.customerNumber
      group by ct.customerNumber, ct.creditLimit
     ) as creditAndPayments;

--- relationship between products prices and sales ---

select p.productCode, p.productName, p.buyPrice, sum(od.quantityOrdered) as totalSales
from products as p
join orderdetails as od on p.productCode = od.productCode
group by p.productCode, p.productname, p.buyPrice
order by p.buyPrice desc;

--- valuable customers, total purchases ---
select cu.customerName, cu.addressLine1, cu.country, sum(od.quantityOrdered) as totalPurchases
from customers as cu
join orders as ord on ord.customerNumber = cu.customerNumber
join orderdetails as od on od.orderNumber = ord.orderNumber
group by cu.customerName, cu.addressLine1, cu.country
order by totalPurchases desc;

--- valuable customers, number of purchases ---
select cu.customerName, cu.addressLine1, cu.country, count(ord.orderNumber) as totalPurchases
from customers as cu
join orders as ord on ord.customerNumber = cu.customerNumber
group by cu.customerName, cu.addressLine1, cu.country
order by totalPurchases desc;

--- performance of sales employees, number of orders ----
select ee.employeeNumber, ee.lastName, ee.firstName, count(ord.orderNumber) as totalSalesPerEmployee
from employees as ee
join customers as cu on cu.salesRepEmployeeNumber = ee.employeeNumber
join orders as ord on ord.customerNumber = cu.customerNumber
group by ee.employeeNumber, ee.lastName, ee.firstName
order by totalSalesPerEmployee desc;

--- performance of sales employees, total amount sales per employee ----
select ee.employeeNumber, ee.lastName, ee.firstName, 
sum(od.priceEach * od.quantityOrdered) as totalAmountSalesPerEmployee
from employees as ee
join customers as cu on cu.salesRepEmployeeNumber = ee.employeeNumber
join orders as ord on ord.customerNumber = cu.customerNumber
join orderdetails as od on od.orderNumber = ord.orderNumber
group by ee.employeeNumber, ee.lastName, ee.firstName
order by totalAmountSalesPerEmployee desc;

--- most succefull product, percentage of sales over quantity in stock ---
select p.productCode, p.productName, sum(p.quantityInStock) as totalInventory,
sum(od.quantityOrdered) as totalSales,
sum(od.priceEach*od.quantityOrdered) as totalAmountSales 
from products as p
join orderdetails as od on od.productCode = p.productCode
group by p.productCode, p.productName
order by totalAmountSales desc;

--- most succefull productLine, percentage of sales over quantity in stock ---
select pl.productline, pl.textDescription, sum(p.quantityInStock) as totalInventory,
sum(od.quantityOrdered) as totalSales,
sum(od.priceEach*od.quantityOrdered) as totalAountSales, 
sum(od.quantityOrdered)*100/sum(p.quantityInStock) as SalePercentage
from products as p
join productlines as pl  on p.productLine = pl.productLine
join orderdetails as od on od.productCode = p.productCode
group by pl.productline, pl.textDescription
order by SalePercentage desc;


