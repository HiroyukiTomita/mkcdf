c get_year.f
c
c  abc_YYYY.bin
c-----------------------------------------------------------------------
      character*100 file
    
      read(5,*) file 
      ic=len_trim(file)
      ic2=ic-4
      ic1=ic2-3
      write(6,*)file(ic1:ic2)
      stop
      end
