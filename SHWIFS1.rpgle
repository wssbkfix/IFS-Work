**free
ctl-opt option(*nodebugio:*srcstmt:*nounref) dftactgrp(*no) ;

dcl-pr getBaseFolder  char(30) ;
   *n char(200) ; 
   *n int(10) ;
end-pr ; 

dcl-ds PgmDs psds qualified ;
PgmName *proc ;
end-ds ;

dcl-s filePos like(Path_Name) ;
dcl-s stPos int(10) ;

dcl-f shwIFS1  workstn indds(Dspf) sfile(SFL01:Z1RRN) ;

dcl-c MaxSfl 9999 ;

dcl-ds Dspf qualified ;
    Exit ind pos(3) ;
    Refresh ind pos(5) ;
    SflDspCtl ind pos(30) ;
    SflDsp ind pos(31) ;
end-ds ;

dcl-f PATHIFS  keyed ;

dcl-s PrvPosition like(Z1POSITION) ;

Z1SCREEN = %trimr(PgmDs.PgmName) + '-1' ;

setll *loval PATHIFSR ;
read PATHIFS ;
SETLL *loval PATHIFSR ; 
LoadSubfile() ;


dow (1 = 1) ;
    write REC01 ;
    exfmt CTL01 ;

    if (Dspf.Exit) ;
        leave ;
    elseif (Dspf.Refresh) ;
        Z1POSITION = ' ' ;   
        PrvPosition = ' ' ;  
        setll *loval PATHIFSR  ;
        read PATHIFS ;
        setll *loval PATHIFSR ;
        LoadSubfile() ;
        iter ;
    elseif (Z1POSITION <> PrvPosition) ;
        PrvPosition = Z1POSITION ;
        filePos = Z1POSITION ;
        setll filePos PATHIFSR ;
        read PATHIFS ;
        SETLL filePos PATHIFSR ; 
        LoadSubfile() ;
        iter ;
    endif ;

    if (Dspf.SflDsp) ;
        ReadSubfile() ;
    endif ;
enddo ;

*inlr = *on ;

dcl-proc LoadSubfile ;
  Dspf.SflDspCtl = *off ;
  Dspf.SflDsp = *off ;
  write CTL01 ;
  Dspf.SflDspCtl = *on ;
  Z1OPT = ' ' ;
  scattr = 'CCSID' ; 
  scfldr = getBaseFolder(path_name
                        :stPos) ; 

  for Z1RRN = 1 to MaxSfl ;
    read PATHIFS ;
    if (%eof) ;
      leave ;
    endif ;
    scpath = %subst(path_name: stPos : 30) ;
    scdesc  = OBJTXT  ;
    scattr2 = %char(CCSID) ; 

    write SFL01 ;
  endfor ;
  if (Z1RRN > 1) ;
    Dspf.SflDsp = *on ;
  endif ;
end-proc ;
dcl-proc ReadSubfile ;
  dow (1 = 1) ;

    readc SFL01 ;
    if (%eof) ;
      leave ;
    endif ;
 //something depending on value in Z1OPT
    Z1OPT = ' ' ;
    update SFL01 ;
  enddo ;
end-proc ;

dcl-proc getBaseFolder ;

dcl-pi *n char(30) ;
  wkPathName Char(200) ;
  stPos int(10) ; 
end-pi ;

  stPos = %scan('WSSBKFIX2' : wkPathName) ; 
  stPos = %scan('/': wkPathName : stPos) ;
  return %subst(wkPathName: 1: stPos); 
end-proc ;
