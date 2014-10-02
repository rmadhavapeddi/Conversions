--Extraction Query
SELECT DISTINCT '|' + PP.First AS [First Name]
	,PP.Last AS [Last Name]
	,convert(VARCHAR, PP.Birthdate, 101) AS [Birth Date]
	,PP.Sex AS [Sex]
	,PP.Address1 + ISNULL(PP.Address2, '') AS [Address]
	,PP.City AS [City]
	,PP.STATE AS [State]
	,PP.Zip AS [Postal Code]
	,PP.MedicalRecordNumber AS [Medical Record Code]
	,PV.TicketNumber AS [Visit Code]
	,NULL AS [Inpatient/Outpatient]
	,NULL AS [Enterprise]
	,NULL AS [Corporation]
	,NULL AS [Facility Code or Department]
	,cast(DF1.ListName AS VARCHAR(50)) AS [Site]
	,DF1.Address1 AS [Location]
	,PS.Description AS [Location Type]
	,NULL AS [Facility Sub]
	,Convert(VARCHAR, PV.Entered, 101) AS [Visit Date]
	,'NEC04' AS [Client Code]
	,PRESDRUGS.DRUGS AS [Drugs Prescribed at Visit]
	,DF.NPI AS [Prescriber NPI or DEA]
	,NULL AS [Pharmacy]
	,DR.NPI AS [Referral]
	,NULL AS [Date of Referral]
	,NULL AS [eRx Number]
	,PD.DIAGNOSISCODES
	,PC.PROCEDURECODES AS [Procedure Codes]
	,'PATIENT4' AS [File Type]
FROM PatientProfile PP(NOLOCK)
LEFT JOIN PatientVisit PV ON PV.PatientProfileId = PP.PatientProfileId
LEFT JOIN (
	SELECT PV1.PatientVisitId
		,CASE 
			WHEN LEN(PV1.DIAGNOSISCODES) > 0
				THEN substring(PV1.DIAGNOSISCODES, 1, LEN(PV1.DIAGNOSISCODES) - 1)
			END AS DIAGNOSISCODES
	FROM PatientVisit PVP
	LEFT JOIN (
		SELECT DISTINCT PatientVisitId
			,(
				SELECT innerData.ICD9code + '*' AS [text()]
				FROM PatientVisitDiags INNERDATA
				WHERE INNERDATA.PatientVisitId = OUTERDATA.PatientVisitId
					AND Listorder <= 10
				ORDER BY ListOrder
				FOR XML PATH('')
				) DIAGNOSISCODES
		FROM PatientVisitDiags OUTERDATA
		) PV1 ON PV1.PatientVisitId = PVP.PatientVisitId
	) PD ON PD.PatientVisitId = PV.PatientVisitId
LEFT JOIN (
	SELECT PV1.PatientVisitId
		,CASE 
			WHEN len(PV1.PROCEDURECODES) > 0
				THEN substring(PV1.PROCEDURECODES, 1, LEN(PV1.PROCEDURECODES) - 1)
			END AS PROCEDURECODES
	FROM PatientVisit PVP
	LEFT JOIN (
		SELECT DISTINCT PatientVisitId
			,(
				SELECT innerData.CPTCode + '*' AS [text()]
				FROM PatientVisitProcs INNERDATA
				WHERE INNERDATA.PatientVisitId = OUTERDATA.PatientVisitId
					AND Listorder <= 10
				ORDER BY ListOrder
				FOR XML PATH('')
				) PROCEDURECODES
		FROM PatientVisitProcs OUTERDATA
		) PV1 ON PV1.PatientVisitId = PVP.PatientVisitId
	) PC ON PC.PatientVisitId = PV.PatientVisitId
LEFT JOIN DoctorFacility DF1 ON DF1.DoctorFacilityId = PV.FacilityId
LEFT JOIN DoctorFacility DF ON DF.DoctorFacilityId = PV.DoctorId
LEFT JOIN LOCREG LR ON LR.LOCID = DF.LocationId
LEFT JOIN MedLists PS ON PS.MedListsId = DF.PlaceOfServiceMId
	AND TableName = 'placeofservicecodes'
LEFT JOIN DOCUMENT D ON D.PatientVisitId = PV.PatientVisitId
LEFT JOIN (
	SELECT MED.SDID
		,CASE 
			WHEN len(MED.DRUGS) > 0
				THEN substring(MED.DRUGS, 1, LEN(MED.DRUGS) - 1)
			END AS DRUGS
	FROM Document DOC
	LEFT JOIN (
		SELECT DISTINCT SDID
			,(
				SELECT cast(innerData.DESCRIPTION AS VARCHAR(20)) + '*' AS [text()]
				FROM Medicate INNERDATA
				WHERE INNERDATA.SDID = OUTERDATA.SDID
				FOR XML PATH('')
				) DRUGS
		FROM MEDICATE OUTERDATA
		GROUP BY SDID
		HAVING COUNT(*) <= 10
		) MED ON MED.SDID = DOC.SDID
	WHERE MED.SDID IS NOT NULL
	) PRESDRUGS ON PRESDRUGS.SDID = D.SDID
LEFT JOIN DoctorFacility DR ON DR.DoctorFacilityId = PV.ReferringDoctorId



