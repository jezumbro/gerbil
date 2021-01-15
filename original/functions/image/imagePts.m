function [ p, dist ] = imagePts( i ,type, pxtol, TF)
%imageKCPpts - This function takes and image and determines the location
%of the KCP points within the image. These KCP points are a series of 11
%points that are used to determine shinkage.
% i     : RGB image
% pxtol : tolerance of pixels when the image is looking for specific points
% plotTF: true or false if the figure will be plotted after finding all the
%   pionts
if TF
    z = i.c;
else
    z = i.r_c;
end

if i.R.PixelExtentInWorldX < 25.4/300
    numColors = 32;
    [x.original,x.map] = rgb2ind(gather(z),numColors);
    x.la = ...
        0.500 < x.map(:,1) & x.map(:,1) < 0.95 &...
        0.850 < x.map(:,2) & x.map(:,2) <= 1.000 &...
        0.900 < x.map(:,3) & x.map(:,3) <= 1.000 ;
    x.value = find(x.la)-1;
    x.binary=ismember(x.original,x.value);
    %         figure(1);clf;imshow(x.binary);hold on
    %     B = bwboundaries(x.binary,4);temp.Location = [];
    temp.Location = imfindcircles(x.binary,[5 15],'ObjectPolarity','dark','Sensitivity',.9);
else
    g = rgb2gray(gather(z)); % convert to gray scale
    t = detectMinEigenFeatures(g); % determine features
    % assume 11 points are within the strongest 25 of the image
    temp = t.selectStrongest(25);
end

% determine the verticies locations pts = [x,y]
[xWorld,yWorld] = intrinsicToWorld(i.R,temp.Location(:,1),temp.Location(:,2));
pts = double([xWorld,yWorld]);clear temp xWorld yWorld

%% Detemine locations of points
% Find the distance to the top left corner of the picture to all the points
% within the image distance From zero
[p,dist] = determinePts(type, pts, pxtol, false);

end

