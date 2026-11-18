program d4
  real :: four=4
  open(unit=10,file="fort.10",form="unformatted",status="unknown",access="stream")
  open(unit=9, file="fort.9" ,form="unformatted",status="unknown"                )
  do i=1,16
    write(9)four
    write(10)four
  enddo
end program

