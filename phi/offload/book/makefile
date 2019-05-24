SIZE=2048
SIZE=4096
offit:auto.c
#	icc -offload-option,mic,ld,"--no-undefined" -mkl -DSIZE=$(SIZE) auto.c -o offit
	icc  -mkl -DSIZE=$(SIZE) auto.c -o offit

clean:
	rm -rf *offit*
	rm -rf *.script *hosts *out slurm* *error *env *ENV *ssh


