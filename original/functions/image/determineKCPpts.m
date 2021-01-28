function [ p, distance ] = determineKCPpts( pts, pxtol, TF)
% determineKCPpts - this function determines the location of the pts
% based on the input of an image or an autocad file. This process is
% important due to the way that images and normal xy pts are located.
%
% LTCC panel with corresponding locations
% ------------------------------
% | p2                      p3 |
% |            p7              |
% |             |        p8    |
% |             |              |
% |             |              |
% |  p6--------p11--------p9   |
% |             |              |
% |             |              |
% |    p5       |              |
% |            p10             |
% | p1                      p4 |
% ------------------------------
if TF
    g = 159.2529; % mm = 6.2698 inches
else
    g = 145.3972; % mm = 5.7243 inches
end
p = zeros(11,size(pts,2));
pts = sortrows(pts);
[t0,d0] = cart2pol(pts(:,1),pts(:,2));
la = find(d0 > 3.81 & pi/4-pi/14 <= t0 & t0 <= pi/4+pi/14);
% Solve for the closest point to zero, P2, and the furthest point away from
% zero, P4. Then detemine the location of the pts within the image.
% These pts are opposite from one another and begin the process solving
% for additional pts. Min and Max only return one point and do not need
% to be checked for number of pts returned.
% x = [min(pts(:,1)) max(pts(:,1))];
% y = [min(pts(:,2)) max(pts(:,2))];
% dx = discretize(pts(:,1),...
%     [min(x), mean([x(1) mean(x)]),mean([x(2) mean(x)]),max(x)]);
% dy = discretize(pts(:,2),...
%     [min(y), mean([y(1) mean(y)]),mean([y(2) mean(y)]),max(y)]);
% mx = arrayfun(@(x) median(pts(dx == x,1)),1:max(unique(dx)));
% my = arrayfun(@(x) median(pts(dy == x,2)),1:max(unique(dy)));
[~,loc] = min(d0(la));
ind(1) = la(loc);
%     [~,ind(3)] = max(zeroRho);
p(1,:) = pts(ind(1),:);
[t1,d1] = cart2pol(pts(:,1)-p(1,1),pts(:,2)-p(1,2));
[v,i] = sort(abs(d1-g));
la = (v<2);v = v(la);i = i(la);n = 1;stat = 0;
while ~stat && n<=sum(la)
    ind(3) = i(n);
    p(3,:) = pts(ind(3),:);
    theta = t1(ind(3))-pi/4;
    loc = find(g/sqrt(2)-pxtol <= d1 & d1 <= g/sqrt(2)+pxtol);
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
la = find((0.425/sqrt(2))*g-pxtol < d11 & d11 < (0.475/sqrt(2))*g+pxtol);
t11m = mod(t11-theta+2*pi,2*pi);
ind(6)  = la(knnsearch(t11m(la),pi));
ind(7)  = la(knnsearch(t11m(la),pi/2));
ind(9)  = la(knnsearch(mod(t11m(la)+pi,2*pi),pi));
ind(10) = la(knnsearch(t11m(la),(3/2)*pi));

p(6,:) = pts(ind(6),:);
p(7,:) = pts(ind(7),:);
p(9,:) = pts(ind(9),:);
p(10,:) = pts(ind(10),:);

la = (0.4*g-pxtol <= d11 & d11 <= 0.4*g+pxtol &...
    4.0130-pi/16 <= t11m & t11m <= 4.0130+pi/16);
ind(5) = find(la,1);
p(5,:) = pts(ind(5),:);
la = (0.4*g-pxtol <= d11 & d11 <= 0.4*g+pxtol &...
    0.8714-pi/16 <= t11m & t11m <= 0.8714+pi/16);
ind(8) = find(la,1);
p(8,:) = pts(ind(8),:);
if size(pts,1) == 11
    p(11,:) = pts(~ismember(pts,p, 'rows'),:);
else
    %     cpt.p1p3  = mean([p(1,:);p(3,:)],1);
    %     cpt.p2p4  = mean([p(2,:);p(4,:)],1);
    %     cpt.p5p8  = mean([p(5,:);p(8,:)],1);
    cpt.p6p9  = mean([p(6,:);p(9,:)],1);
    cpt.p7p10 = mean([p(7,:);p(10,:)],1);
    %     cpt.p14   = mean(cell2mat({p(1:4,:)}'));
    %     cpt.p67p910 = mean([cell2mat({p(6:7,:)}');cell2mat({p(9:10,:)}')]);
    fields = fieldnames(cpt);
    b = zeros(size(fields,1),size(pts,2));
    for n = 1:numel(fields)
        b(n,:) = cpt.(fields{n});
    end
    p(11,:) = mean(b,1);
end
clear distance;
for n = 1:size(p,1)
    distance(n,:) = arrayfun(@(x) norm(p(x,1:2)-p(n,1:2)),1:size(p,1));
end
end

