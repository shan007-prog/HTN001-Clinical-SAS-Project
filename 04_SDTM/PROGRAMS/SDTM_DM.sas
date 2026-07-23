/**************************************************************************
Program : dm.sas
Study   : HTN001
Domain  : DM
Purpose : Create SDTM DM dataset
Programmer : Shanmugam M
Date : 17-Jul-2026
**************************************************************************/
LIBNAME RAW '/home/u64365683/RAW';
LIBNAME SDTM '/home/u64365683/SDTM';

PROC SORT DATA=RAW.DM OUT=RAW_DM_SORT;
BY USUBJID;
RUN;
PROC SORT DATA=RAW.EX OUT=RAW_EX_SORT;
BY USUBJID;
RUN;
DATA  SDTMPREP ;
MERGE RAW_DM_SORT(in=a) RAW_EX_SORT(in=b) ;
BY USUBJID;
if a;
RUN;

Data sdtm.DM;
length STUDYID $20
DOMAIN $2
USUBJID $40
SUBJID $20
SITEID $10
RFSTDTC $19
RFENDTC $19
RFXSTDTC $19
RFXENDTC $19
RFICDTC $19
AGE 8
AGEU $10
SEX $1
RACE $100
ETHNIC $100
ARM $200
ARMCD $20
ACTARM $200
ACTARMCD $20
COUNTRY $3
;
set SDTMPREP(rename=(SEX=GENDER)
             drop=COUNTRY);

DOMAIN="DM";

RFICDTC  = put(CONSENTDT,e8601da.);
RFSTDTC  = put(EXSTDTC,e8601da.);
RFENDTC  = put(EXENDTC,e8601da.);
RFXSTDTC = put(EXSTDTC,e8601da.);
RFXENDTC = put(EXENDTC,e8601da.);

AGEU="YEARS";

ACTARM=EXTRT;
ACTARMCD=EXTRT;

COUNTRY="IND";

if upcase(strip(GENDER))="MALE" then SEX="M";
else if upcase(strip(GENDER))="FEMALE" then SEX="F";
else SEX="";
 label
        STUDYID   = "Study Identifier"
        DOMAIN    = "Domain Abbreviation"
        USUBJID   = "Unique Subject Identifier"
        SUBJID    = "Subject Identifier for the Study"
        RFSTDTC   = "Subject Reference Start Date/Time"
        RFENDTC   = "Subject Reference End Date/Time"
        RFXSTDTC  = "Date/Time of First Study Treatment"
        RFXENDTC  = "Date/Time of Last Study Treatment"
        RFICDTC   = "Date/Time of Informed Consent"
        SITEID    = "Study Site Identifier"
        AGE       = "Age"
        AGEU      = "Age Units"
        SEX       = "Sex"
        RACE      = "Race"
        ETHNIC    = "Ethnicity"
        ARMCD     = "Planned Arm Code"
        ARM       = "Description of Planned Arm"
        ACTARMCD  = "Actual Arm Code"
        ACTARM    = "Description of Actual Arm"
        COUNTRY   = "Country" ;
KEEP STUDYID DOMAIN USUBJID SUBJID RFSTDTC RFENDTC RFXSTDTC RFXENDTC RFICDTC SITEID AGE AGEU SEX RACE ETHNIC ARMCD ARM ACTARM ACTARMCD COUNTRY;
RUN;

