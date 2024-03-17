CREATE DATABASE HOUSEDB2

USE HOUSEDB2

CREATE TABLE EMPLOYEES(
		EmpID varchar(10) PRIMARY KEY,
		Ename varchar(50) not null,
		Email varchar(50) not null,
		Salary int not null,
		Gender char(1)
		)

CREATE TABLE HOUSES(
		HouseID varchar(10) PRIMARY KEY,
		Area_m2 int not null,
		Price int not null,
		BedRoom int not null 
		)

CREATE TABLE CUSTOMERS(
		CustomerID varchar(10) PRIMARY KEY,
		Gender char(1) not null,
		Cname varchar(50) not null,
		Caddress varchar(50) not null,
		Email varchar(50) not null)

CREATE TABLE CONTRACTS(
		ContractNo varchar(10) PRIMARY KEY,
		HouseID varchar(10) FOREIGN KEY (HouseID) REFERENCES HOUSES(HouseID),
		EmpID varchar(10) FOREIGN KEY (EmpID) REFERENCES EMPLOYEES(EmpID),
		CustomerID varchar(10) FOREIGN KEY (CustomerID) REFERENCES CUSTOMERS(CustomerID),
		StartDate date not null,
		EndDate date not null,
		Duration int,
		ContractValue int,
		PrePaid int,
		OutstandingAmount int)


---- Nhap du lieu

INSERT INTO EMPLOYEES
VALUES ('Emp001','Nguyen Van A','A@',1000,'m'),
	   ('Emp002','Nguyen Van B','B@',2000,'f'),
	   ('Emp003','Nguyen Van C','C@',3000,'m'),
	   ('Emp004','Nguyen Van D','D@',4000,'f'),
	   ('Emp005','Nguyen Van C','D@',5000,'m')

SELECT * FROM EMPLOYEES

INSERT INTO HOUSES
VALUES ('Hou001',1000,1000,1),
	   ('Hou002',2000,2000,2),
	   ('Hou003',3000,3000,3),
	   ('Hou004',4000,4000,4),
	   ('Hou005',5000,5000,5)


INSERT INTO CUSTOMERS
VALUES ('Cus001','m','Nguyen Van E','113 ABC','E@'),
	   ('Cus002','f','Nguyen Van F','114 ABC','F@'),
	   ('Cus003','m','Nguyen Van G','115 ABC','G@'),
	   ('Cus004','f','Nguyen Van H','116 ABC','H@'),
	   ('Cus005','m','Nguyen Van I','117 ABC','I@')


INSERT INTO CONTRACTS(ContractNo, HouseID, EmpID, CustomerID, StartDate, EndDate)
VALUES ('Con001','Hou001','Emp001','Cus001','2019-01-23','2019-03-23'),
	   ('Con002','Hou002','Emp002','Cus002','2019-02-24','2019-04-22'),
	   ('Con003','Hou003','Emp003','Cus003','2019-03-25','2019-05-21'),
	   ('Con004','Hou004','Emp004','Cus004','2019-04-27','2019-06-20'),
	   ('Con005','Hou005','Emp005','Cus005','2019-05-27','2019-07-19')

SELECT * FROM CONTRACTS


--- 

CREATE PROC AddCons(@ContractNo varchar(10), @HouseID varchar(10), 
					@EmpID varchar(10), @CustomerID varchar(10), 
					@StartDate date, @EndDate date)
AS
BEGIN
	DECLARE @Duration int
	SET @Duration = IIF(DATEDIFF(MONTH,@StartDate,@EndDate)=0,1,DATEDIFF(MONTH,@StartDate,@EndDate))
	
	DECLARE @ContractValue int
	SET @ContractValue = @Duration*(SELECT Price FROM HOUSES WHERE HouseID = @HouseID)

	DECLARE @PrePaid int
	SET @PrePaid = IIF(@Duration > 12,50,IIF(@Duration >=6,70,85))

	DECLARE @OutStandingAmount int
	SET @OutStandingAmount = @ContractValue - @PrePaid + 0.1*@ContractValue

	INSERT INTO CONTRACTS
	VALUES(@ContractNo, @HouseID, @EmpID, @CustomerID, @StartDate, @EndDate,@Duration, @ContractValue, @PrePaid, @OutstandingAmount)
END


AddCons 'Con008','Hou005','Emp005','Cus005','2019-05-27','2019-07-19'

SELECT * FROM CONTRACTS