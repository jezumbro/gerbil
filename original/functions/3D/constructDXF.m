function [polyout,lines] = constructDXF(data, layerName)
% plotAutoCADlayer - Constructs AutoCAD layer from DXF file read by
% f_LectDxf which then creates a single output polyshape MATLAB 2017b is
% required for running this command.
% layer - string of layer name
% data - output from f_LectDxf
% transxy - move AutoCAD pts to match other points
debugTF = true;
ipoly = 1;
laname = zeros(size(data(:,3)));
for n = 1:length(layerName)
    laname = or(laname,strcmpi(data(:,3),layerName{n}));
end
lines = [];
%% Hatch
la.hatch = laname & strcmpi(data(:,2),'HATCH');
temp = data(la.hatch,1);
hatchPts = [];vertPts = [];
if any(la.hatch)
    for n = 1:1:size(temp,1)
        b = temp{n};
        vertPts = vertcat(vertPts,b(1:end-1,:));
        hatchPts = vertcat(hatchPts,b(end,:)); % find all the hatch points,
    end
    if isempty(vertPts); vertPts = zeros(1,2); end
    if isempty(hatchPts); hatchPts = zeros(1,2); end
else
    vertPts = zeros(1,2);
    hatchPts = zeros(1,2);
end
%% Lines
la.line = laname & strcmpi(data(:,2),'LINE'); % Find the lines
temp = cell2mat(data(la.line,1)); % convert all the lines to a temp variable
for n = 1:1:size(temp,1)
    lines = vertcat(lines,[temp(n,1:2);temp(n,4:5);NaN(1,2)]); % add lines to the line variable
end
%% Arc
la.arc = laname & strcmpi(data(:,2),'ARC'); % find all the circles, construct circles
temp = cell2mat(data(la.arc,1));
for n = 1:1:size(temp,1)
    temp(n,4:5) = deg2rad(temp(n,4:5));
    if temp(n,4) > temp(n,5)
        ang = linspace(temp(n,4),2*pi+temp(n,5),21)';
    else
        ang = linspace(temp(n,4),temp(n,5),21)';
    end
    xp=temp(n,1)+temp(n,3)*cos(ang);
    yp=temp(n,2)+temp(n,3)*sin(ang);
    lines = vertcat(lines,[xp,yp],NaN(1,2));
end
%% Circles
la.cir = laname & strcmpi(data(:,2),'CIRCLE'); % find all the circles, construct circles
temp = cell2mat(data(la.cir,1));
for n = 1:1:size(temp,1)
    po(ipoly) = polybuffer(temp(n,1:2),'points',temp(n,3));ipoly = ipoly+1;
end

%% Solid
%
la.solid = laname & strcmpi(data(:,2),'SOLID');
temp = data(la.solid,1);
%
for n = 1:1:size(temp,1)
    b = temp{n};
    for m = 2:1:size(b,1)
        b(3:4,:) = flipud(b(3:4,:));
        po(ipoly) = polyshape(b,'Simplify',false);ipoly = ipoly+1;
    end
end
%% Polylines
la.poly = laname & strcmpi(data(:,2),'LWPOLYLINE');
temp = data(la.poly,1);
for n = 1:1:size(temp,1)
    b = temp{n}; 
    if debugTF
%         disp(b);
        fprintf([num2str(n) '/' num2str(size(temp,1)) '\n']);
        
    end
    if ~b(end,1) && norm(b(1,1:2)-b(end-1,1:2)) < 5e-3
        b(end,1) = 1;
    else 
%         disp(norm(b(1,1:2)-b(end-1,1:2)))
    end
    if size(b,1) >3  || any(b(:,3))
        po(ipoly) = pts2polyshape(b(1:end-1,:),b(end,1),b(end,2));ipoly = ipoly+1;
    end
end
fprintf('Merging Shapes...')
if ~(ipoly == 1)
    [~,i] = sort(po.area,'descend');
    po = po(i);po(~(po.area > 0)) = [];    
    polyout = po(1);
    for n = 2:size(po,2) % row
        fprintf('%i/%i\n',n,size(po,2))
        if overlaps(polyout,po(n)) % if overlap
            [x,y] = po(n).boundary;
            if all(isinterior(polyout,[x,y]))
                polyout = addboundary(polyout,[x,y]);
            else
                polyout = union(polyout,po(n));
            end 
        else
            polyout = union(polyout,po(n));   
        end
    end
    
else
    polyout = [];
end
end

