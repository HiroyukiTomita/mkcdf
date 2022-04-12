c mk_ofuro_nc_era5_hourly_v1.1.f 
c
c This is a sample program to create netCDF file 
c for J-OFURO3 Daily 0.25D grid variable for a year
c
c PARAMETERS
c  VVAARR: Variable Name (QA, LHF...)
c  UUNNIITT: unit (g/kg, w/m^2)
c  LLOONNGG: Long name (J-OFURO3 QA V1.0)
c  IINNPPUUTT: Input file (a binary file must have "YYYY.bin")
c  OOUUTTPPUUTT: Input file (a netCDF file must have "YYYY.nc")
c  YYYY: Year (2008)
c  JJDD: Julian day (365 or 366)
c  UUNNIITT: unit (g/kg, w/m^2)
c-----------------------------------------------------------------------  

C     This is part of the netCDF package.
C     Copyright 2006 University Corporation for Atmospheric Research/Unidata.
C     See COPYRIGHT file for conditions of use.

C     This is an example program which writes some 4D pressure and
C     temperatures. It is intended to illustrate the use of the netCDF
C     fortran 77 API. The companion program pres_temp_4D_rd.f shows how
C     to read the netCDF data file created by this program.

C     This program is part of the netCDF tutorial:
C     http://www.unidata.ucar.edu/software/netcdf/docs/netcdf-tutorial

C     Full documentation of the netCDF Fortran 77 API can be found at:
C     http://www.unidata.ucar.edu/software/netcdf/docs/netcdf-f77

C     $Id: pres_temp_4D_wr.f,v 1.11 2007/01/24 19:45:09 russ Exp $

      program mk_ofuro_nc_v1
      implicit none
      include 'netcdf.inc'

C     This is the name of the data file we will create.
      character*100 FILE_NAME
      integer ncid

C     We are writing 4D data, a 2 x 6 x 12 lvl-lat-lon grid, with 2
C     timesteps of data.
      integer NDIMS, NRECS
      parameter (NDIMS = 3, NRECS = JJDD*24)
      integer NLATS, NLONS
      parameter (NLATS = 721, NLONS = 1440)
      character*(*) LAT_NAME, LON_NAME, REC_NAME
      parameter (LAT_NAME = 'latitude', LON_NAME = 'longitude')
      parameter (REC_NAME = 'time')
      integer lon_dimid, lat_dimid, rec_dimid

C     The start and count arrays will tell the netCDF library where to
C     write our data.
      integer start(NDIMS), count(NDIMS)

C     These program variables hold the latitudes and longitudes.
      real lats(NLATS), lons(NLONS)
      integer lon_varid, lat_varid

c     time 
      real recs(NRECS)
      integer rec_varid

C     We will create two netCDF variables, one each for temperature and
C     pressure fields.
      character*(*) LONG_NAME
      parameter(LONG_NAME = 'long_name')
      character*(*) VAR_NAME, VAR_NAME_LONG
      parameter (VAR_NAME='VVAARR',
     +           VAR_NAME_LONG='LLOONNGG')
      integer var_varid
      integer dimids(NDIMS)

C     We recommend that each variable carry a "units" attribute.
      character*(*) UNITS
      parameter (UNITS = 'units')
      character*(*) VAR_UNITS, LAT_UNITS, LON_UNITS, REC_UNITS
      parameter (VAR_UNITS = 'UUNNIITT')
      parameter (LAT_UNITS = 'degrees_north')
      parameter (LON_UNITS = 'degrees_east')
      parameter (REC_UNITS = 'hours since YYYY-01-01')

c     Time origin
      character*(*) TORG
      parameter (TORG='time_origin')
      character*(*) TIME_ORG
      parameter (TIME_ORG = '15-Jan-1901')

c     SPV (missing value)
      character*(*) MISSING
      parameter (MISSING = 'missing_value')
      real spv
      parameter(spv=-9999.0)

C     Program variables to hold the data we will write out. We will only
C     need enough space to hold one timestep of data; one record.
      real var_out(NLONS, NLATS)

c     FOR input files
      character*100 fni
      integer i,j

C     Use these to construct some latitude and longitude data for this
C     example.
      integer START_LAT, START_LON
      parameter (START_LAT = -90.0, START_LON = 0.0)

C     Loop indices.
      integer lvl, lat, lon, rec1

C     Error handling.
      integer retval

C     Create pretend data. If this wasn't an example program, we would
C     have some real data to write, for example, model output.
      do lat = 1, NLATS
         lats(lat) = START_LAT + (lat - 1) * 0.25
      end do
      do lon = 1, NLONS
         lons(lon) = START_LON+(0.25/2) + (lon - 1) * 0.25
      end do
      do rec1 = 1,NRECS
         recs(rec1) = rec1 -1
c         write(6,*) real(recs(rec1))
      enddo

c 
c     Open output data file
      FILE_NAME="OOUUTTPPUUTT"
c     Open input data file
      fni="./IINNPPUUTT"
      open(50,file=fni,form="unformatted")

C     Create the file. 
      retval = nf_create(FILE_NAME, nf_clobber, ncid)
      if (retval .ne. nf_noerr) call handle_err(retval)

