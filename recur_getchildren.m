function children=recur_getchildren(result,person)

%Find all relatives of given person
s = eval(strcat('result.',person))

%Go through all relatives found in s
for i=1:size(s,2)
    children = union(s(i),eval(char(strcat('result.',s(i)))));
end

%remove orignal relative from other relatives
children=setdiff(children,person);
end