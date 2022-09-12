clear all;
clc;
% ********************************Variable name****************************
% T: temperature (C) # P: pressure (kPa) # A: x-section area (m/\2)
% L: length (m) # mDot: flow rate (kmolelhr) # entr: entropy () 
% enrg: enthalpy () # momt: momentum ()
% v: velocity (m/s) # machNum: mach number # ro: density (kg/m /\3)
% seg: segement count %shock: shock location measured from inlet (m) 
% alpha: half angle (degrees) # vFrac: saturated gas vapour fraction
%%%%%%%%%%%
% Postfix legend
% (entr, engr, momt, ro, v)_W: water stream
% (T, P, mach, v)l: inlet
% (L, seg, alpha)_c: converging part
% (L, seg, alpha)_d: diverging part
% (L, mDot)_as: after shock
% (L)_bs: before shock
format long
% *********************************Parameters******************************
T1 =20;
P1 = 30000;
A1 = 0.001257;
L = 0.12;
mDot= 5000;
% ******************************Linking with hysys*************************
MyObject=actxserver('Hysys.Application');
MyObject=COM.Hysys_Application;
% hysolver = MyObject.ActiveDocument.Solver;
solver.CanSolve = 1; 
hysolver.CanSolve = 0;
get(MyObject);
% ******************************Open case flowsheet************************
FileName='hyApp';
Mycase=MyObject.SimulationCases.Open([cd,strcat('\',FileName,'.hsc')]);
% Mycase=Interface.HYSYS_12_Type_Library__SimulationCase
Mycase.Visible=true;
get(Mycase);
MyMaterialStreams=Mycase.FlowSheet.MaterialStreams;				
get(MyMaterialStreams);
MyMaterialStreams.Names;
Mysep=get(MyMaterialStreams,'item','gas')
MyOperation=Mycase.Flowsheet.Operations;
% ****************************Open case Streams data***********************

strInlet = get(MyMaterialStreams,'item','inlet');
strLength = get(MyMaterialStreams,'item','length');
strNatgas = get(MyMaterialStreams,'item','natgas');
strGas = get(MyMaterialStreams,'item','gas');
strWater = get(MyMaterialStreams,'item','water');
strSatgas = get(MyMaterialStreams,'item','satgas');
strDrygas =get(MyMaterialStreams,'item','drygas');
hySS = get(MyOperation,'item','V-100');
% hySS = get(Mycase,.'Flowsheet','Operations','ltem',('SPRDSHT-1 ');
% ******************************Gas saturation*****************************
vFrac = 1;
mDot_W=0;
[entr1, enrgl, momt1, rol, v1] = funcs(solver, strGas, T1, P1, A1, mDot);
while vFrac==1
mDot_W=mDot_W+0.01;
[entr_W, enrg_W, momt_W, ro_W, v_W] = funcs(hysolver,strWater, T1, P1, A1, mDot_W);
vFrac = strSatgas.VapourFractionValue;
end
% ************************Saturated gas properties*************************
T1 = strSatgas.TemperatureValue;
P1 = strSatgas.PressureValue;
mDot = strSatgas.MolarFlowValue*3600;
% *******************************Nozzle design*****************************
seg_c = 30;
alpha_c = 6.85;
alphaRad_c = (alpha_c*pi) /180;
seg_d = 30;
alpha_d = 3;
alphaRad_d = (alpha_d*pi) /180;
A(1) = A1;
T(1) = T1;
P(1) = P1;
% before run the next line , update inlet stream's composition information with length stream's data
[entr(1), enrg(1), momt(1), ro(1), v(1)] = funcs(solver, strInlet, T(1), P(1), A(1), mDot);
[machNum1, v1]= mach(T1, P1, A1, mDot);
machNum(1) =machNum1;
v(1) = v1;
% water(l) = hySS.Cell('D1').Cel1Value;
r1 = sqrt(A1/pi);
ID(1) = 2*r1;
position(1) = 0;
i = 1;
L_segment = 0.0009;
x = tan(alphaRad_c)*L_segment;
IDK = L_segment;
% Finding the throat
converged(i) = true;
exception(i) = false;
while converged(i) ==true && exception(i) ==false && abs(1-machNum(i))>0.2
i = i + 1;
ID(i) = ID(i-1 )-(2*x);
A(i) = (pi*(ID(i))^2)/4;
position(i) = position(i-1)+L_segment;
[T(i), P(i), machNum(i), v(i), vFrac, converged(i), exception(i)] = tpDistr(T(i-1), P(i-1), A(i-1),T1,P1, A(i), mDot);
if converged(i) == true && exception(i) == false
[entr(i), enrg(i), momt(i), ro(i), v(i)] = funcs(hysolver, strInlet, T(i), P(i), A(i),mDot);
end
end
T_Distance=0.0009*(i-1);
L_segment = 0.0000009;
x = tan(alphaRad_c)*L_segment;
% hySS.Cell('B1').CellValue = L_segment;
hysolver.CanSolve = 1 % start solver
hysolver.CanSolve = 0;
converged(i)=1;
converged(i) = true;
exception(i)=false;
while converged(i) == true && exception(i) == false
i = i + 1;
ID(i)=ID(i-1 )-(2*x);
A(i)=(pi*(ID(i))^2)/4;
position(i)=position(i-1 )+L_segment;
[T(i), P(i), machNum(i), v(i), vFrac, converged(i), exception(i)] = tpDistr(T(i-1), P(i-1), A(i-1),T1,P1, A(i), mDot);
if converged(i) == true && exception(i) == false
[entr(i), enrg(i), momt(i), ro(i), v(i)] = funcs(hysolver, strInlet, T(i), P(i), A(i),mDot);
end
end
ithroat=i-1; 