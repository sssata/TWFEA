function[K,F]=BC(K,modelName)

filePathLoad=modelName+"load.txt";

[lType,lNode,lDir,lMag]=textread(convertStringsToChars(filePathLoad),'%1c %u %2c %20.13f');
fprintf('File read complete (' + filePathLoad + ')\n');

% Count number of loads
lCount=length(lType);
j=1;
k=1;
m=1;
n=1;

% Collect every load type
for i=1:lCount;
    if lType(i)=='D' 
        dpDir(j,:)=lDir(i,:);
        dpMag(j)=lMag(i);
        dpNode(j)=lNode(i);
        j=j+1;
    elseif lType(i)=='R'
        rDir(m,:)=lDir(i,:);
        rMag(m)=lMag(i);
        rNode(m)=lNode(i);
        m=m+1;
    elseif lType(i)=='F'
        fDir(k,:)=lDir(i,:);
        fMag(k)=lMag(i);
        fNode(k)=lNode(i);
        k=k+1;
    elseif lType(i)=='M'
        mDir(n,:)=lDir(i,:);
        mMag(n)=lMag(i);
        mNode(n)=lNode(i);
        n=n+1;
    end
end

% count load types
dpCount=0;
rCount=0;
fCount=0;
mCount=0;
if (j>1)
    dpCount=length(dpMag);
end
if m>1
    rCount=length(rMag);
end
if k>1
    fCount=length(fMag);
end
if n>1
    mCount=length(mMag);
end


fprintf('Total Displacements: %u\n', dpCount);
fprintf('Total Rotations: %u\n', rCount);
fprintf('Total Forces: %u\n', fCount);
fprintf('Total Moments: %u\n', mCount);

% the methodology to apply boundary condition is to zero the row and 
% the column of the correponding node number in the global stiffness matrix
% and make the diagonal member 1.0. It means that if on node number i we 
% have set the ux=0.0 we have to do the following in the global stiffness:
% kg(2*i-1,j)=kg(j,2*i-1)=0.0 (for j=1,2*ncount); kg(2*i-1,2*i-1)=1.0

% Create Force Vector
F=zeros(1,length(K));

% Apply Displacements
for i=1:dpCount
    direction=dpDir(i,:);
    node=dpNode(i);
    if direction=='UX'
        for j=1:length(K)
            K(3*node-2,j)=0.0;
            K(j,3*node-2)=0.0;
        end
        K(3*node-2,3*node-2)=1.0;
    elseif direction=='UY'
        for j=1:length(K)
            K(3*node-1,j)=0.0;
            K(j,3*node-1)=0.0;
        end
        K(3*node-1,3*node-1)=1.0;
    end
end

% Apply Rotations
for i=1:rCount
    direction=rDir(i,:);
    node=rNode(i);
    for j=1:length(K)
            K(3*node,j)=0.0;
            K(j,3*node)=0.0;
    end
    K(3*node,3*node)=1.0;
end

% Apply Forces
for i=1:fCount
    direction=fDir(i,:);
    node=fNode(i);
    if direction=='FX'
        F(3*node-2)=fMag(i);
    elseif direction=='FY'
        F(3*node-1)=fMag(i);
    end
end

% Apply Moments
for i=1:mCount
    direction=mDir(i,:);
    node=mNode(i);
    F(3*node)=mMag(i);
end

% transpose into column vector
F=F';

fprintf('Force Vector assembled');
    