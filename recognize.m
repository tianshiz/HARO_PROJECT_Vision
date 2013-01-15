function matched_classes=recognize(descriptors)
%this function takes the descriptor and matches it against the existing
%models.
global gforest
global gvocab
 if(gforest.numData~=size(gvocab,2))
                    gforest= vl_kdtreebuild(double(gvocab)) ;
            end
%increment counter


[q,vocab_tot]=size(gvocab);
%make a comparison with the global forest
[index dist]=vl_kdtreequery(gforest,double(gvocab),double(descriptors),'MAXNUMCOMPARISONS',50);

%gets the frequency that each vocab is in the descriptors
[f,x]=hist(index,1:1:vocab_tot); %p is 1x100
area=trapz(x,f); %area under the curve
%normalizes histogram count
%the histogram is as large as the vocab in row size but keeps a
%count of how many times each word in the vocab is used in the
%sift_descriptors. To make the image size not interfere, we
%normalize this data so the sum of the histogram values=1
normalized_f=f/area;
bar(x,normalized_f);
%1 x sy
[sx sy]=size(normalized_f);
normalized_f=padarray(transpose(normalized_f),0,'post');
    normalized_f=sparse(normalized_f); %sparse matrix saves ALOT of space

matched_classes={};  %cell

%with our histograms, we feed our svm models. we can either feed all of
%them and get the one with the largest value or have it be a two step
%process. For now we stick with the one step process
d = dir('../class_mats');
isub = [d(:).isdir]; %# returns logical vector
nameFolds = {d(isub).name}';
nameFolds(ismember(nameFolds,{'.','..','proto'})) = [];


width=size(nameFolds,1);
result=[];
largest_name='';
largest_val=0;
for i=1:width
 
    folder='../class_mats/';
  path=strcat(strcat(folder,nameFolds{i}),'.mat');
  if exist(path,'file')~=2
      continue;
  end
    loadclass(strcat(strcat(folder,nameFolds{i}),'.mat'))
    
    result(i)=svmeval(normalized_f)
    
    if(i>1)
        if(largest_val<result(i))
            largest_name=nameFolds{i};
            largest_val=result(i);
        end
        
    else
        largest_name=nameFolds{i};
        largest_val=result(i);
    end
end
%we save the class names in a cell
 largest_val
matched_classes=largest_name
%if ret is positive, there a good chance that it matches
end
