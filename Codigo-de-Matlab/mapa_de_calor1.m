%% ====================================================
%% HEAT MAP — correct criterion per case
%% Case 1 (Xco > Leq): alpha where J = 0  (Jacobian)
%% Case 2 (Xco < Leq): alpha where u = Leq (geometric limit)
%% Case 3 (Xco = Leq): no singularity   (gray)
%% ====================================================

continue_program = true;

while continue_program

%% ====================================================
%% Map parameters
%% ====================================================
L_start   = input('Enter the initial value of Xco: ');
L_end     = input('Enter the final value of Xco: ');
L_step    = input('Enter the step size of Xco: ');

Leq_start = input('Enter the initial value of Leq: ');
Leq_end   = input('Enter the final value of Leq: ');
Leq_step  = input('Enter the step size of Leq: ');

alpha_start = input('Enter initial alpha (degrees): ');
alpha_end   = input('Enter final alpha (degrees): ');
alpha_step  = input('Enter alpha step (degrees): ');

beta_r = deg2rad(60);

L_vec      = L_start   : L_step   : L_end;
Leq_vec    = Leq_start : Leq_step : Leq_end;
alpha_range = alpha_start : alpha_step : alpha_end;
nAlpha      = length(alpha_range);

nL   = length(L_vec);
nLeq = length(Leq_vec);

%% ====================================================
%% Compute map
%% ====================================================
alpha_singular_map = NaN(nLeq, nL);
has_singularity     = zeros(nLeq, nL);

fprintf('\nComputing map...\n');

for iL = 1:nL
    for iLeq = 1:nLeq
        Xco = L_vec(iL);
        Leq = Leq_vec(iLeq);

        %% --- Case 3: Xco = Leq -> no singularity, leave NaN ---
        if Xco == Leq
            continue;
        end

        %% --- Case 1: Xco > Leq -> J = 0 criterion (Jacobian) ---
        if Xco > Leq
            J_prev     = NaN;
            alpha_prev = NaN;
            found      = false;

            for i = 1:nAlpha
                alpha_r  = deg2rad(alpha_range(i));
                u_i      = sqrt(Xco^2 + Leq^2 - 2*Xco*Leq*cos(alpha_r));
                c_i      = sqrt(Xco^2 + Leq^2 - 2*Xco*Leq*cos(alpha_r + beta_r));
                J_now    = sin(alpha_r + beta_r)/c_i - sin(alpha_r)/u_i;

                if ~isnan(J_prev) && sign(J_now) ~= sign(J_prev)
                    a_low = deg2rad(alpha_prev);
                    a_high = alpha_r;
                    found = true;
                    break;
                end
                J_prev     = J_now;
                alpha_prev = alpha_range(i);
            end

            if ~found
                continue;
            end

            for iter = 1:100
                a_mid = (a_low + a_high) / 2;

                u_m = sqrt(Xco^2 + Leq^2 - 2*Xco*Leq*cos(a_mid));
                c_m = sqrt(Xco^2 + Leq^2 - 2*Xco*Leq*cos(a_mid + beta_r));
                J_m = sin(a_mid + beta_r)/c_m - sin(a_mid)/u_m;

                u_l = sqrt(Xco^2 + Leq^2 - 2*Xco*Leq*cos(a_low));
                c_l = sqrt(Xco^2 + Leq^2 - 2*Xco*Leq*cos(a_low + beta_r));
                J_l = sin(a_low + beta_r)/c_l - sin(a_low)/u_l;

                if sign(J_m) == sign(J_l)
                    a_low = a_mid;
                else
                    a_high = a_mid;
                end
            end

            alpha_singular_map(iLeq, iL) = rad2deg((a_low + a_high) / 2);
            has_singularity(iLeq, iL)    = 1;

        %% --- Case 2: Xco < Leq -> u = Leq criterion (geometric limit) ---
        else
            u_prev     = NaN;
            alpha_prev = NaN;
            found      = false;

            for i = 1:nAlpha
                alpha_r = deg2rad(alpha_range(i));
                u_i     = sqrt(Xco^2 + Leq^2 - 2*Xco*Leq*cos(alpha_r));
                diff_i  = u_i - Leq;

                if ~isnan(u_prev) && sign(diff_i) ~= sign(u_prev)
                    a_low = deg2rad(alpha_prev);
                    a_high = alpha_r;
                    found = true;
                    break;
                end
                u_prev     = diff_i;
                alpha_prev = alpha_range(i);
            end

            if ~found
                continue;
            end

            for iter = 1:100
                a_mid  = (a_low + a_high) / 2;
                u_mid  = sqrt(Xco^2 + Leq^2 - 2*Xco*Leq*cos(a_mid)) - Leq;
                u_low  = sqrt(Xco^2 + Leq^2 - 2*Xco*Leq*cos(a_low)) - Leq;

                if sign(u_mid) == sign(u_low)
                    a_low = a_mid;
                else
                    a_high = a_mid;
                end
            end

            alpha_singular_map(iLeq, iL) = rad2deg((a_low + a_high) / 2);
            has_singularity(iLeq, iL)    = 1;
        end

    end
