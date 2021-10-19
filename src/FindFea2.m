function [Fea_Map1_1,Fea_Map1_2]=FindFea2(Fea_Map1_Pre) 
conN1=8;conN2=2;
conv_kern1=rand(3,3,conN1);conv_kern2=rand(3,3,conN2);
Fea_Map1_1=zeros(size(Fea_Map1_Pre,1),size(Fea_Map1_Pre,2),conN1);
Fea_Map1_2=zeros(length(1:2:size(Fea_Map1_1,1)),length(1:2:size(Fea_Map1_1,2)),conN1*conN2);
for i=1:conN1
    Fea_Map1_1(:,:,i) = conv2(Fea_Map1_Pre,conv_kern1(:,:,i),'same');
end

for i=1:conN1
    for j=1:conN2
        Fea_Map1_2(:,:,(j-1)*conN1+i) = conv2(max_pooling(Fea_Map1_1(:,:,i),2),conv_kern2(:,:,j),'same');
    end
end