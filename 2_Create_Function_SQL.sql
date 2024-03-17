


CREATE FUNCTION check_existCust2 (@name nvarchar(30), @phone varchar(15))
RETURNS	BIT
AS
BEGIN
		declare @a bit	
		SELECT @a = CASE WHEN
		EXISTS ( SELECT customer.Cust_name
		FROM customer
		WHERE customer.Cust_name like @name
		AND customer.Cust_phone like @phone )
		THEN 1 ELSE 0 END
		RETURN @a
END
GO


SELECT dbo.check_existCust2('Phuong Loan Pham','2263408408')

