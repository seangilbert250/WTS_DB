use [WTS]
go

ALTER TABLE ReleaseSession
  ADD [PrimarySessionManagerID] [int] NULL;
ALTER TABLE ReleaseSession
  ADD [SecondarySessionManagerID] [int] NULL;
