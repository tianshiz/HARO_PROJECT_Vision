function resul=sort_classes(thresh)
%this function calls function similar to sort and group all the classes
%that are similar enough to be considered as one class. This is one of two
%sorting functions that sorts ONLY images under proto, this should be
%called after sort_existing_classes
global gforest
global gforest_quarter
global gforest_half
global gvocab
global gvocab_quarter
global gvocab_half

gforest_half=vl_kdtreebuild(double(gvocab_half)) ;
gforest_quarter=vl_kdtreebuild(double(gvocab_quarter)) ;

%first sort the proto classes
%-------------------------------'
%loop through every _class.mat file in the classes/proto and compare for
%similarity
file_list=what('../class_mats/proto');


update_file_list=file_list; %holds updated list of potential classes with similarity
[len width]=size(file_list.mat);

%lsh init
%these params need to be adjusted depending on the size of content in
%proto. Right now its 100 image per batch, so the values to match that are
%empirically obtained
tableSize=10;
keyLength=100; %bit
%patches=sparse(zeros(1000000,0));
index={};
%get all columns of all proto images
%TODO
patches=[];
for i=1:len
  
    %loads normalized hist from each
    load(strcat('../class_mats/proto/',file_list.mat{i}),'X');
    %patch together
 %   if(size(X,1)==size(patches,1) || size(patches,1)==0)
    patches=[patches X];
 %   else
   %    size(X,1)
 %   end
    index{i}=file_list.mat{i}(1:end-10); %remove the _class.mat end from name
end

T1=lsh('lsh',tableSize,keyLength,size(patches,1),patches); %creates lsh index

for i=1:len
    %every class gets a chance to be compared
    file=file_list.mat{i};
    file=file(1:end-10);
    %deletes the name from list  so can't compare with self and wont be
    % matched against again in the future by another loop, since its
    % redundant
    if(~isnumeric(update_file_list.mat{i}))
        update_file_list.mat{i}=0;
        [len2 width]=size(update_file_list.mat); %all the items to be compared with
        %OPTIMIZATION WITH LSH
        %we use LSH and hash all contents in proto so that we can decide if the
        %updated_name item is worth the time to compare with
        %k is the number of closest neighbors, r is max distance
        [iNN cann]=lshlookup(patches(:,i),patches,T1,'k',4);
        %iNN is the index of matched, k sets how many neighbors are returned, we
        %ignore the first one since its the same patch. So we get 5 neighbors
        %essentially
        clear similar_class  %remove last iteration's data
        %loop through iNN get names of all classes that are similar
        for k=1:size(iNN,2)
            similar_class.(index{iNN(k)})=1; %creates key with name for struct
        end
        
        for j=1:len2
            updated_name=update_file_list.mat{j};
            updated_name=updated_name(1:end-10);
            %check if updated_name in iNN, if not skip
            
            if(isfield(similar_class,char(updated_name)))
                if(updated_name~=0 )
                    
                    root='classes/proto/';
                    %compare with all the classes in the updated list
                    k=hsimilar(file,updated_name,root,root);
                    %if k value is sufficient we save this in a struct. This
                    %makes sure that every similar class is copied. Additionally
                    %classes that are similar to the class copied are also brought over
                    %at the end
                    %default thresh=80
                    if(k>thresh)
                        %  update_file_list.mat{j}=0;
                        %result.file is a cell where as result is a struct
                        % empty=cellfun('isempty',result.file);
                        if(~exist('result'))
                            result=struct(file,{{updated_name}})
                            result.(updated_name)={{file}}
                        else
                            %append to cell array
                            if(isfield(result,file))
                                result.(file){end+1}=updated_name
                            else
                                result.(file)={{updated_name}}
                            end
                            %add record to the compared img as well
                            if(isfield(result,updated_name))
                                result.(updated_name){end+1}=file
                            else
                                result.(updated_name)={{file}}
                            end
                        end
                    else
                        if(exist('result'))
                            if(~isfield(result,file))
                                result.(file)='';
                                
                            end
                        else
                            result.(file)='';
                        end
                    end
                else
                    if(exist('result'))
                        if(~isfield(result,file))
                            result.(file)='';
                            
                        end
                    else
                        result.(file)='';
                    end
                end
            end
        end
    end
end
resul=result;
clear global tot_records
clear global gresult
global gresult
global totals
totals=[]
global garray
garray=[]
clear global gchildren
global gchildren

