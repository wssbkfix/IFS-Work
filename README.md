# IFS Work General Description
The iSeries has always been good at communicating are its resources and describing them.  
The iFS is no exception. I have been working on PUB400 and notice that I was coming up 
against my data limits.  I did some looking around and noticed that the data storage needs 
are a lot less using the IFS to store source than using the Source file system with 
individual members. Seemed like a no brainer to move at least my RPG sourse over to the IFS. 
It's a bit cumersome to complie IFS files on the green screen but Visual Studio Code made it 
fairly easy. I did have some problems with the CCSID I was using for the IFS. It seems that 
usng 1208 instead of 1252 was causing comipile issues with the embedded SQL programs.  I found 
the need to check the CCSID of each source member. I found the some SQL views that listed 
the IFS files I needed to check. I also needed to get a list of of physical file source members. 
There are multiple ways of doing this but I decided to also use a SQL view to do this.  

Running SQL statements against those views gave me want I needed. I wrote some CLLE programs that copied files from the IFS to 
physical file source members, and then back to the IFS. I could use the translation defaults in using CPYFRMSTMF command to get
IFS files to the source members. On copying members back to the IFS I made sure the target had the *PCASCII value to the CCSID for the 
IFS files.  

After doing all of that, I was motivated to develop a simple utility to view the IFS program source files. With some filtering, I got 
what I wanted. It is a very simple program that lists my program source, and display files on the IFS.  

# The Compnents 

## SQL Views 
### QSYS2.IFS_OBJECT_STATISTICS
This view will detail out all the IFS files as well as physical file source members 
There are two parameters for this view: The first is the path to display.  The second is whether subdirectories are wanted
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
If you have more than one source file then you could create a second table 
with just source physical files and then do a join against it. 

SQL for that might look like this: 
SELECT SYSTEM_TABLE_SCHEMA, SYSTEM_TABLE_NAME, TABLE_TYPE, FILE_TYPE,TABLE_TEXT 
FROM QSYS2.SYSTABLES 
WHERE SYSTEM_TABLE_SCHEMA = 'ScottK'
 and   FILE_TYPE = 'S' 
 and  TABLE_TYPE = 'P'  
    
