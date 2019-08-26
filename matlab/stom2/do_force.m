function do_force ( i1, i2, j1, j2)
global the_for
global dy
for i=i1:i2
for j=j1:j2 
    y=j*dy;
    the_for(i,j)=force(y);
end
end
end

