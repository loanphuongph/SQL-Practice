create database JOB_INFO
use JOB_INFO

drop table EMPS

create table EMPS (
	Eno char(5) primary key,
	Ename char(50) not null,
	Skill char(20) not null,
	Salary int not null
)

create table JOBS(
	JobNo char(5) primary key,
	Reg_Skill char(50) not null,
	Num_emp int not null
)

INSERT INTO EMPS
VALUES  ('E001', 'A', 'SQL', 1440),
		('E002', 'B', 'C#', 854),
		('E003', 'C', 'R', 1720),
		('E004', 'D', 'MySQL', 884),
		('E005', 'E', 'Java', 900),
		('E006', 'F', 'SQL', 900),
		('E007', 'G', 'Java', 900),
		('E008', 'H', 'SQL', 900),
		('E009', 'I', 'C#', 936),
		('E010', 'J', 'C++', 840)

INSERT INTO JOBS
VALUES  ('J001', 'SQL', 5),
		('J002', 'Java', 2),
		('J003', 'Python', 1),
		('J004', 'C#', 5)

SELECT * FROM JOBS
SELECT * FROM EMPS

-- Q1. Cho biết số nhân viên theo từng kĩ năng, giảm dần theo số nhân viên

SELECT Skill, count(*) AS Count_column
FROM EMPS
GROUP BY SKILL
ORDER BY Count_column

-- Q2. Cho biết kĩ năng nào có số nhân viên từ 2 người trở lên

SELECT Skill, COUNT(*) AS Count_column
FROM EMPS
GROUP BY SKILL
HAVING Count(*) >= 2

-- Q3. Cho biết thông tin nhân viên có kỹ năng mà không job nào cần
-- Using Subquery
SELECT * FROM EMPS
WHERE Skill not in ( SELECT Reg_Skill FROM JOBS)
-- Using All
SELECT * FROM EMPS
WHERE Skill <> all ( SELECT Reg_Skill FROM JOBS)

-- Q4. Cho biết thông các nhân viên mà có skill ít nhất 1 job cần
SELECT * FROM EMPS
WHERE SKill in ( SELECT Reg_Skill FROM JOBS)

SELECT * FROM EMPS
WHERE SKill = any ( SELECT Reg_Skill FROM JOBS)

-- Q5. Cho biết các job có skill mà không có nhân viên nào có
SELECT Reg_Skill
FROM JOBS
EXCEPT   
SELECT Skill FROM EMPS 

-- Q6. Tăng lương cho 2 nhân viên có lương thấp nhất lên 20%
UPDATE EMPS
SET Salary = Salary*(1.2)
WHERE Salary in ( SELECT TOP 2 Salary FROM EMPS ORDER BY Salary ASC )

-- Q7. Cho biết Skill nào trong Job có ít nhất 1 nhân viên có và Skill của nhân viên nào có ít nhất 1 Job cần.
SELECT Skill FROM EMPS
Intersect 
SELECT Reg_Skill FROM JOBS

-- Q8. Cho biêt Skill nào trong Jobs mà nhân viên không đáp ứng được ( không đủ số lượng hoặc không có )
-- Tạo bảng Temp
SELECT Skill, Count(*) as Skill_Count INTO Temp
FROM EMPS
GROUP BY SKill 

SELECT * FROM JOBS
SELECT * FROM Temp

SELECT Reg_Skill 
FROM Temp right outer join JOBS ON Temp.Skill = JOBS.Reg_Skill
-- Using Right Outer Join
SELECT Reg_Skill 
FROM Temp right outer join JOBS ON Temp.Skill = JOBS.Reg_Skill
Where Temp.Skill_Count < JOBS.Num_emp or Reg_Skill not in (SELECT Skill FROM EMPS)

-- Using Full Outer Join
SELECT Reg_Skill 
FROM Temp Full outer join JOBS ON Temp.Skill = JOBS.Reg_Skill
Where Temp.Skill_Count < JOBS.Num_emp or ( Reg_Skill is not null and Skill is null )

-- Q9. Cho biết Skill nào mà nhân viên có thể đáp ứng

SElECT Reg_Skill
FROM Temp Inner Join Jobs on Temp.Skill = Jobs.Reg_skill
WHERE Temp.Skill_Count >= Jobs.num_emp

-- Q10. Viết Query để tổng hợp dữ liệu như sau

