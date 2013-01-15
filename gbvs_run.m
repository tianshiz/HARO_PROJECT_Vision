function [grabcut_obj]=gbvs_run(img,iter)
%function that takes an image matrix input, and splits back cropped most salient image in the input
% make some parameters
tic
params = makeGBVSParams;

% could change params like this
params.contrastwidth = .11;

% example of itti/koch saliency map call
params.useIttiKochInsteadOfGBVS = 1;

% example of calling gbvs() with default params and then displaying result
outW = 500;
%out = {};
% compute saliency maps for some images
%for i = 1 : 5
  
 % img = imread(sprintf('samplepics/%d.jpg',i));
%img=imread('samplepics/3.jpg');
 % tic; 

    % this is how you call gbvs
    % leaving out params reset them to all default values (from
    % algsrc/makeGBVSParams.m)
   % out{i} = gbvs( img );   
  out = gbvs_fast( img );   
 % toc;

  % show result in a pretty way  
  
  s = outW / size(img,2) ; 
  sz = size(img); sz = sz(1:2);
  sz = round( sz * s );

  img = imresize( img , sz , 'bicubic' );  
  orig_img=img;
  saliency_map = imresize( out.master_map , sz , 'bicubic' );
  if ( max(img(:)) > 2 ) img = double(img) / 255; end
%prctile gets the 75 percentile value in each column of saliency_map
  %img_thresholded = img .* repmat( saliency_map >= prctile(saliency_map(:),75) , [ 1 1 size(img,3) ] );  
[img_thresholded]=cluster_crop(repmat( saliency_map >= prctile(saliency_map(:),55) , [ 1 1 size(img,3) ] ));  
  %remove all black blobs
  %img_thresholded(all(all(img_thresholded==0,3),2),:,:)=[];
 % [m n]=size(img_thresholded);
 


[a b]=size(img_thresholded);
top=0;


for i=1:a
    for j=1:b
        if(img_thresholded(i,j)==1)
            %find top left corner of img_thresh
            if(top==0)
            x=j;
            y=i;
            top=1;
            else
            w=j-x;
            h=i-y;
            end
   
        end
    end
end



grabcut_obj=cv.grabCut(orig_img,[x y w h],'MaxIter',iter);



%loop through all values
for i=1:a
    for j=1:b
        if(grabcut_obj(i,j)==0 || grabcut_obj(i,j)==2)
        %possibly bg and bg removed http://www.cs.stonybrook.edu/~kyamagu/mexopencv/matlab/grabCut.html
        grabcut_obj(i,j)=255;
        
        elseif(grabcut_obj(i,j)==3 || grabcut_obj(i,j)==1)
            %possibly fg and fg
            grabcut_obj(i,j)=uint8(orig_img(i,j));    
        end
    end
end
%chop off excess white borders

   grabcut_obj(all(all(grabcut_obj==255,2),2),:)=[];
   
   grabcut_obj(:,all(grabcut_obj==255))=[];

grabcut_obj=im2single(grabcut_obj);
%all 0 pixel
%  t=size(size(grabcut_obj));
%  if t(1,2)==3
%      %imshow(img);
%      % orig_img=single(rgb2gray(orig_img));
%          grabcut_obj=single(rgb2gray(grabcut_obj));
%  else
%      
%    
%   % orig_img=single(orig_img);
%    grabcut_obj=single(grabcut_obj);
%  end


%   object=img.*img_thresholded; 
%   object(all(all(object==0,2),2),:)=[];
%   object(:,all(object==0))=[];
  
 % figure;
% image(orig_img)
%  subplot(1,2,1);
% imshow(object);
%  title('most salient (75%ile) parts');
%   
%  subplot(1,2,2);
% show_imgnmap(img,out);
% title('saliency map overlayed');
  
%   if ( i < 5 )
%     fprintf(1,'Now waiting for user to press enter...\n');
%     pause;
%   end

%end
toc
 end
