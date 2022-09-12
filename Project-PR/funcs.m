%%%%%%%%%%%
% funcs - computes stream properties
%Input:
% solver - hysys solver % stream - stream name % T - temperature
% P - pressure          % a- xsection          % mDot - flow rate
%Output:
% entr - enthalpy     % enrg - energy     % momt - momentum
% ro - density   % v - velocity
function [entr, enrg, momt, ro, v] = funcs(solver, stream, T, P, a, mDot);
% linking with hysys
stream.Temperature.SetValue(T, 'C')
stream.pressure.SetValue(P, 'kPa')
stream.MolarFlow.SetValue(mDot,'kgmole/h')
solver.CanSolve = 1; %Start solver
solver.CanSolve = 0; %Stop solver
S = stream.MassEntropyValue; % (kJ / kg*C)
h = stream.MassEnthalpyValue * 1000; % (J / kg)
ro = stream.MassDensityValue; %(kg / m^3)
Mw = stream.MolecularWeightValue;
m = mDot*Mw; % (kg / hr)
v = (m/3600) / (ro*a); % (m / s)
entr = S; % (kJ / kg*C)
enrg = h + (v^2)/2; % (m^2 / s^2)
momt= ((P*1000)*a)+((m/3600)*v);