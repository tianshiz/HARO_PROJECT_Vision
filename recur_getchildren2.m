function children=recur_getchildren2(parent,result)

    myEle=result.(parent); %struct element of parent
    %get children
    global gchildren
    children.(char(parent))=1
    gchildren.(char(parent))=1;
    num=size(myEle,2)
    for i=1:num
        if(~isfield(gchildren,myEle{i}))
            %find the children of each individual children
            children_s=recur_getchildren2(char(myEle{i}),result)
            fn=fieldnames(children_s);
            for p=1:size(fn)
                str=fn(p);
                children.(char(str))=1;
                gchildren.(char(str))=1;
            end
            children.(char(myEle{i}))=1;
            gchildren.(char(myEle{i}))=1;
            %loop through children_
        end
    end
    if(num==0)
        children=struct([]); %defaults to empty struct
    end

end