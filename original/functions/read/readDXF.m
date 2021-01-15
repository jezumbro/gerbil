function [AutoCAD] = readDXF(filename)
% readDXFfile - read entities information of dxf file
% author = jezumbro
%
debugTF = true;
i = 1;
iblk = 1;
%% Read dxf file
fid = fopen(filename);    % Read filename of .dxf file
code = strtrim(fgetl(fid));tline = 'SOF';
while ~strcmpi(tline,'EOF')
    switch code % Entity or other
        case '0' % text string - Entity type
            tline = fgetl(fid);
            switch tline
                case 'ARC'
                    [AutoCAD(i,:), code] = readArc(fid);i=i+1;
                case 'BLOCK'
                    [tb,code] = readBlock(fid,tline);
                    if ~isempty(tb)
                        block(iblk,:) = tb;iblk = iblk+1;tb = {};
                    end
                case 'LINE'
                    [AutoCAD(i,:), code] = readLine(fid);i=i+1;
                case 'LWPOLYLINE'
                    [AutoCAD(i,:),code] = readLWpolyline(fid);i=i+1;
                case 'CIRCLE'
                    [AutoCAD(i,:),code] = readCircle(fid);i=i+1;
                case 'HATCH'
                    [AutoCAD(i,:), code] = readHatch(fid);i=i+1;
                case 'SOLID'
                    [AutoCAD(i,:), code] = readSolid(fid);i=i+1;
                case 'EOF'
                case 'SECTION'
                    code = strtrim(fgetl(fid));
                case 'INSERT'
                    [AutoCAD(i,:), code] = readInsert(fid,block);i = i+1;
                case 'POLYLINE'
                    [AutoCAD(i,:),code] = readPolyline(fid,tline);i=i+1;
                otherwise
                    %disp(tline)
            end
        case '9'
            tline = fgetl(fid);
            if strcmpi(tline,'$INSUNITS')
                code = strtrim(fgetl(fid));
                unitvalue = str2double(fgetl(fid));
            end
            code = strtrim(fgetl(fid));
        otherwise
            tline = fgetl(fid);
            code = strtrim(fgetl(fid));
    end
end
fclose(fid);
AutoCAD(strcmpi(AutoCAD(:,2),'NAN'),:) = [];
switch unitvalue
    case {0,1}
        la.solid = strcmpi(AutoCAD(:,2),'SOLID');
        la.circ = strcmpi(AutoCAD(:,2),'CIRCLE');
        la.line = strcmpi(AutoCAD(:,2),'LINE');
        la.lwpoly = strcmpi(AutoCAD(:,2),'LWPOLYLINE');
        AutoCAD(la.solid,1) = cellfun(@(x) x(:,:)*25.4,AutoCAD(la.solid,1),'UniformOutput',false);
        AutoCAD(la.circ,1) = cellfun(@(x) x(:,:)*25.4,AutoCAD(la.circ,1),'UniformOutput',false);
        AutoCAD(la.line,1) = cellfun(@(x) x(:,:)*25.4,AutoCAD(la.line,1),'UniformOutput',false);
        AutoCAD(la.lwpoly,1) = cellfun(@(x) [x(1:end-1,1:2)*25.4 x(1:end-1,3:end);x(end,1), x(end,2)*25.4, x(end,3:end)],AutoCAD(la.lwpoly,1),'UniformOutput',false);
    otherwise
end
end
function [AutoCAD, code] = readArc(fid)
code = fgetl(fid);
while ~strcmpi(strtrim(code),'0')
    tline = fgetl(fid);
    switch code % Line Entity
        case '8'
            layer = tline;
        case '10'
            tmat(1) = str2double(tline);
        case '20'
            tmat(2) = str2double(tline);
        case '40'
            tmat(3) = str2double(tline);
        case '50'
            tmat(4) = str2double(tline);
        case '51'
            tmat(5) = str2double(tline);
    end
    code = strtrim(fgetl(fid));
end
AutoCAD = {round(tmat,6),'ARC',layer};clear tmat
end
function [block,code] = readBlock(fid,tline)
code = fgetl(fid);
while ~strcmpi(strtrim(tline),'ENDBLK')
    tline = fgetl(fid);
    switch code % Line Entity
        case '0'
            switch tline
                case 'ARC'
                    [b, code]=readArc(fid);
                    tline = fgetl(fid);
                case 'CIRCLE'
                    [b, code]=readCircle(fid);
                    tline = fgetl(fid);
                case 'LINE'
                    [b, code]=readLine(fid);
                    tline = fgetl(fid);
                case 'LWPOLYLINE'
                    [b, code]=readLWpolyline(fid);
                    tline = fgetl(fid);
                case 'HATCH'
                    [b, code]=readHatch(fid);
                    tline = fgetl(fid);
                case 'SOLID'
                    [b, code]=readSolid(fid);
                    tline = fgetl(fid);
                otherwise
                    %disp(tline)
            end
        case '2'
            tname = tline;
        case '8'
            layer = tline;
    end
    code = strtrim(fgetl(fid));
end
if exist('b','var')
    block = {tname, b{:}};
else
    block = {};
