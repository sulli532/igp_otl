# *******************************************************************************
# Title: 01_igp.R
# Created by: William Sullivan
# Created on: 9/21/2020
#                     *Purpose: This script demonstrates how the International
#                               Grade Placement index (OTL) is created.
# *******************************************************************************
# 
# The 2012 PISA Survey asks students a number of questions with respect to
# their experience with formal mathematics instruction.

***From  IGP Vars Defined.sas,  in S:\Centers-Inst\CSC\Research\Projects\PISA\2012\PROGRAMS;
***Version from C:\Users\houang\Desktop\MCDA\Current\TraceMap Data\GTTM

*THESE ANALYSES USE THE REVISED FORMAL MATH VARIABLE AND THE IGP VARIABLES BASED ON THE REVISED ST62 ITEMS;
*GET 5-POINT SUMMARY FOR TWO-LEVEL REGRESSIONS OUTPUT TO REGRESSIONS2 EXCEL FILE;
LIBNAME  DATA "X:\Research\Projects\PISA\DATA";
LIBNAME LIBRARY "X:\Research\Projects\PISA\DATA"; 

OPTIONS NODSNFERR NOFMTERR mlogic symbolgen mautosource sasautos="\\Mac\Home\Documents\_Office\TOOLBOX\SAS_Macros";
*******************************************************************************************;
*COMPUTER SCORES IN A DIFFERENT FILE                                                       ;
*******************************************************************************************;
X:\CSC-Archive\Archive_2014\SMSO\PISA\DATA;
LIBNAME  C_DEC03 "X:\CSC-Archive\Archive_2014\SMSO\PISA\DATA\Dec03_DATABASE\CBA\C_data_STQ_DEC17";
DATA CMPTR; SET DATA.L3OTLHBRRCMPTR; RUN;


*Variable definitions in SAS Code *********************************************************;
**********************************************************************************************;
*NOTE: IGNORE ST62Q04 AS THIS IS A FOIL THAT DIDN'T WORK. SO THAT LEAVES 13 TOPICS AND 2 FOILS;
**********************************************************************************************;
*RECODE THOSE ST62 TOPICS WITH IGP>7 AND REDEFINE FORMAL MATH                                 ; 
*COMPUTE IGP ACROSS ALL TOPICS, REDUCE IGP ONLY FOR THOSE ANSWERING "4" OR "5" TO FOILS       ;
*REVISE IGP VALUES FOR SOME TOPICS, FOILS IGP=-1 FOR THOSE ANSWERING "4" OR "5" TO FOILS      ;
**********************************************************************************************;
DATA A2; SET ALL; FOILS=0;
*NOTE: IMPQ11 BASED ON ST62Q11 (IMPQ13 --> ST62Q13). THESE ARE ADJUSTED BY A REGRESSION IMPUTATION BASED ON 
       AGE, GRADE, ESCS and 12 OTHER VARIABLES (+ERROR TERM).  SEE ImputeFoils3.sas for details.
       THE ST62Q_ VARIABLES ARE NOT SUBSTANTIALLY DIFFERENT EXCEPT IN A FEW COUNTRIES, i.e., Albania; 
 IF IMPQ11>3 OR IMPQ13>3 THEN FOILS=4; 
 IF IMPQ11=5 OR IMPQ13=5 THEN FOILS=5;
*RECODE ORIGINAL VARIABLES SO 'NEVER' = 0;
ARRAY O [15] ST62Q01 ST62Q02 ST62Q03 ST62Q06 ST62Q07 ST62Q08 ST62Q09
             ST62Q10 ST62Q11 ST62Q12 ST62Q13 ST62Q15 ST62Q16 ST62Q17 ST62Q19;
ARRAY R [15] R62_01 R62_02 R62_03 R62_06 R62_07 R62_08 R62_09
             R62_10 R62_11 R62_12 R62_13 R62_15 R62_16 R62_17 R62_19;
DO i=1 TO 15; R[i]=O[i]-1; END;
*RECODE ONLY THOSE TOPICS WITH AN IGP > 7 FOR THOSE WHO SELECTED "4" OR "5" ON EITHER OF THE FOILS;
ARRAY O2 [10] ST62Q01 ST62Q03 ST62Q06 ST62Q07 ST62Q08
              ST62Q09 ST62Q10 ST62Q16 ST62Q17 ST62Q19;
