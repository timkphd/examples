program main
  use list_mod
  implicit none
  integer i
  type(list) :: my_list

  do i=1, 10
     call my_list%add(i)
  enddo
  call my_list%add(1.23)
  call my_list%add('A')
  call my_list%add('B')
  call my_list%add('C')
  call my_list%printvalues()
end program main

