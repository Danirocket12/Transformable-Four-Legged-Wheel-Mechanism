%% Solicitar parámetros fijos de alfa
alfa_ini  = input('Ingresa el valor inicial de alfa (grados): ');
alfa_fin  = input('Ingresa el valor final de alfa (grados): ');
alfa_paso = input('Ingresa el paso de alfa (grados): ');
 
%% Umbral crítico de theta
theta_umbral = input('Ingresa el umbral mínimo de θ aceptable (grados): ');
 
%% Cantidad de curvas15
n_curvas = input('¿Cuántas curvas quieres graficar?: ');
 
%% Pedir L y lequilatero para cada curva
L_valores   = zeros(1, n_curvas);
leq_valores = zeros(1, n_curvas);
 
for k = 1:n_curvas
    fprintf('\n--- Curva %d ---\n', k);
    L_valores(k)   = input('  Ingresa el valor de L: ');
    leq_valores(k) = input('  Ingresa el valor de lequilatero: ');
end
 
%% Beta y phi constantes
beta   = 60;
beta_r = deg2rad(beta);
phi    = -pi/2;
 
%% Rango de alfa
alfa_rango = alfa_ini : alfa_paso : alfa_fin;
 
%% Colores automáticos
colores = lines(n_curvas);
 
%% Precalcular todos los datos
Xr_matrix    = zeros(n_curvas, length(alfa_rango));
theta_matrix = zeros(n_curvas, length(alfa_rango));
y_matrix     = zeros(n_curvas, length(alfa_rango));
c_matrix     = zeros(n_curvas, length(alfa_rango));   % <-- NUEVO: matriz de c
 
%% Registro de puntos críticos: {curva, alfa_idx, theta_valor}
puntos_criticos = {};
 
for k = 1:n_curvas
    L           = L_valores(k);
    lequilatero = leq_valores(k);
 
    fprintf('\n--- Curva %d: L = %.0f, lequilatero = %.0f ---\n', k, L, lequilatero);
    fprintf('%-10s %-12s %-12s %-15s %-12s\n', 'alfa(°)', 'y', 'c', 'theta(°)', 'Xr');
    fprintf('%s\n', repmat('-', 1, 61));
 
    hay_criticos = false;
 
    for i = 1:length(alfa_rango)
        alfa   = alfa_rango(i);
        alfa_r = deg2rad(alfa);
 
        y         = sqrt(L^2 + lequilatero^2 - 2*lequilatero*L*cos(alfa_r));
        c         = sqrt(L^2 + lequilatero^2 - 2*lequilatero*L*cos(alfa_r + beta_r));
        theta     = acos((c^2 + y^2 - lequilatero^2) / (2 * y * c));
        theta_deg = rad2deg(theta);
        Xr        = c - y;
 
        Xr_matrix(k,i)    = Xr;
        theta_matrix(k,i) = theta_deg;
        y_matrix(k,i)     = y;
        c_matrix(k,i)     = c;   % <-- NUEVO: guardar c
 
        fprintf('%-10.1f %-12.4f %-12.4f %-15.4f %-12.4f\n', alfa, y, c, theta_deg, Xr);
 
        %% Detección de punto crítico
        if theta_deg < theta_umbral
            puntos_criticos{end+1} = struct('curva', k, 'idx', i, 'alfa', alfa, 'theta', theta_deg);
            if ~hay_criticos
                fprintf('\n  ⚠  ADVERTENCIA — Curva %d (L=%.0f, leq=%.0f):\n', k, L, lequilatero);
                hay_criticos = true;
            end
            fprintf('     → alfa = %.1f°  →  θ = %.4f°  (por debajo del umbral de %.1f°)\n', ...
                    alfa, theta_deg, theta_umbral);
        end
    end
 
    if ~hay_criticos
        fprintf('  ✓  Curva %d: ningún punto crítico detectado.\n', k);
    end
end
 
fprintf('\n');
 
%% Empaquetar datos en struct
datos.alfa_rango      = alfa_rango;
datos.alfa_ini        = alfa_ini;
datos.alfa_fin        = alfa_fin;
datos.alfa_paso       = alfa_paso;
datos.Xr_matrix       = Xr_matrix;
datos.theta_matrix    = theta_matrix;
datos.y_matrix        = y_matrix;
datos.c_matrix        = c_matrix;   % <-- NUEVO
datos.L_valores       = L_valores;
datos.leq_valores     = leq_valores;
datos.colores         = colores;
datos.beta            = beta;
datos.n_curvas        = n_curvas;
datos.phi             = phi;
datos.theta_umbral    = theta_umbral;
datos.puntos_criticos = puntos_criticos;
 
