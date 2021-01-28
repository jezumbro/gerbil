function [polyout,lines] = constructDXF(data, layer)
%plotAutoCADlayer - Constructs AutoCAD layer from DXF file read by
% f_LectDxf which then creates a single output polyshape MATLAB 2017b is
% required for running this command.
% layer - string of layer name
% data - output from f_LectDxf
% transxy - move AutoCAD pts to match other points
ipoly = 1;
lines = [];
%% Lines
la.line = strcmpi(data(:,3),layer) & strcmpi(data(:,2),'LINE'); % Find the lines
temp = cell2mat(data(la.line,1)); % convert all the lines to a temp variable
for n = 1:1:size(temp,1)
    lines = vertcat(lines,[temp(n,1:2);temp(n,4:5);NaN(1,2)]); % add lines to the line variable
end
%% Circles
ang=linspace(0,2*pi,10);
la.cir = strcmpi(data(:,3),layer) & strcmpi(data(:,2),'CIRCLE'); % find all the circles, construct circles
temp = cell2mat(data(la.cir,1));
for n = 1:1:size(temp,1)
    xp=temp(n,1)+temp(n,3)*cos(ang);
    yp=temp(n,2)+temp(n,3)*sin(ang);
    po(ipoly) = polyshape([xp',yp']);ipoly = ipoly+1;
end
%% Hatch
la.hatch = strcmpi(data(:,3),layer) & strcmpi(data(:,2),'HATCH');
temp = data(la.hatch,1);
hatchPts = [];vertPts = [];
for n = 1:1:size(temp,1)
    b = temp{n};
    vertPts = vertcat(vertPts,b(1:end-1,:));
    hatchPts = vertcat(hatchPts,b(end,:)); % find all the hatch points,
    
    %     for m = 1:1:size(b,1)
    %         plot(b(m,1),b(m,2),'Marker','.','Color','r')
    %     end
end
%% Solid

la.solid = strcmpi(data(:,3),layer) & strcmpi(data(:,2),'SOLID');
temp = data(la.solid,1);
for n = 1:1:size(temp,1)
    b = temp{n};
    po(ipoly) = polyshape(b);ipoly = ipoly+1;
end
polyout = union(po);
%% Polylines
% Figure out stuff from here
la.poly = strcmpi(data(:,3),layer) & strcmpi(data(:,2),'LWPOLYLINE');
temp = data(la.poly,1);
for n = 1:1:size(temp,1)
    clear d
    b = temp{n};
    if all(ismember(b(:,1:2),vertPts,'row'))
        pts2polyshape(b)
        po(ipoly) = pts2polyshape(b);ipoly = ipoly+1;
    else        
        lines = vertcat(lines,pts2lines(b),NaN(1,2));
    end
end
polyout = union(po);
end

