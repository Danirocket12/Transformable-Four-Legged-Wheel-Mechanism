%% leg_pivot_angle.m
% Calculo del angulo de pivote de la pierna (psi) segun la seccion
% "6.3. Leg Pivot Angle" del articulo de la rueda transformable
% (mecanismo de disco de trayectoria, cuatro patas).
%
% ENTRADAS (las provee el programa / ya las tienes calculadas):
%   rp  -> r'/2 : (mitad del) diametro referenciado al pasador, en posicion u (mm)
%   np  -> n'/2 : (mitad del) diametro referenciado al pasador, en posicion c (mm)
%   dp  -> distancia del centro del disco al pasador de pivote (mm)
%   c   -> distancia final del seguidor (mm)   [Ec. 2 de la seccion 3]
%
% NOTA: el angulo de 45 grados es un parametro de diseno fijo
% (orientacion de montaje de las "orejas" del disco, Fig. 10).
clear; clc;
%% ---- Datos de entrada (el programa los solicita) ----
rp = input('Ingrese r''/2 (mm): ');
np = input('Ingrese n''/2 (mm): ');
dp = input('Ingrese dp (mm): ');
c  = input('Ingrese c (mm): ');
ang_mount = 45;    % angulo de montaje de las orejas [deg] (fijo por diseno)
%% ---- Conversion a radianes para funciones trig de MATLAB ----
ang_mount_r = deg2rad(ang_mount);
%% ---- Triangulo ANTES de la elongacion (Fig. 12) ----
% Eq. 28
M = sqrt(dp^2 + rp^2 - 2*dp*rp*cos(ang_mount_r));
% Eq. 29
theta_s = acosd( (dp^2 + M^2 - rp^2) / (2*dp*M) );
% Eq. 30
theta_y = 180 - (ang_mount + theta_s);
%% ---- Triangulo DESPUES de la elongacion (Fig. 13) ----
% Eq. 31
Ap = sqrt(c^2 + dp^2 - 2*c*dp*cos(ang_mount_r));
% Eq. 32
Mp = sqrt(np^2 + dp^2 - 2*np*dp*cos(ang_mount_r));
% Eq. 33
Tp = np - c;
% Eq. 34
theta_b = acosd( (Tp^2 + Ap^2 - Mp^2) / (2*Tp*Ap) );
% Eq. 35
theta_yp = acosd( (Tp^2 + Mp^2 - Ap^2) / (2*Tp*Mp) );
% Eq. 36
theta_x = 180 - (theta_yp + theta_b);
%% ---- Superposicion de ambos estados (Fig. 14) ----
% Eq. 37
theta_alpha = 180 - theta_y;
% Eq. 38  -> angulo de pivote de la pierna
psi = 180 - (theta_alpha + theta_yp);
%% ---- Resultados ----
fprintf('----- Resultados intermedios -----\n');
fprintf('M        = %.4f mm\n', M);
fprintf('theta_s  = %.4f deg\n', theta_s);
fprintf('theta_y  = %.4f deg\n', theta_y);
fprintf('Ap       = %.4f mm\n', Ap);
fprintf('Mp (M'')  = %.4f mm\n', Mp);
fprintf('Tp       = %.4f mm\n', Tp);
fprintf('theta_b  = %.4f deg\n', theta_b);
fprintf('theta_yp = %.4f deg\n', theta_yp);
fprintf('theta_x  = %.4f deg\n', theta_x);
fprintf('theta_a  = %.4f deg\n', theta_alpha);
fprintf('-----------------------------------\n');
fprintf('psi (angulo de pivote de la pierna) = %.4f deg\n', psi);