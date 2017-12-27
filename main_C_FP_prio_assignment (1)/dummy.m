a = [1 2; 3 4;7 9]
b = [3 4]
c=ismember(a,b,'rows')
if (all(c(:)==0))
   d=1
else
   d=2
end