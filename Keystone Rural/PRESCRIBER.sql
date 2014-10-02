--Extraction Query
SELECT DISTINCT '|PRESCRIBER' AS [File Type]
	,'NEC01' AS [Client Code]
	,ISNULL(First, '') AS [First Name]
	,ISNULL(Last, '') AS [Last Name]
	,ISNULL(DF.NPI, '') AS [NPI Number]
	,isnull(convert(VARCHAR, UE.StartDate, 101), '') AS [Start Date]
	,ISNULL(convert(VARCHAR, UE.EndDate, 101), '') AS [End Date]
	,ISNULL(DEA, '') AS [DEA NUMBER]
	,ISNULL(StateLicenseNo, '') AS [State License Number]
	,ISNULL(UE.Type, '') AS [Employment Type]
	,ISNULL(U.NPI, '') AS [Taxonomy]
	,'' AS [Type of Prescriber]
	,'' AS [Class]
	,ISNULL(MS.Description, '') AS [Specialization]
FROM DoctorFacility DF(NOLOCK)
LEFT JOIN MedLists MS ON MS.MedListsId = DF.SpecialtyMId
	AND MS.TableName = 'Specialty'
LEFT JOIN USR U ON U.PVID = DF.PVID
LEFT JOIN cus_VOW_340B_UserEmployment UE ON UE.DoctorFacilityId = DF.DoctorFacilityId


--Extraction File Script
DECLARE @FileName VARCHAR(255)
DECLARE @querytext VARCHAR(4000)
DECLARE @filelocation VARCHAR(8000)
DECLARE @cmd VARCHAR(5000)
    
SET @querytext = '"select distinct ''|PRESCRIBER'' as [File Type],''NEC01'' as [Client Code],First as [First Name],Last as [Last Name],DF.NPI as [NPI Number],convert(varchar,UE.StartDate,101) as [Start Date],convert(varchar,UE.EndDate,101) as [End Date], DEA as [DEA NUMBER],StateLicenseNo as [State License Number],UE.Type as [Employment Type], U.NPI as [Taxonomy], NULL as [Type of Prescriber], NULL as [Class],MS.Description as [Specialization] from demo12GA.dbo.DoctorFacility DF(nolock) left outer join demo12GA.dbo.MedLists MS on MS.MedListsId =DF.SpecialtyMId and MS.TableName =''Specialty'' left outer join demo12GA.dbo.USR U on U.PVID = DF.PVID left outer join demo12GA.dbo.cus_VOW_340B_UserEmployment UE on UE.DoctorFacilityId= DF.DoctorFacilityId  "'   
SET @FileName = 'Prescriber Information'   
SET @filelocation = '"C:\' + @FileName + '.TXT"'       
SET @cmd = 'bcp ' + @querytext + ' queryout ' + @filelocation + ' -T -c -t"|" -r"|"\n' 
EXEC master..XP_CMDSHELL @cmd
 
