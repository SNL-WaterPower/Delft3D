      subroutine chksto ( flux  , subs  , stoch , nstoc ,
     j                    itemid, nitem )

      integer      nstoc , nitem
      character*10 flux(nstoc),subs(nstoc),itemid(nitem)
      real         stoch(nstoc)

c     Subroutine to check tables R6-R7-R8

c     Check if the same flux (velocity, dispersion) 
c     if it occurs more than once, has a consistent set of  
c     stoichiometry rules

c     After the check, the doubles are removed

c     flux   array of items (fluxes, velocity, dispersion) 
c     subs   array of affected substances
c     stoch  stoichionetry constants
c     nstoc  nr of stochi lines

c     fluxi  local flux index array
c     subsi  local substance index array
c     repet  indicates if a line is a repeated line

      integer      istoc  , iitem , istoc2, iitem2, isubs , irepet, 
     j             nstoc2
      integer      fluxi(nstoc), subsi(nstoc), repet(nstoc)
      logical      done
      integer      isflux(nitem), isrepe(nitem)
      real         effect(nitem), effec2(nitem)

c     zero local arrays

      write ( 11, * ) 'chksto'
      do iitem = 1,nitem
          isflux(iitem) = 0
          isrepe(iitem) = 0
      enddo
          
c     index table on items

      do istoc = 1,nstoc
          repet(istoc) = 1
          call zoek (flux(istoc),nitem,itemid,10,iitem)
          if (iitem.le.0) then
              write ( 11, * ) flux(istoc)
              stop 'BUG CHKSTO 001'
          endif
          fluxi(istoc) = iitem
          isflux(iitem) = 1
          call zoek (subs(istoc),nitem,itemid,10,iitem)
          if (iitem.le.0) stop 'BUG CHKSTO 002'
          subsi(istoc) = iitem
      enddo
      write ( 11, * ) 'stochi table indexed'

c     check occurence of repeated lines 

      do istoc = 1,nstoc
c         check table processed so far, upward
          do istoc2 = istoc-1,1,-1
              if ( fluxi(istoc2) .eq. fluxi(istoc) .and.
     j             subsi(istoc2) .eq. subsi(istoc) ) then
                  repet(istoc) = repet(istoc2) + 1
                  isrepe(fluxi(istoc)) = repet(istoc)
                  goto 10
              endif
          enddo
   10     continue
      enddo

c     check if multiple occurences are consistent
c     if a flux occurs in more than one process, it should affect
c     the same substances in the same way

      do iitem = 1,nitem
c         Only fluxes:
          if ( isflux(iitem) .eq. 1 ) then
              if ( isrepe(iitem) .gt. 1 )  
     j        write (11,*) ' flux ',itemid(iitem),isrepe(iitem)
c             Zero effect on substances
              do iitem2 = 1,nitem
                  effect(iitem2) = 0.0
              enddo
c             Compute effect on substances first occurrence
              do istoc = 1,nstoc
                  if ( fluxi(istoc) .eq. iitem ) then
                      if ( repet(istoc) .eq. 1 ) then
                          isubs = subsi(istoc)
                          effect(isubs) =  stoch(istoc)
                      endif
                  endif
              enddo
              do irepet = 2,isrepe(iitem)
              write (11,*) ' check ',irepet
c             Zero effect on substances
              do iitem2 = 1,nitem
                  effec2(iitem2) = 0.0
              enddo
c             Compute effect on substances following occurences
              do istoc = 1,nstoc
                  if ( fluxi(istoc) .eq. iitem ) then
                      if ( repet(istoc) .eq. irepet ) then
                          isubs = subsi(istoc)
                          effec2(isubs) =  stoch(istoc)
                      endif
                  endif
              enddo
c             Check
              do iitem2 = 1,nitem
                  if ( effec2(iitem2) .ne. effect(iitem2) ) then
                      write (*,*) ' Flux/vel/disp ',itemid(iitem),
     j               ' not consistently defined'
                      write (*,*) ' Effect on substance ',
     j                itemid(iitem2),effec2(iitem2),effect(iitem2)
                      stop
                  endif
              enddo
              enddo
          endif
      enddo

c     Clear multiple occurences


  190 nstoc2 = nstoc
      do istoc = 1,nstoc2
          if ( repet(istoc) .gt. 1 ) then
              do istoc2 = istoc+1,nstoc2
                  flux (istoc2-1) = flux (istoc2)
                  fluxi(istoc2-1) = fluxi(istoc2)
                  subs (istoc2-1) = subs (istoc2)
                  subsi(istoc2-1) = subsi(istoc2)
                  repet(istoc2-1) = repet(istoc2)
                  stoch(istoc2-1) = stoch(istoc2)
              enddo
              nstoc = nstoc - 1
              goto 190
          endif
      enddo

      return
      end

