%% ====================================================
%% VERIFICACIÓN NUMÉRICA DEL JACOBIANO
%% Compara J analítico vs J numérico (diferencias finitas)
%% ====================================================

%% Parámetros de verificación
L   = input('Ingresa L: ');
Leq = input('Ingresa Leq: ');

alfa_ini  = input('Ingresa alfa inicial (grados): ');
alfa_fin  = input('Ingresa alfa final (grados): ');
alfa_paso = input('Ingresa paso de alfa (grados): ');

beta_r     = deg2rad(60);
alfa_rango = alfa_ini : alfa_paso : alfa_fin;
n          = length(alfa_rango);

%% ====================================================
%% Calcular u, c, ΔXr para todo el rango
%% ====================================================
u_vec  = zeros(1, n);
c_vec  = zeros(1, n);
Xr_vec = zeros(1, n);

for i = 1:n
    alfa_r   = deg2rad(alfa_rango(i));
    u_vec(i) = sqrt(L^2 + Leq^2 - 2*Leq*L*cos(alfa_r));
    c_vec(i) = sqrt(L^2 + Leq^2 - 2*Leq*L*cos(alfa_r + beta_r));
    Xr_vec(i) = c_vec(i) - u_vec(i);
end

%% ====================================================
%% J ANALÍTICO
%% J(α) = L·Leq · [sin(α+60)/c - sin(α)/u]
%% ====================================================
J_analitico = zeros(1, n);
for i = 1:n
    alfa_r = deg2rad(alfa_rango(i));
    J_analitico(i) = L * Leq * (sin(alfa_r + beta_r)/c_vec(i) - sin(alfa_r)/u_vec(i));
end

%% ====================================================
%% J NUMÉRICO — diferencias finitas centradas
%% dXr/dα ≈ (Xr(α+h) - Xr(α-h)) / (2h)
%% ====================================================
h = deg2rad(alfa_paso);  % paso en radianes

J_numerico = zeros(1, n);
for i = 1:n
    alfa_r = deg2rad(alfa_rango(i));

    %% Xr en alfa + h
    u_p  = sqrt(L^2 + Leq^2 - 2*Leq*L*cos(alfa_r + h));
    c_p  = sqrt(L^2 + Leq^2 - 2*Leq*L*cos(alfa_r + h + beta_r));
    Xr_p = c_p - u_p;

    %% Xr en alfa - h
    u_m  = sqrt(L^2 + Leq^2 - 2*Leq*L*cos(alfa_r - h));
    c_m  = sqrt(L^2 + Leq^2 - 2*Leq*L*cos(alfa_r - h + beta_r));
    Xr_m = c_m - u_m;

    J_numerico(i) = (Xr_p - Xr_m) / (2 * h);
end

%% ====================================================
%% Error entre analítico y numérico
%% ====================================================
error_abs    = abs(J_analitico - J_numerico);
error_rel    = error_abs ./ (abs(J_analitico) + 1e-12) * 100;
error_max    = max(error_abs);
error_prom   = mean(error_abs);

%% ====================================================
%% REPORTE EN CONSOLA
%% ====================================================
fprintf('\n=== VERIFICACIÓN DEL JACOBIANO ===\n');
fprintf('L = %.0f  |  Leq = %.0f\n\n', L, Leq);
fprintf('%-10s %-15s %-15s %-15s %-12s\n', ...
        'alfa(°)', 'J analítico', 'J numérico', 'Error abs', 'Error rel(%)');
fprintf('%s\n', repmat('-', 1, 67));

for i = 1:n
    fprintf('%-10.1f %-15.8f %-15.8f %-15.8f %-12.6f\n', ...
            alfa_rango(i), J_analitico(i), J_numerico(i), error_abs(i), error_rel(i));
end

fprintf('\n--- Resumen ---\n');
fprintf('Error absoluto máximo:  %.2e\n', error_max);
fprintf('Error absoluto promedio: %.2e\n', error_prom);

if error_max < 1e-4
    fprintf('\n✓ VERIFICACIÓN EXITOSA — J analítico coincide con J numérico\n');
    fprintf('  La derivación del Jacobiano es correcta.\n\n');
else
    fprintf('\n⚠ DISCREPANCIA DETECTADA — revisar la derivación\n\n');
end

%% ====================================================
%% GRÁFICA 1 — J analítico vs J numérico
%% ====================================================
figure; set(gcf, 'Color', [0.97 0.97 0.97]); hold on;

