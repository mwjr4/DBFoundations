--*************************************************************************--
-- Title: Assignment06
-- Author: MichaelWilliams
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2017-01-01,MichaelWilliams,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_MichaelWilliams')
	 Begin 
	  Alter Database [Assignment06DB_MichaelWilliams] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_MichaelWilliams;
	 End
	Create Database Assignment06DB_MichaelWilliams;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_MichaelWilliams;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [mOney] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10 -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, UnitsInStock + 20 -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
 
'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'

-- Question 1 (5% pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!



GO
 CREATE VIEW dbo.vcategories
  WITH SCHEMABINDING
 AS SELECT  CategoryID, CategoryName FROM dbo.Categories;
GO

SELECT * FROM dbo.vcategories;
GO

GO
 CREATE VIEW dbo.vProducts
  AS SELECT  ProductID, ProductName, CategoryID, UnitPrice FROM dbo.Products;
GO

SELECT * FROM dbo.vProducts;
GO


GO
 CREATE VIEW dbo.vEmployees
  AS SELECT  EmployeeID, EmployeeFirstName, EmployeeLastname, ManagerID FROM dbo.Employees;
GO

SELECT * FROM dbo.vEmployees;
GO

GO
 CREATE VIEW dbo.vInventories
  AS SELECT  InventoryID, InventoryDate, EmployeeID, ProductID, COUNT FROM dbo.Inventories;
GO

SELECT * FROM dbo.vInventories;
GO



--Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?

--Categories Table

GO

CREATE VIEW dbo.vPublicCategoryInfo  
 AS SELECT  CategoryID FROM dbo.Categories

GO

CREATE VIEW dbo.vPrivateCategoryInfo  
 AS SELECT  CategoryID, CategoryName FROM dbo.Categories;
go

SELECT * FROM dbo.vPublicCategoryInfo;
SELECT * FROM dbo.vPrivateCategoryInfo;

DENY SELECT ON dbo.vPrivateCategoryInfo TO PUBLIC;
GRANT SELECT ON dbo. vPublicCategoryInfo TO PUBLIC; --I left out columns in the public view so the table differences are obvious

--Products Table

GO
CREATE VIEW dbo.vPublicProductInfo 
 AS SELECT  ProductID, ProductName, CategoryID FROM dbo.Products;

GO
 CREATE VIEW dbo.vPrivateProductInfo 
  AS SELECT  ProductID, ProductName, CategoryID, UnitPrice FROM dbo.Products;
GO

SELECT * FROM dbo.vPublicProductInfo;
SELECT * FROM dbo.vPrivateProductInfo;

DENY SELECT ON dbo.vPrivateProductInfo TO PUBLIC;
GRANT SELECT  ON dbo.vPublicProductInfo TO PUBLIC; --I left out columns in the public view so the table differences are obvious

--Employee Table
GO
 CREATE  VIEW dbo.vPublicEmployeeInfo
  AS SELECT  EmployeeID, ManagerID FROM dbo.Employees;
GO


CREATE VIEW dbo.vPrivateEmployeeInfo  
 AS SELECT  InventoryID, InventoryDate, EmployeeID, ProductID, COUNT FROM dbo.Inventories;
GO

SELECT * FROM dbo.vPublicEmployeeInfo;
SELECT * FROM dbo.vPrivateEmployeeInfo;


DENY SELECT ON dbo.vPrivateEmployeeInfo TO PUBLIC;
GRANT SELECT  ON dbo.vPublicEmployeeInfo TO PUBLIC; --I left out columns in the public view so the table differences are obvious



--Inventories Table


GO
 CREATE VIEW dbo.vPublicInventoryInfo
  AS SELECT  InventoryID, EmployeeID, ProductID FROM dbo.Inventories;
GO


CREATE VIEW dbo.vPrivateInventoryInfo  
 AS SELECT  InventoryID, InventoryDate, EmployeeID, ProductID, COUNT FROM dbo.Inventories;
GO

SELECT * FROM dbo.vPublicInventoryInfo;
SELECT * FROM dbo.vPrivateInventoryInfo;


DENY SELECT ON dbo.vPrivateInventoryInfo TO PUBLIC; 
 GRANT SELECT  ON dbo.vPublicInventoryInfo TO PUBLIC; --I left out columns in the public view so the table differences are obvious
Go

-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!

GO
 CREATE VIEW dbo.vProductsByCategories
  AS SELECT CategoryName, ProductName, UnitPrice 
   FROM Categories AS C 
    Inner Join Products AS P
  ON c.CategoryID=p.CategoryID;
GO

SELECT * FROM vProductsByCategories ORDER BY CategoryName, ProductName;


-- Question 4 (10% pts): How can you create a view to show a list of Product names and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!

GO
 CREATE VIEW dbo.vInventoriesByProductsByDates
  AS SELECT COUNT, InventoryDate, ProductName 
   FROM Products AS P 
    Inner Join Inventories AS I
  ON p.ProductID=i.ProductID;
GO

SELECT * FROM dbo.vInventoriesByProductsByDates ORDER BY ProductName, InventoryDate, COUNT;

GO



-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

-- Here is are the rows selected from the view:

-- InventoryDate	EmployeeName
-- 2017-01-01	    Steven Buchanan
-- 2017-02-01	    Robert King
-- 2017-03-01	    Anne Dodsworth

--Select * From Inventories;
--Select * From Employees;

GO
 CREATE VIEW dbo.vInventoriesByEmployeesByDates
  AS SELECT InventoryDate, (EmployeeFirstName + ' '+ EmployeeLastName) AS EmployeeName 
   FROM Employees AS E
   Inner Join Inventories AS I
  ON E.EmployeeID=I.EmployeeID;
GO

SELECT DISTINCT * FROM dbo.vInventoriesByEmployeesByDates ORDER BY InventoryDate;


-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

--Select * From Categories
--Select * From Products
--Select * From Inventories



GO
 CREATE  VIEW dbo.vInventoriesByProductsByCategories
  AS SELECT CategoryName AS Category, ProductName AS Product, InventoryDate, COUNT 
   FROM Products AS P 
    Inner Join Inventories AS I
  ON P.ProductID=I.ProductID
    Inner Join Categories AS C
    ON C.CategoryID=P.CategoryID
GO

SELECT * FROM dbo.vInventoriesByProductsByCategories ORDER BY Category, Product, InventoryDate,COUNT;
GO


-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

--Select * From Categories;
--Select * From Products;
--Select * From Employees;
--Select * From Inventories;



GO
 CREATE VIEW dbo.vInventoriesByProductsByEmployees
  AS SELECT CategoryName AS Category, ProductName AS Product, (EmployeeFirstName + ' '+ EmployeeLastName) AS EmployeeName, InventoryDate, COUNT 
   FROM Inventories AS I 
    Inner Join Employees AS E
   ON E.EmployeeID=I.EmployeeID
    Inner Join Products AS P
   ON I.ProductID=P.ProductID 
    Inner Join Categories AS C
   ON C.CategoryID=P.CategoryID
    
GO

SELECT * FROM dbo.vInventoriesByProductsByEmployees ORDER BY InventoryDate, Category, Product, EmployeeName;


-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 

GO
 CREATE VIEW dbo.vInventoriesForChaiAndChangByEmployees
  AS SELECT CategoryName AS Category, ProductName AS Product, InventoryDate, COUNT, (EmployeeFirstName + ' '+ EmployeeLastName) AS EmployeeName
   FROM Inventories AS I 
    Inner Join Employees AS E
   ON E.EmployeeID=I.EmployeeID
    Inner Join Products AS P
   ON I.ProductID=P.ProductID 
    Inner Join Categories AS C
   ON C.CategoryID=P.CategoryID
WHERE P.ProductID= 1 or P.ProductID=2
    
GO

SELECT * FROM dbo.vInventoriesForChaiAndChangByEmployees 



-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!

GO

CREATE  VIEW dbo.vEmployeesByManager AS SELECT (Emp.EmployeeFirstName + ' ' + Emp.EmployeeLastName) AS Manager,(Mgr.EmployeeFirstName + ' ' + Mgr.EmployeeLastName) AS Employee 
  FROM Employees AS Mgr Inner Join Employees AS Emp
 ON Emp.EmployeeID = Mgr.ManagerID
GO
SELECT * FROM dbo.vEmployeesByManager ORDER BY Manager, Employee --Returns what i want





-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views? (My view shows this)Also show the Employee's Manager Name and order the data by 
-- Category, Product, InventoryID, and Employee (My select statement shows this)


GO              
CREATE  VIEW dbo.vInventoriesByProductsByCategoriesByEmployees 
AS SELECT  c.CategoryID, CategoryName, p.ProductID, ProductName, UnitPrice, InventoryID, InventoryDate, COUNT,e.EmployeeID
   FROM dbo.vInventories AS [I] 
    Inner Join dbo.vEmployees AS [E]
     ON E.EmployeeID=I.EmployeeID
    Inner Join vProducts AS [P]
     ON I.ProductID=P.ProductID 
    Inner Join dbo.vCategories AS [C]
     ON C.CategoryID=P.CategoryID
GO

SELECT CategoryID,CategoryName,ProductID,ProductName,UnitPrice, InventoryID,InventoryDate,COUNT, EmployeeID, Employee,Manager
 FROM dbo.vInventoriesByProductsByCategoriesByEmployees AS [A]
  Inner Join dbo.vEmployeesByManager [E]
 
 ON EmployeeID=EmployeeID
 WHERE Manager In ('Steven Buchanan' , 'Andrew Fuller')
ORDER BY CategoryID,ProductName, Employee DESC, Manager 


GO
    

 --Here are the two select statements that give me what i want seperately. I need to join them to return one table.
--Select  CategoryID,CategoryName,ProductID,ProductName,UnitPrice, InventoryID,InventoryDate,Count,EmployeeID From dbo.vAllBasicViews
--Order By CategoryName, ProductID, InventoryID 
--Select * From dbo.vEmployeesByManager Order By Manager, Employee 


--This is as good as it gets . 

 

-- Test your Views (NOTE: You must change the your view names to match what I have below!)
Print 'Note: You will get an error until the views are created!'
Select * From [dbo].[vCategories]
Select * From [dbo].[vProducts]
Select * From [dbo].[vInventories]
Select * From [dbo].[vEmployees]
Select * From [dbo].[vProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByDates]  
Select * From [dbo].[vInventoriesByEmployeesByDates]
Select * From [dbo].[vInventoriesByProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByEmployees]
Select * From [dbo].[vInventoriesForChaiAndChangByEmployees]
Select * From [dbo].[vEmployeesByManager]
Select * From [dbo].[vInventoriesByProductsByCategoriesByEmployees]

/***************************************************************************************/