USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[CRReportBuilder_Save]    Script Date: 7/23/2018 9:55:15 AM ******/
DROP PROCEDURE [dbo].[CRReportBuilder_Save]
GO

/****** Object:  StoredProcedure [dbo].[CRReportBuilder_Save]    Script Date: 7/23/2018 9:55:15 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE procedure [dbo].[CRReportBuilder_Save]
	@ReleaseID int,
	@ContractID int,
	@Builder xml,
	@UpdatedBy nvarchar(50) = 'WTS',
	@Saved bit = 0 output
as
begin
	set nocount on;

	declare @itemUpdateTypeID int;
	declare @date datetime;

	set @date = getdate();


		if @Builder.exist('builder/save') > 0
			begin
				select @itemUpdateTypeID = ITEM_UPDATETYPEID from ITEM_UPDATETYPE where upper(ITEM_UPDATETYPE) = 'UPDATE';

				------------------------------------------------
				-- WORKLOAD ALLOCATION / VISIBLE TO CUSTOMER --
				------------------------------------------------
				with
				w_aors as (
					select
						tbl.[save].value('workloadAllocationID[1]', 'int') as WorkloadAllocationID,
						tbl.[save].value('aorid[1]', 'int') as AORID,
						arl.AORReleaseID
					from @Builder.nodes('builder/save') as tbl([save])
					left join AORRelease arl
					on tbl.[save].value('aorid[1]', 'int') = arl.AORID
					where arl.ProductVersionID = @ReleaseID
				)
				SELECT arl.AORReleaseID
					, arl.WorkloadAllocationID
					, wa.WorkloadAllocation
					, arl.AORCustomerFlagship
				into #OldAORData
				from AORRelease arl
				join w_aors
				on arl.AORReleaseID = w_aors.AORReleaseID
				left join WorkloadAllocation wa
				on arl.WorkloadAllocationID = wa.WorkloadAllocationID;

				with
				w_aors as (
					select
						tbl.[save].value('workloadAllocationID[1]', 'int') as WorkloadAllocationID,
						tbl.[save].value('aorid[1]', 'int') as AORID,
						arl.AORReleaseID
					from @Builder.nodes('builder/save') as tbl([save])
					left join AORRelease arl
					on tbl.[save].value('aorid[1]', 'int') = arl.AORID
					where arl.ProductVersionID = @ReleaseID
				)
				update AORRelease
				set WorkloadAllocationID = w_aors.WorkloadAllocationID,
					AORCustomerFlagship = 1,
					UpdatedBy = @UpdatedBy,
					UpdatedDate = @date
				from w_aors
				where AORRelease.AORReleaseID = w_aors.AORReleaseID
				and exists (
					select 1
					from AORRelease arl
					left join AORReleaseTask art
					on arl.AORReleaseID = art.AORReleaseID
					left join WORKITEM wi
					on art.WORKITEMID = wi.WORKITEMID
					left join WTS_SYSTEM_CONTRACT wsc
					on wi.WTS_SYSTEMID = wsc.WTS_SYSTEMID
					where AORRelease.AORReleaseID = arl.AORReleaseID
					and (isnull(@ContractID, 0) = 0 or wsc.CONTRACTID = @ContractID)
					and (isnull(@ReleaseID, 0) = 0 or arl.ProductVersionID = @ReleaseID)
				);

				with
				w_aors as (
					select
						tbl.[save].value('workloadAllocationID[1]', 'int') as WorkloadAllocationID,
						tbl.[save].value('aorid[1]', 'int') as AORID,
						arl.AORReleaseID
					from @Builder.nodes('builder/save') as tbl([save])
					left join AORRelease arl
					on tbl.[save].value('aorid[1]', 'int') = arl.AORID
					where arl.ProductVersionID = @ReleaseID
				)
				SELECT arl.AORReleaseID
					, arl.WorkloadAllocationID
					, wa.WorkloadAllocation
					, arl.AORCustomerFlagship
				into #NewAORData
				from AORRelease arl
				join w_aors
				on arl.AORReleaseID = w_aors.AORReleaseID
				left join WorkloadAllocation wa
				on arl.WorkloadAllocationID = wa.WorkloadAllocationID;

				INSERT INTO AORRelease_History(ITEM_UPDATETYPEID, AORReleaseID, FieldChanged, OldValue, NewValue, CREATEDBY, CREATEDDATE, UPDATEDBY, UPDATEDDATE)
				SELECT 
					@itemUpdateTypeID
					, #OldAORData.AORReleaseID
					, 'Workload Allocation'
					, #OldAORData.WorkloadAllocation
					, #NewAORData.WorkloadAllocation
					, @UpdatedBy
					, @date
					, @UpdatedBy
					, @date
				from #OldAORData
				left join #NewAORData
				on #OldAORData.AORReleaseID = #NewAORData.AORReleaseID
				where #OldAORData.WorkloadAllocation != #NewAORData.WorkloadAllocation;

				INSERT INTO AORRelease_History(ITEM_UPDATETYPEID, AORReleaseID, FieldChanged, OldValue, NewValue, CREATEDBY, CREATEDDATE, UPDATEDBY, UPDATEDDATE)
				SELECT 
					@itemUpdateTypeID
					, #OldAORData.AORReleaseID
					, 'Visible To Customer'
					, CASE WHEN #OldAORData.AORCustomerFlagship = 1 THEN 'Yes' else 'No' end
					, CASE WHEN #NewAORData.AORCustomerFlagship = 1 THEN 'Yes' else 'No' end
					, @UpdatedBy
					, @date
					, @UpdatedBy
					, @date
				from #OldAORData
				left join #NewAORData
				on #OldAORData.AORReleaseID = #NewAORData.AORReleaseID
				where #OldAORData.AORCustomerFlagship != #NewAORData.AORCustomerFlagship;

				------------------
				-- AORRELEASECR --
				------------------
				with
				w_crs as (
					select
						tbl.[save].value('crid[1]', 'int') as CRID,
						tbl.[save].value('aorid[1]', 'int') as AORID,
						arl.AORReleaseID
					from @Builder.nodes('builder/save') as tbl([save])
					left join AORRelease arl
					on tbl.[save].value('aorid[1]', 'int') = arl.AORID
					where arl.ProductVersionID = @ReleaseID
				)
				SELECT arc.AORReleaseID
					, arc.CRID
					, cr.CRName
				into #OldCRData
				from AORReleaseCR arc
				left join AORCR cr
				on arc.CRID = cr.CRID
				where not exists (
					select 1
					from w_crs
					where arc.AORReleaseID = w_crs.AORReleaseID
					and arc.CRID = w_crs.CRID
				)
				and exists (
					select 1
					from AORRelease arl
					left join AORReleaseTask art
					on arl.AORReleaseID = art.AORReleaseID
					left join WORKITEM wi
					on art.WORKITEMID = wi.WORKITEMID
					left join WTS_SYSTEM_CONTRACT wsc
					on wi.WTS_SYSTEMID = wsc.WTS_SYSTEMID
					left join AOR
					on arl.AORID = AOR.AORID
					where AOR.Archive = 0
					and arl.AORCustomerFlagship = 1
					and arc.AORReleaseID = arl.AORReleaseID
					and (isnull(@ContractID, 0) = 0 or wsc.CONTRACTID = @ContractID)
					and (isnull(@ReleaseID, 0) = 0 or arl.ProductVersionID = @ReleaseID)
				);

				with
				w_crs as (
					select
						tbl.[save].value('crid[1]', 'int') as CRID,
						tbl.[save].value('aorid[1]', 'int') as AORID,
						arl.AORReleaseID
					from @Builder.nodes('builder/save') as tbl([save])
					left join AORRelease arl
					on tbl.[save].value('aorid[1]', 'int') = arl.AORID
					where arl.ProductVersionID = @ReleaseID
				)
				delete from AORReleaseCR
				where not exists (
					select 1
					from w_crs
					where AORReleaseCR.AORReleaseID = w_crs.AORReleaseID
					and AORReleaseCR.CRID = w_crs.CRID
				)
				and exists (
					select 1
					from AORRelease arl
					left join AORReleaseTask art
					on arl.AORReleaseID = art.AORReleaseID
					left join WORKITEM wi
					on art.WORKITEMID = wi.WORKITEMID
					left join WTS_SYSTEM_CONTRACT wsc
					on wi.WTS_SYSTEMID = wsc.WTS_SYSTEMID
					left join AOR
					on arl.AORID = AOR.AORID
					where AOR.Archive = 0
					and arl.AORCustomerFlagship = 1
					and AORReleaseCR.AORReleaseID = arl.AORReleaseID
					and (isnull(@ContractID, 0) = 0 or wsc.CONTRACTID = @ContractID)
					and (isnull(@ReleaseID, 0) = 0 or arl.ProductVersionID = @ReleaseID)
				);

				with
				w_crs as (
					select
						tbl.[save].value('crid[1]', 'int') as CRID,
						tbl.[save].value('aorid[1]', 'int') as AORID,
						arl.AORReleaseID
					from @Builder.nodes('builder/save') as tbl([save])
					left join AORRelease arl
					on tbl.[save].value('aorid[1]', 'int') = arl.AORID
					where arl.ProductVersionID = @ReleaseID
				)
				SELECT arl.AORReleaseID
					, cr.CRID
					, cr.CRName
				into #NewCRData
				from w_crs
				left join AORRelease arl
				on w_crs.AORID = arl.AORID
				left join AORCR cr
				on w_crs.CRID = cr.CRID
				where arl.ProductVersionID = @ReleaseID
				and not exists (
					select 1
					from w_crs
					left join AORReleaseCR arc
					on arc.AORReleaseID = arl.AORReleaseID
					left join AORReleaseTask art
					on arl.AORReleaseID = art.AORReleaseID
					left join WORKITEM wi
					on art.WORKITEMID = wi.WORKITEMID
					left join WTS_SYSTEM_CONTRACT wsc
					on wi.WTS_SYSTEMID = wsc.WTS_SYSTEMID
					left join AOR
					on arl.AORID = AOR.AORID
					where AOR.Archive = 0
					and arl.AORCustomerFlagship = 1
					and (isnull(@ContractID, 0) = 0 or wsc.CONTRACTID = @ContractID)
					and (isnull(@ReleaseID, 0) = 0 or arl.ProductVersionID = @ReleaseID
					and arc.CRID = w_crs.CRID
					and arl.AORID = w_crs.AORID)
				);

				with
				w_crs as (
					select
						tbl.[save].value('crid[1]', 'int') as CRID,
						tbl.[save].value('aorid[1]', 'int') as AORID
					from @Builder.nodes('builder/save') as tbl([save])
				)
				insert into AORReleaseCR(AORReleaseID, CRID, CreatedBy, UpdatedBy)
				select arl.AORReleaseID,
					CRID,
					@UpdatedBy,
					@UpdatedBy
				from w_crs
				left join AORRelease arl
				on w_crs.AORID = arl.AORID
				where arl.ProductVersionID = @ReleaseID
				and not exists (
					select 1
					from w_crs
					left join AORReleaseCR arc
					on arc.AORReleaseID = arl.AORReleaseID
					left join AORReleaseTask art
					on arl.AORReleaseID = art.AORReleaseID
					left join WORKITEM wi
					on art.WORKITEMID = wi.WORKITEMID
					left join WTS_SYSTEM_CONTRACT wsc
					on wi.WTS_SYSTEMID = wsc.WTS_SYSTEMID
					left join AOR
					on arl.AORID = AOR.AORID
					where AOR.Archive = 0
					and arl.AORCustomerFlagship = 1
					and (isnull(@ContractID, 0) = 0 or wsc.CONTRACTID = @ContractID)
					and (isnull(@ReleaseID, 0) = 0 or arl.ProductVersionID = @ReleaseID
					and arc.CRID = w_crs.CRID
					and arl.AORID = w_crs.AORID)
				);

				INSERT INTO AORRelease_History(ITEM_UPDATETYPEID, AORReleaseID, FieldChanged, OldValue, NewValue, CREATEDBY, CREATEDDATE, UPDATEDBY, UPDATEDDATE)
				SELECT 
					@itemUpdateTypeID
					, isnull(#OldCRData.AORReleaseID, #NewCRData.AORReleaseID)
					, 'CRs'
					, isnull(#OldCRData.CRName, '')
					, isnull(#NewCRData.CRName, '')
					, @UpdatedBy
					, @date
					, @UpdatedBy
					, @date
				from AORRelease arl
				left join #OldCRData
				on arl.AORReleaseID = #OldCRData.AORReleaseID
				left join #NewCRData
				on arl.AORReleaseID = #NewCRData.AORReleaseID
				where isnull(#OldCRData.CRName, '') != isnull(#NewCRData.CRName, '');

				----------------
				-- DEPLOYMENT --
				----------------
				with
				w_deployments as (
					select
						tbl.[save].value('aorid[1]', 'int') as AORID,
						arl.AORReleaseID,
						tbl.[save].value('deploymentid[1]', 'int') as DeploymentID
					from @Builder.nodes('builder/save') as tbl([save])
					left join AORRelease arl
					on tbl.[save].value('aorid[1]', 'int') = arl.AORID
					where arl.ProductVersionID = @ReleaseID
				)
				delete from AORReleaseDeliverable
				where not exists (
					select 1
					from w_deployments
					where AORReleaseDeliverable.AORReleaseID = w_deployments.AORReleaseID
					and AORReleaseDeliverable.DeliverableID = w_deployments.DeploymentID
				)
				and (exists (
						select distinct AORReleaseDeliverableID
						from AORRelease arl
						left join AORReleaseTask art
						on arl.AORReleaseID = art.AORReleaseID
						left join WORKITEM wi
						on art.WORKITEMID = wi.WORKITEMID
						left join WTS_SYSTEM_CONTRACT wsc
						on wi.WTS_SYSTEMID = wsc.WTS_SYSTEMID
						left join AORReleaseCR arc
						on arl.AORReleaseID = arc.AORReleaseID
						where arl.AORCustomerFlagship = 1
						and isnull(arc.CRID, 0) > 0
						and AORReleaseDeliverable.AORReleaseID = arl.AORReleaseID
						and (isnull(@ContractID, 0) = 0 or wsc.CONTRACTID = @ContractID)
						and (isnull(@ReleaseID, 0) = 0 or arl.ProductVersionID = @ReleaseID)
					) or exists (
						select 1
						from w_deployments
						where AORReleaseDeliverable.AORReleaseID = w_deployments.AORReleaseID
						and w_deployments.DeploymentID = 0
					)
				);

				with
				w_deployments as (
					select
						tbl.[save].value('crid[1]', 'int') as CRID,
						tbl.[save].value('aorid[1]', 'int') as AORID,
						arl.AORReleaseID,
						tbl.[save].value('deploymentid[1]', 'int') as DeploymentID
					from @Builder.nodes('builder/save') as tbl([save])
					left join AORRelease arl
					on tbl.[save].value('aorid[1]', 'int') = arl.AORID
					where arl.ProductVersionID = @ReleaseID
					and tbl.[save].value('deploymentid[1]', 'int') > 0
				)
				insert into AORReleaseDeliverable(AORReleaseID, DeliverableID, CreatedBy, UpdatedBy)
				select arl.AORReleaseID,
					DeploymentID,
					@UpdatedBy,
					@UpdatedBy
				from w_deployments
				left join AORRelease arl
				on w_deployments.AORID = arl.AORID
				where arl.ProductVersionID = @ReleaseID
				and not exists (
					select 1
					from w_deployments
					left join AORReleaseDeliverable ard
					on ard.AORReleaseID = arl.AORReleaseID
					left join AORReleaseTask art
					on arl.AORReleaseID = art.AORReleaseID
					left join WORKITEM wi
					on art.WORKITEMID = wi.WORKITEMID
					left join WTS_SYSTEM_CONTRACT wsc
					on wi.WTS_SYSTEMID = wsc.WTS_SYSTEMID
					left join AORReleaseCR arc
					on arl.AORReleaseID = arc.AORReleaseID
					where arl.AORCustomerFlagship = 1
					and (isnull(@ContractID, 0) = 0 or wsc.CONTRACTID = @ContractID)
					and (isnull(@ReleaseID, 0) = 0 or arl.ProductVersionID = @ReleaseID
					and (isnull(w_deployments.DeploymentID, 0) = 0 or ard.DeliverableID = w_deployments.DeploymentID)
					and arl.AORID = w_deployments.AORID
					and arc.CRID = w_deployments.CRID)
				);
				
			end;

		set @Saved = 1;

		if object_id('tempdb..#OldAORData') is not null
		begin
			drop table #OldAORData;
		end; 

		if object_id('tempdb..#NewAORData') is not null
		begin
			drop table #NewAORData;
		end; 

		if object_id('tempdb..#OldCRData') is not null
		begin
			drop table #OldCRData;
		end; 

		if object_id('tempdb..#NewCRData') is not null
		begin
			drop table #NewCRData;
		end;
end;
GO


