prompt = 'Which model would you like to use? \nEnter 1 for HDS, 2 for F-HDS, 3 for C-HDS, 4 for FC-HDS: ';
model = input(prompt);
switch model
    case 1
        str='result_HDS';
        mkdir ..\result_HDS;
    case 2
        str='result_F-HDS';
        mkdir ..\result_F-HDS;
    case 3
        str='result_C-HDS';
        mkdir ..\result_C-HDS;
    case 4
        str='result_FC-HDS';
        mkdir ..\result_FC-HDS;
    otherwise
        disp('The input should be one of 1, 2, 3, 4!');
        return;
end

win=1;%window radius for edge detection
wins=2;%window radius for interpolation
th_edge=5;%depth threshold for edge detection
th_class=5;%depth threshold for classification
th_mem=0.6;%membership threshold for classification
alpha=0.9;%preset constant for classification
sigma_c=300;% sigmas are parameters of Gaussian kernels
sigma_f2=1000;
sigma_d=2*wins^2;
net=vgg16;

RGB_file_path =  'E:\E\database\Upsample_2006\RGB image\';%path of RGB images
Depth_file_path =  'E:\E\database\Upsample_2006\Depth\';%path of depth maps
img_list = dir(strcat(RGB_file_path,'*.png'));%image list
img_num = length(img_list);%number of images
if img_num > 0 
    for i = 1:img_num 
        image_name = img_list(i).name;%name of images 
        image_name_short=image_name(1:end-4);
        RGB = imread(strcat(RGB_file_path,image_name));
        Depth = double(imread(strcat(Depth_file_path,image_name_short,'.bmp')));
        Fea_Map2_Pre=activations(net,RGB,'conv1_1');%shallow feature maps for shallow feature extraction
        [srcRow,srcCol,~]=size(RGB);%high resolution size
        for xx=1:4
            r=2^xx;%upsampling scale
            dstRow=floor((srcRow-1)/r)+1;%low resolution size
            dstCol=floor((srcCol-1)/r)+1;
            mm=floor((srcRow-r*(dstRow-1)-1)/2)+1;
            nn=floor((srcCol-r*(dstCol-1)-1)/2)+1;
            Depth_IM=Depth(mm:r:end,nn:r:end);
            Depth_BL=imresize(Depth_IM,[srcRow srcCol],'bilinear');%simple bilinear interpolation
            iter=0;
            tic;
            
            if model==2 || model==4 % for F-HDS and FC-HDS model
            Fea_Map1_Pre=double(rgb2gray(RGB(mm:mm+r*(dstRow-1)+1,nn:nn+r*(dstCol-1)+1,:)));%multi-layer feature extraction for multi-layer feature extraction
                switch xx
                    case 1
                        Fea_Map1_1=FindFea1(Fea_Map1_Pre);
                    case 2
                        [Fea_Map1_1,Fea_Map1_2]=FindFea2(Fea_Map1_Pre);
                    case 3
                        [Fea_Map1_1,Fea_Map1_2,Fea_Map1_3]=FindFea3(Fea_Map1_Pre);
                    case 4
                        [Fea_Map1_1,Fea_Map1_2,Fea_Map1_3,Fea_Map1_4]=FindFea4(Fea_Map1_Pre);
                end
            end
            while iter<=xx-1
                iter=iter+1;%layers of the pyramid strategy
                l=xx-iter+1;
                RGB_l=double(RGB(mm:2^(l-1):mm+r*(dstRow-1)+1,nn:2^(l-1):nn+r*(dstCol-1)+1,:));%RGB image down-sampling to get the RGB image in the upper layer
                if model==1 || model==3 %for HDS and C-HDS model
                    Depth_IM=EachLayer(Depth_IM,RGB_l,win,wins,th_edge,th_class,th_mem,alpha,sigma_c,sigma_d,model);%processing of each layer
                else % for F-HDS and FC-HDS model
                    sigma_f1=2*(12^l)^2;
                    Fea_Map1_l=eval(strcat('Fea_Map1_',num2str(l)));%shallow feature maps in the upper layer
                    Fea_Map2_l=Fea_Map2_Pre(mm:2^(l-1):mm+r*(dstRow-1)+1,nn:2^(l-1):nn+r*(dstCol-1)+1,:);%multi-layer feature maps in the upper layer
                    Depth_IM=EachLayer_Feature(Depth_IM,RGB_l,Fea_Map1_l,Fea_Map2_l,win,wins,th_edge,th_class,th_mem,alpha,sigma_f2,sigma_f1,sigma_f2,sigma_d,model);%processing of each layer
                end
            end
            ti=toc;
            Depth_HR=zeros(srcRow,srcCol);
            Depth_HR(mm:mm+size(Depth_IM,1)-1,nn:nn+size(Depth_IM,2)-1)=Depth_IM;
            Depth_HR(Depth_HR==0)=Depth_BL(Depth_HR==0);
            imwrite(uint8(Depth_HR),strcat('..\',str,'\',image_name_short,'_',num2str(r),'.bmp'));
        end
    end
else
    disp('Please check the path of the dataset!');
end


