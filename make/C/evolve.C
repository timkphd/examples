#include "headers.h"

/*-----------------------------------------------------------------------------
 *  evolve  --  integrates an N-body system, for a total duration dt_tot.
 *              Snapshots are sent to the standard output stream once every
 *              time interval dt_out.  Diagnostics are sent to the standard
 *              error stream once every time interval dt_dia.
 *
 *  note: the integration time step, shared by all particles at any given time,
 *        is variable.  Before each integration step we use coll_time (short
 *        for collision time, an estimate of the time scale for any significant
 *        change in configuration to happen), multiplying it by dt_param (the
 *        accuracy parameter governing the size of dt in units of coll_time),
 *        to obtain the new time step size.
 *
 *  Before moving any particles, we start with an initial diagnostics output
 *  and snapshot output if desired.  In order to write the diagnostics, we
 *  first have to calculate the potential energy, with get_acc_jerk_pot_coll().
 *  That function also calculates accelerations, jerks, and an estimate for the
 *  collision time scale, all of which are needed before we can enter the main
 *  integration loop below.
 *       In the main loop, we take as many integration time steps as needed to
 *  reach the next output time, do the output required, and continue taking
 *  integration steps and invoking output this way until the final time is
 *  reached, which triggers a `break' to jump out of the infinite loop set up
 *  with `while(true)'.
 *-----------------------------------------------------------------------------
 */

void evolve(const real mass[], real pos[][NDIM], real vel[][NDIM],
            int n, real & t, real dt_param, real dt_dia, real dt_out,
            real dt_tot, bool init_out, bool x_flag)
{
    cerr << "Starting a Hermite integration for a " << n
         << "-body system,\n  from time t = " << t 
         << " with time step control parameter dt_param = " << dt_param
         << "  until time " << t + dt_tot 
         << " ,\n  with diagnostics output interval dt_dia = "
         << dt_dia << ",\n  and snapshot output interval dt_out = "
         << dt_out << "." << endl;

    real (* acc)[NDIM] = new real[n][NDIM];          // accelerations and jerks
    real (* jerk)[NDIM] = new real[n][NDIM];         // for all particles
    real epot;                        // potential energy of the n-body system
    real coll_time;                   // collision (close encounter) time scale

    get_acc_jerk_pot_coll(mass, pos, vel, acc, jerk, n, epot, coll_time);

    int nsteps = 0;               // number of integration time steps completed
    real einit;                   // initial total energy of the system

    write_diagnostics(mass, pos, vel, acc, jerk, n, t, epot, nsteps, einit,
                      true, x_flag);
    if (init_out)                                    // flag for initial output
        put_snapshot(mass, pos, vel, n, t);

    real t_dia = t + dt_dia;           // next time for diagnostics output
    real t_out = t + dt_out;           // next time for snapshot output
    real t_end = t + dt_tot;           // final time, to finish the integration

    while (true){
        while (t < t_dia && t < t_out && t < t_end){
            real dt = dt_param * coll_time;
            evolve_step(mass, pos, vel, acc, jerk, n, t, dt, epot, coll_time);
            nsteps++;
        }
        if (t >= t_dia){
            write_diagnostics(mass, pos, vel, acc, jerk, n, t, epot, nsteps,
                              einit, false, x_flag);
            t_dia += dt_dia;
        }
        if (t >= t_out){
            put_snapshot(mass, pos, vel, n, t);
            t_out += dt_out;
        }
        if (t >= t_end)
            break;
    }

    delete[] acc;
    delete[] jerk;
}