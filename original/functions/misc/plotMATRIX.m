function [T,vect] = plotMATRIX(axis,pts,delayTime,param)
dist = zeros(size(pts,1)-1,1); 
distcat = {'move'};
id = 1;
hold(axis,'on');zoom(axis,'on')
totalTime = 0;
if isempty(param)
    param.wait_time(1) = 0;
    param.approachspeed(1) = 0;
    param.exitspeed(1) = 0;
    param.movespeed(1) = 0;
    param.printspeed(1) = 0;
end
time = param.wait_time(1); speed = 30;
for n = 2:size(pts,1)
    temp = 10*round(pts(n-1,4))+round(pts(n,4));
    switch temp
        case {00} % general moves, approach speed, exit speed
            if pts(n,3) < pts(n-1,3) % move down at approach speed
                plot3(axis,pts(n-1:n,1),pts(n-1:n,2),pts(n-1:n,3),'c.--');  
                speed = param.approachspeed(1);
                moveTime = norm(diff(pts(n-1:n,1:3)))/speed;
                time = time + moveTime;
                distcat(id,1) = {'approach'};
            elseif pts(n,3) > pts(n-1,3) % move up at exit speed and set move speed                
                plot3(axis,pts(n-1:n,1),pts(n-1:n,2),pts(n-1:n,3),'m.--')
                speed = param.exitspeed(1);
                moveTime = norm(diff(pts(n-1:n,1:3)))/speed;
                time = moveTime; % reset time to new time interval
                speed = param.movespeed(1);
                distcat(id,1) = {'exit'};
            else % move at either print or move speed if no z change
                moveTime = norm(diff(pts(n-1:n,1:3)))/speed;
                time = time + moveTime;
                distcat(id,1) = {'move'};
                plot3(axis,pts(n-1:n,1),pts(n-1:n,2),pts(n-1:n,3),'g.--')
            end
        case {01} % turn on print
            if time < param.wait_time(1)
                delay = param.wait_time(1)-time;  
            else
                delay = 0;
            end
            speed = param.printspeed(1);
            plot3(axis,pts(n-1:n,1),pts(n-1:n,2),pts(n-1:n,3),'c.-')
            moveTime = delay + norm(diff(pts(n-1:n,1:3)))/speed;
            distcat(id,1) = {'on'};
        case {10, 20} % turn off print
            plot3(axis,pts(n-1:n,1),pts(n-1:n,2),pts(n-1:n,3),'m.-')
            moveTime = delay + norm(diff(pts(n-1:n,1:3)))/speed;
            distcat(id,1) = {'off'};
        case 11 % continue printing
            plot3(axis,pts(n-1:n,1),pts(n-1:n,2),pts(n-1:n,3),'b.-')
            moveTime = delay + norm(diff(pts(n-1:n,1:3)))/speed;
            distcat(id,1) = {'printing'};
        case {12, 22}
            plot3(axis,pts(n-1:n,1),pts(n-1:n,2),pts(n-1:n,3),'y.-')
            moveTime = delay + norm(diff(pts(n-1:n,1:3)))/speed;
            distcat(id,1) = {'fast print'};
        case 21
            plot3(axis,pts(n-1:n,1),pts(n-1:n,2),pts(n-1:n,3),'k.-')
            moveTime = delay + norm(diff(pts(n-1:n,1:3)))/speed;
            distcat(id,1) = {'printing'};
        otherwise
            disp(temp)
    end
    totalTime(n) = moveTime;
    dist(id,1) = norm(diff(pts(n-1:n,1:3)));id = id+1;
    pause(delayTime)
end
if ~isempty(param)
T = table(dist,distcat,'VariableNames',{'dist','cat'});
T.move_time = (T.dist.*(strcmpi(T.cat,'printing')))/param.printspeed(1);
T.move_time = T.move_time+T.dist.*(strcmpi(T.cat,'fast print'))/(2*param.printspeed(1));
T.move_time = T.move_time+T.dist.*(strcmpi(T.cat,'approach'))/param.approachspeed(1);
T.move_time = T.move_time+T.dist.*(strcmpi(T.cat,'exit'))/param.exitspeed(1);
T.move_time = T.move_time+T.dist.*(strcmpi(T.cat,'move'))/param.movespeed(1);

T.valve_time = param.ovalve.dist(1)*(strcmpi(T.cat,'on'))/param.ovalve.speed(1);
T.valve_time = T.valve_time + param.ovalve.dist(1)*(strcmpi(T.cat,'off'))/param.cvalve.speed(1);
T.delay_time = param.ovalve.delay(1)*(strcmpi(T.cat,'on'));
T.delay_time = T.delay_time + param.cvalve.delay(1)*(strcmpi(T.cat,'off'));
vect = [sum(T.move_time(contains(T.cat,'printing'))),...
    sum(T.move_time(contains(T.cat,'fast print'))),...
    sum(T.move_time(contains(T.cat,'move'))),...
    sum(T.move_time(contains(T.cat,'approach'))),...  
        sum(T.move_time(contains(T.cat,'exit'))),...
    sum(T.delay_time(contains(T.cat,'on'))),...
    sum(T.delay_time(contains(T.cat,'off'))),...
    sum(contains(T.cat,'on'))];
fprintf(['Total Time: %.4f sec\n'...
    'Print Time: %.4f sec\n'...
    'Valve Openings: %.0f\n'], sum(totalTime) ,sum(vect(1:2)),vect(end));
else
    T = [];
    vect = [];
end
end