end

fprintf('Map computed.\n');
fprintf('Combinations with singularity/limit: %d of %d\n\n', ...
    sum(has_singularity(:)), nL*nLeq);

%% ====================================================
%% Ask for points BEFORE plotting
%% ====================================================
points_Xco  = [];
points_Leq  = [];
points_alpha = [];
points_sing = [];

fprintf('Do you want to mark specific points on the map? (y/n): ');
resp = input('', 's');

if lower(resp) == 'y'
    n_points = input('How many points do you want to mark?: ');
    for i = 1:n_points
        fprintf('\n--- Point %d ---\n', i);
        Xco_p = input('  Enter Xco: ');
        Leq_p = input('  Enter Leq: ');

        found  = false;
        alpha_p = NaN;

        if Xco_p == Leq_p
            fprintf('  -> Case 3: no singularity\n');
            points_alpha(end+1) = NaN;
            points_sing(end+1) = 0;

        elseif Xco_p > Leq_p
            %% Case 1: J = 0
            J_prev    = NaN;
            alpha_prev = NaN;
            for k = 1:nAlpha
                alpha_r  = deg2rad(alpha_range(k));
                u_i      = sqrt(Xco_p^2 + Leq_p^2 - 2*Xco_p*Leq_p*cos(alpha_r));
                c_i      = sqrt(Xco_p^2 + Leq_p^2 - 2*Xco_p*Leq_p*cos(alpha_r + beta_r));
                J_now    = sin(alpha_r + beta_r)/c_i - sin(alpha_r)/u_i;
                if ~isnan(J_prev) && sign(J_now) ~= sign(J_prev)
                    a_low = deg2rad(alpha_prev);
                    a_high = alpha_r;
                    found = true;
                    break;
                end
                J_prev    = J_now;
                alpha_prev = alpha_range(k);
            end
            if found
                for iter = 1:100
                    a_mid = (a_low+a_high)/2;
                    u_m = sqrt(Xco_p^2+Leq_p^2-2*Xco_p*Leq_p*cos(a_mid));
                    c_m = sqrt(Xco_p^2+Leq_p^2-2*Xco_p*Leq_p*cos(a_mid+beta_r));
                    J_m = sin(a_mid+beta_r)/c_m - sin(a_mid)/u_m;
                    u_l = sqrt(Xco_p^2+Leq_p^2-2*Xco_p*Leq_p*cos(a_low));
                    c_l = sqrt(Xco_p^2+Leq_p^2-2*Xco_p*Leq_p*cos(a_low+beta_r));
                    J_l = sin(a_low+beta_r)/c_l - sin(a_low)/u_l;
                    if sign(J_m)==sign(J_l); a_low=a_mid; else; a_high=a_mid; end
                end
                alpha_p = rad2deg((a_low+a_high)/2);
                fprintf('  -> Case 1 - singular alpha (J=0) = %.6f deg\n', alpha_p);
                points_alpha(end+1) = alpha_p;
                points_sing(end+1) = 1;
            else
                fprintf('  -> Case 1 - no singularity in range\n');
                points_alpha(end+1) = NaN;
                points_sing(end+1) = 0;
            end

        else
            %% Case 2: u = Leq
            u_prev    = NaN;
            alpha_prev = NaN;
            for k = 1:nAlpha
                alpha_r = deg2rad(alpha_range(k));
                u_i    = sqrt(Xco_p^2+Leq_p^2-2*Xco_p*Leq_p*cos(alpha_r)) - Leq_p;
                if ~isnan(u_prev) && sign(u_i)~=sign(u_prev)
                    a_low = deg2rad(alpha_prev);
                    a_high = alpha_r;
                    found = true;
                    break;
                end
                u_prev    = u_i;
                alpha_prev = alpha_range(k);
            end
            if found
                for iter = 1:100
                    a_mid = (a_low+a_high)/2;
                    u_mid = sqrt(Xco_p^2+Leq_p^2-2*Xco_p*Leq_p*cos(a_mid)) - Leq_p;
                    u_low = sqrt(Xco_p^2+Leq_p^2-2*Xco_p*Leq_p*cos(a_low)) - Leq_p;
                    if sign(u_mid)==sign(u_low); a_low=a_mid; else; a_high=a_mid; end
                end
                alpha_p = rad2deg((a_low+a_high)/2);
                fprintf('  -> Case 2 - limit alpha (u=Leq) = %.6f deg\n', alpha_p);
                points_alpha(end+1) = alpha_p;
                points_sing(end+1) = 1;
            else
                fprintf('  -> Case 2 - u never reaches Leq (always valid)\n');
                points_alpha(end+1) = NaN;
                points_sing(end+1) = 0;
            end
        end

        points_Xco(end+1) = Xco_p;
        points_Leq(end+1) = Leq_p;
    end