plot(alfa_rango, J_analitico, '-o', 'LineWidth', 2.5, 'MarkerSize', 6, ...
     'Color', [0.2 0.5 0.8], 'MarkerFaceColor', 'white', ...
     'DisplayName', 'J analítico');

plot(alfa_rango, J_numerico, '--s', 'LineWidth', 2, 'MarkerSize', 6, ...
     'Color', [0.8 0.2 0.2], 'MarkerFaceColor', 'white', ...
     'DisplayName', 'J numérico (dif. finitas)');

yline(0, 'k--', 'LineWidth', 1.5, 'DisplayName', 'J = 0 (singularidad)');

hold off; grid on; grid minor;
ax = gca;
ax.GridColor = [0.7 0.7 0.7]; ax.MinorGridColor = [0.85 0.85 0.85];
ax.GridLineStyle = '--'; ax.MinorGridLineStyle = ':';
ax.FontSize = 11; ax.Box = 'on';
xlabel('alfa (grados)', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('J(\alpha)', 'FontSize', 12, 'FontWeight', 'bold');
title(sprintf('Verificación del Jacobiano  —  L=%.0f  Leq=%.0f', L, Leq), ...
      'FontSize', 14, 'FontWeight', 'bold');
legend('Location', 'best', 'FontSize', 11);

if error_max < 1e-4
    annotation('textbox', [0.15 0.15 0.4 0.08], ...
        'String', sprintf('✓ Error máximo: %.2e — Derivación correcta', error_max), ...
        'FitBoxToText', 'on', 'BackgroundColor', [0.85 1 0.85], ...
        'EdgeColor', [0 0.6 0], 'FontSize', 10, 'FontWeight', 'bold');
else
    annotation('textbox', [0.15 0.15 0.4 0.08], ...
        'String', sprintf('⚠ Error máximo: %.2e — Revisar derivación', error_max), ...
        'FitBoxToText', 'on', 'BackgroundColor', [1 0.85 0.85], ...
        'EdgeColor', 'red', 'FontSize', 10, 'FontWeight', 'bold');
end

%% ====================================================
%% GRÁFICA 2 — Error absoluto entre ambos
%% ====================================================
figure; set(gcf, 'Color', [0.97 0.97 0.97]);

semilogy(alfa_rango, error_abs, '-o', 'LineWidth', 2.5, 'MarkerSize', 6, ...
         'Color', [0.7 0.1 0.1], 'MarkerFaceColor', 'white');

grid on; grid minor;
ax2 = gca;
ax2.GridColor = [0.7 0.7 0.7]; ax2.MinorGridColor = [0.85 0.85 0.85];
ax2.GridLineStyle = '--'; ax2.MinorGridLineStyle = ':';
ax2.FontSize = 11; ax2.Box = 'on';
xlabel('alfa (grados)', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Error absoluto |J_{anal} - J_{num}|', 'FontSize', 12, 'FontWeight', 'bold');
title(sprintf('Error entre J analítico y J numérico  —  L=%.0f  Leq=%.0f', L, Leq), ...
      'FontSize', 14, 'FontWeight', 'bold');

%% ====================================================
%% GRÁFICA 3 — ΔXr para contexto
%% ====================================================
figure; set(gcf, 'Color', [0.97 0.97 0.97]); hold on;

plot(alfa_rango, Xr_vec, '-o', 'LineWidth', 2.5, 'MarkerSize', 6, ...
     'Color', [0.2 0.7 0.3], 'MarkerFaceColor', 'white', ...
     'DisplayName', '\DeltaXr');

%% Marcar donde J ≈ 0 (singularidad)
[J_min_val, J_min_idx] = min(abs(J_analitico));
if J_min_val < 0.01
    plot(alfa_rango(J_min_idx), Xr_vec(J_min_idx), 'xr', ...
         'MarkerSize', 14, 'LineWidth', 2.5, ...
         'DisplayName', sprintf('J≈0 en α=%.1f°', alfa_rango(J_min_idx)));
end

hold off; grid on; grid minor;
ax3 = gca;
ax3.GridColor = [0.7 0.7 0.7]; ax3.MinorGridColor = [0.85 0.85 0.85];
ax3.GridLineStyle = '--'; ax3.MinorGridLineStyle = ':';
ax3.FontSize = 11; ax3.Box = 'on';
xlabel('alfa (grados)', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('\DeltaXr', 'FontSize', 12, 'FontWeight', 'bold');
title(sprintf('\\DeltaXr en función de alfa  —  L=%.0f  Leq=%.0f', L, Leq), ...
      'FontSize', 14, 'FontWeight', 'bold');
legend('Location', 'best', 'FontSize', 11);