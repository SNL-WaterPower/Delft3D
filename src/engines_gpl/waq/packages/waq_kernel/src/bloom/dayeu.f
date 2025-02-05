!!  Copyright (C)  Stichting Deltares, 2012-2015.
!!
!!  This program is free software: you can redistribute it and/or modify
!!  it under the terms of the GNU General Public License version 3,
!!  as published by the Free Software Foundation.
!!
!!  This program is distributed in the hope that it will be useful,
!!  but WITHOUT ANY WARRANTY; without even the implied warranty of
!!  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
!!  GNU General Public License for more details.
!!
!!  You should have received a copy of the GNU General Public License
!!  along with this program. If not, see <http://www.gnu.org/licenses/>.
!!
!!  contact: delft3d.support@deltares.nl
!!  Stichting Deltares
!!  P.O. Box 177
!!  2600 MH Delft, The Netherlands
!!
!!  All indications and logos of, and references to registered trademarks
!!  of Stichting Deltares remain the property of Stichting Deltares. All
!!  rights reserved.

!
!   ******************************************************************
!   *    SUBROUTINE FOR DETERMING THE EUPHOPHIC DAYLENGTH AND THE    *
!   *                     EUPHOTIC ZONE                              *
!   ******************************************************************
!
      SUBROUTINE DAYEU(DAY,DAYEUF,EXTTOT,DEP,DEPEUF,DSOL,EULIGH,IDUMP)
      IMPLICIT REAL*8 (A-H,O-Z)
      INCLUDE 'ioblck.inc'
!
! Compute the euphotic depth.
!
      IF (EULIGH .GT. DSOL) EULIGH = DSOL
      DEPEUF=DLOG(DSOL/EULIGH)
      DEPEUF=DEPEUF/EXTTOT
!
! Check whether the euphotic depth exceeds the physical depth. If it
! does, set DEPEUF = DEP.
!
      IF (DEPEUF .GT. DEP) DEPEUF=DEP
!
! Compute the euphotic day length.
!
      DAYEUF=DAY * (DEPEUF/DEP)
!
! Print the euphotic day length and depth.
!
      IF (IDUMP .EQ. 1) WRITE(OUUNI,10) DAY,DAYEUF,DEP,DEPEUF
   10 FORMAT (' Day length = ',F5.2,' Euphotic day length = ',F5.2,
     1        ' Depth = ',F5.2,' Euphotic depth = ',F5.2)
      RETURN
      END
