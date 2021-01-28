function readSlic3rGcode(infilename,param,outfilename)
% readGcode - read G code from slicer to generate tool paths
fidi = fopen(infilename);
fido = fopen(outfilename,'w');
fprintf(fido,'speed 2.000\n');
tline = upper(fgetl(fidi));ppt = [0,0,0];
while ischar(tline)
    if size(tline,2)>=3
        switch strtrim(tline(1:3))
            case {'G01', 'G1'}
                if contains(tline,{'X','Y','Z'})
                    [pt] = parseLine(tline);
                    temp = diff([ppt;pt]);
                    fprintf(fido,'move %.4f %.4f %.4f\n',...
                        temp(1),temp(2),temp(3));
                    ppt = pt;
                end
            case 'G10' % stop printing - close nozzel, move to hover height
                % at exit speed, set speed to moving speed
                fprintf(fido,['//STOP PRINTING\n'...
                    'valverel 0.000 %.4f\n'...
                    'wait %.4f\n'...
                    'speed %.4f\n'...
                    'move %.4f %.4f %.4f\n'...
                    'speed %.4f\n'],...
                    param.cvalve.speed(1),...
                    param.cvalve.delay(1),...
                    param.exitspeed(1),...
                    0,0,param.hover_height(1),...
                    param.movespeed(1));
            case 'G11' % start printing - set to appror move at approach speed
                fprintf(fido,['//START PRINTING\n'...
                    'speed %.4f\n'...
                    'move %.4f %.4f %.4f\n'...
                    'valverel %.4f %.4f\n'...
                    'wait %.4f\n'...
                    'speed %.4f\n'],...
                    param.approachspeed(1),...
                    0,0,-param.hover_height(1),...
                    param.ovalve.dist(1),param.ovalve.speed(1),...
                    param.ovalve.delay(1),...
                    param.printspeed(1));
            case {'G21'}
                %units now set to MM
                disp('G21')
            otherwise
                disp(strtrim(tline(1:3)))
        end
    end
    tline = upper(fgetl(fidi));
end
fclose(fido);
fclose(fidi);
end

function [pt] = parseLine(tline)
if contains(tline,'X')
    t = extractBetween(tline,'X',' ');
    pt(1) = str2double(t{1});
else
    pt(1) = 0;
end
if contains(tline,'Y')
    t = extractBetween(tline,'Y',' ');
    pt(2) = str2double(t{1});
else
    pt(2) = 0;
end
if contains(tline,'Z')
    t = extractBetween(tline,'Z',' ');
    pt(3) = str2double(t{1});
else
    pt(3) = 0;
end
end