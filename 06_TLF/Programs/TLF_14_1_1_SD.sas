/*********************************************
PROGRAM   : TLF_14_1_1_SUBJECT DISPOSITION.SAS
STUDY     : HTN001
OUTPUT    : TABLE 14.1.1 SUBJECT DISPOSITON
PURPOSE   : PRODUCE SUBJECT DISPOSITION TABLE
PROGRAMMER: SHANMUGAM M
***********************************************/
libname ADAM "/home/u64365683/ADaM";
libname TLF  "/home/u64365683/TLF";

PROC CONTENTS DATA=ADAM.ADSL VARNUM;
RUN;
PROC PRINT DATA=ADAM.ADSL(OBS=5);
VAR USUBJID TRT01P TRT01A SAFFL COMPLFL;
RUN;
proc freq data=adam.adsl;
    tables trt01a*compLfl /OUT=dis outpct missing;
run;
proc print data=dis;
run;
data dis_re;
length category $40 result $20 TRTID $15;
set dis;
if complfl="Y" then do 
order=1;
category=upcase("completed study");
end;
else if complfl="N" then do
order=2;
category=upcase("Discontiuned study");
end;
if trt01a="DRUG A" then trtid="DRUG_A";
else if trt01a="PLACEBO" then trtid="PLACEBO";
result=cats(put(count,3.)," (",put(pct_row,5.1),"%)");
run;
proc sort data=dis_re;
    by order category;
run;
proc print data=dis_re;
run;

proc transpose data=dis_re
               out=dis_trans(drop=_name_);
    by order category;
    id trtID;
    var result;
    RUN;

ODS LISTING CLOSE;
ODS RTF
FILE="/home/u64365683/TLF/T14_1_1_Subject_Disposition.rtf"
STYLE=JOURNAL;
TITLE1 "PROTOCOL HTN001";
TITLE2 "TABLE 14.1.1";
TITLE3 "SUBJECT DISPOSITION";
TITLE4 "SAFETY POPULATION";
footnote1 "Note: Percentages are based on the number of subjects in each treatment group.";
footnote2 "Source: ADaM ADSL";
    proc report data=dis_trans nowd;
    column order category drug_a placebo;

    define order /
        order
        noprint;

    define category /
        display
        "Study Disposition";

    define DRUG_A /
        display
        "Drug_A|(N=60)";

    define placebo /
        display
        "Placebo|(N=60)";
run;
ODS RTF CLOSE;
ODS LISTING;
TITLE;
FOOTNOTE;

proc contents data=dis_trans varnum;
run;

