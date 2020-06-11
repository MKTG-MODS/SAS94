/* Specify a host and port that are valid for your site.*/
options cashost='rccsasprd02.redcross.net' casport=5570 ; 

/* Specify location of authinfo file */
/*cas AUTHINFO="/home/hallm/.authinfo" CASSERVERMD="rccsasprd02.redcross.net"*/

cas casauto host="rccsasprd02.redcross.net" port=5570 AUTHINFO="/home/hallm/.authinfo";

/* The LIST option for the CASLIB statement writes out the settings for the specified caslib.*/
caslib casuser list;

caslib _all_ assign;

/* To read and write data to and from the caslib using traditional SAS PROCs and the DATA step, 
you must associate a libref with the caslib using the LIBNAME statement with the CAS engine. */

/* This statement associates the mycas libref with the Casuser caslib */
libname mycas cas caslib=casuser;

/* There are three ways to read in data from the SAS client to the CAS server: */

/**************************************/
/* 1. Using the DATA STEP to load CAS */
/**************************************/
/* The CARS table now exists in the Casuser caslib.*/
data mycas.cars;
   set sashelp.cars;
run;

/**************************************/
/* 2. Using PROC CASUTIL to load CAS  */
/**************************************/
proc casutil;
   load file='/home/hallm/sas_data/csv/cars.xls' 	/* 1 */
   casout='cars2' outcaslib='casuser' 				/* 2 */
   importoptions=(filetype='xls' getnames=true); 	/* 3 */
quit;

/* 1. The file= option points to the file to be read in. */
/* 2. The casout= option names the output table and the outCaslib= option designates the output caslib. */
/* 3. The importOptions= option enables you to specify the options used when importing the file. */
/*    - The fileType= option specifies the import file type */
/*    - The GETNAMES statement determines whether the first line of data is used to create the variable names for that file. */


/**************************************/
/* 3. Using PROC CAS to load CAS      */
/**************************************/
/* PROC CAS enables you to interact with CAS by executing the CAS language (CASL). */
/* CASL interacts with the server by enabling you to run CAS actions, */
/* which are requests to perform tasks on the server. */
*/

 /* drop a caslib */
/* caslib csvlib drop; */

proc cas;
table.dropcaslib / caslib='csvlib' quiet=false;
run;

/* The following PROC CAS code uses the addCaslib and loadTable actions to read in the cars.csv file. */
proc cas;
   session casauto;
   table.addcaslib 				/* 1 */
      caslib='csvlib'
      datasource={srctype='path'}
      path='/home/hallm/sas_data/csv';
   run;
   table.loadtable /		    /* 2 */
      path='cars123.csv'
      casout={caslib='casuser',name='cars3'}
      importoptions={filetype='csv',getnames='true'};
quit;

/* 1. The addCaslib action adds the Csvlib caslib, which contains the information about the location of the file being read in. 
/*    - The SrcType='path' parameter states that the file being read in is located in the directory listed on the path= parameter.
/* 2. The loadTable action indicates the name of the file being read in and the name of the output table. 
/*    - The path= parameter names the input file */
/*    - The caslib= parameter specifies the output caslib */
/*    - The name= parameter designates the output table */
/*    - The fileType= parameter specifies the input file type */
/*    - The getNames= parameter tells the loadTable action to use the first row of data for the variable names in the table */











proc cas;
  session casauto;
  
/* Create copy of HEART in SAS 9.4 WORK library */
   PROC COPY in=sashelp out=work ;
   SELECT heart ;
   run;

   %let myserver="rccsasprd02.redcross.net" 5570;
   SIGNON myserver user=HallM passwd="Pogo005!";
   rsubmit;
   
/* Allocate CAS library named MYCAS as sasdemo */
   libname MYCAS CAS
     caslib="CASUSER"
     host="rccsasprd02.redcross.net" 
     port=5570 ;
 
/* Upload HEART dataset from SAS 9.4 WORK to CAS library */
   PROC UPLOAD data=heart
   out=mycas.heart94; 
   run;
   
/* Perform simple CAS analytics */
   PROC MDSUMMARY data=mycas.heart94 ;
     GROUPBY deathcause;
     VAR cholesterol systolic diastolic ;
   output out=mycas.heartsum94; 
   run;
   
/* Verify CAS datasets in CAS library */
   PROC DATASETS lib=mycas; 
   run;

   PROC PRINT data=mycas.heartsum94; run;
endrsubmit ;
signoff ;

cas casauto terminate;
cas casauto disconnect;