Copyright>        OpenRadioss
Copyright>        Copyright (C) 1986-2023 Altair Engineering Inc.
Copyright>
Copyright>        This program is free software: you can redistribute it and/or modify
Copyright>        it under the terms of the GNU Affero General Public License as published by
Copyright>        the Free Software Foundation, either version 3 of the License, or
Copyright>        (at your option) any later version.
Copyright>
Copyright>        This program is distributed in the hope that it will be useful,
Copyright>        but WITHOUT ANY WARRANTY; without even the implied warranty of
Copyright>        MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
Copyright>        GNU Affero General Public License for more details.
Copyright>
Copyright>        You should have received a copy of the GNU Affero General Public License
Copyright>        along with this program.  If not, see <https://www.gnu.org/licenses/>.
Copyright>
Copyright>
Copyright>        Commercial Alternative: Altair Radioss Software
Copyright>
Copyright>        As an alternative to this open-source version, Altair also offers Altair Radioss
Copyright>        software under a commercial license.  Contact Altair to discuss further if the
Copyright>        commercial version may interest you: https://www.altair.com/radioss/.
Chd|====================================================================
Chd|  TFORC3                        source/elements/truss/tforc3.F
Chd|-- called by -----------
Chd|        FORINT                        source/elements/forint.F      
Chd|-- calls ---------------
Chd|        M1LAWT                        source/materials/mat/mat001/m1lawt.F
Chd|        M2LAWT                        source/materials/mat/mat002/m2lawt.F
Chd|        SIGEPS34T                     source/materials/mat/mat034/sigeps34t.F
Chd|        SIGEPS44T                     source/materials/mat/mat044/sigeps44t.F
Chd|        TBILAN                        source/elements/truss/tbilan.F
Chd|        TCOOR3                        source/elements/truss/tcoor3.F
Chd|        TDEFO3                        source/elements/truss/tdefo3.F
Chd|        TDLEN3                        source/elements/truss/tdlen3.F
Chd|        TFCUM3                        source/elements/truss/tfcum3.F
Chd|        TFCUM3P                       source/elements/truss/tfcum3p.F
Chd|        ELBUFDEF_MOD                  ../common_source/modules/mat_elem/elbufdef_mod.F
Chd|        H3D_MOD                       share/modules/h3d_mod.F       
Chd|====================================================================
      SUBROUTINE TFORC3(
     1   ELBUF_STR,JFT,      JLT,      PM,
     2   GEO,      NCT,      X,        F,
     3   V,        PARTSAV,  BUFMAT,   DT2T,
     4   NELTST,   ITYPTST,  STIFN,    FSKY,
     5   IADT,     OFFSET,   IPARTT,   TANI,
     6   FX1,      FX2,      FY1,      FY2,
     7   FZ1,      FZ2,      NEL,      GRESAV,
     8   GRTH,     IGRTH,    MSTR,     DMELTR,
     9   IOUTPRT,  IPM,      NPF,      TF,
     A   ITASK,    H3D_DATA, NFT,      MTN,
     B   JSMS,     IGRE)
C-----------------------------------------------
C   M o d u l e s
C-----------------------------------------------
      USE ELBUFDEF_MOD
      USE H3D_MOD
C-----------------------------------------------
C   I m p l i c i t   T y p e s
C-----------------------------------------------
#include      "implicit_f.inc"
C-----------------------------------------------
C   G l o b a l   P a r a m e t e r s
C-----------------------------------------------
#include      "mvsiz_p.inc"
C-----------------------------------------------
C   C o m m o n   B l o c k s
C-----------------------------------------------
#include      "param_c.inc"
#include      "parit_c.inc"
#include      "com08_c.inc"
C-----------------------------------------------
C   D u m m y   A r g u m e n t s
C-----------------------------------------------
      INTEGER, INTENT(IN) :: IGRE
      INTEGER, INTENT(IN) :: NFT
      INTEGER, INTENT(IN) :: MTN
      INTEGER, INTENT(IN) :: JSMS
      INTEGER NCT(*),IADT(2,*),IPARTT(*),OFFSET,
     .        JFT,JLT,NELTST,ITYPTST,NEL,GRTH(*),IPM(NPROPMI,*),
     .        IGRTH(*),IOUTPRT,NPF(*),ITASK
      my_real DT2T,
     .   BUFMAT(*),PM(*),GEO(NPROPG,*),X(*),F(*),V(*),PARTSAV(*),TF(*),
     .   STIFN(*),FSKY(*),TANI(15,*),FX1(MVSIZ),FY1(MVSIZ),FZ1(MVSIZ),
     .   FX2(MVSIZ),FY2(MVSIZ),FZ2(MVSIZ),GRESAV(*),MSTR(*),DMELTR(*)
C
      TYPE (ELBUF_STRUCT_), TARGET :: ELBUF_STR
      TYPE(H3D_DATABASE) :: H3D_DATA
C-----------------------------------------------
C   L o c a l   V a r i a b l e s
C-----------------------------------------------
      INTEGER  LCO,NUVAR,NFUNC,IFUNC(100),I
      INTEGER  MAT(MVSIZ),PID(MVSIZ),NGL(MVSIZ),NC1(MVSIZ),NC2(MVSIZ)
      my_real 
     .   STI(MVSIZ),OFF(MVSIZ),
     .   EPS(MVSIZ),AL(MVSIZ),VX1(MVSIZ),VX2(MVSIZ),VY1(MVSIZ),
     .   VY2(MVSIZ),VZ1(MVSIZ),VZ2(MVSIZ),EX(MVSIZ),EY(MVSIZ),EZ(MVSIZ),
     .   X1(MVSIZ),X2(MVSIZ),Y1(MVSIZ),Y2(MVSIZ),Z1(MVSIZ),Z2(MVSIZ)
