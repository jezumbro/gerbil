function [i,p,bPts,dist] = imageProcess(fullFilePath,type,measVert,measHorz)
%% Filename & Image read for original
% fn = 'R02-0_front.tif'; fp = [pwd '/'];
% fn = 'C2-TDP-006-B01_front.tif';fp = 'C:\Users\jezumbro\Box\Honeywell KCNSC - Radar Project\KCP - HiDEC\TechnologyDemonstrationPanels\TDP-006\C2-TDP-006-B\LTCC Manufacturing\Images\';
% [fn,fp] = uigetfile('.tif');
i.original = imread(fullFilePath);%imread([fp fn]); % imread(uigetimagefile);
i.original = (flipud(i.original)); %gpuArray
%% Find the boundary of the LTCC panel.
% Limit the number of colors to four colors to determine the boundary of
% the LTCC panel.
[ ~ , i.c ] = boundaryPts( i.original ,[]);

%% Determine size of image
horz.factor = 25.4/measHorz;
vert.factor = 25.4/measVert;
i.size = size(i.c);
i.R = imref2d(i.size(1:2),horz.factor,vert.factor);

%% Determine image shinkage points
[p,dist.pxMatrix] = imagePts(i,type,1.9050,true); % 0.075 in
[xpw,ypw] = worldToIntrinsic(i.R,p(:,1),p(:,2));pw = [xpw,ypw]; clear xpw ypw
horz.pts = [p(1,:) p(2,:);p(4,:) p(3,:)];
horz.dif = diff(horz.pts);
rot.horz = mean(...
    arrayfun(@(x,y) atand(y/x),horz.dif(1:2:end),horz.dif(2:2:end)));
vert.pts = [p(1,:) p(4,:);p(2,:) p(3,:)];
vert.dif = diff(vert.pts);
rot.vert = -1*mean(...
    arrayfun(@(x,y) atand(y/x),vert.dif(2:2:end),vert.dif(1:2:end)));
% temp = diff(p(2:3,:));
theta = mean([rot.vert;rot.horz]);
i.r = imrotate(i.c,theta);
[ bPts , i.r_c ] = boundaryPts( i.r ,...
    [min(pw(:,1)) max(pw(:,1)) min(pw(:,2)) max(pw(:,2))]);
i.size = size(i.r_c);
i.R = imref2d(i.size(1:2),horz.factor,vert.factor);
[i.x,i.map] = rgb2ind(gather(i.r_c),32);
[p,dist.pxMatrix] = imagePts(i,type,1.27,false); % 0.05in
[xbpts,ybpts]=intrinsicToWorld(i.R,bPts(:,2),bPts(:,1));
bPts = [xbpts,ybpts];


end