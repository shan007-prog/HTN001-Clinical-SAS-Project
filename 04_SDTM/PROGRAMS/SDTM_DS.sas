/**************************************************************************
Program    : ds.sas
Study      : HTN001
Domain     : DS
Purpose    : Create SDTM DS dataset
Programmer : Shanmugam M
Date       : 21-Jul-2026
**************************************************************************/

LIBNAME RAW '/home/u64365683/RAW';
LIBNAME SDTM '/home/u64365683/SDTM';

PROC SORT DATA=RAW.DS OUT= DS_SORT;
BY USUBJID DSSEQ;
RUN;
PROC SORT DATA=SDTM.DM OUT=DM_REF(KEEP=USUBJID RFSTDTC) NODUPKEY;
BY USUBJID;
RUN;
DATA DS_PREP;
LENGTH USUBJID $40;
MERGE DS_SORT(IN=A) DM_REF(IN=B);
BY USUBJID ;
IF A;
RUN;

OPTIONS ERRORS=100;

DATA SDTM.DS;
LENGTH
STUDYID $20
DOMAIN $2
USUBJID $40
DSSEQ 8
DSTERM $200
DSDECOD $200
DSCAT $40
DSSCAT $40
DSSTDTC $19
DSSTDY 8
EPOCH $40;
SET ds_prep(RENAME=(DSSTDTC=RAW_DSSTDTC DSSEQ=RAW_DSSEQ));
BY USUBJID;
DOMAIN="DS";
DSSCAT="STUDY PARTICIPATION";
DSSTDTC=PUT(RAW_DSSTDTC,E8601DA.);	
RFSTDT=INPUT(SUBSTR(RFSTDTC,1,10),YYMMDD10.);
IF RAW_DSSTDTC >= RFSTDT THEN DSSTDY=RAW_DSSTDTC-RFSTDT+1;
ELSE DSSTDY=RAW_DSSTDTC-RFSTDT;
IF FIRST.USUBJID THEN DSSEQ=1;
ELSE DSSEQ+1;
label
    STUDYID = "Study Identifier"
    DOMAIN  = "Domain Abbreviation"
    USUBJID = "Unique Subject Identifier"
    DSSEQ   = "Sequence Number"
    DSTERM  = "Reported Term for the Disposition Event"
    DSDECOD = "Standardized Disposition Term"
    DSCAT   = "Disposition Category"
    DSSCAT  = "Disposition Subcategory"
    EPOCH   = "Epoch"
    DSSTDTC = "Disposition Date/Time of Event"
    DSSTDY    = "Study Day of Disposition Event";
KEEP STUDYID DOMAIN USUBJID DSSEQ DSTERM DSDECOD DSCAT DSSCAT EPOCH DSSTDTC DSSTDY;
RUN;

