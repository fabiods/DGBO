      program readlc
      implicit none
      character*2 ch
      integer k,ks,kp,kd,z,num
      double precision ess(50),epp(50),edd(50)  
      read(*,*)
      read(*,*)
      ks=0
      kp=0
      kd=0
 88   continue
      read(*,*,ERR=89,END=89) ch,z,num
      write(*,*) num
      if (ch.eq.'S') then
       do k=1,num
        ks=ks+1
        read(*,*) ess(ks)
        write(*,*) ess(ks)
       end do
      end if
      if (ch.eq.'P') then
       do k=1,num
        kp=kp+1
        read(*,*) epp(kp)
        write(*,*) epp(kp)
       end do
      end if
      if (ch.eq.'D') then
       do k=1,num
        kd=kd+1
        read(*,*) edd(kd)
        write(*,*) edd(kd)
       end do
      end if
      goto 88
89    write(*,*) 'done'
      if (ks.gt.0) then
         write(*,*) 'S', ess(ks)
      endif
      if (kp.gt.0) then
         write(*,*) 'P',epp(kp)
      endif
      if (kd.gt.0) then
         write(*,*) 'D',edd(kd)
      endif   
      end program
