%% Hmax.m
% Calculo de la posicion maxima teorica de la punta de la pierna (Hmax)
% segun la seccion "6.4. Maximum Theoretical Leg-Tip Position" del
% articulo de la rueda transformable (mecanismo de disco de trayectoria).
%
% ENTRADAS:
%   rp   -> r'/2 : (mitad del) diametro referenciado al pasador, en posicion u (mm)
%   dp   -> distancia del centro del disco al pasador de pivote (mm)
%   psi  -> angulo de pivote de la pierna [deg] (obtenido, p. ej., de leg_pivot_angle.m)
%   Lb   -> longitud rigida de la pierna (mm)
%
% NOTA: el angulo de 45 grados es un parametro de diseno fijo
% (orientacion de montaje de las "orejas" del disco, Fig. 10).
% Si tu diseno usa otra orientacion, cambia ang_mount abajo.
clear; clc;
%% ---- Datos de entrada (el programa los solicita) ----
rp  = input('Ingrese r''/2 (mm): ');
dp  = input('Ingrese dp (mm): ');
psi = input('Ingrese psi (deg): ');
Lb  = input('Ingrese Lb (mm): ');
ang_mount = 45;    % angulo de montaje de las orejas [deg] (fijo por diseno)
%% ---- Conversion a radianes para funciones trig de MATLAB ----
ang_mount_r = deg2rad(ang_mount);
%% ---- Triangulo antes de la elongacion (Fig. 12), para obtener theta_s ----
% Eq. 28 (M, diagonal del triangulo antes de la elongacion)
M = sqrt(dp^2 + rp^2 - 2*dp*rp*cos(ang_mount_r));
% Eq. 39 (equivalente a Eq. 29)
theta_s = acosd( (dp^2 + M^2 - rp^2) / (2*dp*M) );
%% ---- Angulo limite y Hmax ----
% Eq. 40
beta_max = theta_s + psi;
% Eq. 41
Hmax = sqrt(Lb^2 + dp^2 - 2*Lb*dp*cosd(beta_max));
%% ---- Resultados ----
fprintf('----- Resultados intermedios -----\n');
fprintf('M         = %.4f mm\n', M);
fprintf('theta_s   = %.4f deg\n', theta_s);
fprintf('beta_max  = %.4f deg\n', beta_max);
fprintf('-----------------------------------\n');
fprintf('Hmax (posicion maxima teorica de la punta de la pierna) = %.4f mm\n', Hmax);