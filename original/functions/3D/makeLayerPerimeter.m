function [perimeterpts] = makeLayerPerimeter(param,obj,z)
%makeLayerPerimeter creates the perimeter from the object this is called to
% construct the objects perimeter. The object takes the first point and
% adds a z step of the hover height then concatenates the array, then the
% final point with a z step of the hover height for printing. Only the
% array is printed not the two approaches.
[x,y] = obj.boundary;
dz = z*ones(size(y));
nanLoc = find(isnan(x));
index = [1; nanLoc; size(x,1)];
perimeterpts = [];
for n = 2:1:size(index,1)
    loc = index(n-1:n); la = ismember(loc,nanLoc);
    if la(1); loc(1) = loc(1)+1; end
    if la(2); loc(2) = loc(2)-1; end
    if isempty(nanLoc) && isempty(x)
        pts = [];
    else
        pts = [x(loc(1)),y(loc(1)),dz(loc(1))+param.hover_height,0;
            x(loc(1):loc(2)-1),y(loc(1):loc(2)-1),dz(loc(1):loc(2)-1),...
            ones(loc(2)-(loc(1)),1);
            x(loc(2)),y(loc(2)),dz(loc(2)),0;
            x(loc(2)),y(loc(2)),dz(loc(2))+param.hover_height,0];
    end
    perimeterpts = vertcat(perimeterpts,pts);
end
end


