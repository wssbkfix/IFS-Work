# IFS Work General Description
The iSeries has always been good at communicating are its resources and describing them.  
The iFS is no exception. I have been working on PUB400 and notice that I was coming up 
against my data limits.  I did some looking around and noticed that the data storage needs 
are a lot less using the IFS to store source than using the Source file system with 
individual members. Seemed like a no brainer to move at least my RPG source over to the IFS. 
It's a bit cumbersome to compile IFS files on the green screen but Visual Studio Code made it 
fairly easy. I did have some problems with the CCSID I was using for the IFS. It seems that 
using 1208 instead of 1252 was causing compile issues with the embedded SQL programs.  I found 
the need to check the CCSID of each source member. I found some SQL views that listed 
the IFS files I needed to check. I also needed to get a list of physical file source members. 
There are multiple ways of doing this, but I decided to also use a SQL view to do this.  

Running SQL statements against those views gave me what I needed. I wrote some CLLE programs that copied files from the IFS to 
physical file source members, and then back to the IFS. I could use the translation defaults in using CPYFRMSTMF command to get
IFS files to the source members. On copying members back to the IFS I made sure the target had the *PCASCII value to the CCSID for the 
IFS files.  

After doing all of that, I was motivated to develop a simple utility to view the IFS program source files. With some filtering, I got 
what I wanted. It is a simple program that lists my program source, and displays IFS files.  

# The Components 

## SQL Views 
### QSYS2.IFS_OBJECT_STATISTICS
This view will detail all the IFS files as well as physical file source members. There are two parameters for this view: The first is the path to display. The second is whether subdirectories are wanted 
 Example:  FROM TABLE(QSYS2.IFS_OBJECT_STATISTICS('/home/WSSBKFIX2', 'YES')) In this case, I wanted all of the subdirectories under   
 /home/WSSBKFIX2  
filtering note: To filter out any data files you can add to the where clause Path_name that ends in .RPGLE, SQLRPGLE ... (any source type you want) 

 
 To bring up the members from a physical source file I did the following 
     FROM TABLE('QSYS.LIB/WSSBKFIX21.LIB/QPRGLESRC' , 'NO'))  

### FROM QSYS2.SYSPARTITIONSTAT Alternate to get member views. 
This view will detail out all of the members in a source physical file.  
Example:  SELECT SYSTEM_TABLE_SCHEMA  AS Library,  
        SYSTEM_TABLE_NAME AS File,  
        TO_CHAR(COUNT(*),'999G999') AS Nombrs  
    FROM QSYS2.SYSPARTITIONSTAT  
   WHERE SYSTEM_TABLE_SCHEMA = 'WSSBKFIX21'  
    AND  SYSTEM_TABLE_SCHEMA = 'QRPGLESRC'  

       
If you have more than one source file, then you could create a second table 
with just source physical files and then do a join against it.  

SQL for that might look like this: 
SELECT SYSTEM_TABLE_SCHEMA, SYSTEM_TABLE_NAME, TABLE_TYPE, FILE_TYPE,TABLE_TEXT  
FROM QSYS2.SYSTABLES  
WHERE SYSTEM_TABLE_SCHEMA = 'ScottK'  
 and   FILE_TYPE = 'S'  
 and  TABLE_TYPE = 'P'  
    
## OBJECTS 
### PATHIFS file.  
This is the input file to the program that was created by running the following: SQL statements 
**1- Create the file** 
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
Note the following: 
old school Record format name to accomodate the RPG program 
old school Primary key to accomodate the RPG program 

**2- Populate the file** 
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

Note: 
The where clause eliminates all but the source files in the IFS

### SHWIFS1 Display file 
This is a simple subfile program with a subfile and page size the same 9999. 

### SHWIFS1 rpg program 
SHWIFS1: This is a simple program that reads the PATHIFS file (created by running the QSY2.IFS_OBJECT_STATISTICS view) It is a non-elastic subfile 
where the system takes care of all of the paging.  Counting on less than 9999 records in the subfile.  

No SQL in this program, just simple F spec access.  It is completely in free.  

## Setup 
1- Create the PATHIFS table 
2- Populate the PATHIFS table. You can make this table small or large depending on the where clause  
3- Run program CALL SHOWIFS1    
   You can use the position to option to navigate the list.   
4- run update query to populate the TEXT_DESCRIPTION field if it   
   is null  

# References 
1- The SHWIFS1 program and display file  
This was taken from a sample on the web.  
URL: [sample program] ('https://www.rpgpgm.com/2016/05/example-subfile-program-using-modern-rpg.html')
You will notice that I modified the program a little to read a different file and display different fields. Other than that, it is very much the same. The url documents the program very well 

2- QSYS2.IFS_OBJECT_STATISTICS table fuction. Lists IFS files  
The link below documents the view and the fields it picks up well.  
URL: [view for IFS ] (https://www.ibm.com/docs/en/i/7.4?topic=services-ifs-object-statistics-table-function)  

3- QSYS2.SYSPARTITIONSTAT table function. Lists source members.  
Technically, this can list a lot more that source members but with the correct where clause this is easy to figure out.  
This is not used in the SHWIFS1 program, but I use it when I need a list of source members.  
URL: [View Src Mbrs] (https://www.ibm.com/docs/en/i/7.4?topic=views-syspartitionstat)   

