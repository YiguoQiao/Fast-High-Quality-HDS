function bwimg1=PyraUpsampleBasic_Feature(bwimg,bwimg1,Io1_1,Io2_1,de,win,wins,th,alf,alf0)
alf1=(2*wins*(de+1))^2; 
[dstWidth1,dstHeight1]=size(bwimg1);
wo=2*win+1;
bwimgx=zeros(dstWidth1,dstHeight1,wo^2-1);
BC=imresize(bwimg,[dstWidth1 dstHeight1],'bilinear');
iter=0;
for i=-win:win  
    for j=-win:win
         if ~(i==0 && j==0)
            iter=iter+1;
            bwimgx(win+1:dstWidth1-win,win+1:dstHeight1-win,iter)= BC(win+1+i:dstWidth1-win+i,win+1+j:dstHeight1-win+j) ;
         end
    end
end
BCe=(max(bwimgx,[],3)-min(bwimgx,[],3))>th|BC==0;
bwimg1(bwimg1==0&BCe==0)=BC(bwimg1==0&BCe==0);
[la,lb]=find(bwimg1==0);
lab=find(la<=wins|la>dstWidth1-wins|lb<=wins|lb>dstHeight1-wins);
la(lab)=[];lb(lab)=[];
lc  = sub2ind(size(bwimg1), la, lb);  
Alc=(0:size(Io1_1,3)-1)*dstWidth1*dstHeight1;
Alc=repmat(Alc,size(lc,1),1);
Blc=repmat(lc,1,size(Io1_1,3));
Ix=Io1_1(Alc+Blc);
Ix2=Io2_1(Alc+Blc);
B=zeros(size(lc));
A=B;
for i=-wins:wins
    for j=-wins:wins
        lcx  = sub2ind(size(bwimg1), la+i, lb+j);  
        bwx =bwimg1(lcx);
        Blcx=repmat(lcx,1,size(Io1_1,3));
        Ixx=Io1_1(Alc+Blcx);
        Ixx2=Io2_1(Alc+Blcx);
        Dis=(sum((Ix2-Ixx2).^2,2)./alf0+sum((Ix-Ixx).^2,2)./alf+repmat((i^2+j^2)/alf1,size(lc))).*(bwx~=0);
        Dis(Dis==0)=Inf;
        XX=exp(-Dis); 
        B=B+XX;
        A=A+XX.*bwx;
    end
end
bwimgf=A./B;
bwimg1(lc)=bwimgf;
bwimg1(bwimg1==0)=BC(bwimg1==0);
bwimg1(isnan(bwimg1))=BC(isnan(bwimg1));


        
