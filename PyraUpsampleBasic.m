function bwimg1=PyraUpsampleBasic(bwimg,bwimg1,Io1_1,de,win,wins,th)
alf1=(2*wins*(de+1))^2; 
alf=100;
[dstWidth1,dstHeight1]=size(bwimg1);
wo=2*win+1;
bwimgx=zeros(dstWidth1,dstHeight1,wo^2);
BC=imresize(bwimg,[dstWidth1 dstHeight1],'bilinear');
iter=0;
for i=-win:win  
    for j=-win:win
        iter=iter+1;
        bwimgx(win+1:dstWidth1-win,win+1:dstHeight1-win,iter)=abs(BC(win+1:dstWidth1-win,win+1:dstHeight1-win)-BC(win+1+i:dstWidth1-win+i,win+1+j:dstHeight1-win+j));
    end
end
BCe=max(bwimgx,[],3)>th;
bwimg1(bwimg1==0&BCe==0)=BC(bwimg1==0&BCe==0);
[la,lb]=find(bwimg1==0);
lab=find(la<=wins|la>dstWidth1-wins|lb<=wins|lb>dstHeight1-wins);
la(lab)=[];lb(lab)=[];
lc  = sub2ind(size(bwimg1), la, lb);  
Ix=Io1_1([lc lc+dstWidth1*dstHeight1 lc+2*dstWidth1*dstHeight1]);
B=zeros(size(lc));
A=B;
for i=-wins:wins
    for j=-wins:wins
        lcx  = sub2ind(size(bwimg1), la+i, lb+j);  
        bwx =bwimg1(lcx);
        Ixx=Io1_1([lcx lcx+dstWidth1*dstHeight1 lcx+2*dstWidth1*dstHeight1]);
        Dis=(sum((Ix-Ixx).^2,2)./alf+repmat((i^2+j^2)/alf1,size(lc))).*(bwx~=0);
        Dis(Dis==0)=Inf;
        XX=exp(-Dis); 
        B=B+XX;
        A=A+XX.*bwx;
    end
end
bwimgf=A./B;
bwimg1(lc)=bwimgf;
bwimg1(bwimg1==0)=BC(bwimg1==0);


        