%% ---- INTERFAZ CON BOTONES ----
alto_ventana = 510 + n_curvas * 45;   % +50 para el nuevo botón
fig = uifigure('Name', 'Selector de Gráficas', ...
               'Position', [100 100 440 alto_ventana], ...
               'Color', [0.97 0.97 0.97]);
 
uilabel(fig, 'Text', 'Selecciona la gráfica que deseas ver:', ...
        'Position', [20 alto_ventana-50 400 30], ...
        'FontSize', 13, 'FontWeight', 'bold', ...
        'HorizontalAlignment', 'center');
 
uibutton(fig, 'Text', 'Xr  —  Todas las curvas', ...
    'Position', [60 alto_ventana-100 300 40], ...
    'FontSize', 12, 'BackgroundColor', [0.2 0.5 0.8], 'FontColor', 'white', ...
    'ButtonPushedFcn', @(~,~) graficar_Xr_todas(datos));
 
uibutton(fig, 'Text', 'θ  —  Todas las curvas', ...
    'Position', [60 alto_ventana-150 300 40], ...
    'FontSize', 12, 'BackgroundColor', [0.2 0.7 0.4], 'FontColor', 'white', ...
    'ButtonPushedFcn', @(~,~) graficar_theta_todas(datos));

% ── NUEVO BOTÓN ──────────────────────────────────────────────────────────────
uibutton(fig, 'Text', 'Tabla  c  e  y  —  Por alfa', ...
    'Position', [60 alto_ventana-200 300 40], ...
    'FontSize', 12, 'BackgroundColor', [0.15 0.55 0.55], 'FontColor', 'white', ...
    'ButtonPushedFcn', @(~,~) mostrar_tabla_cy(datos));
% ─────────────────────────────────────────────────────────────────────────────
 
uilabel(fig, 'Text', '— Cinemática —', ...
        'Position', [60 alto_ventana-245 300 25], ...
        'FontSize', 11, 'FontColor', [0.4 0.4 0.4], ...
        'HorizontalAlignment', 'center');
 
uibutton(fig, 'Text', 'Posición  —  Por alfa y f', ...
    'Position', [60 alto_ventana-280 300 35], ...
    'FontSize', 11, 'BackgroundColor', [0.6 0.2 0.6], 'FontColor', 'white', ...
    'ButtonPushedFcn', @(~,~) graficar_posicion(datos));
 
uibutton(fig, 'Text', 'Velocidad  —  Por alfa y f', ...
    'Position', [60 alto_ventana-325 300 35], ...
    'FontSize', 11, 'BackgroundColor', [0.8 0.5 0.0], 'FontColor', 'white', ...
    'ButtonPushedFcn', @(~,~) graficar_velocidad(datos));
 
uibutton(fig, 'Text', 'Aceleración  —  Por alfa y f', ...
    'Position', [60 alto_ventana-370 300 35], ...
    'FontSize', 11, 'BackgroundColor', [0.7 0.1 0.1], 'FontColor', 'white', ...
    'ButtonPushedFcn', @(~,~) graficar_aceleracion(datos));
 
y_pos = alto_ventana - 420;
for k = 1:n_curvas
    etiqueta = sprintf('Curva %d  —  L=%.0f  leq=%.0f', k, L_valores(k), leq_valores(k));
    uibutton(fig, 'Text', etiqueta, ...
        'Position', [60 y_pos 300 35], ...
        'FontSize', 11, ...
        'BackgroundColor', colores(k,:), 'FontColor', 'white', ...
        'ButtonPushedFcn', @(~,~) graficar_curva(datos, k));
    y_pos = y_pos - 45;
end
 
uibutton(fig, 'Text', '🔄  Nuevas gráficas (reiniciar)', ...
    'Position', [60 30 300 40], ...
    'FontSize', 12, 'BackgroundColor', [0.5 0.1 0.1], 'FontColor', 'white', ...
    'ButtonPushedFcn', @(~,~) reiniciar(fig));
 
%% ====================================================
%% FUNCIONES
%% ====================================================

