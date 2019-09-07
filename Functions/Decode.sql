use [WTS]
go

if object_id('[dbo].[Decode]', 'FN') is not null
drop function [dbo].[Decode];
go

create function [dbo].[Decode]
(
	@input nvarchar(4000)
)
returns nvarchar(4000)
as
begin
	declare @char nvarchar(5)
	declare @asc nvarchar(5)
	declare @asc2 nvarchar(5)

	while (charindex('%', @input) > 0)
	begin
	 set @char=(select substring(@input, charindex('%', 
		@input) +1, 2))
	 if (isnumeric(substring(@char, 1, 1)))>0
	 begin
	  set @asc=(select cast(substring(@char, 1, 1)
		as int))*16
	 end
	 else
	 begin 
	  set @asc=(select ascii(cast(substring(@char, 1, 1) 
		as char)))-55
	  set @asc=(select @asc*16)
	 end
	 if (isnumeric(substring(@char, 2, 1)))>0
	  set @asc=(select cast(@asc as int) + 
		(select cast(substring(@char, 2, 1) as int)))
	 else
	 begin 
	  set @asc2=(select ascii(cast(substring(@char, 2, 1) 
		as char)))-55
	  set @asc=(select cast(@asc as int) + 
		(select cast(@asc2 as int)))
	 end
	 set @input=
		(select substring(@input, 0, charindex('%', @input))) 
		+ char(@asc) + (select substring(@input, charindex('%', 
		@input)+3, len(@input)))
	end
	return @input
end;
go
