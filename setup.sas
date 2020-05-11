/* Required Step */
/* SPRE Enabled */
/* Sets the SAS macro variable &DATAPATH */
/* Copy data used in the CAS coding examples to the path defined by the macro variable &DATAPATH */
/* Macro &DATAPATH is used in the CAS coding examples */

/* Specify a host and port that are valid for your site.*/
options cashost='rccsasprd02.redcross.net' casport=5570 ; 

cas mySession host="rccsasprd02.redcross.net" port=5570 AUTHINFO="/home/hallm/.authinfo";
/* cas casauto host="rccsasprd02.redcross.net" port=5570 AUTHINFO="/home/hallm/.authinfo"; */

/* Set DATAPATH to a path known to your SAS Viya environment */
/* For parallel loading via a CASLIB ensure the paths is known to all CAS worker nodes as well as the CAS controler node */
/* Due to the data sizes used in all examples parallel loading is not a requirement */
%let datapath = /home/hallm/sas_data;
%put datapath;

libname sas7bdat "&datapath";

libname sas7bdat cas caslib=casuser;


proc copy in=sashelp out=sas7bdat;
   select baseball cars heart;
run;
