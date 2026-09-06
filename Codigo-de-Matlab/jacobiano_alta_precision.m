%% ====================================================
%% VERIFICACIÓN DE ALTA PRECISIÓN
%% Encuentra el alfa exacto donde J=0 para L y Leq dados
%% mediante bisección con 100 iteraciones
%% ====================================================

%% Parámetros
L   = input('Ingresa L: ');
Leq = input('Ingresa Leq: ');

alfa_ini  = input('Ingresa alfa inicial (grados): ');
alfa_fin  = input('Ingresa alfa final (grados): ');
alfa_paso = input('Ingresa paso de alfa (grados): ');

beta_r = deg2rad(60);
alfa_rango = alfa_ini : alfa_paso : alfa_fin;
nAlfa = length(alfa_rango);

%% ====================================================
%% Paso 1 — Encontrar el intervalo donde J cambia de signo
%% ====================================================
J_prev    = NaN;
alfa_prev = NaN;
encontrado = false;

for i = 1:nAlfa
    alfa_r = deg2rad(alfa_rango(i));
    u = sqrt(L^2 + Leq^2 - 2*Leq*L*cos(alfa_r));
    c = sqrt(L^2 + Leq^2 - 2*Leq*L*cos(alfa_r + beta_r));
    J_actual = sin(alfa_r + beta_r)/c - sin(alfa_r)/u;

    if ~isnan(J_prev) && sign(J_actual) ~= sign(J_prev)
        a_low = deg2rad(alfa_prev);
        a_hig = alfa_r;
        encontrado = true;
        break;
    end
    J_prev    = J_actual;
    alfa_prev = alfa_rango(i);
end

if ~encontrado
    fprintf('\n⚠ No se encontró singularidad en el rango dado.\n');
    return;
end

%% ====================================================
%% Paso 2 — Bisección con 100 iteraciones
%% ====================================================
for iter = 1:100
    a_mid = (a_low + a_hig) / 2;

    u_m = sqrt(L^2 + Leq^2 - 2*Leq*L*cos(a_mid));
    c_m = sqrt(L^2 + Leq^2 - 2*Leq*L*cos(a_mid + beta_r));
    J_m = sin(a_mid + beta_r)/c_m - sin(a_mid)/u_m;

    u_l = sqrt(L^2 + Leq^2 - 2*Leq*L*cos(a_low));
    c_l = sqrt(L^2 + Leq^2 - 2*Leq*L*cos(a_low + beta_r));
    J_l = sin(a_low + beta_r)/c_l - sin(a_low)/u_l;

    if sign(J_m) == sign(J_l)
        a_low = a_mid;
    else
        a_hig = a_mid;
    end
end

alfa_exacto = rad2deg((a_low + a_hig) / 2);

%% ====================================================
%% Paso 3 — Verificar con alfa exacto
%% ====================================================
alfa_r = deg2rad(alfa_exacto);
u = sqrt(L^2 + Leq^2 - 2*Leq*L*cos(alfa_r));
c = sqrt(L^2 + Leq^2 - 2*Leq*L*cos(alfa_r + beta_r));

J_exacto   = L * Leq * (sin(alfa_r + beta_r)/c - sin(alfa_r)/u);
Xr_exacto  = c - u;
arg_exacto = (u^2 + c^2 - Leq^2) / (2*u*c);

term1 = sin(alfa_r + beta_r)/c;
term2 = sin(alfa_r)/u;