end
end
function [AutoCAD, code] = readLine(fid)
code = fgetl(fid);
while ~strcmpi(strtrim(code),'0')
    tline = fgetl(fid);
    switch code % Line Entity
        case '8'
            layer = tline;
        case '10'
            tmat(1) = str2double(tline);
        case '20'
            tmat(2) = str2double(tline);
        case '30'
            tmat(3) = str2double(tline);
        case '11'
            tmat(4) = str2double(tline);
        case '21'
            tmat(5) = str2double(tline);
        case '31'
            tmat(6) = str2double(tline);
    end
    code = strtrim(fgetl(fid));
end
AutoCAD = {round(tmat,6),'LINE',layer};
end
function [AutoCAD, code] = readCircle(fid)
code = fgetl(fid); twidth = 0;
while ~strcmpi(strtrim(code),'0')
    tline = fgetl(fid);
    switch code % Line Entity
        case '8'
            layer = tline;
        case '10'
            tmat(1) = str2double(tline);
        case '20'
            tmat(2) = str2double(tline);
        case '39'
            twidth = str2double(tline);
        case '40'
            tmat(3) = str2double(tline);
            
    end
    code = strtrim(fgetl(fid));
end
AutoCAD = {round(tmat,6),'CIRCLE',layer};clear tmat
end
function [AutoCAD, code] = readLWpolyline(fid)
vi = 1;
code = fgetl(fid);tclosed = 0;twidth = 0;
while ~strcmpi(strtrim(code),'0')
    tline = fgetl(fid);
    switch code
        case '8'
            layer = tline;
        case '10'
            tmat(vi,1) = str2double(tline);
        case '20'
            tmat(vi,2) = str2double(tline);
            tmat(vi,3) = 0;
            vi = vi+1;
        case '42'
            tmat(vi-1,3) = str2double(tline);
        case '43'
            twidth = str2double(tline);
        case '70'
            tclosed = str2double(tline);
    end
    code = strtrim(fgetl(fid));
end
tmat(end+1,:) = [tclosed twidth NaN];
AutoCAD = {round(tmat,6),'LWPOLYLINE',layer};
end
function [AutoCAD, code] = readPolyline(fid,tline)
vi = 1;
code = fgetl(fid);tclosed = 0;twidth = 0;
while ~strcmpi(strtrim(tline),'SEQEND')
    tline = fgetl(fid);
    switch code
        case '8'
            layer = tline;
        case '10'
            tmat(vi,1) = str2double(tline);
        case '20'
            tmat(vi,2) = str2double(tline);
            tmat(vi,3) = 0;
            vi = vi+1;
        case '39'
            twidth = str2double(tline);
        case '42'
            tmat(vi-1,3) = str2double(tline);
        case '70'
            tclosed = str2double(tline);
    end
    code = strtrim(fgetl(fid));
end
tmat(end+1,:) = [tclosed twidth NaN];tmat(1,:) = [];
AutoCAD = {round(tmat,6),'LWPOLYLINE',layer};
end
function [AutoCAD, code] = readSolid(fid)
code = fgetl(fid);
while ~strcmpi(strtrim(code),'0')
    tline = fgetl(fid);
    switch code % Line Entity
        case '8'
            layer = tline;
        case '10'
            tmat(1,1) = str2double(tline);
        case '20'
            tmat(1,2) = str2double(tline);
        case '11'
            tmat(2,1) = str2double(tline);
        case '21'
            tmat(2,2) = str2double(tline);
        case '12'
            tmat(3,1) = str2double(tline);
        case '22'
            tmat(3,2) = str2double(tline);
        case '13'
            tmat(4,1) = str2double(tline);
        case '23'
            tmat(4,2) = str2double(tline);
    end
    code = strtrim(fgetl(fid));
end
AutoCAD = {round(tmat,6),'SOLID',layer};clear tmat
end
function [AutoCAD, code] = readHatch(fid)
code = fgetl(fid);vi = 1;
while ~strcmpi(strtrim(code),'0')
    tline = fgetl(fid);
    switch code % Line Entity
        case '8'
            layer = tline;
        case '10'
            tmat(vi,1) = str2double(tline);
        case '20'
            tmat(vi,2) = str2double(tline);
            vi = vi+1;
    end
    code = strtrim(fgetl(fid));
end
tmat(any(tmat(:,:) == [0 0],2),:) = [];
AutoCAD = {round(tmat,6),'HATCH',layer};clear tmat
end
function [AutoCAD, code] = readInsert(fid,block)
code = fgetl(fid);
while ~strcmpi(strtrim(code),'0')
    tline = fgetl(fid);
    switch code % Line Entity
        case '2'
            la = strcmpi(block(:,1),tline);
        case '8'
            layer = tline;
        case '10'
            tmat(1) = str2double(tline);
        case '20'
            tmat(2) = str2double(tline);
    end
    code = strtrim(fgetl(fid));
end
if sum(la) == 1
    ts = size(block{la,2},2);
    tmat = [tmat zeros(1,ts-2)]+block{la,2};
    AutoCAD = {round(tmat,6),block{la,3},layer};clear tmat
else
    AutoCAD = {[0 0],'NaN','None'};
end
end