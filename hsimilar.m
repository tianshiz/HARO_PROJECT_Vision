function K=hsimilar(class_namex,class_namey,root,root2)
global gforest
global gforest_quarter
global gforest_half
global gvocab
global gvocab_quarter
global gvocab_half


for i=1:3
    if i==1
[hsum0, hsum1,hsum2]=similar(class_namex,class_namey,gforest,gvocab,root,root2);
    end
    if i==2
[hsum01, hsum11,hsum21]=similar(class_namex,class_namey,gforest_half,gvocab_half,root,root2);
    end
    if i==3
[hsum02, hsum12,hsum22]=similar(class_namex,class_namey,gforest_quarter,gvocab_quarter,root,root2);
    end
end

hsum0=(hsum0+hsum01+hsum02)/3;
hsum1=(hsum1+hsum11+hsum12)/3;
hsum2=(hsum2+hsum21+hsum22)/3;

K=hsum0*(1/2^(2))+hsum1*(1/2^(2-1))+hsum2*(1/2^(2-2));

end