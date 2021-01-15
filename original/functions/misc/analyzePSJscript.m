% analyzePSJscript(filename)

filename = 'C:\Users\jezumbro\Desktop\UNIPOLAR_Layer-TOP_V2-psjscript.txt';
speed = 30; extrude = 0; mat = [0,0,0,extrude,speed]; 
fid = fopen(filename);
tline = fgetl(fid);

while ~feof(fid)
    if contains(lower(tline),'move')
        mat = [mat;getXYZ(tline),extrude,speed];
    elseif contains(lower(tline),'speed')
        speed = getSpeed(tline);
    elseif contains(lower(tline),'valverel')
        [dist,speed] = getValve(tline)
        if dist > 0
            extrude = 1;
            valve.open_speed = speed;
            valve.open_dist = dist;
        else
            extrude = 0;
            valve.close_speed = speed;
        end
    elseif contains(lower(tline),'wait')
        if extrude
            valve.open_delay = getWait(tline);
        else
            valve.close_delay = getWait(tline);
        end
    else
        disp(tline)
    end
    tline = fgetl(fid);
    
end
function pt = getXYZ(string)
cell = strsplit(strtrim(strrep(string,'move','')),' ');
pt = cellfun(@(x) str2num(x),cell);
end

function speed  = getSpeed(string)
speed = str2num(strtrim(strrep(string,'speed','')));
end

function [dist,speed] = getValve(string)
cell = strsplit(strtrim(strrep(string,'valverel','')),' ');
temp = cellfun(@(x) str2num(x),cell); dist = temp(1); speed = temp(2);
end

function wait = getWait(string)
wait = str2num(strtrim(strrep(string,'wait','')));
end