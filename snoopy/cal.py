#!/usr/bin/env python3
import sys
import os
two="""           JJJJJJJ   AAAAA   N     N  U     U   AAAAA   RRRRRR   Y     Y
              J     A     A  NN    N  U     U  A     A  R     R   Y   Y
              J     A     A  N N   N  U     U  A     A  R     R    Y Y
              J     AAAAAAA  N  N  N  U     U  AAAAAAA  RRRRRR      Y
              J     A     A  N   N N  U     U  A     A  R   R       Y
           J  J     A     A  N    NN  U     U  A     A  R    R      Y
            JJ      A     A  N     N   UUUUU   A     A  R     R     Y
       FFFFFFF  EEEEEEE  BBBBBB   RRRRRR   U     U   AAAAA   RRRRRR   Y     Y
       F        E        B     B  R     R  U     U  A     A  R     R   Y   Y
       F        E        B     B  R     R  U     U  A     A  R     R    Y Y
       FFFFF    EEEEE    BBBBBB   RRRRRR   U     U  AAAAAAA  RRRRRR      Y
       F        E        B     B  R   R    U     U  A     A  R   R       Y
       F        E        B     B  R    R   U     U  A     A  R    R      Y
       F        EEEEEEE  BBBBBB   R     R   UUUUU   A     A  R     R     Y
                    M     M   AAAAA   RRRRRR    CCCCC   H     H
                    MM   MM  A     A  R     R  C     C  H     H
                    M M M M  A     A  R     R  C        H     H
                    M  M  M  AAAAAAA  RRRRRR   C        HHHHHHH
                    M     M  A     A  R   R    C        H     H
                    M     M  A     A  R    R   C     C  H     H
                    M     M  A     A  R     R   CCCCC   H     H
                     AAAAA   PPPPPP   RRRRRR   IIIIIII  L
                    A     A  P     P  R     R     I     L
                    A     A  P     P  R     R     I     L
                    AAAAAAA  PPPPPP   RRRRRR      I     L
                    A     A  P        R   R       I     L
                    A     A  P        R    R      I     L
                    A     A  P        R     R  IIIIIII  LLLLLLL
                             M     M   AAAAA   Y     Y
                             MM   MM  A     A   Y   Y
                             M M M M  A     A    Y Y
                             M  M  M  AAAAAAA     Y
                             M     M  A     A     Y
                             M     M  A     A     Y
                             M     M  A     A     Y
                         JJJJJJJ  U     U  N     N  EEEEEEE
                            J     U     U  NN    N  E
                            J     U     U  N N   N  E
                            J     U     U  N  N  N  EEEEE
                            J     U     U  N   N N  E
                         J  J     U     U  N    NN  E
                          JJ       UUUUU   N     N  EEEEEEE
                         JJJJJJJ  U     U  L        Y     Y
                            J     U     U  L         Y   Y
                            J     U     U  L          Y Y
                            J     U     U  L           Y
                            J     U     U  L           Y
                         J  J     U     U  L           Y
                          JJ       UUUUU   LLLLLLL     Y
                 AAAAA   U     U   GGGGG   U     U   SSSSS   TTTTTTT
                A     A  U     U  G     G  U     U  S     S     T
                A     A  U     U  G        U     U  S           T
                AAAAAAA  U     U  G   GGG  U     U   SSSSS      T
                A     A  U     U  G     G  U     U        S     T
                A     A  U     U  G     G  U     U  S     S     T
                A     A   UUUUU    GGGGG    UUUUU    SSSSS      T
 SSSSS   EEEEEEE  PPPPPP  TTTTTTT  EEEEEEE  M     M  BBBBBB   EEEEEEE  RRRRRR
S     S  E        P     P    T     E        MM   MM  B     B  E        R     R
S        E        P     P    T     E        M M M M  B     B  E        R     R
 SSSSS   EEEEE    PPPPPP     T     EEEEE    M  M  M  BBBBBB   EEEEE    RRRRRR
      S  E        P          T     E        M     M  B     B  E        R   R
S     S  E        P          T     E        M     M  B     B  E        R    R
 SSSSS   EEEEEEE  P          T     EEEEEEE  M     M  BBBBBB   EEEEEEE  R     R
            OOOOO    CCCCC   TTTTTTT   OOOOO   BBBBBB   EEEEEEE  RRRRRR
           O     O  C     C     T     O     O  B     B  E        R     R
           O     O  C           T     O     O  B     B  E        R     R
           O     O  C           T     O     O  BBBBBB   EEEEE    RRRRRR
           O     O  C           T     O     O  B     B  E        R   R
           O     O  C     C     T     O     O  B     B  E        R    R
            OOOOO    CCCCC      T      OOOOO   BBBBBB   EEEEEEE  R     R
       N     N   OOOOO   V     V  EEEEEEE  M     M  BBBBBB   EEEEEEE  RRRRRR
       NN    N  O     O  V     V  E        MM   MM  B     B  E        R     R
       N N   N  O     O  V     V  E        M M M M  B     B  E        R     R
       N  N  N  O     O  V     V  EEEEE    M  M  M  BBBBBB   EEEEE    RRRRRR
       N   N N  O     O   V   V   E        M     M  B     B  E        R   R
       N    NN  O     O    V V    E        M     M  B     B  E        R    R
       N     N   OOOOO      V     EEEEEEE  M     M  BBBBBB   EEEEEEE  R     R
       DDDDDD   EEEEEEE   CCCCC   EEEEEEE  M     M  BBBBBB   EEEEEEE  RRRRRR
       D     D  E        C     C  E        MM   MM  B     B  E        R     R
       D     D  E        C        E        M M M M  B     B  E        R     R
       D     D  EEEEE    C        EEEEE    M  M  M  BBBBBB   EEEEE    RRRRRR
       D     D  E        C        E        M     M  B     B  E        R   R
       D     D  E        C     C  E        M     M  B     B  E        R    R
       DDDDDD   EEEEEEE   CCCCC   EEEEEEE  M     M  BBBBBB   EEEEEEE  R     R
         SUNDAY            MONDAY            TUESDAY          WEDN
ESDAY         THURSDAY           FRIDAY           SATURDAY
        1    222  33333    4  55555  666  77777  888   999
       11   2   2     3   44  5     6         7 8   8 9   9
        1      2    33   4 4  5555  6666     7   888   9999
        1    2    3   3 44444     5 6   6   7   8   8     9
      11111 22222  333     4  5555   666    7    888   999
  000    1    222  33333    4  55555  666  77777  888   999
 0   0  11   2   2     3   44  5     6         7 8   8 9   9
 0   0   1      2    33   4 4  5555  6666     7   888   9999
 0   0   1    2    3   3 44444     5 6   6   7   8   8     9
  000  11111 22222  333     4  5555   666    7    888   999
    31    28    31    30    31    30    31    31    30    31    30    31
      1        I  ---------I-- -----
    m1  yr01    m2  yr02     1                                                  
 11-1                                                                      *PAGE
 1152  1X 1  1X 1  9X-1 51  5X10  2O-1 50  4X 1  1X 4  2/ 6  2O-1 49  2X 1 SNP 1
 1X 5  2/ 9  2O-1 48  4X 5  2/11  2O-1 48  2X 6  2/12  2O-1 47  2$22  2O-1 SNP 2
46  3$23  2O-1 45  3$ 1  1$ 9  4* 3  4* 2  2O-1 45  3$ 1  1$ 9  5* 2  5* 2 SNP 3
 1O-1 45  3$ 1  1$ 9  5* 2  5* 2  2O-1 44  6$ 9  5* 2  5* 3  5O-1 44  3$ 1 SNP 4
 2$ 9  4* 4  4* 8  3O-1 43  4$ 1  2$33  2O-1 43  7$35  2O-1 43  6$37  3O-1 SNP 5
43  7$37  3O-1 43  7$38  3O-1 42  6$ 1  2$38  3O-1 42  7$ 1  2$22  7M 8  3OSNP 6
-1 42  7$ 1  1$ 1  2O19 11M 5  3O-1 42  7$ 1  1$ 2  2O18 11M 5  3O-1 41  8$SNP 7
 1  1$ 3  1O 1  6O14  7M 6  3O-1 41  1$ 1  6$ 1  1$ 4  1O 5  6O21  3O-1 41 SNP 8
 1$ 1  6$ 1  1$ 4  2O 7  3O20  3O-1 41  7$ 2  1$ 5  1O 7  1O 2  3O14  4O-1 SNP 9
41  1$ 4  2$ 2  1$ 6  1O 6  1O 4 16O-1 41  2$ 3  1$ 1  1$ 8  1O 6  1O 4  1$SNP10
 1  1$ 2  2$-1 42  3$ 1  1$ 1  1$ 7 10* 3  1$ 1  1$ 1  3$-1 44  2$11  1O 1 SNP11
 5* 1  2O 2  1$ 2  3$-1 44  2$10  2O 7  2O 2  2$ 1  1$ 1  1$-1 55  2O 8  2OSNP12
 3  2$ 1  1$-1 56  2O 8  2O-1 55  2O10  2O-1 55  2O11  2O-1 54  2O12  2O-1 SNP13
53  2O13  2O-1 51  3O 6  1O 7  2O-1 50  3O 7  1O 7  3O-1 49  3O 2  1O 5  1OSNP14
 8  2O-1 48  3O 2  1O 5  2O 8  2O-1 47  3O 3  1O 5  2O 8  2O-1 46  2O 1  3OSNP15
 1  1O 5  2O 8  2O-1 45  4O 2  3O 5  2O 8  2O-1 44  3O 5  2O 5  2O 7  2O-1 SNP16
44  3O 5  2O 5  2O 7  3O-1 43  2O 7  1O 6  3O 5  2O 1  4O-1 43  2O 7  1O 4 SNP17
 8O 1 14O-1 38  6I 3O 5  1O 7  1O 3  7O 9  2O-1 34  4I 1  6I 2O 5  1O17  3OSNP18
 8  2O-1 32  3I11  7O12  4O 4  2O 3  1O 3  2O10  6--1 32  7I 3  2I 8  1O15 SNP19
 3O 3  2O 3  2O 2  1O 3  8--1 37  3I 3  3I 6  1O10  1O 6  2O 3  1O 4  1O 2 SNP20
 1O-1 39  6I 1  4I 2  2O 9  2O 6  2O 2  3O 2  1O 1  2O10  6--1 49  4-13O 5 SNP21
 1O 1  2O 1  7O 2 10--1 37  9-17  8O 1  2O-1 -1 -1 49  1L 1O 1V 1E 1  1I 1SSNP22
 1  1A 1  1W 1E 1T 1  1P 1U 2P 1Y 1  1D 1O 1G-1                            SNP23
-2                                                                         *EOP*
 1151 10X-1 51 14X-1 49  4X 4  3X 3  3X-1 48  4X 4  1X 2  2X 3  3X-1 47  3XDOC 1
15  3X-1 46  2X19  2X-1 45  3X20  2X-1 44  3X22  2X-1 44  3X22  3X-1 44  3XDOC 2
14  2X 1  3X 3 11X-1 44  2X12  5X 3  4X 2  5X 3  4X-1 44  2X11  2X24  3X-1 DOC 3
44  2X39  2X-1 44  1X41  2X-1 44  1X42  2X-1 43  2X43  2X-1 43  2X 1  1X 2 DOC 4
 2X38  2X-1 43  1X 1  2X 1  4X38  2X-1 43  1X 2  2X 1  4X23  5X 9  2X-1 43 DOC 5
 1X 2  7X21  8X 8  2X-1 43  1X 2  8X20  8X 8  2X-1 43  1X 2  9X20  6X 9  2XDOC 6
-1 43  1X 2 10X33  2X-1 43  1X 2 10X33  2X-1 43  1X 2 10X32  3X-1 43  2X 1 DOC 7
10X31  3X-1 44  1X 1  8X 1  1X31  2X-1 44  1X 1  8X 1  2X28  3X-1 44  1X 2 DOC 8
 7X 1  3X10 19X-1 45  1X 1  7X 1  4X 8  6X-1 45  1X 2  6X 1  5X 6  2X 2  3XDOC 9
-1 46  1X 1  6X 1  2X 2  2X 5  2X 2  3X-1 46  2X 1  5X 1  2X 3  2X 4  2X 2 DOC10
 3X-1 48  1X 2  2X 2  1X 5  8X-1 49  2X 3  2X 4 10X-1 50  5X 6  2X 6  2X-1 DOC11
52  1X 7  2X 8  1X-1 56  4X 4 10X-1 55  3X 3  6X 3  6X-1 54  2X16  3X 1  1XDOC12
-1 36 19X18 24X-1 35  1X17  4X 3  8X 4  3X22  1X-1 34  1X19  7X 5  3X 2  3XDOC13
24  1X-1 33  1X34  5X26  1X-1 32  1X67  1X-1 31 71X-1 31  1X69  1X-1 31  1XDOC14
52 14X 3  1X-1 31  1X52  1X12  1X 3  1X-1 31  1X 2  4X 2  5X 1  5X 1  5X 1 DOC15
 5X 1  4X 4  3X 2  5X 2  1X 1  3X 2  1X 3  1X 1  1X 3  1X-1 31  1X 2  1X 3 DOC16
 1X 1  1X 3  1X 1  1X 7  1X 3  1X 3  1X 1  1X 3  1X 4  1X 3  1X 6  1X 2  1XDOC17
 3  2X 2  1X 1  1X 3  1X-1 31  1X 2  1X 3  1X 1  1X 3  1X 1  1X 7  1X 3  1XDOC18
 3  1X 1  4X 5  1X 3  5X 2  1X 2  1X 3  1X 1  1X 1  1X 1  1X 3  1X-1 31  1XDOC19
 2  1X 3  1X 1  1X 3  1X 1  1X 7  1X 3  1X 3  1X 1  1X 1  1X 6  1X 7  1X 2 DOC20
 1X 2  1X 3  1X 2  2X 1  1X 3  1X-1 31  1X 2  4X 2  5X 1  5X 3  1X 3  5X 1 DOC21
 1X 2  1X 4  3X 2  5X 2  1X 1  3X 2  1X 3  1X 1  1X 3  1X-1 31  1X52  1X12 DOC22
 1X 3  1X-1 31  1X52 14X 3  1X-1 31  1X69  1X-1 31  1X69  1X-1 31  1X69  1XDOC23
-1                                                                         DOC24
-2                                                                         *EOP*
 11-1 35  6$ 9  5$-1 33 10$ 5 10$-1 32 12$ 3 13$-1 31 14$ 1 15$-1 30 15$ 1 MAY 1
16$-1 30 15$ 1 16$-1 30 15$ 1 16$-1 31 10$ 8 12$-1 32  7$12  8$-1 33  5$14 MAY 2
 5$-1 56  8$-1 29  7$18 11$-1 27  9$17 12$-1 26 11$15 13$-1 26 12$13 14$-1 MAY 3
26 14$ 1  2$ 5  4$ 1 12$-1 27 12$ 1 13$ 1 10$-1 28  9$ 3 13$ 3  6$-1 30  6$MAY 4
 3 14$-1 39 13$ 1  2$-1 40 11$ 2  2$-1 42  9$ 3  2$-1 54  2$-1 55  2$-1 55 MAY 5
 2$-1 55  2$-1 55  2$47  1, 3  1.-1 55  2$47  1, 2  1/ 3  1.-1 55  2$ 7  8$MAY 6
32  1, 1  1/ 2  1. 1- 2  1.-1 54  2$ 4 14$30  1. 2  1. 1- 2  1. 1--1 53  2$MAY 7
 3 16$28  1. 1/ 4  1. 2- 1  3.-1 28  6$18  2$ 2 19$18  1. 8- 1  1* 5  1. 2-MAY 8
-1 24 14$13  2$ 1 11$27  1/16  7.-1 23 16$11 12$30  1,17  2.-1 22  8# 1  9$MAY 9
 9 10$34  8.11  4--1 21  6$ 7  7$ 6  5$49  1. 8  2- 2.-1 21  2$12  7$ 4  3$MAY10
53  1. 2  1. 3- 2. 3  1--1 36  6$ 3  2$55  1. 1  1, 6  1- 1.-1 37  5$ 2  2$MAY11
55  1/ 3  1,-1 39  4$ 1  2$54  1/ 1  1, 1  1, 1  1,-1 39  4$ 1  2$53  1, 2 MAY12
 1, 1  1, 2  1,-1 40  5$54  1, 2  1, 2  1, 1  1,-1 41  4$54  1, 2  1, 2  1,MAY13
 1  1,-1 42  3$54  1, 3  1, 1  1, 1  1,-1 43  2$55  1, 3  1, 2  1,-1 44  1$MAY14
56  1- 2. 1, 1.10- 1.-1 44  1$59  1I 3 10--1 44  1$53  9/ 1.-1 -1 -1 -1 -1 MAY15
-1 -1 -1 65  1S 1  1I 1  1G 1  1H 2  1. 1  1. 1  1.-1                      MAY16
-2                                                                         *EOP*
 11-1O 1+-1  1 -1O 1+-1  1 -1O 1+63  7$-1  1 -1O 1+59 15$-1  1 -1O 1+57 18$SKP 1
-1  1 -1O 1+57 18$-1  1 -1O 1+35  4$20 15$-1  1 37O 1 -1O 1+33  4$ 1  2$28 SKP 2
 5$-1  1 36O 1 -1O 1+30  6$ 1  3$26  6$-1  1 35O 1 -1O 1+29  6$ 1  3$24  8$SKP 3
-1  1 34O 1 -1O 1+27  7$ 1  3$14  6$ 3  6$ 7 13$-1  1 74O12 -1O 1+26 11$11 SKP 4
16$ 8  2$12  4$-1  1 50O12 10O17 -1O 1+25 11$11  2$13 10$17  2$-1  1 26O 1 SKP 5
20O 8  2O33 -1O 1+23  3$ 1  8$10  2$ 8  2$33  2$-1  1 25O 1 20O 8  2O35 -1OSKP 6
 1+22  3$ 1  8$10  2$ 8  2$35  2$-1  1 25O 1 19O 8  2O21  9O 7 -1O 1+21  4$SKP 7
 1  6$11  2$ 8  2$21  9$ 7  2$-1  1 24O 1 19O31 12O 6 -1O 1+20  4$ 1  6$10 SKP 8
 3$31 12$ 6  2$-1  1 45O16  2O12 12O 6 -1O 1+20 25$16  2$12 12$ 6  2$-1  1 SKP 9
45O16  2O30 -1O 1+20 25$16  2$30  2$-1  1 45O17  2O21  2O 5 -1O 1+21 24$17 SKP10
 2$21  2$ 5  2$-1  1 45O18  2O19  2O 5 -1O 1+23 15$ 4  3$18  2$19  2$ 5  2$SKP11
-1  1 45O20  2O14  3O 4 -1O 1+43  2$20  2$14  3$ 4  3$-1  1 46O20  2O 4 -1OSKP12
 1+44  2$20  2$ 4 16$-1  1 50O17 -1O 1+46  4$17  7$-1  1 54O14 -1O 1+49  5$SKP13
14  3$14  4$-1  1 58O10 18O 2 -1O 1+53  5$10  2$14  2$ 2  1$ 3  3$-1  1 60OSKP14
 8 18O 2 -1O 1+58  2$ 8  2$14  2$ 2  9$-1  1 61O 7 18O 2  1O 7 -1O 1+59  2$SKP15
 7  2$14  2$ 2  1$ 7  3$-1  1 84O11 -1O 1+61 10$11  2$11  4$-1  1 82O14 -1OSKP16
 1+48  4$ 9 12$ 6  3$14  3$-1  1 48O 4 28O 7 -1O 1+46  2$ 4  1$ 7 13$ 4  3$SKP17
 7 12$-1  1 47O 5 14O 6  6O 6 -1O 1+45  2$ 5  1$ 8  5$ 6  6$ 6  4$ 4  5$-1 SKP18
 1 48O 4 14O 8  1O 7 -1O 1+46  2$ 4  2$11  1$ 8  1$ 7  3$-1  1 50O 2 14O12 SKP19
-1O 1+48  2$ 2 14$12  4$-1  1 49O30 -1O 1+45  4$30  2$-1  1 45O35 -1O 1+43 SKP20
 2$35  2$-1  1 45O 8 14O14 -1O 1+42  3$ 8 14$14  2$-1  1 47O 6 14O15 -1O 1+SKP21
42  5$ 6  2$10  2$15  2$-1  1 46O 3  1O 3 14O16 -1O 1+43  3$ 3  1$ 3  1$11 SKP22
 2$16  2$-1  1 47O 2 18O17 -1O 1+45  2$ 2  5$11  2$17  2$-1  1 66O19 -1O 1+SKP23
47  5$12  2$19  2$-1  1 66O 7  7O 5 -1O 1+64  2$ 7  7$ 5  3$-1  1 66O 5  4OSKP24
 4  2O 5 -1O 1+57  3$ 4  2$ 5  4$ 4  2$ 5  2$-1  1 66O 3  2O 8  2O 5 -1O 1+SKP25
55  4$ 4  3$ 3  2$ 8  2$ 5  2$-1  1 57O 5O 4O 1  3O 9  2O 5 -1O 1+54  3$ 5 SKP26
 4$ 1  3$ 9  2$ 5  2$-1  1 54O 1 13O11  1O 6 -1O 1+53  1$ 1  2$ 5  6$11  1$SKP27
 6  7$-1  1 53O 2 11O12  2O 4  3O 4 -1O 1+52  1$ 2  1$ 5  5$12  2$ 4  3$ 4 SKP28
 3$-1  1 52O 2 11O12  2O 2  3O 6 -1O 1+51  1$ 2  2$ 5  4$12  2$ 2  3$ 6  3$SKP29
-1  1 52O 2 11O11  4O 6 -1O 1+49  3$ 2  2$ 5  4$11  4$ 6  4$-1  1 51O 3 10OSKP30
10  5O 3  3O 1 -1O 1+48  3$ 3  2$ 5  3$10  5$ 3  3$ 1  3$-1  1 48O 1  2O 3 SKP31
10O 9  3O 7 -1O 1+47  1$ 1  2$ 3  2$ 5  3$ 9  3$ 7  5$-1  1 48O 2  1O 3 10OSKP32
 7  3O 6 -1O 1+47  1$ 2  1$ 3  2$ 5  3$ 7  3$ 6 12$-1  1 48O 2  1O 4 10O 3 SKP33
 3O 6  5O 6 -1O 1+46  2$ 2  1$ 4 10$ 3  3$ 6  5$ 6  3$-1  1 48O 2  1O 6  8OSKP34
 2 13O 4 -1O 1+46  2$ 2  1$ 6  8$ 2 13$ 4  5$-1  1 48O 2 13O 5  6O 6 -1O 1+SKP35
46  2$ 2 13$ 5  6$ 6  9$-1  1 49O 7 14O 5  7O 7 -1O 1+47  2$ 7 14$ 5  7$ 7 SKP36
 5$-1  1 76O16 -1O 1+48 28$16  3$-1  1 65O10 -1O 1+54  4$ 4  3$10 21$-1  1 SKP37
70O 7  1O 7 -1O 1+47 10$ 7  6$ 7  1$ 7  5$-1  1 81O 4 -1O 1+48  8$13 12$ 4 SKP38
 6$-1  1 -1O 1+79 11$-1  1 -1O                                             SKP39
-2                                                                         *EOP*
 1156 20*-1  1+56 20Q-1 54  3*20  3*-1  1+53  3Q20  3Q-1 52  2*26  2*-1  1+YOY 1
51  2Q26  2Q-1 50  2*10 10* 9  1*-1  1+49  2Q10 10Q 9  1Q-1 49  1*22  1* 9 YOY 2
 2*-1  1+48  1Q22  1Q 9  2Q-1 48  1*23  1*11  1*-1  1+47  1Q23  1Q11  1Q-1 YOY 3
46  2* 8  1* 3  2* 8  2*13  1*-1  1+45  2Q 8  1Q 3  2Q 8  2Q13  1Q-1 46  1*YOY 4
10 13*16  2*-1  1+45  1Q10 13Q16  2Q-1 45  1*41  1*-1  1+44  1Q41  1Q-1 45 YOY 5
 1*42  1*-1  1+44  1Q42  1Q-1 45  1*12  3* 3  4* 2  3*15  1*-1  1+44  1Q12 YOY 6
 3Q 3  4Q 2  3Q15  1Q-1 45  1*12  3* 7  1* 1  3*15  1*-1  1+44  1Q12  3Q 7 YOY 7
 1Q 1  3Q15  1Q-1 45  1*22  1*19  1*-1  1+44  1Q22  1Q19  1Q-1 45  1*16  6*YOY 8
20  2*-1  1+44  1Q16  6Q20  2Q-1 43  3*42  1* 1  2*-1  1+42  3Q42  1Q 1  2QYOY 9
-1 43  1*33  1*10  1* 1  2*-1  1+42  1Q33  1Q10  1Q 1  2Q-1 43  1*33  3* 8 YOY10
 1* 1  2*-1  1+42  1Q33  3Q 8  1Q 1  2Q-1 43  1*10  3*19  1*10  3*-1  1+42 YOY11
 1Q10  3Q19  1Q10  3Q-1 44  4* 9  1*16  2*11  1*-1  1+43  4Q 9  1Q16  2Q11 YOY12
 1Q-1 48  1* 9 16*12  1*-1  1+47  1Q 9 16Q12  1Q-1 49  1*35  1*-1  1+48  1QYOY13
35  1Q-1 50  2*32  1*-1  1+49  2Q32  1Q-1 52  1*29  2*-1  1+51  1Q29  2Q-1 YOY14
53  3*24  2*-1  1+52  3Q24  2Q-1 56  2*18  4*-1  1+55  2Q18  4Q-1 58 18*-1 YOY15
 1+57 18Q-1 58 16*-1  1+57 16Q-1 44  4*10  3*12  3*14  4* 2  2*-1  1+43  4QYOY16
10  3Q12  3Q14  4Q 2  2Q-1 39  5* 2  2* 9  1* 3  1*10  1* 3  1*12  1* 4  2*YOY17
 1  3*-1  1+38  5Q 2  2Q 9  1Q 3  1Q10  1Q 3  1Q12  1Q 4  2Q 1  3Q-1 39  2*YOY18
 2  1* 2  4* 6  1* 5 10* 5  1*11  1* 4  2* 1  3*-1  1+38  2Q 2  1Q 2  4Q 6 YOY19
 1Q 5 10Q 5  1Q11  1Q 4  2Q 1  3Q-1 41  3* 2  2* 2  6*22 12* 3  1* 3  4*-1 YOY20
 1+40  3Q 2  2Q 2  6Q22 12Q 3  1Q 3  4Q-1 39  5* 4  1* 3  1*33  2* 4  1* 7 YOY21
 1*-1  1+38  5Q 4  1Q 3  1Q33  2Q 4  1Q 7  1Q-1 37  2* 2  2* 5 42* 7  1*-1 YOY22
 1+36  2Q 2  2Q 5 42Q 7  1Q-1 37  7* 8  1*27  1* 5  2* 9  3*-1  1+36  7Q 8 YOY23
 1Q27  1Q 5  2Q 9  3Q-1 40  4* 8  1*28  1* 4  2* 5  3* 1  1*-1  1+39  4Q 8 YOY24
 1Q28  1Q 4  2Q 5  3Q 1  1Q-1 43  3* 6  1*29  2* 4  1* 4  1* 2  2*-1  1+42 YOY25
 3Q 6  1Q29  2Q 4  1Q 4  1Q 2  2Q-1 43  1* 1  1* 4  2* 2  2*26  2* 5  1* 2 YOY26
 2*-1  1+42  1Q 1  1Q 4  2Q 2  2Q26  2Q 5  1Q 2  2Q-1 43  1* 2  8*28  2* 5 YOY27
 3*-1  1+42  1Q 2  8Q28  2Q 5  3Q-1 43  1* 8  1* 7  1* 7  1* 9  2* 2  7*-1 YOY28
 1+42  1Q 8  1Q 7  1Q 7  1Q 9  2Q 2  7Q-1 43  1* 8  2* 5  4* 4  4* 6  4* 1 YOY29
 4*-1  1+42  1Q 8  2Q 5  4Q 4  4Q 6  4Q 1  4Q-1 43  1* 8  4* 2  6* 2  6* 4 YOY30
10*-1  1+42  1Q 8  4Q 2  6Q 2  6Q 4 10Q-1 43  1* 8  5* 1  7* 1  7* 1 13*-1 YOY31
 1+42  1Q 8  5Q 1  7Q 1  7Q 1 13Q-1 43  1* 8 35*-1  1+42  1Q 8 35Q-1 43  1*YOY32
 8  1* 1  7* 1  7* 1  7* 3  7*-1  1+42  1Q 8  1Q 1  7Q 1  7Q 1  7Q 3  7Q-1 YOY33
40  6* 6  1* 3  4* 4  4* 4  4* 5  4* 1  1*-1  1+39  6Q 6  1Q 3  4Q 4  4Q 4 YOY34
 4Q 5  4Q 1  1Q-1 38  2* 6  2* 4  1* 4  1* 7  1* 7  1* 8  2* 2  1*-1  1+37 YOY35
 2Q 6  2Q 4  1Q 4  1Q 7  1Q 7  1Q 8  2Q 2  1Q-1 37  1*10  1* 3  1*33  1*-1 YOY36
 1+36  1Q10  1Q 3  1Q33  1Q-1 36 14* 2  1*33  1*-1  1+35 14Q 2  1Q33  1Q-1 YOY37
36  1*12  1* 2 35*-1  1+35  1Q12  1Q 2 35Q-1 36 14* 2 35*-1  1+35 14Q 2 35QYOY38
-1 36 14* 2 35*-1  1+35 14Q 2 35Q-1 37  1*10  1* 3 35*-1  1+36  1Q10  1Q 3 YOY39
35Q-1 38  2* 6  2* 9  1* 3 17* 3  1*-1  1+37  2Q 6  2Q 9  1Q 3 17Q 3  1Q-1 YOY40
40  6*11  1* 8  2* 4  1* 8  1*-1  1+39  6Q11  1Q 8  2Q 4  1Q 8  1Q-1 57  1*YOY41
 3  7* 2 12*-1  1+56  1Q 3  7Q 2 12Q-1 57 11* 1 21*-1  1+56 11Q 1 21Q-1 54 YOY42
11* 3 17* 5  3*-1  1+53 11Q 3 17Q 5  3Q-1 53  1*23  1*14  1*-1  1+52  1Q23 YOY43
 1Q14  1Q-1 52  1*23 17*-1  1+51  1Q23 17Q-1 53 23*-1  1+52 23Q-1  0  0  0 YOY44
-2                                                                         *EOP 
 1152  3*-1 51  6*-1 49  1* 8  1*-1 48  1*10  1*-1 48  1*10  1* 7  5*-1 47 DGH 1
 1*11  1* 4  1* 8  1*-1 47  1*10  1* 4  1*10  1* 6  4*-1 47  1*10  2* 2  1*DGH 2
12  1* 3  2* 2  1* 1  1*-1 46  1* 1  2O 6  1* 2  2& 9  1* 3  2* 8  1*-1 45 DGH 3
 1* 8  1* 5  2&14  1* 3  2* 3  1*-1 44  1*15  2&15  3* 1  5*-1 44  1*15  2&DGH 4
 2  9*12  1*-1 44  1*15  2&11  1*11  1*-1 46  2* 2  3* 7  2& 7* 5  6* 5  1*DGH 5
-1 36 12X 2* 3& 7* 2& 7X 1* 2  2* 6X 5*16X-1 36  1X12  5&16  2*28  1X-1 36 DGH 6
 1X12  5&46  1X-1 36  1X12  5&46  1X-1 36  1X11  6&46  1X-1 36  1X11  6&46 DGH 7
 1X-1 35 13X 6&48X-1 35  1X11  7&47  1X-1 35  1X11  7&47  1X-1 35  1X12  6&DGH 8
47  1X-1 35  1X13  4&48  1X-1 35  1X14  2&49  1X-1 35  1X65  1X-1 34 69X-1 DGH 9
34  1X67  1X-1 34  1X67  1X-1 34  1X67  1X-1 34  1X67  1X-1 34  1X67  1X-1 DGH10
34  1X67  1X-1 34 69X-1 35  1X65  1X-1 35 67X-1 43  1X47  1X-1 43  1X47  1XDGH11
-1 43 49X-1 43  1X47  1X-1 43  1X47  1X-1 43  1X47  1X-1 43  1X47  1X-1 43 DGH12
 1X47  1X-1 43 49X-1 43  1X47  1X-1 43  1X47  1X-1 43  1X47  1X-1 43  1X47 DGH13
 1X-1 43  1X47  1X-1 43 49X-1 43  1X47  1X-1 43 49X-1                      DGH14
-2                                                                         *EOP*
 11   89 11*-1 87 19*-1 84  4* 4  2* 3  2* 2  2* 2  4*-1 81  3* 9 14* 1  3*PNT 1
-1 28  4*47  3*23  2* 3  3*-1 27  2*47  3*28  4* 1  3*-1 26  2*48  3*30  2*PNT 2
 3  2*-1 19  4* 3  1*17 12*20  2*33  3* 1  2*-1 16 12*14  4* 7  6*17  2* 3 PNT 3
 3*32  2*-1 14  5* 8  4* 1  2* 5  4*15  3*15  3* 3  5*30  2*-1 12  3*14 12*PNT 4
20  3* 1  3* 9  3* 6  4*27  3*-1 11  3*18  2*28  7* 9  2* 9  4*25  2*-1 10 PNT 5
 2*20  2*28  3* 2  3* 9  2*11  5*21  3*-1  9  2*21  2*29  7* 9  3*14  5*18 PNT 6
 2*-1  9  1*23  2*28  7*10  3*17  5*14  2*-1  8  1*53  6*13  3*19  6*10  2*PNT 7
-1  8  1*53  2*19  3*22  7* 4  2*-1  7  3*20  6*24  3*21  4*26  3* 2  2*-1 PNT 8
 7  3*18 13*16  5*24  4*28  2*-1  7  5*16  2* 8 21*29  4*24  3*-1  7  7*14 PNT 9
 2*16  9*36  6*16  4*-1  7  8*13  2*64  7* 7  6*-1  6 11*11  3*69 10*-1  6 PNT10
12*11  2*-1  6 14* 9  3*-1  6 15*10  3*-1  6 15*11  5* 8  6*-1  7 15*13 12*PNT11
 2  2*-1  7 16*24  3*-1  8 16*16  9*-1  9 16*15  2* 2  2*-1 10 21*10  6* 4 PNT12
 9*18  6*-1 11 24* 5 24*13  2* 4  3*-1 12 15* 6 10*19  5*10  2* 5  3*-1 13 PNT13
15* 7  5* 8  7*11  3* 8  2* 3  2* 2  2*-1 15 13* 9  1* 5 16* 9  3* 6  2* 8 PNT14
 2*-1 17 11* 7  3* 1  5*14  3* 9  2* 6  2* 5  5*-1 20  8* 6  3*23  2* 9  2*PNT15
 6  2* 8  2*-1 22  6* 5  2*25  2* 9  3* 7  2* 6  2*-1 24  3* 6  2* 8  8* 3 PNT16
 1* 2  1* 3  2* 9  2* 8  2* 5  3*-1 33 10* 1  2* 4  2* 2  1* 2  1* 2  3* 9 PNT17
 2* 8  2* 6  2*-1 45  1* 5 11*10 12* 6  2*-1 45  2*25  5* 4  3* 6  2*-1 45 PNT18
 2*43  2*-1 46  1*43  2*-1 46  2*42  2*-1 47  2*26  8* 7  2*-1 48  2*24 13*PNT19
 2  3*-1 49  2*21  3* 9  6*-1 50  2*18  3*-1 51  4* 6  2* 7  2*-1 53 10* 6 PNT20
 2*-1 59  3* 6  2*-1 49 11* 4  9*-1 47  3*22  2*-1 47  2*24  2*-1 48  2*15 PNT21
 3* 6  1*-1 49  3* 7  2* 6  3* 2  2*-1 51  4* 5  2* 7  3*-1 54 16*-1 -1 -1 PNT22
-2                                                                         *EOP*
 1162 10*-1 59  4*10  4*-1 56  3*18  2*-1 54  2* 6  6*11  2*-1 53  1* 6  2*CHB 1
19  1*-1 52  1* 6  1*22  1*-1 51  1* 7  1* 6  1* 6  1* 9  1*-1 50  1* 9  2*CHB 2
 2  2* 1  2* 2  2*10  1*-1 50  1*11  2* 5  2*12  1*-1 49  1* 6  1*16  2* 9 CHB 3
 1*-1 49  1* 5  1* 7  4* 8  1* 8  1*-1 48  1* 5  1* 4  2O 1  1* 5  2O 5  1*CHB 4
 8  2*-1 48  1* 5  1* 7  1*11  1* 8  1* 2  1*-1 48  1* 6  1* 7  3*21  1*-1 CHB 5
48  1*37  1*-1 49  1*33  3*-1 50  1*32  1*-1 50  1* 7  1I14- 1I 8  1*-1 51 CHB 6
 1* 1  1* 2  2*23  1*-1 52  1* 1  2* 2  3*18  2*-1 52  1* 1  1* 2  2* 2  1*CHB 7
14  3*-1 52  1* 5  4*10  4*-1 53  1* 5 13* 3  1*-1 54  1* 5  2*12  2*-1 53 CHB 8
 2* 5 13* 3&-1 50  2* 8  3* 4& 4* 7&-1 52  2* 6  4* 2& 6* 5&-1 49  1*10  1*CHB 9
17&-1 48  1*11  1*18&-1 48  1*10  1*20&-1 47  1& 1* 9  1*21&-1 47  2& 1* 7 CHB10
 1*13& 1* 8&-1 47  3& 2* 2  3*14& 2* 8&-1 48  2& 1O 1& 2* 3& 1O 6& 1O 6& 1OCHB11
 1* 8&-1 49  3O 4& 3O 4& 3O 4& 2O 1* 8&-1 49  4O 2& 5O 2& 5O 2& 3O 1* 6  1*CHB12
 1&-1 49 23O 1* 6  1* 2&-1 49  2& 6O 1& 6O 1& 6O 1& 1* 6  1* 2&-1 48  4& 4OCHB13
 3& 4O 3& 4O 2& 1* 6  2* 2&-1 48  5& 2O 5& 2O 5& 2O 3& 1* 1  1* 1  1* 1  4*CHB14
 1&-1 48 24& 1* 1  1* 1  2* 1  1* 3&-1 48 24& 5* 1& 1* 4&-1 49 33X-1 49 33XCHB15
-1 49 33X-1 57  1* 7  1* 2  1* 8  1*-1 57  9* 2  8*-1 57  1* 7  1* 2  1* 8 CHB16
 1*-1 52 28*-1 48  4* 9  4*14  2*-1 46  2*12  2*18  2*-1 45 37*-1 79 -1 54 CHB17
 1O 1H 1, 1  1G 2O 1D 1  1G 1R 1I 1E 1F-1                                  CHB18
-2                                                                         *EOP*
 11-1  1 -1  1 -1 57 13X-1 54  4X11  3X-1 54  1X20  2X-1 53  2X22  2X-1 52 SHR 1
 2X26  2X-1 51  2X29  2X-1 50  2X32  2X-1 49  2X34  2X-1 49  2X35  2X-1 49 SHR 2
 2X36  2X-1 49  2X16  5X16  2X-1 37 11X 1  2X 9  1X 4  1X 2  3X 2  1X15  2XSHR 3
-1 33  4R 8  3X 2  1X 7  2X 4  1X 1  1X 5  1X 1  1X14  2X-1 29  9R 7  5X 1 SHR 4
 6X 1  2X 1  2X 1  1X 6  1X 2  1X13  2X-1 26 12R 7  3X17  1X 6  1X 1  1X13 SHR 5
 2X-1 24 15R 6  3X23  1X 1  1X12  2X-1 21  1X 4 14R 5  3X21  1X 1  2X11  2XSHR 6
-1 19  1X 7 14R 4  7X19  2X 9  2X-1 17  1X10 13R 2  5X 3  1X22  1X 5  2X-1 SHR 7
15  2R12  7R 1X 8  3X 4  1X23  1X 4  2X-1 14  4R12  5R 1X 9  2X 5  1X14  2XSHR 8
 7  1X 5  2X-1 13  6R12  3R 1X10  1R 1X 6  1X14  2X 6  1X 6  2X-1 12  8R12 SHR 9
 2R 1X 7  4R 1X 7  1X15  1X 1  4X 8  2X-1 11 10R12  1R 1X 4  7R 1X 8  1X14 SHR10
 2X 3  1X 8  2X-1 10 12R 9  4V 1X10R 1X 9  1X13  1X 4  1X 8  2X-1 10 13R 5 SHR11
 9V 8R 2X11  1X 5  2X 4  1X 5  1X 6  2X-1  9 15R 2 13V 4R 3X 1  1X12  1X 1 SHR12
 1X 2  1X 4  1X 6  1X 4  2X-1  8  1X 2 13R16V 1R 3X 4  1X17  3X 9  3X-1  8 SHR13
 1X 4 10R17V 2X 7  2X-1  7  1X 7  7R18V11  2X-1  7  1X10  3R19V 1X12  1X 5-SHR14
-1  6  1X12  1R20V 1  2X12  4- 9  1/-1  6  2R12 20V 3  3X 9  4- 8  1/-1  6 SHR15
 4R 9 20V 4  3B 1X 7  4- 8  1/-1  6  6R 6 21V 3  5B 1  4X 2  4- 1 590-1  6 SHR16
 9R 3 20V 3  6B 6  3- 3 59O-1  7 10R20V 3  7B12 59O-1  7 10R20V 1X 1  8B 9 SHR17
 1%61O-1  7  1X 2  7R19V 2  9B 8  1%62O-1  8  1X 7 19V 2  9B72O-1  9  1X 6 SHR18
18V 3  9B72O-1 10  1X 5 17V 1X 2  9B40O 1/24  3O-1 11  1X 4 16V 2  1X 1  9BSHR19
 8  3O54  3O-1 12  1X 3 15V 4  9B 9  3O54  3O-1 13  1X 2 13V 6  8B10  3O54 SHR20
 3O-1 14  2X11V 8  7B11  3O54  3O-1 17  7V11  5B12  3O54  3O-1 36  3B-1    SHR21
-2                                                                         *EOP*
 11-1 54  1/ 4- 1X 6  1/ 4- 1X-1 53  1/ 1  4- 1  1X 4  1/ 1  1/ 2- 1X 1  1XPLT 0
-1 52  1/ 1  1/ 4  1X 1  1X 2  1/ 1  1/ 4  1X 1  1X-1 51  1/ 1  1/ 2  1/ 3-PLT 1
 1X 1  1I 1- 1I 1  1I 1X 3  1I 1  1I-1 51  1I 1  1I 1  1/-1 51  1I 1  1I 1 PLT 2
 1/ 4O 1I 1  1I 1- 1I 1  1I 1O 1X 2  1I 1  1I-1 51  1I 1  1I 1/ 4O 1/ 1  1/PLT 3
 3O 1X 1  1X 1O 1X 1  1/ 1  1/-1 51  1I 1  1X 1/ 3O 1/ 1  1/ 1O 1/ 3- 1X 1 PLT 4
 1X 1- 1X 1  1/-1 52  1X 1  1X 2- 1/ 1  1/ 1O 1/ 5  1X 3- 1/-1 51  1/ 1S 1XPLT 5
 2- 1/ 1- 1X 1O 1/10  1X-1 49  1/ 1X 2S 1/ 5O 1/12  1X-1 48  1/ 2  1X 1/ 5OPLT 6
 1/14  1X-1 47  1/ 4  1X 4O 1I 6  2/ 1X 3  2/ 1X 1  1X-1 47  1I 5  1X 3O 1IPLT 7
 5  2/ 2  1X 1  2/ 2  1X 1  1X 6- 4& 3- 1X-1 47  1I 6  1I 2O 1I 6  1% 18 1<PLT 8
 3  1% 18 1<17  1X-1 47  1I 2  1& 3  1I 1O 1% 1/ 1<32  1X-1 47  1I 6  1I 2OPLT 9
 1I34  1X-1 47  1X 5  1/ 3O 1I35  1X-1 48  1X 3  1/ 4O 1I36  1X-1 49  1X 1-PLT10
 1/ 5O 1X28  1X 1- 1X 5  1<-1 50  1X 7O 1X26  1% 3& 1< 4  1<-1 51  1X 7O 1XPLT11
25  1% 3& 1< 4  1<-1 52  1X 7O 1X 2- 1X23  1X 1- 1X 5  1<-1 53  1X10O 1X 7 PLT12
 3*19  1<-1 54  1X 9- 1X10  1*18  1/-1 63  2X11  1*16  1/-1 65  1X11  1* 2-PLT13
 1X11  1/-1 66  1I 7  1/ 3* 3  1X 9- 1/-1 40  1* 1# 1* 1# 1* 1# 1* 7- 1*11 PLT14
 1I 6  1/-1 41  1* 1I11  1I 1* 5- 1* 4  1I 6  1I10  2--1 40  1* 1I11  1I 1*PLT15
 5  1I 1* 1# 1* 1< 1* 1# 1* 1# 1* 1# 1* 1< 9  1< 2O 1<-1 41  1* 1I11  1I 1*PLT16
 3  1* 1# 1* 3  1% 7O 1< 6  1- 2  1% 2O 1<-1 41  1* 1I11  1I 5- 2* 1# 1* 1%PLT17
 1* 1# 1* 1# 1* 1# 1* 1< 5& 1/ 1  2X 1, 5&-1 38  1* 1# 1* 1# 1*11- 1* 3- 1*PLT18
 6  1I 7  1I 3& 2- 1< 6  1% 3  1<-1 64  1/22  1< 1  1%-1 63  1/22  1< 1  1%PLT19
-1 62  1/18  1- 4  1< 1  1%-1 61  1/ 1* 9  1/ 3& 1I 4& 1/ 1  1/ 2& 1/ 2& 1/PLT20
-1 60  1/ 2&13  1I 8  2X-1 59  1/ 3&13  1I 1  1/ 3& 1< 2  2X-1 58  1/ 3&13 PLT21
 1/ 3& 1< 2  1I 2  2X-1 43  1-13  1/ 4&12  1/ 4& 1I 2  1/ 2  2X-1 45  1-10 PLT22
 1/ 4*13  1I 4  1/ 2  1X 2  2X-1 44  1- 1  1- 7  1/ 3*15  1X 4  1X 3  1< 1 PLT23

 2X-1 45  1- 3  1- 1  1- 1  1  1%11  1/ 5& 1X 1  1X 4  1< 2  1I 1  2X-1 47 PLT24
 1- 1  4* 1  1%10  1& 7  1X 5  1I 2  1I 1  2X-1 50  1- 1  1- 1  1- 1X23  1IPLT25
 2  1I 1  2X-1 56  1X22  1I 2  1I 1  2X-1 57  1X21  1I 2  1I 1  2X-1 58  1XPLT26
 6  1/ 7& 1X 5  1I 2& 1< 1/ 2X-1 59  1X 4& 1/ 9  1X 4& 1< 2  1/ 2X 1/-1 45 PLT27
45X-1 45 45X-1                                                             PLT28
-2                                                                         *EOP*
 11-1                                                                      LHP00
82  1- 6X 1--1 78  4X 8  2X-1 56  5X16  1X15  2X-1 54  2X 5  2X13  1X18  2XLHP 1
-1 52  2X 9  3X 9  1X21  2X-1 50  2X10  1* 1- 2  3X 5  1X15  4* 5  2X-1 49 LHP 2
 2X 9  1/ 3* 5  5X15  6* 6  1X-1 48  3X 8  1- 2*27  7* 6  1X-1 47  3X40  5*LHP 3
 7  1X-1 47  2X18  1/ 1<33  1X-1 46  3X18  1/34  1X-1 46  3X17  1% 1/ 1  1XLHP 4
32  1X-1 44  3X 1  1X20  1- 2X29  1X-1 43  4X 1  1X22  9X20  1X-1 42  4X 2 LHP 5
 1X28  8X13  2X-1 41  1X 1  3X 1  2X26  2X 8 13X-1 41  4X 1  1X26  2X-1 39 LHP 6
 5X 2  2X23  2X-1 39  5X 1  1X 1  2X21  2X-1 38  6X 1  1X 3  2X18  3X-1 37 LHP 7
 4X 1  3X 7  1X14  6X-1 37  4X 1  2X10  1X11  1X 2  5X-1 37  4X 1  2X11  1XLHP 8
 9  1X 3  5X-1 36  3X 1  4X12  1X 7  1X 5  6X-1 36  3X 1  4X13  1X 6  1X 6 LHP 9
 6X-1 36  7X14  1X 6  1X 7  5X-1 36  8X13  1X 6  1X 7  5X-1 37  8X12  1I 6/LHP10
 1I 8  5X-1 38  7X12  1I 6/ 1I 8  5X-1 38  8X11  1I 6/ 1I 8  5X-1 39  7X11 LHP11
 1X 6  1X 8  5X-1 41  5X11  1X 6  1X 8  5X-1 57  1X 6  1X 8  4X-1 57  1X 6 LHP12
 1X 8  3X-1 57  1X 6  1X-1 56  1X 7  1X-1 55  1X 9  1X-1 54  2X 9  1X-1 54 LHP13
 1X10  1X-1 53  1X11  1X-1 53  1X11  1X-1 46  6X 1  1X12  1X 2  6X-1 44  3XLHP14
 4  2X13  1X 1  2X 5  2X-1 43  2X 7  2X13  1X 8  2X-1 43  1X10  1X11  2X 9 LHP15
 1X-1 42  1X11  1X11  1X11  1X-1 42  1X11  1X11  1X11  1X-1 43  1X10  1X11 LHP16
 1X11  1X-1 43  1X10  1X11  1X11  1X-1 44  1X 9  2X10  1X10  1X-1 44  2X 8 LHP17
 1X11  1X10  1X-1 34  8X 4  1X 7  2X 3  2X 5  1X 9  1X-1 33  2X 7  4X 1  1XLHP18
 3  4X 4  2X 5  1X11  7X-1 31  2X 4  2X 7  6X 7  2X 6  2X 6  1X 8  3X-1 31 LHP19
 1X 4  2X21  2X 7  1X 6  2X 5  1X 4  1X-1 31  1X 4  1X 5  1X 6  1X 9  2X 8 LHP20
 2X 6  1X 4  1X 4  1X-1 31  1X 3  1X 6  1X 5  1X10  2X10  1X 6  2X 3  1X 3 LHP21
 1X-1 31 57X-1                                                             LHP22
-2                                                                         *EOP*
 11-1O 1 -1O 1 -1O75  9*-1  1+-1O71  4* 7  3*-1  1+74O 7 -1O69  2*14  1*-1 BGL 1
 1+70O14 -1O66  2* 3  3*12  1*-1  1+67O 3  3O12 -1O50 15* 3  1* 5  1*12  1*BGL 2
-1  1+64O 3  1O 5  1O12 -1O47  3*18  1* 5  1*13  1*-1  1+49O18  1O 5  1O13 BGL 3
-1O45  2*20  2* 4  2*13  1*-1  1+46O20  2O 4  2O13 -1O44  1*22  2* 4  2*14 BGL 4
 1*-1  1+44O22  2O 4  2O14 -1O43  1*38  6* 2  1*-1  1+43O38  6O 2 -1O42  1*BGL 5
12  6*19  9* 1  1*-1  1+42O12  6O19  9O 1 -1O42  1*11  8*17 10* 2  1*-1  1+BGL 6
42O11  8O17 10O 2 -1O42  1*12  5*18 12* 1  1*-1  1+42O12  5O18 12O 1 -1O42 BGL 7
 1*34 13* 1  1*-1  1+42O34 13O 1 -1O42  1*28  1* 5 13* 1  1*-1  1+42O28  1OBGL 8
 5 13O 1 -1O43  1* 7  1*18  1* 1  1* 3 14* 1  1*-1  1+43O 7  1O18  1O 1  1OBGL 9
 3 14O 1 -1O44  1* 5  1* 1  1*16  1* 2  1* 3 14* 1  1*-1  1+44O 5  1O 1  1OBGL10
16  1O 2  1O 3 14O 1 -1O45  2* 3  1* 2  3*11  2* 1  1* 1  1* 2 15* 1  1*-1 BGL11
 1+46O 3  1O 2  3O11  2O 1  1O 1  1O 2 15O 1 -1O47  4* 1  1* 3 12* 3  2* 2 BGL12
14* 2  1*-1  1+50O 1  1O 3 12O 3  2O 2 14O 2 -1O51  3* 2  1* 4  1* 2  1* 3 BGL13
 3* 4 14* 1  1*-1  1+53O 2  1O 4  1O 2  1O 3  3O 4 14O 1 -1O54 15* 4 15* 1 BGL14
 1*-1  1+68O 4 15O 1 -1O62  1* 8  2* 2 12* 2  1*-1  1+62O 8 16O 2 -1O63  1*BGL15
 6  1* 5 10* 1  2*-1  1+63O 6 16O 1 -1O61 10* 6 10*-1  1+-1O61 10* 7  6*-1 BGL16
 1+-1O59  2* 8  1*-1  1+60O 8 -1O58  1*11  1*-1  1+58O11 -1O56  2* 7  1* 5 BGL17
 1*-1  1+57O 7  1O 5 -1O55  2* 8  1* 5  1*-1  1+56O 8  1O 5 -1O54  2* 8  1*BGL18
 7  1*-1  1+55O 8  1O 7 -1O53  2* 9  1* 4  1* 2  1*-1  1+54O 9  1O 4  1O 2 BGL19
-1O53  1* 9  1* 5  1* 3  1*-1  1+53O 9  1O 5  1O 3 -1O52  1*10  1* 5  1* 3 BGL20
 1*-1  1+52O10  1O 5  1O 3 -1O52  1*10  1* 5  1* 3  1*-1  1+52O10  1O 5  1OBGL21
 3 -1O52  1*10  1* 4  1* 1  2* 2  1*-1  1+52O10  1O 4  1O 1  2O 2 -1O51  1*BGL22
10  1* 5  2* 2  1* 1  1*-1  1+51O10  1O 5  2O 2  1O 1 -1O51  1*10  1* 5  1*BGL23
 3  1* 2  1*-1  1+51O10  1O 5  1O 3  1O 2 -1O51  1*10  1* 7  3* 2  1*-1  1+BGL24
51O10  1O 7  3O 2 -1O51  1*10  1* 9  1* 3  1*-1  1+51O10  1O 9  1O 3 -1O51 BGL25
 1*10  1* 6  1* 1  1* 4  1*-1  1+51O10  1O 6  1O 1  1O 4 -1O52  1*10  1* 5 BGL26
 2* 5  1*-1  1+52O10  1O 5  2O 5 -1O52  1*11  5* 7  1* 3  2*-1  1+52O11  5OBGL27
 7 -1O53  1*21  1* 3  1* 2  1*-1  1+53O21  5O 2 -1O54  2*18  5* 3  1*-1  1+BGL28
55O18  5O 3 -1O56  1*25  1*-1  1+56O25 -1O47  6* 4  2*22  1*-1  1+58O22 -1OBGL29
46  1* 6  3* 2  1* 3  9* 9  1*-1  1+46O 6  6O 3  9O 9 -1O46  1* 2  1* 6  1*BGL30
 1  1* 3  1* 6  1* 9  1*-1  1+46O 2  1O 6  3O 3  8O 9 -1O47  2* 2  1* 5  1*BGL31
 4  1* 5  1* 5  1* 3  1*-1  1+48O 2  1O 5  1O 4  7O 5  1O 3 -1O48  3*11  2*BGL32
 4  1* 2  1* 2  1* 1  2*-1  1+50O11  7O 2  1O 2  1O 1 -1O50  2*12  1* 3  1*BGL33
 2  1* 2  1*-1  1+51O12  5O 2  1O 2 -1O52  3*10  1* 2  1* 2  3*-1  1+54O10 BGL34
 4O 2 -1O55  4* 6  1* 3  2*-1  1+58O 6 -1O59  6*-1  1+-1O             1 -1OBGL35
50 32--1  1+-1O33 63--1  1+-1O42 67--1  1+-1O59 44--1  1+-1O 1 -1O         BGL36
-2                                                                         *EOP*
 11-1                                                                      LNS00
58  7*-1 53  4* 8  3*-1 51  2*16  1*-1 50  2* 7  1*10  1* 9  1*-1 49  1*21 LNS 1
 2* 3  1* 1  1* 2  1*-1 49  1* 7  1*15  1* 1  2* 5  1*-1 48  1*10  2*13  1*LNS 2
 7  1*-1 49  1*23  1* 8  1*-1 48  2* 4  1* 5  3* 4  1* 4  1* 9  1*-1 47  1*LNS 3
 1  1* 3  1* 2  20 1  1* 4  20 2  1* 2  1*10  1*-1 47  2* 4  1* 5  1* 8  1*LNS 4
 1  1*11  1*-1 47  1* 6  1* 5  2* 5  1* 2  1* 5  2* 4  1*-1 46  1*22  1* 4 LNS 5
 3* 1  1* 3  1*-1 46  1* 9  3* 2  2* 6  1* 2  3* 1  1* 1  1* 3  1*-1 46  1*LNS 6
 8  2* 1  3* 2  1* 4  1* 2  2* 2  1* 2  1* 2  1*-1 47  1* 6  2* 1  2* 1  1*LNS 7
 2  1* 4  1* 2  1* 2  1* 3  1* 2  1*-1 50  1* 3  3* 3  1* 6  1* 3  1* 3  1*LNS 8
 1  1* 2  1*-1 49  6* 5  1* 6  1* 2  1* 3  1* 2  1* 1  1*-1 48  1*11  8* 1 LNS 9
 1* 5  1* 1  1* 1  1*-1 47  1*11  1* 6X 3* 7  2* 1  1*-1 46  2*11  1* 6X 1*LNS10
 1  1* 8  2*-1 45  1* 20 1* 9  1* 70 1* 1  1* 8  1*-1 45  1* 30 1* 7  1* 80LNS11
 1* 1  1* 8  1*-1 45  1* 30 1X 7* 8X 1* 2  1* 6  1* 10-1 45  1* 4015X 1* 1 LNS12
 1* 1  2* 2  2* 10-1 46  2*170 1* 1  1* 3  1* 30 1*-1 48  1*160 1* 1  1* 3 LNS13
 1* 30 1*-1 48  1*160 1* 1  1* 4  1* 10 1*-1 48  1*16X 1* 1  1* 4  1* 1X 1*LNS14
-1 48  1*15X 1* 2  1* 4  1* 1X 1*-1 47  1*150 1* 2  1* 4  1* 10 1*-1 46  1*LNS15
170 1* 2  1* 4  1* 10 1* 6  2*-1 45  1*18X 1* 2  1* 4  1* 1X 1* 4  1* 3  1*LNS16
-1 45  1*18X 1* 2  1* 4  1* 2X 1* 2  1* 4  1*-1 45  1*18# 1* 2  1* 4  1* 2#LNS17
 1* 1  1* 4  1*-1 45  1*19# 1* 1  1* 4  1* 1# 1* 1  1* 5  1*-1 45  1*19# 1*LNS18
 2  1* 3  1* 1# 2* 2  1* 3  1*-1 45 21* 3  1* 3  2* 2  2* 3  1* 3  5*-1 52 LNS19
 1* 7  1* 1  1* 3  1* 2  1* 6  2* 3  1* 1  3* 5  1*-1 52  1* 7  1* 1  1* 3 LNS20
 1* 3  1* 4  1* 1  1* 3  2* 7  1* 3  3*-1 52  9* 1  6* 3  1* 2  1* 2  1*11 LNS21
 5* 2  5*-1 52  1* 7  1* 1  1* 5  1* 2  1* 2  1* 2  1*23  1*-1 45 25* 2  2*LNS22
 2  1*24  1*-1 43  2*11  2*12  1* 2  1* 7  3*14  3*-1 41  2*11  2*15 10* 2 LNS23
15*-1 40 34*-1 -1 -1 -1 -1 -1 50  1S 1E 1C 1U 1R 1I 1T 1Y 1  1I 1S 1  1A 1 LNS24
 1W 1A 1R 1M 1  1B 1L 1A 1N 1K 1E 1T-1                                     LNS25
-2                                                                         *EOP*
"""
#create input for our fortran program
if (len(sys.argv) > 4):
    m1=int(sys.argv[1])
    y1=int(sys.argv[2])
    m2=int(sys.argv[3])
    y2=int(sys.argv[4])
