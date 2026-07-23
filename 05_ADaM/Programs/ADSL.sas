/*******************************************************************
Program : adsl.sas
Study   : HTN001
Domain  : ADSL
Purpose : Create ADaM subject level anlaysis dataset
Programmer : Shanmugam M
Date    : 19-Jul-2026

**********************************************************************/
libname sdtm '/home/u64365683/SDTM';
libname adam '/home/u64365683/ADaM';

OPTIONS ERRORS=100;

PROC SORT DATA=SDTM.DM OUT=DM_SORT;
BY USUBJID;
RUN;

PROC SORT DATA=SDTM.ex OUT=EX_SORT;
BY USUBJID ;
RUN;
PROC SORT DATA=SDTM.DS OUT=DS_SORT;
BY USUBJID;
RUN;

data adsl_prep;
merge DM_SORT(IN=A) EX_SORT(IN=B) DS_SORT(IN=C);
BY USUBJID;
IF A;
RUN;

DATA ADaM.ADSL;
LENGTH
STUDYID $20
USUBJID $40
SITEID $10
SUBJID $20
AGE 8
AGEU $10
AGEGR1 $10
AGEGR1N 8
SEX $1
RACE $100
ETHNIC $100
COUNTRY $3
TRT01P $20
TRT01PN 8
TRT01A $20
TRT01AN 8
TRTSDT 8
TRTEDT 8
TRTDURD 8
SAFFL $1
ITTFL $1
SCRNFL $1
COMPLFL $1
EOSSTT $20
EOSDT 8
DCSREAS $100


;

SET ADSL_PREP;

TRT01P=ARM;
IF UPCASE(STRIP(TRT01P))="DRUG A" THEN TRT01PN=1;
ELSE IF UPCASE(STRIP(TRT01P))="PLACEBO" THEN TRT01PN=2;

TRT01A=EXTRT;
IF UPCASE(STRIP(TRT01A))="DRUG A" THEN TRT01AN=1;
ELSE IF UPCASE(STRIP(TRT01A))="PLACEBO" THEN TRT01AN=2;


IF 18<= AGE<= 40 THEN DO; 
AGEGR1="18-40";
AGEGR1N=1;
END;
ELSE IF 41<= AGE<= 60 THEN DO;
AGEGR1="41-60";
AGEGR1N=2;
END;
ELSE  DO AGEGR1 =">60";
 AGEGR1N=3;
 END;

TRTSDT=INPUT(EXSTDTC,E8601DA.);
TRTEDT=INPUT(EXENDTC,E8601DA.);
FORMAT TRTSDT TRTEDT DATE9.;

SCRNFL="Y";

TRTDURD=TRTEDT-TRTSDT+1;

IF NOT MISSING(ARM)THEN ITTFL="Y";
ELSE ITTFL="N";

IF NOT MISSING(EXSTDTC) THEN SAFFL="Y";
ELSE SAFFL="N";
EOSSTT=DSDECOD;
IF DSDECOD="COMPLETED" THEN COMPLFL="Y";
ELSE COMPLFL="N";
EOSDT=INPUT(SUBSTR(DSSTDTC,1,10),YYMMDD10.);
FORMAT EOSDT DATE9.;
IF COMPLFL="N" THEN DSCREAS=COALESCEC(DSTERM,DSDECOD);
label
    STUDYID  = "Study Identifier"
    USUBJID  = "Unique Subject Identifier"
    SUBJID   = "Subject Identifier for the Study"
    SITEID   = "Study Site Identifier"
    AGE      = "Age"
    AGEU     = "Age Units"
    AGEGR1   = "Age Group 1"
    SEX      = "Sex"
    RACE     = "Race"
    ETHNIC   = "Ethnicity"
    COUNTRY  = "Country"

    TRT01P   = "Planned Treatment for Period 01"
    TRT01PN  = "Planned Treatment for Period 01 (N)"
    TRT01A   = "Actual Treatment for Period 01"
    TRT01AN  = "Actual Treatment for Period 01 (N)"

    TRTSDT   = "Date of First Exposure to Treatment"
    TRTEDT   = "Date of Last Exposure to Treatment"
    TRTDURD  = "Total Treatment Duration (Days)"

    SCRNFL   = "Screened Population Flag"
    ITTFL    = "Intent-to-Treat Population Flag"
    SAFFL    = "Safety Population Flag"
    COMPLFL  = "Study Completion Flag"
    RFSTDTC  = "Subject Reference Start Date/Time"
    RFENDTC  = "Subject Reference End Date/Time"
    EOSSTT   = "End-of-Study Status"
    EOSDT    = "End-of-Study Date"
    DCSREAS  = "Reason for Study Discontinuation"
;
KEEP
    STUDYID USUBJID SUBJID SITEID AGE AGEU AGEGR1 AGEGR1N SEX RACE ETHNIC
    COUNTRY TRT01P TRT01PN TRT01A TRT01AN
    TRTSDT TRTEDT TRTDURD SCRNFL ITTFL SAFFL COMPLFL EOSSTT EOSDT DCSREAS RFSTDTC RFENDTC 
;
RUN;