SELECT Skill, Count(*) as Skill_Count, Sum(Salary) as Total_Sal
FROM EMPS
GROUP BY Skill
Union
SELECT 'TOTAL', COUNT(*) as Skill_Count, Sum(Salary) as Total_Sal FROM EMPS

-- Q11. Viết Query để tổng hợp dữ liệu
SELECT Cast(' ' as nvarchar(50)) as Ename, Skill, Cast(' ' as nvarchar(50)) as Salary, Cast(Count(*) as nvarchar(50))as Skill_Count,
       Cast(Sum(Salary) as nvarchar(50)) as Total_Sal
FROM EMPS
GROUP BY Skill
Union
SELECT  Ename, Skill, Cast( Salary as nvarchar(50)) as Salary, Cast(' ' as nvarchar(50)) as Skill_Count,
        Cast(' ' as nvarchar(50)) as Total
FROM EMPS
ORDER BY Skill, Ename

USE JOB_INFO
SELECT * FROM JOBS
SELECT * FROM EMPS

-- Q1. Cho biết số nhân viên theo từng kĩ năng, giảm dần theo số nhân viên
SELECT Skill, Count(*) As Skill_count 
FROM EMPS
GROUP BY Skill
ORDER BY Skill_count DESC

-- Q2. Cho biết kĩ năng nào có số nhân viên từ 2 người trở lên

SELECT Skill, Count(*) As Skill_count
FROM EMPS
GROUP BY Skill
HAVING COUNT(*) >=2

-- Q3. Cho biết thông tin nhân viên có kỹ năng mà không job nào cần
-- Using Subquery

SELECT * FROM EMPS
WHERE Skill not in (SELECT Reg_Skill FROM JOBS)

-- Using All

SELECT * FROM EMPS
WHERE Skill <> all (SELECT Reg_Skill FROM JOBS)

-- Q4. Cho biết thông các nhân viên mà có skill ít nhất 1 job cần

SELECT * FROM EMPS
WHERE Skill = any ( SELECT Reg_Skill FROM JOBS) 

-- Q5. Cho biết các job có skill mà không có nhân viên nào có

SELECT Reg_Skill
FROM JOBS
EXCEPT
SELECT Skill
FROM EMPS

-- Q6. Tăng lương cho 2 nhân viên có lương thấp nhất lên 20%

UPDATE EMPS
SET Salary = Salary*1.2
WHERE Salary in (SELECT TOP 2 Salary FROM EMPS ORDER BY SALARY ASC)

-- Q7. Cho biết Skill nào trong Job có ít nhất 1 nhân viên có và Skill của nhân viên nào có ít nhất 1 Job cần.
SELECT Skill FROM EMPS
INTERSECT
SELECT Reg_Skill FROM JOBS

-- Q8. Cho biêt Skill nào trong Jobs mà nhân viên không đáp ứng được ( không đủ số lượng hoặc không có )
-- Tạo bảng Temp
SELECT Skill, COUNT(*) as Skill_Count INTO Temp2
FROM EMPS
GROUP BY Skill

SELECT * FROM TEMP2
-- Using Right Outer Join
SELECT Reg_Skill
FROM Temp2 full outer join JOBS ON Temp2.Skill = JOBS.Reg_Skill 
WHERE Temp2.Skill_Count < JOBS.Num_emp or Reg_Skill not in (SELECT Skill FROM Temp2) 


-- Using Full Outer Join

-- Q9. Cho biết Skill nào mà nhân viên có thể đáp ứng

SELECT Reg_Skill
FROM JOBS
WHERE 

-- Q10. Viết Query để tổng hợp dữ liệu như sau

SELECT Skill, Count(*) as Skill_Count, Sum(Salary) as Total_Sal
FROM EMPS
GROUP BY Skill
Union
SELECT 'TOTAL', COUNT(*) as Skill_Count, Sum(Salary) as Total_Sal FROM EMPS

-- Q11. Viết Query để tổng hợp dữ liệu
SELECT Cast(' ' as nvarchar(50)) as Ename, Skill, Cast(' ' as nvarchar(50)) as Salary, Cast(Count(*) as nvarchar(50))as Skill_Count,
       Cast(Sum(Salary) as nvarchar(50)) as Total_Sal
FROM EMPS
GROUP BY Skill
Union
SELECT  Ename, Skill, Cast( Salary as nvarchar(50)) as Salary, Cast(' ' as nvarchar(50)) as Skill_Count,
        Cast(' ' as nvarchar(50)) as Total
FROM EMPS
ORDER BY Skill, Ename

