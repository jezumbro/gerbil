function [out,xlength,waitTime] = writeOptimizedscript(param,directory,filename,randomTF)
% writeOptimizedscript -


%% Setup parameter sweeps
% Nozzel Parameters
% nozzelsn = repmat([param.nozzel.sn ','],1,steps);
% nozzelid =  param.nozzel.id.*ones(1,steps);
% nozzelod =  param.nozzel.od.*ones(1,steps);

% Line Parameters
% line_width   = param.line_width.*ones(1,steps);
% line_height  = param.line_height.*ones(1,steps);
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
% Pressue
% pressure         =  param.pressure.*ones(1,num);
%% Movement declariation
time = param.wait_time(1);
xstep = param.linelength;
ystep = param.stepsize;

fidns = fopen([directory filename '\Scripts\' filename '-psj_script.txt'],'w');

fprintf(fidns,['// Created: %s \n'...
    'speed 30\n'...
    'move 0 0 %.3f\n'],datestr(datetime),...
    hover_height(1)+dispensegap(1));

for n = 1:num
    if randomTF
        xstep = 10*rand(1);
    end       
    waitTime(n) = param.wait_time(1)-time;
    if time < param.wait_time(1)
        fprintf(fidns,'wait %.3f // Delay for wait time...\n',...
            param.wait_time(1)-time);
        time = 0;
    else
    end
    
    fprintf(fidns,['//Line %g\n',...
        'speed %.3f\n'... Start print line
        'move 0 0 -%.3f\n'...
        'valverel %.3f %.3f\n'...
        'wait %.3f\n'...
        'speed %.3f\n'...
        'move %.3f 0 0\n'],...
        n,...
        approachspeed(n),...
        hover_height(n),...
        ovalvedist(n),ovalvespeed(n),...
        ovalvedelay(n),...
        printspeed(n),...
        xstep);
    fprintf(fidns,['valverel 0.000 %.3f\n'... End print line
        'wait %.3f\n'...
        'speed %.3f\n'...
        'move 0 0 %.3f\n'],...
        cvalvespeed(n),...
        cvalvedelay(n),...
        exitspeed(n),...
        (hover_height(n)+(dispensegap(n+1)-dispensegap(n))));
    if n ~= num
        fprintf(fidns,['speed %.3f\n'...
            'move -%.3f %.3f 0\n'],...
            movespeed(n),...
            xstep,ystep);
        time = (hover_height(n)+(dispensegap(n+1)-dispensegap(n)))/exitspeed(n)...
            + norm([xstep,ystep])/movespeed(n)...
            +hover_height(n+1)./approachspeed(n+1);
    end
    xlength(n) = xstep;
end    
% fprintf(fidns,['speed %.3f\n'...
%             'move -%.3f -%.3f 0\n'],...
%             movespeed(n),...
%             xstep,num*ystep);
out = fclose(fidns);
end
