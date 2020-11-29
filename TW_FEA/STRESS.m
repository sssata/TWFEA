function[sigmaAxial,sigmaBendingA,sigmaBendingB]=STRESS(U,nCount,eCount,eCos,eSin,eL,eNodei,eNodej,E,eA,eI,eY)

sigmaAxial=zeros(1,eCount);
sigmaBendingA=zeros(1,eCount);
sigmaBendingB=zeros(1,eCount);

for i=1:eCount
    
    na=eNodei(i);
    nb=eNodej(i);
    lambda=eCos(i);
    mu=eSin(i);
    
    % define transform matrix
    R=[
        lambda  mu      0.0       0.0       0.0       0.0;
        -mu     lambda  0.0       0.0       0.0       0.0;
        0.0     0.0     1.0       0.0       0.0       0.0;
        0.0     0.0     0.0       lambda    mu        0.0;
        0.0     0.0     0.0       -mu       lambda    0.0;
        0.0     0.0     0.0       0.0       0.0       1.0
        ];

    % retrieve relevant displacements from global displacement vector
    uGlobal=[U(3*na-2);U(3*na-1);U(3*na);U(3*nb-2);U(3*nb-1);U(3*nb)];

    
    % transform relevant displacements to local coordinates
    uLocal=R*uGlobal;
    
    uA=uLocal(1);   % x displacement of node A of element
    vA=uLocal(2);   % y displacement of node A of element
    tA=uLocal(3);   % theta of node A of element
    uB=uLocal(4);   % x displacement of node B of element
    vB=uLocal(5);   % y displacement of node B of element
    tB=uLocal(6);   % theta of node B of element
    
    % Calculate Axial Stress
    sigmaAxial(i)=E*(uB-uA)/eL(i);
    
    % Calculate Bending Stress
    sigmaBendingA(i)=eY(i)*E*((6/(eL(i)^2)*(vB-vA))-(2/eL(i)*(2*tA+tB)));
    sigmaBendingB(i)=eY(i)*E*((6/(eL(i)^2)*(vA-vB))+(2/eL(i)*(2*tB+tA)));
    
end

fprintf('Stresses calculated\n');
   