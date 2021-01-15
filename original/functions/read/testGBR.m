%  filename = ['/Users/zeke/Box Sync/LTCC Projects/'...
%     'KTH - LTCC Projects/Gerbers/Gerber_LTCC_KTH_20171205/cond2.gbr'];
% filename = ['C:\Users\jezumbro\Box Sync\LTCC Projects\KTH - LTCC Projects\'...
%   'Gerbers\Gerber_LTCC_KTH_20171205\cond.gbr']
% filename = 'C:\Users\jezumbro\Desktop\SIMPLE_PATH_TEST_Metal-4.gbr'; %
% doesn't work yet
% filename = ['F:\TechnologyDemonstrationPanel\TDP-006\C2-TDP-006-A\LTCC Manufacturing\Gerbers\NEARSIDE_THINFILM.PHO'];

% filename = ['/Users/zeke/Box Sync/Honeywell KCNSC - Radar Project' ...
%     '/KCP - HiDEC/TechnologyDemonstrationPanels/TDP-006/C2-TDP-006-A'...
%     '/LTCC Manufacturing/Gerbers/NEARSIDE_THINFILM.PHO'];
% filename = 'C:\Users\jezumbro\Desktop\Artwork with Man. Revisions Included Sent Off\SOLDERMASKTOP.art'
% filename = 'F:\Gerber_LTCC_KTH_20171205\cond.gbr'
filename = ['C:\Users\jezumbro\Box Sync\Honeywell KCNSC - Radar Project\'...
    'KCP - HiDEC\TechnologyDemonstrationPanels\TDP-006\C2-TDP-006-A\'...
    'LTCC Manufacturing\Gerbers\NEARSIDE_THINFILM.PHO'];
layer = readRS274file(filename);
[xlim,ylim] = boundingbox(layer);
layer = translate(layer,-[mean(xlim) mean(ylim)]);
T = triangulation(layer);
nT.Points = T.Points;
nT.ConnectivityList = T.ConnectivityList+size(T.Points,1);
z = zeros(size(T.Points,1),1);
vertices = [[T.Points,z];[nT.Points,z+param.line_width]];
tempboundaries = T.freeBoundary;
faces = sortrows([fliplr(T.ConnectivityList);
    nT.ConnectivityList;
    tempboundaries, tempboundaries(:,1)+size(T.Points,1);
    tempboundaries+size(T.Points,1),tempboundaries(:,2)]);

stlwrite('cond.stl',faces,vertices,'MODE','ascii')
[status,cmdout] = system(['slic3r-console cond.stl'...
    ' --nozzle-diameter ' num2str(param.line_width) ' --layer-height ' num2str(param.line_width)...
    ' --first-layer-height ' num2str(param.line_width) ' --print-center 0,0 --use-firmware-retraction'...
    ' --seam-position nearest' ' --avoid-crossing-perimeters --skirts 0']);
readSlic3rGcode(['C:\Users\user\Box Sync\Honeywell KCNSC - Radar Project\'...
    'Zeke - R&D\MATLAB\cond.gcode'],param,['C:\Users\jezumbro\Box Sync\Honeywell KCNSC - Radar Project\'...
    'Zeke - R&D\MATLAB\cond.txt'])