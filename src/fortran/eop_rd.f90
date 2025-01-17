SUBROUTINE eop_rd (EOP_fname, EOP_sol, mjd , eop)


! ----------------------------------------------------------------------
! Subroutine:  eop_rd.f90
! ----------------------------------------------------------------------
! Purpose:
!  Read EOP (Earth Orientation Parameters) data based on the different solutions
!  that are available e.g. CO4, Rapid solutions, ultra-rapid
! ----------------------------------------------------------------------
! Input arguments:
! - EOP_fname:		EOP data file name
! - EOP_sol:		EOP solution type (see Note 1)
! - mjd:			Modified Julian Day number of the required date (in UTC)
!
! Output arguments:
! - eop:			Array of the EOP data for the input day
!   				eop = [MJD xp yp UT1_UTC LOD dX dY]  1x6 matrix
!   				MJD:     MJD referred to 0h in UTC time scale 
!   				x,y:     Polar motion coordinates (arcsec) 
!   				UT1_UTC: UT1-UTC difference (sec)
!					dX,dY:   Corrections to Precession-Nutation model (arcsec)
! ----------------------------------------------------------------------
! Note 1:
! Values of the EOP_sol input argument:
! 1. EOP_sol = 1 : refers to EOP data format of the C04 solution
!    			   provided by the IERS Earth Orientation Center 
! 2. EOP_sol = 2 : refers to EOP data format of the daily solution (finals2000A.daily)
!    			   provided by the IERS Rapid Service/Prediction Center
! 3. EOP_sol = 3 : refers to EOP data format of the ultra-rapid products
!    			   provided by the IGS (per every 6 hours)
! ----------------------------------------------------------------------
! Dr. Thomas Papanikolaou, Geoscience Australia               March 2016
! ----------------------------------------------------------------------


      USE mdl_precision
      USE mdl_num
      use pod_yaml
      IMPLICIT NONE
	  
! ----------------------------------------------------------------------
! Dummy arguments declaration
! ----------------------------------------------------------------------
! IN
      INTEGER (KIND = prec_int8), INTENT(IN) :: mjd
      INTEGER (KIND = prec_int1), INTENT(IN) :: EOP_sol
      CHARACTER (LEN=512), INTENT(IN) :: EOP_fname
! OUT
      REAL (KIND = prec_d), INTENT(OUT) :: eop(EOP_MAX_ARRAY)
! ----------------------------------------------------------------------

! ----------------------------------------------------------------------
! Local variables declaration
! ----------------------------------------------------------------------
       LOGICAL igu_flag
       REAL (KIND = prec_d) :: mjd_t

! ----------------------------------------------------------------------


! ----------------------------------------------------------------------
      IF (EOP_sol == EOP_C04T) THEN
         CALL eop_c04 (EOP_fname,mjd , eop)
      ELSE IF (EOP_sol == EOP_FAST) THEN
         CALL eop_finals2000A (EOP_fname,mjd , eop)
      ELSE IF (EOP_sol == EOP_SUPER_FAST) THEN
         mjd_t = mjd * 1.d0
         CALL erp_igu (EOP_fname,mjd_t , eop, igu_flag)
	!	 CALL eop_finals2000A (EOP_fname,mjd , eop)		 
      END IF
! ----------------------------------------------------------------------
      if (.false.) PRINT *, "eop_rd.f90 eop", eop


END

SUBROUTINE eop_rd_arc (EOP_fname, EOP_SOL, from, to, rowcount, my_eop_data)

      USE mdl_precision
      USE mdl_num
      use pod_yaml
      IMPLICIT NONE

! ----------------------------------------------------------------------
! Dummy arguments declaration
! ----------------------------------------------------------------------
! IN
      REAL (KIND = prec_d), INTENT (IN) :: from , to
      INTEGER (KIND = prec_int1), INTENT(IN) :: EOP_sol
      CHARACTER (LEN=512), INTENT(IN) :: EOP_fname
! OUT
      INTEGER (KIND = prec_int4), INTENT(OUT) :: rowcount
      REAL (KIND = prec_d), INTENT(OUT) :: my_eop_data(MAX_ERP_ROWS, EOP_MAX_ARRAY)
! ----------------------------------------------------------------------

! ----------------------------------------------------------------------
! Local vars
! ----------------------------------------------------------------------
      INTEGER (KIND = prec_int4) :: idx, i, allocateStatus

      if (EOP_SOL == EOP_SUPER_FAST) then
          call erp_igu_read(EOP_fname, from, to, idx, my_eop_data)
      else if (EOP_SOL == EOP_FAST) then
          call eop_finals_arc(EOP_fname, from, to, idx, my_eop_data)
      else if (EOP_SOL == EOP_C04T) then
          call eop_c04_rd(EOP_fname, from, to, idx, my_eop_data)
      end if

      rowcount = idx
end