% ── NUEVA FUNCIÓN: tabla c e y para un alfa específico ───────────────────────
function mostrar_tabla_cy(d)
    % Pedir alfa al usuario
    fprintf('\n  Alfas disponibles: ');
    fprintf('%.1f  ', d.alfa_rango);
    fprintf('\n');
    alfa_v = input('  Ingresa el valor de alfa (grados): ');

    % Buscar índice más cercano
    [~, idx] = min(abs(d.alfa_rango - alfa_v));
    alfa_encontrado = d.alfa_rango(idx);
    if abs(alfa_encontrado - alfa_v) > d.alfa_paso / 2
        fprintf('  ⚠ Alfa %.1f no encontrado. Usando más cercano: %.1f°\n', alfa_v, alfa_encontrado);
    end

    % Construir tabla
    curva_ids  = (1:d.n_curvas)';
    L_col      = d.L_valores(:);
    leq_col    = d.leq_valores(:);
    y_col      = d.y_matrix(:, idx);
    c_col      = d.c_matrix(:, idx);
    theta_col  = d.theta_matrix(:, idx);   % <-- theta añadido

    T = table(curva_ids, L_col, leq_col, y_col, c_col, theta_col, ...
              'VariableNames', {'Curva', 'L', 'leq', 'y', 'c', 'theta_deg'});

    % Mostrar en ventana uifigure con uitable
    fig_t = uifigure('Name', sprintf('Tabla  c,  y  y  θ  —  alfa = %.1f°', alfa_encontrado), ...
                     'Position', [200 200 650 80 + d.n_curvas * 35], ...
                     'Color', [0.97 0.97 0.97]);

    uilabel(fig_t, ...
        'Text', sprintf('Valores de  c,  y  y  θ  para  α = %.1f°   (β = %d°)', alfa_encontrado, d.beta), ...
        'Position', [20 fig_t.Position(4)-45 610 28], ...
        'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');

    uit = uitable(fig_t, ...
        'Data', T, ...
        'Position', [20 20 610 fig_t.Position(4)-70], ...
        'FontSize', 11, ...
        'ColumnWidth', {55, 65, 65, 100, 100, 110}, ...
        'RowStriping', 'on');

    % Nombres de columnas
    uit.ColumnName = {'Curva', 'L', 'leq', 'y', 'c', 'θ (°)'};
end
% ─────────────────────────────────────────────────────────────────────────────

function graficar_Xr_todas(d)
    Xr_todos = d.Xr_matrix(:);
    figure; set(gcf, 'Color', [0.97 0.97 0.97]); hold on;
    for k = 1:d.n_curvas
        plot(d.alfa_rango, d.Xr_matrix(k,:), '-o', 'LineWidth', 2.5, 'MarkerSize', 5, ...
             'Color', d.colores(k,:), 'MarkerFaceColor', 'white', ...
             'MarkerEdgeColor', d.colores(k,:), ...
             'DisplayName', sprintf('L=%.0f  leq=%.0f', d.L_valores(k), d.leq_valores(k)));
    end
    hold off;
    aplicar_estilo(gca, d.alfa_ini, d.alfa_paso, d.alfa_fin, min(Xr_todos), max(Xr_todos), 2);
    xlabel('alfa (grados)', 'FontSize', 12, 'FontWeight', 'bold');
    ylabel('Xr', 'FontSize', 12, 'FontWeight', 'bold');
    title(sprintf('Xr en función de alfa  (\\beta = %d°)', d.beta), 'FontSize', 14, 'FontWeight', 'bold');
    legend('Location', 'best', 'FontSize', 11);
end
 