%at this point result should have all the classes that are similar to each
%class. But each cell will have overlaps, so we first remove the overlaps
%how result is structured:
%result.classname={class1,class2}
if(exist('result'))
    fn=fieldnames(result);
    
    for p=1:size(fn)
        first=0;
        %loop through, for each get all the childs of the similar images and remove
        %them
        str=fn(p);
        each_cell=result.(char(str));
        if(~strcmp(each_cell,''))
            empty=cellfun('isempty',each_cell);
            
            %check if the 1st level field is empty
            if(sum(~empty(1)) && sum(~strcmp(each_cell,'')))
                %tot returns a struct of all children
                tot=recur_getchildren2(char(str),result)
                % cel=result.(char(str))
                
                %   if(size(cel,2)>5)  %cell must be greater than 5 for us to make a new class
                %   for i=1:size(cel,2)  %translate cell into tot struct
                %      tot.(char(cel{i}))=1
                % end
                
                %loop through tot, tot include the main class itself so we
                %need a tot of size greater than 1
                if(size(fieldnames(tot),1)>1)
                    %we need to remove all the children from result since they dont need
                    %their own folders now
                    fn2=fieldnames(result);
                    for p2=1:size(fn2)
                        str2=fn2(p2);
                        %loop through tot struct
                        if(isfield(tot,char(str2)))
                            if(tot.(char(str2))==1)
                                result.(char(str2))='';
                            end
                        end
                    end
                    
                    
                    %So now we copy the _class.mat and respective files into the new
                    %folders
                    %we create a folder under classes and classes_mat
                    S=(char(str))
                    % S=S(1:end-4); %removes .mat from name
                    newfolder=strcat('../classes/',S);
                    newfolder_mat=strcat('../class_mats/',S);  %remove proto after testing!!!
                    exist(newfolder,'dir');
                    if(exist(newfolder,'dir')~=7)
                        mkdir(newfolder);
                    else
                        break;
                    end
                    if(exist(newfolder_mat,'dir')~=7)
                        mkdir(newfolder_mat);
                    else
                        break;
                    end
                    
%                     C=10;
%                     type=5;
%                     scale=2;
                    %gets the result and creates new folder and stuff
                    fn3=fieldnames(tot);
                    sub_classes={};
                    
                    for p3=1:size(fn3)
                        load(strcat(strcat('../class_mats/proto/',char(fn3(p3))),'_class.mat'),'X');
                        sub_classes{p3}=X;
                        movefile(strcat(strcat('../classes/proto/',char(fn3(p3))),'.jpg'),newfolder);
                        movefile(strcat(strcat('../class_mats/proto/',char(fn3(p3))),'_class.mat'),newfolder_mat);
                        
                        %retrain SVM
                        
                        
                    end
                    
                    
                    %disabled svm here
                    
%                     
%                     %only if negative exist do we train, other wise this is
%                     %the first either being trained and it cant train since
%                     %there is no neg. To solve this we defer this class's
%                     %training to the next itfirsteration
%                     folder=strcat(strcat(newfolder_mat,'/'),S)
%                     
%                     loadclass(strcat(folder,'_class.mat')); %folder for main class
%                     
%                     len=size(sub_classes,2);
%                     listing=[];
%                     
%                     size(fn)
%                     for i=1:len
%                         listing=[listing sub_classes{i}];
%                         
%                     end
%                     if(exist('negative'))
%                         po=ones(size(listing,2),1);
%                         ne=-1*ones(size(negative,2),1);
%                         
%                         if(first==1)
%                             first=0;
%                             %here negative is the first class and is what we are
%                             %training. The listing from the current iteration
%                             %acts as the negative
%                             loadclass(strcat(last_folder,'_class.mat')); %load old folder to train the first class
%                             svmtrain([negative listing],vertcat(ne,po),C);
%                             saveclass(strcat(last_folder,'.mat'));
%                             loadclass(strcat(folder,'_class.mat')); %reload back to current folder for next sequence
%                         end
%                         svmtrain([listing negative],vertcat(po,ne),C);
%                         saveclass(strcat(folder,'.mat'));
%                     else
%                         first=1;
%                         last_folder=folder;
%                     end
%                     negative=listing;
                end
                %   end
            end
        end
    end
    
end




%lastly sort the existing established classes, there may be cases where two
%classes will be established and be very similar. TODO later
%-------------------------------------
end