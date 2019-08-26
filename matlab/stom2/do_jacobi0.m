function do_jacobi(i1,i2,j1,j2)
    global a1
    global a2
    global a3
    global a4
    global a5
    global diff
    global the_for
    global psi
    global new_psi
    diff=0.0;
%    for i=i1:i2
%    for j=j1:j2
    for j=j1:j2
    for i=i1:i2
            new_psi(i,j)=a1*psi(i + 1,j) + a2*psi(i - 1,j) + a3*psi(i,j+1) + a4*psi(i,j-1) - a5*the_for(i,j);
            diff=diff+abs(new_psi(i,j)-psi(i,j));
    end
    end
    psi=new_psi;
end

