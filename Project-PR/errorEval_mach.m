%%%%%%%%%%%
% errorEval - computes error in one iteration of newton raphson to compute Machnumber
%Input:        #solver - hysys solver # stream - stream name # T - temperature 
% a- xsection  # P - pressure         #mDot - flow rate      # entrl- entropy inlet
%Output:       err - error in current newton raphson iteration to compute Mach number
function [err]= errorEval_mach(solver, stream, T, P, A, mDot,entr1)
dP = 0.1;
[entr, enrg,momt,ro,v] = funcs(solver, stream, T, P, A, mDot);
f1 = entr - entr1;
[entr_Pinc, enrg_Pinc,momt_Pinc,ro,v] = funcs(solver, stream, T, P + dP/2, A, mDot);
[entr_Pdec, enrg_Pdec,momt_Pdec,ro,v] = funcs(solver, stream, T, P - dP/2, A, mDot);
df1_dP = (entr_Pinc- entr_Pdec) / dP;
err= -f1/df1_dP;% 2xl matrix