ARRAY R2 [10] R62_01 R62_03 R62_06 R62_07 R62_08 R62_09 R62_10 R62_16 R62_17 R62_19;
 IF FOILS=5 THEN DO i=1 TO 10; 
    IF O2[i]=5 THEN R2[i]=2;
    ELSE IF O2[i]=4 THEN R2[i]=1;
    ELSE IF O2[i]=3 THEN R2[i]=0.5;
    ELSE IF O2[i]=2 THEN R2[i]=0;
    ELSE IF O2[i]=1 THEN R2[i]=0; ELSE R2[i]=O2[i]; END; 
 IF FOILS=4 THEN DO i=1 TO 10; 
    IF O2[i]=5 THEN R2[i]=2.5;
     ELSE IF O2[i]=4 THEN R2[i]=1.5;
     ELSE IF O2[i]=3 THEN R2[i]=1;
     ELSE IF O2[i]=2 THEN R2[i]=0;
     ELSE IF O2[i]=1 THEN R2[i]=0; ELSE R2[i]=O2[i]; END; 
ALGR=MEAN(OF R62_01 R62_03 R62_06);
GEOMR=MEAN(OF R62_07 R62_12 R62_15 R62_16);
FORMALMTH=MEAN(OF ALGR GEOMR OTL_2); IF FORMALMTH>3 THEN FORMALMTH=3;
*WORD PROBLEMS AND APPLIED MATH OTL VARS;
ARRAY M [4] ST73Q01 ST74Q01 ST75Q01 ST76Q01;
ARRAY T [4] ST73 ST74 ST75 ST76;
DO i=1 TO 4; IF M[i]>4 THEN M[i]=.; END;
DO i=1 TO 4; T[i]=4-M[i]; END;
COTL_1=ST73; IF ST73=2 THEN COTL_1=1;
OTL_2=ST74; IF ST74>=0 THEN OTL_2=0; IF ST74>=2 THEN OTL_2=1;
OTL_AP=MEAN(OF ST75 ST76); OTL_AP2=OTL_AP*OTL_AP;
*Create IGP weighted ST62 variables;
 ARRAY R3 [13] R62_01 R62_02 R62_03 R62_06 R62_07 R62_08 R62_09 R62_10 R62_12 R62_15 R62_16 R62_17 R62_19; *Codings reduced by FOILS;
 ARRAY G  [13] IV1 IV2 IV3 IV4 IV5 IV6 IV7 IV8 IV9 IV10 IV11 IV12 IV13;  *Items IGP value/weight;
 ARRAY IV [13] (9.5, 3.5, 9.5, 7.75, 9.75, 11.75, 8.5, 7.5, 6.75, 5.81, 9.75, 7.625, 8.875); *TOPIC IGP VALUES;
 ARRAY N  [13] GE_01 GE_02 GE_03 GE_06 GE_07 GE_08 GE_09 GE_10 GE_12 GE_15 GE_16 GE_17 GE_19; *IGP-weighted response value for each item;
DO i=1 TO 13; G[i]=IV[i]; END;

SUM13T=SUM(OF R62_01 R62_02 R62_03 R62_06 R62_07 R62_08 R62_09 R62_10 R62_12 R62_15 R62_16 R62_17 R62_19);
DO i=1 TO 13;
 IF SUM13T=0 OR SUM13T=. THEN N[i]=.;
    ELSE N[i] = R3[i] * G[i]; END; 

SUM13GE=SUM(OF GE_01 GE_02 GE_03 GE_06 GE_07 GE_08 GE_09 GE_10 GE_12 GE_15 GE_16 GE_17 GE_19); 
IGP13F=SUM13GE/142.08;
IGP13Gr=SUM13GE/35.52;  
label
ST62_01   = "0-4 Coding for ST62Q01"
R62_01    = "Foil-Adjusted, 0-4 Coding for ST62Q01"
GE_01     = "IGP Weighted, version of R62_01 (Foil-Adjusted)"
SUM13T    = "Sum of 13 Foil-Adjusted Items"
SUM13GE   = "Sum of 13 IGP Weighted Items"
IGP13F    = "13-Item Formal Math: 1-3 Scale"
IGP13Gr   = "13-Item Formal Math: Grade Level Scale"
COTL_1    = "Word Problems"
OTL_2     = "Dichotomous Coding of ST74"
OTL_AP    = "Applied Math"
OTL_AP2   = "Applied Math, Quadratic"
FORMALMTH = "Formal Math, IGP version"; RUN;
