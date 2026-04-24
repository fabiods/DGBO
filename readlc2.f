      program readlc
      implicit none
      character*2 ch
      integer k,ks,kp,kd,kf,kg,z,num,izero,ich,iocc
      double precision ess(50),epp(50),edd(50),eff(5),edd(50)  ,iuno
# read directly input.d12
      read(*,*)
#      read(*,*)
      ks=0
      kp=0
      kd=0
      kf=0
      kg=0
 88   continue
# 0 0  6  2. 1.
# 0 2  1  0. 1. *
      read(*,*,ERR=89,END=89) izero,ich,num,iocc,iuno
      write(*,*) num
      if (ich.eq.0) ch='S'
      if (ich.eq.2) ch='P'
      if (ich.eq.3) ch='D'
      if (ich.eq.4) ch='F'
      if (ich.eq.5) ch='G'
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
      if (ch.eq.'F') then
       do k=1,num
        kf=kf+1
        read(*,*) eff(kf)
        write(*,*) eff(kf)
       end do
      end if 
      if (ch.eq.'G') then
       do k=1,num
        kd=kd+1
        read(*,*) egg(kg)
        write(*,*) egg(kg)
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
     if (kf.gt.0) then
         write(*,*) 'F',eff(kd)
      endif
     if (kg.gt.0) then
         write(*,*) 'G',egg(kd)
      endif
      end program
