#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <mpi.h>
#ifdef __APPLE__
#import "fmemopen.h"
#endif

FILE *fptr;
  char *buffer;
  size_t buf_size;

int mypal;
/* 
Purpose:
   Create a grayscale or color indexed tif file.
   without using any library.  Useful for cases
   where libtiff is not available. 

Author:
    Timothy H. Kaiser, Ph.D.
    May 2016
*/

/*
Based in part on:
	 Paul Bourke
	 http://paulbourke.net/dataformats/tiff/
*/

/*
Color maps from...
http://matplotlib.org/examples/color/colormaps_reference.html
import matplotlib.pyplot as plt
cmap=plt.get_cmap('Spectral')
cmap=plt.get_cmap('rainbow')
for k in [0,1,2] :
	for i in range(0,256):
		x=i/255.0
		rgba = cmap(x)
		c=int(65535.0*rgba[k])
		print c
	print
*/
/***** Start of tif routines *****/
int spectral1[]={
40606,41160,41714,42268,42823,43377,43931,44486,45040,45594,46149,46703,47257,
47812,48366,48920,49475,50029,50583,51137,51692,52246,52800,53355,53909,54463,
54897,55209,55522,55834,56146,56459,56771,57084,57396,57709,58021,58333,58646,
58958,59271,59583,59896,60208,60520,60833,61145,61458,61770,62083,62395,62708,
62798,62889,62980,63070,63161,63252,63342,63433,63524,63615,63705,63796,63887,
63977,64068,64159,64250,64340,64431,64522,64612,64703,64794,64884,64975,65026,
65036,65046,65056,65066,65076,65086,65096,65106,65116,65126,65136,65146,65157,
65167,65177,65187,65197,65207,65217,65227,65237,65247,65257,65267,65278,65288,
65298,65308,65318,65328,65338,65348,65358,65368,65378,65388,65398,65409,65419,
65429,65439,65449,65459,65469,65479,65489,65499,65509,65519,65529,65409,65157,
64905,64653,64401,64149,63897,63645,63393,63141,62889,62637,62385,62133,61881,
61629,61377,61125,60873,60621,60369,60117,59865,59613,59361,59110,58515,57920,
57326,56731,56136,55542,54947,54352,53758,53163,52569,51974,51379,50785,50190,
49595,49001,48406,47812,47217,46622,46028,45433,44838,44244,43599,42903,42208,
41513,40817,40122,39426,38731,38036,37340,36645,35949,35254,34558,33863,33168,
32472,31777,31081,30386,29691,28995,28300,27604,26909,26214,25689,25165,24641,
24117,23593,23069,22545,22021,21497,20973,20449,19925,19400,18876,18352,17828,
17304,16780,16256,15732,15208,14684,14160,13636,13112,13071,13515,13958,14402,
14845,15288,15732,16175,16619,17062,17506,17949,18393,18836,19280,19723,20166,
20610,21053,21497,21940,22384,22827,23271,23714,24158
};
int spectral2[]={
257  , 871  , 1486 , 2101 , 2716 , 3330 , 3945 , 4560 , 5175 , 5790 , 6404 ,
7019 , 7634 , 8249 , 8863 , 9478 , 10093, 10708, 11323, 11937, 12552, 13167,
13782, 14397, 15011, 15626, 16170, 16644, 17118, 17591, 18065, 18539, 19012,
19486, 19960, 20434, 20907, 21381, 21855, 22328, 22802, 23276, 23749, 24223,
24697, 25170, 25644, 26118, 26591, 27065, 27539, 28013, 28668, 29323, 29978,
30633, 31288, 31943, 32598, 33253, 33908, 34563, 35219, 35874, 36529, 37184,
37839, 38494, 39149, 39804, 40459, 41114, 41770, 42425, 43080, 43735, 44390,
44969, 45473, 45977, 46481, 46985, 47489, 47993, 48497, 49001, 49505, 50009,
50513, 51017, 51520, 52024, 52528, 53032, 53536, 54040, 54544, 55048, 55552,
56056, 56560, 57064, 57568, 57880, 58192, 58505, 58817, 59130, 59442, 59755,
60067, 60379, 60692, 61004, 61317, 61629, 61942, 62254, 62566, 62879, 63191,
63504, 63816, 64129, 64441, 64753, 65066, 65378, 65484, 65383, 65283, 65182,
65081, 64980, 64879, 64779, 64678, 64577, 64476, 64375, 64275, 64174, 64073,
63972, 63872, 63771, 63670, 63569, 63468, 63368, 63267, 63166, 63065, 62965,
62723, 62481, 62239, 61997, 61755, 61513, 61271, 61029, 60788, 60546, 60304,
60062, 59820, 59578, 59336, 59094, 58853, 58611, 58369, 58127, 57885, 57643,
57401, 57159, 56917, 56660, 56388, 56116, 55844, 55572, 55300, 55028, 54756,
54484, 54211, 53939, 53667, 53395, 53123, 52851, 52579, 52307, 52034, 51762,
51490, 51218, 50946, 50674, 50402, 50130, 49858, 49273, 48688, 48104, 47519,
46935, 46350, 45766, 45181, 44597, 44012, 43427, 42843, 42258, 41674, 41089,
40505, 39920, 39336, 38751, 38167, 37582, 36997, 36413, 35828, 35244, 34664,
34090, 33515, 32941, 32366, 31792, 31217, 30643, 30069, 29494, 28920, 28345,
27771, 27196, 26622, 26047, 25473, 24898, 24324, 23749, 23175, 22600, 22026,
21451, 20877, 20303
};
int spectral3[]={
16962, 17093, 17224, 17355, 17486, 17617, 17748, 17879, 18010, 18141, 18272,
18403, 18534, 18665, 18796, 18927, 19058, 19189, 19320, 19451, 19582, 19713,
19844, 19975, 20106, 20237, 20242, 20121, 20000, 19879, 19758, 19637, 19516,
19395, 19275, 19154, 19033, 18912, 18791, 18670, 18549, 18428, 18307, 18186,
18065, 17944, 17823, 17702, 17581, 17460, 17339, 17219, 17521, 17823, 18126,
18428, 18730, 19033, 19335, 19637, 19940, 20242, 20544, 20847, 21149, 21451,
21754, 22056, 22359, 22661, 22963, 23266, 23568, 23870, 24173, 24475, 24777,
25140, 25563, 25987, 26410, 26833, 27257, 27680, 28103, 28527, 28950, 29373,
29796, 30220, 30643, 31066, 31490, 31913, 32336, 32759, 33183, 33606, 34029,
34453, 34876, 35299, 35723, 36247, 36771, 37295, 37819, 38343, 38867, 39391,
39915, 40439, 40963, 41487, 42011, 42536, 43060, 43584, 44108, 44632, 45156,
45680, 46204, 46728, 47252, 47776, 48300, 48824, 48890, 48497, 48104, 47711,
47318, 46925, 46532, 46139, 45746, 45352, 44959, 44566, 44173, 43780, 43387,
42994, 42601, 42208, 41815, 41422, 41029, 40636, 40243, 39850, 39457, 39064,
39184, 39305, 39426, 39547, 39668, 39789, 39910, 40031, 40152, 40273, 40394,
40515, 40636, 40757, 40878, 40999, 41120, 41240, 41361, 41482, 41603, 41724,
41845, 41966, 42087, 42153, 42163, 42173, 42183, 42193, 42203, 42213, 42223,
42233, 42243, 42253, 42263, 42273, 42284, 42294, 42304, 42314, 42324, 42334,
42344, 42354, 42364, 42374, 42384, 42394, 42405, 42646, 42888, 43130, 43372,
43614, 43856, 44098, 44340, 44581, 44823, 45065, 45307, 45549, 45791, 46033,
46275, 46517, 46758, 47000, 47242, 47484, 47726, 47968, 48210, 48452, 48436,
48164, 47892, 47620, 47348, 47076, 46804, 46532, 46260, 45987, 45715, 45443,
45171, 44899, 44627, 44355, 44083, 43810, 43538, 43266, 42994, 42722, 42450,
42178, 41906, 41634
};