function graficar_theta_todas(d)
    theta_todos = d.theta_matrix(:);
    figure; set(gcf, 'Color', [0.97 0.97 0.97]); hold on;
 
    for k = 1:d.n_curvas
        plot(d.alfa_rango, d.theta_matrix(k,:), '-o', 'LineWidth', 2.5, 'MarkerSize', 5, ...
             'Color', d.colores(k,:), 'MarkerFaceColor', 'white', ...
             'MarkerEdgeColor', d.colores(k,:), ...
             'DisplayName', sprintf('L=%.0f  leq=%.0f', d.L_valores(k), d.leq_valores(k)));
    end
 
    %% Línea de umbral
    yline(d.theta_umbral, '--', sprintf('Umbral: %.1f°', d.theta_umbral), ...
          'Color', [0.6 0.0 0.0], 'LineWidth', 1.5, 'FontSize', 10, ...
          'LabelHorizontalAlignment', 'left');
 
    %% Marcar puntos críticos
    primer_critico = true;
    for j = 1:length(d.puntos_criticos)
        pc = d.puntos_criticos{j};
        if primer_critico
            plot(pc.alfa, pc.theta, 'xr', 'MarkerSize', 12, 'LineWidth', 2.5, ...
                 'DisplayName', sprintf('θ < %.1f° (crítico)', d.theta_umbral));
            primer_critico = false;
        else
            plot(pc.alfa, pc.theta, 'xr', 'MarkerSize', 12, 'LineWidth', 2.5, ...
                 'HandleVisibility', 'off');
        end
    end
 
    hold off;
    aplicar_estilo(gca, d.alfa_ini, d.alfa_paso, d.alfa_fin, min(theta_todos), max(theta_todos), 2);
    xlabel('alfa (grados)', 'FontSize', 12, 'FontWeight', 'bold');
    ylabel('\theta (grados)', 'FontSize', 12, 'FontWeight', 'bold');
    title(sprintf('\\theta en función de alfa  (\\beta = %d°)', d.beta), 'FontSize', 14, 'FontWeight', 'bold');
    legend('Location', 'best', 'FontSize', 11);
end
 
function [combos, t_vec] = pedir_parametros_cinematica(d)
    combos    = [];
    continuar = true;
    t_total   = 0;
    fprintf('\n  Alfas disponibles: ');
    fprintf('%.1f  ', d.alfa_rango);
    fprintf('\n');
    while continuar
        fprintf('\n--- Nueva combinación ---\n');
        alfa_v = input('  Ingresa alfa (grados): ');
        f_v    = input('  Ingresa f (frecuencia en Hz): ');
        w_v    = 2 * pi * f_v;
        if isempty(combos)
            t_total = input('  Tiempo total a graficar (segundos): ');
        end
        [~, idx] = min(abs(d.alfa_rango - alfa_v));
        alfa_encontrado = d.alfa_rango(idx);
        if abs(alfa_encontrado - alfa_v) > d.alfa_paso/2
            fprintf('  ⚠ Alfa %.1f no encontrado. Usando más cercano: %.1f°\n', alfa_v, alfa_encontrado);
        end
 
        %% Advertir si el alfa seleccionado tiene puntos críticos
        for j = 1:length(d.puntos_criticos)
            pc = d.puntos_criticos{j};
            if pc.alfa == alfa_encontrado
                fprintf('  ⚠  ADVERTENCIA: alfa=%.1f° en Curva %d tiene θ=%.4f° (bajo umbral de %.1f°)\n', ...
                        alfa_encontrado, pc.curva, pc.theta, d.theta_umbral);
            end
        end
 
        combos(end+1, 1) = alfa_encontrado;
        combos(end,   2) = w_v;
        combos(end,   3) = f_v;
        resp = input('  ¿Calcular con otra combinación? (1=si, 0=no): ');
        if resp ~= 1
            continuar = false;
        end
    end
    t_vec = linspace(0, t_total, 500);
end
 
function graficar_posicion(d)
    [combos, t_vec] = pedir_parametros_cinematica(d);
    n_combos = size(combos, 1);
    figure; set(gcf, 'Color', [0.97 0.97 0.97]);
    sgtitle(sprintf('Posición  p(t) = (Xr/2)·sen(wt+\\phi) + (y+Xr/2)  (\\beta=%d°)', d.beta), ...
            'FontSize', 13, 'FontWeight', 'bold');
    for ia = 1:n_combos
        alfa_v = combos(ia, 1); w_v = combos(ia, 2); f_v = combos(ia, 3);
        idx    = find(d.alfa_rango == alfa_v);
        subplot(n_combos, 1, ia); hold on;
        for k = 1:d.n_curvas
            Xr  = d.Xr_matrix(k, idx); y = d.y_matrix(k, idx);
            pos = (Xr/2) * sin(w_v * t_vec + d.phi) + (y + Xr/2);
            plot(t_vec, pos, 'LineWidth', 2, 'Color', d.colores(k,:), ...
                 'DisplayName', sprintf('L=%.0f leq=%.0f', d.L_valores(k), d.leq_valores(k)));
        end
        hold off; grid on; grid minor;
        ax = gca; ax.GridColor = [0.7 0.7 0.7]; ax.MinorGridColor = [0.85 0.85 0.85];
        ax.GridLineStyle = '--'; ax.MinorGridLineStyle = ':'; ax.FontSize = 10; ax.Box = 'on';
        ylabel('Pos', 'FontSize', 10);
        title(sprintf('\\alpha=%.1f°  f=%.4f Hz', alfa_v, f_v), 'FontSize', 10);
        if ia == n_combos; xlabel('Tiempo (s)', 'FontSize', 11, 'FontWeight', 'bold'); end
        legend('Location', 'eastoutside', 'FontSize', 9);
    end
