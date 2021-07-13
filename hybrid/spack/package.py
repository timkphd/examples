# Copyright 2013-2021 Lawrence Livermore National Security, LLC and other
# Spack Project Developers. See the top-level COPYRIGHT file for details.
#
# SPDX-License-Identifier: (Apache-2.0 OR MIT)

# ----------------------------------------------------------------------------
# If you submit this package back to Spack as a pull request,
# please first remove this boilerplate and all FIXME comments.
#
# This is a template package file for Spack.  We've put "FIXME"
# next to all the things you'll want to change. Once you've handled
# them, you can save this file and test your package like this:
#
#     spack install examples
#
# You can edit this file again by typing:
#
#     spack edit examples
#
# See the Spack documentation for more information on packaging.
# ----------------------------------------------------------------------------

from spack import *


class Fhostone(Package):
    """Hybrid MPI/OpenMP program."""

    homepage = "https://github.com/timkphd/examples"
    url      = "https://github.com/timkphd/examples/raw/master/hybrid/spack/fhostone-1.0.tar.gz"

    # FIXME: Add a list of GitHub accounts to
    # notify when the package is updated.
    # maintainers = ['github_user1', 'github_user2']

    version('1.0', sha256='a2dd3e6404f813da0d0768ff32190ec16aae59a4b338deaede58b7582df208ae')

    depends_on('mpi')
    depends_on('cmake',type='build')
    install_targets = ['install']

    def cmake_args(self):
        spec = self.spec
        args = []
#        args.append('-DWITH_CUDA=OFF')
#        args.append('-DCMAKE_INSTALL_NAME_DIR:PATH=%s/bin' % self.prefix)
        return(args)


    def install(a,b,thedir):
#        f=open("/home/tkaiser2/spack.out","w")
#        f.write("hello"+"\n\n"+str(a)+"\n\n"+str(b)+"\n\n"+str(thedir)+"\n\nxxxxx\n")
#        f.write("hello\n")
        where2="-DCMAKE_INSTALL_PREFIX="+thedir
        cmake(".",where2)
#        f.write("\ncmake")
        make('install')
        
#        f.write("\nmake('install')")
#        f.close()
