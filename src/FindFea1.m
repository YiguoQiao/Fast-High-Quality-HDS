function Fea_Map1_1=FindFea1(Fea_Map1_Pre) 
conN1=8;
conv_kern=rand(3,3,conN1);
Fea_Map1_1=zeros(size(Fea_Map1_Pre,1),size(Fea_Map1_Pre,2),conN1);
for i=1:conN1
Fea_Map1_1(:,:,i) = conv2(Fea_Map1_Pre,conv_kern(:,:,i),'same');
end