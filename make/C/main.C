#include "headers.h"

/*-----------------------------------------------------------------------------
 *  main  --  reads option values, reads a snapshot, and launches the
 *            integrator
 *-----------------------------------------------------------------------------
 */

int main(int argc, char *argv[])
{
    real  dt_param = 0.03;     // control parameter to determine time step size
    real  dt_dia = 1;          // time interval between diagnostics output
    real  dt_out = 1;          // time interval between output of snapshots
    real  dt_tot = 10;         // duration of the integration
    bool  init_out = false;    // if true: snapshot output with start at t = 0
                               //          with an echo of the input snapshot
    bool  x_flag = false;      // if true: extra debugging diagnostics output

    if (! read_options(argc, argv, dt_param, dt_dia, dt_out, dt_tot, init_out,
                       x_flag))
        return 1;                // halt criterion detected by read_options()

    int n;                       // N, number of particles in the N-body system
    cin >> n;

    real t;                      // time
    cin >> t;

    real * mass = new real[n];                  // masses for all particles
    real (* pos)[NDIM] = new real[n][NDIM];     // positions for all particles
    real (* vel)[NDIM] = new real[n][NDIM];     // velocities for all particles

    get_snapshot(mass, pos, vel, n);

    evolve(mass, pos, vel, n, t, dt_param, dt_dia, dt_out, dt_tot, init_out,
           x_flag);

    delete[] mass;
    delete[] pos;
    delete[] vel;
}
