function [hsum0, hsum1,hsum2]=similar(class_namex,class_namey,forest,vocab,root,root2)
%this function computes the pyramid matching kernel and returns K, the more
%positive the more similar. For now we have total 3 levels in the pyramid.
%Histx and histy are both single rowed vectors


% if (size(gvocab,1)==0)
%     load('vocab.mat','vocab');  
%         gvocab=vocab;
%    'loaded'
% end
class_namex;
class_namey;
sum0=0;
sum1=0;
sum2=0;
hsum0=0;
hsum1=0;
hsum2=0;
[q,vocab_tot]=size(vocab);
%make a comparison with the global forest
im=fullfile(vl_root,root,strcat(class_namex,'.jpg'));
im=imread(im);
if ( max(im(:)) > 2 ) im = double(im) / 255;
end
t=size(size(im));
if t(1,2)==3
    imshow(im)
    im=single(rgb2gray(im));
else
    
    
    im=single(im);
end
im=single(im);
im2=fullfile(vl_root,root2,strcat(class_namey,'.jpg'));
im2=imread(im2);
if ( max(im2(:)) > 2 ) im2 = double(im2) / 255;
end
t=size(size(im2));
if t(1,2)==3
    imshow(im2)
    im2=single(rgb2gray(im2));
else
    
    
    im2=single(im2);
end

im2=single(im2);
%i4G3fxbeZkScvEewRKa1Bq8jB
%jQ1qkr1W4zGpyb6WXPRvzpWJShistA=histA/area;

[width,length]=size(im); %get dimension of image
[width2,length2]=size(im2); %get dimension of image

%L=0, get element-wise minimum for each element and then sum the total
%sum0=sum(min(histx,histy));

%L=1, break up image into 4 grids, compute 4 histograms, then add them
%together. All the images that apply to these singular classes are in
%/classes/proto
pyramidA={};
pyramidB={};

%2nd level more coarse pyramid
pyramidA2={};
pyramidB2={};
for l=2:-1:0
    
    grid_num=4^l; %number of grids depending on l
    
    %4 blocks
    tot=1;
    totw=1;
    tot2=1;
    totw2=1;
    histA=[];
    histB=[];
    if(l==2)
        for block=1:grid_num
            
            if(mod(block,(2*l))~=0) %last block in row if 0
                xvals=(totw:round(width/(2*l)*(totw-1+width/(2*l))/(width/(2*l)))); %row doesn't change for 2*l blocks
                yvals=(tot:round(length/(2*l)*(tot-1+length/(2*l))/(length/(2*l))));
                
                tot=tot+round(length/(2*l));%increment starting point
                
                %duplicate for 2nd image
                xvals2=(totw2:round(width2/(2*l)*(totw2-1+width2/(2*l))/(width2/(2*l)))); %row doesn't change for 2*l blocks
                yvals2=(tot2:round(length2/(2*l)*(tot2-1+length2/(2*l))/(length2/(2*l))));
                
                tot2=tot2+round(length2/(2*l));%increment starting point
                
                
            else
                xvals=(totw:round(width/(2*l)*(totw-1+width/(2*l))/(width/(2*l))));
                totw=totw+round(width/(2*l)); %update totw to increment
                yvals=(tot:round(length/(2*l)*(tot-1+length/(2*l))/(length/(2*l))));
                tot=1; %reset tot for horizontal travel
                
                
                xvals2=(totw2:round(width2/(2*l)*(totw2-1+width2/(2*l))/(width2/(2*l))));
                totw2=totw2+round(width2/(2*l)); %update totw to increment
                yvals2=(tot2:round(length2/(2*l)*(tot2-1+length2/(2*l))/(length2/(2*l))));
                tot2=1; %reset tot for horizontal travel
            end
            
            
            %trim off else
            I=im;
            I2=im2;%values that are out of bounds, this will happen due to rounding above
            [a b]=size(xvals);
            while(xvals(b)>=width)
                xvals(b)=[];
                [a b]=size(xvals);
            end
            
            % %
            [a b]=size(yvals);
            while(yvals(b)>=length)
                yvals(b)=[];
                [a b]=size(yvals);
            end
            
            %duplicate
            %trim off values that are out of bounds, this will happen due to rounding above
            [a b]=size(xvals2);
            while(xvals2(b)>=width2)
                xvals2(b)=[];
                [a b]=size(xvals2);
            end
            
            % %
            [a b]=size(yvals2);
            while(yvals2(b)>=length2)
                yvals2(b)=[];
                [a b]=size(yvals2);
            end
            if(l==2)
                % subplot(4,4,block);imshow(im(xvals,yvals))
            end
            %figure,imshow(im(xvals,yvals))
            I=im(xvals,yvals);
            I2=im2(xvals2,yvals2);
            
            
            %get sift descriptors
            [f,d]=vl_dsift(I,'size',4,'step',8);
            %tree and vocab dont match in dimension
