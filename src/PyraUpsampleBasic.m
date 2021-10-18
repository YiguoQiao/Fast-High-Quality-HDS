function Depth_Upper=PyraUpsampleBasic(Depth_IM,Depth_Upper,RGB_Upper,win,wins,th_edge,sigma_c,sigma_d)  
[dstRow,dstCol]=size(Depth_Upper);
Side_len=2*win+1;%side length of the window
MatrixComp=zeros(dstRow,dstCol,Side_len^2-1);
Depth_BL_Upper=imresize(Depth_IM,[dstRow dstCol],'bilinear');
iter=0;
for i=-win:win  
    for j=-win:win
        if ~(i==0 && j==0)
            iter=iter+1;
            MatrixComp(win+1:dstRow-win,win+1:dstCol-win,iter)=Depth_BL_Upper(win+1+i:dstRow-win+i,win+1+j:dstCol-win+j);    
        end
    end
end
Edge=(max(MatrixComp,[],3)-min(MatrixComp,[],3))>th_edge|Depth_BL_Upper==0;%boundary detection
Depth_Upper(Depth_Upper==0&Edge==0)=Depth_BL_Upper(Depth_Upper==0&Edge==0);%to accelerate the program, fill the regions except the edges by using bilinear interpolation 
[Lx,Ly]=find(Depth_Upper==0);% find the locations of the edges
Invalid_L=find(Lx<=wins|Lx>dstRow-wins|Ly<=wins|Ly>dstCol-wins);
Lx(Invalid_L)=[];Ly(Invalid_L)=[];
index  = sub2ind(size(Depth_Upper), Lx, Ly);  
RGB_index=RGB_Upper([index index+dstRow*dstCol index+2*dstRow*dstCol]);
B=zeros(size(index));
A=B;
for i=-wins:wins
    for j=-wins:wins
        index_neighbour  = sub2ind(size(Depth_Upper), Lx+i, Ly+j); % neighbouring locations of the to be interpolated point 
        Depth_index_neighbour =Depth_Upper(index_neighbour);
        RGB_index_neighbour=RGB_Upper([index_neighbour index_neighbour+dstRow*dstCol index_neighbour+2*dstRow*dstCol]);% R, G, B channels of the neighbouring locations
        Dis=(sum((RGB_index-RGB_index_neighbour).^2,2)./sigma_c+repmat((i^2+j^2)/sigma_d,size(index))).*(Depth_index_neighbour~=0);%color distance + spatial distance
        Dis(Dis==0)=Inf;
        kernel=exp(-Dis); %Gaussian kernels
        B=B+kernel;
        A=A+kernel.*Depth_index_neighbour;
    end
end
Depth_index=A./B;
Depth_Upper(index)=Depth_index;
Depth_Upper(Depth_Upper==0)=Depth_BL_Upper(Depth_Upper==0);
Depth_Upper(isnan(Depth_Upper))=Depth_BL_Upper(isnan(Depth_Upper));


        
