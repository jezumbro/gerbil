function [layup,dxf,po,alignment] = layup2polyshape(direct)
% direct = 'C:\Users\jezumbro\Desktop\LTCCtest'; % input file directory
if ~endsWith(direct,'\')
    direct = [direct '\'];
end
layupfileinfo = dir([direct 'Layup\*.xlsx']); % read the corresponding layup file
layupfileinfo(startsWith({layupfileinfo.name},'~')) = [];  %remove non-directories
layup = readLayupFile([layupfileinfo.folder '\' layupfileinfo.name]);
dxffileinfo = dir([direct 'Layout\' layup.designfilename{1}]);
dxf = readDXFfile([dxffileinfo.folder '\' dxffileinfo.name]);

boundary = constructDXF(dxf,layup.boundary.name{1});[x,y] = boundary.centroid;
alignment = cell2mat(dxf(strcmpi(dxf(:,3),layup.alignment.name{1}),1)); 
alignment = alignment(:,1:2)-[x,y];
f = waitbar(0,['Loading ' num2str(size(layup.conductor.name,1)) 'Layers...']);pause(1);
for n = 1:size(layup.conductor.name,1)    
    waitbar(n/size(layup.conductor.name,1),f,['Loading Layer #' num2str(n) '...'])
    po(n) = translate(intersect(constructDXF(dxf,layup.conductor.name{n}),boundary),-x,-y);    
end
close(f);
[~,name,~] = fileparts([layupfileinfo.name]);
if ~exist([direct 'nScrypt_app\'],'dir')
    mkdir([direct 'nScrypt_app\'])
end
save([direct 'nScrypt_app\' name '.mat'],'layup','dxf','po','alignment')
end