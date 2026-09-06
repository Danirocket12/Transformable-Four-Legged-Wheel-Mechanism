%% =====================================================================
%  PSI MAXIMO EN FUNCION DE ALFA (0 a 90 grados)
%  ---------------------------------------------------------------------
%     u(alfa) = sqrt(L_uc^2 + leq_uc^2 - 2*leq_uc*L_uc*cos(alfa))
%     c(alfa) = sqrt(L_uc^2 + leq_uc^2 - 2*leq_uc*L_uc*cos(alfa+beta))

% =====================================================================

clc;
clear;
close all;

fprintf('=====================================================\n');
fprintf('   VARIABLES FIJAS (no dependen de alfa)\n');
fprintf('=====================================================\n\n');

r               = input('r (radio base, ec. 29/31): ');
Lw              = input('Lw: ');
La              = input('La: ');
x               = input('x: ');
Leslabon        = input('Leslabon: ');
phi_trayectoria = input('phi_trayectoria: ');
dseguidor       = input('dseguidor: ');
L               = input('L (ec. 34/37, NO confundir con L_uc): ');

fprintf('\n=====================================================\n');
fprintf('   CONSTANTES PARA u(alfa) y c(alfa)\n');
fprintf('=====================================================\n\n');

L_uc    = input('L_uc (constante para u y c): ');
leq_uc  = input('leq_uc (lequilatero, constante para u y c): ');
beta    = 60;                     % grados, fijo segun tu codigo de referencia
beta_r  = deg2rad(beta);

fprintf('\nbeta fijo en %d grados (no se pide, es constante de diseno).\n', beta);

%% --------------------- RANGO DE ALFA (fijo segun lo acordado) ---------
alfa_ini  = 0;
alfa_fin  = 90;
alfa_paso = 0.1;                  % resolucion del barrido, en grados
alfa_rango = alfa_ini:alfa_paso:alfa_fin;
n = length(alfa_rango);

%% =====================================================================
%  BARRIDO DE ALFA
% =====================================================================
u_vec    = zeros(1,n);
c_vec    = zeros(1,n);
psi_vec  = NaN(1,n);

for i = 1:n
    alfa_r = deg2rad(alfa_rango(i));

    u_vec(i) = sqrt(L_uc^2 + leq_uc^2 - 2*leq_uc*L_uc*cos(alfa_r));
    c_vec(i) = sqrt(L_uc^2 + leq_uc^2 - 2*leq_uc*L_uc*cos(alfa_r + beta_r));

    v = [r, Lw, La, x, Leslabon, phi_trayectoria, u_vec(i), dseguidor, L, c_vec(i)];
    psi_vec(i) = psi_from_vars(v);
end

%% =====================================================================
%  RESULTADOS: maximo de psi
% =====================================================================
[psi_max, idx_max] = max(psi_vec);
n_validos = sum(~isnan(psi_vec));

fprintf('\n=====================================================\n');
fprintf('   RESULTADOS\n');
fprintf('=====================================================\n\n');
fprintf('Puntos validos en el barrido: %d / %d\n\n', n_validos, n);

if isnan(psi_max)
    fprintf(['NINGUN valor de alfa en [%.1f, %.1f] grados produjo una geometria valida.\n' ...
             'Revisa las variables fijas y las constantes L_uc, leq_uc.\n\n'], alfa_ini, alfa_fin);
else
    alfa_opt = alfa_rango(idx_max);
    fprintf('*** ALFA OPTIMO   = %.2f grados ***\n', alfa_opt);
    fprintf('*** PSI MAXIMO    = %.4f grados ***\n', rad2deg(psi_max));
    fprintf('    u(alfa_opt)   = %.6f\n', u_vec(idx_max));
    fprintf('    c(alfa_opt)   = %.6f\n\n', c_vec(idx_max));

    fprintf('Tabla resumen cada 5 grados:\n');
    fprintf('%-10s %-12s %-12s %-12s\n', 'alfa(°)', 'u', 'c', 'psi(°)');
    fprintf('%s\n', repmat('-', 1, 48));
    for a = alfa_ini:5:alfa_fin
        [~, idx] = min(abs(alfa_rango - a));
        if isnan(psi_vec(idx))
            fprintf('%-10.1f %-12.4f %-12.4f %-12s\n', alfa_rango(idx), u_vec(idx), c_vec(idx), 'invalido');
        else
            fprintf('%-10.1f %-12.4f %-12.4f %-12.4f\n', alfa_rango(idx), u_vec(idx), c_vec(idx), rad2deg(psi_vec(idx)));
        end
    end
end

%% =====================================================================
%  GRAFICA: psi vs alfa
% =====================================================================
figure; set(gcf, 'Color', [0.97 0.97 0.97]);

