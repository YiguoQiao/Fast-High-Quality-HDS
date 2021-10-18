function Depth_Upper=PyraUpsampleClass_Feature(Depth_IM,Depth_Upper,RGB_l,Fea_Map1_l,Fea_Map2_l,win,wins,th_edge,th_class,th_mem,alpha,sigma_c,sigma_f1,sigma_f2,sigma_d) 
[dstRow,dstCol]=size(Depth_Upper);
Side_len=2*win+1;%side length of the window
MatrixComp=zeros(dstRow,dstCol,Side_len^2-1);
Depth_BL_Upper=imresize(Depth_IM,[dstRow dstCol],'bilinear');
iter=0; 
for i=-win:win  
    for j=-win:win
         if ~(i==0 && j==0)
            iter=iter+1;
            MatrixComp(win+1:dstRow-win,win+1:dstCol-win,iter)= Depth_BL_Upper(win+1+i:dstRow-win+i,win+1+j:dstCol-win+j) ;
         end
    end
end
Edge=(max(MatrixComp,[],3)-min(MatrixComp,[],3))>th_edge|Depth_BL_Upper==0;%boundary detection
Depth_Upper(Depth_Upper==0&Edge==0)=Depth_BL_Upper(Depth_Upper==0&Edge==0);%to accelerate the program, fill the regions except the edges by using bilinear interpolation 
[Lx,Ly]=find(Depth_Upper==0);
Invalid_L=find(Lx<=wins|Lx>dstRow-wins|Ly<=wins|Ly>dstCol-wins);
Lx(Invalid_L)=[];Ly(Invalid_L)=[];
index  = sub2ind(size(Depth_Upper), Lx, Ly);  
RGB_index=RGB_l([index index+dstRow*dstCol index+2*dstRow*dstCol]);
Feature1_index=Fea_Map1_l([index index+dstRow*dstCol index+2*dstRow*dstCol]);
Feature2_index=Fea_Map2_l([index index+dstRow*dstCol index+2*dstRow*dstCol]);
B0=zeros(size(index,1),Side_len^2-1);
iter=0;
A0=B0;C0=B0;
for i=-wins:wins
    for j=-wins:wins
        if ~(i==0 && j==0)
            iter=iter+1; 
            index_neighbour  = sub2ind(size(Depth_Upper), Lx+i, Ly+j); % neighbouring locations of the to be interpolated point    
            Depth_index_neighbour =Depth_Upper(index_neighbour);
            RGB_index_neighbour=RGB_l([index_neighbour index_neighbour+dstRow*dstCol index_neighbour+2*dstRow*dstCol]);% R, G, B channels of the neighbouring locations
            Feature1_index_neighbour=Fea_Map1_l([index_neighbour index_neighbour+dstRow*dstCol index_neighbour+2*dstRow*dstCol]);% shallow feature channels of the neighbouring locations
            Feature2_index_neighbour=Fea_Map2_l([index_neighbour index_neighbour+dstRow*dstCol index_neighbour+2*dstRow*dstCol]);% multi-layer feature channels of the neighbouring locations
            Dis=(sum((RGB_index-RGB_index_neighbour).^2,2)./sigma_c+sum((Feature1_index-Feature1_index_neighbour).^2,2)./sigma_f1+sum((Feature2_index-Feature2_index_neighbour).^2,2)./sigma_f2+repmat((i^2+j^2)/sigma_d,size(index))).*(Depth_index_neighbour~=0);%color distance + feature distance + spatial distance
            Dis(Dis==0)=Inf;
            Dis_c=(sum((RGB_index-RGB_index_neighbour).^2,2)./sigma_c+sum((Feature1_index-Feature1_index_neighbour).^2,2)./sigma_f1+sum((Feature2_index-Feature2_index_neighbour).^2,2)./sigma_f2).*(Depth_index_neighbour~=0);%color distance + feature distance
            Dis_c(Dis_c==0)=Inf;
            A0(:,iter)=Depth_index_neighbour;
            B0(:,iter)=Dis;
            C0(:,iter)=Dis_c;
        end
    end
end
Sorted_depth=sort(A0,2);%sort the depth values
Depth_index=zeros(size(A0,1),1);
for i=1:size(Sorted_depth,1)
    cla=1;%number of classes
    Cla=zeros(1,size(A0,2));%classification result
    for j=1:size(Sorted_depth,2)-1
        if Sorted_depth(i,j)~=0 && Sorted_depth(i,j+1)-Sorted_depth(i,j)>th_class
             CV=Sorted_depth(i,j);%critical values of the classification
             Cla(1,A0(i,:)~=0&A0(i,:)<=CV&Cla(1,:)==0)=cla;
             cla=cla+1;
        end
    end
    if cla==1
         Cla(1,A0(i,:)~=0)=cla;
    else
         Cla(1,A0(i,:)>CV&Cla(1,:)==0)=cla;
    end
    Dis_c_all=C0(i,A0(i,:)~=0);
    W_c=Dis_c_all.^(-1);%weights according to the sum of the color distance and the feature distance
    sw=sum(W_c,2);%sum of weights
    Cla_all=Cla(1,Cla(1,:)~=0);
    M=zeros(1,cla);
    for z=1:cla
        M(z)=sum(W_c(Cla_all==z),'all')/sw;%membership 
    end
    [Mem_max,La]=max(M);%maximum membership
    if Mem_max<th_mem
        Omega=0.5;
    else
        Omega=alpha;
    end
    kernel1=exp(-B0(i,Cla(1,:)==La))*Omega;%Gaussian kernels
    kernel2=exp(-B0(i,Cla(1,:)~=La&Cla(1,:)~=0))*(1-Omega);
    A0_1=kernel1.*A0(i,Cla(1,:)==La);
    A0_2=kernel2.*A0(i,Cla(1,:)~=La&Cla(1,:)~=0);
    B=sum(kernel1,2)+sum(kernel2,2);
    A=sum(A0_1,2)+sum(A0_2,2);
    Depth_index(i)=A./B;
end
Depth_Upper(index)=Depth_index;
Depth_Upper(Depth_Upper==0)=Depth_BL_Upper(Depth_Upper==0);
Depth_Upper(isnan(Depth_Upper))=Depth_BL_Upper(isnan(Depth_Upper));



        
