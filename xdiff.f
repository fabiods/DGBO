      program xdiff
      implicit none
      integer i,j,n,nc,k
      double precision dd,dene,mmin,mmax
      integer , parameter :: mm=10000,ncmax=11
      double precision e1(mm),e2(mm),ed(mm),x1(mm,ncmax),y(ncmax)
      double precision ox(ncmax),rrr,dmax(ncmax),dmin(ncmax)
      double precision oxmin(ncmax),oxmax(ncmax)
      integer kf,ii
!     rrr=0.001d0
      
      open(UNIT=88,FILE='nc.dat',STATUS='OLD')
      read(88,*) nc
      close(88)
      write(*,*) 'readed num coulums: nc',nc
!    the input is basrun.allene.dat.uniq
! example:    -240.54594804580000000000 -240.5459480458 0 5E-01 9E-02 4E+00 5E-01 2E-01 7E-01 2E-01
!    this are all points SORTED
!    the first ones are very far from the minmum
!    the last  ones are close to the miumm      
      i=0
 333  i=i+1
      read(*,*,END=44) e1(i),e2(i),ed(i),x1(i,1:nc)
!      write(*,*)  i, e1(i)

      goto 333
 44   write(*,*) 'readed np',i-1
      n=i-1


       !     compute ox
      oxmax(1:nc)=1e-7
      oxmin(1:nc)=1e+7
      do i=1,n
         
         do k=1,nc
         if (x1(i,k).gt.1.d0) then
            ox(k)=1
         else if (x1(i,k).gt.0.1d0) then
            ox(k)=0.1d0
         else if (x1(i,k).gt.0.01d0) then
            ox(k)=0.01d0
         end if
         if (ox(k).gt.oxmax(k)) oxmax(k)=ox(k)
         if (ox(k).lt.oxmin(k)) oxmin(k)=ox(k)
         enddo
         
      enddo
      
      do k=1,nc
         write(*,*) 'ox',oxmin(k),oxmax(k)
      enddo
      
! compute granularity: minimal distance
      mmin=1.d7
      mmax=1.d-7
      
      rrr=1.d7
! loop over all couple of points 
! to find rrr = minimal distance
      do i=1,n      
         do j=i+1,n
           ! distance between 2 points 
           dd=0.d0
            do k=1,nc
            dd=   dd+abs(x1(i,k)-x1(j,k))/oxmin(k)
            enddo
!            if (dd.lt.rrr*1.0001d0) then
!               dene=abs(e1(i)-e1(j))
!               write(*,*) i,j,rrr,dene
!               if (dene.gt.mmax) then
!                  write(*,'(A,F20.10,6E11.4)') 'max',dene,
!     &  x1(i),x2(i),x3(i),x1(j),x2(j),x3(j)
!                  mmax=dene
!             endif
               if (dd.lt.rrr) rrr=dd
!               if (dene.lt.mmin) mmin=dene
!            endif
         enddo
         ! compare to minimum
          write(*,'(3F20.10,"    ",20E10.3)')       
     &   e1(i)-e1(n),    e2(i)-e2(n), ed(i)-ed(n),                           
     &  (x1(i,ii)-x1(n,ii),ii=1,nc)
      enddo
  
   
      ! last one
!      do k=1,nc
!         write(*,*) 'ox',ox(k)
!      enddo   
      write(*,'(A,F10.4)') 'granularity',rrr
!---------------------compute dist-----------
      ! compute granularity
      mmin=1.d7
      mmax=1.d-7
      dmax(1:nc)=1.d-7
      dmin(1:nc)=1.d+7
!      do i=1,n
!         do k=1,nc
!         if (x1(i,k).gt.1.d0) then
!            ox(k)=1
!         else if (x1(i,k).gt.0.1d0) then
!            ox(k)=0.1d0
!         else if (x1(i,k).gt.0.01d0) then
!            ox(k)=0.01d0
!         end if
!      enddo

! loop over all couple of points
! dd is the distance
! y(k) is the vector  distance
      do i=n,1,-1 
      do j=n,i+1,-1
            dd=0.d0
            do k=1,nc
               dd=   dd+abs(x1(i,k)-x1(j,k))/oxmin(k)
               y(k)=abs(x1(i,k)-x1(j,k))/oxmin(k)     
            enddo     


            if (dd.lt.rrr*1.0001d0) then
               ! now only one in y(k) is 1, which is ?
               kf=0
               do k=1,nc
                  if (y(k).gt.0.9) then
                     kf=k
                   endif  
               enddo
               
               dene=abs(e1(i)-e1(j))
               if (dene.gt.dmax(kf)) then
                  dmax(kf)=dene
                  write(*,'(A,I4,F20.10,2I5,"    ",20E10.3)')       
     & 'max kf',kf,dene,i,j,                                
     &  (x1(i,ii),ii=1,nc),(y(ii),ii=1,nc) 
               endif
               if (dene.lt.dmin(kf)) then
                  dmin(kf)=dene
               endif   
!               y(1:nc)=x1(i,1:nc)-x1(j,1:nc) 

!               write(*,'(2I5,2F10.5,20F5.0)') i,j,dd,dene,y(1:nc)
               
               if (dene.gt.mmax) then
                  write(*,'(A,F20.10,2I5,"    ",20E10.3)')
     & 'max global',dene,i,j,
     &  (x1(i,ii),ii=1,nc),(y(ii),ii=1,nc)
                  mmax=dene
             endif
               if (dene.lt.mmin) mmin=dene
            endif
         enddo
         
      enddo
      write(*,'("dmax",20F20.10)') dmax(1:nc)
      write(*,'("dmin",20F20.10)') dmin(1:nc)
      write(*,*) "global max", mmax
      write(*,*) "global min", mmin
      write(*,*) '--'
      end program