%% ====================================================
%% Reporte
%% ====================================================
fprintf('\n=== VERIFICACIÓN DE ALTA PRECISIÓN ===\n');
fprintf('L = %.0f  |  Leq = %.0f\n\n', L, Leq);
fprintf('alfa singular exacto:  %.15f°\n\n', alfa_exacto);
fprintf('--- Valores en ese alfa ---\n');
fprintf('u              = %.15f\n', u);
fprintf('c              = %.15f\n', c);
fprintf('ΔXr            = %.15f\n', Xr_exacto);
fprintf('Leq            = %.15f\n', Leq);
fprintf('ΔXr - Leq      = %.2e  (debe ser ≈ 0)\n\n', Xr_exacto - Leq);
fprintf('--- Jacobiano ---\n');
fprintf('u                      = %.15f\n', u);
fprintf('c                      = %.15f\n', c);
fprintf('Término 1 sin(α+60°)/c = %.15f\n', term1);
fprintf('Término 2 sin(α)/u     = %.15f\n', term2);
fprintf('Diferencia             = %.2e  (debe ser ≈ 0)\n', term1 - term2);
fprintf('J analítico            = %.2e  (debe ser ≈ 0)\n\n', J_exacto);
fprintf('--- Argumento del arccos ---\n');
fprintf('arg = %.15f\n', arg_exacto);
fprintf('arg - 1 = %.2e  (debe ser ≈ 0)\n\n', arg_exacto - 1);
if abs(arg_exacto - 1) < 1e-6
    fprintf('✓ SINGULARIDAD CONFIRMADA — arccos colapsa en alfa = %.10f°\n\n', alfa_exacto);
else
    fprintf('⚠ arg = %.10f — no exactamente 1, aumentar iteraciones\n\n', arg_exacto);
end

%% ====================================================
%% GRÁFICA — J(alfa) cerca del punto singular
%% ====================================================
margen = 5;
alfa_zoom = (alfa_exacto - margen) : 0.01 : (alfa_exacto + margen);
J_zoom    = zeros(size(alfa_zoom));
arg_zoom  = zeros(size(alfa_zoom));

for i = 1:length(alfa_zoom)
    ar = deg2rad(alfa_zoom(i));
    u_z = sqrt(L^2 + Leq^2 - 2*Leq*L*cos(ar));
    c_z = sqrt(L^2 + Leq^2 - 2*Leq*L*cos(ar + beta_r));
    J_zoom(i)   = L * Leq * (sin(ar + beta_r)/c_z - sin(ar)/u_z);
    arg_zoom(i) = (u_z^2 + c_z^2 - Leq^2) / (2*u_z*c_z);
end

figure; set(gcf, 'Color', [0.97 0.97 0.97]);

yyaxis left;
hold on;
plot(alfa_zoom, J_zoom, '-b', 'LineWidth', 2.5, 'DisplayName', 'J(\alpha)');
plot(alfa_exacto, 0, 'o', 'MarkerSize', 10, ...
     'MarkerEdgeColor', 'b', 'MarkerFaceColor', 'w', ...
     'HandleVisibility', 'off');
text(alfa_exacto, 0, sprintf('  \\alpha = %.6f°', alfa_exacto), ...
     'FontSize', 10, 'Color', 'b', 'FontWeight', 'bold', ...
     'VerticalAlignment', 'bottom');
yline(0, 'k--', 'LineWidth', 1.5, 'HandleVisibility', 'off');
ylabel('J(\alpha)', 'FontSize', 12, 'FontWeight', 'bold');

yyaxis right;
plot(alfa_zoom, arg_zoom, '-', 'LineWidth', 2, 'Color', [0.8 0.2 0.2], ...
     'DisplayName', 'arg del arccos');
yline(1, 'r:', 'LineWidth', 1.5, 'HandleVisibility', 'off');
ylabel('Argumento del arccos', 'FontSize', 12, 'FontWeight', 'bold');

grid on; grid minor;
ax = gca;
ax.GridColor = [0.7 0.7 0.7];
ax.GridLineStyle = '--';
ax.FontSize = 11; ax.Box = 'on';
xlabel('alfa (grados)', 'FontSize', 12, 'FontWeight', 'bold');
title(sprintf('J(\\alpha) y argumento del arccos cerca de la singularidad  —  L=%.0f  Leq=%.0f', L, Leq), ...
      'FontSize', 13, 'FontWeight', 'bold');
legend('Location', 'best', 'FontSize', 11);
hold off;