subplot(2,1,1);
plot(alfa_rango, rad2deg(psi_vec), '-', 'LineWidth', 2.2, 'Color', [0.15 0.45 0.75]);
hold on;
if ~isnan(psi_max)
    plot(alfa_opt, rad2deg(psi_max), 'or', 'MarkerSize', 9, 'LineWidth', 2.2, ...
         'DisplayName', sprintf('Maximo: alfa=%.2f°, psi=%.2f°', alfa_opt, rad2deg(psi_max)));
    legend('psi(alfa)', 'Maximo', 'Location', 'best');
end
hold off; grid on; grid minor;
ax = gca; ax.GridLineStyle = '--'; ax.MinorGridLineStyle = ':'; ax.Box = 'on';
xlabel('alfa (grados)', 'FontWeight', 'bold');
ylabel('\psi (grados)', 'FontWeight', 'bold');
title('\psi en funcion de alfa', 'FontWeight', 'bold', 'FontSize', 13);

subplot(2,1,2);
plot(alfa_rango, u_vec, '-', 'LineWidth', 2, 'Color', [0.2 0.6 0.3], 'DisplayName', 'u(alfa)');
hold on;
plot(alfa_rango, c_vec, '-', 'LineWidth', 2, 'Color', [0.8 0.4 0.0], 'DisplayName', 'c(alfa)');
hold off; grid on; grid minor;
ax2 = gca; ax2.GridLineStyle = '--'; ax2.MinorGridLineStyle = ':'; ax2.Box = 'on';
xlabel('alfa (grados)', 'FontWeight', 'bold');
ylabel('Distancia', 'FontWeight', 'bold');
title('u(alfa) y c(alfa)', 'FontWeight', 'bold', 'FontSize', 13);
legend('Location', 'best');

%% =====================================================================
%  FUNCION DE CALCULO DE PSI (igual que en buscar_psi_maximo.m)
% =====================================================================
function psi = psi_from_vars(v)
    % v = [r, Lw, La, x, Leslabon, phi_trayectoria, u, dseguidor, L, c]
    r               = v(1);
    Lw              = v(2);
    La              = v(3);
    x               = v(4);
    Leslabon        = v(5);
    phi_trayectoria = v(6);
    u               = v(7);
    dseguidor       = v(8);
    L               = v(9);
    c               = v(10);

    psi = NaN;

    % --- Ecs. 29-31 ---
    rad29 = r^2 - (Lw/2)^2;
    if rad29 < 0, return; end
    Li        = sqrt(rad29);
    Lsaliente = La - x;
    dp        = Li + Lsaliente;
    if dp <= 0, return; end

    % --- Ecs. 32-34 ---
    Delta_y = Leslabon - (phi_trayectoria/2 - u) - dseguidor/2;
    r_prima = phi_trayectoria + 2*Delta_y - 2*L;
    if r_prima <= 0, return; end

    % --- Ecs. 35-37 ---
    Delta_D = Leslabon - (phi_trayectoria/2 - c) - dseguidor/2;
    n_prima = phi_trayectoria + 2*Delta_D - 2*L;
    if n_prima <= 0, return; end

    ang45 = pi/4;

    % --- Triangulo Figura 19: M, theta_s, theta_y ---
    rp2 = r_prima/2;
    M2  = dp^2 + rp2^2 - 2*dp*rp2*cos(ang45);
    if M2 <= 0, return; end
    M = sqrt(M2);

    cos_theta_s = (dp^2 + M^2 - rp2^2) / (2*dp*M);
    if abs(cos_theta_s) > 1, return; end
    theta_s = acos(cos_theta_s);
    theta_y = pi - (ang45 + theta_s);
    if theta_y <= 0 || theta_y >= pi, return; end

    % --- Triangulo Figura 20: A, M', T, theta_b, theta_y', theta_x ---
    np2 = n_prima/2;
    A2  = c^2 + dp^2 - 2*c*dp*cos(ang45);
    if A2 <= 0, return; end
    A = sqrt(A2);

    Mp2 = np2^2 + dp^2 - 2*np2*dp*cos(ang45);
    if Mp2 <= 0, return; end
    Mp = sqrt(Mp2);

    T = np2 - c;
    if T == 0, return; end

    cos_theta_b = (T^2 + A^2 - Mp^2) / (2*T*A);
    if abs(cos_theta_b) > 1, return; end
    theta_b = acos(cos_theta_b);

    cos_theta_yp = (T^2 + Mp^2 - A^2) / (2*T*Mp);
    if abs(cos_theta_yp) > 1, return; end
    theta_yp = acos(cos_theta_yp);

    theta_x = pi - (theta_yp + theta_b);
    if theta_x <= 0 || theta_x >= pi, return; end

    % --- Superposicion (ec. 38) ---
    theta_alpha = pi - theta_y;
    psi = pi - (theta_alpha + theta_yp);

    if ~isreal(psi) || isnan(psi)
        psi = NaN;
    end
end