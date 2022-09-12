%%%%%%%%%%%
% errorEval_as - computes error in one iteration of newton raphson to predict
% upstream properties of shockwave
%Input:
% solver - hysys solver
% stream - stream name
% enrgl -inlet energy
% momt 1 - inlet momentum
% T - temperature guess
% P - pressure guess
% a - xsection
% mDot - flow rate
%Output:
% err - error in current newton raphson iteration
function [err]= errorEval_as(solver, stream,enrg1,momt1, T, P, a, mDot)
dT = 0.1;
dP = 0.1;
[entr, enrg,momt,ro,v] = funcs(solver, stream, T, P, a, mDot);
f1 = enrg- enrg1;
f2 = momt - momt1;
[entr_Tinc, enrg_Tinc,momt_Tinc,ro,v] = funcs(solver, stream, T + dT/2, P, a, mDot);
[entr_Tdec, enrg_Tdec,momt_Tdec,ro,v] = funcs(solver, stream, T - dT/2, P, a, mDot);
[entr_Pinc, enrg_Pinc,momt_Pinc,ro,v] = funcs(solver, stream, T, P+dP/2 , a, mDot);
[entr_Pdec, enrg_Pdec,momt_Pdec,ro,v] = funcs(solver, stream, T, P-dP/2, a, mDot);
df2_dT = (momt_Tinc- momt_Tdec) / dT;
dfl_dT = (enrg_Tinc- enrg_Tdec) / dT;
df2_dP = (momt_Pinc- momt_Pdec) / dP;
dfl_dP = (enrg_Pinc- enrg_Pdec) / dP;
jacobean= [dfl_dT dfl_dP; df2_dT df2_dP];
err= -inv(jacobean)*[f1; f2];% 2xl matrix