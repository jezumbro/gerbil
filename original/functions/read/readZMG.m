function [data,laser] = readZMG(filename)
% filename = 'C:\Transfer\Installs\MtGen3\Projects\Material\MapData\material_Grid Map.zmg'
debugTF = false;
fid = fopen(filename,'r');
raw = []; axisInd = 1;
while ~feof(fid)
    tline = fgetl(fid);
    if debugTF; fprintf( [tline '\n'] );end
    if startsWith(tline,';')
        if startsWith(tline,'; GRID_SCAN_SET')
            start_string = strsplit(strtrim(...
                extractAfter(tline,'; GRID_SCAN_SET')),' ');
            gss = cellfun(@(x) str2double(x),start_string);
        elseif startsWith(tline,'; SYS_AXIS_SET')
            start_string = strsplit(strtrim(...
                extractAfter(tline,'; SYS_AXIS_SET')),' ');
            sas = cellfun(@(x) str2double(x),start_string);
        elseif startsWith(tline,'; MACH_SET')
            start_string = strsplit(strtrim(...
                extractAfter(tline,'; MACH_SET')),' ');
            ms = cellfun(@(x) str2double(x),start_string);
        elseif startsWith(tline,'; SCAN_WORLD_START_POSITION')
            start_string = strsplit(strtrim(...
                extractAfter(tline,'; SCAN_WORLD_START_POSITION')),' ');
            swsp = cellfun(@(x) str2double(x),start_string);
        elseif contains(tline,{'[Axis.0]','[Axis.1]','[Axis.2]'})
            for n = 1:17
                tline = fgetl(fid);
                switch n
                    case 1
                        axis(axisInd).name = extractAfter(tline,'=');
                    case 3
                        axis(axisInd).count = str2num(extractAfter(tline,'='));
                    otherwise
                end
            end
            axisInd = axisInd + 1;
        else
        end
    else
        raw = [raw;str2num(tline)];
    end
        tline = fgetl(fid);
end
fclose(fid);
data = [raw(:,2)/ms(8),raw(:,5)/ms(9),raw(:,8)/ms(10)];
if debugTF
    figure(1);
    subplot(311);plot(raw(:,1),data(:,1))
    subplot(312);plot(raw(:,1),raw(:,3))
    subplot(313);plot(raw(:,1),raw(:,4))
    figure(2);
    subplot(311);plot(raw(:,1),data(:,2))
    subplot(312);plot(raw(:,1),raw(:,6))
    subplot(313);plot(raw(:,1),raw(:,7))
    figure(3);
    subplot(311);plot(raw(:,1),data(:,3))
    subplot(312);plot(raw(:,1),raw(:,9))
    subplot(313);plot(raw(:,1),raw(:,10))
end
laser = raw(:,10);
data(:,3) = data(:,3) + laser;
data = round(data,3);
if debugTF
    figure;plot3(data(:,1),data(:,2),data(:,3),'.-')
end