function lines = makeTraces(param,obj)
% makeTraces takes in the subraction of the pobj and the original object
% into the function along with the parameters of the print. After taking
% the intersection of the two objects it finds the regions that have not
% been printed then takes the midpoints of the verties that describe the
% traces into cosideration
mobj = obj.regions;lines = [];
tobj = mobj(mobj.area >= min(param.line_width).^2);
for n = 1:size(tobj,1)
    pts = tobj(n).Vertices;
    [x,y] = tobj(n).boundingbox;dx = diff(x);dy = diff(y);
    vert = [];iv = 1;
    if dx>dy
        t = sortrows(pts,[2 1]);
    else
        t = sortrows(pts,[1 2]);
    end
    vert(iv,:) = t(1,:); iv = iv+1;
    [~,d] = cart2pol(t(:,1)-vert(1,1),t(:,2)-vert(1,2));
    [~,i] = max(d.*(d <= min(param.line_width)*1.5));
    vert(iv:iv+1,:) = [t(i,:);nan(1,2)];iv = iv+2;
    t = t(~(d <= min(param.line_width)*1.5),:);
    while ~isempty(t) && iv <= 200
        if dx>dy
            t = sortrows(t,[2 1]);
        else
            t = sortrows(t,[1 2]);
        end
        vert(iv,:) = t(1,:); iv = iv+1;
        [~,d] = cart2pol(t(:,1)-vert(iv-1,1),t(:,2)-vert(iv-1,2));
        [~,i] = max(d.*(d <= min(param.line_width)*1.5));
        vert(iv:iv+1,:) = [t(i,:);nan(1,2)];iv = iv+2;
        t = t(~(d <= min(param.line_width)*1.5),:);
    end
    vpt = cell2mat(arrayfun(@(x,y) [mean([vert(x,1),vert(y,1)]),...
        mean([vert(x,2),vert(y,2)])],(1:3:size(vert,1))',(2:3:size(vert,1))',...
        'UniformOutput',false));
    lines = vertcat(lines,intersect(obj,vpt),nan(1,2));
end
end