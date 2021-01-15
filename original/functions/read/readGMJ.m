% readGMJ
filename = 'D:\OZIC\UNIPOLAR\nScrypt\Scripts\UNIPOLAR_Layer-TOP_V2-gmj.gmj';
debugTF = true;
fid = fopen(filename);
while ~feof(fid)
    tline = fgetl(fid)
    if contains(tline,'<LocalOffset')
        localVect = str2double(extractBetween(tline,'"','"'));
    elseif contains(tline,'<ScanFrequencyX>')
        freq(1,1) = str2double(extractBetween(tline,'>','<'))
    elseif contains(tline,'<ScanFrequencyY>')
        freq(2,1) = str2double(extractBetween(tline,'>','<'))
    elseif contains(tline,'<Rows>')
        scanNum(1,1) = str2double(extractBetween(tline,'>','<'))
    elseif contains(tline,'<Columns>')
        scanNum(2,1) = str2double(extractBetween(tline,'>','<'))
    else
        c = 'nothing';
    end
    
end