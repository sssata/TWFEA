clear all;

% define range of t
pointCount=100;
tValue=linspace(0.01,0.99,pointCount);

stress=zeros(pointCount,7);
stressMax=zeros(1,pointCount);

for i=1:pointCount
    stress(i,:)=MAIN(tValue(i));
    stressMax(i)=max(stress(i,:));
end

close all;
hold on;
plot(tValue,stress);
xlabel('Location of Node 5 between Node 4 and Node 6');
ylabel('Absolute Stress (PSI)');
title('Location of Node 5 vs Element Absolute Stress');

[value,index]=min(stressMax);

fprintf("Minimum Stress: %f\n",value)
fprintf("Location: %f\n",tValue(index))

plot(tValue(index), value,'o');
legend('Element 1','Element 2','Element 3','Element 4','Element 5','Element 6','Element 7');
txt=['Min stress: ' num2str(value) ' at ' num2str(tValue(index))];
text(tValue(index), value,txt);

[minT,minStress]=fminsearch(@getStress,tValue(index));

% run once without defined t to rewrite truss.dat
MAIN(-1);

% define function with input t, output max absolute stress
function s = getStress(input)
    stress=MAIN(input);
    s=max(stress);
end