C
      my_real ,DIMENSION(:) ,POINTER :: UVAR
      TYPE(G_BUFEL_),POINTER :: GBUF
C-----------------------------------------------
C   S o u r c e   L i n e s
C-----------------------------------------------
      GBUF => ELBUF_STR%GBUF
C
      LCO=1+5*NFT
      CALL TCOOR3(
     1   X,       NCT(LCO),MAT,     PID,
     2   NGL,     NC1,     NC2,     X1,
     3   X2,      Y1,      Y2,      Z1,
     4   Z2,      NEL)
      CALL TDEFO3(
     1   V,       GBUF%OFF,OFF,     NC1,
     2   NC2,     EPS,     AL,      VX1,
     3   VX2,     VY1,     VY2,     VZ1,
     4   VZ2,     EX,      EY,      EZ,
     5   X1,      X2,      Y1,      Y2,
     6   Z1,      Z2,      NEL)
C-------     activation only in compression in laws
      DO I=1,NEL
       IF (GEO(2,PID(I))>ZERO .AND. GBUF%OFF(I)>ZERO) OFF(I)=ZERO
      ENDDO
      CALL TDLEN3(
     1   JFT,      JLT,      PM,       GBUF%OFF,
     2   OFF,      DT2T,     NELTST,   ITYPTST,
     3   MSTR,     DMELTR,   GBUF%DT,  NEL,
     4   GBUF%G_DT,MAT,      NGL,      AL,
     5   JSMS)
!
      IF (MTN == 1) THEN
        CALL M1LAWT(
     1   PM,         GEO,        OFF,        GBUF%FOR,
     2   GBUF%EINT,  GBUF%AREA,  GBUF%LENGTH,STI,
     3   MAT,        PID,        EPS,        AL,
     4   NEL)
c
      ELSEIF (MTN == 2) THEN
        CALL M2LAWT(
     1   PM,         GEO,        OFF,        GBUF%FOR,
     2   GBUF%EINT,  GBUF%AREA,  GBUF%LENGTH,GBUF%PLA,
     3   STI,        MAT,        PID,        NGL,
     4   EPS,        AL,         NEL)
c
      ELSEIF (MTN == 34) THEN
        NUVAR =  GBUF%G_NUVAR
        UVAR  => GBUF%VAR
        CALL SIGEPS34T(NEL      ,NGL      ,MAT      ,PID        ,BUFMAT    ,
     .                 IPM      ,GEO      ,OFF      ,GBUF%FOR   ,STI       ,
     .                 GBUF%EINT,GBUF%AREA,GBUF%LENGTH,AL       ,EPS       ,
     .                 NUVAR     ,UVAR     )
c
c
      ELSEIF (MTN == 44) THEN
        NUVAR =  GBUF%G_NUVAR
        UVAR  => GBUF%VAR
        NFUNC = IPM(10,MAT(1))
        DO I=1,NFUNC
          IFUNC(I) = IPM(10+I,MAT(1))
        ENDDO
        CALL SIGEPS44T(NEL      ,NGL      ,MAT      ,PID        ,BUFMAT    ,
     .                 IPM      ,GEO      ,OFF      ,GBUF%FOR   ,STI       ,
     .                 GBUF%PLA ,GBUF%EINT,GBUF%AREA,GBUF%LENGTH,AL        ,
     .                 EPS      ,NUVAR    ,UVAR     ,NPF        ,TF        ,
     .                 NFUNC    ,IFUNC    )
c
      ENDIF ! IF (MTN)
C-------     activation for GBUF%OFF + save the strain in buffer
      DO I=1,NEL
       IF (GEO(2,PID(I))>ZERO) THEN
         IF (GBUF%OFF(I)==ZERO.AND.OFF(I)==ONE) GBUF%OFF(I)=ONE
       END IF
       GBUF%STRA(I) = GBUF%STRA(I) + EPS(I)*DT1
      ENDDO
C--------------------------
C     BILANS PAR MATERIAU
C--------------------------
      IF (IOUTPRT>0) THEN
      CALL TBILAN(
     1   PM,       V,        GBUF%EINT,GBUF%AREA,
     2   PARTSAV,  IPARTT,   TANI,     GBUF%FOR,
     3   GRESAV,   GRTH,     IGRTH,    MAT,
     4   AL,       VX1,      VX2,      VY1,
     5   VY2,      VZ1,      VZ2,      X1,
     6   X2,       Y1,       Y2,       Z1,
     7   Z2,       ITASK,    H3D_DATA, NEL,
     8   IGRE)
      END IF !(IOUTPRT>0) THEN
C-------------------------
C     ASSEMBLE
C-------------------------
      IF (IPARIT == 0) THEN
        CALL TFCUM3(
     1   F,       GBUF%FOR,STIFN,   STI,
     2   FX1,     FX2,     FY1,     FY2,
     3   FZ1,     FZ2,     GBUF%OFF,OFF,
     4   NC1,     NC2,     EX,      EY,
     5   EZ,      NEL)
      ELSE
        CALL TFCUM3P(
     1   GBUF%FOR,STI,     FSKY,    FSKY,
     2   IADT,    FX1,     FX2,     FY1,
     3   FY2,     FZ1,     FZ2,     GBUF%OFF,
     4   OFF,     NC1,     NC2,     EX,
     5   EY,      EZ,      NEL,     NFT)
      ENDIF
C-----------------------------------------------
      RETURN
      END
