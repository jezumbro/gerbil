function status = mach32nMill(infilename)
% mach32nMill(infilename) - this function takes in Gcode for a Mach3
% machine an converts it to a PSJ style .txt file for the nScrypt. This
% code is only meant to provide a quick method to convert all the G1 and G0
% commands to different tool paths for the nScrypt nMill
% Written by: Zeke Zumbro 
% Date: June 13, 2018
%
% Input:
% infilename - the file path and name for the corresponding text files
% Output:
% status - the status of the files along with a .txt file in the same
% directory that the infilename was loaded from.

fi = fopen(infilename);[path,name,ext] = fileparts(infilename);
fo = fopen([path '\' name '.txt'],'w');
fprintf(fo,['// %s.txt created from MATLAB mach32nMill()\n'... print header
    '// Input: %s\n'...
    '// Date: %s\n'...
    'speed 5\n'],name,[name ext],datestr(datetime));
pcmd = 'G5';ppt = [0 0 5]; % set to a random command, also set the starting point to [0 0 5]
while ~feof(fi)
    clear pt % clear the pt that was just taken in
    tline = fgetl(fi); % get a line of code
    if startsWith(tline,'G') % if the line starts with 'G'
        [pcmd,pt] = gcode(tline,pcmd,fo,ppt);
        if any(pt)
            if pt(4) ~= 0
                fprintf(fo,'speed %.3f\n',pt(4)/60);
            end
            dpt = diff([ppt;pt(1:3)]);
            fprintf(fo,'move\t%.3f\t%.3f\t%.3f\n',...
                dpt(1),dpt(2),dpt(3));
            ppt = ppt+dpt;
        end
    elseif startsWith(tline,'M')
        mcode(tline,fo)
    elseif startsWith(tline,'S')
        temp = strsplit(strrep(tline,'S',''),' ');
        mcode(temp{2},fo)
    elseif any(strcmpi(pcmd,{'G1','G0'})) && contains(tline,{'X','Y','Z'})
        pt = str2array(tline,ppt);
        if pt(4) ~= 0
            fprintf(fo,'speed\t%.3f\n',pt(4)/60);
        end
        dpt = diff([ppt;pt(1:3)]);
        fprintf(fo,'move\t%.3f\t%.3f\t%.3f\n',...
            dpt(1),dpt(2),dpt(3));
        ppt = ppt+dpt;
    end
end

fclose(fi);
fprintf(fo,'Mill Off');
fclose(fo);
end

function [pcmd,mat] = gcode(str,pcmd,fo,ppt) % Gcode function
mat = zeros(1,4);       % setup an output matrix
temp = strsplit(str);   % split up the string looking for the initial command 
switch temp{1}
    case 'G0' % G0 command, set the speed back to 25mm/sec and move to that point
        pcmd = 'G0';
        fprintf(fo,'speed\t25\n');
        mat = str2array(str,ppt);
    case 'G1' % G1 command, move to the next point at the given speed
        pcmd = 'G1';
        mat = str2array(str,ppt);
    
    case 'G28' % move to origin
        fprintf(fo,'move\t0\t0\t5\n');
    case 'G43'
    otherwise
        pcmd = temp{1};
end
end

function mat = str2array(str,ppt) % find what the input string structure 
mat = zeros(1,4); % set the matrix to zero
sloc = sort([1 strfind(str,' ') length(str)]); % find the spaces
xloc = strfind(str,'X'); % find if the string contains an X point
yloc = strfind(str,'Y'); % find if the string contains an Y point
zloc = strfind(str,'Z'); % find if the string contains an Z point
floc = strfind(str,'F'); % find if the string contains a feed rate
if ~isempty(xloc) % if the string can be found replace the zero if not put the previous point in
    mat(1) = str2double(str(xloc+1:sloc(find(sloc > xloc,1))));
else
    mat(1) = ppt(1);
end
if ~isempty(yloc) % if the string can be found replace the zero if not put the previous point in
    mat(2) = str2double(str(yloc+1:sloc(find(sloc > yloc,1))));
else
    mat(2) = ppt(2);
end
if ~isempty(zloc) % if the string can be found replace the zero if not put the previous point in
    mat(3) = str2double(str(zloc+1:sloc(find(sloc > zloc,1))));
else
    mat(3) = ppt(3);
end
if ~isempty(floc) % if the string can be found replace the zero if not put the previous point in
    mat(4) = str2double(str(floc+1:sloc(find(sloc > floc,1))));
end
end
function mcode(str,fo)
temp = strsplit(str);
switch temp{1}
    case 'M3'
        fprintf(fo,'Mill_Direction CCW\n');
        fprintf(fo,'Mill On\nWait 20\n');
    case 'M4'
        fprintf(fo,'Mill_Direction CW\n');
        fprintf(fo,'Mill On\nWait 20\n');
    case 'M5'
        fprintf(fo,'Mill Off\n');
    otherwise
        pcmd = pcmd;
end
end