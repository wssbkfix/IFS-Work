# IFS Work General Description
The iSeries has always been good at communicating are its resources and describing them.  The iFS is no exception. I have been working on 
PUB400 and notice that I was coming up against my data limits.  I did some looking around and 
noticed that the data storage needs are a lot less using the IFS to store source than 
using the Source file system with individual members. Seemed like a no brainer to move at least my RPG sourse 
over to the IFS. It's a bit cumersome to complie IFS files on the green screen but Visual Studio Code made it 
fairly easy. I did have some problems with the CCSID I was using for the IFS. It seems that usng 1208 instead of 
1252 was causing comipile issues with the embedded SQL programs.  I found the need to check the CCSID of each source 
member. I found the some SQL views that listed the IFS files I needed to check. I also needed to get a list of of physical file
source members. There are multiple ways of doing this but I decided to also use a SQL view to do this.  

Running SQL statements against those views gave me want I needed. I wrote some CLLE programs that copied files from the IFS to 
physical file source members, and then back to the IFS. I could use the translation defaults in using CPYFRMSTMF command to get
IFS files to the source members. On copying members back to the IFS I made sure the target had the *PCASCII value to the CCSID for the 
IFS files.  

After doing all of that, I was motivated to develop a simple utility to view the IFS program source files. With some filtering, I got 
what I wanted. It is a very simple program that lists my program source, and display files on the IFS.  
