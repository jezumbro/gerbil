function [data,laser] = readCZG(filename)
%filename = 'C:\Transfer\Installs\MtGen3\ParameterFiles\4597\optimization\2018924\15-11-57\material_Grid Map.czg';
debugTF = false;
fid = fopen(filename,'r');
raw = []; 
while ~feof(fid)
    tline = fgetl(fid);
    if debugTF;fprintf([tline '\n']);end
    if startsWith(tline,';')
        if startsWith(tline,'; SCAN_WORLD_START_POSITION')
            start_string = strsplit(strtrim(...
                extractAfter(tline,'; SCAN_WORLD_START_POSITION')),' ');
            swsp = [str2double(start_string{1});
                str2double(start_string{2});
                str2double(start_string{3})];
        elseif startsWith(tline,'; MACH_SET')
            start_string = strsplit(strtrim(...
                extractAfter(tline,'; MACH_SET')),' ');
            ms = cellfun(@(x) str2double(x),start_string);
        elseif startsWith(tline,'; SYS_AXIS_SET')
            start_string = strsplit(strtrim(...
                extractAfter(tline,'; SYS_AXIS_SET')),' ');
            sas = cellfun(@(x) str2double(x),start_string);
        else
%             disp('comment')
        end
    else
        raw = [raw;str2num(tline)];
%         disp(tline)
    end
end
fclose(fid);
data = [raw(:,1)/ms(8)+sas(9),raw(:,2)/ms(9)+sas(10),raw(:,3)/ms(10)+sas(11)];
laser = 20*(raw(:,4)/ms(7))-10;
data(:,3) = data(:,3) + laser;
data = round(data,3);
if debugTF
    figure;plot3(data(:,1),data(:,2),data(:,3),'.-')
end
end