end

%% ====================================================
%% PLOT
%% ====================================================
lim_min = max(min(L_vec), min(Leq_vec));
lim_max = min(max(L_vec), max(Leq_vec));

figure; set(gcf, 'Color', [0.97 0.97 0.97]);

pcolor(L_vec, Leq_vec, alpha_singular_map);
shading flat;
colormap(turbo);
set(gca, 'Color', [0.75 0.75 0.75]);
axis xy;

cb = colorbar;
cb.Label.String     = 'Critical Alpha (degrees)';
cb.Label.FontSize   = 12;
cb.Label.FontWeight = 'bold';

hold on;

[C, h] = contour(L_vec, Leq_vec, alpha_singular_map, ...
                 5:5:85, 'k-', 'LineWidth', 0.8);
h.DisplayName = 'Isolines every 5 deg';
clabel(C, h, 'FontSize', 8, 'Color', 'k');

plot([lim_min lim_max], [lim_min lim_max], ...
     'k-', 'LineWidth', 3, ...
     'DisplayName', 'Case 3: X_{co} = L_{eq}');

text(L_vec(round(nL*0.25)), Leq_vec(round(nLeq*0.80)), ...
     'Case 2: X_{co} < L_{eq}', ...
     'FontSize', 11, 'FontWeight', 'bold', 'Color', 'w', ...
     'HorizontalAlignment', 'center');

text(L_vec(round(nL*0.75)), Leq_vec(round(nLeq*0.25)), ...
     'Case 1: X_{co} > L_{eq}', ...
     'FontSize', 11, 'FontWeight', 'bold', 'Color', 'w', ...
     'HorizontalAlignment', 'center');

