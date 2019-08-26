nx=200;
ny=200;
lx=2000000.;
ly=2000000.;
global alpha
alpha=1.0e-9;
beta=2.25e-11;
gamma=3.0e-6;
steps=75;
global dx
global dy
dx=lx/(nx+1);
dy=ly/(ny+1);
dx2=dx*dx;
dy2=dy*dy;
bottom=2.0*(dx2+dy2);
global a1
global a2
global a3
global a4
global a5
global a6
global a1

a1=(dy2/bottom)+(beta*dx2*dy2)/(2.0*gamma*dx*bottom);
a2=(dy2/bottom)-(beta*dx2*dy2)/(2.0*gamma*dx*bottom);
a3=dx2/bottom;
a4=dx2/bottom;
a5=dx2*dy2/(gamma*bottom);
a6=pi/(ly);
myid=0;
nodes_row=1;
nodes_col=1;
myid_row=0;
myid_col=0;
myrow=1;
mycol=1;
dj=double(ny)/double(nodes_row);
j1=round(1.0+myid_row*dj);
j2=round(1.0+(myid_row+1)*dj)-1;
di=double(nx)/double(nodes_col);
i1=round(1.0+myid_col*di);
i2=round(1.0+(myid_col+1)*di)-1;
i1=i1+1;
i2=i2+1;
j1=j1+1;
j2=j2+1;
global psi
global new_psi
global the_for
psi=ones(i2+1,j2+1);
new_psi=ones(i2+1,j2+1);
the_for=ones(i2+1,j2+1);
global diff
diff=0;

bc(i1,i2,j1,j2,nx,ny);
new_psi=psi;
do_force ( i1, i2, j1, j2);

steps=75000
every=750
tic;
global s
for s=1:steps
    do_jacobi(i1,i2,j1,j2)
    if mod(s,every) == 0
        XOUT=sprintf('%8d %10.3f %13.6g',s,toc,diff);
        disp(XOUT)
    end
end
XOUT=sprintf('%8d %10.3f %13.6g',s,toc,diff);
disp(XOUT)
%exit

