use [WTS]
go

ALTER TABLE WorkloadAllocation
ADD Abbreviation nvarchar(10) null;
go

UPDATE WorkloadAllocation
SET Abbreviation = 'R'
WHERE WorkloadAllocationID = 1

UPDATE WorkloadAllocation
SET Abbreviation = 'T'
WHERE WorkloadAllocationID = 3

UPDATE WorkloadAllocation
SET Abbreviation = 'C'
WHERE WorkloadAllocationID = 4

UPDATE WorkloadAllocation
SET Abbreviation = 'Tr'
WHERE WorkloadAllocationID = 5

UPDATE WorkloadAllocation
SET Abbreviation = 'P'
WHERE WorkloadAllocationID = 6

UPDATE WorkloadAllocation
SET Abbreviation = 'IS'
WHERE WorkloadAllocationID = 7

UPDATE WorkloadAllocation
SET Abbreviation = 'BD'
WHERE WorkloadAllocationID = 8