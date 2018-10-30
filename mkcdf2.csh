#!/bin/csh -f
#
# mkcdf2_v1.csh 
#
#  mkcdf2 -options data_file_YYYY1[-YYYY2]
#
#  VAR: Variable
#   -name      : variable name  e.g., QA
#   -name_long : long name  e.g. "J-OFURO3 QA V1.0"
#   -unit      : unit for variable [option]
#
#  SR: Spatial Resolution
#   -hr : 1440 x 720
#   -lr :  360 x 180
#
#  TR: Temporal Resolution
#   -day : daily mean   (365 or 366 days)
#   -mon : monthly mean (12 months) 
#   -ann : annual mean  (1)
#   -clm : climatological mean (12 months)
#   -ltmm: long-term monthly mean (12 months x n years)
#          (data file must be one big file as data_file_YYYY1-YYYY2.bin)
#
#  DT: Data Type
#   -real (default)
#   -integer  
#
# CHANGES
#  V1.3 @MacPro3 (add option for integer[daily hr only])
#  v1.2 @MacPro3 (add EMSST variables)
#  v1.1 @MacPro3 (-unit, ENV)
#----------------------------------------------------------------------- 
# ENV.
   set netcdfinc=/opt/local/include
   set netcdflib=/opt/local/lib
   set codedir=/Users/tomita/KSD/UNIX/MKCDF/mkcdf
   set version=v1.3

# INIT.
  set name=VAR
  set name_long=VAR_NAME
  set nopt=$#argv
  set sw_hr=1
  set sw_lr=0
  set ws_day=1
  set sw_mon=0
  set sw_ann=0
  set sw_clm=0
  set sw_ltmm=0
  set sw_real=1
  set sw_int=0
  @ nopt=$nopt - 1

# OPT
  set n=1
  foreach input ($argv[1-$nopt])
    if ( "$input" == "-hr" ) then
     set sw_hr=1
     set sw_lr=0
     goto SKIP
    endif
    if ( "$input" == "-lr" ) then
     set sw_hr=0
     set sw_lr=1
     goto SKIP
    endif
    if ( "$input" == "-mon" ) then
     set sw_mon=1
     goto SKIP
    endif
    if ( "$input" == "-ann" ) then
     set sw_ann=1
     goto SKIP
    endif
    if ( "$input" == "-clm" ) then
     set sw_clm=1
     goto SKIP
    endif
    if ( "$input" == "-ltmm" ) then
     set sw_ltmm=1
     goto SKIP
    endif
    if ("$input" == "-name") then
     @ np=$n + 1
     set name=$argv[$np]
     goto SKIP
    endif
    if ("$input" == "-name_long") then
     @ np=$n + 1
     set name_long=`echo $argv[$np]`
     goto SKIP
    endif
    if ("$input" == "-unit") then
     @ np=$n + 1
     set unit=`echo $argv[$np]`
     goto SKIP
    endif
    if ("$input" == "-real") then
     set sw_real=1 
     set sw_int=0
     goto SKIP
    endif
    if ("$input" == "-integer") then
     set sw_real=0
     set sw_int=1
     goto SKIP
    endif
SKIP:
    @ n=$n + 1
  end

