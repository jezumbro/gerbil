function [output] = writeFFJ(alignmentpts,filename)
% writeFFJ - writes the nScrypt FFJ for a given project based on the two
% alignment points that are needed for the system
[path,name] = fileparts(filename);
% Open filename
fid = fopen([path '\Scripts\' name '-ffj.ffj'],'w');
% Write inforamtion about the FFJ
fprintf(fid,['<?xml version="1.0" encoding="UTF-8"?>\n'...
    '<FiducialFindJob>\n'...
    '<UserUnits>Millimeters</UserUnits>\n'...
    '<Fiducials>\n']);
% Write first alignment point
fprintf(fid,'<WorldOffsetLocation X="%.4f" Y="%.4f" Z="%.4f" />\n',...
    alignmentpts(1,1),alignmentpts(1,2),0);
% Write method to find alignment point
fprintf(fid,['<VisionProcessName>FidFindTest01</VisionProcessName>\n'...
    '</Fiducials>\n'...
    '<Fiducials>\n']);
% Write second alignment point
fprintf(fid,'<WorldOffsetLocation X="%.4f" Y="%.4f" Z="%.4f" />\n',...
    alignmentpts(2,1),alignmentpts(2,2),0);
% Write method of finding alignment point
fprintf(fid,['<VisionProcessName>FidFindTest01</VisionProcessName>\n'...
    '</Fiducials>\n'...
    '</FiducialFindJob>']);
% Close FFJ file
output = fclose(fid);
end

