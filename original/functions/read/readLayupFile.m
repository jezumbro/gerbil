function [information] = readLayupFile(fp)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
[~,otxt,~] = xlsread(fp);txt = lower(otxt);
la.alignment = contains(txt(:,2),'alignment');
la.boundary = contains(txt(:,2),'boundary');
la.punch = contains(txt(:,2),'punch');
la.tape = find(la.punch)-1;
la.viafill = contains(txt(:,2),'via fill');
la.conductor = contains(txt(:,2),'conductor');
information.designfilename = otxt(la.designfile,7);
information.alignment.name = otxt(la.alignment,7);
information.alignment.type = otxt(la.alignment,3);
information.boundary.name = otxt(la.boundary,7);
information.conductor.material = otxt(la.conductor,3);
information.conductor.name = cellfun(@(x) strtrim(strsplit(x,',')),...
    otxt(la.conductor,7),'UniformOutput',false);
information.conductor.oname = lower(otxt(la.conductor,8));
information.punch.name = cellfun(@(x) strtrim(strsplit(x,',')),...
    otxt(la.punch,8),'UniformOutput',false);
information.punch.material = otxt(la.tape,17);
end

