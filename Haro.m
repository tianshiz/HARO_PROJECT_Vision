function  Haro(I)
%main function for Haro's object recognition algorithm, takes an image

%addpath('/home/le/Dropbox/HARO PROJECT/libsvm-3.12/matlab')

%we have two approaches for dealing with forest and vocab. We use a
%universal tree and vocab list for when Haro doesn't know much(under 50000
%vocab). But when Haro already knows a lot we instead make the process a
%two leveled process
global gvocab
global gvocab_half
global gvocab_quarter
%50000 is 200words per image, 10 image per class and 25 classes. Not m
if (size(dir('../classes/'),1)>25)
   
    %create a gvocab composed of representative images from each class,
    %depending on how large the class is
    %the exact amount is up to debate
else   


%gvocab stores the total vocab of the bot, check if its been loaded yet
%a vocab is a kmeans of the sift descriptors that makes it 128xnumber of
%vocab

if (size(gvocab,1)==0)
    load('vocab.mat','vocab','vocab_half','vocab_quarter');
    if(size(vocab,1)==0) %nothing in vocab.mat
        known_vocab=zeros(128,0); %create a blank
    else
        known_vocab=vocab;
        gvocab=known_vocab;
        gvocab_half=vocab_half;
        gvocab_quarter=vocab_quarter;
    end
else
    known_vocab=gvocab; %gvocab is updated in learning_loop

end


%makes a global forest with existing vocab
global gforest
global gforest_half
global gforest_quarter

if(size(gforest,1)==0) %not defined yet, create tree
    if(  size(known_vocab)~=0)
        gforest= vl_kdtreebuild(double(known_vocab)) ;
        gforest_half=vl_kdtreebuild(double(gvocab_half)) ;
        gforest_quarter=vl_kdtreebuild(double(gvocab_quarter)) ;
    end
end


%known_vocab=zeros(128,0); %known vocabs need to be extracted somehow before haro starts
%forest = vl_kdtreebuild(double(known_vocab)) ; %original forest
end

global vid


%take snapshot
% vid.ReturnedColorSpace='rgb';


%I = getsnapshot(vid);
I= imresize(I,[240 320]);

%apply saliency map and crop out useless parts
I=gbvs_run(I,2);
if(~isempty(I))
   

%new HSMK puts in difference resolution
Ih=imresize(I,.5);
Iq=imresize(I,.25);
%imshow(I)
%takes dense SIFT, much faster than SIFT
[f,d]=vl_dsift(I,'size',4,'step',8);
[f,dh]=vl_dsift(Ih,'size',4,'step',8);
[f,dq]=vl_dsift(Iq,'size',4,'step',8);
%known_vocab=zeros(128,0);


%--------------------------
%SHORT TERM MEMORY
%here Haro should be storing the memory of this image locally
%so that it would not attempt to learn the same object over and over
%-------------

global multiple_descriptor
global multiple_descriptor_half
global multiple_descriptor_quarter
global images

[t images_size]=size(images);
if (images_size==0)
    images{1}=I;
else
    %append to images
    [b a]=size(images);
    a=a+1;
    images{a}=I;
    
end
[t desc_size]=size(multiple_descriptor);
 duplicate=0;
if(desc_size==0)
    multiple_descriptor{1}=d;
    multiple_descriptor_half{1}=dh;
    multiple_descriptor_quarter{1}=dq;
else
    [b a]=size(multiple_descriptor);
    columns=size(d,2)
    %check if descriptor is too similar to the previous saved ones, we dont want exact or close to exact duplicates
    
   
    for d_check=1:a
        %see if the current image matches the image in loop in terms of
        %size. identical images all have the same dimension due to how
        %awesome the saliency toolbox is
        if(size(images{d_check})==size(images{a}))
            [match, score]=vl_ubcmatch(d,multiple_descriptor{d_check});
            %match 60 out of 128 descriptors or have a mean score less than
            %40,000
            if((size(match,2))>60 || mean(score)<40000)
                duplicate=1;
                size(match,2);
            
                mean(score);
                'duplicate'
                break;
            else
                size(match,2);
                
                mean(score);
            end
        end
    end
    if(duplicate)
        %remove from images
        images(a)=[];
     
    
        
    else
     
        a=a+1;
        multiple_descriptor{a}=d;
        %more HSMK
        multiple_descriptor_half{a}=dh;
        multiple_descriptor_quarter{a}=dq;
    end
    
    
end

%loop through multiple_descriptors, if no match, put in multiple descriptor
%if match, then return the label of the matched object. Basically we can
%skip the recognition process altogether. Multiple_descriptors must n
%----------------------------
%RECOGNITION
%Recognition works by taking the sift descriptors and doing a kdtree query
%with the existing forest. The resulting histogram is then fed to the svm
%to do a match. If there is a match we output the class matched
%-----------------------------
%if(~duplicate && size(gforest,1)==0) %only run recognition if not a duplicate
   matched_classes=recognize(d)
%end
%--------------------------
%LONG TERM MEMORY
%this function checks if Haro knows the object, if not it learns it
%regardless, it saves the image and adds it to a class
%here d stores image
matched_classes=[];
%this should be called only when there are enough images saved
[a s]=size(multiple_descriptor);
%if(s>50 && duplicate==0)
 %normalized_f=learning_loop(multiple_descriptor,known_vocab,matched_classes,images);
%end

%-------
%Here Haro sorts all the singular classes and groups those that are similar

%sort_classes();
end

end