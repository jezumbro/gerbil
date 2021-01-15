function [layer,alignment] = readRS274X(filename)
alignment = zeros(2,2);alignmenti = 1;
debugTF = false;
if debugTF; figure(1); clf; hold on;end
fidi = fopen(filename);
tline = fgetl(fidi); tooli = 0;ppt = [0,0];pd = [];
pout = polyshape();DT = table();
disp('Reading File...')
while ischar(tline)
    temp = strsplit(tline,'*');temp1 = temp(~cellfun(@(x) isempty(x),temp));
    for n = 1:size(temp1,2)
        tline2 = temp1{n};
        if n > 1 & startsWith(temp1{1},'%') & ~startsWith(temp1{n},'%')
            tline2 = ['%' tline2];         
        end
        if debugTF; fprintf([tline2 '\n']);end
        if length(tline2) >= 3
            switch tline2(1:3)
                case '%AD' % aperature
                    tline2 = erase(tline2,{'%AD'});
                    str = strsplit(tline2,',');
                    type = {str{1}(end)};
                    name = {str{1}(1:end-1)};
                    switch type{1}
                        case 'R'
                            mat = {cellfun(@(x) str2double(x),strsplit(str{2},'X'))};
                        case 'C'
                            mat = {str2double(str{2})};
                    end
                    DT = [DT;table(name,type,mat)];
                case '%MO' % unit
                    form.unit = erase(tline2,{'%MO'});
                case '%FS' % format
                    tline2 = erase(tline2,{'%FS'});
                    form.x = tline2(strfind(tline2,'X')+[1,2]);
                    form.y = tline2(strfind(tline2,'Y')+[1,2]);
                case '%LN'
                    form.name = erase(tline2,{'%LN'});
                case 'G01' % move linearly
                    tline2 = erase(tline2,'G01');
                    if ~isempty(tline2)
                        [pout(end+1),ppt,pd] = readDcode(tline2,form,DT(tooli,:),ppt,pd);
                    end
                case 'G02'
                    disp('zeke')
                case 'G03'
                    disp('zeke')
                case 'G04' % comment
                    if contains(tline,'nScrypt-FFJ1')
                        a = extractAfter(tline,'nScrypt-FFJ1');
                        pt = readFormat(a,form,[0,0]);
                        alignment(1,1:2) = pt(1:2);
                    elseif contains(tline,'nScrypt-FFJ2')
                        a = extractAfter(tline,'nScrypt-FFJ2');
                        pt = readFormat(a,form,[0,0]);
                        alignment(2,1:2) = pt(1:2);
                    elseif contains(tline,'nScrypt-FFJ')
                        a = extractAfter(tline,'nScrypt-FFJ');
                        pt = readFormat(a,form,[0,0]);
                        alignment(alignmenti,1:2) = pt(1:2);
                        alignmenti = alignmenti + 1;
                    else
