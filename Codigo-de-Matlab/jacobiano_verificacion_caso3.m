%% ====================================================
%% VERIFICACIÓN — J(alfa) cuando L = Leq
%% en el Caso 3 (L = Leq)
%% ====================================================
 
%% Parámetros
alfa_ini  = input('Ingresa el valor inicial de alfa (grados): ');
alfa_fin  = input('Ingresa el valor final de alfa (grados): ');
alfa_paso = input('Ingresa el paso de alfa (grados): ');
 
n_curvas = input('¿Cuántas curvas quieres graficar (distintos valores de L=Leq)?: ');
 
L_valores = zeros(1, n_curvas);
for k = 1:n_curvas
    fprintf('\n--- Curva %d ---\n', k);
    L_valores(k) = input('  Ingresa el valor de L (= Leq): ');
end
 
beta_r   = deg2rad(60);
alfa_rango = alfa_ini : alfa_paso : alfa_fin;
colores    = lines(n_curvas);
 
%% ====================================================
%% Calcular J(alfa) para cada curva
%% ====================================================
J_matrix   = zeros(n_curvas, length(alfa_rango));
theta_matrix = zeros(n_curvas, length(alfa_rango));
 
fprintf('\n%-10s', 'alfa(°)');
for k = 1:n_curvas
    fprintf('%-20s', sprintf('J (L=Leq=%.0f)', L_valores(k)));
end
fprintf('\n%s\n', repmat('-', 1, 10 + 20*n_curvas));
 
for i = 1:length(alfa_rango)
    alfa   = alfa_rango(i);
    alfa_r = deg2rad(alfa);
    fprintf('%-10.1f', alfa);
 
    for k = 1:n_curvas
        L   = L_valores(k);
        Leq = L;   % Caso 3: L = Leq
 
        u = sqrt(L^2 + Leq^2 - 2*Leq*L*cos(alfa_r));
        c = sqrt(L^2 + Leq^2 - 2*Leq*L*cos(alfa_r + beta_r));
 
        %% ---- JACOBIANO COMPLETO (multiplicado por L·Leq) ----
        J_val = L * Leq * (sin(alfa_r + beta_r)/c - sin(alfa_r)/u);
 
        %% Calcular theta para referencia
        arg      = max(-1, min(1, (c^2 + u^2 - Leq^2)/(2*u*c)));
        theta_deg = rad2deg(acos(arg));
 
        J_matrix(k, i)     = J_val;
        theta_matrix(k, i) = theta_deg;
 
        fprintf('%-20.6f', J_val);
    end
    fprintf('\n');
end
 
%% ====================================================
%% GRÁFICA 1 — J(alfa) para todos los L=Leq
%% ====================================================
figure; set(gcf, 'Color', [0.97 0.97 0.97]); hold on;
 
for k = 1:n_curvas
    plot(alfa_rango, J_matrix(k,:), '-o', 'LineWidth', 2.5, 'MarkerSize', 5, ...
         'Color', colores(k,:), 'MarkerFaceColor', 'white', ...
         'MarkerEdgeColor', colores(k,:), ...
         'DisplayName', sprintf('L = Leq = %.0f', L_valores(k)));
end
 
%% Línea en J = 0
yline(0, 'k--', 'LineWidth', 2, 'DisplayName', 'J = 0 (singularidad)');
 
