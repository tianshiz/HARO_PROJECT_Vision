function main_loop()
clear global multiple_descriptor
clear global images
clear global gvocab
clear global gforest
global vid
vid=videoinput('winvideo',1,'YUY2_160x120');
%camera gui
fh=figure;
vid=videoinput('winvideo');
vidRes=get(vid,'VideoResolution');
nBands=get(vid,'NumberOfBands');
hImage=image(zeros(vidRes(2),vidRes(1),nBands));
anal_butt=uicontrol(fh,'Style','pushbutton','String','Analyze','Position',[5 5 100 70]);
classes_butt=uicontrol(fh,'Style','pushbutton','String','Class List','Position',[450 5 100 70]);
set(anal_butt,'Callback','Haro');
%set(classes_butt,'Callback','list_classes');
 
 
preview(vid,hImage);

end