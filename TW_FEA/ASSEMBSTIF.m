function[K]=ASSEMBSTIF(nCount,eCount,elcos,elsin,eL,eNodei,eNodej,E,eA,eI,eY)

ndim=3*nCount;
K=zeros(ndim,ndim);

% for each element
for i=1:eCount
    
    lambda=elcos(i);
    mu=elsin(i);
    
    % define transform matrix
    R=[
        lambda  mu      0.0       0.0       0.0       0.0;
        -mu     lambda  0.0       0.0       0.0       0.0;
        0.0     0.0     1.0       0.0       0.0       0.0;
        0.0     0.0     0.0       lambda    mu        0.0;
        0.0     0.0     0.0       -mu       lambda    0.0;
        0.0     0.0     0.0       0.0       0.0       1.0
        ];
    
    % define top half of local stiffness matrix in local coords (with E/L factored out)
    kLocal=[
        eA(i)       0           0           -eA(i)      0           0;
        0 12*eI(i)/(eL(i)^2) 6*eI(i)/eL(i) 0 -12*eI(i)/(eL(i)^2) 6*eI(i)/eL(i);
        0           0           4*eI(i)     0        -6*eI(i)/eL(i) 2*eI(i);
        0           0           0           eA(i)       0           0;
        0           0           0           0    12*eI(i)/(eL(i)^2) -6*eI(i)/(eL(i));
        0           0           0           0           0           4*eI(i)
        ];
    % multiply all elements by E/L
    kLocal=kLocal*(E/eL(i));
    
    % copy over top half to bottom half
    for j=2:6
        for k=1:(j-1)
            kLocal(j,k)=kLocal(k,j);
        end
    end
    
    % transform local stiffness matrix to global coordinates
    kGlobal = R'*kLocal*R;
    
    % assemble local matrix to global matrix
    na=eNodei(i);
    nb=eNodej(i);
    localToGlobalMap=[3*na-2 3*na-1 3*na 3*nb-2 3*nb-1 3*nb];
    for j=1:6
        for k=1:6
            globalj=localToGlobalMap(j);
            globalk=localToGlobalMap(k);
            K(globalj,globalk)=K(globalj,globalk)+kGlobal(j,k);
        end
    end
end

fprintf('Global stiffness matrix assembled\n');
    