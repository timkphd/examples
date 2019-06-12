program splayit
        use tree_data
        use tree_junk
        use mytime
        use splayvars
        implicit none
        integer(i8) mp,mc,ml

        integer(i8) malloc_count_peak,malloc_count_current
        integer j
        interface
                integer function iran(iseed)
                        integer, intent(in), optional :: iseed
                end function iran
        end interface
        dowrite=.false.
        bs=8
        ml=0
        allocate(path%bytes(bs))
        nullify(root)
        i=iran(1)
        read(*,*)mysize
!        write(*,*)bit_size(mysize)
1234     continue
       allocate(key%bytes(bs))
   do i=1,mysize
     do j=1,bs
        key%bytes(j)=iran()
    enddo
    call RANDOM_NUMBER(aran)
    rjk=32768*aran
        call insert(key, rjk, root)
    enddo
    call inorder(root)
        do
    mp=malloc_count_peak()
    mc=malloc_count_current()
    if(mp .gt. 0)then
    write(*,'(20x,"xxxxx ",3a16)')"peak","current","delta"
    write(*,'(20x,"mmmmm ",3i16)')mp,mc,mc-ml
    endif
    ml=mc
        write(*,*)' 0-stop'
        write(*,*)' 1-add'
        write(*,*)' 2-show inorder'
        write(*,*)' 3-count'
        write(*,*)' 4-delete'
        write(*,*)' 5-wipe out the structure'
        write(*,*)' 6-show inorder b'
        write(*,*)' 7-delete min'
        write(*,*)' 8-find by value'
        write(*,*)' 9-find by key'
        write(*,*)'10-add many'
        write(*,*)'11-toggle write'
        read(*,*)command
        select case (command)
            case (0)
                stop
           case (1)
                     write(*,*)'enter path'
                     read(*,*)path%bytes
                     exists=find(path,root)
                     if(exists)then
                         write(*,*)'path exists adding to value'
                         root%item=root%item+1
                     else
                         write(*,*)'new path adding to tree with value 1'
                         call insert(path, Real(1), root)
                     endif
            case (2)
                     st1=gtime()
                    call inorder(root)
                     st2=gtime()
                    write(*,*)st2-st1
               case (3)
                     write(*,*)"count=",rf(root)
            case (4)
                     write(*,*)'enter path'
                     read(*,*)path%bytes
                     call delete(root,path)
             case (5)
                    
                     call wipe(root)
             case (6) 
                    st1=gtime()
                    call inorder2(root)
                    st2=gtime()
                    write(*,*)st2-st1
             case (7) 
                    call deletemin(root)
             case (8)
                    write(*,*)'enter value'
                    read(*,*)rjk 
                    path%bytes=-1
                    call findval(root,rjk,path)
                    write(*,"(20i4)")path%bytes
             case (9)
                     write(*,*)'enter path'
                     read(*,*)path%bytes
                     exists=find(path,root)
                     if(exists)then
                         write(*,*)'path exists value:',root%item
                         root%item=root%item+1
                     else
                         write(*,*)'does not exist'
                     endif
             case (10) 
                    deallocate(key%bytes)
                    write(*,*)"how many?"
                    read(*,*)mysize
                    goto 1234
             case (11) 
                    dowrite=.not. dowrite
       end select
        enddo
END program splayit