int rainbow1[]={
32767,32253,31739,31225,30711,30197,29683,29169,28655,28141,27627,27113,26599,
26085,25571,25057,24543,24029,23515,23001,22487,21973,21459,20945,20431,19917,
19403,18889,18375,17861,17347,16833,16319,15805,15291,14777,14263,13749,13235,
12721,12207,11693,11179,10665,10151,9637,9123,8609,8095,7581,7067,6553,6039,5525,
5011,4497,3983,3469,2955,2441,1927,1413,899,385,128,642,1156,1670,2184,2698,
3212,3726,4240,4754,5268,5782,6296,6810,7324,7838,8352,8866,9380,9894,10408,
10922,11436,11950,12464,12978,13492,14006,14520,15034,15548,16062,16576,17090,
17604,18118,18632,19146,19660,20174,20688,21202,21716,22230,22744,23258,23772,
24286,24800,25314,25828,26342,26856,27370,27884,28398,28912,29426,29940,30454,
30968,31482,31996,32510,33024,33538,34052,34566,35080,35594,36108,36622,37136,
37650,38164,38678,39192,39706,40220,40734,41248,41762,42276,42790,43304,43818,
44332,44846,45360,45874,46388,46902,47416,47930,48444,48958,49472,49986,50500,
51014,51528,52042,52556,53070,53584,54098,54612,55126,55640,56154,56668,57182,
57696,58210,58724,59238,59752,60266,60780,61294,61808,62322,62836,63350,63864,
64378,64892,65406,65535,65535,65535,65535,65535,65535,65535,65535,65535,65535,
65535,65535,65535,65535,65535,65535,65535,65535,65535,65535,65535,65535,65535,
65535,65535,65535,65535,65535,65535,65535,65535,65535,65535,65535,65535,65535,
65535,65535,65535,65535,65535,65535,65535,65535,65535,65535,65535,65535,65535,
65535,65535,65535,65535,65535,65535,65535,65535,65535,65535,65535,65535,65535,
65535,65535
};
int rainbow2[]={
0,807,1614,2421,3228,4034,4839,5644,6448,7251,8053,8854,9653,10451,11247,12042,
12834,13625,14414,15200,15984,16766,17545,18322,19096,19867,20634,21399,22161,
22919,23673,24425,25172,25915,26655,27391,28122,28849,29572,30290,31004,31713,
32417,33116,33810,34499,35183,35862,36535,37202,37864,38520,39170,39815,40453,
41085,41711,42330,42944,43550,44150,44743,45330,45910,46482,47048,47606,48158,
48701,49238,49767,50289,50802,51309,51807,52298,52780,53255,53721,54180,54630,
55071,55505,55930,56346,56754,57154,57545,57927,58300,58664,59019,59366,59703,
60032,60351,60661,60962,61254,61536,61809,62073,62327,62572,62807,63033,63249,
63455,63652,63840,64017,64185,64343,64492,64630,64759,64878,64987,65086,65175,
65255,65324,65384,65434,65474,65503,65523,65533,65533,65523,65503,65474,65434,
65384,65324,65255,65175,65086,64987,64878,64759,64630,64492,64343,64185,64017,
63840,63652,63455,63249,63033,62807,62572,62327,62073,61809,61536,61254,60962,
60661,60351,60032,59703,59366,59019,58664,58300,57927,57545,57154,56754,56346,
55930,55505,55071,54630,54180,53721,53255,52780,52298,51807,51309,50802,50289,
49767,49238,48701,48158,47606,47048,46482,45910,45330,44743,44150,43550,42944,
42330,41711,41085,40453,39815,39170,38520,37864,37202,36535,35862,35183,34499,
33810,33116,32417,31713,31004,30290,29572,28849,28122,27391,26655,25915,25172,
24425,23673,22919,22161,21399,20634,19867,19096,18322,17545,16766,15984,15200,
14414,13625,12834,12042,11247,10451,9653,8854,8053,7251,6448,5644,4839,4034,3228,
2421,1614,807,0
};