C     Define the dimensions. The record dimension is defined to have
C     unlimited length - it can grow as needed. In this example it is
C     the time dimension.
      retval = nf_def_dim(ncid, LAT_NAME, NLATS, lat_dimid)
      if (retval .ne. nf_noerr) call handle_err(retval)
      retval = nf_def_dim(ncid, LON_NAME, NLONS, lon_dimid)
      if (retval .ne. nf_noerr) call handle_err(retval)
      retval = nf_def_dim(ncid, REC_NAME, NRECS, rec_dimid)
      if (retval .ne. nf_noerr) call handle_err(retval)

C     Define the coordinate variables. We will only define coordinate
C     variables for lat and lon.  Ordinarily we would need to provide
C     an array of dimension IDs for each variable's dimensions, but
C     since coordinate variables only have one dimension, we can
C     simply provide the address of that dimension ID (lat_dimid) and
C     similarly for (lon_dimid).
      retval = nf_def_var(ncid, LAT_NAME, NF_REAL, 1, lat_dimid, 
     +     lat_varid)
      if (retval .ne. nf_noerr) call handle_err(retval)
      retval = nf_def_var(ncid, LON_NAME, NF_REAL, 1, lon_dimid, 
     +     lon_varid)
      if (retval .ne. nf_noerr) call handle_err(retval)
      retval = nf_def_var(ncid, REC_NAME, NF_REAL, 1, rec_dimid, 
     +     rec_varid)
      if (retval .ne. nf_noerr) call handle_err(retval)

C     Assign units attributes to coordinate variables.
      retval = nf_put_att_text(ncid, lat_varid, UNITS, len(LAT_UNITS), 
     +     LAT_UNITS)
      if (retval .ne. nf_noerr) call handle_err(retval)
      retval = nf_put_att_text(ncid, lon_varid, UNITS, len(LON_UNITS), 
     +     LON_UNITS)
      if (retval .ne. nf_noerr) call handle_err(retval)
      retval = nf_put_att_text(ncid, rec_varid, UNITS, len(REC_UNITS), 
     +     REC_UNITS)
      if (retval .ne. nf_noerr) call handle_err(retval)

c     Assign time_origin
c      retval = nf_put_att_text(ncid, rec_varid, TORG, len(TIME_ORG), 
c     +     TIME_ORG)
c      if (retval .ne. nf_noerr) call handle_err(retval)

C     The dimids array is used to pass the dimids of the dimensions of
C     the netCDF variables. Both of the netCDF variables we are creating
C     share the same four dimensions. In Fortran, the unlimited
C     dimension must come last on the list of dimids.
      dimids(1) = lon_dimid
      dimids(2) = lat_dimid
      dimids(3) = rec_dimid

C     Define the netCDF variables for the var_name data.
      retval = nf_def_var(ncid, VAR_NAME, NF_REAL, NDIMS, dimids, 
     +     var_varid)
      if (retval .ne. nf_noerr) call handle_err(retval)

C     Assign units attributes to the netCDF variables.
      retval = nf_put_att_text(ncid, var_varid, UNITS, len(VAR_UNITS), 
     +     VAR_UNITS)
      if (retval .ne. nf_noerr) call handle_err(retval)
c      write(6,*) "OK 1"

C     Assign long_name attributes to the netCDF variables.
      retval = nf_put_att_text(ncid, var_varid,
     +     LONG_NAME, len(VAR_NAME_LONG), 
     +     VAR_NAME_LONG)
      if (retval .ne. nf_noerr) call handle_err(retval)

c     Assign missing_value attributes to the netCDF variables.
      retval = nf_put_att_real(ncid, var_varid, MISSING,NF_FLOAT, 1,
     +     spv)
      if (retval .ne. nf_noerr) call handle_err(retval)
c      write(6,*) "OK 4"

C     End define mode.
      retval = nf_enddef(ncid)
      if (retval .ne. nf_noerr) call handle_err(retval)

C     Write the coordinate variable data. This will put the latitudes
C     and longitudes of our data grid into the netCDF file.
      retval = nf_put_var_real(ncid, lat_varid, lats)
      if (retval .ne. nf_noerr) call handle_err(retval)
      retval = nf_put_var_real(ncid, lon_varid, lons)
      if (retval .ne. nf_noerr) call handle_err(retval)
      retval = nf_put_var_real(ncid, rec_varid, recs)
      if (retval .ne. nf_noerr) call handle_err(retval)
c      write(6,*) "OK 5"

C     These settings tell netcdf to write one timestep of data. (The
C     setting of start(4) inside the loop below tells netCDF which
C     timestep to write.)
      count(1) = NLONS
      count(2) = NLATS
      count(3) = 1
      start(1) = 1
      start(2) = 1

C     Write the pretend data. This will write our surface pressure and
C     surface temperature data. The arrays only hold one timestep worth
C     of data. We will just rewrite the same data for each timestep. In
C     a real application, the data would change between timesteps.
      do rec1 = 1, NRECS
         start(3) = rec1

         do j=1,NLATS
          read(50)(var_out(i,j),i=1,NLONS)
         enddo

         retval = nf_put_vara_real(ncid, var_varid, start, count, 
     +        var_out)
         if (retval .ne. nf_noerr) call handle_err(retval)
      end do

C     Close the file. This causes netCDF to flush all buffers and make
C     sure your data are really written to disk.
      retval = nf_close(ncid)
      if (retval .ne. nf_noerr) call handle_err(retval)
   
      print *,'*** SUCCESS writing example file', FILE_NAME, '!'
      end

      subroutine handle_err(errcode)
      implicit none
      include 'netcdf.inc'
      integer errcode

      print *, 'Error: ', nf_strerror(errcode)
      stop 2
      end
