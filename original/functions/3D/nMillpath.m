clear;
% NOTE: ALL UNITS ARE MM
% AM Lines 1: Big Shell,             x: 27.584 y: 11.018 z: 0.500 
% AM Lines 2: Center with one inlet, x: 26.213 y:  6.319 z: 1.500
% AM Lines 3: Center with two inlets x: 27.584 y:  6.319 z: 2.000
% AM Lines 4: 2 ends, long middle    x: 27.584 y:  6.319 z: 0.500
% AM Lines 5: 2 ends, small middle   x: 27.584 y:  6.319 z: 0.500
x = 3; % mm
y = 3; % mm
z = 0.7; % mm
xystep = 0.1; % mm
zstep  = 0.1; % mm
za = 0:-abs(zstep):-abs(z);
xa = -0.5*x:xystep:0.5*x;
data = [0 0 5];i = 1;
for n = 1:size(za,2)
    xa = fliplr(xa); i = i+2;
    if size(za,2) == n
        xa = linspace(xa(1),xa(end),2*size(xa,2));
    end
    for m = 1:size(xa,2)
        if mod(i,2)==0 % iseven
            data = [data;
                xa(m) -0.5*y za(n);
                xa(m) 0.5*y za(n)];
        else
            data = [data;
                xa(m) 0.5*y za(n);
                xa(m) -0.5*y za(n)];
        end
        i = i+1;
    end
end
data(end+1,:) = [0 0 5];
%% Plot Machine tool path
% figure(1);cla;hold on;
% for n = 2:size(data,1)
%     plot3(data(n-1:n,1),data(n-1:n,2),data(n-1:n,3),'k')
%     pause(0.01)
% end
%% Write machine tool path to file
filepath = ['C:\Transfer\Installs\MtGen3\Projects\'...
    'machine_k-state_amshielding\Scripts\psjscripts\'];
filename = 'amlines2';
fo = fopen([filepath filename '.txt'],'w');
fprintf(fo,['// %s.txt created from MATLAB nMillpath()\n'... print header
    '// Date: %s\n'...
    'speed 8\n'...
    'Mill Off\n'...
    'Mill_Direction CW\n'...
    'Mill On\n'...
    'wait 1\n'],filename,datestr(datetime));
fp = find(abs(data(:,3)) == z,1);
pts = [0 0 5;diff(data)];
for n = 1:size(pts,1)
    if n == fp
        fprintf(fo,'speed 10\n');
    end
    fprintf(fo,'move %.3f %.3f %.3f\n',pts(n,1),pts(n,2),pts(n,3));
end
fprintf(fo,'Mill Off\n');
fclose(fo);