int rainbow3[]={
65535,65533,65530,65523,65515,65503,65490,65474,65455,65434,65410,65384,65356,
65324,65291,65255,65216,65175,65132,65086,65038,64987,64934,64878,64820,64759,
64696,64630,64562,64492,64419,64343,64265,64185,64102,64017,63930,63840,63747,
63652,63555,63455,63353,63249,63142,63033,62921,62807,62691,62572,62451,62327,
62201,62073,61942,61809,61674,61536,61396,61254,61109,60962,60813,60661,60507,
60351,60193,60032,59869,59703,59536,59366,59194,59019,58843,58664,58483,58300,
58114,57927,57737,57545,57350,57154,56955,56754,56552,56346,56139,55930,55718,
55505,55289,55071,54852,54630,54406,54180,53951,53721,53489,53255,53018,52780,
52540,52298,52053,51807,51559,51309,51057,50802,50547,50289,50029,49767,49504,
49238,48971,48701,48430,48158,47883,47606,47328,47048,46766,46482,46197,45910,
45621,45330,45038,44743,44448,44150,43851,43550,43248,42944,42638,42330,42021,
41711,41399,41085,40770,40453,40134,39815,39493,39170,38846,38520,38193,37864,
37534,37202,36869,36535,36199,35862,35523,35183,34842,34499,34155,33810,33464,
33116,32767,32417,32065,31713,31359,31004,30647,30290,29931,29572,29211,28849,
28486,28122,27757,27391,27023,26655,26286,25915,25544,25172,24799,24425,24049,
23673,23297,22919,22540,22161,21780,21399,21017,20634,20251,19867,19482,19096,
18709,18322,17934,17545,17156,16766,16376,15984,15593,15200,14807,14414,14020,
13625,13230,12834,12438,12042,11644,11247,10849,10451,10052,9653,9253,8854,8453,
8053,7652,7251,6850,6448,6046,5644,5242,4839,4437,4034,3631,3228,2824,2421,2018,
1614,1211,807,403,0
};

