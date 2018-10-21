function a = readimage()
%READIMAGE Summary of this function goes here
%   Detailed explanation goes here
[Filename, Pathname]=uigetfile('*.*','File Selector');
if Filename==0
  % user pressed cancel
  ed = errordlg('Input must be an image','Error');
  set(ed, 'WindowStyle', 'modal');
  uiwait(ed);
  return
end
name=strcat(Pathname,Filename);     
a=imread(name);
end