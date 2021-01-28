obj = serial('com4','baudrate',250000)
fopen(obj)
pause(1)
cmd = readBuffer(obj);
fprintf(obj,'G28')
cmd = readBuffer(obj)
fprintf(obj,'G1 X10 Z2')
cmd = readBuffer(obj)
fprintf(obj,'M114')
cmd = readBuffer(obj)
fclose(obj)

function out = readBuffer(obj)
int = fgetl(obj);out = [];
while ~isempty(int) || contains(int,'ok\n')
    out = [out,int];
   int = fgetl(obj)
end
end