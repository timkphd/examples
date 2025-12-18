#!/opt/spack/base/120925/envs/3.14.1/bin/python
# coding: utf-8

# In[ ]:


import numpy as np
def gaussian_elimination_solver_org(A_coeffs, b_constants):
    """
    Solves a system of linear equations Ax = b using Gaussian elimination.
    """
    n = len(b_constants)
    # Create the augmented matrix
    aug_matrix = np.hstack((A_coeffs, b_constants.reshape(-1, 1)))

    # --- Forward Elimination (to Row Echelon Form) ---
    for i in range(n):
        pivot_row = i
        for j in range(i + 1, n):
            if abs(aug_matrix[j, i]) > abs(aug_matrix[pivot_row, i]):
                aug_matrix[[i, pivot_row]] = aug_matrix[[pivot_row, i]] # Swap rows
                pivot_row = j

        # Check for singular matrix
        if aug_matrix[i, i] == 0:
            raise ValueError("Matrix is singular, no unique solution exists.")

        # Eliminate elements below the pivot
        for j in range(i + 1, n):
            factor = aug_matrix[j, i] / aug_matrix[i, i]
            aug_matrix[j, :] -= factor * aug_matrix[i, :]

    # --- Back Substitution ---
    x = np.zeros(n)
    #print(aug_matrix)
    for i in reversed(range(n)):
        sum_ax = np.sum(aug_matrix[i, i+1:n] * x[i+1:n])
        x[i] = (aug_matrix[i, n] - sum_ax) / aug_matrix[i, i]       
    return x


# In[ ]:


import numpy as np
from numba import jit
@jit("float64[:](float64[:,:],float64[:])")
def gaussian_elimination_solver(A_coeffs, b_constants):
    """
    Solves a system of linear equations Ax = b using Gaussian elimination.
    """
    n = len(b_constants)
    # Create the augmented matrix
    #aug_matrix = np.hstack((A_coeffs, b_constants.reshape(-1, 1)))
    aug_matrix = np.empty((n,n+1), dtype=A_coeffs.dtype)
    aug_matrix[0:n,0:n]=A_coeffs
    aug_matrix[:,n]=b_constants

    # --- Forward Elimination (to Row Echelon Form) ---
    for i in range(n):
        pivot_row = i
        for j in range(i + 1, n):
            if abs(aug_matrix[j, i]) > abs(aug_matrix[pivot_row, i]):
                # aug_matrix[[i, pivot_row]] = aug_matrix[[pivot_row, i]] # Swap rows
                d=aug_matrix[i,:].copy()
                aug_matrix[i, :] = aug_matrix[pivot_row,:].copy()
                aug_matrix[pivot_row, :] = d.copy()
                pivot_row = j
        # Check for singular matrix
        if aug_matrix[i, i] == 0:
            raise ValueError("Matrix is singular, no unique solution exists.")

        # Eliminate elements below the pivot
        for j in range(i + 1, n):
            factor = aug_matrix[j, i] / aug_matrix[i, i]
            aug_matrix[j, :] -= factor * aug_matrix[i, :]

    # --- Back Substitution ---
    x = np.zeros(n)
    #print(aug_matrix)
    for i in range(n-1,-1,-1):
        sum_ax = np.sum(aug_matrix[i, i+1:n] * x[i+1:n])
        x[i] = (aug_matrix[i, n] - sum_ax) / aug_matrix[i, i]
    return(x)


# In[ ]:


from time import time
mysize=100
nt=10
verbose=False
print("Matrix size: ",mysize)


# In[ ]:


np.random.seed(42)
nba=np.zeros([nt])
print("\nNumba")
for i in range(0,nt):
    a=np.random.random([mysize,mysize]).astype(np.float64)
    b=np.random.random([mysize]).astype(np.float64)
    t1=time()
    solution = gaussian_elimination_solver(a, b)
    t2=time()
    print("%8.2e" % (t2-t1))
    nba[i]=t2-t1
    if verbose :
        formatted_vector = f"[{' '.join(f'{x:8.4f}' for x in solution)}]"
        print("  ",formatted_vector)


# In[ ]:


np.random.seed(42)
py=np.zeros([nt])
print("\nPure python")
for i in range(0,nt):
    a=np.random.random([mysize,mysize]).astype(np.float64)
    b=np.random.random([mysize]).astype(np.float64)
    t1=time()
    solution = gaussian_elimination_solver_org(a, b)
    t2=time()
    print("%8.2e" % (t2-t1))
    py[i]=t2-t1
    if verbose :
        formatted_vector = f"[{' '.join(f'{x:8.4f}' for x in solution)}]"
        print("  ",formatted_vector)


# In[ ]:


np.random.seed(42)
lib=np.zeros([nt])
print("\nnp.linalg.solve")
for i in range(0,nt):
    a=np.random.random([mysize,mysize]).astype(np.float64)
    b=np.random.random([mysize]).astype(np.float64)
    t1=time()
    solution = np.linalg.solve(a, b)
    t2=time()
    print("%8.2e" % (t2-t1))
    lib[i]=t2-t1
    if verbose :
        formatted_vector = f"[{' '.join(f'{x:8.4f}' for x in solution)}]"
        print("  ",formatted_vector)


# In[ ]:


lib


# In[ ]:


print("\nTimes (sec)")
print("python     numba      linalg")
pys=0.0
nbas=0.0
libs=0.0
count=0
for i in range(1,nt):
    print(f"{py[i]:8.3e}  {nba[i]:8.3e}  {lib[i]:8.3e}"  )
    count=count+1
    pys=pys+py[i]
    nbas=nbas+nba[i]
    libs=libs+lib[i]


# In[ ]:


print("\nSpeedup")
print("python  numba   linalg")
for i in range(1,nt):   
    print(f"{1:.0f}      {(py[i]/nba[i]):6.2f}   {(py[i]/lib[i]):6.2f}"  )

print("\nAverages")
pys=pys/count
nbas=nbas/count
libs=libs/count
print(f"{pys:8.3e}  {nbas:8.3e}  {libs:8.3e}"  )
print(f"{1:.0f}           {(pys/nbas):8.2f}   {(pys/libs):8.2f}"  )






