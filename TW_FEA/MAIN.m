% ***************************
% "MAIN(-1)" to run main program without specified t for bike frame optimization
% ***************************

function[elementAbsMaxStress]=MAIN(t)

% ***************************
% To run a different model:
% 1. Create a new folder inside this directory named with the new model name. 
% 2. Create "node.txt", "elem.txt", and "load.txt" inside the new folder
% 2. Change "modelName" below to the new folder's name.
% ***************************
modelName="Bike";

modelName=modelName+"/";

% Read node and elem files and plot model
[eCos,eSin,eL,eNodei,eNodej,nCount,eCount,ex,eA,eI,eY]=PREPROC(modelName,t);

% Assemble stiffness matrix
[K]=ASSEMBSTIF(nCount,eCount,eCos,eSin,eL,eNodei,eNodej,ex,eA,eI,eY);

% Read load file and apply boundary conditions
Original_K=K;
[K,F]=BC(K,modelName);

% Calculate displacement vector
U=K\F;

% Calculate stresses
[sigmaAxial,sigmaBendingA,sigmaBendingB]=STRESS(U,nCount,eCount,eCos,eSin,eL,eNodei,eNodej,ex,eA,eI,eY);

% Calculate force vector {f}=[K]{U}
Original_F=Original_K*U;

% Print results
filePathOutput=modelName+"truss.dat";
fid = fopen(filePathOutput,'w+');
fprintf(fid,'Nodal displacements in global cartesian \n');
fprintf(fid,'Node number         UX                    UY                 theta\n');
for i=1:nCount
    fprintf(fid,'%8u %20.13f %20.13f %20.13f\n',[i;U(3*i-2);U(3*i-1);U(3*i)]);
end
fprintf(fid,'********************************************************** \n');
fprintf(fid,'Element Stresses \n');
fprintf(fid,'                           Node A                                 Node B\n');
fprintf(fid,'Element Index   Axial      Bending          Max          Min      Bending          Max          Min\n');
maxStressElement=-1;
maxStressNode=-1;
maxStress=0.0;
elementAbsMaxStress=zeros(1,eCount);

for i=1:eCount
    sigmaMaxA=sigmaAxial(i)+abs(sigmaBendingA(i));
    sigmaMinA=sigmaAxial(i)-abs(sigmaBendingA(i));
    sigmaMaxB=sigmaAxial(i)+abs(sigmaBendingB(i));
    sigmaMinB=sigmaAxial(i)-abs(sigmaBendingB(i));
    fprintf(fid,'%8u %12.4f %12.4f %12.4f %12.4f %12.4f %12.4f %12.4f\n',[i;sigmaAxial(i);sigmaBendingA(i);sigmaMaxA;sigmaMinA;sigmaBendingB(i);sigmaMaxB;sigmaMinB]);
    
    % Find absolute max stress value and its associated location
    currentMaxStress=[sigmaMaxA sigmaMinA sigmaMaxB sigmaMinB];
    for j=1:4
        % Compare stresses of current element to max stress so far
        if abs(currentMaxStress(j))>abs(maxStress)
            maxStress=currentMaxStress(j);
            maxStressElement=i;
            if j<3
                maxStressNode=eNodei(i);
            else
                maxStressNode=eNodej(i);
            end
        end
    end
    
    elementAbsMaxStress(i)=max(abs(currentMaxStress));
end

fprintf(fid, '\nMax Stress Magnitude:     %16.6f    on element %8u at node %8u\n', maxStress, maxStressElement, maxStressNode);

fprintf(fid,'********************************************************** \n');
fprintf(fid,'Node Forces \n');
fprintf(fid,'Node number         FX                    FY                   M\n');
for i=1:nCount
    fprintf(fid,'%8u %20.13f %20.13f %20.13f\n',[i;Original_F(3*i-2);Original_F(3*i-1);Original_F(3*i)]);
end
fclose(fid);

fprintf('Results saved (' + filePathOutput + ')\n');



        