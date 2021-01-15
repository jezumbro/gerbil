function [ bPts, c ] = boundaryPts( i ,windowRange)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
numColors = 32;
[x.original,x.map] = rgb2ind(gather(i),numColors);
if isempty(windowRange)
    x.la = ...
        0.500 < x.map(:,1) & x.map(:,1) < 0.925 &...
        0.850 < x.map(:,2) & x.map(:,2) < 0.999 &...
        0.900 < x.map(:,3) & x.map(:,3) < 0.999 ;
else
    x.la = ...
        0.500 < x.map(:,1) & x.map(:,1) < 0.95 &...
        0.850 < x.map(:,2) & x.map(:,2) <= 1.000 &...
        0.900 < x.map(:,3) & x.map(:,3) <= 1.000 ;
end
x.value = find(x.la)-1;
x.binary=ismember(x.original,x.value);

[B] = bwboundaries(x.binary);
for n = 1:size(B,1)
    if 10 < polyarea(B{n}(:,2),B{n}(:,1))
        polyArea(n) = polyarea(B{n}(:,2),B{n}(:,1));
%         plot(B{n}(:,2),B{n}(:,1),'Linewidth',2)
    else
        polyArea(n) = 0;
    end
end

[~,polyArealoc] = max(polyArea);
bPts = B{polyArealoc};
cropWindow = [min(bPts(:,2)) min(bPts(:,1)) ... bPts(:,2) = x
    max(bPts(:,2))-min(bPts(:,2))...            bPts(:,1) = y
    max(bPts(:,1))-min(bPts(:,1))];
if ~isempty(windowRange)
    temp = diff([cropWindow;...
        [windowRange(1) windowRange(3)...
        windowRange(2)-windowRange(1)...
        windowRange(4)-windowRange(3)]]);
    if sum(temp(1:2) < 0) > 0
        x.c = x.original;
        c = i;
    else
        x.c = imcrop(x.binary,cropWindow);
        c = imcrop(i,cropWindow);
    end
else
    x.c = imcrop(x.binary,cropWindow);
    c = imcrop(i,cropWindow);
end


[B] = bwboundaries(x.c);
for n = 1:size(B,1)
    if 10 < polyarea(B{n}(:,2),B{n}(:,1))
        polyArea(n) = polyarea(B{n}(:,2),B{n}(:,1));
    else
        polyArea(n) = 0;
    end
end


[~,polyArealoc] = max(polyArea);
bPts = B{polyArealoc};

end