end
 
function graficar_velocidad(d)
    [combos, t_vec] = pedir_parametros_cinematica(d);
    n_combos = size(combos, 1);
    figure; set(gcf, 'Color', [0.97 0.97 0.97]);
    sgtitle(sprintf('Velocidad  v(t) = |(Xr/2)·w·cos(wt+\\phi)|  (\\beta=%d°)', d.beta), ...
            'FontSize', 13, 'FontWeight', 'bold');
    for ia = 1:n_combos
        alfa_v = combos(ia, 1); w_v = combos(ia, 2); f_v = combos(ia, 3);
        idx    = find(d.alfa_rango == alfa_v);
        subplot(n_combos, 1, ia); hold on;
        for k = 1:d.n_curvas
            Xr  = d.Xr_matrix(k, idx);
            vel = abs((Xr/2) * w_v * cos(w_v * t_vec + d.phi));
            plot(t_vec, vel, 'LineWidth', 2, 'Color', d.colores(k,:), ...
                 'DisplayName', sprintf('L=%.0f leq=%.0f', d.L_valores(k), d.leq_valores(k)));
        end
        hold off; grid on; grid minor;
        ax = gca; ax.GridColor = [0.7 0.7 0.7]; ax.MinorGridColor = [0.85 0.85 0.85];
        ax.GridLineStyle = '--'; ax.MinorGridLineStyle = ':'; ax.FontSize = 10; ax.Box = 'on';
        ylabel('Vel', 'FontSize', 10);
        title(sprintf('\\alpha=%.1f°  f=%.4f Hz', alfa_v, f_v), 'FontSize', 10);
        if ia == n_combos; xlabel('Tiempo (s)', 'FontSize', 11, 'FontWeight', 'bold'); end
        legend('Location', 'eastoutside', 'FontSize', 9);
    end
end
 
function graficar_aceleracion(d)
    [combos, t_vec] = pedir_parametros_cinematica(d);
    n_combos = size(combos, 1);
    figure; set(gcf, 'Color', [0.97 0.97 0.97]);
    sgtitle(sprintf('Aceleración  a(t) = |(Xr/2)·w²·sen(wt+\\phi)|  (\\beta=%d°)', d.beta), ...
            'FontSize', 13, 'FontWeight', 'bold');
    for ia = 1:n_combos
        alfa_v = combos(ia, 1); w_v = combos(ia, 2); f_v = combos(ia, 3);
        idx    = find(d.alfa_rango == alfa_v);
        subplot(n_combos, 1, ia); hold on;
        for k = 1:d.n_curvas
            Xr   = d.Xr_matrix(k, idx);
            acel = abs(-(Xr/2) * w_v^2 * sin(w_v * t_vec + d.phi));
            plot(t_vec, acel, 'LineWidth', 2, 'Color', d.colores(k,:), ...
                 'DisplayName', sprintf('L=%.0f leq=%.0f', d.L_valores(k), d.leq_valores(k)));
        end
        hold off; grid on; grid minor;
        ax = gca; ax.GridColor = [0.7 0.7 0.7]; ax.MinorGridColor = [0.85 0.85 0.85];
        ax.GridLineStyle = '--'; ax.MinorGridLineStyle = ':'; ax.FontSize = 10; ax.Box = 'on';
        ylabel('Acel', 'FontSize', 10);
        title(sprintf('\\alpha=%.1f°  f=%.4f Hz', alfa_v, f_v), 'FontSize', 10);
        if ia == n_combos; xlabel('Tiempo (s)', 'FontSize', 11, 'FontWeight', 'bold'); end
        legend('Location', 'eastoutside', 'FontSize', 9);
    end
end
 
