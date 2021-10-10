function bwimg1=PyraUpsampleClass_Feature(bwimg,bwimg1,Io1_1,Io2_1,de,win,wins,th,alf,alf0)
alf1=(2*wins*(de+1))^2; 
[dstWidth1,dstHeight1]=size(bwimg1);
wo=2*win+1;
bwimgx=zeros(dstWidth1,dstHeight1,wo^2-1);
BC=imresize(bwimg,[dstWidth1 dstHeight1],'bilinear');
iter=0;th1=5;
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
Dis=zeros(size(lc,1),wo^2-1);iter=0;BWX=Dis;
for i=-wins:wins
    for j=-wins:wins
        if ~(i==0 && j==0)
            iter=iter+1; 
            lcx  = sub2ind(size(bwimg1), la+i, lb+j);  
            bwx =bwimg1(lcx);
            Blcx=repmat(lcx,1,size(Io1_1,3));
            Ixx=Io1_1(Alc+Blcx);
            Ixx2=Io2_1(Alc+Blcx);
            Dis0=(sum((Ix2-Ixx2).^2,2)./alf0+sum((Ix-Ixx).^2,2)./alf+repmat((i^2+j^2)/alf1,size(lc))).*(bwx~=0);
            Dis0(Dis0==0)=Inf;
            Dis(:,iter)=Dis0;
            BWX(:,iter)=bwx;
        end
    end
end
BWX1=sort(BWX,2);
bwimgf=zeros(size(BWX,1),1);
for i=1:size(BWX1,1)
    cla=1;Cla=zeros(1,size(BWX,2));
    for j=1:size(BWX1,2)-1
        if BWX1(i,j)~=0 && BWX1(i,j+1)-BWX1(i,j)>th1
             cur=BWX1(i,j);
             Cla(1,BWX(i,:)~=0&BWX(i,:)<=cur&Cla(1,:)==0)=cla;
             cla=cla+1;
        end
    end
    if cla==1
         Cla(1,BWX(i,:)~=0)=cla;
    else
         Cla(1,BWX(i,:)>cur&Cla(1,:)==0)=cla;
    end
    dis=BWX(i,BWX(i,:)~=0);
    weight=dis.^(-1);
    sw=sum(weight,2);
    Lab=Cla(1,Cla(1,:)~=0);
    M=zeros(1,cla);
    for z=1:cla
        M(z)=sum(weight(Lab==z),'all')/sw;
    end
    [Mem,La]=max(M);
    if Mem<0.8
        Omega=0.5;
    else
        Omega=0.9;
    end
    Dis1=exp(-Dis(i,Cla(1,:)==La))*Omega;
    Dis2=exp(-Dis(i,Cla(1,:)~=La&Cla(1,:)~=0))*(1-Omega);
    MDis1=Dis1.*BWX(i,Cla(1,:)==La);
    MDis2=Dis2.*BWX(i,Cla(1,:)~=La&Cla(1,:)~=0);
    B=sum(Dis1,2)+sum(Dis2,2);
    A=sum(MDis1,2)+sum(MDis2,2);
    bwimgf(i)=A./B;
end
bwimg1(lc)=bwimgf;
bwimg1(bwimg1==0)=BC(bwimg1==0);
bwimg1(isnan(bwimg1))=BC(isnan(bwimg1));



        
