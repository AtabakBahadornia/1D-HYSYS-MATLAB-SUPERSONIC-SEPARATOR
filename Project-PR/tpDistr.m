%%%%%%%%%%%
% tpDistr - computes stream properties in next xsection
%
%Input:
% T1 - current temperature
% P1 - current pressure
% A1 -current xsection size
% T2i - next temperature initial guess
% P2i - next pressure initial guess
% A2 - next xsection size
% mDot - flow rate
%Output:
% T2 - next temperature
% P2 - next pressure
% v - next velocity
% vFrac - next vapour fraction
% converged - NR convergence flag
% exception - erroneous parameter flag
function [T2, P2, machNum, v, vFrac, convergeCond, exceptionCond] = tpDistr(Stream,T1, P1,A1, T2i, P2i, A2, mDot)
% linking with hysys
MyObject=actxserver('Hysys.Application');
MyObject=COM.Hysys_Application;
solver.CanSolve = 1; %Start solver
hysolver.CanSolve = 0;
Mycase=MyObject.SimulationCases.Open([cd,strcat('\','hyAPP','.hsc')]);
MyMaterialStreams=Mycase.FlowSheet.MaterialStreams;				
% strInlet= get(MyMaterialStreams,'item','inlet');
% strLength = get(MyMaterialStreams,'item','length');
% strlnlet = hyApp.ActiveDocument.Flowsheet.MaterialStreams.Item('inlet');
% strLength = hyApp.ActiveDocument.Flowsheet.MaterialStreams.Item('length');
% hySS = hyApp.ActiveDocument.Flowsheet.Operations.Item('SPRDSHT-1 ');
% Newton-Raphson
[entr1, enrg1, momt1, ro1, v1] = funcs(hysolver, Stream, T1, P1, A1, mDot);
tolerance = 0.001;% tolerance for error
max_iterations = 100; % maximum number of iterations
% set initial guess
T2 = T2i; % (C)
P2 = P2i; % (kPa)
k=0;
pres= tolerance + 1.;
tres = tolerance + 1.;
exceptionCond = false;
while (exceptionCond == false) && (tres >= tolerance || pres>= tolerance) && k <= max_iterations
err= errorEval(hysolver, Stream, entr1, enrg1, T2, P2, A2, mDot);
T2 = T2 + err(1, 1);
P2 = P2 + err(2, 1);
if P2 < 0 || T2 < -273
exceptionCond = true;
else
tres = abs( err(1,1) );
pres = abs( err(2,1) );
k=k+1;
end
end
convergeCond = false;
machNum=0;
v=0;
vFrac = 0;
if exceptionCond == false
    if k > max_iterations
        convergeCond = false;
    else
        convergeCond = true;
        [machNum, v] =mach(T2, P2, A2, mDot);
    end
end