%The following code is simulating the filament found in Zheng. We can
%easily extend this to incorporate multiple filaments as needed.
clear 
clc

num_filaments = 1;
% Parameters
N = 3;           % number of hexbugs (angles to track)
sigma = 1.0071;    % elastoactive number.
tau = 1.1031;       % dimensionless timescale. Right now it is arbitrarily set to 0.1.
tspan = [0 100]; % simulation time in units of tau.
theta0 = 1e-1*rand(N,1); % initial angles. Randomly choose slightly bend angles.

%Simulate the set of ODEs (found below)
opts = odeset('RelTol',1e-9,'AbsTol',1e-9);
[t,theta] = ode45(@(t,theta) theta_dot(theta,sigma,tau,N), tspan, theta0, opts);

mean_curv = (theta(:,N)-theta(:,1));
mean_pol = 1/N.*sum(theta,2);

%% Plot of the angles as a function of time
% Plot results
figure(1);
% Plot with thicker line and markers
plot(t, mean_curv, '-', 'LineWidth', 1.5);
hold on
%plot(t1, theta1(:,1), '-', 'LineWidth', 1.5);
% Labels with LaTeX formatting
xlabel('Time (s)', 'Interpreter', 'latex', 'FontSize', 12);
ylabel('$\theta_i$', 'Interpreter', 'latex', 'FontSize', 12);
% Title with LaTeX
title('Hexbug Simulation', 'Interpreter', 'latex', 'FontSize', 14);
% Add grid
grid on;
grid minor; % optional for minor grid lines
% Optional: set axis limits for better view
%hold off
%% Plot of the mean curvature and mean polarization as a phase plot
%Two quantities of interest from Zheng 2023 et al.,

figure(2);

% Plot with line style, color, and markers
plot(mean_pol, mean_curv, '-', 'LineWidth', 1.5,'color','b')
hold on
xlabel('Mean Polarization', 'Interpreter', 'latex', 'FontSize', 12);
ylabel('Mean Curvature', 'Interpreter', 'latex', 'FontSize', 12);

% Title
title('Mean Curvature vs. Mean Polarization', 'Interpreter', 'latex', 'FontSize', 14);

% Grid
grid on;
grid minor;

% Optional: add axis limits to better frame the data
ylim([-4,4])
xlim([-4,4])

%hold off
%% Plot of the actual positions of the hexbugs as a function of time
%See what path each pendulum point swept out;
l = 1;
cts = cos(theta);
sts = sin(theta);
%Now we will get the x and y positions of each hexbug.
xs = zeros(size(theta));
ys = zeros(size(theta));
for j = 1:N
    if j == 1
        xs(:, j) = cts(:, j);
        ys(:, j) = sts(:, j);
    else
        xs(:, j) = xs(:, j-1) + cts(:, j);  % Sum of previous columns
        ys(:, j) = ys(:, j-1) + sts(:, j);
    end
end

xs = l*xs;
ys = l*ys; 

figure(3) 
for k = 1:N
    plot(xs(:,k), ys(:,k),'-','linewidth',2)
    hold on
    scatter(xs(end,k),ys(end,k),100,'filled','MarkerEdgeColor','k','MarkerFaceColor','k')

    % Labels with LaTeX formatting
    xlabel('x(t)', 'Interpreter', 'latex', 'FontSize', 12);
    ylabel('y(t)', 'Interpreter', 'latex', 'FontSize', 12);

end

%hold off