hold off; grid on; grid minor;
ax = gca;
ax.GridColor = [0.7 0.7 0.7]; ax.MinorGridColor = [0.85 0.85 0.85];
ax.GridLineStyle = '--'; ax.MinorGridLineStyle = ':';
ax.FontSize = 11; ax.Box = 'on';
xlabel('alfa (grados)', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('J_{completo}(\alpha)', 'FontSize', 12, 'FontWeight', 'bold');
title({'J_{completo}(\alpha) = L \cdot L_{eq} \cdot ( sin(\alpha+\beta)/c  -  sin(\alpha)/u )', ...
       'Caso 3: L = L_{eq}'}, ...
      'FontSize', 13, 'FontWeight', 'bold');60
legend('Location', 'best', 'FontSize', 11);
 
%% Anotación
if all(J_matrix(:) > 0) || all(J_matrix(:) < 0)
    annotation('textbox', [0.15 0.15 0.35 0.08], ...
        'String', '✓ J(α) nunca cruza cero — sin singularidad real', ...
        'FitBoxToText', 'on', 'BackgroundColor', [0.85 1 0.85], ...
        'EdgeColor', [0 0.6 0], 'FontSize', 10, 'FontWeight', 'bold');
else
    annotation('textbox', [0.15 0.15 0.35 0.08], ...
        'String', '⚠ J(α) cruza cero — singularidad detectada', ...
        'FitBoxToText', 'on', 'BackgroundColor', [1 0.85 0.85], ...
        'EdgeColor', 'red', 'FontSize', 10, 'FontWeight', 'bold');
end
 
%% ====================================================
%% GRÁFICA 2 — theta(alfa) para confirmar que es 30° constante
%% ====================================================
figure; set(gcf, 'Color', [0.97 0.97 0.97]); hold on;
 
for k = 1:n_curvas
    plot(alfa_rango, theta_matrix(k,:), '-o', 'LineWidth', 2.5, 'MarkerSize', 5, ...
         'Color', colores(k,:), 'MarkerFaceColor', 'white', ...
         'MarkerEdgeColor', colores(k,:), ...
         'DisplayName', sprintf('L = Leq = %.0f', L_valores(k)));
end
 
%% Línea en theta = 30°
yline(30, 'k--', 'LineWidth', 2, 'DisplayName', '\theta = 30° = \pi/6');
 
hold off; grid on; grid minor;
ax2 = gca;
ax2.GridColor = [0.7 0.7 0.7]; ax2.MinorGridColor = [0.85 0.85 0.85];
ax2.GridLineStyle = '--'; ax2.MinorGridLineStyle = ':';
ax2.FontSize = 11; ax2.Box = 'on';
xlabel('alfa (grados)', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('\theta (grados)', 'FontSize', 12, 'FontWeight', 'bold');
title('\theta(\alpha) cuando L = L_{eq}  —  confirmación \theta = \pi/6 constante', ...
      'FontSize', 14, 'FontWeight', 'bold');
legend('Location', 'best', 'FontSize', 11);
 
annotation('textbox', [0.15 0.15 0.4 0.08], ...
    'String', sprintf('✓ θ = 30° = π/6 constante para cualquier L = Leq y cualquier α'), ...
    'FitBoxToText', 'on', 'BackgroundColor', [0.85 1 0.85], ...
    'EdgeColor', [0 0.6 0], 'FontSize', 10, 'FontWeight', 'bold');
 
%% ====================================================
%% GRÁFICA 3 — J(alfa) vs theta(alfa) superpuestos
%% ====================================================
figure; set(gcf, 'Color', [0.97 0.97 0.97]); hold on;
 
yyaxis left;
hold on;
for k = 1:n_curvas
    plot(alfa_rango, J_matrix(k,:), '-o', 'LineWidth', 2.5, 'MarkerSize', 5, ...
         'Color', colores(k,:), ...
         'DisplayName', sprintf('J  L=Leq=%.0f', L_valores(k)));
end
yline(0, 'k--', 'LineWidth', 1.5, 'HandleVisibility', 'off');
ylabel('J_{completo}(\alpha)', 'FontSize', 12, 'FontWeight', 'bold');
hold off;
 
yyaxis right;
hold on;
for k = 1:n_curvas
    plot(alfa_rango, theta_matrix(k,:), '--s', 'LineWidth', 2, 'MarkerSize', 5, ...
         'Color', colores(k,:) * 0.7, ...
         'DisplayName', sprintf('\theta  L=Leq=%.0f', L_valores(k)));
end
yline(30, 'k:', 'LineWidth', 1.5, 'HandleVisibility', 'off');
ylabel('\theta (grados)', 'FontSize', 12, 'FontWeight', 'bold');
hold off;
 
grid on; grid minor;
ax3 = gca;
ax3.GridColor = [0.7 0.7 0.7]; ax3.MinorGridColor = [0.85 0.85 0.85];
ax3.GridLineStyle = '--'; ax3.MinorGridLineStyle = ':';
ax3.FontSize = 11; ax3.Box = 'on';
xlabel('alfa (grados)', 'FontSize', 12, 'FontWeight', 'bold');
title('J_{completo}(\alpha) y \theta(\alpha) superpuestos  —  L = L_{eq}', ...
      'FontSize', 14, 'FontWeight', 'bold');
legend('Location', 'best', 'FontSize', 10);
 
%% ====================================================
%% REPORTE EN CONSOLA
%% ====================================================
fprintf('\n=== REPORTE DE VERIFICACIÓN ===\n');
for k = 1:n_curvas
    J_min = min(J_matrix(k,:));
    J_max = max(J_matrix(k,:));
    fprintf('\nL = Leq = %.0f:\n', L_valores(k));
    fprintf('  J_completo mínimo: %.6f\n', J_min);
    fprintf('  J_completo máximo: %.6f\n', J_max);
    fprintf('  θ mínimo: %.6f°\n', min(theta_matrix(k,:)));
    fprintf('  θ máximo: %.6f°\n', max(theta_matrix(k,:)));
    if J_min > 0 || J_max < 0
        fprintf('  ✓ J nunca cruza cero — NO hay singularidad real\n');
    else
        fprintf('  ⚠ J cruza cero — singularidad detectada\n');
    end
end
fprintf('\n');