else:
    import time
    m1=1
    m2=1
    y1=int(time.localtime()[0])
    y2=y1+1
m1=("%2.2d" % m1)
m2=("%2.2d" % m2)
y1=("%4.4d" % y1)
y2=("%4.4d" % y2)
two=two.replace("m1",m1)
two=two.replace("m2",m2)
two=two.replace("yr01",y1)
two=two.replace("yr02",y2)
fort2=open("fort.2","w")
fort2.write(two)
fort2.close()
os.system("./snoopy")


fname="fort.3"
input=open(fname,"r")
outfile=fname+".out"
output=open(outfile,"w")
lines=input.readlines()
ic=0
for line in lines:
	lines[ic]=line.strip("\n")
	ic=ic+1

#        Space           Normal behaviour    printing/CR/LF
#          0             Double spacing      LF/printing/CR/LF
#          +             Overwrite mode      CR/printing/CR/LF
#          1             Next page           m*LF/CR/LF/n*LF/printing/CR/LF
lf=chr(10)
ff=chr(12)
cr=chr(13)
for line in lines:
	if(len(line) > 0):
		rtn=lf
		if line[0]=="+":
			rtn=cr
		if line[0]=="1":
			rtn=ff
		output.write(rtn)
		output.write(line[1:])
command_org="enscript -B -f Courier7 -r -e fort.3.out -o cal.ps"
command=command_org.split()
#print(command)
import subprocess
# HACK for some reason sometimes enscript skips the last
# page the first time you run it so we run it twice. 
for i in [0,1] :
    #x=subprocess.run(["enscript","-B",  "-f", "Courier7" ,"-r", "-e", "fort.3.out", "-o" ,"cal.ps"],capture_output=True,encoding='utf-8')  
    x=subprocess.run(command,capture_output=True,encoding='utf-8')  
    #print(x.args)
    #print(x.returncode)
    output=x.stderr.split("\n")
output=x.stderr.split("\n")
for o in output:
    if (len(o) > 0):
        print(o)
print("**********")
print("If the output reports that few or no pages")
print("were produced try running this command:")
print(command_org)

