%The following code is simulating the filament found in Zheng. We can
%easily extend this to incorporate multiple filaments as needed.

% Parameters
N = 7;          % number of hexbugs (angles to track)
sigma = 0.166;  % elastoactive number.
tau = 0.1;      %dimensionless timescale. Right now it is arbitrarily set to 0.1.
tspan = [0 100]; % simulation time in units of tau.
theta0 = pi/6*rand(N,1); % initial angles. Randomly choose slightly bend angles.

%Simulate the set of ODEs (found below)
opts = odeset('RelTol',1e-6,'AbsTol',1e-8);
[t,theta] = ode45(@(t,theta) theta_dot(theta,sigma,tau,N), tspan, theta0, opts);

%% Plot of the angles as a function of time
% Plot results
figure(1);
% Plot with thicker line and markers
plot(t, theta, '-', 'LineWidth', 1.5);
% Labels with LaTeX formatting
xlabel('Time (s)', 'Interpreter', 'latex', 'FontSize', 12);
ylabel('$\theta_i$', 'Interpreter', 'latex', 'FontSize', 12);
% Title with LaTeX
title('Hexbug Simulation', 'Interpreter', 'latex', 'FontSize', 14);
% Add grid
grid on;
grid minor; % optional for minor grid lines
% Optional: set axis limits for better view

%% Plot of the mean curvature and mean polarization as a phase plot
%Two quantities of interest from Zheng 2023 et al.,
mean_curv = theta(:,7)-theta(:,1);
mean_pol = 1/N.*sum(theta,2);
figure(2);

% Plot with line style, color, and markers
plot(mean_pol, mean_curv, '-', 'LineWidth', 1.5)

% Labels with LaTeX formatting
xlabel('Mean Polarization', 'Interpreter', 'latex', 'FontSize', 12);
ylabel('Mean Curvature', 'Interpreter', 'latex', 'FontSize', 12);

% Title
title('Mean Curvature vs. Mean Polarization', 'Interpreter', 'latex', 'FontSize', 14);

% Grid
grid on;
grid minor;

% Optional: add axis limits to better frame the data
xlim([min(mean_pol) max(mean_pol)]);
ylim([min(mean_curv) max(mean_curv)]);

% Optional: add legend if plotting multiple series
% legend('Data', 'Location', 'best', 'Interpreter', 'latex');


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

hold off


function dtheta = theta_dot(theta, sigma, tau, N)
    A = zeros(N,N);
    b = zeros(N,1);

    % i = 1
    sum_sin = sum(sin(theta(1) - theta));
    A(1,1) = tau * N;
    A(1,2:N) = tau * cos(theta(1) - theta(2:end));
    b(1) = - (2*theta(1) - theta(2) - sigma * sum_sin);

    % i = 2:N-1
    for i = 2:N-1
        sum_sin = sum(sin(theta(i) - theta(i:N)));
        % Build A row
        for j = 1:i
            A(i,j) = tau * (N-i+1) * cos(theta(i) - theta(j));
        end
        for j = i+1:N
            A(i,j) = tau * (N-j+1) * cos(theta(i) - theta(j));
        end
        % Right-hand side
        b(i) = - (2*theta(i) - theta(i-1) - theta(i+1) - sigma*sum_sin);
    end

    % i = N
    for j = 1:N
        A(N,j) = tau * cos(theta(N) - theta(j));
    end
    b(N) = - (theta(N) - theta(N-1));

    % Solve linear system for theta_dot
    dtheta = A\b;
end
