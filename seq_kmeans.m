function gcluster=seq_kmeans(vectors,k,g)
%gets the sequential kmeans using kmeans++ init
%g is 0 or 1, 0 if no existing cluster exist to build on. 1 means there is
%already a cluster
%k is the number of clusters 
%first convert vectors, which is a cekk so that all matrices are concat
%together as a single matrix
vs=size(vectors,2);
combv=[];

for i=1:vs
    combv=[combv vectors{i}];
end

vectors=combv;
%if gcluster is empty, we do a blank kmeans and randomly pick values
if(g==0)

    centers=[];
    %mi is the mean of all vectors in cluster i
    %given the vectors, we first find the initial guesses for k centroids
    r=randperm(size(vectors,2)); %gets random listing of vectors
    r=r(1) ; %gets the first random center
    
    centers(:,1)=vectors(:,r);
    nearest=centers(:,1); %intially only and thus nearest
    tree=vl_kdtreebuild(centers);
    
    for i=1:k
       
        %For each data point x, compute D(x), the distance between x and the
        %nearest center that has already been chosen.
        sv=size(vectors,2); %get num of columns
        D=zeros(1,sv);
        for j=1:sv
            %we use kdtree query to find NN so we only have to ubcmatch once
            [index dist]=vl_kdtreequery(tree,double(centers),double(vectors(:,j)),'MAXNUMCOMPARISONS',50);
            
            [MATCHES,SCORES] =vl_ubcmatch(uint8(vectors(:,j)),uint8(centers(:,index)));
            D(j)=SCORES^2; %D^2
        end
        
        %after all points are iterated, we then pick a new center based on
        %probability proportional to D(x)^2
        cum=zeros(1,sv);
        sum=0;
        %add all D's, so each cum(j) is a proportional size sample
        for j=1:sv
            cum(j)=D(j)+sum;
            sum=cum(j);
        end
        %we have a sample size one, so just get a random number 1:sum
        rand_num=round(rand()*sum);
        %find cum that is nearest and greater than rand_num
        nearest=sum;
        newk=1;
        for j=1:sv
            if(cum(j)>rand_num && nearest>cum(j))
                nearest=cum(j);
                newk=j;
            end
            
        end
        %at this point we have chosen new k
        centers(:,i)=vectors(:,newk);
        tree=vl_kdtreebuild(centers); %rebuild tree
    end
    %proceed with normal kmeans, now we have all of our centers
    
    %counts for n init
    n=zeros(1,k);
else
   
    %gcluster is set so we must get the saved n array
    load('seqkmeans.mat','gnarray', 'gcluster');
    n=gnarray;
    centers=gcluster;
    tree=vl_kdtreebuild(centers); %rebuild tree

    sv=size(vectors,2);
  
end %end isempty(gcluster)

for i=1:sv
    %go through vectors one at a time, use tree to query NN
    size(vectors(:,i));
    [index dist]=vl_kdtreequery(tree,double(centers),double(vectors(:,i)),'MAXNUMCOMPARISONS',50);
    n(index)=n(index)+1; %incre ni
    %refer to formulate on http://www.cs.princeton.edu/courses/archive/fall08/cos436/Duda/C/sk_means.htm
    diff=(uint8(vectors(:,i))-uint8(centers(:,index)));
    
    in=1./(uint8(n(index))*(uint8(index)));
  
    centers(:,index)=uint8(centers(:,index))+in*diff;
%     if(index==1)
%         c=[0 ,0, 1];
%     elseif(index==2)
%         c=[0, 1 ,0];
%     elseif(index==3)
%         c=[0, 1, 1];
%     else
%    c=[1,0,0]
%     end
%     scatter(vectors(1,i),vectors(2,i),4,c)
%     hold on;
end
gcluster=centers;
gnarray=n;

%scatter(centers(1,:),centers(2,:),6,'+')
save('seqkmeans.mat','gnarray', 'gcluster');
end