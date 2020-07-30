<style type="text/css" rel="stylesheet">
body {
  font-family: Helvetica, arial, sans-serif;
  font-size: 14px;
  line-height: 1.6;
  padding-top: 10px;
  padding-bottom: 10px;
  background-color: white;
  padding: 30px;
  color: #333;
}
pre { color: #f000ff;background-color: #f0f0f0;font-size: 12px}

</style>


	
# Topics to Cover:

	

- F95 auto deallocation

	

- Stream IO

	

- Fortran and C interoperability

	

- Forall statement

	

- OOP


	

- [Link to examples   
    https://petra.acns.colostate.edu/docs/fortran/95/source/index.html](source/index.html)

- - -

	
# F95 auto deallocation
- Fortran 90 introduced the allocatable array

	
	```	...
	! specify that an array "x_ray" is allocatable
        real, allocatable :: x_ray(:)
	...
	...
	! allocate memory for the array
        allocate(x_ray(10))
	! use it
        do i=1,10
                x_ray(i)=i+2
        end do
	! deallocate the array
        deallocate(x_ray)
    ```
	
	
- After an array is deallocated it can not be used (until reallocated)
- If an array is in a subroutine and the subroutine returns the status of the array is unknown
- This is a portability issue, different compilers can do things differently
- Program correctness?
- Memory leak

	
- - -

# F95 auto deallocation
 In F95 and beyond if an array is allocated in a subroutine it is automatically deallocated on exit
- Prevents memory leaks
- Programs compiled under F90/F95 might behave differently 
- Related: Pointers in F90

A pointer is a variable that can be used in place of a regular variable or an array.
The variable that is being pointed to must be given the target attribute.
We will use a pointer to illustrate the differences in allocatable arrays in F90/F95

	
- - -

# F95 auto deallocation - Our example
- In our example we have a pointer, vector, that is "global" defined in a module
- A subroutine "dummy"
- Dummy allocates and fills a local x_ray "x_ray"
- Points vector to dummy
- Uses the ASSOCIATED function to show the status of x_ray and vector
- Dummy does not deallocate the array
- Our main program calls dummy twice and does <b>illegal</b> references to "vector"
- We compile with IBM xlf90 and xlf95 and seen the differences


#### Source: test1.f90

```
module aptr
        REAL, POINTER, DIMENSION(:) :: VECTOR =&gt; NULL()
        !real, allocatable,target :: array(:)
end module
subroutine dummy(i)
        use aptr
        !save
        real, allocatable,target :: x_ray(:)
        write(*,*)
        write(*,*)"in dummy vector associated", ASSOCIATED(vector)
!        write(*,*)allocated(x_ray)
        allocate(x_ray(i))
        do j=1,i
        x_ray(j)=j
        enddo
        write(*,*)"vector associated", ASSOCIATED(vector), &amp;
                  " vector points to x_ray",ASSOCIATED(vector,x_ray)
        vector=&gt;x_ray
        write(*,*)"vector associated", ASSOCIATED(vector), &amp;
                  " vector points to x_ray",ASSOCIATED(vector,x_ray)
        write(*,*)"sum(vector)",sum(vector),ASSOCIATED(vector)
        write(*,*)
end subroutine
program xyz
        use aptr
        write(*,*)"in main before first call to dummy"
        if(associated(vector)) then
                write(*,*)"sum(vector)",sum(vector),ASSOCIATED(vector)
                write(*,*)vector
        else
                write(*,*)"vector not ASSOCIATED"
        endif
        call dummy(5)
        write(*,*)"back in main after first call to dummy"
        if(associated(vector)) then
                write(*,*)"sum(vector)",sum(vector),ASSOCIATED(vector)
                write(*,*)vector
        else
                write(*,*)"vector not ASSOCIATED"
        endif
        call dummy(4)
        write(*,*)"back in main after second call to dummy"
        if(ASSOCIATED(vector)) then
                write(*,*)"sum(vector)",sum(vector),ASSOCIATED(vector)
                write(*,*)vector
        else
                write(*,*)"vector not ASSOCIATED"
        endif
end

```

<table>
	<thead>
	<tr>
		<th>Fortran 90 Complier - xlf90</th> <th>Fortran 95 Complier - xlf95</th>
	</tr>
	</thead>
	<tbody>
	<tr>
		<td> 
<pre>
in main before first call to dummy
vector not ASSOCIATED

in dummy vector associated F
vector associated F  vector points to x_ray F
vector associated T  vector points to x_ray T
sum(vector) 15.00000000 T

back in main after first call to dummy
sum(vector) 15.00000000 T
1.000000000 2.000000000 3.000000000 4.000000000 5.000000000

in dummy vector associated T
vector associated T  vector points to x_ray F
vector associated T  vector points to x_ray T
sum(vector) 10.00000000 T

back in main after second call to dummy
sum(vector) 10.00000000 T
1.000000000 2.000000000 3.000000000 4.000000000
</pre>
 </td> 
 <td>
 <pre>
in main before first call to dummy
vector not ASSOCIATED

in dummy vector associated F
vector associated F  vector points to x_ray F
vector associated T  vector points to x_ray T
sum(vector) 15.00000000 T

back in main after first call to dummy
sum(vector) 12.00000000 T
0.0000000000E+00 0.0000000000E+00 3.000000000 4.000000000 5.000000000

in dummy vector associated T
vector associated T  vector points to x_ray F
vector associated T  vector points to x_ray T
sum(vector) 10.00000000 T

back in main after second call to dummy
sum(vector) 7.000000000 T
0.0000000000E+00 0.0000000000E+00 3.000000000 4.000000000
 </pre>
 </td>
	</tr>
	</tbody>
</table>


- - -

# Our example - comments


- Which output is correct?
- Neither - the program is invalid or at least very poorly written
- The main routine references a pointer to an array that is no longer defined
- In the "f90" version it looks like it is still defined
- The f90 version most likely has a memory leak
- My opinion is that associated should return false if the target is deallocated
- Uncomment the "!save" and the array will remain allocated for both f90 and f95


- - -

	
# Stream IO
- Fortran support unformatted reads and writes
- Unformatted I/O are not new
- There is a new mode called Stream
    	
        		
        
    - Stream output produces clean output
        
        		
    - Without Stream output every write adds beginning/end of record marks
        
        		
    - "Stream" I/O is similar (identical) to C binary write/read commands
        
        	
    
    	

	
	
- - -

# Diversion - linux od command

## od -A d -j4 -v -N 64 -t f8 fort.10

- Write a file "fort.10" to the terminal
- -A d  =  header for the number the bytes written with decimal numbers
- -j 4  = skip the first 4 bytes
- -v    = don't skip repeats
- -N 64 = write 64 bytes
- -t f8 = format the output as 8 bytes reals


- Other formats include
- -c    = write as characters
- -b    = write as octal bytes
- -t f4 = format the output as 4 bytes reals
- -t d# = write as integers of size #



- - -

# od example

## "View" a file that contains 16 4 byte reals = 4.0
```[tkaiser@mio001 tf]$ ls -lt fort.10
-rw-rw-r-- 1 tkaiser tkaiser 64 Jul  6 11:22 fort.10

[tkaiser@mio001 tf]$ cat fort.10
?@?@?@?@?@?@?@?@?@?@?@?@?@?@?@?@[tkaiser@mio001 tf]$ 


[tkaiser@mio001 tf]$ od  -A d -j4 -v -N 64 -t f4 fort.10
0000004   4.000000e+00   4.000000e+00   4.000000e+00   4.000000e+00
0000020   4.000000e+00   4.000000e+00   4.000000e+00   4.000000e+00
0000036   4.000000e+00   4.000000e+00   4.000000e+00   4.000000e+00
0000052   4.000000e+00   4.000000e+00   4.000000e+00
0000064
[tkaiser@mio001 tf]$ od -A d -j4 -v -N 64 -b fort.10
0000004 000 000 200 100 000 000 200 100 000 000 200 100 000 000 200 100
0000020 000 000 200 100 000 000 200 100 000 000 200 100 000 000 200 100
0000036 000 000 200 100 000 000 200 100 000 000 200 100 000 000 200 100
0000052 000 000 200 100 000 000 200 100 000 000 200 100
0000064
```

## "View" a file that contains 4 copies of the string "abcdefghABCDEFGH"
```[tkaiser@mio001 tf]$ cat fort.10
abcdefghABCDEFGHabcdefghABCDEFGHabcdefghABCDEFGHabcdefghABCDEFGH[tkaiser@mio001 tf]$ 
[tkaiser@mio001 tf]$ 


[tkaiser@mio001 tf]$ od  -A d -j0 -v -N 64 -c fort.10
0000000   a   b   c   d   e   f   g   h   A   B   C   D   E   F   G   H
0000016   a   b   c   d   e   f   g   h   A   B   C   D   E   F   G   H
0000032   a   b   c   d   e   f   g   h   A   B   C   D   E   F   G   H
0000048   a   b   c   d   e   f   g   h   A   B   C   D   E   F   G   H
```
- - -



# Our Fortran example
	

	[Source: bin.f90<span class="custom critical">      module numz
! module defines the basic real types
          integer, parameter:: b8 = selected_real_kind(14)
          integer, parameter:: b4 = selected_real_kind(3)
          integer, parameter :: in2 = selected_int_kind(1)
          integer, parameter :: in4 = selected_int_kind(6)
          integer, parameter :: in8 = selected_int_kind(12)
                end module
function getlen(fname)
    integer i
    integer getlen
    character(len=1) :: a
    character(*) :: fname
    open(unit=11,file=trim(fname),form="unformatted",status="old",access="stream")
    len=0
    do 
        read(11,end=1234)a
        len=len+1
    enddo
    1234 continue
    close(11)
    getlen=len
end function
program atest
    use numz
    integer getlen
    real(b8) x8(4)
    real(b4) x4(8)
    integer(in2) i2(16)
    integer(in4) i4(8)
    integer(in8) i8(4)
    integer wrs,k
    character (len=8)  str8
    character (len=16) str16
    character (len=1)  str1(8)  
    character (len=2) todo(10),indo
    wrs=0
    do while(wrs &lt; 10)
        read(*,*,end=1234)indo
        if(indo .eq. "st")goto 1234
        wrs=wrs+1
        todo(wrs)=indo
    enddo
1234 continue    
        str8="!@#$%^&amp;*"
    str16="abcdefghABCDEFGH"
    str1=(/"1","2","3","4","5","6","7","8"/)
    !write(*,*)str8
    !write(*,*)str16
    !write(*,*)str1
    i2=(/1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16/)
    i4=(/10,20,30,40,50,60,70,80/)
    i8=(/100,200,300,400/)
    x8=(/10.,20.,30.,40./)
    x4=(/1.,2.,3.,4.,5.,6.,7.,8./)
    open(unit=9,file="fort.9",form="unformatted",status="replace")
    open(unit=10,file="fort.10",form="unformatted",status="replace",access="stream")
        do ifile=9,10
            do i=1,wrs
                select case(todo(i))
                    case ("i2")
                        write(ifile)i2
                    case ("i4")
                        write(ifile)i4
                    case ("i8")
                        write(ifile)i8
                    case ("r4")
                        write(ifile)x4
                    case ("r8")
                        write(ifile)x8
                    case ("c1")
                        do k=1,4
                            write(ifile)str1
                        enddo
                    case ("c8")
                        do k=1,4
                            write(ifile)str8
                        enddo
                    case ("cx")
                        do k=1,2
                            write(ifile)str16
                        enddo
                end select
            enddo
            close(ifile)
        enddo
        open(unit=9,file="fort.9",form="unformatted",status="old")
        open(unit=10,file="fort.10",form="unformatted",status="old",access="stream")
    do ifile=9,10
        do i=1,wrs
            select case(todo(i))
                case ("i2")
                    read(ifile)i2 ; write(*,*)i2
                case ("i4")
                    read(ifile)i4 ; write(*,*)i4
                case ("i8")
                    read(ifile)i8 ; write(*,*)i8
                case ("r4")
                    read(ifile)x4 ; write(*,*)x4
                case ("r8")
                    read(ifile)x8 ; write(*,*)x8
                case ("c1")
                    do k=1,4
                        read(ifile)str1
                    enddo
                    write(*,*)str1
                case ("c8")
                    do k=1,4
                        read(ifile)str8
                    enddo
                    write(*,*)str8
                case ("cx")
                    do k=1,2
                        read(ifile)str16
                    enddo
                    write(*,*)str16
            end select
        enddo
        close(ifile)
    enddo
    write(*,*)
    write(*,*)"length fort.10 =",getlen("fort.10")
    write(*,*)"length fort.9 =",getlen("fort.9")
end program
               </span>](source/bin.f90)



```      module numz
! module defines the basic real types
          integer, parameter:: b8 = selected_real_kind(14)
          integer, parameter:: b4 = selected_real_kind(3)
          integer, parameter :: in2 = selected_int_kind(1)
          integer, parameter :: in4 = selected_int_kind(6)
          integer, parameter :: in8 = selected_int_kind(12)
          
      end module
function getlen(fname)
    integer i
    integer getlen
    character(len=1) :: a
    character(*) :: fname
    open(unit=11,file=trim(fname),form="unformatted",status="old",access="stream")
    len=0
    do 
        read(11,end=1234)a
        len=len+1
    enddo
    1234 continue
    close(11)
    getlen=len
end function


program atest
    use numz
    integer getlen
    real(b8) x8(4)
    real(b4) x4(8)
    integer(in2) i2(16)
    integer(in4) i4(8)
    integer(in8) i8(4)
    integer wrs,k
    character (len=8)  str8
    character (len=16) str16
    character (len=1)  str1(8)  
    character (len=2) todo(10),indo
    wrs=0
    do while(wrs &lt; 10)
        read(*,*,end=1234)indo
        if(indo .eq. "st")goto 1234
        wrs=wrs+1
        todo(wrs)=indo
    enddo
1234 continue    
    

    str8="!@#$%^&amp;*"
    str16="abcdefghABCDEFGH"
    str1=(/"1","2","3","4","5","6","7","8"/)
    !write(*,*)str8
    !write(*,*)str16
    !write(*,*)str1

    i2=(/1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16/)
    i4=(/10,20,30,40,50,60,70,80/)
    i8=(/100,200,300,400/)
    x8=(/10.,20.,30.,40./)
    x4=(/1.,2.,3.,4.,5.,6.,7.,8./)
    open(unit=9,file="fort.9",form="unformatted",status="replace")
    open(unit=10,file="fort.10",form="unformatted",status="replace",access="stream")

        do ifile=9,10
            do i=1,wrs
                select case(todo(i))
                    case ("i2")
                        write(ifile)i2
                    case ("i4")
                        write(ifile)i4
                    case ("i8")
                        write(ifile)i8
                    case ("r4")
                        write(ifile)x4
                    case ("r8")
                        write(ifile)x8
                    case ("c1")
                        do k=1,4
                            write(ifile)str1
                        enddo
                    case ("c8")
                        do k=1,4
                            write(ifile)str8
                        enddo
                    case ("cx")
                        do k=1,2
                            write(ifile)str16
                        enddo
                end select
            enddo
            close(ifile)
        enddo
        open(unit=9,file="fort.9",form="unformatted",status="old")
        open(unit=10,file="fort.10",form="unformatted",status="old",access="stream")
    do ifile=9,10
        do i=1,wrs
            select case(todo(i))
                case ("i2")
                    read(ifile)i2 ; write(*,*)i2
                case ("i4")
                    read(ifile)i4 ; write(*,*)i4
                case ("i8")
                    read(ifile)i8 ; write(*,*)i8
                case ("r4")
                    read(ifile)x4 ; write(*,*)x4
                case ("r8")
                    read(ifile)x8 ; write(*,*)x8
                case ("c1")
                    do k=1,4
                        read(ifile)str1
                    enddo
                    write(*,*)str1
                case ("c8")
                    do k=1,4
                        read(ifile)str8
                    enddo
                    write(*,*)str8
                case ("cx")
                    do k=1,2
                        read(ifile)str16
                    enddo
                    write(*,*)str16
            end select
        enddo
        close(ifile)
    enddo
    write(*,*)
    write(*,*)"length fort.10 =",getlen("fort.10")
    write(*,*)"length fort.9 =",getlen("fort.9")
end program
       
    
    


```

## Opens two unformatted files
```        open(unit=9, file="fort.9", form="unformatted",status="replace")
        open(unit=10,file="fort.10",form="unformatted",status="replace",<b>access="stream"</b>)
```

## Then...

- Reads from the command line what type of data to write in 32 byte blocks



	

- "i2" - 16 2 byte integers

	

- "i4" -  8 4 byte integers

	

- "i8" -  4 8 byte integers

	

- "x4" -  8 4 byte reals

	

- "x8" -  4 8 byte reals

	

- "c1" -  (/"1","2","3","4","5","6","7","8"/) 4 times

	

- "c8" -  "!@#$%^&amp;*" 4 times

	

- "cx" -  "abcdefghABCDEFGH" 4 times



- Writes the data
- Closes the files
- Reopens the files and reads the data back
- Calls a function to return the length of each file


## For this version of the program we get the length by openning the file and read/count character by character

- - -


# Our Fortran example writing 64 bits of real*4 data

```
[tkaiser@mio001 tf]$ ./a.out
[tkaiser@mio001 tf]$ ./a.out
r4
r4
st
   1.000000       2.000000       3.000000       4.000000       5.000000    
   6.000000       7.000000       8.000000    
   1.000000       2.000000       3.000000       4.000000       5.000000    
   6.000000       7.000000       8.000000    
   1.000000       2.000000       3.000000       4.000000       5.000000    
   6.000000       7.000000       8.000000    
   1.000000       2.000000       3.000000       4.000000       5.000000    
   6.000000       7.000000       8.000000    
 
 length fort.10 =          64
 length fort.9 =          80
[tkaiser@mio001 tf]$ 

[tkaiser@mio001 tf]$ ls -l fort.10 fort.9
-rw-rw-r-- 1 tkaiser tkaiser 32 Jul  6 13:05 fort.10
-rw-rw-r-- 1 tkaiser tkaiser 48 Jul  6 13:05 fort.9
[tkaiser@mio001 tf]$ 
```

- - -


# Where is  the difference in length? od can show us
```[tkaiser@mio001 tf]$ ls -l fort.10 fort.9
-rw-rw-r-- 1 tkaiser tkaiser 32 Jul  6 13:05 fort.10
-rw-rw-r-- 1 tkaiser tkaiser 48 Jul  6 13:05 fort.9
[tkaiser@mio001 tf]$ 
```

<table>
<tbody><tr>
<td class="x">[tkaiser@mio001 tf]$ od -A d  -v  -b fort.10 </td>
<td class="y">[tkaiser@mio001 tf]$ od -A d  -v  -b fort.9</td>
</tr>
<tr>
<td class="x">
```
0000000 000 000 200 077 000 000 000 100 000 000 100 100 000 000 200 100
0000016 000 000 240 100 000 000 300 100 000 000 340 100 000 000 000 101
0000032 000 000 200 077 000 000 000 100 000 000 100 100 000 000 200 100
0000048 000 000 240 100 000 000 300 100 000 000 340 100 000 000 000 101
0000064
[tkaiser@mio001 tf]$ 
```
</td>

<td class="y">
```0000000 <b>040 000 000 000</b> 000 000 200 077 000 000 000 100 000 000 100 100
0000016 000 000 200 100 000 000 240 100 000 000 300 100 000 000 340 100
0000032 000 000 000 101 <b>040 000 000 000 040 000 000 000</b> 000 000 200 077
0000048 000 000 000 100 000 000 100 100 000 000 200 100 000 000 240 100
0000064 000 000 300 100 000 000 340 100 000 000 000 101 <b>040 000 000 000</b>
0000080
[tkaiser@mio001 tf]$ 
```
</td>
</tr>
</tbody></table>
  

  

<table>
<tbody><tr>
<td class="x">[tkaiser@mio001 tf]$ od -A d  -v  -t f4 fort.10</td>
<td class="y">[tkaiser@mio001 tf]$ od -A d  -v  -t f4 fort.9</td>
</tr>
<tr>
<td class="x">
```0000000   1.000000e+00   2.000000e+00   3.000000e+00   4.000000e+00
0000016   5.000000e+00   6.000000e+00   7.000000e+00   8.000000e+00
0000032   1.000000e+00   2.000000e+00   3.000000e+00   4.000000e+00
0000048   5.000000e+00   6.000000e+00   7.000000e+00   8.000000e+00
0000064

```
</td>
<td class="y">
```
0000000   <b>4.484155e-44</b>   1.000000e+00   2.000000e+00   3.000000e+00
0000016   4.000000e+00   5.000000e+00   6.000000e+00   7.000000e+00
0000032   8.000000e+00   <b>4.484155e-44   4.484155e-44</b>   1.000000e+00
0000048   2.000000e+00   3.000000e+00   4.000000e+00   5.000000e+00
0000064   6.000000e+00   7.000000e+00   8.000000e+00   <b>4.484155e-44</b>
0000080

```
</td>
</tr>
</tbody></table>
  

  

## Both files contain the same data but the one not opened in "stream" mode has extra "junk"

	

- Can make the file longer

	

- Make it difficult to write files that need to be read by other programs


- - -

	
# F2003 Fortran and C interoperability
<dl>
	<dt>This section "borrows" heavily from: </dt>
		<dd><a href="https://gcc.gnu.org/onlinedocs/gfortran/Interoperability-with-C.html">https://gcc.gnu.org/onlinedocs/gfortran/Interoperability-with-C.html</a>.</dd>
</dl>

	

- People have been writing mixed language programs for years

	

- Many libraries called from Fortran are written in C (MPI)

	

- Many libraries called from C are written in Fortran (LAPACK)

	

- Issues:
    	
        	
        
    - 	How do you handle things like derived typed and global varialbes
        
        	
    - 	Fortran (usualy) does a call by reference C does a call by value
        
        	
    - 	There has not been a standard way to do this
        
    



Since Fortran 2003 (ISO/IEC 1539-1:2004(E)) there is a standardized way to generate procedure and derived-type declarations and global variables which are interoperable with C (ISO/IEC 9899:1999). 


Fortran 2003 adds a data type attribute <b>bind(c)</b>, and a module, <b>ISO_C_BINDING</b> which standardizes Fortran/C ISO_C_BINDING.


	

- ISO_C_BINDING contains:
        
        	
        
    - 6 intrinsic procedures
        
        	
    - Over 20 Fortran data types that map to C types
        
        	
    - 8 Character constants
        
        	
    - 2 Null pointer types
        
    



- - -

# ISO_C_BINDING character constants
<table class="greenbar">
<tbody><tr><th>Name</th><th>C definition</th><th>Value </th></tr>
<tr class="alt"><td>C_NULL_CHAR</td><td>null character</td><td>'\0' </td></tr>
<tr><td>C_ALERT</td><td>alert</td><td>'\a' </td></tr>
<tr class="alt"><td>C_BACKSPACE</td><td>backspace</td><td>'\b' </td></tr>
<tr><td>C_FORM_FEED</td><td>form feed</td><td>'\f' </td></tr>
<tr class="alt"><td>C_NEW_LINE</td><td>new line</td><td>'\n' </td></tr>
<tr><td>C_CARRIAGE_RETURN</td><td>carriage return</td><td>'\r' </td></tr>
<tr class="alt"><td>C_HORIZONTAL_TAB</td><td>horizontal tab</td><td>'\t' </td></tr>
<tr><td>C_VERTICAL_TAB</td><td>vertical tab</td><td>'\v' </td></tr>
</tbody></table>

We'll see examples of C_NULL_CHAR. It's important.

- - -

# ISO_C_BINDING intrinsic procedures
<dl>
	<dt>C_ASSOCIATED</dt>
		<dd><a href="https://gcc.gnu.org/onlinedocs/gfortran/C_005fASSOCIATED.html#C_005fASSOCIATED"> Status of a C pointer</a><br>C_ASSOCIATED(c_ptr_1[, c_ptr_2]) determines the status of the C pointer c_ptr_1 or if c_ptr_1 is associated with the target c_ptr_2.</dd>
	<dt>C_F_POINTER</dt>
		<dd><a href="https://gcc.gnu.org/onlinedocs/gfortran/C_005fF_005fPOINTER.html#C_005fF_005fPOINTER">Convert C into Fortran pointer</a><br>C_F_POINTER(CPTR, FPTR[, SHAPE]) assigns the target of the C pointer CPTR to the Fortran pointer FPTR and specifies its shape.</dd>
	<dt>C_F_PROCPOINTER</dt>
		<dd><a href="https://gcc.gnu.org/onlinedocs/gfortran/C_005fF_005fPROCPOINTER.html#C_005fF_005fPROCPOINTER">Convert C into Fortran procedure pointer</a><br>C_F_PROCPOINTER(CPTR, FPTR) Assign the target of the C function pointer CPTR to the Fortran procedure pointer FPTR.</dd>
	<dt>C_FUNLOC</dt>
		<dd><a href="https://gcc.gnu.org/onlinedocs/gfortran/C_005fFUNLOC.html#C_005fFUNLOC">Obtain the C address of a procedure</a><br>C_FUNLOC(x) determines the C address of the argument.</dd>
	<dt>C_LOC</dt>
		<dd><a href="https://gcc.gnu.org/onlinedocs/gfortran/C_005fLOC.html#C_005fLOC">C_LOC — Obtain the C address of an object</a><br>C_LOC(X) determines the C address of the argument. </dd>
	<dt>C_SIZEOF</dt>
		<dd><a href="https://gcc.gnu.org/onlinedocs/gfortran/C_005fSIZEOF.html#C_005fSIZEOF">C_SIZEOF — Size in bytes of an expression</a><br>C_SIZEOF(X) calculates the number of bytes of storage the expression X occupies. </dd>
</dl>
We'll look at C_LOC, C_F_POINTER and C_ASSOCIATED


- - -

# ISO_C_BINDING Fortran data types
The Fortran data types "map" to C types.  If you want to use a variable in both Fortran and C it should be declared as one of thes types in Fortran.


<table class="greenbar">
<tbody><tr><th>Fortran Type</th><th>Named constant</th><th>C type</th></tr>
<tr class="alt"><td>INTEGER</td><td>C_INT</td><td>int </td></tr>
<tr><td>INTEGER</td><td>C_SHORT</td><td>short int </td></tr>
<tr class="alt"><td>INTEGER</td><td>C_LONG</td><td>long int </td></tr>
<tr><td>INTEGER</td><td>C_LONG_LONG</td><td>long long int </td></tr>
<tr class="alt"><td>INTEGER</td><td>C_SIGNED_CHAR</td><td>signed char/unsigned char </td></tr>
<tr><td>INTEGER</td><td>C_SIZE_T</td><td>size_t </td></tr>
<tr class="alt"><td>INTEGER</td><td>C_INT8_T</td><td>int8_t </td></tr>
<tr><td>INTEGER</td><td>C_INT16_T</td><td>int16_t </td></tr>
<tr class="alt"><td>INTEGER</td><td>C_INT32_T</td><td>int32_t </td></tr>
<tr><td>INTEGER</td><td>C_INT64_T</td><td>int64_t </td></tr>
<tr class="alt"><td>INTEGER</td><td>C_INT_LEAST8_T</td><td>int_least8_t </td></tr>
<tr><td>INTEGER</td><td>C_INT_LEAST16_T</td><td>int_least16_t </td></tr>
<tr class="alt"><td>INTEGER</td><td>C_INT_LEAST32_T</td><td>int_least32_t </td></tr>
<tr><td>INTEGER</td><td>C_INT_LEAST64_T</td><td>int_least64_t </td></tr>
<tr class="alt"><td>INTEGER</td><td>C_INT_FAST8_T</td><td>int_fast8_t </td></tr>
<tr><td>INTEGER</td><td>C_INT_FAST16_T</td><td>int_fast16_t </td></tr>
<tr class="alt"><td>INTEGER</td><td>C_INT_FAST32_T</td><td>int_fast32_t </td></tr>
<tr><td>INTEGER</td><td>C_INT_FAST64_T</td><td>int_fast64_t </td></tr>
<tr class="alt"><td>INTEGER</td><td>C_INTMAX_T</td><td>intmax_t </td></tr>
<tr><td>INTEGER</td><td>C_INTPTR_T</td><td>intptr_t </td></tr>
<tr class="alt"><td>REAL</td><td>C_FLOAT</td><td>float </td></tr>
<tr><td>REAL</td><td>C_DOUBLE</td><td>double </td></tr>
<tr class="alt"><td>REAL</td><td>C_LONG_DOUBLE</td><td>long double </td></tr>
<tr><td>COMPLEX</td><td>C_FLOAT_COMPLEX</td><td>float _Complex </td></tr>
<tr class="alt"><td>COMPLEX</td><td>C_DOUBLE_COMPLEX</td><td>double _Complex </td></tr>
<tr><td>COMPLEX</td><td>C_LONG_DOUBLE_COMPLEX</td><td>long double _Complex </td></tr>
<tr><td>LOGICAL</td><td>C_BOOL</td><td>_Bool </td></tr>
<tr class="alt"><td>CHARACTER</td><td>C_CHAR</td><td>char </td></tr>
</tbody></table>

- - -

# Our First Example - call a C routine to get file length

	

- This is from our previous "Stream IO" example"

	

- The calls are:

```    write(*,*)"length fort.10 =",getlen_c("fort.10")
    write(*,*)"length fort.9 =",getlen_c("fort.9")
```    
    
	

- getlne_c is actually a Fortran routine that calls a C routine


## C Routine:

	

	[Source: getit.c<span class="custom critical">#include <sys types.h="">
#include <sys stat.h="">
#include <unistd.h>
#include <stdio.h>
size_t c_filesize(char* filename)
{
    size_t rv = 0;  // Return 0, if failure
    struct stat  file_info;
    if ( (filename != NULL) &amp;&amp; (stat(filename,&amp;file_info) == 0) )  //NULL check/stat() call
      rv = (size_t)file_info.st_size;  // Note: this may not fit in a size_t variable
  return rv;
}
</stdio.h></unistd.h></sys></sys></span>](source/getit.c)


    
    #include <sys types.h="">
    #include <sys stat.h="">
    #include <unistd.h>
    #include <stdio.h>
    size_t c_filesize(char* filename)
    {
        size_t rv = 0;  // Return 0, if failure
        struct stat  file_info;
    
        if ( (filename != NULL) &amp;&amp; (stat(filename,&amp;file_info) == 0) )  //NULL check/stat() call
          rv = (size_t)file_info.st_size;  // Note: this may not fit in a size_t variable
    
      return rv;
    }
    
    </stdio.h></unistd.h></sys></sys>
<table>
<tbody><tr>
<td>
    
    module getit
    contains
    function getlen_c(fname)
        USE ISO_C_BINDING, ONLY: c_long, c_char,C_NULL_CHAR
        use numz
        integer(in8) :: getlen_c
        interface 
            integer(c_long) function filesize(aname) BIND(C, NAME='c_filesize')
              USE ISO_C_BINDING, ONLY: c_long, c_char
              character(kind=c_char) :: aname(*)
            end function fileSize
        end interface
        character(*) :: fname
        character(128) :: tmp
        character(kind=c_char) :: string(128)
        integer strlen
        ! fill the string with nulls (strings for c must be null terminated)
        string=C_NULL_CHAR
        ! copy our input string to a c_char string
        tmp=trim(ADJUSTL(fname))
        strlen=len_trim(tmp)
        do i=1,strlen
            string(i:i)=tmp(i:i)
        enddo
        getlen_c=fileSize(string)
    end function
    end module
    
</td>
<td>
<div class="scroll">

<p class="s">
Our Function getlen_c takes a file name and returns a file length.
</p>

<p class="s">
ISO_C_BINDING contains our Fortran equivalent data types.  Here we are going to define variables that have typed matching C long and C char.  We are also going to use the C null character.
</p>

<p class="s">
Our function returns an integer of type "in8".  In8 is defined in "numz" to be an 8 byte integer.
</p>

<p class="s">
Next we have the interface for our C routine.  It will return a C long and take a C character array.  
</p>

<p class="s">
The BIND clause first "just" says that this is a C routine.  If you have ever written mixed language programs you will appreciate the NAME='c_filesize' clause.  What this does is specify the name of the routine in C.  Why is this important.  Previously, if you wrote a mixed language program the Fortran compiler may or may not append and underscore (_) to the end of the routine name.  So on the C side you would need to be able to compile with or without the underscore.  Here we are forcing the Fortran compiler to name our C function as given.
</p>

<p class="s">
The string we are sending to the C routine is defined here.  
</p>

<p class="s">
We are going to fill it with NULLs.  This is a bit of an overkill.  Only the character after our filename needs to be NULL.
</p>

<p class="s">
Next we "unpad" our input string and copy it to our C string.
</p>

<p class="s">
Finally we call the C routine.
</p>
</div>
</td>
</tr>
</tbody></table>

- - -

# Our Second Example - Fortran calls C and C calls Fortran

	[Source: fandc.f90 - module<span class="custom critical">MODULE FTN_C 
INTERFACE
! int C_Library_Function(float* sendbuf, int sendcount, float *recvcounts, float *mysum)
INTEGER (C_INT) FUNCTION C_LIBRARY_FUNCTION (SENDBUF, SENDCOUNT, RECV, mysum) &amp;
                BIND(C, NAME='C_Library_Function')
    USE ISO_C_BINDING
    IMPLICIT NONE
    TYPE (C_PTR), VALUE :: SENDBUF 
    INTEGER (C_INT), VALUE :: SENDCOUNT 
     Real (C_FLOAT) :: mysum
    TYPE (C_PTR), VALUE :: RECV
    END FUNCTION C_LIBRARY_FUNCTION 
END INTERFACE
INTERFACE
subroutine c_dosim ( ) BIND(C, NAME='do_sim')
    USE ISO_C_BINDING
    IMPLICIT NONE
    END subroutine c_dosim 
END INTERFACE
END MODULE FTN_C
</span>](source/ftnc_mod.f90)  
	[Source: fandc.f90 - main <span class="custom critical">program backforth
    USE ISO_C_BINDING, ONLY: C_INT, C_FLOAT, C_LOC 
    USE FTN_C
    REAL (C_FLOAT), TARGET :: SEND(10)
    INTEGER (C_INT) :: SENDCOUNT
    Real (C_FLOAT) :: mysum
    REAL (C_FLOAT), ALLOCATABLE, TARGET :: RECV(:)
    SENDCOUNT=size(SEND)
    do i=1,SENDCOUNT
        SEND(i)=i
    enddo
    ALLOCATE( RECV(SENDCOUNT) )
    mysum=-1.0
    write(*,'("Fortran mysum before C call  = ",f7.1)'),mysum
    i=C_LIBRARY_FUNCTION(C_LOC(SEND), SENDCOUNT, C_LOC(RECV),mysum)
    write(*,'("Back from C in Fortran mysum = ",f7.1)'),mysum
    do i=1,SENDCOUNT
        write(*,*)send(i),recv(i)
    enddo
    write(*,'("Fortran calling C again")')
    call c_dosim()
end program
</span>](source/main.f90)  
	[Source: fandc.f90 - subroutine<span class="custom critical">SUBROUTINE SIMULATION(ALPHA, BETA, GAMMA, DELTA, ARRAYS) BIND(C ,NAME='f_routine')
    USE ISO_C_BINDING
    IMPLICIT NONE
    INTEGER (C_LONG), VALUE :: alpha
    REAL (C_DOUBLE), INTENT(INOUT) :: beta
    REAL (C_DOUBLE), INTENT(OUT) :: gamma
    REAL (C_DOUBLE),DIMENSION(*),INTENT(IN) :: DELTA 
    TYPE, BIND(C) :: PASS
        INTEGER (C_INT) :: LENC, LENF
        TYPE (C_PTR) :: C, F 
    END TYPE PASS
    TYPE (PASS), INTENT(INOUT) :: ARRAYS
    REAL (C_FLOAT), ALLOCATABLE, TARGET, SAVE :: ETA(:) 
    REAL (C_FLOAT), POINTER :: C_ARRAY(:)
    integer i,j
    write(*,'("In Fortran called from C alpha=",i4,&amp;
              " beta=",f10.2," gamma=",f10.2)')&amp;
            alpha,beta,gamma
    gamma=0.0
    do i=1,alpha
        gamma=gamma+beta*delta(i)
    enddo
    beta=1234.0
        !...
    write(*,*)"! Associate C_ARRAY with an array allocated in C"
    CALL C_F_POINTER (ARRAYS%C, C_ARRAY, (/ARRAYS%LENC/) ) 
    if(c_associated(ARRAYS%C, c_loc(C_ARRAY)))then
        write(*,*)'ARRAYS%C, C_ARRAY point to same target'
    else
        write(*,*)'ARRAYS%C, C_ARRAY do not point to same target'
        stop
    endif
    !...
    write(*,*)"! Allocate an array and make it available in C" 
    ARRAYS%LENF = 100
    ALLOCATE (ETA(ARRAYS%LENF))
    ARRAYS%F = C_LOC(ETA)
    j=min(ARRAYS%lenc,ARRAYS%lenf)
    write(*,*)"Fortan fills the array for C"
    do i=1,j
        ETA(i)=C_ARRAY(i)*2
    enddo
END SUBROUTINE SIMULATION
</span>](source/simulation.f90)


<div class="scroll">
```MODULE FTN_C 
INTERFACE
! int C_Library_Function(float* sendbuf, int sendcount, float *recvcounts, float *mysum)
INTEGER (C_INT) FUNCTION C_LIBRARY_FUNCTION (SENDBUF, SENDCOUNT, RECV, mysum) &amp;
                BIND(C, NAME='C_Library_Function')
    USE ISO_C_BINDING
    IMPLICIT NONE
    TYPE (C_PTR), VALUE :: SENDBUF 
    INTEGER (C_INT), VALUE :: SENDCOUNT 
     Real (C_FLOAT) :: mysum
    TYPE (C_PTR), VALUE :: RECV
    END FUNCTION C_LIBRARY_FUNCTION 
END INTERFACE
INTERFACE
subroutine c_dosim ( ) BIND(C, NAME='do_sim')
    USE ISO_C_BINDING
    IMPLICIT NONE
    END subroutine c_dosim 
END INTERFACE
END MODULE FTN_C

SUBROUTINE SIMULATION(ALPHA, BETA, GAMMA, DELTA, ARRAYS) BIND(C ,NAME='f_routine')
    USE ISO_C_BINDING
    IMPLICIT NONE
    INTEGER (C_LONG), VALUE :: alpha
    REAL (C_DOUBLE), INTENT(INOUT) :: beta
    REAL (C_DOUBLE), INTENT(OUT) :: gamma
    REAL (C_DOUBLE),DIMENSION(*),INTENT(IN) :: DELTA 
    TYPE, BIND(C) :: PASS
        INTEGER (C_INT) :: LENC, LENF
        TYPE (C_PTR) :: C, F 
    END TYPE PASS
    TYPE (PASS), INTENT(INOUT) :: ARRAYS
    REAL (C_FLOAT), ALLOCATABLE, TARGET, SAVE :: ETA(:) 
    REAL (C_FLOAT), POINTER :: C_ARRAY(:)
    integer i,j
    write(*,'("In Fortran called from C alpha=",i4,&amp;
              " beta=",f10.2," gamma=",f10.2)')&amp;
            alpha,beta,gamma
    gamma=0.0
    do i=1,alpha
        gamma=gamma+beta*delta(i)
    enddo
    beta=1234.0
    
    !...
    write(*,*)"! Associate C_ARRAY with an array allocated in C"
    CALL C_F_POINTER (ARRAYS%C, C_ARRAY, (/ARRAYS%LENC/) ) 
    if(c_associated(ARRAYS%C, c_loc(C_ARRAY)))then
        write(*,*)'ARRAYS%C, C_ARRAY point to same target'
    else
        write(*,*)'ARRAYS%C, C_ARRAY do not point to same target'
        stop
    endif
    !...
    write(*,*)"! Allocate an array and make it available in C" 
    ARRAYS%LENF = 100
    ALLOCATE (ETA(ARRAYS%LENF))
    ARRAYS%F = C_LOC(ETA)
    j=min(ARRAYS%lenc,ARRAYS%lenf)
    write(*,*)"Fortan fills the array for C"
    do i=1,j
        ETA(i)=C_ARRAY(i)*2
    enddo
END SUBROUTINE SIMULATION

program backforth
    USE ISO_C_BINDING, ONLY: C_INT, C_FLOAT, C_LOC 
    USE FTN_C
    REAL (C_FLOAT), TARGET :: SEND(10)
    INTEGER (C_INT) :: SENDCOUNT
    Real (C_FLOAT) :: mysum
    REAL (C_FLOAT), ALLOCATABLE, TARGET :: RECV(:)

    SENDCOUNT=size(SEND)
    do i=1,SENDCOUNT
        SEND(i)=i
    enddo
    ALLOCATE( RECV(SENDCOUNT) )
    mysum=-1.0
    write(*,'("Fortran mysum before C call  = ",f7.1)'),mysum
    i=C_LIBRARY_FUNCTION(C_LOC(SEND), SENDCOUNT, C_LOC(RECV),mysum)
    write(*,'("Back from C in Fortran mysum = ",f7.1)'),mysum

    do i=1,SENDCOUNT
        write(*,*)send(i),recv(i)
    enddo
    write(*,'("Fortran calling C again")')
    call c_dosim()
end program

```
</div>

	

- Main program is Fortran

	

- Calls two C routines

	

- First routine accepts a size and two arrays and puts "sin" of first into the second

	

- Second routine creats a derived type (structure) and then calls a Fortran routine

	

- We show how to:
    	
        	
        
    - C calling Fortran
        
        	
    - Fortran calling C
        
        	
    - Pass by location
        
        	
    - Pass by value
        
        	
    - Use structures
        
    
    
    	

	

- We will go through this example "programatically"



- - -

# Our Main Routine

<table>
<tbody><tr>
<td>
<div class="scroll">
```program backforth
    USE ISO_C_BINDING, ONLY: C_INT, C_FLOAT, C_LOC 
    USE FTN_C
    REAL (C_FLOAT), TARGET :: SEND(10)
    INTEGER (C_INT) :: SENDCOUNT
    Real (C_FLOAT) :: mysum
    REAL (C_FLOAT), ALLOCATABLE, TARGET :: RECV(:)

    SENDCOUNT=size(SEND)
    do i=1,SENDCOUNT
        SEND(i)=i
    enddo
    ALLOCATE( RECV(SENDCOUNT) )
    mysum=-1.0
    write(*,'("Fortran mysum before C call  = ",f7.1)'),mysum
    i=C_LIBRARY_FUNCTION(C_LOC(SEND), SENDCOUNT, C_LOC(RECV),mysum)
    write(*,'("Back from C in Fortran mysum = ",f7.1)'),mysum

    do i=1,SENDCOUNT
        write(*,*)send(i),recv(i)
    enddo
    write(*,'("Fortran calling C again")')
    call c_dosim()
end program

```
</div>
</td>
<td>
We will use C ints and floats in this program as well as the C_LOC function so there are included here.


We will be sending a regular array which we fill.  We allocate an array that will have data put in it in the C procedure.


MYSUM will also be modified in the c routine.  SENDCOUNT will not be changed.


Using C_LOC is a bit odd in my opinion.  SEND and RECV are arrays but we will be sending the arrays as pointers.  C_LOC gives the pointer address. 


We next look at the interface for C_LIBRARY_FUNCTION.  Before that we note that after the call to C_LIBRARY_FUNCTION we print our returned data.

</td>
</tr>
</tbody></table>

<table>
<tbody><tr>
<td>

- - -
# Our Interface



<div class="scroll">
```MODULE FTN_C 
INTERFACE
! int C_Library_Function(float* sendbuf, int sendcount, float *recvcounts, float *mysum)
INTEGER (C_INT) FUNCTION C_LIBRARY_FUNCTION (SENDBUF, SENDCOUNT, RECV, mysum) &amp;
                BIND(C, NAME='C_Library_Function')
    USE ISO_C_BINDING
    IMPLICIT NONE
    TYPE (C_PTR), VALUE :: SENDBUF 
    INTEGER (C_INT), VALUE :: SENDCOUNT 
     Real (C_FLOAT) :: mysum
    TYPE (C_PTR), VALUE :: RECV
    END FUNCTION C_LIBRARY_FUNCTION 
END INTERFACE
INTERFACE
subroutine c_dosim ( ) BIND(C, NAME='do_sim')
    USE ISO_C_BINDING
    IMPLICIT NONE
    END subroutine c_dosim 
END INTERFACE
END MODULE FTN_C


```
</div>
</td>
<td>


We include the C interface for the routine as a reference.  


In the interface we declare the SENDBUF and RECV as pointers.  So this matches what we did in the program.  Note that we are sending these by VALUE, which is normal for C.  We can do this because we are not changing the value of the pointer.


SENDCOUNT will not change either so we send by value.


MYSUM will be changed in the C routine.  It is sent by location.  Note in the C routine it will be dereferenced as indicated in the C interface.

</td>
</tr>
</tbody></table>


  

  

- - -

# Now we look at the C routine called by Fortran

<table>
<tbody><tr>
<td>

	[Source: cpart_1.c<span class="custom critical">#include <math.h>
#include <stdio.h>
#include <stdlib.h>
/* this routine is called by fortran */
int C_Library_Function(float* sendbuf, int sendcount, float *recvcounts, float *mysum) {
int i;
float pi=3.1415926;
printf("In C mysum before loop =%g\n",*mysum);
*mysum=0.0;
for(i=0;i<sendcount;i++) c="" mysum="" after="" loop="%g\n&quot;,*mysum);" return="" span=""></sendcount;i++)></stdlib.h></stdio.h></math.h></span>](source/cpart_1.c)

<div class="scroll">
```#include <math.h>
#include <stdio.h>
#include <stdlib.h>
/* this routine is called by fortran */
int C_Library_Function(float* sendbuf, int sendcount, float *recvcounts, float *mysum) {
int i;
float pi=3.1415926;
printf("In C mysum before loop =%g\n",*mysum);
*mysum=0.0;

for(i=0;i<sendcount;i++) c="" mysum="" after="" loop="%g\n&quot;,*mysum);" return="" pre="">
</sendcount;i++)></stdlib.h></stdio.h></math.h>```</div>
</td><td>
The Routine just takes the input array and put sin in the output array and sums into *mysum.


The cool thing about this routine is that there is nothing special about it.


Note: sendbuf, recvcounts, are pointers / arrays.  We are passing back mysum so it also needs to be a pointer.  Finally sendcount is not a pointer because it is not changed.


</td>
</tr>
</tbody></table>
- - -

# Here is a C routine that will call Fortran
<table>
<tbody><tr>
<td>

	[Source: cpart_2.c<span class="custom critical">#include <stdio.h>
#include <stdlib.h>
struct pass {int lenc, lenf; float *c,  *f;};
void f_routine(long alpha, double *beta, double *gamma, double delta[], struct pass *arrays);
/* this routine is called by fortran but it
   also calls a fortran routine "simulation"
*/
void do_sim(){ 
	struct pass arrays;
	long alpha;
	double beta;
	double gamma;
	double *delta;
	int i;
	printf("C in do_sim\n");	
	alpha=10;
	delta=(double*)malloc(alpha*sizeof(double));
	beta=0.5;
	gamma=0;
	for (i=0;i<alpha;i++) arrays.lenc="10;" arrays.lenf="10;" arrays.c="(float*)malloc(arrays.lenc*sizeof(float));" for="" call="" the="" fortran="" subroutine="" back="" in="" gamma="%g\n&quot;,beta,gamma);" span=""></alpha;i++)></stdlib.h></stdio.h></span>](source/cpart_2.c)

<div class="scroll">
```#include <stdio.h>
#include <stdlib.h>
struct pass {int lenc, lenf; float *c,  *f;};

void f_routine(long alpha, double *beta, double *gamma, double delta[], struct pass *arrays);

/* this routine is called by fortran but it
   also calls a fortran routine "simulation"
*/
void do_sim(){ 
	struct pass arrays;
	long alpha;
	double beta;
	double gamma;
	double *delta;
	int i;
	printf("C in do_sim\n");	
	alpha=10;
	delta=(double*)malloc(alpha*sizeof(double));
	beta=0.5;
	gamma=0;
	for (i=0;i<alpha;i++) arrays.lenc="10;" arrays.lenf="10;" arrays.c="(float*)malloc(arrays.lenc*sizeof(float));" for="" call="" the="" fortran="" subroutine="" back="" in="" gamma="%g\n&quot;,beta,gamma);" pre="">
</alpha;i++)></stdlib.h></stdio.h>```</div>
</td><td>
We have a data structure that will have a match in Fortran
This interface statement is for our Fortran Routine
We set alpha, beta, gamma, allocate delta and fill it.
The "len" portions of our data structure are assigned.
We allocate arrays.c and fill it but <b>we don't allocate arrays.f</b>


We call our Fortran routine.


On return from Fortran beta and gamma have been changed and arrays.f has been allocated and filled.

</td>
</tr>
</tbody></table>
- - -

# Finally... we have our Fortran called by C
<table>
<tbody><tr>
<td>

	[Source: simulation.f90<span class="custom critical">SUBROUTINE SIMULATION(ALPHA, BETA, GAMMA, DELTA, ARRAYS) BIND(C ,NAME='f_routine')
    USE ISO_C_BINDING
    IMPLICIT NONE
    INTEGER (C_LONG), VALUE :: alpha
    REAL (C_DOUBLE), INTENT(INOUT) :: beta
    REAL (C_DOUBLE), INTENT(OUT) :: gamma
    REAL (C_DOUBLE),DIMENSION(*),INTENT(IN) :: DELTA 
    TYPE, BIND(C) :: PASS
        INTEGER (C_INT) :: LENC, LENF
        TYPE (C_PTR) :: C, F 
    END TYPE PASS
    TYPE (PASS), INTENT(INOUT) :: ARRAYS
    REAL (C_FLOAT), ALLOCATABLE, TARGET, SAVE :: ETA(:) 
    REAL (C_FLOAT), POINTER :: C_ARRAY(:)
    integer i,j
    write(*,'("In Fortran called from C alpha=",i4,&amp;
              " beta=",f10.2," gamma=",f10.2)')&amp;
            alpha,beta,gamma
    gamma=0.0
    do i=1,alpha
        gamma=gamma+beta*delta(i)
    enddo
    beta=1234.0
        !...
    write(*,*)"! Associate C_ARRAY with an array allocated in C"
    CALL C_F_POINTER (ARRAYS%C, C_ARRAY, (/ARRAYS%LENC/) ) 
    if(c_associated(ARRAYS%C, c_loc(C_ARRAY)))then
        write(*,*)'ARRAYS%C, C_ARRAY point to same target'
    else
        write(*,*)'ARRAYS%C, C_ARRAY do not point to same target'
        stop
    endif
    !...
    write(*,*)"! Allocate an array and make it available in C" 
    ARRAYS%LENF = 100
    ALLOCATE (ETA(ARRAYS%LENF))
    ARRAYS%F = C_LOC(ETA)
    j=min(ARRAYS%lenc,ARRAYS%lenf)
    write(*,*)"Fortan fills the array for C"
    do i=1,j
        ETA(i)=C_ARRAY(i)*2
    enddo
END SUBROUTINE SIMULATION
</span>](source/simulation.f90)

<div class="scroll">
```SUBROUTINE SIMULATION(ALPHA, BETA, GAMMA, DELTA, ARRAYS) BIND(C ,NAME='f_routine')
    USE ISO_C_BINDING
    IMPLICIT NONE
    INTEGER (C_LONG), VALUE :: alpha
    REAL (C_DOUBLE), INTENT(INOUT) :: beta
    REAL (C_DOUBLE), INTENT(OUT) :: gamma
    REAL (C_DOUBLE),DIMENSION(*),INTENT(IN) :: DELTA 
    TYPE, BIND(C) :: PASS
        INTEGER (C_INT) :: LENC, LENF
        TYPE (C_PTR) :: C, F 
    END TYPE PASS
    TYPE (PASS), INTENT(INOUT) :: ARRAYS
    REAL (C_FLOAT), ALLOCATABLE, TARGET, SAVE :: ETA(:) 
    REAL (C_FLOAT), POINTER :: C_ARRAY(:)
    integer i,j
    write(*,'("In Fortran called from C alpha=",i4,&amp;
              " beta=",f10.2," gamma=",f10.2)')&amp;
            alpha,beta,gamma
    gamma=0.0
    do i=1,alpha
        gamma=gamma+beta*delta(i)
    enddo
    beta=1234.0
    
    !...
    write(*,*)"! Associate C_ARRAY with an array allocated in C"
    CALL C_F_POINTER (ARRAYS%C, C_ARRAY, (/ARRAYS%LENC/) ) 
    if(c_associated(ARRAYS%C, c_loc(C_ARRAY)))then
        write(*,*)'ARRAYS%C, C_ARRAY point to same target'
    else
        write(*,*)'ARRAYS%C, C_ARRAY do not point to same target'
        stop
    endif
    !...
    write(*,*)"! Allocate an array and make it available in C" 
    ARRAYS%LENF = 100
    ALLOCATE (ETA(ARRAYS%LENF))
    ARRAYS%F = C_LOC(ETA)
    j=min(ARRAYS%lenc,ARRAYS%lenf)
    write(*,*)"Fortan fills the array for C"
    do i=1,j
        ETA(i)=C_ARRAY(i)*2
    enddo
END SUBROUTINE SIMULATION


```
</div>
</td><td>
The subroutine statement says that this routine can be called from C with the name f_routine

Alpha is passed by value as indicated by the attribute.

Beta has intent inout and gamma out.  Both could have been given intent inout since they are passed as pointers.

Next we have our data structure arrays  having the type pass matching the C pass structure.

We finally have eta and c_array which will be mapped to arrays in the C world.


We are changing beta and gamma.  These changed values gets printed in C.


We are passing in our data structure which contains ARRAYS%C.  We show here haw we can use C_F_POINTER
to set a pointer to that.  Then we call c_associated to check that this worked.   

Next we show how we can allocate an array in Fortran "ETA" and then assign its memory to the array originally from C.
 This is done indirectly, we don't allocate the C variable.  The reason for this is related to what we talked about earlier.  
 The array could be automatically deallocated on routine exit.  Here we give "ETA" the save attribute to prevent that. 


</td>
</tr>
</tbody></table>
- - -

# The Results...
	[Source: results2<span class="custom critical">In C mysum before loop =-1
In C mysum after loop  = 4.5
C in do_sim
Fortran mysum before C call  =    -1.0
Back from C in Fortran mysum =     4.5
   1.00000000       0.00000000    
   2.00000000      0.642787576    
   3.00000000      0.984807730    
   4.00000000      0.866025448    
   5.00000000      0.342020273    
   6.00000000     -0.342019975    
   7.00000000     -0.866025329    
   8.00000000     -0.984807789    
   9.00000000     -0.642787814    
   10.0000000      -3.01991605E-07
Fortran calling C again
In Fortran called from C alpha=  10 beta=      0.50 gamma=      0.00
 ! Associate C_ARRAY with an array allocated in C
 ARRAYS%C, C_ARRAY point to same target
 ! Allocate an array and make it available in C
 Fortan fills the array for C
C back in do_sim
beta = 1234 gamma=2250
0 0
1 2
2 4
3 6
4 8
5 10
6 12
7 14
8 16
9 18
</span>](source/results2)

<div class="scroll">
```In C mysum before loop =-1
In C mysum after loop  = 4.5
C in do_sim
Fortran mysum before C call  =    -1.0
Back from C in Fortran mysum =     4.5
   1.00000000       0.00000000    
   2.00000000      0.642787576    
   3.00000000      0.984807730    
   4.00000000      0.866025448    
   5.00000000      0.342020273    
   6.00000000     -0.342019975    
   7.00000000     -0.866025329    
   8.00000000     -0.984807789    
   9.00000000     -0.642787814    
   10.0000000      -3.01991605E-07
Fortran calling C again
In Fortran called from C alpha=  10 beta=      0.50 gamma=      0.00
 ! Associate C_ARRAY with an array allocated in C
 ARRAYS%C, C_ARRAY point to same target
 ! Allocate an array and make it available in C
 Fortan fills the array for C
C back in do_sim
beta = 1234 gamma=2250
0 0
1 2
2 4
3 6
4 8
5 10
6 12
7 14
8 16
9 18

```
</div>

- - -

# Forall statement

Fortran 95 provides an efficient alternative to the element by element construction of an array value in Fortran 90.


#### Interpreting the FORALL Statement


	

1. Evaluate the subscript and stride expressions for each forall_triplet_spec in any order. All possible pairings of index_name values form the set of combinations. For example, given the following statement:

	

1. Evaluate the scalar_mask_expr for the set of combinations, in any order, producing a set of active combinations (those for which scalar_mask_expr evaluated to .TRUE.). For example, if the mask (I+J.NE.6) is applied to the above set, the set of active combinations is:

	

1. For assignment_statement, evaluate, in any order, <span class="b">all values in the right-hand side expression</span> and all subscripts, strides, and substring bounds in the left-hand side variable for all active combinations of index_name values.

	

1. For assignment_statement, <span class="b">assign, in any order, the computed expression values</span> to the corresponding variable entities for all active combinations of index_name values.



<table>
	<thead>
	<tr>
		<th>Fortran 90 nested Do</th> <th>Similar Fortran 95 Forall</th>
	</tr>
	</thead>
	<tbody>
	<tr>
		<td class="x">```    do j=j1,j2
        do i=i1,i2
            new_psi(i,j)=a1*psi(i+1,j) + a2*psi(i-1,j) + &amp;
                         a3*psi(i,j+1) + a4*psi(i,j-1) - &amp;
                         a5*for(i,j)
         enddo
     enddo
   <span class="b"> psi(i1:i2,j1:j2)=new_psi(i1:i2,j1:j2)</span>		
		```</td>
		
		<td class="y">```   <span class="b"> FORALL (i=i1:i2, j=j1:j2)</span>
            psi(i,j)=a1*psi(i+1,j) + a2*psi(i-1,j) + &amp;
                         a3*psi(i,j+1) + a4*psi(i,j-1) - &amp;
                         a5*for(i,j)
    end forall
		```</td>
	</tr>
	<tr>
		<td class="x">run time = 7.08 (75,000 iterations) </td> <td class="y">run time = 6.58  (75,000 iterations)</td>
	</tr>
	</tbody>
</table>


- - -

# Object-oriented programming (OOP) in Fortran...

### object-oriented programming...

	

- You can define classes that contain both data and methods which operate on that data

	

- Then create separate instances of the class, each with its own data methods called from an instance of the class will work on its data


### Fortran Support in 33 seconds or less

	

- Fortran 90 modules may contain data, but there is no notion of separate instances of a module.

	

- A Fortran 90/95 module can be viewed as an object because it can encapsulate both data and procedures. 

	

- Fortran 2003 (F2003) added the ability for a derived type to encapsulate procedures in addition to data. 

	

- F2003 also introduced type extension to its derived types which implements inheritance.

	

- Inheritance allows code reusability through an implied inheritance link in which leaf objects, known as children, reuse components from their parent and ancestor objects.

	

- Polymorphism is also supported in Fortran 2003.

	

- Polymorphism occurs when a procedure, such as a function or a subroutine, can take a variety of data types as arguments. 

	

- You can also have data polymorphism - a pointer can point to different data types 


- - -

### Really good source for more information

<dl>
	<dt>Fortan Wiki Object-oriented programming</dt>
		<dd><a href="http://fortranwiki.org/fortran/show/Object-oriented+programming">http://fortranwiki.org/fortran/show/Object-oriented+programming</a></dd>
	<dt>Object-Oriented Programming in Fortran 2003 Part 1: Code Reusability</dt>
		<dd><a href="https://www.pgroup.com/lit/articles/insider/v3n1a3.htm">https://www.pgroup.com/lit/articles/insider/v3n1a3.htm</a></dd>
	<dt>Object-Oriented Programming in Fortran 2003 Part 2: Data Polymorphism</dt>
		<dd><a href="https://www.pgroup.com/lit/articles/insider/v3n2a2.htm">https://www.pgroup.com/lit/articles/insider/v3n2a2.htm</a></dd>
	<dt>Object-Oriented Programming in Fortran 2003 Part 3: Parameterized Derived Types</dt>
		<dd><a href="https://www.pgroup.com/lit/articles/insider/v5n2a4.htm">https://www.pgroup.com/lit/articles/insider/v5n2a4.htm</a></dd>
	<dt>Object-Oriented Programming in Fortran 2003 Part 4: User-Defined Derived Type Input/Output</dt>
		<dd><a href="https://www.pgroup.com/lit/articles/insider/v6n2a3.htm">https://www.pgroup.com/lit/articles/insider/v6n2a3.htm</a></dd>
</dl>
- - -

### A cool example from above
	[Source: list.f90 - module<span class="custom critical">Click to open this file in a new window.</span>](source/list.f90)  
	[Source: link.f90 - module<span class="custom critical">Click to open this file in a new window.</span>](source/link.f90)  
	[Source: ll.f90 - module<span class="custom critical">Click to open this file in a new window.</span>](source/ll.f90)  

### Creates a linked list with different data types for values

<table>
<tbody><tr>
<td class="x">Source</td>
<td class="y">Output</td>
</tr>
<tr>
<td class="x">
```program main
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


```
</td>

<td class="y">
```           1
           2
           3
           4
           5
           6
           7
           8
           9
          10
   1.23000002    
 A
 B
 C

```
</td>
</tr>
</tbody></table>



