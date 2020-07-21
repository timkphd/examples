              // Time-stamp: <2002-01-18 21:51:36 piet>
             //================================================================
            //                                                                |
           //           /__----__                         ........            |
          //       .           \                     ....:        :.          |
         //       :                 _\|/_         ..:                         |
        //       :                   /|\         :                     _\|/_  |
       //  ___   ___                  _____                      ___    /|\   |
      //  /     |   \    /\ \     / |   |   \  / |        /\    |   \         |
     //  |   __ |___/   /  \ \   /  |   |    \/  |       /  \   |___/         |
    //   |    | |  \   /____\ \ /   |   |    /   |      /____\  |   \     \/  |
   //     \___| |   \ /      \ V    |   |   /    |____ /      \ |___/     |   |
  //                                                                      /   |
 //              :                       _/|     :..                    |/    |
//                :..               ____/           :....          ..         |
/*   o   //          :.    _\|/_     /                   :........:           |
 *  O  `//\                 /|\                                               |
 *  |     /\                                                                  |
 *=============================================================================
 *
 *  nbody_sh1.C:  an N-body integrator with a shared but variable time step
 *                (the same for all particles but changing in time), using
 *                the Hermite integration scheme.
 *                        
 *                ref.: Hut, P., Makino, J. & McMillan, S., 1995,
 *                      Astrophysical Journal Letters 443, L93-L96.
 *                
 *  note: in this first version, all functions are included in one file,
 *        without any use of a special library or header files.
 *_____________________________________________________________________________
 *
 *  usage: nbody_sh1 [-h (for help)] [-d step_size_control_parameter]
 *                   [-e diagnostics_interval] [-o output_interval]
 *                   [-t total_duration] [-i (start output at t = 0)]
 *                   [-x (extra debugging diagnostics)]
 * 
 *         "step_size_control_parameter" is a coefficient determining the
 *            the size of the shared but variable time step for all particles
 *
 *         "diagnostics_interval" is the time between output of diagnostics,
 *            in the form of kinetic, potential, and total energy; with the
 *            -x option, a dump of the internal particle data is made as well
 * 
 *         "output_interval" is the time between successive snapshot outputs
 *
 *         "total_duration" is the integration time, until the program stops
 *
 *         Input and output are written from the standard i/o streams.  Since
 *         all options have sensible defaults, the simplest way to run the code
 *         is by only specifying the i/o files for the N-body snapshots:
 *
 *            nbody_sh1 < data.in > data.out
 *
 *         The diagnostics information will then appear on the screen.
 *         To capture the diagnostics information in a file, capture the
 *         standard error stream as follows:
 *
 *            (nbody_sh1 < data.in > data.out) >& data.err
 *
 *  Note: if any of the times specified in the -e, -o, or -t options are not an
 *        an integer multiple of "step", output will occur slightly later than
 *        predicted, after a full time step has been taken.  And even if they
 *        are integer multiples, round-off error may induce one extra step.
 *_____________________________________________________________________________
 *
 *  External data format:
 *
 *     The program expects input of a single snapshot of an N-body system,
 *     in the following format: the number of particles in the snapshot n;
 *     the time t; mass mi, position ri and velocity vi for each particle i,
 *     with position and velocity given through their three Cartesian
 *     coordinates, divided over separate lines as follows:
 *
 *                      n
 *                      t
 *                      m1 r1_x r1_y r1_z v1_x v1_y v1_z
 *                      m2 r2_x r2_y r2_z v2_x v2_y v2_z
 *                      ...
 *                      mn rn_x rn_y rn_z vn_x vn_y vn_z
 *
 *     Output of each snapshot is written according to the same format.
 *
 *  Internal data format:
 *
 *     The data for an N-body system is stored internally as a 1-dimensional
 *     array for the masses, and 2-dimensional arrays for the positions,
 *     velocities, accelerations and jerks of all particles.
 *_____________________________________________________________________________
 *
 *    version 1:  Jan 2002   Piet Hut, Jun Makino
 *_____________________________________________________________________________
 */

#include  <iostream>
#include  <cmath>                          // to include sqrt(), etc.
#include  <cstdlib>                        // for atoi() and atof()
#include  <unistd.h>                       // for getopt()
using namespace std;

typedef double  real;                      // "real" as a general name for the
                                           // standard floating-point data type

const int NDIM = 3;                        // number of spatial dimensions

void correct_step(real pos[][NDIM], real vel[][NDIM], 
                  const real acc[][NDIM], const real jerk[][NDIM],
                  const real old_pos[][NDIM], const real old_vel[][NDIM], 
                  const real old_acc[][NDIM], const real old_jerk[][NDIM],
                  int n, real dt);
void evolve(const real mass[], real pos[][NDIM], real vel[][NDIM],
            int n, real & t, real dt_param, real dt_dia, real dt_out,
            real dt_tot, bool init_out, bool x_flag);
void evolve_step(const real mass[], real pos[][NDIM], real vel[][NDIM],
                 real acc[][NDIM], real jerk[][NDIM], int n, real & t,
                 real dt, real & epot, real & coll_time);
void get_acc_jerk_pot_coll(const real mass[], const real pos[][NDIM],
                           const real vel[][NDIM], real acc[][NDIM],
                           real jerk[][NDIM], int n, real & epot,
                           real & coll_time);
void get_snapshot(real mass[], real pos[][NDIM], real vel[][NDIM], int n);
void predict_step(real pos[][NDIM], real vel[][NDIM], 
                  const real acc[][NDIM], const real jerk[][NDIM],
                  int n, real dt);
void put_snapshot(const real mass[], const real pos[][NDIM],
                  const real vel[][NDIM], int n, real t);
bool read_options(int argc, char *argv[], real & dt_param, real & dt_dia,
                  real & dt_out, real & dt_tot, bool & i_flag, bool & x_flag);
void write_diagnostics(const real mass[], const real pos[][NDIM],
                       const real vel[][NDIM], const real acc[][NDIM],
                       const real jerk[][NDIM], int n, real t, real epot,
                       int nsteps, real & einit, bool init_flag,
                       bool x_flag);