xlabel('X_{co}', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('L_{eq}', 'FontSize', 12, 'FontWeight', 'bold');
title('Heat Map', 'FontSize', 12, 'FontWeight', 'bold');

text(lim_min + (lim_max-lim_min)*0.55, lim_min + (lim_max-lim_min)*0.50, ...
     'Case 3: X_{co} = L_{eq}', ...
     'FontSize', 11, 'FontWeight', 'bold', 'Color', 'k', ...
     'HorizontalAlignment', 'center', 'Rotation', 30);

%% Plot points
for i = 1:length(points_Xco)
    Xco_p  = points_Xco(i);
    Leq_p  = points_Leq(i);
    alpha_p = points_alpha(i);
    if points_sing(i) == 1
        scatter(Xco_p, Leq_p, 150, 'w', 'filled', ...
                'MarkerEdgeColor', 'k', 'LineWidth', 2, ...
                'HandleVisibility', 'off');
        text(Xco_p+0.3, Leq_p+0.3, ...
             sprintf('Xco=%.2f\nLeq=%.2f\n\\alpha=%.4f deg', Xco_p, Leq_p, alpha_p), ...
             'FontSize', 9, 'Color', 'w', 'FontWeight', 'bold');
    else
        scatter(Xco_p, Leq_p, 150, 'g', 'filled', ...
                'MarkerEdgeColor', 'k', 'LineWidth', 2, ...
                'HandleVisibility', 'off');
        text(Xco_p+0.3, Leq_p+0.3, ...
             sprintf('Xco=%.2f\nLeq=%.2f\nno sing.', Xco_p, Leq_p), ...
             'FontSize', 9, 'Color', 'g', 'FontWeight', 'bold');
    end
end

%% Save image
set(gcf, 'ToolBar', 'none', 'MenuBar', 'none');
exportgraphics(gcf, 'heat_map.pdf', 'ContentType', 'vector');
fprintf('Image saved as heat_map.pdf\n');

%% ====================================================
%% MAIN MENU
%% ====================================================
exit_menu = false;

while ~exit_menu
    fprintf('\n========================================\n');
    fprintf('  What would you like to do now?\n');
    fprintf('  [1] Enter more points manually\n');
    fprintf('  [2] Compute a new map\n');
    fprintf('  [3] Finish\n');
    fprintf('========================================\n');
    option = input('  Enter option (1, 2, or 3): ');

    switch option
        case 1
            n_points = input('How many points do you want to enter?: ');
            for i = 1:n_points
                fprintf('\n--- Point %d ---\n', i);
                Xco_p = input('  Enter Xco: ');
                Leq_p = input('  Enter Leq: ');
                found = false;

                if Xco_p == Leq_p
                    fprintf('  -> Case 3: no singularity\n');
                elseif Xco_p > Leq_p
                    J_prev=NaN; alpha_prev=NaN;
                    for k=1:nAlpha
                        alpha_r=deg2rad(alpha_range(k));
                        u_i=sqrt(Xco_p^2+Leq_p^2-2*Xco_p*Leq_p*cos(alpha_r));
                        c_i=sqrt(Xco_p^2+Leq_p^2-2*Xco_p*Leq_p*cos(alpha_r+beta_r));
                        J_now=sin(alpha_r+beta_r)/c_i-sin(alpha_r)/u_i;
                        if ~isnan(J_prev)&&sign(J_now)~=sign(J_prev)
                            a_low=deg2rad(alpha_prev); a_high=alpha_r; found=true; break;
                        end
                        J_prev=J_now; alpha_prev=alpha_range(k);
                    end
                    if found
                        for iter=1:100
                            a_mid=(a_low+a_high)/2;
                            u_m=sqrt(Xco_p^2+Leq_p^2-2*Xco_p*Leq_p*cos(a_mid));
                            c_m=sqrt(Xco_p^2+Leq_p^2-2*Xco_p*Leq_p*cos(a_mid+beta_r));
                            J_m=sin(a_mid+beta_r)/c_m-sin(a_mid)/u_m;
                            u_l=sqrt(Xco_p^2+Leq_p^2-2*Xco_p*Leq_p*cos(a_low));
                            c_l=sqrt(Xco_p^2+Leq_p^2-2*Xco_p*Leq_p*cos(a_low+beta_r));
                            J_l=sin(a_low+beta_r)/c_l-sin(a_low)/u_l;
                            if sign(J_m)==sign(J_l); a_low=a_mid; else; a_high=a_mid; end
                        end
                        alpha_p=rad2deg((a_low+a_high)/2);
                        fprintf('  -> Case 1 - singular alpha = %.6f deg\n', alpha_p);
                        scatter(Xco_p,Leq_p,150,'w','filled','MarkerEdgeColor','k','LineWidth',2,'HandleVisibility','off');
                        text(Xco_p+0.3,Leq_p+0.3,sprintf('Xco=%.2f\nLeq=%.2f\n\\alpha=%.4f deg',Xco_p,Leq_p,alpha_p),'FontSize',9,'Color','w','FontWeight','bold');
                    else
                        fprintf('  -> Case 1 - no singularity in range\n');
                        scatter(Xco_p,Leq_p,150,'g','filled','MarkerEdgeColor','k','LineWidth',2,'HandleVisibility','off');
                    end
                else
                    u_prev=NaN; alpha_prev=NaN;
                    for k=1:nAlpha
                        alpha_r=deg2rad(alpha_range(k));
                        u_i=sqrt(Xco_p^2+Leq_p^2-2*Xco_p*Leq_p*cos(alpha_r))-Leq_p;
                        if ~isnan(u_prev)&&sign(u_i)~=sign(u_prev)
                            a_low=deg2rad(alpha_prev); a_high=alpha_r; found=true; break;
                        end
                        u_prev=u_i; alpha_prev=alpha_range(k);
                    end
                    if found
                        for iter=1:100
                            a_mid=(a_low+a_high)/2;
                            u_mid=sqrt(Xco_p^2+Leq_p^2-2*Xco_p*Leq_p*cos(a_mid))-Leq_p;
                            u_low=sqrt(Xco_p^2+Leq_p^2-2*Xco_p*Leq_p*cos(a_low))-Leq_p;
                            if sign(u_mid)==sign(u_low); a_low=a_mid; else; a_high=a_mid; end
                        end
                        alpha_p=rad2deg((a_low+a_high)/2);
                        fprintf('  -> Case 2 - limit alpha (u=Leq) = %.6f deg\n', alpha_p);
                        scatter(Xco_p,Leq_p,150,'w','filled','MarkerEdgeColor','k','LineWidth',2,'HandleVisibility','off');
                        text(Xco_p+0.3,Leq_p+0.3,sprintf('Xco=%.2f\nLeq=%.2f\n\\alpha=%.4f deg',Xco_p,Leq_p,alpha_p),'FontSize',9,'Color','w','FontWeight','bold');
                    else
                        fprintf('  -> Case 2 - u never reaches Leq (always valid)\n');
                        scatter(Xco_p,Leq_p,150,'g','filled','MarkerEdgeColor','k','LineWidth',2,'HandleVisibility','off');
                    end
                end
            end

        case 2
            exit_menu = true; continue_program = true;
        case 3
            exit_menu = true; continue_program = false;
            fprintf('\nProgram finished.\n');
        otherwise
            fprintf('Invalid option. Enter 1, 2, or 3.\n');
    end
end

%% ====================================================
%% CONSOLE REPORT
%% ====================================================
fprintf('\n=== CRITICAL ALPHA REPORT ===\n');
fprintf('%-10s %-10s %-20s\n', 'Xco', 'Leq', 'critical_alpha');
fprintf('%s\n', repmat('-', 1, 40));
for iL = 1:nL
    for iLeq = 1:nLeq
        if has_singularity(iLeq, iL) == 1
            fprintf('%-10.1f %-10.1f %-20.10f\n', ...
                L_vec(iL), Leq_vec(iLeq), alpha_singular_map(iLeq, iL));
        end
    end
end
fprintf('\n');

end % while continue_program