--Extraction File Script
DECLARE @FileName VARCHAR(255)
DECLARE @querytext VARCHAR(8000)
DECLARE @filelocation VARCHAR(2000)
DECLARE @cmd VARCHAR(8000)
    
SET @querytext = '"select distinct ''|''+PP.First as [First Name], PP.Last as [Last Name],convert(varchar,PP.Birthdate,101)  as [Birth Date], PP.Sex  as [Sex],PP.Address1 +ISNULL(PP.Address2,'''')  as [Address],PP.City  as [City],PP.State  as [State],PP.Zip  as [Postal Code],PP.MedicalRecordNumber  as [Medical Record Code],PV.TicketNumber as [Visit Code], NULL  as [Inpatient/Outpatient], NULL  as [Enterprise], NULL  as [Corporation],NULL  as [Facility Code or Department],cast(DF1.ListName as varchar(50)) as [Site],DF1.Address1  as [Location],PS.Description  as [Location Type], NULL  as [Facility Sub],Convert(varchar,PV.Entered,101) as [Visit Date], ''NEC04'' as [Client Code], PRESDRUGS.DRUGS  as [Drugs Prescribed at Visit], DF.NPI  as [Prescriber NPI or DEA], NULL  as [Pharmacy], DR.NPI  as [Referral], NULL  as [Date of Referral], NULL  as [eRx Number],  PD.DIAGNOSISCODES, PC.PROCEDURECODES  as [Procedure Codes], ''PATIENT4''  as [File Type] from demo12GA.dbo.PatientProfile PP(nolock) Left outer join demo12GA.dbo.PatientVisit PV on PV.PatientProfileId =PP.PatientProfileId LEFT OUTER JOIN (select PV1.PatientVisitId, Case when LEN(PV1.DIAGNOSISCODES)>0 then substring(PV1.DIAGNOSISCODES,1,LEN(PV1.DIAGNOSISCODES)-1) end  as DIAGNOSISCODES FROM demo12GA.dbo.PatientVisit PVP left join (select distinct PatientVisitId, (	SELECT innerData.ICD9code + ''*'' AS [text()] from demo12GA.dbo.PatientVisitDiags INNERDATA 	where INNERDATA.PatientVisitId = OUTERDATA.PatientVisitId 	and Listorder <=10 	order by ListOrder For XML PATH ('''') )DIAGNOSISCODES from demo12GA.dbo.PatientVisitDiags OUTERDATA ) PV1 on PV1.PatientVisitId = PVP.PatientVisitId) PD on PD.PatientVisitId = PV.PatientVisitId LEFT OUTER JOIN (select PV1.PatientVisitId, Case when len(PV1.PROCEDURECODES)>0 then  substring(PV1.PROCEDURECODES,1,LEN(PV1.PROCEDURECODES)-1)  end as PROCEDURECODES FROM demo12GA.dbo.PatientVisit PVP left join ( select distinct PatientVisitId, ( 	SELECT innerData.CPTCode + ''*'' AS [text()] from demo12GA.dbo.PatientVisitProcs INNERDATA 	where INNERDATA.PatientVisitId = OUTERDATA.PatientVisitId 	and Listorder <=10  	order by ListOrder For XML PATH ('''') )PROCEDURECODES from demo12GA.dbo.PatientVisitProcs OUTERDATA ) PV1 on PV1.PatientVisitId = PVP.PatientVisitId  ) PC on PC.PatientVisitId = PV.PatientVisitId LEFT OUTER JOIN demo12GA.dbo.DoctorFacility DF1 on DF1.DoctorFacilityId = PV.FacilityId LEFT OUTER JOIN demo12GA.dbo.DoctorFacility DF on DF.DoctorFacilityId =PV.DoctorId LEFT OUTER JOIN demo12GA.dbo.LOCREG LR on LR.LOCID =DF.LocationId LEFT OUTER JOIN demo12GA.dbo.MedLists PS on PS.MedListsId =DF.PlaceOfServiceMId and TableName =''placeofservicecodes'' LEFT OUTER JOIN demo12GA.dbo.DOCUMENT D on D.PatientVisitId = PV.PatientVisitId LEFT OUTER JOIN ( select MED.SDID,  Case when len(MED.DRUGS)>0 then substring(MED.DRUGS,1,LEN(MED.DRUGS)-1) end as DRUGS FROM demo12GA.dbo.Document DOC left join (select distinct SDID,(	SELECT cast(innerData.DESCRIPTION as varchar(20)) + ''*'' AS [text()] from demo12GA.dbo.Medicate INNERDATA	where INNERDATA.SDID = OUTERDATA.SDID		For XML PATH ('''') )DRUGS from demo12GA.dbo.MEDICATE OUTERDATA group by SDID having COUNT(*) <=10 ) MED on MED.SDID = DOC.SDID where MED.SDID is NOT NULL)PRESDRUGS on PRESDRUGS.SDID = D.SDID LEFT OUTER JOIN demo12GA.dbo.DoctorFacility DR on DR.DoctorFacilityId =PV.ReferringDoctorId "'  
SET @FileName = 'Patient Authentication' 
SET @filelocation = '"C:\' + @FileName + '.TXT"'       
SET @cmd = 'bcp ' + @querytext + ' queryout ' + @filelocation + ' -T -c -t"|" -r"|"\n' 
EXEC master..XP_CMDSHELL @cmd


