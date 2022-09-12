format long
% *****************************Inlet Parameters****************************
T1 =20;
P1 = 30000;
D1=0.04;
A1 = pi/4*(D1)^2;
L = 0.12;
mDot= 6000;
% *****************************Nozzle Parameters****************************
seg_c = 30;
alpha_c = 6.85;
alphaRad_c = (alpha_c*pi) /180;
seg_d = 30;
alpha_d = 3;
alphaRad_d = (alpha_d*pi) /180;
% *****************************Outlet Parameters****************************
Pexit=70/100*P1; %Desired pressure recovery
Shock=0.09; % first guess for shocklocation, L_c <shock<L
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
Mysep=get(MyMaterialStreams,'item','gas');
MyOperation=Mycase.Flowsheet.Operations;
% ****************************Open case Streams data***********************

strInlet = get(MyMaterialStreams,'item','inlet');
strLength = get(MyMaterialStreams,'item','length');
strNatgas = get(MyMaterialStreams,'item','natgas');
strGas = get(MyMaterialStreams,'item','gas');
strWater = get(MyMaterialStreams,'item','water');
strSatgas = get(MyMaterialStreams,'item','satgas');
strDrygas =get(MyMaterialStreams,'item','drygas');
strCondensate =get(MyMaterialStreams,'item','condensate');
% ******************************Gas saturation*****************************
vFrac = 1;
mDot_W=0;
[entr1, enrgl, momt1, rol, v1] = funcs(solver, strGas, T1, P1, A1, mDot);
while vFrac==1
mDot_W=mDot_W+0.001;
[entr_W, enrg_W, momt_W, ro_W, v_W] = funcs(hysolver,strWater, T1, P1, A1, mDot_W);
vFrac = strSatgas.VapourFractionValue;
end
% ************************Saturated gas properties*************************
T1 = strSatgas.TemperatureValue;
P1 = strSatgas.PressureValue;
mDot = strSatgas.MolarFlowValue*3600;
% *************************converged section design************************
A(1) = A1;
T(1) = T1;
P(1) = P1;
% before run the next line , update inlet stream's composition information with length stream's data
[entr(1), enrg(1), momt(1), ro(1), v(1)] = funcs(solver, strInlet, T(1), P(1), A(1), mDot);
[machNum1, v1]= mach(T1, P1, A1, mDot);
machNum(1) =machNum1;
v(1) = v1;
position(1) = 0;
i = 1;
L_segment = 0.00009;
x = tan(alphaRad_c)*L_segment;
converged(i) = true;
exception(i) = false;
while converged(i) ==true && exception(i) ==false && abs(1-machNum(i))>0.01
i = i + 1;
position(i) = position(i-1)+L_segment;
[T(i), P(i), machNum(i), v(i), vFrac, converged(i), exception(i)] = tpDistr(strInlet,T(i-1), P(i-1), A(i-1),T1,P1, A(i), mDot);
if converged(i) == true && exception(i) == false
[entr(i), enrg(i), momt(i), ro(i), v(i)] = funcs(hysolver, strInlet, T(i), P(i), A(i),mDot);
end
end
% L_segment = 0.00001;
% x = tan(alphaRad_c)*L_segment;
% hysolver.CanSolve = 1 % start solver
% hysolver.CanSolve = 0;
% converged(i)=1;
% converged(i) = true;
% exception(i)=false;
% while converged(i) == true && exception(i) == false && abs(1-machNum(i))>0.01
% i = i + 1;
% ID(i)=ID(i-1 )-(2*x);
% A(i)=(pi*(ID(i))^2)/4;
% position(i)=position(i-1 )+L_segment;
% [T(i), P(i), machNum(i), v(i), vFrac, converged(i), exception(i)] = tpDistr(strInlet,T(i-1), P(i-1), A(i-1),T1,P1, A(i), mDot);
% if converged(i) == true && exception(i) == false 
% [entr(i), enrg(i), momt(i), ro(i), v(i)] = funcs(hysolver, strInlet, T(i), P(i), A(i),mDot);
% end
% end
ithroat=i-1; 
TD=sqrt(A(ithroat)*4/pi);
% **********************find Exit Cross section Area details***********************
i=ithroat;
L_c = ( (sqrt( A(1)/pi))- (sqrt(A(ithroat)/pi)) )/(tan(alphaRad_c));
L_d=L-L_c;
rt = sqrt(A(ithroat)/pi);
dL_c=L_c / seg_c;
dL_d=L_d / seg_d;
for h = L_c+ dL_d:dL_d:L
i = i+1;
p(i) = h;
[T(i), P(i), machNum(i), v(i),vFrac , converged, exception] = tpDistr(strInlet,T(i-1), P(i-1), A(i-1 ),T(1),P(1),A(i),mDot);
[entr(i), enrg(i), momt(i), ro(i), v(i)] = funcs(hysolver, strInlet, T(i), P(i), A(i), mDot);
end
ExD=sqrt(A(i)*4/pi);
position(end:end+29)=L_c+dL_d:dL_d:L;
% *************************Plot Nozzle Schematic***************************
% Nozzle_plot(ID(1), TD,ExD, L_c, L_d)