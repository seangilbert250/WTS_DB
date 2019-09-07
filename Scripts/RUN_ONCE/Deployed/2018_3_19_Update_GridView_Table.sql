use wts
go


--Ensure all views have view name in their json because this will throw off selecting the correct dropdown choice
Declare @currentViewName nvarchar(max);
While exists (select * from GridView WHERE lower(Tier1Columns) like '%"viewname":""%')
	begin
		select top 1 @currentViewName = t1.ViewName from (select * from GridView WHERE lower(Tier1Columns) like '%"viewname":""%') t1;
		update GridView set Tier1Columns = REPLACE(Tier1Columns,'"viewname":""','"viewname":"' + @currentViewName + '"')
		WHERE ViewName = @currentViewName;
		print @currentViewName;
	end
go



----Update the AOR grids that have no QF in their json
DECLARE @RC int
DECLARE @GridName nvarchar(50)='AOR'
DECLARE @UserName nvarchar(50)='110'
DECLARE @S varchar(max) 

update gridView set 
Tier1Columns = SUBSTRING(Tier1Columns, 1, len(Tier1Columns)-1) + ',"QFContract":"13,16,1,8,5,6,2,19","QFRelease":"38,40","QFAORType":"0,2,1","QFVisibleToCustomer":"1,0","QFTaskStatus":"80,72,1,2,3,4,5,7,8,9,11,12,13,15","QFAORProductionStatus":"0,76,108,75,78,77"}' 
where GridNameID = 11 and (Tier1Columns not like '%QF%' and Tier1Columns like '%sectionorder%')


