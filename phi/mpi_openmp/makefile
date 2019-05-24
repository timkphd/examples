default: StomOmpf_00d.mic StomOmpf_00d.x86 helloc.mic helloc.x86 hellof.mic hellof.x86 hybrid.mic hybrid.x86 ppong.mic ppong.x86 phostname

StomOmpf_00d.mic:StomOmpf_00d.f
	ifort $(MIC)  StomOmpf_00d.f -o StomOmpf_00d.mic
	rm *mod

StomOmpf_00d.x86:StomOmpf_00d.f
	ifort $(X86)  StomOmpf_00d.f -o StomOmpf_00d.x86
	rm *mod

clean:
	rm -rf *mod StomOmpf_00d.mic StomOmpf_00d.x86 hello*.mic hello*.x86 tmp* hybrid.mic hybrid.x86 ppong.mic ppong.x86 phostone.mic phostone.x86
	rm -rf *script *hosts *out *error

MIC=-free -mmic -openmp -O3
X86=-free  -openmp -O3


#source /opt/intel/impi/4.1.1.036/intel64/bin/mpivars.sh
ppong.mic:ppong.c
	mpiicc -mmic ppong.c -o ppong.mic

ppong.x86:ppong.c
	mpiicc  ppong.c -o ppong.x86

helloc.mic:helloc.c
	mpiicc -mmic helloc.c -o helloc.mic

helloc.x86:helloc.c
	mpiicc  helloc.c -o helloc.x86

hellof.mic:hellof.f
	mpiifort -mmic hellof.f -o hellof.mic

hellof.x86:hellof.f
	mpiifort  hellof.f -o hellof.x86


hybrid.mic: hybrid.f90
	mpiifort  -mmic  -openmp hybrid.f90 -o hybrid.mic
	rm *mod

hybrid.x86: hybrid.f90
	mpiifort    -openmp hybrid.f90 -o hybrid.x86
	rm *mod

phostname: phostone.c 
	mpiicc   -openmp phostone.c -o phostone.x86
	mpiicc   -mmic -openmp phostone.c -o phostone.mic


