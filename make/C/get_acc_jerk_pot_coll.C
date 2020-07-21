#include "headers.h"
/*-----------------------------------------------------------------------------
 *  get_acc_jerk_pot_coll  --  calculates accelerations and jerks, and as side
 *                             effects also calculates potential energy and
 *                             the time scale coll_time for significant changes
 *                             in local configurations to occur.
 *                                                  __                     __
 *                                                 |          -->  -->       |
 *               M                           M     |           r  . v        |
 *   -->          j    -->       -->          j    | -->        ji   ji -->  |
 *    a   ==  --------  r    ;    j   ==  -------- |  v   - 3 ---------  r   |
 *     ji     |-->  |3   ji        ji     |-->  |3 |   ji      |-->  |2   ji |
 *            | r   |                     | r   |  |           | r   |       |
 *            |  ji |                     |  ji |  |__         |  ji |     __|
 *                             
 *  note: it would be cleaner to calculate potential energy and collision time
 *        in a separate function.  However, the current function is by far the
 *        most time consuming part of the whole program, with a double loop
 *        over all particles that is executed every time step.  Splitting off
 *        some of the work to another function would significantly increase
 *        the total computer time (by an amount close to a factor two).
 *
 *  We determine the values of all four quantities of interest by walking
 *  through the system in a double {i,j} loop.  The first three, acceleration,
 *  jerk, and potential energy, are calculated by adding successive terms;
 *  the last, the estimate for the collision time, is found by determining the 
 *  minimum value over all particle pairs and over the two choices of collision
 *  time, position/velocity and sqrt(position/acceleration), where position and
 *  velocity indicate their relative values between the two particles, while
 *  acceleration indicates their pairwise acceleration.  At the start, the
 *  first three quantities are set to zero, to prepare for accumulation, while
 *  the last one is set to a very large number, to prepare for minimization.
 *       The integration loops only over half of the pairs, with j > i, since
 *  the contributions to the acceleration and jerk of particle j on particle i
 *  is the same as those of particle i on particle j, apart from a minus sign
 *  and a different mass factor.
 *-----------------------------------------------------------------------------
 */

void get_acc_jerk_pot_coll(const real mass[], const real pos[][NDIM],
                           const real vel[][NDIM], real acc[][NDIM],
                           real jerk[][NDIM], int n, real & epot,
                           real & coll_time)
{
    for (int i = 0; i < n ; i++)
        for (int k = 0; k < NDIM ; k++)
            acc[i][k] = jerk[i][k] = 0;
    epot = 0;
    const real VERY_LARGE_NUMBER = 1e300;
    real coll_time_q = VERY_LARGE_NUMBER;      // collision time to 4th power
    real coll_est_q;                           // collision time scale estimate
                                               // to 4th power (quartic)
    for (int i = 0; i < n ; i++){
        for (int j = i+1; j < n ; j++){            // rji[] is the vector from
            real rji[NDIM];                        // particle i to particle j
            real vji[NDIM];                        // vji[] = d rji[] / d t
            for (int k = 0; k < NDIM ; k++){
                rji[k] = pos[j][k] - pos[i][k];
                vji[k] = vel[j][k] - vel[i][k];
            }
            real r2 = 0;                           // | rji |^2
            real v2 = 0;                           // | vji |^2
            real rv_r2 = 0;                        // ( rij . vij ) / | rji |^2
            for (int k = 0; k < NDIM ; k++){
                r2 += rji[k] * rji[k];
                v2 += vji[k] * vji[k];
                rv_r2 += rji[k] * vji[k];
            }
            rv_r2 /= r2;
            real r = sqrt(r2);                     // | rji |
            real r3 = r * r2;                      // | rji |^3

// add the {i,j} contribution to the total potential energy for the system:

            epot -= mass[i] * mass[j] / r;

// add the {j (i)} contribution to the {i (j)} values of acceleration and jerk:

            real da[3];                            // main terms in pairwise
            real dj[3];                            // acceleration and jerk
            for (int k = 0; k < NDIM ; k++){
                da[k] = rji[k] / r3;                           // see equations
                dj[k] = (vji[k] - 3 * rv_r2 * rji[k]) / r3;    // in the header
            }
            for (int k = 0; k < NDIM ; k++){
                acc[i][k] += mass[j] * da[k];                 // using symmetry
                acc[j][k] -= mass[i] * da[k];                 // find pairwise
                jerk[i][k] += mass[j] * dj[k];                // acceleration
                jerk[j][k] -= mass[i] * dj[k];                // and jerk
            }

// first collision time estimate, based on unaccelerated linear motion:

            coll_est_q = (r2*r2) / (v2*v2);
            if (coll_time_q > coll_est_q)
                coll_time_q = coll_est_q;

// second collision time estimate, based on free fall:

            real da2 = 0;                                  // da2 becomes the 
            for (int k = 0; k < NDIM ; k++)                // square of the 
                da2 += da[k] * da[k];                      // pair-wise accel-
            double mij = mass[i] + mass[j];                // eration between
            da2 *= mij * mij;                              // particles i and j

            coll_est_q = r2/da2;
            if (coll_time_q > coll_est_q)
                coll_time_q = coll_est_q;
        }                                     
    }                                               // from q for quartic back
    coll_time = sqrt(sqrt(coll_time_q));            // to linear collision time
}                                             