%                         disp('none')
                    end
                case 'G36' % region
                    temp1 = [];tline2 = [];
                    while ~strcmpi(tline2,'G37*')
                        temp1 = horzcat(temp1,tline2);
                        tline2 = fgetl(fidi);
                    end
                    temp1 = strsplit(temp1,'*');
                    temp1 = temp1(~cellfun(@(x) isempty(x),temp1));
                    if any(contains(temp1,{'G02','G03', 'G75' 'G74'}))
                        A = strip(num2str([any(contains(temp1,'G03')) any(contains(temp1,'G02'))...
                            any(contains(temp1,'G75')) any(contains(temp1,'G74'))]));
                        A= A(~isspace(A));
                        switch A
                            case '1010' % contains G2 and G75 commands
                                for n = 1:size(temp1,2)
                                    if debugTF; fprintf([temp1{n} '\n']);end
                                    [pt] = readFormat(temp1{n},form,ppt);
                                    if norm(pt(1,3:4))
                                        pout(end+1) = polybuffer(pt(1:2)+pt(3:4),'points',norm(pt(1,3:4)));
                                        ppt = pt(1:2);pt = [];
                                    else
                                        ppt = pt(1:2);pt = [];
                                    end
                                end
                            case '1100'
                                pts = [];
                                for n = 1:size(temp1,2)
                                    if debugTF; fprintf([temp1{n} '\n']);end
                                    [pt] = readFormat(temp1{n},form,ppt);
                                    if debugTF; plot(pt(:,1),pt(:,2),'.');end
                                    if startsWith(temp1(n),'G03') || startsWith(temp1(n),'G02')
                                        cpt = [pt(3)+ppt(1),pt(4)+ppt(2)];
                                        a_ppt = mod(atan2(ppt(2)-cpt(2),ppt(1)-cpt(1))+2*pi,2*pi);
                                        a_pt = mod(atan2(pt(2)-cpt(2),pt(1)-cpt(1))+2*pi,2*pi);
                                        if a_pt == 0 && a_ppt > pi; a_pt = 2*pi; end
                                        if a_ppt == 0 && a_pt > pi; a_ppt = 2*pi; end
                                        r = norm(pt(1,3:4));
                                        ang = linspace(a_ppt,a_pt,ceil(2*pi*r*(abs(a_pt-a_ppt))/0.1))';
                                        t_pts = r*[cos(ang),sin(ang)]+cpt;      
                                        pts = [pts;t_pts];
                                        ppt = pt(1:2);pt = [];
                                    else
                                        pts = [pts;pt(1:2)];
                                        ppt = pt(1:2);pt = [];                                        
                                    end
                                    if debugTF; plot(pts(:,1),pts(:,2),'.-');end
                                end
                                pout(end+1) = polyshape(pts);
                            otherwise
                                disp('error')
                        end
                    else
                        pts = [];
                        for n = 1:size(temp1,2)
                            [pt] = readFormat(temp1{n},form,ppt);
                            pts(end+1,:) = pt(1:2);
                            ppt = pts(n,:);
                        end
                        pout(end+1) = polyshape(pts);
                    end
                    %                     end
                case 'G54'
                    tline2 = erase(tline2,'G54');
                    tooli = find(contains(DT.name,tline2),1,'first');
                    
                otherwise
                    if ~isempty(DT) && contains(tline2,DT.name) %% switch to a tool
                        tooli = find(contains(DT.name,tline2),1,'first');
                    elseif contains(tline2,{'D01','D02','D03'}) % do something based on input D codes
                        [pout(end+1),ppt,pd] = readDcode(tline2,form,DT(tooli,:),ppt,pd);
                    else
                        %                         disp(tline2)
                        %                         fprintf('')
                    end
            end
        end
    end
    tline = fgetl(fidi);
    if debugTF
        figure(1);cla;plot(pout)
        fprintf('%d\n',length(pout)')
    end
end
disp('Done')
disp('Combining File...')
eps = 0.001;
layer1 = union(pout);
layer0 = polybuffer(layer1,eps,'JointType','miter','MiterLimit',2);
layer = polybuffer(layer0,-eps,'JointType','miter','MiterLimit',2);
if strcmpi(form.unit,'IN')
    layer = scale(layer,25.4);
end
disp('Done')
end

%% Read the plot codes in the file and construct the corresponding polyshape
function [pout,pt,d] = readDcode(temp,form,tool,ppt,pd)
[pt] = readFormat(temp,form,ppt);pt = pt(1:2);
d = ['D', extractAfter(temp,'D')];
if strcmpi(d,'D');d=pd;end
switch [tool.type{1} d]
    case 'CD03'
        if strcmpi(form.unit,'IN')
            pts = linspace(0,2*pi,floor(2*tool.mat{1}/.001))';
        else
            pts = linspace(0,2*pi,floor(2*tool.mat{1}/.0254))';
        end
        pout = polyshape(0.5*tool.mat{1}.*[cos(pts), sin(pts)]+[pt]);
    case 'RD03'
        pts = pt+[-tool.mat{1}/2;
            -tool.mat{1}(1)/2, tool.mat{1}(2)/2;
            tool.mat{1}/2;
            tool.mat{1}(1)/2, -tool.mat{1}(2)/2];
        pout = polyshape(pts);
    case 'CD02'
        pout = polyshape();
    case 'RD02'
        pout = polyshape();
    case 'CD01'
        a = atan2d(ppt(2)-pt(2),ppt(1)-pt(1));
        pts = [ppt;
            ppt;
            pt;
            pt]+...
            [cosd(a-90)*tool.mat{1}(1)/2, sind(a-90)*tool.mat{1}(1)/2;
            cosd(a+90)*tool.mat{1}(1)/2, sind(a+90)*tool.mat{1}(1)/2;
            cosd(a+90)*tool.mat{1}(1)/2, sind(a+90)*tool.mat{1}(1)/2;
            cosd(a-90)*tool.mat{1}(1)/2, sind(a-90)*tool.mat{1}(1)/2];
        
        if strcmpi(form.unit,'IN')
            b = floor(2*tool.mat{1}/.001);
        else
            b = floor(2*tool.mat{1}/.0254);
        end
        if b <=10;pts1 = linspace(0,2*pi,10)';
        else
            pts1 = linspace(0,2*pi,b)';
        end
        p(1) = polyshape(0.5*tool.mat{1}.*[cos(pts1), sin(pts1)]+pt);
        p(2) = polyshape(0.5*tool.mat{1}.*[cos(pts1), sin(pts1)]+ppt);
        p(3) = polyshape(pts);
        pout = union(p);
    case 'RD01'
        pts = [min([x ppt(1)]) min([y ppt(2)]);
            min([x ppt(1)]) max([y ppt(2)]);
            max([x ppt(1)]) max([y ppt(2)]);
            max([x ppt(1)]) min([y ppt(2)])]+...
            [-tool.mat{1}/2 ;
            -tool.mat{1}(1)/2, tool.mat{1}(2)/2;
            tool.mat{1}/2;
            tool.mat{1}(1)/2, -tool.mat{1}(2)/2];
        pout = polyshape(pts);
    otherwise
        pout = polyshape();
        disp([tool.type{1} d ' ' temp])
end

end
%% Read format of the input string
function [pt] = readFormat(temp,form,ppt)
A = strip(num2str([contains(temp,'X') contains(temp,'Y')...
    contains(temp,'I') contains(temp,'J')...
    contains(temp,'D') contains(temp,'*')])); A= A(~isspace(A));
switch A
    case {'111110'}
        x = readNumber(extractBetween(temp,'X','Y'),[form.x]);
        y = readNumber(extractBetween(temp,'Y','I'),[form.y]);
        i = readNumber(extractBetween(temp,'I','J'),[form.x]);
        j = readNumber(extractBetween(temp,'J','D'),[form.y]);
    case {'110010','110011'} % has xyd in array
        x = readNumber(extractBetween(temp,'X','Y'),[form.x]);
        y = readNumber(extractBetween(temp,'Y','D'),[form.y]);
        i = 0; j = 0;
    case '110001' % has xy and no d in array
        x = readNumber(extractBetween(temp,'X','Y'),[form.x]);
        y = readNumber(extractBetween(temp,'Y','*'),[form.y]);
        i = 0; j = 0;
    case '110000' % has XY no d or *
        x = readNumber(extractBetween(temp,'X','Y'),[form.x]);
        y = readNumber({extractAfter(temp,'Y')},[form.y]);
        i = 0; j = 0;
    case {'100010','100011'} % has xd no y
        x = readNumber(extractBetween(temp,'X','D'),[form.x]);
        y = ppt(2); i = 0; j = 0;
    case '100001'
        x = readNumber(extractBetween(temp,'X','*'),[form.x]);
        y = ppt(2); i = 0; j = 0;
    case '100000'
        x = readNumber({extractAfter(temp,'X')},[form.x]);
        y = ppt(2); i = 0; j = 0;
    case {'010011','010010'}
        x = ppt(1); i = 0; j = 0;
        y = readNumber(extractBetween(temp,'Y','D'),[form.y]);
    case '010001'
        x = ppt(1); i = 0; j = 0;
        y = readNumber(extractBetween(temp,'Y','*'),[ form.y]);
    case '010000'
        x = ppt(1); i = 0; j = 0;
        y = readNumber({extractAfter(temp,'Y')},[form.y]);
    otherwise
        x = ppt(1);
        y = ppt(2);
        i = 0; j = 0;
end
pt = [x,y,i,j];
end
function num = readNumber(strin,form)
if ~isempty(strin)
    strin = strin{1};
    t = str2double(form(end));
    num = str2double(strin)/10^t;
else
    num = nan;
end
end

