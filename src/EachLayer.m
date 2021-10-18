function Depth_Upper=EachLayer(Depth_IM,RGB_Upper,win,wins,th_edge,th_class,th_mem,alpha,sigma_c,sigma_d,model)   
Depth_Upper=zeros(size(RGB_Upper,1),size(RGB_Upper,2));%map the depth to its higher resolution grid
Depth_Upper(1:2:end,1:2:end)=Depth_IM;
if model==1 % for the HDS model
    Depth_Upper=PyraUpsampleBasic(Depth_IM,Depth_Upper,RGB_Upper,win,wins,th_edge,sigma_c,sigma_d);%interpolation guided by RGB image in the same layer
else % for the C-HDS model
    Depth_Upper=PyraUpsampleClass(Depth_IM,Depth_Upper,RGB_Upper,win,wins,th_edge,th_class,th_mem,alpha,sigma_c,sigma_d);%interpolation guided by RGB image in the same layer
end
end