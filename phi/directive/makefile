LIBS=-limf -lsvml -lintlc -lirng
dooff:dooff.c
	icc -offload-option,mic,ld,"--no-undefined" dooff.c -o dooff $(LIBS)

clean:
	rm -rf dooff k.in
	rm -rf *script hosts* slurm*out
