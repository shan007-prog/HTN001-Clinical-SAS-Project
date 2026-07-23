/**************************************************************************
Program    : ex.sas
Study      : HTN001
Domain     : EX
Purpose    : Create SDTM Exposure dataset
Programmer : Shanmugam M
Date       : 19-Jul-2026
**************************************************************************/
libname raw  "/home/u64365683/RAW";
libname sdtm "/home/u64365683/SDTM";

proc sort data=raw.ex (RENAME=(EXSTDTC=RAW_EXSTDTC EXENDTC=RAW_EXENDTC)) out=ex_sort;
by usubjid exseq ;
run;
proc sort data=sdtm.dm(keep=usubjid rfstdtc) out=dm_ref nodupkey;
by usubjid; 
run;
data dm_ref;
length usubjid $14;
set dm_ref ;
RUN;
proc contents data=dm_ref;
run;
data ex_prep;
merge ex_sort(in=a) dm_ref;
by usubjid;
if a;
run;
OPTIONS ERRORS=100;
data sdtm.ex;
length 
STUDYID $20
DOMAIN $2
USUBJID $40
EXSEQ 8
EXTRT $200
EXDOSE 8
EXDOSU $40
EXDOSFRQ $20
EXROUTE $40
EXSTDTC $19
EXENDTC $19
EXSTDY 8
EXENDY 8 ;
set ex_prep;
DOMAIN="EX";
EXSTDTC=PUT(RAW_EXSTDTC,E8601DA.);
EXENDTC=PUT(RAW_EXENDTC,E8601DA.);

RFSTDT=INPUT(SUBSTR(RFSTDTC,1,10),YYMMDD10.);

IF RAW_EXSTDTC >= RFSTDT THEN EXSTDY=RAW_EXSTDTC-RFSTDT+1;
ELSE EXSTDY=RAW_EXSTDTC-RFSTDT;
IF RAW_EXENDTC >= RFSTDT THEN EXENDY=RAW_EXENDTC- RFSTDT+1;
ELSE EXENDY = RAW_EXENDTC-RFSTDT;
label
STUDYID  = "Study Identifier"
DOMAIN   = "Domain Abbreviation"
USUBJID  = "Unique Subject Identifier"
EXSEQ    = "Sequence Number"
EXTRT    = "Name of Actual Treatment"
EXDOSE   = "Dose per Administration"
EXDOSU   = "Dose Units"
EXDOSFRQ = "Dosing Frequency per Interval"
EXROUTE  = "Route of Administration"
EXSTDTC  = "Start Date/Time of Treatment"
EXENDTC  = "End Date/Time of Treatment"
EXSTDY   = "Study Day of Start of Treatment"
EXENDY   = "Study Day of End of Treatment";

keep  STUDYID DOMAIN USUBJID EXSEQ EXTRT EXDOSE EXDOSU
    EXDOSFRQ EXROUTE EXSTDTC EXENDTC EXSTDY EXENDY;
RUN;

proc contents data=ex_prep varnum;
run;
PROC PRINT DATA=SDTM.EX(OBS=5);
RUN;
proc print data=ex_prep(obs=10);
    var usubjid raw_exstdtc raw_exendtc rfstdtc;
    format raw_exstdtc raw_exendtc date9.;
run;