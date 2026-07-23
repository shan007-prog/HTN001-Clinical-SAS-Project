/*QC VALIDATION*/

/*EX-QC-001*/
PROC CONTENTS DATA=SDTM.EX;
RUN;

/*EX-QC-002*/
data qc_ex_treatment;
    set sdtm.ex;

    if extrt not in ("DRUG A", "PLACEBO");
run;

proc freq data=sdtm.ex;
    tables extrt / missing;
run;

/*EX-QC-003*/
data qc_ex_dose;
    set sdtm.ex;

    length issue $150;

    if extrt="DRUG A" then do;
        if exdose ne 50 then
            issue="Drug A dose is not 50";

        else if exdosu ne "mg" then
            issue="Drug A dose unit is not mg";
    end;

    else if extrt="PLACEBO" then do;
        if not missing(exdose) then
            issue="Placebo EXDOSE should be missing";

        else if not missing(exdosu) then
            issue="Placebo EXDOSU should be missing";
    end;

    if not missing(issue);
run;
/*EX-QC-004*/
data qc_ex_route;
    set sdtm.ex;

    if exroute ne "ORAL";
run;

proc freq data=sdtm.ex;
    tables exroute / missing;
run;
/*EX-QC-005*/
data qc_ex_frequency;
    set sdtm.ex;

    if exdosfrq ne "QD";
run;

proc freq data=sdtm.ex;
    tables exdosfrq / missing;
run;
/*EX-QC-006*/
proc sort data=sdtm.ex out=qc_ex_sort;
    by usubjid;
run;

proc sort data=sdtm.dm(
              keep=usubjid rfstdtc
          )
          out=qc_dm_ref
          nodupkey;
    by usubjid;
run;

data qc_ex_dates;
    merge qc_ex_sort(in=a)
          qc_dm_ref;
    by usubjid;

    if a;

    length issue $200;

    exstdt = input(substr(exstdtc,1,10),yymmdd10.);
    exendt = input(substr(exendtc,1,10),yymmdd10.);
    rfstdt = input(substr(rfstdtc,1,10),yymmdd10.);

    format exstdt exendt rfstdt date9.;

    if not missing(exstdt) and not missing(rfstdt) then do;
        if exstdt >= rfstdt then
            qc_exstdy = exstdt-rfstdt+1;
        else
            qc_exstdy = exstdt-rfstdt;
    end;

  if exendt >= rfstdt then;
            qc_exendy = exendt-rfstdt+1;
  else
            qc_exendy = exendt-rfstdt;
            
    if missing(exstdt) then
        issue="Invalid or missing EXSTDTC";

    else if missing(exendt) then
        issue="Invalid or missing EXENDTC";

    else if exendt < exstdt then
        issue="EXENDTC is earlier than EXSTDTC";

    else if exstdy ne qc_exstdy then
        issue="EXSTDY derivation mismatch";

    else if exendy ne qc_exendy then
        issue="EXENDY derivation mismatch";

    if not missing(issue);
run;

/*EX-QC-004*/