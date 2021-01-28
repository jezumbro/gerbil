function pts = makeLayerFill(param,obj,theta,z)
% makeLayerFill constructs the internal fill method of the raster this was
% generated from Erin Mullin's Layer funciton with addional adeptations to
% include different startpoints and the entire 0-2pi working area for
% raster angles. Pass theta in as a radian
dxy = min(param.line_width);
theta = mod(theta,2*pi);if theta < 0;theta = 2*pi-theta;end

[x,y]=obj.boundingbox;

if diff(y)/diff(x) > 1
    theta = pi/2;
    unit.mag = 2*sqrt(2)*diff(y)+dxy;
else
    theta = 0;
    unit.mag = 2*sqrt(2)*diff(x)+dxy;
end
unit.vec = round([cos(theta) sin(theta) 0],6);
q = ceil(rdivide(theta,pi/4)); if (q == 0); q = 1; end
switch q
    case 1 % theta <= pi/4
        hyp = abs(dxy/sin(pi/2-theta));alt = abs(dxy/cos(pi/2-theta));
        if (theta == 0);hyp = dxy; alt = dxy;end
        dy = (min(y)-floor(diff(x)/dxy)*dxy:...
            +hyp:max(y)+floor(diff(x)/dxy)*dxy)';
        dx = min(x)*ones(size(dy))-alt;
    case 2 % pi/4 < theta & theta <= pi/2
        hyp = abs(dxy/sin(theta));alt = abs(dxy/cos(theta));
        if (theta == pi/2);hyp = dxy; alt = dxy;end
        dx = (min(x)-floor(diff(y)/dxy)*dxy:...
            +hyp:max(x)+floor(diff(y)/dxy)*dxy)';
        dy = min(y)-alt*ones(size(dx));
    case 3 % pi/2 < theta & theta <= 3pi/4
        hyp = abs(dxy/sin(theta));alt = abs(dxy/cos(theta));
        dx = (min(x)-hyp:hyp:max(x)-unit.mag*unit.vec(1))';
        dy = min(y)-alt*ones(size(dx));
    case 4 % 3pi/4 < theta & theta <= pi
        hyp = abs(dxy/sin(pi/2-theta));alt = abs(dxy/cos(pi/2-theta));
        if (theta == pi);hyp = dxy; alt = dxy;end
        dy = (max(y)+hyp:-hyp:min(y)-unit.mag*unit.vec(2))';
        dx = max(x)+alt*ones(size(dy));
    case 5 % pi < theta & theta <= 5pi/4
        hyp = abs(dxy/sin(pi/2-theta));alt = abs(dxy/cos(pi/2-theta));
        dy = (min(y)-hyp:hyp:max(y)-unit.mag*unit.vec(2))';
        dx = max(x)+alt*ones(size(dy));
    case 6 % 5pi/4 < theta & theta <= 3pi/2
        hyp = abs(dxy/sin(theta));alt = abs(dxy/cos(theta));
        if (theta == 3*pi/2);hyp = dxy; alt = dxy;end
        dx = (min(x)-hyp:hyp:max(x)-unit.mag*unit.vec(1))';
        dy = max(y)+alt*ones(size(dx));
    case 7 % 3pi/2 < theta & theta <= 7pi/4
        hyp = abs(dxy/sin(theta));alt = abs(dxy/sin(90-theta));
        dx = (max(x)+hyp:-hyp:min(x)-unit.mag*unit.vec(1))';
        dy = max(y)+alt*ones(size(dx));
    case 8 % 7pi/4 < theta
        hyp = abs(dxy/sin(pi/2-theta));alt = abs(dxy/cos(pi/2-theta));
        dy = (min(y)-hyp:hyp:max(y)-unit.mag*unit.vec(2))';
        dx = min(x)-alt*ones(size(dy));
    otherwise
end

modLineTF = false;
dz = z*ones(size(dy));
if unit.mag < 1
    lines = [dx,dy,dz,dx+unit.vec(1),...
        dy+unit.vec(2),dz+unit.vec(3)];
else
    lines = [dx,dy,dz,dx+unit.mag*unit.vec(1),...
        dy+unit.mag*unit.vec(2),dz+unit.mag*unit.vec(3)];
end
%% Trying to speed things up
if mod(size(lines,1),2); modLineTF = true;lines = [lines;lines(end,:)];end
modLines = round(cell2mat(...
    arrayfun(@(i,j)...
    [lines(i,[1 4])',lines(i,[2 5])';
    lines(j,[4 1])',lines(j,[5 2])'],...
    (1:2:size(lines,1))',(2:2:size(lines,1))','UniformOutput',false)),3);
% if modLineTF; modLines(end-1:end,:)=[];end
% Check to see if only one line is returned
a = obj.Vertices; b = [a;a(1,:)];
[x0,y0] = intersections(modLines(:,1)',modLines(:,2)',b(:,1)',b(:,2)');
in = [x0,y0];
% [in,~] = intersect(obj,modLines); laNan = isnan(in(:,1));
% in(laNan,:) = [];
switch q
    case 1
        ins = sortrows(in,[2 1]);
        ind = [0,0;round(diff(ins),4)];
        temp = cumsum(ind(:,2) > 0);
    case 2
        ins = sortrows(in,[1 2]);
        ind = [0,0;round(diff(ins),4)];
        temp = cumsum(ind(:,1) > 0);
    otherwise
end
ut = unique(temp);
pts = [];
if size(ut,1) > 1
    for n = 1:size(ut,1)
        t = (ut(n));
        if mod(n,2)
            pts = vertcat(pts,flipud(ins((temp==t),:)));
        else
            pts = vertcat(pts,ins((temp==t),:));
        end
    end
    
    midPts = cell2mat(arrayfun(@(x) mean([pts(x-1,:);pts(x,:)]),...
        (2:size(in,1))','UniformOutput',false));
    extrude = [isinterior(obj,midPts(:,1),midPts(:,2));0];
    pts(:,3:4) = [z*ones(size(pts(:,1))),extrude];
    pts = vertcat(pts(1,:)+[0 0 param.hover_height -1],...
        pts,...
        pts(end,:)+[0 0 param.hover_height 0]);
    temp = diff(pts(:,3:4));
    ind1  = find(temp(:,2) == 1);
    indn1 = find(temp(:,2) == -1);
    ptsm = pts(1,:);
    for n = 2:size(pts,1)
        if ismember(n-1,indn1) && ismember(n,ind1)
            ptsm = vertcat(ptsm,[pts(n,:);...
                pts(n,:)+[0 0 param.hover_height 0];...
                pts(n+1,:)+[0 0 param.hover_height -1]]);
        else
            ptsm = vertcat(ptsm,pts(n,:));
        end
    end
    clear pts;
    pts = ptsm;
end
end