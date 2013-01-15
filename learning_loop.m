function normalized_f=learning_loop(sift_descriptors,known_vocab,matched_classes,images)

%this function is called when Haro is idle and when there is a batch
%of new images to learn
%note that even if haro recognizes the image, we still process it so that
%haro can get more samples. match_classes is an array of the id of matched classes
%, 0 if no match. eventually we would need a cap on this
%rooms for improvement: incremental nearest neighbor algorithm
%incremental SVM

global gvocab
global gvocab_quarter
global gvocab_half
symbols = ['a':'z' 'A':'Z' '0':'9'];
stLength = 25;
global multiple_descriptor_half
global multiple_descriptor_quarter

%optimization: makes more sense to quantize all image descriptors

%loop encode
%get dimensions, a is different layer of descriptors for each image
vocab=zeros(128,0);

tic;
if(isempty(known_vocab))
    %quantizes the image desciptor with elkan method, vocab of 600
%large vocab requires large dataset, otherwise the categorization accuracy
%is effected
    vocab=seq_kmeans(sift_descriptors,600,0);
    vocab_half=seq_kmeans(multiple_descriptor_half,600,0);
    vocab_quarter=seq_kmeans(multiple_descriptor_quarter,600,0);
else
   vocab=seq_kmeans(sift_descriptors,600,1);
    vocab_half=seq_kmeans(multiple_descriptor_half,600,1);
    vocab_quarter=seq_kmeans(multiple_descriptor_quarter,600,1);
end
toc

[q,w]=size(vocab);
%the total vocabulary of Haro, definitely huge, but nothing can be done
%except reduce the number of vocab we save, which is something that should
%be done if performance is lacking
vocab_tot=w;
[sizeb,sizea]=size(sift_descriptors);

'past';
%builds kdtree to do a search, this would be slow too, but we reduce it by
%doing batches of sift_descriptors at once
forest = vl_kdtreebuild(double(vocab)) ;



for n=1:sizea
    [index dist]=vl_kdtreequery(forest,double(vocab),double(sift_descriptors{n}),'MAXNUMCOMPARISONS',50);
 
   %here we do a special optimization that is disabled while we have
    %little data points
    %when our dataset gets huge, we would only query a tree composed of
    %"representative" classes. Matching a class here means we will then
    %create another tree(or call the cache) of the the classes under
    %the representative class and then we can carry on as normal.
    %Reference sift_pack.m line 66
    
    %gets the frequency that each vocab is in the descriptors
    [f,x]=hist(index,1:1:vocab_tot); %p is 1x100
    area=trapz(x,f); %area under the curve
    %normalizes histogram count
    %the histogram is as large as the vocab in row size but keeps a
    %count of how many times each word in the vocab is used in the
    %sift_descriptors. To make the image size not interfere, we
    %normalize this data so the sum of the histogram values=1
    normalized_f=f/area;
    %figure;
    %bar(x,normalized_f);
    %1 x sy
    [sx sy]=size(normalized_f);
   % size(vocab)
    %IMPORTANT, we no longer have to pad, since the word limit is set initially
    normalized_f=padarray(transpose(normalized_f),0,'post');
    normalized_f=sparse(normalized_f); %sparse matrix saves ALOT of space
    % random_name=  qu( round(rand(1,50)*numRands2) );
    % round(rand(1,50)*numRands2)
    C=10;
    type=5;
    scale=2;
   
    %training_instance_matrix(n,:)=normalized_f  %normalized_f is what histc returns
    
    %SVM training
    %we check if this is a matched class or not, if the latter:
    
    %check if the matched class
    %random name
    nums = randi(numel(symbols),[1 stLength]);
    random_name = symbols (nums);
    random_name=strcat('a',random_name); %make name start with a letter, struct keys need this
   % [sizeIb,sizeIa]=size(images{n});
    ima=images{n};
    if(size(matched_classes)==0)
        %new class is made, with only one element and no negative. This
        %model cannot be used to evaluate new inputs. Later a process will
        %attempt to combine these singular classes cause there will be many
        %of these. This is because a class with only one element is useless
        %and will not warrant great result, we must wait for more data and
        %then group them accordingly.
        svmtrain(normalized_f,[1]',C,type,scale);
        %save model and histogram involved, rand_name is the name of
        %the class, not each element
        
        %all these class mats are put in the proto folder, not ready to
        %model. The class name is the name of the first object in the class
        saveclass(strcat('../class_mats/proto/',strcat(random_name,'_class.mat')));
      %  negative=normalized_f;    %acts as a negative for future use
      %  neg_ima=ima;
        %save the image into directory
        imwrite(ima,strcat('../classes/proto/',strcat(random_name,'.jpg')),'jpeg');
    else
        loadclass(matched_classes(n));
        eval(['load ' matched_classes(n)]);
   %     svmtrain([normalized_f negative],[1 -1]',C); %trains existing class with a negative
        %check if folder exists, if not create a new class folder and
        %add image into folder
     
        %save the image into directory
        folder=strcat('../classes/',matched_classes(n));
        folder=strcat(folder,'/');
        imwrite(ima,strcat(folder,strcat(random_name,'.jpg')),'jpeg');
        %imwrite(neg_ima,strcat(folder,strcat(random_name,'_neg.jpg')),'jpeg');

    end
    
    
    
end
%clear the globals
clear global multiple_descriptor
clear global multiple_descriptor_half
clear global multiple_descriptor_quarter
clear global images
%save the new vocab total
save('vocab.mat','vocab','vocab_half','vocab_quarter');
gvocab=vocab; %update the global variable
gvocab_half=vocab_half;
gvocab_quarter=vocab_quarter;
end
