function [mat,lim] = constructSTL(polyin,param,file)
[filepath,filename,ext] = fileparts(file);
layerWidth = 0.5*param.line_width(1);
T = triangulation(polyin);
nT.Points = T.Points;
nT.ConnectivityList = T.ConnectivityList+size(T.Points,1);
z = zeros(size(T.Points,1),1);
vertices = [[T.Points,z];[nT.Points,z+layerWidth]];
tempboundaries = T.freeBoundary;
faces = sortrows([fliplr(T.ConnectivityList);
    nT.ConnectivityList;
    tempboundaries, tempboundaries(:,1)+size(T.Points,1);
    tempboundaries+size(T.Points,1),tempboundaries(:,2)]);

fidstatus = stlwrite([filepath '\' filename '.stl'],faces,vertices,'MODE','ascii');
if ~fidstatus
[status,cmdout] = system(['slic3r-console ' filepath '\' filename '.stl'...
    ' --nozzle-diameter ' num2str(layerWidth) ' --layer-height ' num2str(layerWidth)...
    ' --first-layer-height ' num2str(layerWidth) ...
    ' --infill-first --infill-only-where-needed' ' --print-center 0,0 --end-gcode G99'...
    '--solid-fill-pattern concentric --start-gcode ;MATLAB'...
    ' --skirts 0']);% --skirt-distance 2  ']); 
disp(cmdout)
if ~status % if file was written read
    mat = readSlic3rGcode2mat([filepath '\' filename '.gcode'],polyin,param);    
    lim = [min(mat);max(mat)];
else
    mat = nan;
    lim = nan;
end
    
%     delete([filepath '\' filename '.stl'])
%     delete([filepath '\' filename '.gcode'])
end
end