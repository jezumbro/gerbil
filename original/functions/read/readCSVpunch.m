function output = readCSVpunch(filename)
pts = csvread(filename);
punchArray = [6 10 20 94].*.0254;
output = pts(:,[2,3]).*25.4;
output(:,3) = punchArray(pts(:,1))'
end