%             if(size(gforest,1)==0) %not defined yet, create tree
%                 if(  size(gvocab,2)~=0)
%                     gforest= vl_kdtreebuild(double(gvocab)) ;
%                 end
%                 'insideforest'
%             elseif(gforest.numData~=size(gvocab,2))
%                 gforest= vl_kdtreebuild(double(gvocab)) ;
%                 'in forest again'
%             end


            [index dist]=vl_kdtreequery(forest,double(vocab),double(d),'MAXNUMCOMPARISONS',50);
          
            [f,x]=hist(index,1:1:vocab_tot); %p is 1x100
            ar=trapz(x,f); %area under the curve
            %normalizes histogram counte
            %normalize this data so the sum of the histogram values=1
            normalized_f=f/ar;
            %1 x sy
            [sx sy]=size(normalized_f);
            %pad nothing, we still need the transpose however
            normalized_f=padarray(transpose(normalized_f),0,'post');
            normalized_f=sparse(normalized_f); %sparse matrix saves ALOT of space
            
            pyramidA{block}=normalized_f;
            
            %histA=vertcat(histA,normalized_f); %concat hist together
            histA=normalized_f;
            %get sift descriptors
            I2=single(I2);
            [f,d]=vl_dsift(I2,'size',4,'step',8);
            
            
            [index dist]=vl_kdtreequery(forest,double(vocab),double(d),'MAXNUMCOMPARISONS',50);
            [f,x]=hist(index,1:1:vocab_tot); %p is 1x100
            ar=trapz(x,f); %area under the curve
            %normalizes histogram counte
            %normalize this data so the sum of the histogram values=1
            normalized_f=f/ar;
            % sum(normalized_f)
            %1 x sy
            [sx sy]=size(normalized_f);
            normalized_f=padarray(transpose(normalized_f),0,'post');
            normalized_f=sparse(normalized_f); %sparse matrix saves ALOT of space
            
            pyramidB{block}=normalized_f;
            
            
            %histB=vertcat(histB,normalized_f); %concat hist together
            histB=normalized_f;
             sum2=sum2+sum(min(histA,histB));
            hsum2=hsum2+sum2/sqrt(sum(min(histA,histA))*sum(min(histB,histB)));
        end
        %finest sum gets the least weight, 16 parts
       
    end
    x=[1:sy]';
    if(l==1)
        %we take the 16 histogram parts and make them into 4 by adding them
        pyramidA2{1}=pyramidA{1}+pyramidA{2}+pyramidA{5}+pyramidA{6}; %top left
        pyramidA2{2}=pyramidA{3}+pyramidA{4}+pyramidA{7}+pyramidA{8};  %top right
        pyramidA2{3}=pyramidA{9}+pyramidA{10}+pyramidA{13}+pyramidA{14}; %bot left
        pyramidA2{4}=pyramidA{11}+pyramidA{12}+pyramidA{15}+pyramidA{16}; %bot right
        
        pyramidA2{1}=pyramidA2{1}/trapz(x,pyramidA2{1});
        pyramidA2{2}=pyramidA2{2}/trapz(x,pyramidA2{2});
        pyramidA2{3}=pyramidA2{3}/trapz(x,pyramidA2{3});
        pyramidA2{4}=pyramidA2{4}/trapz(x,pyramidA2{4});
   
        
        %we take the 16 histogram parts and make them into 4 by adding them
        pyramidB2{1}=pyramidB{1}+pyramidB{2}+pyramidB{5}+pyramidB{6}; %top left
        pyramidB2{2}=pyramidB{3}+pyramidB{4}+pyramidB{7}+pyramidB{8};  %top right
        pyramidB2{3}=pyramidB{9}+pyramidB{10}+pyramidB{13}+pyramidB{14}; %bot left
        pyramidB2{4}=pyramidB{11}+pyramidB{12}+pyramidB{15}+pyramidB{16}; %bot right
        
        pyramidB2{1}=pyramidB2{1}/trapz(x,pyramidB2{1});
        pyramidB2{2}=pyramidB2{2}/trapz(x,pyramidB2{2});
        pyramidB2{3}=pyramidB2{3}/trapz(x,pyramidB2{3});
        pyramidB2{4}=pyramidB2{4}/trapz(x,pyramidB2{4});
        
        
        for i=1:4
             histA=pyramidA2{i};
             histB=pyramidB2{1};
             
                %get the intercept
            sum1=sum1+sum(min(histA,histB));
            hsum1=hsum1+sum1/sqrt(sum(min(histA,histA))*sum(min(histB,histB)));

        end
%         %vertcat the 4 histograms
%         histA=vertcat(histA, pyramidA2{1});
%         histA=vertcat(histA, pyramidA2{2});
%         histA=vertcat(histA, pyramidA2{3});
%         histA=vertcat(histA, pyramidA2{4});
%         %vertcat the 4 histograms
%         histB=vertcat(histB, pyramidB2{1});
%         histB=vertcat(histB, pyramidB2{2});
%         histB=vertcat(histB, pyramidB2{3});
%         histB=vertcat(histB, pyramidB2{4});
%         %get the intercept
%         sum1=sum(min(histA,histB))
%         hsum1=sum1/sqrt(sum(min(histA,histA))*sum(min(histB,histB)))
        
    elseif(l==0)
        %we take pyramid2 with the 4 parts and mold it into one
        histA=pyramidA2{1}+pyramidA2{2}+pyramidA2{3}+pyramidA2{4};
        histB=pyramidB2{1}+pyramidB2{2}+pyramidB2{3}+pyramidB2{4};
        histA=histA/trapz(x,histA);
        histB=histB/trapz(x,histB);
        %coarsest gets least weight
        sum0=sum(min(histA,histB));
        hsum0=sum0/sqrt(sum(min(histA,histA))*sum(min(histB,histB)));
    end
    
end
%weighted sum
%weight=1/2^(2-l), the upper level gets greater weight
K=sum0*(1/2^(2))+sum1*(1/2^(2-1))+sum2*(1/2^(2-2));
%add hsum in each R for each l, then divide by 1/(R+1)  to get sumx

end
