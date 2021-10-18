function Depth_Upper=EachLayer_Feature(Depth_IM,RGB_l,Fea_Map1_l,Fea_Map2_l,win,wins,th_edge,th_class,th_mem,alpha,sigma_c,sigma_f1,sigma_f2,sigma_d,model)
Depth_Upper=zeros(size(Fea_Map1_l,1),size(Fea_Map1_l,2));%map the depth to its higher resolution grid
Depth_Upper(1:2:end,1:2:end)=Depth_IM(1:floor((size(Fea_Map1_l,1)+1)/2),1:floor((size(Fea_Map1_l,2)+1)/2));
if model==2 % for the F-HDS model
    Depth_Upper=PyraUpsampleBasic_Feature(Depth_IM,Depth_Upper,RGB_l,Fea_Map1_l,Fea_Map2_l,win,wins,th_edge,sigma_c,sigma_f1,sigma_f2,sigma_d);
else % for the FC-HDS model
    Depth_Upper=PyraUpsampleClass_Feature(Depth_IM,Depth_Upper,RGB_l,Fea_Map1_l,Fea_Map2_l,win,wins,th_edge,th_class,th_mem,alpha,sigma_c,sigma_f1,sigma_f2,sigma_d);
end
end