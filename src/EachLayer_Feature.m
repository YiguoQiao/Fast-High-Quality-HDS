function [r1,bwimg1]=EachLayer_Feature(r,bwimg,he,he1,de,win,wins,th,alf1,alf2)
r1=r/2;
bwimg1=zeros(size(he,1),size(he,2));
bwimg1(1:2:end,1:2:end)=bwimg(1:floor((size(he,1)+1)/2),1:floor((size(he,2)+1)/2));
%bwimg1=PyraUpsampleBasic_Feature(bwimg,bwimg1,he,he1,de,win,wins,th,alf1,alf2);
bwimg1=PyraUpsampleClass_Feature(bwimg,bwimg1,he,he1,de,win,wins,th,alf1,alf2);
end