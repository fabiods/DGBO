      program checkbr 
 
      character(len=30)       :: arg,str,ss(20)
      integer                 :: i, x,j,c(3),numpar,ierr
      double precision        :: vv(20),vvk(20,3),par(20),ratio
      character(len=2)            ::type(3)
      type(1)='S'
      type(2)='P'
      type(3)='D'
      numpar=command_argument_count()
      write(*,*) 'numpar',numpar
      do i = 1, numpar
      call GET_COMMAND_ARGUMENT(i, arg)
!      write(*,*) arg
      read(arg,*) par(i)
!      write(*,') par(i)
      enddo
      write(*,'("dstr",20E10.3)') par(1:numpar)
      write(*,*) 'readinf basrunsed.dat'
      open(UNIT=44,FILE='basrunsed.dat',STATUS='OLD')
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
            if (str(5:5).eq.type(k)) then
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
               write(*,*) ratio
               if (ratio.lt.1.618d0) then
                  ierr=ierr+1
               endif   
            enddo    
         endif   
      enddo
      write(*,*) 'ierr',ierr
      end  program  
