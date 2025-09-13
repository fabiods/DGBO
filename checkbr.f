      program checkbr 
      implicit none
      character(len=30)       :: arg,str,ss(20),filename
      integer                 :: i, x,j,c(3),numpar,ierr,numj,k
      integer il,ilx
      logical isb
      double precision        :: vv(20),vvk(20,3),par(20),ratio,geop
      double precision        :: val(20)
      character(len=2)            ::type(3),cht
      type(1)='S'
      type(2)='P'
      type(3)='D'
! input:
! checkbr.x filename maxratio par1 par2 ....parN
!           filename is used only to read the string PAR*
! bmax.dat is eventually read the check contractions

      numpar=command_argument_count()-2
      write(*,*) 'numpar ',numpar
      
      call GET_COMMAND_ARGUMENT(1,arg)
      read(arg,*) filename
      write(*,*) 'filename ', filename
      
      call GET_COMMAND_ARGUMENT(2, arg)
      read(arg,*) geop
      write(*,*) 'geo prog',geop

      inquire(FILE='bmax.dat', exist=isb)  
      if (isb) then
       write(*,*) 'bmax.dat found'
       open(UNIT=33,FILE='bmax.dat',STATUS='OLD')
       do il=1,numpar
        read(33,*) ilx,val(il)
       end do
      else
       write(*,*) 'bmax not found'
      endif
      do i = 1, numpar
      call GET_COMMAND_ARGUMENT(i+2, arg)
!      write(*,*) arg
      read(arg,*) par(i)
!      write(*,') par(i)
      enddo
      write(*,'("dstr",20E10.3)') par(1:numpar)
      write(*,*) 'reading ',filename
      open(UNIT=44,FILE=filename,STATUS='OLD')
      j=0
 39   j=j+1
      read(44,*,END=40) ss(j),vv(j)
      write(*,*) ss(j),vv(j)
            goto 39
 40   numj=j-1
      close(44)
            
      if (numj.ne.numpar) then
         write(*,*)'bad number of parameters',numj,numpar
         stop
      end if
      c(:)=0
      ierr=0
      do k=1,3
         write(*,*) '-----------',type(k),'----------'
         do j=1,numj
            str=ss(j)
!            write(*,*) str(5:5)
            if (j.le.9) cht=str(5:5)
            if (j.ge.10) cht=str(6:6)
            if (cht.eq.type(k)) then
               write(*,*) str
               c(k)=c(k)+1
               vvk(c(k),k)=par(j)!vv(j)
            endif
         enddo
         do i=1,c(k)
            write(*,*) i,vvk(i,k)
         enddo
         if (c(k).ge.2) then
            do i=2,c(k)
               ratio=vvk(i-1,k)/vvk(i,k)
               write(*,*) "PROG ",ratio
               if (ratio.lt.geop) then
                  ierr=ierr+1
               endif   
            enddo    
         endif   
      enddo
      if (isb) then 
      write(*,*)
      do ilx=1,numpar
      if (val(ilx).gt.1.d-6) then
       if (vv(ilx).gt.val(ilx)*1.15d0) then
         write(*,*) ilx,'too high', vv(ilx),'>',val(ilx)
         ierr=ierr+1
        else
         write(*,*) vv(ilx),'<',val(ilx)
       endif
       endif
      enddo
      endif
      write(*,*) 'ierr',ierr
      end  program  
