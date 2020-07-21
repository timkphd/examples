#include "headers.h"
/*-----------------------------------------------------------------------------
 *  write_diagnostics  --  writes diagnostics on the error stream cerr:
 *                         current time; number of integration steps so far;
 *                         kinetic, potential, and total energy; absolute and
 *                         relative energy errors since the start of the run.
 *                         If x_flag (x for eXtra data) is true, all internal
 *                         data are dumped for each particle (mass, position,
 *                         velocity, acceleration, and jerk).
 *
 *  note: the kinetic energy is calculated here, while the potential energy is
 *        calculated in the function get_acc_jerk_pot_coll().
 *-----------------------------------------------------------------------------
 */

void write_diagnostics(const real mass[], const real pos[][NDIM],
                       const real vel[][NDIM], const real acc[][NDIM],
                       const real jerk[][NDIM], int n, real t, real epot,
                       int nsteps, real & einit, bool init_flag,
                       bool x_flag)
{
    real ekin = 0;                       // kinetic energy of the n-body system
    for (int i = 0; i < n ; i++)
        for (int k = 0; k < NDIM ; k++)
            ekin += 0.5 * mass[i] * vel[i][k] * vel[i][k];

    real etot = ekin + epot;             // total energy of the n-body system

    if (init_flag)                       // at first pass, pass the initial
        einit = etot;                    // energy back to the calling function

    cerr << "at time t = " << t << " , after " << nsteps
         << " steps :\n  E_kin = " << ekin
         << " , E_pot = " << epot
         << " , E_tot = " << etot << endl;
    cerr << "                "
         << "absolute energy error: E_tot - E_init = "
         << etot - einit << endl;
    cerr << "                "
         << "relative energy error: (E_tot - E_init) / E_init = "
         << (etot - einit) / einit << endl;

    if (x_flag){
        cerr << "  for debugging purposes, here is the internal data "
             << "representation:\n";
        for (int i = 0; i < n ; i++){
            cerr << "    internal data for particle " << i+1 << " : " << endl;
            cerr << "      ";
            cerr << mass[i];
            for (int k = 0; k < NDIM; k++)
                cerr << ' ' << pos[i][k];
            for (int k = 0; k < NDIM; k++)
                cerr << ' ' << vel[i][k];
            for (int k = 0; k < NDIM; k++)
                cerr << ' ' << acc[i][k];
            for (int k = 0; k < NDIM; k++)
                cerr << ' ' << jerk[i][k];
            cerr << endl;
        }
    }
}