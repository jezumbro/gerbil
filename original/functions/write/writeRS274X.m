function status = writeRS274X(layer,layerName,outputDir,alignment)
% writeRS274X - takes in a polyshape layer and exports and gerber file to
% the outputFile location
% layer - polyshape input assumed MM system
% layerName - name of layer and file
% outputDir - directory of output

constant = 0.001; % merge points closer than this distance
% dxf = readDXF('C:\Users\jezumbro\Desktop\C2-KTH-001-B_8.7Aug6 2018.dxf');
% layer = constructDXF(dxf,layerName);
[~,yb] = boundingbox(layer);
r = layer.regions;
output = [];
for n = 1:size(r,1)
    if r(n).NumHoles % if the shape has holes
        rh = r(n).holes; rh(rh.area <= 1e-3) = []; % remove any holes less than 1 micron^2
        [xh,yh] = rh.centroid; % find the center of the holes
        xhm = cell2mat(arrayfun(@(n) [xh(n);xh(n)],(1:1:size(xh,1))',...
            'UniformOutput',false)); % order x coordinates for line
        yhm = cell2mat(arrayfun(@(n) [yh(n);yb(2)],(1:1:size(yh,1))',...
            'UniformOutput',false)); % order y coordinates for line
        lines = arrayfun(@(n) [xhm(n-1:n),yhm(n-1:n)],(2:2:size(xhm,1))',...
            'UniformOutput',false); % create lines in cell array
        line = []; % clear line
        for m = 1:size(lines,1)
            [in,~] = intersect(r(n),lines{m}); [~,i] = sort(in(:,2)-yh(m));
            inm = in(i,:);
            lines{m} = inm(1:2,:)+[0,-constant;0,constant];
            line = [line;lines{m};nan(1,2)];
        end
        sbound = [];
        for m = 1:size(lines,1)
            [in,~] = intersect(r(n),lines{m}); in = in(1:2,:);
            [xc,yc] = rh(m).boundary;if ispolycw(xc,yc); xc = flipud(xc);yc = flipud(yc);end
            [ptc,ic] = unique([xc,yc],'rows');ind = dsearchn(ptc(:,:).*(ptc(:,1)<in(1,1)),in(1,:));
            if ind == 1
                bound{m} = [[in(1,1);xc(ic(ind):end-1);in(1,1)],[in(1,2);yc(ic(ind):end-1);in(1,2)]];
            else
                bound{m} = [[in(1,1);xc(ic(ind):end-1);xc(1:ic(ind)-1);in(1,1)]...
                    ,[in(1,2);yc(ic(ind):end-1);yc(1:ic(ind)-1);in(1,2)]];
            end
            sbound = [sbound;in];
        end
        sbound(1:2:size(sbound),:) = [];
        [x,y] = r(n).boundary;ind = find(isnan(x(:,1)),1);pts = [x(1:ind-1),y(1:ind-1)];
        %         plot(x,y);
        if ~ispolycw(pts(:,1),pts(:,2)); pts = flipud(pts); end
        i = 2;opts = [pts(1,:)]; ep = []; pts(1,:) = [];
        while ~isempty(pts)
            if size(line,1) > 2
                [xi,yi] = intersections([opts(end,1); pts(1,1)],[opts(end,2); pts(1,2)],line(:,1)',line(:,2)');
            else
                xi = [];
            end
            if isempty(xi)
                opts = [opts;pts(1,:)];
                pts(1,:) = [];
            else
                opts = [opts;[xi(1),yi(1)]];
                if any(ismember(round(sbound,3),round([xi(1),yi(1)],3),'row'))
                    pts = [bound{ismember(round(sbound,3),round([xi(1),yi(1)],3),'row')};...
                        [xi(1),yi(1)];...
                        pts];
                    ind = find(ismember(round(line,3),round([xi(1),yi(1)+constant],3),'row'));
                    line(ind-1:ind,:) = [];
                else
                    disp('z')
                end
            end
            %             plot(opts(:,1),opts(:,2),'k.-')
        end
    else
        [x,y] = r(n).boundary;
        opts = [x,y];
        %         plot(opts(:,1),opts(:,2),'-')
    end
    output = [output;opts;nan(1,2)];
end
%% write corresponding gerber file
if ~endsWith(outputDir,'\'); outputDir = [outputDir '\'];end
[path,~,~] = fileparts(outputDir);
if ~exist(path,'dir')
    mkdir(path)
end
fid = fopen([path '\' layerName '.gbr'],'w');
fprintf(fid,['G04 Gerber FMT 4.6, Leading zero omitted, Abs format (unit mm)*\n'...
    'G04 Created by MATLAB writeRS274X() date: %s*\n'],datestr(datetime));
fprintf(fid,['G04 *\n'...
    '%%FSLAX46Y46*%%\n'...
    '%%MOMM*%%\n'...
    '%%SFA1.000B1.000*%%\n'...
    '%%MIA0B0*%%\n'...
    '%%IPPOS*%%\n'...
    '%%ADD14C,0.00200*%%\n']);
fprintf(fid,'%%LN%s*%%\n',layerName);
fprintf(fid,['%%LPD*%%\n'...
    'G36*\n']);
flag = 0;
for n = 1:size(output,1)
    if n == 1 || flag
        fprintf(fid,'X%.0fY%.0fD02*\n',output(n,1)*1e6,output(n,2)*1e6);
        flag = 0;
    elseif  n == size(output,1)
        fprintf(fid,'G37*\n');
    elseif isnan(output(n,1))
        fprintf(fid,['G37*\n'...
            'G36*\n']);
        flag = 1;
    else
        fprintf(fid,'G01X%.0fY%.0fD01*\n',output(n,1)*1e6,output(n,2)*1e6);
    end
end
if ~isempty(alignment)
    fprintf(fid,['G04 nScrypt-FFJ1 X%.3fY%.3f*\n'...
        'G04 nScrypt-FFJ2 X%.3fY%.3f*\n'],alignment(1,1),alignment(1,2),...
        alignment(2,1),alignment(2,2));
end
fprintf(fid,'%%LPD*%%\nM02*\n');
status = fclose(fid);
end