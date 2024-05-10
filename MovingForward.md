# Main
**in design phase status: design no objects**  
A simple program that reads a list of files from the IFS.  The big take-away is not a utility that will save the world but to look at some of the tools that will help manage the IFS. I see the following challenges: 
1- For Display files, you can compile from the IFS, the command does know about the IFS. Could a utity be build that moves the source to a member and then compiles it. 
2- IFS has  a unix tree structure. It is possible that source member names could be dplicated accross folders. Would a check for that be desirable? 
3- Source is in both IFS files and source members.  ONe might want to verify that no dplication is taking place? 
4- You are looking for source but don't know what folder it is in.  A nice search utility could be created. In an emergency, a one of the table functions could be used 

The above list could go on, but with a easy way to view the IFS and source members we can get a better handle of the resources in the folder structure.  

The plan is to modify the simple that we started with and to come up with a utility that will build the file listing IFS objects and then display with improved filtering and navigation. 

There will be a SHWIFS2 version of the utility. For now the functionalty will include the following: 
1- A filter screen to setup what files in the IFS will be picked up. 
2- an ability to look at the attributes of an entry.  
3- A stats function that will show the data used for each 

