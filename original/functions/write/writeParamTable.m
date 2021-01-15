function writeParamTable(param,p,fileInfo)
[path,name,~] = fileparts(fileInfo);
varname = strsplit(name,'_');
d = datetime;
saveDirPath = [path '\optimization\' sprintf('%i%i%i',year(d),month(d),day(d)) ...
    '\' sprintf('%0.f-%.0f-%.0f',hour(d),minute(d),second(d)) '\'];
if ~exist(saveDirPath,'dir')
    mkdir(saveDirPath)   
end
filename = [saveDirPath sprintf('%0.f-%.0f-%.0f_%s_%s',hour(d),minute(d),second(d),...
    varname{2}, varname{3}) '.csv'];
%% parse paramters
num = param.numberofsteps(1);
% Line Distances
if param.hover_height(2) ~= param.hover_height(1) && param.hover_height(2) ~= 0
    hover_height = linspace(param.hover_height(1),param.hover_height(2),num);
else
    hover_height =  param.hover_height(1).*ones(1,num);
end
if param.dispensegap(2) ~= param.dispensegap(1) && param.dispensegap(2) ~= 0
    dispensegap = linspace(param.dispensegap(1),param.dispensegap(2),num);
    dispensegap(num+1) = dispensegap(num);
else
    dispensegap =  param.dispensegap(1).*ones(1,num+1);
end


% Speeds
if param.printspeed(2) ~= param.printspeed(1) && param.printspeed(2) ~= 0
    printspeed = linspace(param.printspeed(1),param.printspeed(2),num);
else
    printspeed = param.printspeed(1).*ones(1,num);
end

if param.movespeed(2) ~= param.movespeed(1) && param.movespeed(2) ~= 0
    movespeed = linspace(param.movespeed(1),param.movespeed(2),num);
else
    movespeed= param.movespeed(1).*ones(1,num);
end

if param.approachspeed(2) ~= param.approachspeed(1) && param.approachspeed(2) ~= 0
    approachspeed = linspace(param.approachspeed(1),param.approachspeed(2),num);
else
    approachspeed = param.approachspeed(1).*ones(1,num);
end

if param.exitspeed(2) ~= param.exitspeed(1) && param.exitspeed(2) ~= 0
    exitspeed = linspace(param.exitspeed(1),param.exitspeed(2),num);
else
    exitspeed = param.exitspeed(1).*ones(1,num);
end
% Valve open parameters
if param.ovalve.dist(2) ~= param.ovalve.dist(1) && param.ovalve.dist(2) ~= 0
    ovalvedist = linspace(param.ovalve.dist(1),...
        param.ovalve.dist(2),num);
else
    ovalvedist = param.ovalve.dist(1).*ones(1,num);
end

if param.ovalve.speed(2) ~= param.ovalve.speed(1) && param.ovalve.speed(2) ~= 0
    ovalvespeed = linspace(param.ovalve.speed(1),...
        param.ovalve.speed(2),num);
else
    ovalvespeed = param.ovalve.speed(1).*ones(1,num);
end

if param.ovalve.delay(2) ~= param.ovalve.delay(1) && param.ovalve.delay(2) ~= 0
    ovalvedelay = linspace(param.ovalve.delay(1),...
        param.ovalve.delay(2),num);
else
    ovalvedelay = param.ovalve.delay(1).*ones(1,num);
end
% Valve close parameters
if param.cvalve.speed(2) ~= param.cvalve.speed(1) && param.cvalve.speed(2) ~= 0
    cvalvespeed = linspace(param.cvalve.speed(1),...
        param.cvalve.speed(2),num);
else
    cvalvespeed      =  param.cvalve.speed(1).*ones(1,num);
end

if param.cvalve.delay(2) ~= param.cvalve.delay(1) && param.cvalve.delay(2) ~= 0
    cvalvedelay = linspace(param.cvalve.delay(1),...
        param.cvalve.delay(2),num);
else
    cvalvedelay      =  param.cvalve.delay(1).*ones(1,num);
end


fid = fopen(filename,'w');
% Write inforamtion about the header of the file
fprintf(fid,['LineNumber,line_length,line_width,line_height,hover_height,'...
    'dispensegap,printspeed,movespeed,approachspeed,exitspeed,'...
    'openvalvedist,openvalvespeed,openvalvedelay,closevalvespeed,'...
    'closevalvedelay,pressure,wait_time,\n']);
for n = 1:num
    fprintf(fid,'%.3f,',...
        n,...
        p.length(n),...
    param.line_width(1),...
    param.line_height(1),...
    hover_height(n),...
    dispensegap(n),...
    printspeed(n),...
    movespeed(n),...
    approachspeed(n),...
    exitspeed(n),...
    ovalvedist(n),...
    ovalvespeed(n),...
    ovalvedelay(n),...
    cvalvespeed(n),...
    cvalvedelay(n),...
    param.pressure(1),...
    p.waitTime(n));
fprintf(fid,'\n');
end
output = fclose(fid);flag = true;
f = waitbar(0,'Waiting on GMJ...');
while (datetime - d) < 	minutes(60) && flag
    waitbar(minutes(datetime -d)/60,f, 'Waiting on GMJ...')
    info = dir('C:\Transfer\Installs\MtGen3\Projects\Material\MapData\material_line9gmj.zmg');
    if ~isempty(info) && d < datetime(info.date)  
        waitbar(59/60 ,f, 'Found GMJ...')
        pause(60)
        copyfile('C:\Transfer\Installs\MtGen3\Projects\Material\MapData\',saveDirPath)
        waitbar(1, f, 'Copied Files')
        flag = false;
    end
end
close(f)
for n = 0:num-1
   delete(['C:\Transfer\Installs\MtGen3\Projects\Material\MapData\material_line' num2str(n) 'gmj.zmg'])
end
end