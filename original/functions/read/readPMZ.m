% readPMZ(filename)
filename = 'C:\Transfer\Installs\MtGen3\Projects\Material\MapData\NewScan.pmz'
fid = fopen(filename,'r');
tline = fgetl(fid);
raw = []; axisInd = 1;
while ~feof(fid)
    if startsWith(tline,';')
        if contains(tline,{'[Axis.0]','[Axis.1]','[Axis.2]'})
            for n = 1:17
                tline = fgetl(fid);
                switch n
                    case 1
                        axis(axisInd).name = extractAfter(tline,'=')
                    case 3
                        axis(axisInd).count = str2num(extractAfter(tline,'='))
                    otherwise
                        % do nothing
                end
            end
            axisInd = axisInd + 1;
        else
%             disp('comment')
        end
    else
        raw = [raw;str2num(tline)];
%         disp(tline)
    end
        tline = fgetl(fid);
end
fclose(fid);
data = [raw(:,2)/axis(1).count,raw(:,5)/axis(2).count,raw(:,8)/axis(3).count]
plot(data(:,1),data(:,2),'.-')