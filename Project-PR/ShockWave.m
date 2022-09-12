clear all;
clc;
format long
% *****************************Inlet Parameters****************************
T1 =20;
P1 = 30000;
D1=0.04;
A1 = pi/4*(D1)^2;
L = 0.12;
mDot= 5000;
% *****************************Nozzle Parameters****************************
seg_c = 30;
alpha_c = 6.85;
alphaRad_c = (alpha_c*pi) /180;
seg_d = 30;
alpha_d = 3;
alphaRad_d = (alpha_d*pi) /180;
% *****************************Outlet Parameters****************************
Pexit=48.5/100*P1; %Desired pressure recovery
Shock=0.12 % first guess for shocklocation, L_c <shock<L
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
r1 = sqrt(A1/pi);
ID(1) = 2*r1;
position(1) = 0;
i = 1;
L_segment = 0.0009;
x = tan(alphaRad_c)*L_segment;
converged(i) = true;
exception(i) = false;
while converged(i) ==true && exception(i) ==false && abs(1-machNum(i))>0.01
i = i + 1;
ID(i) = ID(i-1 )-(2*x);
A(i) = (pi*(ID(i))^2)/4;
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
% ***************************Shockwave prediction**************************
i=ithroat;
L_c = ((sqrt(A(1)/pi))- (sqrt(A(ithroat)/pi)))/ (tan(alphaRad_c));
L_d=L-L_c
rt = sqrt(A(ithroat)/pi);
dL_c=L_c / seg_c;
dL_d=L_d / seg_d;
L_bs=Shock-L_c;
dL_bs=L_bs/seg_d;
L_as=L-L_c-L_bs;
dL_as=L_as/seg_d;
Abs=(((L_bs*(tan(alphaRad_d)))+(sqrt(A(ithroat)/pi)) )^2)*pi;
Aex=(( (L_d*(tan (alphaRad_d)))+(sqrt(A(ithroat)/pi)) )^2)*pi;
[Tbs, Pbs, machNumbs, vbs, vFracbs,convergedbs, exceptionbs]= tpDistr(strInlet,T(ithroat), P(ithroat), A(ithroat),-120, 1000, Abs, mDot);
[entrbs, enrgbs, momtbs, robs, vbs] = funcs(hysolver, strInlet, Tbs, Pbs, Abs, mDot);
mDot_as= strDrygas.MolarFlowValue*3600;
% before run the next line , update natgas stream's composition information with drygas stream's data
[Tas,Pas ,machNumas, vas, converged, exception]= tpDistr_as(Tbs, Pbs, Abs,T(1) ,P(1),Abs,mDot_as);
[Tex, Pex, machNumex, vex, vFrac,convergedex, exceptionex]=tpDistr(strNatgas,Tas, Pas, Abs,T1,P1, Aex,mDot_as);
if Pex>Pexit
display ('choose bigger shock')
else if Pex<Pexit
display('choose lower shock')
else display ('shocklocation is correct')
end
end
Aas=Abs;
[entras, enrgas, momtas, roas, vas] = funcs(hysolver, strNatgas, Tas, Pas, Aas, mDot_as);
for h=L_c+dL_bs:dL_bs:Shock
i=i+1;
p(i)=h;
R=(p(i)-L_c)*tan(alphaRad_d);
A(i)= ((R+rt)^2) *pi;
[T(i), P(i), machNum(i), v(i), vFrac, converged, exception] = tpDistr(strInlet,T(i-1),P(i-1), A(i-1),-120, 1000, A(i), mDot);

[ entr(i), enrg(i), momt(i), ro(i), v(i)] = funcs(hysolver, strInlet, T(i), P(i), A(i),mDot);
end
pas=L_c+(L_bs);
i=i+1;
p(i)= pas;
A(i)=Aas;
T(i)= Tas;
P(i)= Pas;
machNum(i)= machNumas;
v(i)=vas;
entr(i) = entras;
enrg(i)=enrgas;
momt(i) = momtas;
ro(i)=roas;
for h=Shock+dL_as:dL_as:L
i=i+1;
p(i)=h;
R =(p(i)-L_c )*tan( alphaRad_d);
A(i)= ((R+rt)^2) *pi;
[T(i), P(i), machNum(i), v(i), converged, exception] = tpDistr(strNatgas,Tas, Pas, Abs,T1 ,P1,A(i),mDot);
[entr(i), enrg(i), momt(i), ro(i), v(i)] = funcs(hysolver, strNatgas, T(i), P(i), A(i), mDot );
end
position(ithroat+1:ithroat+31)=L_c:L_bs/seg_d:L_c+L_bs;
position(ithroat+31:ithroat+61)=L_c+L_bs:L_as/seg_d:L;
position(ithroat+62:end)=[];
plot(position,T,'b','Linewidth',3)
title('PR EOS Temperature distribution diagram')
xlabel('Nozzle length(m)')
ylabel('Entropy (KJ/kgK)')
legend('Real Gas')