function bc(i1,i2,j1,j2,nx,ny)
    global psi
    if((i1-1) ==  1)
        for j=j1-1:j2+1
            psi(i1-1,j)=0.0;
        end
    end

    if((i2-1) ==  ny)
        for j=j1-1:j2+1
            psi(i2+1,j)=0.0;
        end
    end

    if((j1-1) ==  1)
        for j=i1-1:i2+1
            psi(j,j1-1)=0.0;
        end
    end

    if((j2-1) ==  nx)
        for j=i1-1:i2+1
            psi(j,j2+1)=0.0;
        end
    end

end

