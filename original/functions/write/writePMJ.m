function output = writePMJ(param,gizmo,scanDist,filename)
[path,name] = fileparts(filename);
fid = fopen([path '\Scripts\' name '-psj.psj'],'w');
fprintf(fid,['<?xml version="1.0" encoding="UTF-8"?>\n'...
    '<PrintMapJob>\n']);
fprintf(fid,'<PrintFilePath>%s</PrintFilePath>\n',...
    fullfile(path,'Scripts',[name '-psjscript.txt']));
fprintf(fid,'<ScanOutputFilePath>%s</ScanOutputFilePath>\n',...
    fullfile(path,'Scripts',[name '-psjscript.txt']));
fprintf(fid,'<PumpSlotName>%s</PumpSlotName>\n',gizmo);
fprintf(fid,'<LaserSensorSlotName>PrimaryLaserSensor</LaserSensorSlotName>\n');
fprintf(fid,['<FloorDeviceName></FloorDeviceName>\n'...
    '<CleanRadius>0.5</CleanRadius>\n'...
    '<ScanSpeed>10</ScanSpeed>']);
fprintf(fid,'<PrintFrequency>%.3f</PrintFrequency>\n',scanDist);
fprintf(fid,'<PrintClearanceHeight>%.3f</PrintClearanceHeight>\n',param.dispensegap(1));
fprintf(fid,'<ScanClearanceHeight>0</ScanClearanceHeight>');

fprintf(fid,['<FloorType>NORMAL</FloorType>\n'...
    '<UseExistingScan>False</UseExistingScan>\n'...
    '<LocalStartOffset X="0.000" Y="0.000" Z="0.000" />\n'])
fprintf(fid,'</PrintMapJob>\n');
output = fclose(fid);
end
