function [matrix,time] = constructMatrix(obj,lines,param)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
robj= obj.regions;nozArea = (pi/4)*min(param.line_width)^2;
pts = {zeros(1,size(robj,1))};dist = zeros(1,size(robj,1));
for n = 1:size(robj,1)
    clear temp
    if robj(n).area > 25*nozArea
        pobj = polybuffer(robj(n),-min(param.line_width/2));
        fobj = polybuffer(robj(n),-min(param.line_width));
        if fobj.area > nozArea
            temp.fill = makeLayerFill(param,fobj,0,0);
        else
            temp.fill = [];
        end
        
        temp.perm = makeLayerPerimeter(param,pobj,0);
        temp.all = vertcat(temp.fill,temp.perm);
    else
        temp.all = makeLayerFill(param,robj(n),0,0);
    end
    pts(:,n) = {temp.all};
    if isempty(temp.all)
        time.print(n) = 0;
        time.move(n) = 0;
        sp(n,:) = [0 0];
        ep(n,:) = [0 0];
    else
        temp.dist = diff(temp.all(:,1:3));
        temp.move = arrayfun(@(x) norm(temp.dist(x,:)),1:size(temp.dist,1))';
        temp.move(:,2) = temp.all(1:end-1,4);
        time.print(n) = sum(temp.move(:,1).*temp.move(:,2))/param.printspeed;
        time.move(n) = sum(temp.move(:,1).*~temp.move(:,2))/param.movespeed;
        sp(n,:) = temp.all(1,1:2);
        ep(n,:) = temp.all(end,1:2);
    end
end
m = n+1;
loc = find(isnan(lines(1:end,1)));
loc = unique([1;loc;size(lines,1)]);
for n = 2:size(loc,1)
    if n == 2
        temp.line = lines(loc(n-1):loc(n)-1,:);
    elseif n == size(loc,1)
        temp.line = lines(loc(n-1)+1:loc(n),:);
    else
        temp.line = lines(loc(n-1)+1:loc(n)-1,:);
    end
    temp.all = [temp.line(1,1:2) param.hover_height 0;...
        temp.line(:,1:2) zeros(size(temp.line,1),1) ...
        ones(size(temp.line,1),1);...
        temp.line(end,1:2) 0 0;...
        temp.line(end,1:2) param.hover_height 0];
    pts(:,m) = {temp.all};
    if isempty(temp.all)
        time.print(m) = 0;
        time.move(m) = 0;
        sp(m,:) = [0 0];
        ep(m,:) = [0 0];
    else
        temp.dist = diff(temp.all(:,1:3));
        temp.move = arrayfun(@(x) norm(temp.dist(x,:)),1:size(temp.dist,1))';
        temp.move(:,2) = temp.all(1:end-1,4);
        time.print(m) = sum(temp.move(:,1).*temp.move(:,2))/param.printspeed;
        time.move(m) = sum(temp.move(:,1).*~temp.move(:,2))/param.movespeed;
        sp(m,:) = temp.all(1,1:2);
        ep(m,:) = temp.all(end,1:2);
    end
    m = m+1;
end
la = ismember(ep,[0 0],'row') & ismember(sp,[0 0],'row');
pts(:,la) = [];ep(la,:) = [];sp(la,:) = [];index = 1:1:size(pts,2);
[~,dist] = cart2pol(sp(:,1),sp(:,2));
[~,i] = sort(dist); ind = i(1); m = 2;
while m < size(pts,2)+1 & ~all(ismember(index,ind))
    [~,dist] = cart2pol(sp(:,1)-ep(ind(m-1),1),sp(:,2)-ep(ind(m-1),2));
    [~,i] = sort(dist);i = i.*~ismember(i,ind); i(i == 0) = [];
    ind = vertcat(ind,i(1));m = m+1;
end
i = ind;
matrix = [0 0 param.hover_height 0];
for n = 1:size(i',2)
    matrix = vertcat(matrix,pts{i(n)});
end
end