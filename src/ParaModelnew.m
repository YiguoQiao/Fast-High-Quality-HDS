RGB_file_path =  '..\datasets\RGB image\';% 
Depth_file_path =  '..\datasets\Depth\';% 
img_path_list = dir(strcat(RGB_file_path,'*.png'));%
img_num = length(img_path_list);%
win=1;wins=2;th=5;
net=vgg16;
if img_num > 0 %
    for i = 1:img_num %
        image_name = img_path_list(i).name;% 
        image_name_short=image_name(1:end-4);
        he = imread(strcat(RGB_file_path,image_name));
        D = imread(strcat(Depth_file_path,image_name_short,'.bmp'));
        bwimg0=double(D)/255;
        [srcWidth,srcHeight,~]=size(he);
        for xx=1:4
            r=2^xx;
            dstWidth=floor((srcWidth-1)/r)+1;
            dstHeight=floor((srcHeight-1)/r)+1;
            mm=floor((srcWidth-r*(dstWidth-1)-1)/2)+1;
            nn=floor((srcHeight-r*(dstHeight-1)-1)/2)+1;
            bwimg=bwimg0(mm:r:end,nn:r:end);
            BC=imresize(bwimg,[srcWidth srcHeight],'bilinear');
            r1=r;iter=0;
            Io2=activations(net,he,'conv1_1');
            tic;
            while iter<=xx-1
                iter=iter+1;
                alf1=0.00001*4^iter;
                alf2=200*iter^0.5;
                alf=1.5*iter^(5);
                l=xx-iter+1;
                Io1_1= he(mm:2^(l-1):end,nn:2^(l-1):end,:) ;
                Io1_1=double(Io1_1);
                Io2_1=Io2(mm:2^(l-1):end,nn:2^(l-1):end,:);
                Io2_1=Io2_1(1:size(Io1_1,1),1:size(Io1_1,2),:);
                [r1,bwimg]=EachLayer(r1,bwimg,Io1_1,xx-iter,win,wins,th,alf);
                %[r1,bwimg]=EachLayer_Feature(r1,bwimg,Io1_1,Io2_1,xx-iter,win,wins,th,alf1,alf2);
            end
            ti=toc;
            W1 =zeros(srcWidth,srcHeight);
            W1(mm:mm+size(bwimg,1)-1,nn:nn+size(bwimg,2)-1)=bwimg;
            W1(W1==0)=BC(W1==0);
            DD=uint8(W1*255);
            imwrite(DD,strcat('..\results\',image_name_short,'_',num2str(r),'.bmp'));
        end
    end
end


