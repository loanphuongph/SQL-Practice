use bank


--------------------------------------- CAU 21 ------------------------------------------------

CREATE PROC abc(@Cust_name nvarchar(50), @Cust_phone varchar(15), @Cust_ad nvarchar(50), @Br_id char(5))
AS
BEGIN
	DECLARE @a char(6), @newid char(6)
	SET @a = ( SELECT MAX(Cust_id) from customer ) + 1
	SET @newid = '0000' + @a
	INSERT INTO Customer
	VALUES (@newid, @Cust_name, @Cust_phone, @Cust_ad, @Br_id)
END

drop proc abc
abc 'Kami-chan','0932126019','P.Hòa Cường, Q.Hải Châu, TP.Đà Nẵng','VT009'

SELECT * from customer


--------------------------------------- CAU 22 ------------------------------------------------

CREATE PROC def(@Br_id char(2))
AS
BEGIN
	DECLARE @cNewID char(5), @max_new char(5)
	IF @Br_id IN (SELECT LEFT(BR_id,2) FROM Branch )
		BEGIN
			SET @max_new = (SELECT MAX(RIGHT(BR_id,3)) FROM Branch WHERE LEFT(BR_id,2) = @Br_id ) +1
			SET @CnewID = IIF (LEN(@max_new) = 3, @br_id + @max_new, IIF(LEN(@max_new) = 2, @br_id + '0' + @max_new, @br_id + '00' + @max_new))
			print 'Ma moi la: '+ @CnewID
		END
	ELSE
		BEGIN
			print'Ma nay khong ton tai --> Tao ma moi tu dau'
			SET @cNewID = @Br_id + '001'
			print 'Ma moi la ' + @cNewID
		END

END

drop proc def
def 'VB'

select * from transactions

--------------------------------------- CAU 11 ------------------------------------------------
-- Thêm một bản ghi vào TRANSACTIONS nếu biết các thông tin ngày giao dịch, thời gian giao dịch, số tài khoản, 
-- loại giao dịch, số tiền giao dịch. Công việc cần làm bao gồm: (PROCEDURE)
-- a.	Kiểm tra ngày và thời gian giao dịch có hợp lệ không. Nếu không, ngừng xử lý (F)

CREATE FUNCTION date_check(@t_date date, @t_time time(7))
RETURNS BIT
AS
BEGIN
	DECLARE @a int
	SELECT @a = CASE WHEN ( SELECT DATEPART(HOUR, @t_time) ) IN (0,1,2,3) THEN 0
																		  ELSE 1 END
	RETURN @a
END

select * from transactions
SELECT dbo.date_check('2011-12-27','02:45:00.0000000') -- tra ve 0 vi trong 0->3h sang

drop function date_check
-- b.	Kiểm tra số tài khoản có tồn tại trong bảng ACCOUNT không? Nếu không, ngừng xử lý (F)

CREATE FUNCTION acc_check (@ac_no char(10))
RETURNS BIT
AS
BEGIN
	DECLARE @a bit
	SELECT @a = CASE WHEN EXISTS (SELECT * FROM transactions WHERE ac_no = @ac_no)
	THEN 1 ELSE 0 END
	RETURN @a
END

select * from account
drop function acc_check
SELECT dbo.acc_check('1000000001')

-- c.	Kiểm tra loại giao dịch có phù hợp không? Nếu không, ngừng xử lý (F)

CREATE FUNCTION type_check (@t_type char(1))
RETURNS BIT
AS
BEGIN
	DECLARE @a bit
	SELECT @a = CASE WHEN @t_type IN (0,1) -- Chỉ có 2 loại 0 và 1
	THEN 1 ELSE 0 END
	RETURN @a
END

SELECT dbo.type_check('2')

-- d.	Kiểm tra số tiền có hợp lệ không (lớn hơn 0)? Nếu không, ngừng xử lý (F)

CREATE FUNCTION amount_check (@ac_no char(10), @t_amount numeric(15,0), @t_type char(1)) -- 0 rut 1 gui
RETURNS BIT
AS
BEGIN
	DECLARE @a bit
	IF @t_amount < 0
		SET @a = 0
	ELSE 
		SELECT @a = CASE WHEN @t_type = 0  AND ( @t_amount <= ( SELECT ac_balance FROM account WHERE Ac_no = @ac_no ) ) THEN 1
						 WHEN @t_type = 1  AND @t_amount > 0 THEN 1
						 ELSE 0 END 
	RETURN @a
END

SELECT dbo.amount_check('1000000001','99999999999','0') -- So tien < 0 thi deu tra ve sai, neu rut tien ma TK khong du thi tra ve sai

drop function amount_check
-- e.	Tính mã giao dịch mới (F)

CREATE FUNCTION create_id ()
RETURNS CHAR(10)
AS
BEGIN
	DECLARE @old_max char(10), @new_max char(6), @counter int, @newid char(10), @add varchar(10)
	SET @old_max = ( SELECT MAX(t_id) from transactions )
	SET @new_max = @old_max + 1
	SET @counter = 1
	IF LEN(@new_max) < LEN(@old_max)
		BEGIN
			SET @add = '0'
				WHILE @counter < (LEN(@old_max) - LEN(@new_max) )
				BEGIN 
						SET @add =  '0' + @add
						SET @counter = @counter + 1
				END
		END
	SET @newid = @add + @new_max
	RETURN @newid
