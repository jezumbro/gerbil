function [mat,lim] = constructSTL_individual(polyin,param,file)
[filepath,filename,~] = fileparts(file);mat = [];cat = categorical({'move'});
layerWidth = 0.5*param.line_width(1);
regions = polyin.regions;
[~,i] = sort(regions.area,'descend'); 
regions = regions(i);
for n = 1:size(regions,1)
    [cx,cy] = regions(n).boundingbox;
    T = triangulation(regions(n));
    nT.Points = T.Points;
    nT.ConnectivityList = T.ConnectivityList+size(T.Points,1);
    z = zeros(size(T.Points,1),1);
    vertices = [[T.Points,z];[nT.Points,z+layerWidth]];
    tempboundaries = T.freeBoundary;
    faces = sortrows([fliplr(T.ConnectivityList);
        nT.ConnectivityList;
        tempboundaries, tempboundaries(:,1)+size(T.Points,1);
        tempboundaries+size(T.Points,1),tempboundaries(:,2)]);

fidstatus = stlwrite(fullfile(filepath,[filename '_' num2str(n) '.stl']),faces,vertices,'MODE','binary');
if ~fidstatus
[status,cmdout] = system(sprintf(['slic3r-console "%s"'...
    ' --nozzle-diameter %d --layer-height %d'...
    ' --first-layer-height %d'...    
    ' --skirts 0  --infill-first --end-gcode G99'...
    ' --start-gcode ;MATLAB --gcode-comments'...
    ' --seam-position nearest  --no-plater  --print-center 100,100'],...  --infill-only-where-needed --solid-fill-pattern concentric
    fullfile(filepath,[filename '_' num2str(n) '.stl']),...
    layerWidth,layerWidth,layerWidth));
disp(cmdout)
if ~status % if file was written read
    vect = -[100,100]+[mean(cx),mean(cy)];
    [tmat, tcat] = readSlic3rGcode2mat(...
        fullfile(filepath,[filename '_' num2str(n) '.gcode']),translate(polyin,-vect),param);
    tmat1 = tmat(2:end,:)+[vect,0,0];
    mat = [mat;tmat1];
    cat = [cat;tcat(2:end,:)];
    lim = [min(mat);max(mat)];
else
    mat = nan;
    lim = nan;
end
end
end
%     delete([filepath '\' filename '.stl'])
%     delete([filepath '\' filename '.gcode'])
end