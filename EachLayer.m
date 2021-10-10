function [r1,bwimg1]=EachLayer(r,bwimg,I1,de,win,wins,th,alf)
r1=r/2;
bwimg1=zeros(size(I1,1),size(I1,2));
bwimg1(1:2:end,1:2:end)=bwimg;
%bwimg1=PyraUpsampleBasic(bwimg,bwimg1,I1,de,win,wins,th);
bwimg1=PyraUpsampleClass(bwimg,bwimg1,I1,de,win,wins,th,alf);
end