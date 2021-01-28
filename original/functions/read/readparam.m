function param = readparam(filename)
T = readtable(filename);
param.line_width    = [T.value(strcmpi(T.parameter,'line_width')) 0];
param.line_height   = [T.value(strcmpi(T.parameter,'line_height')) 0];
param.hover_height  = [T.value(strcmpi(T.parameter,'hover_height')) 0];
param.dispensegap   = [T.value(strcmpi(T.parameter,'dispensegap')) 0];
param.printspeed    = [T.value(strcmpi(T.parameter,'printspeed')) 0];
param.movespeed     = [T.value(strcmpi(T.parameter,'movespeed')) 0];
param.approachspeed = [T.value(strcmpi(T.parameter,'approachspeed')) 0];
param.exitspeed     = [T.value(strcmpi(T.parameter,'exitspeed')) 0];
param.ovalve.dist   = [T.value(strcmpi(T.parameter,'openvalvedist')) 0];
param.ovalve.speed  = [T.value(strcmpi(T.parameter,'openvalvespeed')) 0];
param.ovalve.delay  = [T.value(strcmpi(T.parameter,'openvalvedelay')) 0];
param.cvalve.speed  = [T.value(strcmpi(T.parameter,'closevalvespeed')) 0];
param.cvalve.delay  = [T.value(strcmpi(T.parameter,'closevalvedelay')) 0];
param.pressure      = [T.value(strcmpi(T.parameter,'pressure')) 0];
if any(contains(T.parameter,'wait_time'))
    param.wait_time      = [T.value(strcmpi(T.parameter,'wait_time')) 0];
else
    param.wait_time      = [0 0];
end
end