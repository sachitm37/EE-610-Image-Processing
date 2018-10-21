function new = logtransform( a )
%LOGTRANSFORM Summary of this function goes here
%   Detailed explanation goes here
hwd1=size(a);
if(numel(hwd1)==3)
    HSV1=rgb2hsv(a);
    V=HSV1(:,:,3);      %for rgb images
    c=1.0/log(256);
else
    V=double(a);
    c=255.0/log(256.0);
end
V1 = c*log(V+1);
if(numel(hwd1)==3)    % for rgb images
    HSV1(:,:,3)=V1;
    new=hsv2rgb(HSV1);
else
    new=uint8(V1);
end
end