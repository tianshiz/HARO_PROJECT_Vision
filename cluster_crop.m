function[cluster_matrix]=cluster_crop(m)
%m is just a binary map, we just need one of the 3 layers, they are all the
%same
m=m(:,:,1);
[rnum,cnum]=size(m)
%BLUR the image within 5% of rnum
pixel_dif=1;
%find all clusters
[L num]=bwlabel(m([1:pixel_dif:rnum],[1:pixel_dif:cnum]),4);
%go through each cluster, insert into separate matrix
num
max_cluster=0;
max_cluster_num=0;
container=zeros(rnum,cnum);
%loop through all cluster in matrix
for a=1:num
    %find location of the cluster
    [r, c]=find(L==a);
    %cluster_dim(a)=[r c];
    %get min column and row values
    % rmin=min(r)-1;
    %cmin=min(c)-1;
    %  r=r-rmin;
    % c=c-cmin;
    
    %gets size of cluster
    [s v]=size(r);
   % s=s+(pixel_dif-1)*s;
  %  v=v+(pixel_dif-1)*v;
    %maintains max cluster
    if s>max_cluster_num
        
        %insert n 0 columns between each columns and fill in 1's wnere they
        %are sandwiched by ones
        
%         for i=1:pixel_dif:cnum
%             
%             pix_holder=pixel_dif-1;
%             %row filler for each pixel
%           
%             while pix_holder>=1
%    
%               r(i+pix_holder)=1;
%               pix_holder=pix_holder-1;
%             end
%         end
        max_cluster_num=s;
        max_cluster=a;
        last_container=container; %saves previous container
        container=zeros(rnum,cnum);
        for b=1:s    
            for i=1:pixel_dif
                if((c(b)+i-1)<cnum)
                 container(r(b),c(b)+i-1)=1;
                end
            end
        end
        
        for b=1:v   
            for i=1:pixel_dif
                if((r(b)+i-1)<rnum)
                 container(r(b)+i-1,c(b))=1;
                end
            end
        end
    end
    %all clusters are separated
    
    %get centroid, by summing all columns and divide by col number
    %centroid(a)=sum(container(:,:,a),2)/s;
end
%merge largest and 2nd largest container
[ab bc]=size(container);
for i=1:ab
    for j=1:bc
        if(last_container(i,j)==1)
        container(i,j)=1;
        end
    end
end

[row col]=size(container);
%only rows and columns that have any 1's should be filled
container(any(container==1,2),any(container==1))=1;
cluster_matrix=container(:,:);
%determine if any clusters can be combined
%centroid euclidean distance is within 5%(flexible) of rnum
%minin=.05*rnum;
%centroid of the max cluster
%max_centroid=centroid(max_cluster);
%find distance of all clusters from max_centroid, those with min dists are
%added
%centroid_dist=fix(abs(centroid-max_centroid)-minin);
%centroid_dist(all(centroid_dist))=[];
%cluster_add=size(centroid_dist);




end