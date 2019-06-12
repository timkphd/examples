module ga_list_mod
    interface chuck
        subroutine chuck(result,doinit)
                logical, optional, intent (in) :: doinit
                integer, dimension(:) :: result
        end subroutine
    end interface
end module

