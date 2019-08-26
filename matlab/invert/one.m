for n=[800]
t=0.0;
count=1000;
for c=1:count
a=rand(n,n);
x=ones(n,1);
b=a*x;
tic;
z=a\b;
t=t+toc;
end
t=t/count;
XOUT=sprintf('%8d %10.5f ',n,t);
disp(XOUT)
end

