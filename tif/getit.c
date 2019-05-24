#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#ifdef __APPLE__
#import "fmemopen.h"
#endif
FILE *fptr;
char*buffer;
size_t buf_size;
FILE *dptr;
char *dbuffer;
size_t dbuf_size;
FILE *optr;
int offset;
int header;
int debug;
double flip_d(unsigned char *bytes) {
	char eight[8];
	double d,*dp;
	eight[7]=bytes[0];
	eight[6]=bytes[1];
	eight[5]=bytes[2];
	eight[4]=bytes[3];
	eight[3]=bytes[4];
	eight[2]=bytes[5];
	eight[1]=bytes[6];
	eight[0]=bytes[7];
#if MACHINE == mc2
	eight[0]=bytes[0];
	eight[1]=bytes[1];
	eight[2]=bytes[2];
	eight[3]=bytes[3];
	eight[4]=bytes[4];
	eight[5]=bytes[5];
	eight[6]=bytes[6];
	eight[7]=bytes[7];
	dp=(double*)eight;
#endif
	d=*dp;
	return d;
}

int flip4(unsigned char *bytes) {
	int i;
	i=0;
	i=16777216*((unsigned int)bytes[0])+65536*((unsigned int)bytes[1])+256*((unsigned int)bytes[2])+(unsigned int)bytes[3];
	return i;
}
int flip2(unsigned char *bytes) {
	int i;
	i=0;
	i=256*((unsigned int)bytes[0])+((unsigned int)bytes[1]);
	return i;
}

// Utility routine to write an integer as two bytes
void write2(FILE *fptr , int n) {
   putc((n & 0xff00) / 256,fptr);    
   putc((n & 0x00ff),fptr);
}

