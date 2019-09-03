% look in our environment for a seed
if length(getenv('MYSEED')) > 0
% found it so use it
  myseed=int32(str2num(getenv('MYSEED')));
else
% seed is milliseconds since 1970-01-01
  myseed=int64(milliseconds(datetime('now','Timezone','UTC')-datetime('1970-01-01','Timezone','UTC')));
  myseed=myseed-1567000000000;
  myseed=int32(myseed);
end
fprintf("my seed is %15d\n",myseed)

% set seed
rng(myseed);

% test it, each run should return a different set of values
for n=1:10
  fprintf("%10.7g %10.7g\n",rand(),randn())
end

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
quit()