function graficar_curva(d, k)
    figure; set(gcf, 'Color', [0.97 0.97 0.97]); hold on;
    yyaxis left;
    plot(d.alfa_rango, d.Xr_matrix(k,:), '-o', 'LineWidth', 2.5, 'MarkerSize', 5, ...
         'Color', [0.8 0.1 0.1], 'MarkerFaceColor', 'white', 'MarkerEdgeColor', [0.8 0.1 0.1]);
    ylabel('Xr', 'FontSize', 12, 'FontWeight', 'bold');
 
    yyaxis right;
    theta_redondeado = round(d.theta_matrix(k,:), 4);
    plot(d.alfa_rango, theta_redondeado, '-s', 'LineWidth', 2.5, 'MarkerSize', 5, ...
         'Color', [0.13 0.45 0.75], 'MarkerFaceColor', 'white', 'MarkerEdgeColor', [0.13 0.45 0.75]);
 
    %% Línea de umbral (eje derecho = theta)
    yline(d.theta_umbral, '--', sprintf('Umbral: %.1f°', d.theta_umbral), ...
          'Color', [0.6 0.0 0.0], 'LineWidth', 1.5, 'FontSize', 10, ...
          'LabelHorizontalAlignment', 'left');
 
    %% Marcar puntos críticos de esta curva
    primer_critico = true;
    for j = 1:length(d.puntos_criticos)
        pc = d.puntos_criticos{j};
        if pc.curva == k
            if primer_critico
                plot(pc.alfa, round(pc.theta, 4), 'xr', 'MarkerSize', 14, 'LineWidth', 2.5, ...
                     'DisplayName', sprintf('θ < %.1f° (crítico)', d.theta_umbral));
                primer_critico = false;
            else
                plot(pc.alfa, round(pc.theta, 4), 'xr', 'MarkerSize', 14, 'LineWidth', 2.5, ...
                     'HandleVisibility', 'off');
            end
        end
    end
 
    ylabel('\theta (grados)', 'FontSize', 12, 'FontWeight', 'bold');
    t_min = min(theta_redondeado); t_max = max(theta_redondeado);
    margen_t = max((t_max - t_min) * 0.05, 1);
    ylim([t_min - margen_t, t_max + margen_t]);
 
    hold off; grid on; grid minor;
    ax = gca; ax.GridColor = [0.7 0.7 0.7]; ax.MinorGridColor = [0.85 0.85 0.85];
    ax.GridLineStyle = '--'; ax.MinorGridLineStyle = ':'; ax.FontSize = 11; ax.Box = 'on';
    xticks(ax, d.alfa_ini : d.alfa_paso : d.alfa_fin);
    xlabel('alfa (grados)', 'FontSize', 12, 'FontWeight', 'bold');
    title(sprintf('Curva %d  —  L=%.0f  leq=%.0f  (\\beta=%d°)', ...
          k, d.L_valores(k), d.leq_valores(k), d.beta), 'FontSize', 13, 'FontWeight', 'bold');
    legend({'Xr', '\theta', sprintf('Umbral %.1f°', d.theta_umbral)}, 'Location', 'best', 'FontSize', 11);
end
 
function aplicar_estilo(ax, x_ini, x_paso, x_fin, y_min, y_max, y_paso)
    grid(ax, 'on'); grid(ax, 'minor');
    ax.GridColor = [0.7 0.7 0.7]; ax.MinorGridColor = [0.85 0.85 0.85];
    ax.GridLineStyle = '--'; ax.MinorGridLineStyle = ':';
    ax.FontSize = 11; ax.Box = 'on';
    margen = (y_max - y_min) * 0.05;
    ylim(ax, [y_min - margen, y_max + margen]);
    xticks(ax, x_ini : x_paso : x_fin);
    yticks(ax, floor(y_min - margen) : y_paso : ceil(y_max + margen));
end
 
function reiniciar(fig)
    resp = uiconfirm(fig, ...
        '¿Deseas iniciar nuevas gráficas? Se borrarán todos los parámetros actuales.', ...
        'Confirmar reinicio', ...
        'Options', {'Sí, reiniciar', 'Cancelar'}, ...
        'DefaultOption', 2, 'CancelOption', 2, 'Icon', 'warning');
    if strcmp(resp, 'Sí, reiniciar')
        close(fig); close all; clc; clear;
        run(mfilename);
    end
end