END

drop function create_id
SELECT dbo.create_id()

-- f.	Thêm mới bản ghi vào bảng TRANSACTIONS (F)
-- wtf 

CREATE PROCEDURE addtrans(@t_id char(10), @t_type char(1), @t_amount numeric(15,0), @t_date date, @t_time time(7), @ac_no char(10))
AS
BEGIN
	INSERT INTO transactions
	VALUES (@t_id, @t_type, @t_amount, @t_date, @t_time , @ac_no)
	PRINT 'Yes'
END

addtrans '0000000100','0','1752000','2011-12-27','07:45:00.0000000','1000000041'


-- g.	Cập nhật bảng ACCOUNT bằng cách cộng hoặc trừ số tiền vừa thực hiện giao dịch tùy theo loại giao dịch (P)

select * from account

CREATE PROCEDURE add_account (@ac_no char(10) , @t_amount numeric(15, 0))
AS
BEGIN
	DECLARE @ac_balance numeric(15, 0)
	SET @ac_balance = ( SELECT ac_balance FROM account WHERE Ac_no =  @ac_no )
	UPDATE account
	SET ac_balance = @ac_balance - @t_amount
END

add_account '1000000001', '8000'


-- Gop lai
CREATE PROCEDURE cau11(@t_type char(1), @t_amount numeric(15,0), @t_date date, @t_time time(7), @ac_no char(10))
AS
BEGIN
	DECLARE @t_id char(10) 
	-- a) Kiểm tra ngày và thời gian giao dịch  
	IF (SELECT dbo.date_check(@t_date,@t_time)) = 1
		-- b) Kiểm tra số tài khoản có tồn tại
		IF (SELECT dbo.acc_check(@ac_no)) = 1
			-- c) Kiểm tra loại giao dịch có phù hợp không
			IF (SELECT dbo.type_check(@t_type)) =1
				-- d) Kiểm tra số tiền có hợp lệ không (lớn hơn 0)
					IF (SELECT dbo.amount_check(@ac_no, @t_amount,@t_type )) = 1
						BEGIN
							-- e) Tính mã giao dịch mới 
							SET @t_id = ( SELECT dbo.create_id() )
							-- f) Thêm mới bản ghi vào bảng TRANSACTIONS
							INSERT INTO transactions
							VALUES (@t_id, @t_type, @t_amount, @t_date, @t_time , @ac_no)
							-- g) Cập nhật bảng ACCOUNT bằng cách cộng hoặc trừ số tiền vừa thực hiện 
							DECLARE @ac_balance numeric(15, 0)
							SET @ac_balance = ( SELECT ac_balance FROM account WHERE Ac_no =  @ac_no )
							UPDATE account
							SET ac_balance = @ac_balance - @t_amount
							PRINT 'Xong'
						END
					ELSE
						PRINT 'So tien k hop le :  Phai > 0 va nho hon so du neu muon rut'
			ELSE
				Print 'Loai giao dich sai, chi co 1 va 0'
		ELSE
			Print 'Khong co tai khoan nay'
	ELSE
		Print 'Thoi gian sai'
END

drop procedure edit_account
select * from transactions
cau11 '1','1752000','2011-12-27','07:45:00.0000000','1000000041'



--------------------------------------- CAU 12cde ------------------------------------------------


-- c.	Kiểm tra số tiền có hợp lệ không? Nếu NULL thì để mặc định là 50000, nhỏ hơn 0 thì ngừng xử lý. (F)

CREATE FUNCTION balance_check (@ac_balance numeric(15, 0))-- Tra ra : NULL -> 50000, <0 --> 0, dat yeu cau --> 1 
RETURNS INTEGER
AS
BEGIN
	DECLARE @a integer
	SELECT @a = CASE WHEN @ac_balance IS NULL THEN 50000
					 WHEN @ac_balance < 0 THEN 0
					 ELSE 1 END
	RETURN @a
END


SELECT dbo.balance_check(NULL)
drop function balance_check


-- d.	Tính số tài khoản mới. Số tài khoản mới bằng MAX(các số tài khoản cũ) + 1 (F)

CREATE FUNCTION create_acno ()
RETURNS CHAR(10)
AS
BEGIN
	DECLARE @old_max char(10), @new_max char(10), @counter int, @new_acno char(10), @add varchar(10)
	SET @old_max = ( SELECT MAX(Ac_no) from account )
	SET @new_acno = @old_max + 1
	RETURN @new_acno
END

select * from account 
drop function create_acno

SELECT dbo.create_acno ()

--e.	Thêm mới bản ghi vào bảng ACCOUNT với dữ liệu đã có. (F)

CREATE PROCEDURE addaccount(@Ac_no char(10), @ac_balance numeric(15, 0), @ac_type char(1), @cust_id char(6))
AS
BEGIN
	INSERT INTO account
	VALUES (@Ac_no, @ac_balance, @ac_type, @cust_id)
	PRINT 'Da them'
END

select * from account

addaccount '1000000000','86358000','1','000001'