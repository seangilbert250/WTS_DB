
CREATE FUNCTION itemContains 
(
	@List AS NVARCHAR(MAX)
	,@item AS NVARCHAR(MAX)
)
RETURNS BIT
AS
BEGIN
	DECLARE @Start AS INT = 0;
	DECLARE @End AS INT = 0;
	WHILE LEN(@List) > @Start AND LEN(@List) > @End BEGIN 
		SET @END = CHARINDEX(',', @List, @Start)
		IF @END = 0 SET @End = LEN(@List) + 1
		IF CHARINDEX(SUBSTRING(@List, @Start, @End - @Start), @item) > 0 RETURN 1
		SET @Start = @End + 1
	END;
	RETURN 0;
END
go
