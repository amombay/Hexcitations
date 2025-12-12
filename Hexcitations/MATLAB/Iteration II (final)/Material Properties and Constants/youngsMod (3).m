clear; clc;

% === USER INPUT: edit these to your measured values ===
names = {'1','2','3','4'};        % labels
k_vals = [0.1812, 0.0745, 0.0903, 0.057];       % spring constants (N/mm)
L_vals = [12.3, 22.3, 32.3, 42.3];                   % rod lengths (mm) -- change to your actual L
% Rectangular cross-section dimensions (mm)
b = 5;    % width (mm)  -- change to your measured width
h = 5;    % thickness (mm) -- change to thickness in bending direction

% === CONVERSIONS TO SI ===
k_SI = k_vals * 1000;   % N/mm -> N/m
L_SI = L_vals / 1000;   % mm -> m
b_SI = b / 1000;        % mm -> m
h_SI = h / 1000;        % mm -> m

% Area and second moment of area for rectangle
A_SI = b_SI .* h_SI;           % m^2
I_SI = (b_SI .* (h_SI.^3)) / 12; % m^4 (b*h^3/12)

% === COMPUTE YOUNG'S MODULUS ===
% Axial model
E_axial = (k_SI .* L_SI) ./ A_SI;   % Pa

% Cantilever tip-load model
E_cantilever = (k_SI .* (L_SI.^3)) ./ (3 * I_SI);  % Pa

% === DISPLAY RESULTS ===
fprintf('\n=== Estimated Young''s Modulus (rectangular cross-section) ===\n');
fprintf('Rod\tk (N/mm)\tL (mm)\tE_axial (MPa)\tE_cantilever (MPa)\n');
fprintf('---------------------------------------------------------------\n');
for i = 1:length(k_vals)
    fprintf('%-6s\t%.4f\t\t%.1f\t\t%.3f\t\t%.3f\n', ...
        names{i}, k_vals(i), L_vals(i), E_axial(i)/1e6, E_cantilever(i)/1e6);
end

% === PLOT: E vs L for both models ===
figure;
plot(L_vals, E_axial/1e6, 'o-', 'LineWidth', 1.5, 'DisplayName', 'Axial E (MPa)');
hold on;
plot(L_vals, E_cantilever/1e6, 's-', 'LineWidth', 1.5, 'DisplayName', 'Cantilever E (MPa)');
xlabel('Rod Length L (mm)');
ylabel('Estimated E (MPa)');
title('Estimated Young''s Modulus (rectangular cross-section)');
legend('Location','best');
grid on;

% === OPTIONAL: check cantilever scaling k ~ 1/L^3 ===
invL3 = 1./(L_SI.^3);
% linear fit k_SI = slope * (1/L^3) + intercept
p = polyfit(invL3, k_SI, 1);
slope = p(1);
intercept = p(2);

% Using slope, estimate E from theoretical relation:
% For cantilever: k = (3 E I) / L^3  -> slope (in k vs 1/L^3) = 3 E I
% => E_est_from_slope = slope / (3*I)
E_from_slope = slope ./ (3 * I_SI(1)); % if cross-section same for all, use I of first (or avg)

fprintf('\n=== Cantilever scaling fit (k vs 1/L^3) ===\n');
fprintf('Fit: k = slope*(1/L^3) + intercept\n');
fprintf('slope = %.4e  (N*m^3)\n', slope);
fprintf('intercept = %.4e (N/m)\n', intercept);
fprintf('Estimated E from slope (using I of first rod): %.3f MPa\n', E_from_slope/1e6);

% Plot k vs 1/L^3 and fit
figure;
plot(invL3, k_SI, 'o', 'MarkerSize',8, 'DisplayName','data (k in N/m)');
hold on;
xfit = linspace(min(invL3), max(invL3), 100);
plot(xfit, polyval(p, xfit), '-', 'DisplayName','linear fit');
xlabel('1 / L^3  (1/m^3)');
ylabel('k (N/m)');
title('Check: k vs 1/L^3 (cantilever scaling)');
legend('Location','best');
grid on;

% === NOTES ===
fprintf(['\nNotes:\n' ...
    '- A = b*h and I = b*h^3/12 (assumes bending axis uses h^3 term).\n' ...
    '- Make sure h corresponds to the thickness in the bending direction (the dimension raised to the 3rd power).\n' ...
    '- If the cross-section/orientation differs for each rod, set b and h arrays per-rod instead of scalars.\n']);


