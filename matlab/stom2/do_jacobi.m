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
    global s
    diff=0.0;
    if mod(s,2) == 1
       new_psi(i1:i2,j1:j2)=a1*psi(i1+1:i2+1,j1:j2)+a2*psi(i1-1:i2-1,j1:j2)+a3*psi(i1:i2,j1+1:j2+1)+a4*psi(i1:i2,j1-1:j2-1)-a5*the_for(i1:i2,j1:j2);
    else
       psi(i1:i2,j1:j2)=a1*new_psi(i1+1:i2+1,j1:j2)+a2*new_psi(i1-1:i2-1,j1:j2)+a3*new_psi(i1:i2,j1+1:j2+1)+a4*new_psi(i1:i2,j1-1:j2-1)-a5*the_for(i1:i2,j1:j2);
    end
    diff=sum(sum(abs(psi-new_psi)));
end

