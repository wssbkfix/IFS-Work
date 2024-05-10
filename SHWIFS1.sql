/* The following are the steps to create the PATHIFS file 
which is the input file for the SHWIFS1 program.  
This file must be created and populated with the code below
If one wants to change what is picked up in the file, one can just clear 
the file and repopulated it.
Any references to Path should be change to reflect 
your situation. 
*/  


/* create the file ------------------------*/
CREATE OR REPLACE TABLE WSSBKFIX21.PATHIFS
(PATH_NAME   CHAR(200), 
 OBJECT_TYPE FOR COLUMN OBJTYP CHAR(10) , 
 CREATE_TIMESTAMP FOR COLUMN CRTMSTMP TIMESTAMP,
 LAST_USED_TIME_STAMP FOR COLUMN LSTTMSTMP TIMESTAMP,
 DATA_SIZE INTEGER, 
 CCSID INTEGER, 
  TEXT_DESCRIPTION FOR COLUMN OBJTXT CHAR(50), 
 PRIMARY KEY (PATH_NAME)
 ) RCDFMT PATHIFSR  
;

/* Populate the file PATHIFS file --------*/
INSERT INTO WSSBKFIX21.PATHIFS 
(PATH_NAME, 
 OBJECT_TYPE,
 CREATE_TIMESTAMP,
 LAST_USED_TIME_STAMP, 
 DATA_SIZE, 
 CCSID,  
 TEXT_DESCRIPTION ) 
 
SELECT PATH_NAME,OBJECT_TYPE,CREATE_TIMESTAMP,LAST_USED_TIMESTAMP,
       DATA_SIZE, CCSID, TEXT_DESCRIPTION 
FROM TABLE(QSYS2.IFS_OBJECT_STATISTICS('/home/WSSBKFIX2', 'YES'))
WHERE 
upper(PATH_NAME) 
LIKE '%.RPGLE' 
OR 
upper(PATH_NAME) 
LIKE '%.SQLRPGLE'
OR
upper(PATH_NAME) LIKE '%.DSPF'
OR 
upper(PATH_NAME) LIKE '%.PF'
OR 
upper(PATH_NAME) LIKE '%.LF'     
ORDER BY PATH_NAME
;

/* replace nulls in TEXT_DESCRIPTION -----*/
 with literal "no Desc" 

UPDATE WSSBKFIX21.PATHIFS  
SET TEXT_DESCRIPTION = 'no Desc' 
WHERE TEXT_DESCRIPTION IS NULL
;
