# Example of how you might create and use a local tarball for spack. 
# Have lines like the those below in your makefile 
#  gz: 
#  	  tar -czf simple-1.0.tgz makefile stf_01.f90 
#	  sha256sum simple-1.0.tgz 
# 
# install: $(ALLF) 
#  	  mkdir -p ${PREFIX}/bin 
#	  cp stf_01 ${PREFIX}/bin 
 
# Run make gz 
# Paste the string from the sha256sum in the version line 
# Run a local web server: 
# python3 -m http.server 8123 
 
 
from spack import * 
 
class Julia(Package): 

    """Vasp built with Intel compilers,mpi,mkl""" 
 
    # FIXME: Add a proper url for your package's homepage here. 
    homepage = "https://github.com/timkphd/examples" 
   #url      = "https://github.com/timkphd/examples/raw/master/hybrid/spack/simple-1.0.tgz" 
    url      = "https://github.com/JuliaLang/julia/releases/download/v1.7.2/julia-1.7.2-full.tar.gz"
   #url      = https://github.com/JuliaLang/julia/releases/download/v1.8.0-beta1/julia-1.8.0-beta1-full.tar.gz
 
    # GitHub accounts to notify when the package is updated. 
    maintainers = ['timkphd'] 
 
    version('1.7.2', sha256='c1b4f1f75aac34c40e81805cba2d87f1e72f9ce1405a525273c3688eee12366f') 
    version('1.8.0', sha256='5afbdd99bbec4c6dd0227cdd5432ae6bf0b39fff428f09282d6e38485918397c')
 
    # depends_on nothing 
 
    def build(self, spec, prefix): 
        # Running from a predefined makefile, no configure or cmake 
        #make('std') 
        make('install') 
 
    def install(self, spec, prefix): 
        # Running from a predefined makefile, no configure or cmake 
        self.build(spec,prefix) 
        #install_tree('julia-1.7.2/', prefix.bin) 
        install_tree('julia-1.7.2/', prefix) 