// Utility routine to write an integer as two bytes
void write2(int n) {
   putc((n & 0xff00) / 256,fptr);    
   putc((n & 0x00ff),fptr);
}

// Utility routine to write an integer as four bytes
void write4(int n) {
	putc((n & 0xff000000) / 16777216,fptr);
	putc((n & 0x00ff0000) / 65536,fptr);
	putc((n & 0x0000ff00) / 256,fptr);
	putc((n & 0x000000ff),fptr);
}

// Utility routine to write string of hex as hex
void WriteHexString(FILE *fptr,char *s)
{
   unsigned int i,c;
   char hex[3];

   for (i=0;i<strlen(s);i+=2) {
      hex[0] = s[i];
      hex[1] = s[i+1];
      hex[2] = '\0';
      sscanf(hex,"%X",&c);
      putc(c,fptr);
   }
}

// Write image width tag (pixels)
void ImageWidth(int n) {
   /* Width tag, short int */
   WriteHexString(fptr,"0100000300000001");
   write2(n);
   WriteHexString(fptr,"0000");
}

// Write image length tag (pixels)
void ImageLength(int n) {
   /* Height tag, short int */
   WriteHexString(fptr,"0101000300000001");
   write2(n);
   WriteHexString(fptr,"0000");
}

// Write BitsPerSample tag - should be 8
void BitsPerSample(int n) {
	if (n == 4) {
		WriteHexString(fptr,"010200030000000100040000");
		return ;
	}
	if (n == 8) {
		WriteHexString(fptr,"010200030000000100080000");
		return ;
	}
}

//Compression flag - none
void Compression( ) {
   WriteHexString(fptr,"010300030000000100010000"); /* none */
}

/* Photometric interpolation tag, short int */
/* 0 or 1 -> gray  */
/* 3      -> color */
void PhotometricInterpretation(int n) {
	WriteHexString(fptr,"0106000300000001");
	write2(n);
	WriteHexString(fptr,"0000");
}

//Writes the tag that says were are real data starts
void StripOffsets(int n) {
   /* Strip offset tag, long int */
	WriteHexString(fptr,"0111000400000001");
	write4(n);

}

// Writes the actual resolution for x and y
// Pointed to by YResolution, YResolution tags
int dores() {
	WriteHexString(fptr,"0000006400000001"); // 064 = 100 dpi
	WriteHexString(fptr,"0000006400000001");
	return 16;
}

