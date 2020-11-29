function[eCos,eSin,eL,eNodei,eNodej,nCount,eCount,E,eA,eI,eY]=PREPROC(modelName,t)
format long;

% Assemble file paths
filePathNode=modelName+"node.txt";
filePathElement=modelName+"elem.txt"

% Read node file
[nIndex,nX,nY]=textread(convertStringsToChars(filePathNode),'%u %20.13f %20.13f');
fprintf('File read complete (' + filePathNode + ')\n');

% Move node 5 for bike optimization
if t~=-1
    nX(5)=8*t+30;
    nY(5)=-15*t+15;
end

% Read element file
[eIndex,eNodei,eNodej,eA,eI,eY]=textread(convertStringsToChars(filePathElement),'%u %u %u %20.13f %20.13f %20.13f');
fprintf('File read complete (' + filePathElement + ')\n');

% Count number of nodes and elements
nCount=length(nIndex);
eCount=length(eIndex);

fprintf('Total Nodes: %u\n', nCount);
fprintf('Total Elements: %u\n', eCount);

% Set youngs modulus
E=30e6;

% Calculate length, sin, and cos of elements
eL=zeros(1,eCount);
eCos=zeros(1,eCount);
eSin=zeros(1,eCount);

for i=1:eCount
    nA=eNodei(i);
    nB=eNodej(i);
    eL(i)=sqrt((nX(nB)-nX(nA))^2+(nY(nB)-nY(nA))^2);
    eCos(i)=(nX(nB)-nX(nA))/eL(i);
    eSin(i)=(nY(nB)-nY(nA))/eL(i);
end


% Plot model

close all;
hold on;

for i=1:eCount
    nA=[nX(eNodei(i)) nX(eNodej(i))];
    nB=[nY(eNodei(i)) nY(eNodej(i))];
    plot(nA,nB,'k+-');
end

xlim([min(nX)-5 max(nX)+5]);
ylim([min(nY)-5 max(nY)+5]);

hold off;

fprintf('Plot complete\n');


