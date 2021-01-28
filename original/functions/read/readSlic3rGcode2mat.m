function [mat, cat] = readSlic3rGcode2mat(infilename,layer,param)
% readSlic3rGcode2mat - reads a slic3r gcode file and parses the file based
% on the move commands within the file

% Version 1.0 - use general G-code for moves
% Version 2.0 - use verbose GCode for general moves

debugTF = false;
fidi = fopen(infilename);
cat = {'move'};fillType = 'perimeter';
mat = [0 0 param.hover_height(1) 0]; ppt = [0,0];
while ~feof(fidi)
    tline = upper(fgetl(fidi));
    if debugTF; disp(tline);end
    if isempty(tline)
        cmd = ''; comment = '';
    else
        temp = strsplit(tline,';');
        cmd = temp{1};
        if contains(tline,';')
            comment = strtrim(temp{2});
        else
            comment = '';
        end
    end
    
    if ~isempty(cmd)
        switch extractBefore(cmd,' ')
            case {'G01', 'G1'}
                if contains(cmd,{'X','Y'}) && contains(comment,'MOVE TO')
                    pt = parseline(cmd); % get the xy coordiants of the point
                    [~,out] = intersect(layer,[ppt;pt]); % check if any part of the movement is outside the layer
                    dist = norm(pt-ppt);   % calculate the distance for the movement
                    if isempty(out) && mat(end,4) && dist < 5*param.line_width(1) % if currently extruding and doesn't break the shape
                        mat = vertcat(mat,[pt 0 1.2]); cat = vertcat(cat,{'fast print'});
                    elseif ~mat(end,4)
                        mat = vertcat(mat,[pt param.hover_height(1) 0]);  cat = vertcat(cat,{'move'});
                    else
                        mat = vertcat(mat,[ppt 0 0;... % stop printing
                            ppt param.hover_height(1) 0;... % exit
                            pt param.hover_height(1) 0
                            pt 0 0]); % move
                        cat = vertcat(cat,{fillType;'exit';'move'});
                    end
                    ppt = pt;
                elseif contains(cmd,{'X','Y'}) && contains(comment,{'INFILL'}) % extrude to the next point
                    pt = parseline(cmd);
                    %                     if mat(end,3) == param.hover_height(1) % if currently at the hover height,
                    %                         mat = vertcat(mat,[ppt 0 0;... % drop to floor
                    %                             pt 0 1]); % print to next point
                    %                     else % keep printing
                    mat = vertcat(mat,[pt 0 0.9]);                    
                    ppt = pt;
                    fillType = 'infill';
                    cat = vertcat(cat,{fillType});
                elseif contains(cmd,{'X','Y'}) && contains(comment,{'PERIMETER'}) % extrude to the next point
                    pt = parseline(cmd);
                    mat = vertcat(mat,[pt 0 1]);
                    ppt = pt;
                    fillType = 'perimeter';
                    cat = vertcat(cat,{fillType});
                elseif contains(comment,'UNRETRACT') && ~ismember(ppt,[0 0],'rows')
                    mat = vertcat(mat,[ppt 0 0]);  % drop to floor
                    cat = vertcat(cat,{'approach'});
                elseif contains(comment,'RETRACT') && ~ismember(ppt,[0 0],'rows')
                    mat(end,4) = 0;
                    mat = vertcat(mat,[ppt param.hover_height(1) 0]);
                    cat = vertcat(cat,{'exit'});
                else
                    % disp(cmd)
                end
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
    end
end
fclose(fidi);
cat = categorical(cat);
mat(ismember(mat,[0 0 0 0],'rows'),:) = [];
if mat(end,3) == 0
    mat = [mat; mat(end,:)+[0,0,param.hover_height(1),0]];
end
end

% parse the new inputline into the G code
function pt = parseline(tline)
if contains(tline,';')
    tline = extractBefore(tline,';');
end
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
end