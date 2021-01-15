function [output] = writeWKP(gizmo,filename)
% writeWPK - writes the nScrypt FFJ for a given project based on the two
% alignment points that are needed for the system
[path,name] = fileparts(filename);
% Open filename
fid = fopen([path '\Scripts\' name '-wkp.wkp'],'w');
% Open filename
% Write inforamtion about the FFJ
fprintf(fid,['<?xml version="1.0" encoding="UTF-8"?>\n'...
    '<WorkPiece>\n'...
    '<Dimensions Width="0.000" Length="0.000" Height="1.000"/>\n'...
    '<OriginIsTaught>False</OriginIsTaught>\n'...
    '</WorkPiece>\n'...
    ]);
output = fclose(fid);
end
