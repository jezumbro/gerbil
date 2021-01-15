clear;
infilename = 'C:\Users\jezumbro\Desktop\hidec\idk.txt';
fidi = fopen(infilename);
tline = upper(fgetl(fidi));
mat = [0 0 0]
while ischar(tline)
    temp = strsplit(tline,' ');
    sw = temp{1};temp(1) = [];
    switch sw
        case 'SPEED'
            temp{1};
        case 'MOVE' % stop printing - turn off extrude, keep same point
            if 3 == size(temp,2)
                mat(end+1,:) = [str2double(temp{1}) ... 
                    str2double(temp{2}) str2double(temp{3})];
            else
                disp('zeke')
            end
        case 'G11' % start printing - keep same point with noextrude
            mat = vertcat(mat,[ppt 0 extrude]);
            extrude = 1;
        case {'G21'}
            %units now set to MM
            % disp('G21')
        case 'G92'
            %                 ppt = pt;
        case 'G99' %custom Gcode End
            if mat(end,4)
                mat(end,4) = 0;
            end
        otherwise
            %disp(strtrim(tline(1:3)))
    end
    tline = upper(fgetl(fidi));
end
