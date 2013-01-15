function folder=sort_existing_classes()
%this function sorts existing established classes and merges classes
%additionally it places proto images into similar established classes
%the images in each folder are near instances of each other due to the high
%discimination of the sort_classes function with K>80 threshold
% In this function, we lower the threshold to merge similar folders
% together. This is possible since we now have multiple images of the same
% class to work with, whereas previously we had only 1 of each

%three(?) random images are selected from each class as reps
%each rep must match reps from another, reps from each class has differing
%weights depending on the current size of the class. A class with more
%images is better established

pathFolder='../classes/';
d = dir(pathFolder);
isub = [d(:).isdir]; %# returns logical vector
nameFolds = {d(isub).name}';
nameFolds(ismember(nameFolds,{'.','..','proto'})) = [];
numFolds=size(nameFolds,1);
%ADJUST NUMRANDS for minimum image in a class, lots of classes often only
%have 2 images. They might not be useful
numRands=2;
%s struct keeps track of nonmatches
s=struct();
%to keep track of modified classes, we used this struct:
mod=struct();
for i=1:numFolds %go through each class
    %loads normalized hist from each
    folder=strcat(strcat('../class_mats/',nameFolds(i)));
    folder_jpg=strcat(strcat('/classes/',nameFolds(i)));
    
    subfolder= what(folder{1});
    if(size(subfolder.mat,1)==0)
        %skips if folder is empty
        continue;
    end
    
    
    for k=1:numFolds %go through each class
        if(nameFolds{i}==nameFolds{k})  %can't be same folder being compared
            continue;
        end
        
        folder2=strcat(strcat('../class_mats/',nameFolds(k)));
        folder2_jpg=strcat(strcat('/classes/',nameFolds(k)));
        
        subfolder2= what(folder2{1});
        %if not in the struct of nonmatches, or if folder is not big enough
        if(size(subfolder2.mat,1)<=numRands || size(subfolder2.mat,1)==0 || isfield(s,(strcat(nameFolds{i},nameFolds{k}))) || isfield(s,(strcat(nameFolds{k},nameFolds{i}))==1  ))
            continue
        end
        numMatch=0;
        
        
        for j=1:numRands %go through each random instance
            
            
            namex=subfolder.mat{j};
            namex=namex(1:end-10);
            namey=subfolder2.mat{j};
            namey=namey(1:end-10);
            K=hsimilar(char(namex),char(namey),folder_jpg{1},folder2_jpg{1});
            
            if(K>65)  %lowered thresh to 60,
                numMatch=numMatch+1;
            end
        end
        
        if(numMatch>numRands*.70)
            
            %if 70% of the time, the reps matched, then merge to ith folder
            
            subfolder2_jpg=dir(strcat('..',folder2_jpg{1}));
            sub2_size=size(subfolder2_jpg,1);
            
            for m=3:sub2_size
                
                
                
                %SVM here. We can use negatives
                C=10;
                type=5;
                scale=2;
                
                %check if svm data file exists for folder, if so, append
                %folder2 file
                
                path=strcat(folder{1},'.mat');
                if(exist(path,'file')==2)
                    loadclass(strcat('../class_mats/',strcat(nameFolds{i},'.mat')));
                    svmtrain(X,1,C,type,scale);
                    
                else
                    %else create a new data file in the classes directory, not
                    %in the folders
                    filename=subfolder2.mat{m-2};
                    filename=filename(1:end-4);
                    load(strcat(strcat(folder2{1},'/'),strcat(filename,'.mat')),'X');
                    svmtrain(X,1,C,type,scale);
                    'saved :'
                    nameFolds{i}
                    saveclass(strcat('../class_mats/',strcat(nameFolds{i},'.mat')));
                end
                
                movefile( strcat(strcat(folder2{1},'/'),subfolder2.mat{m-2}),folder{1});
                
                
                movefile( strcat('..',strcat(strcat(folder2_jpg{1},'/'),subfolder2_jpg(m).name)), strcat('..',folder_jpg{1}));
            end
            
            %finally save all changes
            saveclass(strcat('../class_mats/',strcat(nameFolds{i},'.mat')));
            %delete the class file for folder2
            delete(strcat('../class_mats/',strcat(nameFolds{k},'.mat')));
            %mod gets new field
            mod.(nameFolds{i})=1;
            %all mod fields with 0 vals have empty folders
            mod.(nameFolds{k})=0;
            
        else
            
            %updates s struct, this optimizes the code greatly
            s.(strcat(nameFolds{i},nameFolds{k}))=1;
            s.(strcat(nameFolds{k},nameFolds{i}))=1;
            
        end
    end
    
    
end

%with all classes sorted, we now go back to train negative images using mod
pathFolder='../classes/';
d = dir(pathFolder);
isub = [d(:).isdir]; %# returns logical vector
nameFolds = {d(isub).name}';
nameFolds(ismember(nameFolds,{'.','..','proto'})) = [];
numFolds=size(nameFolds,1);
numIter=2;
names=fieldnames(mod);
for i=1:size(names,1)
    
    fieldname=names{i};
    if mod.(fieldname)==1
        %train negs
        loadclass(strcat('../class_mats/',strcat(fieldname,'.mat')));
        %loop through all folders
        %add as many as 2xsize(current folder) TODO
       
        for j=1:numFolds
            if(nameFolds{j}==fieldname)
                continue;
            end
            folder=strcat(strcat('../class_mats/',nameFolds(j)));
            subfolder= what(folder{1})
            size(subfolder.mat,1)
            if(isempty(subfolder))
                continue;
            end
            for k=1:numIter
                %determine how many images per folder we want to put as neg
                randum=floor(rand()*size(subfolder.mat,1));
                if randum==0
                    randum=1;
                end
                file=subfolder.mat{randum};
                classdir=strcat(strcat('../class_mats/',nameFolds{j}),strcat('/',file));
                load(classdir,'X');
                
                
                svmtrain(X,-1,C,type,scale);
            end
        end
        saveclass(strcat('../class_mats/',strcat(fieldname,'.mat')));
        
    else
        %delete empty folders
        rmdir(strcat('../classes/',fieldname));
        rmdir(strcat('../class_mats/',fieldname));
    end
end


end