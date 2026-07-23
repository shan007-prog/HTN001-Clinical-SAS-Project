

/*QC VALIDATION*/


/*DM-QC-001*/
proc contents data=sdtm.dm;
run;

/*DM-QC-002*/
PROC SQL;
SELECT COUNT(*) AS TOAT_SUBJECT
FROM SDTM.DM;
QUIT;

/*DM-QC-003*/
PROC SORT DATA=SDTM.DM OUT=DM_QC NODUPKEY DUPOUT=DM_DUP;
BY USUBJID;
RUN;

/*DM-QC-004*DM-QC-005*DM-QC-006*/
proc contents data=sdtm.dm varnum;
run;

/*DM-QC-007*/
proc freq data=sdtm.dm;
table domain /missing;
run;

/*DM-QC-008*/
proc freq data=sdtm.dm;
table STUDYID /missing;
run;

/*DM-QC-009*/
%MACRO MISSCHK(X);
IF MISSING(&X)THEN DO;
 ISSUE="Missing &x";
 OUTPUT;
 END;
 %MEND;
 
DATA DM_MISS;
SET SDTM.DM;
LENGTH ISSUE $100.;

    %misschk(STUDYID)
    %misschk(DOMAIN)
    %misschk(USUBJID)
    %misschk(SUBJID)
    %misschk(SITEID)
    %misschk(RFSTDTC)
    %misschk(RFICDTC)
    %misschk(AGE)
    %misschk(AGEU)
    %misschk(SEX)

KEEP USUBJID ISSUE;
RUN;
/*DM-QC-010*/
PROC SORT DATA=SDTM.DM OUT=DM_QC NODUPKEY DUPOUT=DM_DUP;
BY USUBJID;
RUN;

/*DM-QC-011*/
proc freq data=sdtm.dm;
    tables sex / missing;
run;
data dm_sex_issue;
    set sdtm.dm;

    if sex not in ("M","F");
run;

proc print data=dm_sex_issue;
    var USUBJID SEX;
run;

/*DM-QC-012*/
proc freq data=sdtm.dm;
    tables age / missing;
run;
data dm_age_issue;
    set sdtm.dm;

    if missing(age) or age < 18 or age > 80;
run;

proc print data=dm_age_issue;
    var USUBJID AGE AGEU;
run;

/*DM-QC-013*/
proc freq data=sdtm.dm;
    tables ageu / missing;
run;
data dm_ageu_issue;
    set sdtm.dm;

    if strip(ageu) ne "YEARS";
run;

proc print data=dm_ageu_issue;
    var USUBJID AGE AGEU;
run;

/*DM-QC-014*/
proc freq data=sdtm.dm;
    tables country / missing;
run;
data dm_country_issue;
    set sdtm.dm;

    if strip(country) ne "IND";
run;

proc print data=dm_country_issue;
    var USUBJID SITEID COUNTRY;
run;

/*DM-QC-015*/
proc freq data=sdtm.dm;
    tables arm actarm;
run;
proc freq data=sdtm.dm;
    tables arm
           actarm
           arm*actarm / missing;
run;
data dm_arm_issue;
    set sdtm.dm;

    if upcase(strip(arm)) ne upcase(strip(actarm));
run;

proc print data=dm_arm_issue;
    var usubjid arm armcd actarm actarmcd;
run;

/*DM-QC-016*/

proc sort data=sdtm.dm out=dm_sdtm;
    by usubjid;
run;
proc sort data=raw.dm out=dm_raw;
by usubjid;
run;
proc sort data=raw.ex out=ex_raw;
    by usubjid;
run;

data dm_rficdtc_issue;
    merge dm_sdtm(in=a keep=usubjid rficdtc)
          dm_raw(in=b keep=usubjid consentdt);
    by usubjid;

    length expected_rficdtc $19 issue $100;

    if a;

    expected_rficdtc = put(consentdt,e8601da.);

    if rficdtc ne expected_rficdtc then do;
        issue = "RFICDTC does not match CONSENTDT";
        output;
    end;

    keep usubjid consentdt rficdtc expected_rficdtc issue;
run;

proc print data=dm_rficdtc_issue;
run;

/*DM-QC-017*/

data dm_rfstdtc_issue;
    merge dm_sdtm(in=a keep=usubjid rfstdtc)
          ex_raw(in=b keep=usubjid exstdtc);
    by usubjid;

    length expected_rfstdtc $19 issue $100;

    if a;

    expected_rfstdtc = put(exstdtc,e8601da.);

    if rfstdtc ne expected_rfstdtc then do;
        issue = "RFSTDTC does not match EXSTDTC";
        output;
    end;

    keep usubjid exstdtc rfstdtc expected_rfstdtc issue;
run;

proc print data=dm_rfstdtc_issue;
run;

/*DM-QC-018*/

data dm_rfendtc_issue;
    merge dm_sdtm(in=a keep=usubjid rfendtc)
          ex_raw(in=b keep=usubjid exendtc);
    by usubjid;

    length expected_rfendtc $19 issue $100;

    if a;

    expected_rfendtc = put(exendtc,e8601da.);

    if rfendtc ne expected_rfendtc then do;
        issue = "RFENDTC does not match EXENDTC";
        output;
    end;

    keep usubjid exendtc rfendtc expected_rfendtc issue;
run;

proc print data=dm_rfendtc_issue;
run;
