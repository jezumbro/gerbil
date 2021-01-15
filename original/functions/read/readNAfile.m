function [out] = readNAfile(filename)
% readNAfile - read the network analyizer file into MATLAB
% filename - location of the file i.e. 'C:\Users\jezumbro\Desktop\FD_ZZ1
% Written by Zeke Zumbro - 05/25/2018
fid = fopen(filename); % open filename
tline = fgetl(fid); % get first line
out.data = []; % setup data varaiable
while ischar(tline) % loop until the file is completely read
    switch upper(tline(1:4))
        case 'SEG ' % find the statement that has the frequency range and the number of points
            temp = strsplit(tline,' ');
            out.freq = linspace(str2double(temp{2}),str2double(temp{3}),str2double(temp{4}))';
            clear temp
        case 'BEGI' % find where the data begins
            tline = fgetl(fid);
            while ~strcmpi(tline,'end') % collect all the data
                temp = strsplit(tline,',');
                out.data(end+1,:) = str2double(temp{1});
                tline = fgetl(fid);
            end
        otherwise
            % do nothing :)
    end
    tline = fgetl(fid); % get the next line of the file
end
fclose(fid); % close the file
end