/* Write RowsPerStrip tag ny in our case */
void RowsPerStrip(int n){
	WriteHexString(fptr,"0116000300000001");
	write2(n); /* Image height */
	WriteHexString(fptr,"0000");
}

// StripByteCounts tag.
// We have a single strip of data so this is set to nx*ny
void StripByteCounts(int n){
   /* StripByteCounts tag, short int */
	WriteHexString(fptr,"0117000400000001");
	write4(n); 
}

// Writes tag that sets our units for resolution (inch)
void ResolutionUnit(int n){
   /* 2 -> pixels/inch */
	WriteHexString(fptr,"0128000300000001");
	write2(n); /* Image height */
	WriteHexString(fptr,"0000");
}

/* This tag is a pointer to where the Y resolution is held,  byte 8*/
void YResolution() {
	WriteHexString(fptr,"011b00050000000100000008");
}

/* This tag is a pointer to where the X resolution is held, byte 16 */
void XResolution() {
	WriteHexString(fptr,"011a00050000000100000010");
}

/* This tag is a pointer to the beginning of the colormap, byte 24 */
void ColorMap(int ic) {
   int i,j,tl;
   		WriteHexString(fptr,  "014000030000030000000018");    // 8
}

// write the color look up table red, green, blue defined above
int scale() {
	int i,j;
	int *rp,*gp,*bp;
	rp=spectral1; gp=spectral2; bp=spectral3;
	if (mypal == 2) {
		rp=rainbow1;      gp=rainbow2;      bp=rainbow3;
	}
	for (i=0;i<=255;i++) {
		j=rp[i];
   		putc((j & 0xff00) / 256,fptr);    
   		putc((j & 0x00ff),fptr);
		}
		
	for (i=0;i<=255;i++) {
 		j=gp[i];
  		putc((j & 0xff00) / 256,fptr);    
   		putc((j & 0x00ff),fptr);
		}
		
	for (i=0;i<=255;i++) {
		j=bp[i];
   		putc((j & 0xff00) / 256,fptr);    
   		putc((j & 0x00ff),fptr);
		}
	return 3*2*768;
}
 
/***** end of tif routines *****/

#define ssize 10.0

float sink(int i, int j,int imax,int jmax){
	float xscale,yscale;
	float x,y,r,dx,dy,bx,by;
	xscale=ssize;
	yscale=ssize;
	dx=(2.0*xscale)/((float)imax);
	bx=xscale-dx*((float)imax);
	x=((float)i)*dx+bx;
	dy=(2.0*yscale)/((float)jmax);
	by=yscale-dy*((float)jmax);
	y=((float)j)*dy+by;
	r=sqrt(x*x+y*y);
	if (r == 0.0)return 1.0;
	return (sin(r)/r);
}


