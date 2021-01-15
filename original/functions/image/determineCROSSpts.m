function [ p, distance ] = determineCROSSpts( pts,greenTF)
% determineKCPpts - this function determines the location of the pts
% based on the input of an image or an autocad file. This process is
% important due to the way that images and normal xy pts are located.
% pts - list of points with real world coordinate systems (not image
% system)
% pxtol - tolerance based on
pxtol = 2;
% LTCC panel with corresponding locations
% ------------------------------
% | p2          p6          p3 |
% |                            |
% |                            |
% |                            |
% |                            |
% | p5          p9          p7 |
% |                            |
% |                            |
% |                            |
% |                            |
% | p1          p8          p4 |
% ------------------------------
if greenTF
    g = 24.4500; % mm = 0.9626 inches
else
    g = 22.5679; % mm = 0.8885 inches
    pxtol = 2;
end
p = zeros(9,size(pts,2));
pts = sortrows(pts);
[t0,d0] = cart2pol(pts(:,1),pts(:,2));
la = find(d0 > 3.81 & pi/4-pi/14 <= t0 & t0 <= pi/4+pi/14);
% Solve for the closest point to zero, P2, and the furthest point away from
% zero, P4. Then detemine the location of the pts within the image.
% These pts are opposite from one another and begin the process solving
% for additional pts. Min and Max only return one point and do not need
% to be checked for number of pts returned.
[~,loc] = min(d0(la));
ind(1) = la(loc);
p(1,:) = pts(ind(1),:);

[t1,d1] = cart2pol(pts(:,1)-p(1,1),pts(:,2)-p(1,2));
[v,i] = sort(abs(d1-(2*sqrt(2)*g)));
la = (v<2);v = v(la);i = i(la);n = 1;stat = 0;
while ~stat && n<=sum(la)
    ind(3) = i(n);
    p(3,:) = pts(ind(3),:);
    theta = t1(ind(3))-pi/4;
    loc = find(2*g-2 <= d1 & d1 <= 2*g+2);
    [~,tl] = min(abs(t1(loc)-theta-pi/2));
    ind(2) = loc(tl);
    p(2,:) = pts(ind(2),:);
    [~,tl] = min(abs(t1(loc)-theta));
    ind(4) = loc(tl);
    p(4,:) = pts(ind(4),:);
    for m = 1:4
        [tm(m,:),dm(m,:)] = cart2pol(p(1:4,1)-p(m,1),p(1:4,2)-p(m,2));
    end
    stat = all( g/sqrt(2)-pxtol <= [dm(1,2) dm(1,4) dm(2,3) dm(4,3)] &...
        [dm(1,2) dm(1,4) dm(2,3) dm(4,3)] <= g/sqrt(2)+pxtol);
    n = n+1;
end

[t11,d11] = cart2pol(pts(:,1)-mean(p(1:4,1)),pts(:,2)-mean(p(1:4,2)));
la = find(g-2 < d11 & d11 <g+2);
t11m = mod(t11-theta+2*pi,2*pi);
ind(5)  = la(knnsearch(t11m(la),pi));
ind(6)  = la(knnsearch(t11m(la),pi/2));
ind(7)  = la(knnsearch(mod(t11m(la)+pi,2*pi),pi));
ind(8) = la(knnsearch(t11m(la),(3/2)*pi));

p(5,:) = pts(ind(5),:);
p(6,:) = pts(ind(6),:);
p(7,:) = pts(ind(7),:);
p(8,:) = pts(ind(8),:);

ind(9) = knnsearch(abs(d11),0);
p(9,:) = pts(ind(9),:);
for n = 1:size(p,1)
    distance(n,:) = arrayfun(@(x) norm(p(x,1:2)-p(n,1:2)),1:size(p,1));
end
end

