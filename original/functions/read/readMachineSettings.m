% readMachineSettings
fid = fopen('C:\Transfer\Installs\MtGen3\Config\MachineSettings.xml');
tool.xyz = [];
tline = fgetl(fid); toolInd = 0;
while ~feof(fid)
    if contains(tline,'<ToolPlateSlotAry>')
        while ~contains(tline,'</ToolPlateSlotAry>')
           if contains(tline,'<Name>')
               toolInd = toolInd+1; 
               tool.name(toolInd) = (extractBetween(tline,'>','<'));
           end
           if contains(tline,'<X0>')
               tool.xyz(1,toolInd) = str2double(extractBetween(tline,'>','<'));
               tline = fgetl(fid);
               tool.xyz(2,toolInd) = str2double(extractBetween(tline,'>','<'));
               tline = fgetl(fid);
               tool.xyz(3,toolInd) = str2double(extractBetween(tline,'>','<'));               
           end
           
            tline = fgetl(fid);
        end
    end
    if contains(tline,'<CalibratedFloorValue>')
               tool.floor(1) = str2double(extractBetween(tline,'>','<'))
           end
    tline = fgetl(fid)
end
la = abs(tool.xyz(1,:))>0;xyz = tool.xyz(:,la)';
T = table(xyz(:,1),xyz(:,2),xyz(:,3),(xyz(:,3)-xyz(end,3))+(tool.floor-xyz(end,3)))
T.Properties.VariableNames = {'x','y','z'};