int main(int argc, char **argv) {
	int nx,ny,i,j,offset,b;
	int cm,tags;
	char gray;
	int pi,dopal;
	int cg;
	int cells,k,dcells;
	int *todo1,*todo2;
	int scell,ecell,ib;
	int writesize;
	MPI_Status status;
	int numnodes,myid;
	int ierr;
	MPI_File fh;
	int where;
	double t1,t2,t3,t4,tsum,tsum_b;

	writesize=50000;
#ifdef __APPLE__
	nx=1600;
	ny=2500;
#else
	nx=16000;
	ny=25000;
#endif
   	pi=0;     // PhotometricInterpretation 0,1 or 3
   	dopal=0;  // create the Color_Map
   	cg=2;
   	MPI_Init(&argc,&argv);
    MPI_Comm_size(MPI_COMM_WORLD,&numnodes);
    MPI_Comm_rank(MPI_COMM_WORLD,&myid);

   if (myid == 0 ) {
		if (argc > 1) {
			sscanf(argv[1],"%d",&cg);
		}
		if (cg < 0 || cg > 2 ) {
			printf(" valid input options are:\n");	
			printf(" 0 - gray     -> gray.tif \n");	
			printf(" 1 - inverted -> invert.tif\n");	
			printf(" 2 - color    -> color.tif\n");	
			printf(" Assuming color\n");
			cg=2;
		}
		mypal=1;
		if (argc > 2) {
			// if mypal == 2 we use the rainbow pallet
			sscanf(argv[2],"%d",&mypal);
		}
   	}

// process 0 generates the header
// the only thing the others need to know is the length
   if (myid == 0 ) {
#ifdef __APPLE__
	buffer=(char*)malloc(4096);
	fptr=fmemopen((void *)buffer, sizeof(char) * 4096, "w");
#else
	fptr=open_memstream (&buffer, &buf_size);
#endif
   	if (cg == 2) {
   		pi=3;
   		dopal=1;
   		// fptr=fopen("color.tif","w");
   	}
   	if (cg == 0) {
   		pi=0;
   		dopal=0;
   		// fptr=fopen("gray.tif","w");
   	}
   	if (cg == 1) {
   		pi=1;
   		dopal=0;
   		// fptr=fopen("invert.tif","w");
   	}
   	
	/* Write the header */
	WriteHexString(fptr,"4d4d002a");    /* Big endian & TIFF identifier */
	/* 
	Next we have a pointer to where our tags start.
	The string above gives us 4 bytes.  The next entry,
	this pointer takes up 4 bytes. The we will store the
	image resolution which take 16 bytes, 8 for X and Y. 
	If we have a color map this is next and it takes 
	3*2*256 bytes.	
	*/
	
	offset=4+4+16;
	if (dopal > 0) 
		offset = offset+3*2*256;
	write4(offset); 
	
	/* Write the X and Y resolution */
	dores();
	
	/* Write the color map if we want it */
	if (dopal > 0) 
		scale();

/* the start of our tags.  We need to say how many there are, 11 or 12. */
   	tags=11;
   	if (dopal > 0)
   		tags++;  
   	if (tags == 11 )
		WriteHexString(fptr,"000b");  /* The number of directory entries (10) */
   	if (tags == 12 )
		WriteHexString(fptr,"000c");  /* The number of directory entries (11) */

/*  These are the tags we will use
ImageWidth           0100
ImageLength          0101
BitsPerSample        0102
Compression          0103
Photometric          0106
StripOffsets         0111
RowsPerStrip         0116
StripByteCounts      0117
XResolution          011a
YResolution          011b
ResolutionUnit       0128
ColorMap             0140
*/

	ImageWidth(nx);
	ImageLength(ny);
	BitsPerSample(8);
	Compression();
	PhotometricInterpretation(pi); // pi=0,1 or 3: gray or color
	/* 
	Next we set the pointer to the beginning of our data.
	It is offset:
	8 byte header
	16 bytes for X,Y resolution
	3*256*2 for color map, if used
	2 byte number of tags
	12 * number tags 
	4 bytes of "00000000"
	*/
	cm=0; 
	if (dopal > 0) 
		cm=3*256*2;
	StripOffsets(8+16+cm+2+12*tags+4);
	
	/* set our sizes */
	RowsPerStrip(ny);
	StripByteCounts(nx*ny);
	XResolution();
	YResolution();
	ResolutionUnit(2);
	
	/* this just sets the point to the color map if needed */
	if (dopal  > 0)
		ColorMap(cm);
	WriteHexString(fptr,"00000000");
#ifdef __APPLE__
   buf_size=ftell(fptr);
#endif
	fclose (fptr);
	}  // end of proc 0 creating the header
	   // which is held in buffer
	   // its size is buf_size

   /* manager tells workers which cells to write */
   cells=nx*ny;
   if (myid == 0) {
		todo1=(int*)malloc((size_t)numnodes*sizeof(int));
		todo2=(int*)malloc((size_t)numnodes*sizeof(int));
		dcells=cells/numnodes;
		for (k=0;k<numnodes;k++) {
			todo1[k]=k*dcells;
			todo2[k]=(k+1)*dcells;
		}
		todo2[numnodes-1]=cells;
   	}
   else {
   	todo1=(int*)malloc(sizeof(int));
   	todo2=(int*)malloc(sizeof(int));
   }
   MPI_Scatter(todo1, 1, MPI_INT, &scell,1, MPI_INT,0,MPI_COMM_WORLD);
   MPI_Scatter(todo2, 1, MPI_INT, &ecell,1, MPI_INT,0,MPI_COMM_WORLD);
   MPI_Bcast(&buf_size, 1, MPI_LONG, 0,MPI_COMM_WORLD);
   printf("%d got %d %d %d\n",myid,(int)buf_size,scell,ecell);
   free(todo1);
   free(todo2);
  // printf(" ***** Ready to start writing \n");
  // printf(" We open the file \n");
   ierr=MPI_File_open(MPI_COMM_WORLD, "mpi.tif",(MPI_MODE_RDWR | MPI_MODE_CREATE), MPI_INFO_NULL, &fh);
   ierr=MPI_File_set_view(fh, 0, MPI_CHAR, MPI_CHAR, "native",MPI_INFO_NULL);
   
   if (myid == 0 ) {
		printf(" Proc 0 writes the header %d\n",(int)buf_size);
		ierr=MPI_File_write_at(fh, 0, buffer, buf_size, MPI_CHAR,&status);
		// and frees the pointer to buffer
		free(buffer);
   }
   // (Re)allocate the buffer
   buffer=(char*)malloc((size_t)writesize*sizeof(char));
   
   // Loop 
   //  Fill the buffer
   //  write at buf_size+ where we are
   ib=0;
   where=buf_size+scell;
   tsum=0.0;
   t1=MPI_Wtime();
   for (k=scell;k<ecell;k++) {
   		// printf("%d %d\n",myid,k);
		i= k % nx;
		j=(k-i)/nx;
//		b=(int)((127.99999)*(1.0+sink(i,j,nx,ny)));
		b=(int)((127.99999)*(1.0+sin((ssize*((float)i-(0.5*nx)))/((float)nx))
		                        *cos((ssize*((float)j-(0.5*ny)))/((float)ny))));
		buffer[ib]=(char)b;
		ib++;
		if( ib == writesize || k == (ecell-1)) {
			// write at buf_size + k;			
			// write ib bytes
			// printf("%d writes %d %d\n",myid,where,ib);
			t4=MPI_Wtime();
			ierr=MPI_File_write_at(fh, where, buffer, ib, MPI_CHAR,&status);
			tsum=tsum+(MPI_Wtime()-t4);

			where=where+ib;
			ib=0;
		}
   	}
   	// close the file
    t2=MPI_Wtime();
    ierr=MPI_File_close(&fh);
    t3=MPI_Wtime();
    if(myid == 0) {
    	printf(" grid size: %d %d\n",nx,ny);
    	if (dopal > 0)
    		printf(" color image\n");
    	else
    		printf(" gray image\n");
	}
    	
    MPI_Reduce(&tsum, &tsum_b, 1, MPI_DOUBLE, MPI_MAX, 0,  MPI_COMM_WORLD);
    if(myid == 0)printf("Max time in print: %g\n",tsum_b);
    MPI_Reduce(&tsum, &tsum_b, 1, MPI_DOUBLE, MPI_MIN, 0,  MPI_COMM_WORLD);
    if(myid == 0)printf("Min time in print: %g\n",tsum_b);
    tsum=t2-t1-tsum;
    MPI_Reduce(&tsum, &tsum_b, 1, MPI_DOUBLE, MPI_MAX, 0,  MPI_COMM_WORLD);
    if(myid == 0)printf("Max time in compute: %g\n",tsum_b);
    MPI_Reduce(&tsum, &tsum_b, 1, MPI_DOUBLE, MPI_MIN, 0,  MPI_COMM_WORLD);
    if(myid == 0)printf("Min time in compute: %g\n",tsum_b);
    tsum=t3-t2;
    MPI_Reduce(&tsum, &tsum_b, 1, MPI_DOUBLE, MPI_MAX, 0,  MPI_COMM_WORLD);
    if(myid == 0)printf("Max time in close: %g\n",tsum_b);
    MPI_Reduce(&tsum, &tsum_b, 1, MPI_DOUBLE, MPI_MIN, 0,  MPI_COMM_WORLD);
    if(myid == 0)printf("Min time in close: %g\n",tsum_b);
    MPI_Finalize();

return 0;
}