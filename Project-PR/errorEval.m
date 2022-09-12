%%%%%%%%%%%
% errorEval - computes error in one iteration ofnewton raphson
%
%Input:
% solver - hysys solver
% stream - stream name
% entrl -inlet enthalpy
% enrg1 - inlet energy
% T - temperature guess
% P - pressure guess
% a - xsection
% mDot - flow rate
%Output:
% err - error in current newton raphson iteration
function [err]= errorEval(solver, stream, entr1, enrg1, T, P, a, mDot)
dT = 0.1;
dP=0.1;
[entr, enrg,momt,ro,v] = funcs(solver, stream, T, P, a, mDot);
f1 = entr- entr1;
f2 = enrg- enrg1;
[entr_Tinc, enrg_Tinc,momt_Tinc,ro,v] = funcs(solver, stream, T + dT/2, P, a, mDot);
[entr_Tdec, enrg_Tdec,momt_Tdec,ro,v] = funcs(solver, stream, T - dT/2, P, a, mDot);
[entr_Pinc, enrg_Pinc,momt_pinc,ro,v] = funcs(solver, stream, T, P + dP/2, a, mDot);
[entr_Pdec, enrg_Pdec,momt_Pdec,ro,v] = funcs(solver, stream, T, P - dP/2, a, mDot);
dfl_dT = (entr_Tinc- entr_Tdec) / dT;
df2_dT = (enrg_Tinc- enrg_Tdec) / dT;
dfl_dP = (entr_Pinc- entr_Pdec) / dP;
df2_dP = (enrg_Pinc- enrg_Pdec) / dP;
jacobean= [dfl_dT dfl_dP; df2_dT df2_dP];
err= -inv(jacobean)*[f1; f2];% 2xl matrix