// Utility routine to write an integer as four bytes
void write4(FILE *fptr , int n) {
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


/*  These are the tags we will use
                                   ptr   mod
ImageWidth           0100    256   
ImageLength          0101    257
BitsPerSample        0102    258
Compression          0103    259
Photometric          0106    262
StripOffsets         0111    273    *    *
SamplesPerPixel      0115    277
RowsPerStrip         0116    278         *
StripByteCounts      0117    279         *
XResolution          011a    282    *    *  
YResolution          011b    283    *    *
PlanarConfiguration  011c    284
ResolutionUnit       0128    296
ColorMap             0140    320    *    *
SampleFormat         0153    339
ModelPixelScaleTag   830e    33550  *    *
ModelTiepointTag     8482    33922  *    *
GeoKeyDirectoryTag   87af    34735  *    *
GeoDoubleParamsTag   87b0    34736  *    *
GeoAsciiParamsTag    87b1    34737  *    *
*/

/* these do not change */
char BitsPerSample_bytes[12];
char Compression_bytes[12];
char Photometric_bytes[12];
char SamplesPerPixel_bytes[12];
char SampleFormat_bytes[12];
char PlanarConfiguration_bytes[12];
char ModelTiepointTag_bytes[12];
char GeoKeyDirectoryTag_bytes[12];
char GeoDoubleParamsTag_bytes[12];
char GeoAsciiParamsTag_bytes[12];
char ResolutionUnit_bytes[12];
char YResolution_bytes[12];
char XResolution_bytes[12];

/* these have a associated variable   */
int RowsPerStrip_val;
int StripByteCounts_val;
int BitsPerSample_val;
int ImageWidth_val;
int ImageLength_val;


/* these have a associated cnt   */
int ModelTiepointTag_cnt;
int GeoDoubleParamsTag_cnt;
int GeoKeyDirectoryTag_cnt;
int GeoAsciiParamsTag_cnt;
int ColorMap_cnt;
int XResolution_cnt;
int YResolution_cnt;

int StripOffsets_ptr;
int XResolution_ptr;
int YResolution_ptr;
int ColorMap_ptr;
int ModelPixelScaleTag_ptr;
int ModelTiepointTag_ptr;
int GeoKeyDirectoryTag_ptr;
int GeoDoubleParamsTag_ptr;
int GeoAsciiParamsTag_ptr;

char *StripOffsets_val;
char *XResolution_val;
char *YResolution_val;
char *ColorMap_val;
char *ModelPixelScaleTag_val;
char *ModelTiepointTag_val;
char *GeoKeyDirectoryTag_val;
char *GeoDoubleParamsTag_val;
char *GeoAsciiParamsTag_val;


int nx,ny,cells;

void doit(int thetag,unsigned char *thebytes);
void writeit(int thetag);

int main(int argc, char **argv) {
	long off1;
	int i1,i2,i3,dtag;
	unsigned char strin[256];
	int tags[25];
	int ntags;
	offset=0;
	nx=512;
	ny=512;
	debug=1;
	if (argc == 4) {
		nx=(int) strtol(argv[2], (char **)NULL, 10);
		ny=(int) strtol(argv[3], (char **)NULL, 10);
	}
	if (debug) printf("****** grid size %d x %d\n",nx,ny);

	fptr=fopen(argv[1],"r");

	off1=4;
	if (debug) printf("%ld %ld %ld %ld\n",sizeof(int),sizeof(long),sizeof(float),sizeof(double));
	fseek(fptr,off1,SEEK_SET);
	fread(&strin,sizeof(char),4,fptr);

	if (debug) {
		for (i1=0;i1<4;i1++) {
			printf("%d\n",(unsigned int)strin[i1]);
		}
	}
	i1=flip4(strin);
	if (debug) printf("offset to beginning of the tags %d\n",i1);
	off1=i1;
	fseek(fptr,off1,SEEK_SET);
	fread(&strin,sizeof(char),2,fptr);

	if (debug) {
		for (i1=0;i1<2;i1++) {
			printf("%d\n",(unsigned int)strin[i1]);
		}
	}
	ntags=flip2(strin);
	if (debug) printf("# tags %d\n",i1);
	offset=10;
	offset=offset+12*ntags;
	for (i2=0; i2<ntags;i2++) {
		fread(&strin,sizeof(char),12,fptr);
		dtag=flip2(strin);
		tags[i2]=dtag;
		if (debug) {
			printf("%5d %4.4x",dtag,dtag);
			for (i3=0;i3<12;i3++) {
				printf(" %2.2x",(unsigned int)strin[i3]);
			}
		}
		doit(dtag,strin);
		if (debug) printf("\n");
		}
	/* we have read the tags and their data */
		fclose(fptr);

	/*   now we collect the header information into a string
	FORMAT:
		4 bytes id
		4 byte pointer to the beginning of our tags
		# of tags 2 bytes
		our tags 12*(# of tags 2)
		so offset starts at 10+12*ntags  (see above)
		tag data
	*/
	/* we collect our tag data in its own buffer - dbuffer */
//#ifdef __APPLE__
	dbuffer=(char*)malloc(4096);
	buffer=(char*)malloc(8092);
	dptr=fmemopen((void *)dbuffer, sizeof(char) * 4096, "w");
	fptr=fmemopen((void *)buffer, sizeof(char) * 8092, "w");
/*
 * #else
	dptr=open_memstream (&dbuffer, &dbuf_size);
	fptr=open_memstream (&buffer, &buf_size);
#endif
*/
	/* 4 bytes id */
	// done above offset=offset+4; /* Big endian & TIFF identifier */
	WriteHexString(fptr,"4d4d002a");    

	/* pointer to the beginning of our tags */
	// done above offset=offset+4; 
	write4(fptr,8); 

	/* # of tags */
	// done above offset=offset+2; 
	write2(fptr,ntags);
	/* write the tags */
	// done above  offset=offset+12*ntags;
	for (i2=0; i2<ntags;i2++) {
		writeit(tags[i2]);
	}
	/* append the tag data */

	/*
	fpos_t dposition,fposition;
	fgetpos(fptr,&fposition);
	fgetpos(dptr,&dposition);
	*/
	long dposition,fposition;
	dposition=ftell(dptr);
	fposition=ftell(fptr);
	
	if (debug) printf("lengths %d %d %d\n",(int)fposition,(int)dposition,offset);
	optr=fopen("out.tif","w");
	fclose(fptr);
	fclose(dptr);
	for(i2=0;i2<fposition;i2++) {
	putc(buffer[i2],optr);
	}
	for(i2=0;i2<dposition;i2++) {
	putc(dbuffer[i2],optr);
	}
	fclose(optr);
}

//Writes the tag that says were are real data starts
void StripOffsets(int n) {
   /* Strip offset tag, long int */
	WriteHexString(fptr,"0111000400000001");
	write4(fptr,n);
}


/* Write RowsPerStrip tag ny in our case */
void RowsPerStrip(int n){
	WriteHexString(fptr,"0116000300000001");
	write2(fptr,n); /* Image height */
	WriteHexString(fptr,"0000");
}

// StripByteCounts tag.
// We have a single strip of data so this is set to nx*ny
void StripByteCounts(int n){
   /* StripByteCounts tag, short int */
	WriteHexString(fptr,"0117000400000001");
	write4(fptr,n); 
}


/* This tag is a pointer to the beginning of the colormap  */
void ColorMap(int n) {
	WriteHexString(fptr,  "0140000300000300");    
	if (debug) printf("color map ptr %d\n",n);
	write4(fptr,n); 
}


// Write image width tag (pixels)
void ImageWidth(int n) {
   /* Width tag, short int */
   WriteHexString(fptr,"0100000300000001");
   write2(fptr,n);
   WriteHexString(fptr,"0000");
}

// Write image length tag (pixels)
void ImageLength(int n) {
   /* Height tag, short int */
   WriteHexString(fptr,"0101000300000001");
   write2(fptr,n);
   WriteHexString(fptr,"0000");
}

void ModelPixelScaleTag(int n) {
	WriteHexString(fptr,"830e000c00000003");
	write4(fptr,n);
}


void doit(int thetag,unsigned char *thebytes){
int i,k,len;
long saveloc,toloc;

switch(thetag) {

   case 256  :
   //ImageWidth           0100    256
   ImageWidth_val=nx;
        break;
    case 257  :
  //ImageLength          0101    257
   ImageLength_val=ny;
       break;
   case 258  :
   //BitsPerSample        0102    258
       for(i=0;i<12;i++)
       	BitsPerSample_bytes[i]=(char)thebytes[i];
       	// we are going to do a copy but we still need this value
       	BitsPerSample_val=flip2(&thebytes[8]);
       	if (debug) printf("BitsPerSample_val= %d\n",BitsPerSample_val);
       break;
   case 259  :
   //Compression          0103    259
       for(i=0;i<12;i++)
       	Compression_bytes[i]=(char)thebytes[i];
       break;
    case 262  :
  //Photometric          0106    262
       for(i=0;i<12;i++)
       	Photometric_bytes[i]=(char)thebytes[i];
       break;
    case 273  :
//	StripOffsets         0111    273    *    *
// We don't do anything here because we don't
// know the final offset
		break;
    case 277  :
    //SamplesPerPixel      0115    277
       for(i=0;i<12;i++)
       SamplesPerPixel_bytes[i]=(char)thebytes[i];
       break;
    case 284  :
    //PlanarConfiguration  011c    284
       for(i=0;i<12;i++)
       PlanarConfiguration_bytes[i]=(char)thebytes[i];
       break;
    case 296  :
    //ResolutionUnit       0128    296
       for(i=0;i<12;i++)
       ResolutionUnit_bytes[i]=(char)thebytes[i];
       break;

    case 339  :
    // SampleFormat         0153    339
       for(i=0;i<12;i++)
       SampleFormat_bytes[i]=(char)thebytes[i];
       break;

    case 279  :
    //StripByteCounts      0117    279         *
       StripByteCounts_val=nx*ny;
       break;
       
    case 282  :
    // Resolution          011a    282    *    *
		XResolution_ptr=offset;
		for(i=0;i<12;i++)
			XResolution_bytes[i]=(char)thebytes[i];
		len=8;
		offset=offset+len;
		XResolution_cnt=len;
		//grab the color map
		XResolution_val=(char*)malloc(8);
		// get the current file location
		saveloc=ftell(fptr);
		toloc=(long)flip4(&thebytes[8]);
		if (debug) printf(" %ld %ld\n",saveloc,toloc);
		// go to where the data is
		fseek(fptr,toloc,SEEK_SET);
		// read it
		fread(XResolution_val,sizeof(char),len,fptr);
		// restore the file read location.  
		fseek(fptr,saveloc,SEEK_SET);
		break;

    case 283  :
    // YResolution          011b    283    *    *
		YResolution_ptr=offset;
		for(i=0;i<12;i++)
			YResolution_bytes[i]=(char)thebytes[i];
		len=8;
		offset=offset+len;
		YResolution_cnt=len;
		//grab the color map
		YResolution_val=(char*)malloc(8);
		// get the current file location
		saveloc=ftell(fptr);
		toloc=(long)flip4(&thebytes[8]);
		if (debug) printf(" %ld %ld\n",saveloc,toloc);
		// go to where the data is
		fseek(fptr,toloc,SEEK_SET);
		// read it
		fread(YResolution_val,sizeof(char),len,fptr);
		// restore the file read location.  
		fseek(fptr,saveloc,SEEK_SET);
		break;


    case 278  :
    //RowsPerStrip         0116    278         *
       RowsPerStrip_val=ny;
       break;
       
    case 320  :
		//ColorMap             0140    320    *    *
		ColorMap_ptr=offset;
		len=3*2*pow(2,BitsPerSample_val);
		offset=offset+len;
		if (debug) printf("ColorMap_ptr %d %d\n",ColorMap_ptr,offset);
		ColorMap_cnt=len;
		//grab the color map
		ColorMap_val=(char*)malloc(3*2*pow(2,BitsPerSample_val));
		// get the current file location
		saveloc=ftell(fptr);
		toloc=(long)flip4(&thebytes[8]);
		if (debug) printf(" %ld %ld\n",saveloc,toloc);
		// go to where the data is
		fseek(fptr,toloc,SEEK_SET);
		// read it
		fread(ColorMap_val,sizeof(char),len,fptr);
		// restore the file read location.  
		fseek(fptr,saveloc,SEEK_SET);
		/********************
		k=0;
		for (j=0;j<3;j++) {
		printf("\n");
		for(i=0;i<256;i++) {
		m=flip2((unsigned char *)&ColorMap_val[k]);
		printf("%d %d\n",i,m);
		k=k+2;
		}
		printf("\n");
		}
		********************/
       break;

    case 33550  :
		//ModelPixelScaleTag   830e    33550  *    *
		ModelPixelScaleTag_ptr=offset;
		len=3*8;
		offset=offset+len;
		if (debug) printf("ModelPixelScaleTag_ptr %d %d\n",ModelPixelScaleTag_ptr,offset);
		//grab the values
		ModelPixelScaleTag_val=(char*)malloc((size_t)len);
		// get the current file location
		saveloc=ftell(fptr);
		toloc=(long)flip4(&thebytes[8]);
		if (debug) printf(" %ld %ld\n",saveloc,toloc);
		// go to where the data is
		fseek(fptr,toloc,SEEK_SET);
		// read it
		fread(ModelPixelScaleTag_val,sizeof(char),len,fptr);
		// restore the file read location.  
		fseek(fptr,saveloc,SEEK_SET);

		if (debug) {
			printf("\nd=");
			for (i=0;i<3;i++) {
				printf(" %g ",flip_d((unsigned char*)&ModelPixelScaleTag_val[i*8]));
			}
				printf("\n");
			for (i=0;i<3;i++) { 
				for (k=0;k<8;k++)
					printf("%6d",(int)ModelPixelScaleTag_val[8*i+k]);
				printf("\n");
			}
		}

       break;

    case 33922  :
		//ModelTiepointTag     8482    33922  *    *
		ModelTiepointTag_ptr=offset;
		for(i=0;i<12;i++)
		ModelTiepointTag_bytes[i]=(char)thebytes[i];
		// grab the count
		ModelTiepointTag_cnt=(int)flip4(&thebytes[4]);
		if (debug) printf("ModelTiepointTag_cnt=%d\n",ModelTiepointTag_cnt);
		len=ModelTiepointTag_cnt*8;
		offset=offset+len;
		if (debug) printf("ModelTiepointTag_ptr %d %d\n",ModelTiepointTag_ptr,offset);

		//grab the values
		ModelTiepointTag_val=(char*)malloc((size_t)len);
		// get the current file location
		saveloc=ftell(fptr);
		toloc=(long)flip4(&thebytes[8]);
		if (debug) printf(" %ld %ld\n",saveloc,toloc);
		// go to where the data is
		fseek(fptr,toloc,SEEK_SET);
		// read it
		fread(ModelTiepointTag_val,sizeof(char),len,fptr);
		// restore the file read location.  
		fseek(fptr,saveloc,SEEK_SET);
		if (debug) {
			printf("\nd=");
			for (i=0;i<ModelTiepointTag_cnt;i++) {
				printf(" %g ",flip_d((unsigned char*)&ModelTiepointTag_val[8*i]));
			}
			printf("\n");
			for (i=0;i<ModelTiepointTag_cnt;i++) { 
				for (k=0;k<8;k++)
					printf("%6d",(int)ModelTiepointTag_val[8*i+k]);
				printf("\n");

			}
			printf("\n");
		}

       break;

    case 34735  :
		//GeoKeyDirectoryTag   87af    34735  *    *
		GeoKeyDirectoryTag_ptr=offset;
		for(i=0;i<12;i++)
		GeoKeyDirectoryTag_bytes[i]=(char)thebytes[i];

		// grap the count
		GeoKeyDirectoryTag_cnt=(int)flip4(&thebytes[4]);
		if (debug) printf("GeoKeyDirectoryTag_cnt=%d\n",GeoKeyDirectoryTag_cnt);
		len=GeoKeyDirectoryTag_cnt*4;
		offset=offset+len;
		if (debug) printf("GeoKeyDirectoryTag_ptr %d %d\n",GeoKeyDirectoryTag_ptr,offset);
		//grab the values
		GeoKeyDirectoryTag_val=(char*)malloc((size_t)len);
		// get the current file location
		saveloc=ftell(fptr);
		toloc=(long)flip4(&thebytes[8]);
		if (debug) printf(" %ld %ld\n",saveloc,toloc);
		// go to where the data is
		fseek(fptr,toloc,SEEK_SET);
		// read it
		fread(GeoKeyDirectoryTag_val,sizeof(char),len,fptr);
		// restore the file read location.  
		fseek(fptr,saveloc,SEEK_SET);
		if (debug) {
			printf("\nd=");
			for (i=0;i<GeoKeyDirectoryTag_cnt;i++) {
				printf(" %d ",flip2((unsigned char*)&GeoKeyDirectoryTag_val[2*i]));
			}
			printf("\n");
		}
		break;
    case 34736  :
		//GeoDoubleParamsTag   87b0    34736  *    *
		GeoDoubleParamsTag_ptr=offset;
		for(i=0;i<12;i++)
		GeoDoubleParamsTag_bytes[i]=(char)thebytes[i]; 
		// grap the count
		GeoDoubleParamsTag_cnt=(int)flip4(&thebytes[4]);
		if (debug) printf("GeoDoubleParamsTag_cnt=%d\n",GeoDoubleParamsTag_cnt);
		len=GeoDoubleParamsTag_cnt*8;
		offset=offset+len;
		if (debug) printf("GeoDoubleParamsTag_ptr %d %d\n",GeoDoubleParamsTag_ptr,offset);
		//grab the values
		GeoDoubleParamsTag_val=(char*)malloc((size_t)len);
		// get the current file location
		saveloc=ftell(fptr);
		toloc=(long)flip4(&thebytes[8]);
		if (debug) printf(" %ld %ld\n",saveloc,toloc);
		// go to where the data is
		fseek(fptr,toloc,SEEK_SET);
		// read it
		fread(GeoDoubleParamsTag_val,sizeof(char),len,fptr);
		// restore the file read location.  
		fseek(fptr,saveloc,SEEK_SET);
		if (debug) {
			printf("\nd=");
			for (i=0;i<GeoDoubleParamsTag_cnt;i++) {
				printf(" %g ",flip_d((unsigned char*)&GeoDoubleParamsTag_val[8*i]));
			}
			printf("\n");
		}
		break;
    case 34737  :
		//GeoAsciiParamsTag    87b1    34737  *    *
		GeoAsciiParamsTag_ptr=offset;
		for(i=0;i<12;i++)
		GeoAsciiParamsTag_bytes[i]=(char)thebytes[i];

		// grap the count
		GeoAsciiParamsTag_cnt=(int)flip4(&thebytes[4]);
		if (debug) printf("GeoAsciiParamsTag_cnt=%d\n",GeoAsciiParamsTag_cnt);
		len=GeoAsciiParamsTag_cnt*1;
		offset=offset+len;
		if (debug) printf("GeoAsciiParamsTag_ptr %d %d\n",GeoAsciiParamsTag_ptr,offset);
		//grab the values
		GeoAsciiParamsTag_val=(char*)malloc((size_t)len);
		// get the current file location
		saveloc=ftell(fptr);
		toloc=(long)flip4(&thebytes[8]);
		if (debug) printf(" %ld %ld\n",saveloc,toloc);
		// go to where the data is
		fseek(fptr,toloc,SEEK_SET);
		// read it
		fread(GeoAsciiParamsTag_val,sizeof(char),len,fptr);
		// restore the file read location.  
		fseek(fptr,saveloc,SEEK_SET);
		if (debug) {
			printf("\nd=");
			for (i=0;i<GeoAsciiParamsTag_cnt;i++) {
				printf("%c",GeoAsciiParamsTag_val[i]);
			}
			printf("\n");
		}
		break;

   /* you can have any number of case statements */
   default : /* Optional */
   printf("\ntag %d not handled on read\n",thetag);
   }
}
void writeit(int thetag){
	int i,k;

	switch(thetag) {

	   case 256  :
			//ImageWidth           0100    256
			ImageWidth(ImageWidth_val); 
			break;
		
		case 257  :
			//ImageLength          0101    257
			ImageLength(ImageLength_val); 
			break;
	   case 258  :
			//BitsPerSample        0102    258
			for (i=0;i<12;i++) {
				putc(BitsPerSample_bytes[i],fptr);
			}
			break;

	   case 259  :
			//Compression          0103    259
			for (i=0;i<12;i++) {
				putc(Compression_bytes[i],fptr);
			}
			break;
		case 262  :
	  //Photometric          0106    262
			for (i=0;i<12;i++) {
				putc(Photometric_bytes[i],fptr);
			}
			break;
		case 273  :
	//	StripOffsets         0111    273    *    *
			// at this point offset should point 
			// to the beginning of our data
			StripOffsets(offset); break;
		case 277  :
		//SamplesPerPixel      0115    277
			for (i=0;i<12;i++) {
				putc(SamplesPerPixel_bytes[i],fptr);
			}
			break;
		
		case 282  :
			for (i=0;i<8;i++) {
				putc(XResolution_bytes[i],fptr);
			}

			write4(fptr,XResolution_ptr);
		
			for (i=0;i<XResolution_cnt;i++) {
				putc(XResolution_val[i],dptr);
			}
			break;

		case 283  :
			for (i=0;i<8;i++) {
				putc(YResolution_bytes[i],fptr);
			}

			write4(fptr,YResolution_ptr);
		
			for (i=0;i<YResolution_cnt;i++) {
				putc(YResolution_val[i],dptr);
			}
			break;

		case 284  :
		//PlanarConfiguration  011c    284
			for (i=0;i<12;i++) {
				putc(PlanarConfiguration_bytes[i],fptr);
			}
			break;
		case 296  :
		//ResolutionUnit  011c    284
			for (i=0;i<12;i++) {
				putc(ResolutionUnit_bytes[i],fptr);
			}
			break;

		case 339  :
		// SampleFormat         0153    339
			for (i=0;i<12;i++) {
				putc(SampleFormat_bytes[i],fptr);
			}
			break;

		case 279  :
		//StripByteCounts      0117    279         *
			StripByteCounts(StripByteCounts_val);
			break;

		case 278  :
		//RowsPerStrip         0116    278         *
		   RowsPerStrip(RowsPerStrip_val); break;
	   
		case 320  :
		//ColorMap             0140    320    *    *
			ColorMap(ColorMap_ptr);
			// write the color map to dptr
			for (i=0;i<ColorMap_cnt;i++) {
				putc(ColorMap_val[i],dptr);
			}
			break;

		case 33550  :
		//ModelPixelScaleTag   830e    33550  *    *
			ModelPixelScaleTag(ModelPixelScaleTag_ptr);
		
			if (debug) printf("**** ModelPixelScaleTag_val\n");
			for (i=0;i<3;i++) { 
				for (k=0;k<8;k++) {
					putc((char)ModelPixelScaleTag_val[8*i+k],dptr);
					if (debug) printf("%6d",(int)ModelPixelScaleTag_val[8*i+k]);
					}
				if (debug) printf("\n");
			}

			break;

		case 33922  :
		//ModelTiepointTag     8482    33922  *    *
			for (i=0;i<8;i++) {
				putc(ModelTiepointTag_bytes[i],fptr);
			}

			write4(fptr,ModelTiepointTag_ptr);
		
			for (i=0;i<ModelTiepointTag_cnt*8;i++) {
				putc(ModelTiepointTag_val[i],dptr);
			}
			break;


		case 34735  :
		//GeoKeyDirectoryTag   87af    34735  *    *
			for (i=0;i<8;i++) {
				putc(GeoKeyDirectoryTag_bytes[i],fptr);
			}

			write4(fptr,GeoKeyDirectoryTag_ptr);
		
			for (i=0;i<GeoKeyDirectoryTag_cnt*4;i++) {
				putc(GeoKeyDirectoryTag_val[i],dptr);
			}
			break;
		case 34736  :
		//GeoDoubleParamsTag   87b0    34736  *    *
					for (i=0;i<8;i++) {
				putc(GeoDoubleParamsTag_bytes[i],fptr);
			}

			write4(fptr,GeoDoubleParamsTag_ptr);
		
			for (i=0;i<GeoDoubleParamsTag_cnt*8;i++) {
				putc(GeoDoubleParamsTag_val[i],dptr);
			}
			break;

		case 34737  :
		//GeoAsciiParamsTag    87b1    34737  *    *
					for (i=0;i<8;i++) {
				putc(GeoAsciiParamsTag_bytes[i],fptr);
			}

			write4(fptr,GeoAsciiParamsTag_ptr);
		
			for (i=0;i<GeoAsciiParamsTag_cnt*1;i++) {
				putc(GeoAsciiParamsTag_val[i],dptr);
			}
			break;

	   default :
	   printf("\ntag %d not handled on write\n",thetag);
	}
}
