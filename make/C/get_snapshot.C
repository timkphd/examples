#include "headers.h"
/*-----------------------------------------------------------------------------
 *  get_snapshot  --  reads a single snapshot from the input stream cin.
 *
 *  note: in this implementation, only the particle data are read in, and it
 *        is left to the main program to first read particle number and time
 *-----------------------------------------------------------------------------
 */

void get_snapshot(real mass[], real pos[][NDIM], real vel[][NDIM], int n)
{
    for (int i = 0; i < n ; i++){
        cin >> mass[i];                       // mass of particle i
        for (int k = 0; k < NDIM; k++)
            cin >> pos[i][k];                 // position of particle i
        for (int k = 0; k < NDIM; k++)
            cin >> vel[i][k];                 // velocity of particle i
    }
}