FILE:
  set file=$argv[$#argv]

GET_YEAR:
# SOUCE and COMPILE for get_year
  if -r tmp_$$.f rm tmp_$$.f
  set gyf=tmp_$$.f
  echo "      character*100 file" > $gyf
  echo "      file="'"'$file'"' >> $gyf
  echo "      ic=len_trim(file)" >>  $gyf
  echo "      ic2=ic-4" >> $gyf
  echo "      ic1=ic2-3" >> $gyf
  echo "      ic4=ic-9" >> $gyf
  echo "      ic3=ic4-3" >> $gyf
  echo "      write(6,'(2a5)')file(ic3:ic4),file(ic1:ic2)" >> $gyf
  echo "      stop" >> $gyf
  echo "      end" >>  $gyf

  ifort -o get_year tmp_$$.f
  ./get_year > tmp1_$$
  set years=`cat tmp1_$$`
  if ($sw_ltmm == 1) then
   set year=$years[1] 
   set year1=$years[1] 
   set year2=$years[2]
  else if ($sw_clm == 1) then
   set year="dummy"
   set year1="dummy"
   set year2="dummy"
  else
   set year=$years[2]
   set year1=$year    # Dummy
   set year2=$year    # Dummy
  endif
  

OFILE:
# DEFINE OUTPUT FILE
  set ofile=`echo $file | sed s/.bin/.nc/g`

# UNIT
  if ($name == "QA" || $name == "QS" || $name == "DQ") then
   set unit="g\/kg"
  else if ($name == "LHF" || $name == "SHF" || $name == "THF") then
   set unit="W\/m^2"
  else if ($name == "SWR" || $name == "USWR" || $name == "DSWR") then
   set unit="W\/m^2"
  else if ($name == "LWR" || $name == "ULWR" || $name == "DLWR") then
   set unit="W\/m^2"
  else if ($name == "NET" || $name == "NHF") then
   set unit="W\/m^2"
  else if ($name == "FWF" || $name == "EVAP" || $name == "RAIN") then
   set unit="mm\/day"
  else if ($name == "TAU" || $name == "TAUX" || $name == "TAUY" || $name == "MF") then
   set unit="N\/m^2"
  else if ($name == "WND" || $name == "UWND" || $name == "VWND" || $name == "DWND") then
   set unit="m\/s"
  else if ($name == "SST" || $name == "TA" || $name == "TA10" || $name == "DT") then
   set unit="deg.C"
  else if ($name == "NUM" || $name == "FREQ" || $name == "EMN" || $name == "EMS" ) then
   set unit="-"
  else if ($name == "WV") then
   set unit="mm"
  endif

# JULIAN DAYS
  if ($year == 1988 || $year == 1992 || $year == 1996 || $year == 2000 || $year == 2004 || $year == 2008 || $year == 2012 || $year == 2016 || $year == 2020 ) then
   set jdays=366
  else
   set jdays=365
  endif

# TEMPORAL
 if ($sw_mon == 1) then
  set temporal=monthly
 else if ($sw_ann == 1) then
  set temporal=annual
 else if ($sw_clm == 1) then
  set temporal=clm
 else if ($sw_ltmm == 1) then
  set temporal=ltmm
 else
  set temporal=daily
 endif

# CHECK
CHK:
  echo "mkcdf2 "$version" :"
  echo "  Variable name :"$name
  echo "  Long name     :"$name_long
  echo "  File name     :"$file
  echo "  File name(.nc):"$ofile
  echo "  Year          :"$year
  echo "  Jdays         :"$jdays
  echo "  Unit          :"$unit
  echo "  Temporal mean :"$temporal

  echo " "
  echo " Converting..."

# MAIN CODE
  if ($sw_hr == 1) then  
   if ($sw_mon == 1) then
    set code=$codedir/mk_ofuro_nc_monthly_v1.1.f
   else if ($sw_ann == 1) then
    set code=/$codedir/mk_ofuro_nc_annual_v1.1.f
   else if ($sw_clm == 1) then
    set code=/$codedir/mk_ofuro_nc_clm_v1.1.f
   else if ($sw_ltmm == 1) then
    set code=/$codedir/mk_ofuro_nc_ltmm_v1.1.f
   else
    if ($sw_real == 1) then
     set code=/$codedir/mk_ofuro_nc_v1.1.f
    else if($sw_int == 1) then
     set code=/$codedir/mk_ofuro_nc_integer_v1.3.f
    endif
   endif
  else if ($sw_lr == 1) then
   if ($sw_mon == 1) then
    set code=/$codedir/mk_ofuro_nc_monthly_lr_v1.1.f
   else if ($sw_ann == 1) then
    set code=/$codedir/mk_ofuro_nc_annual_lr_v1.1.f
   else if ($sw_clm == 1) then
    set code=/$codedir/mk_ofuro_nc_clm_lr_v1.1.f
   else if ($sw_ltmm == 1) then
    set code=/$codedir/mk_ofuro_nc_ltmm_lr_v1.1.f
   else
    set code=/$codedir/mk_ofuro_nc_lr_v1.1.f
   endif
  endif
 
  sed s/VVAARR/$name/g $code >tmp1_$$.f
  sed s/UUNNIITT/$unit/g tmp1_$$.f > tmp2_$$.f
  sed s/LLOONNGG/"$name_long"/g tmp2_$$.f > tmp1_$$.f
  sed s:IINNPPUUTT:"$file":g tmp1_$$.f > tmp2_$$.f
  sed s:OOUUTTPPUUTT:"$ofile":g tmp2_$$.f > tmp1_$$.f
  sed s/YYYY1/$year1/g tmp1_$$.f > tmp2_$$.f
  sed s/YYYY2/$year2/g tmp2_$$.f > tmp1_$$.f
  sed s/YYYY/$year/g tmp1_$$.f > tmp2_$$.f
  sed s/JJDD/$jdays/g tmp2_$$.f > tmp1_$$.f
  
  ifort -I$netcdfinc -L$netcdflib -lnetcdff -o out_nc tmp1_$$.f
  ./out_nc

# CLEAN
  if -r out_nc rm out_nc
  if -r tmp_$$.f rm tmp_$$.f
  if -r tmp1_$$.f rm tmp1_$$.f
  if -r tmp2_$$.f rm tmp2_$$.f
  if -r tmp1_$$ rm tmp1_$$
  if -r get_year rm get_year

