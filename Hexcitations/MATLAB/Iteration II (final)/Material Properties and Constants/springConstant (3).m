clear; close all; clc;

% === STEP 1: Folder setup ===
base_folder = '/Users/sarahnguyen/Desktop/ENGN1735Project/spring'; % <- change if needed
rod_folders = {'3'};

results = struct([]);
g = 9.81; % m/s^2

for f = 1:length(rod_folders)
    rod_name = rod_folders{f};
    folder = fullfile(base_folder, rod_name);

    % === STEP 2: Find images ===
    images = [dir(fullfile(folder, '*.jpg')); ...
              dir(fullfile(folder, '*.jpeg')); ...
              dir(fullfile(folder, '*.png')); ...
              dir(fullfile(folder, '*.tif')); ...
              dir(fullfile(folder, '*.bmp'))];
    n = length(images);
    if n == 0
        warning('No images found in %s', folder);
        continue;
    end

    fprintf('\n=== Processing folder: %s ===\n', rod_name);

    % Prepare arrays
    rod_lengths_mm = zeros(n, 1);
    masses = zeros(n, 1);

    % === STEP 3: Process each image ===
    for i = 1:n
        img_name = images(i).name;
        img_path = fullfile(folder, img_name);
        img = imread(img_path);
        figure(1); imshow(img);

        % --- Ruler calibration ---
        title(sprintf('%s: Click TWO ruler points 10 cm apart (%s)', rod_name, img_name));
        [xr, yr] = ginput(2);
        ruler_px = sqrt(diff(xr).^2 + diff(yr).^2);
        mm_per_px = 100 / ruler_px; % 10 cm = 100 mm

        % --- Measure rod ---
        title(sprintf('%s: Click BASE and TIP of the rod (%s)', rod_name, img_name));
        [xrod, yrod] = ginput(2);
        rod_length_px = sqrt(diff(xrod).^2 + diff(yrod).^2);
        rod_lengths_mm(i) = rod_length_px * mm_per_px;

        % --- Extract mass from filename ---
        mass_str = regexp(img_name, '\d+', 'match');
        if ~isempty(mass_str)
            masses(i) = str2double(mass_str{1}) / 1000; % g → kg
        else
            warning('No mass found in filename: %s', img_name);
        end

        close; % close current image
    end

    % === STEP 4: Compute deflection and fit ===
    L0 = rod_lengths_mm(1); % reference length (first image)
    deflection_mm = rod_lengths_mm - L0;
    forces = masses * g;

    % Linear fit F = kx
    p = polyfit(deflection_mm, forces, 1);
    k = p(1); % N/mm

    fprintf('Spring constant for %s = %.4f N/mm\n', rod_name, k);

    % Store results
    results(end+1).name = rod_name;
    results(end).deflection_mm = deflection_mm;
    results(end).forces = forces;
    results(end).k = k;

    % Plot
    figure(100); hold on;
    plot(deflection_mm, forces, 'o', 'DisplayName', rod_name);
    plot(deflection_mm, polyval(p, deflection_mm), '-', 'HandleVisibility', 'off');
    xlabel('Deflection (mm)');
    ylabel('Force (N)');
    grid on;
end

% === STEP 5: Summary ===
if isempty(results)
    error('No valid data found. Check your folders and images.');
end

figure(100);
title('Force vs Deflection (recalibrated each image)');
legend('Location', 'best');

fprintf('\n=== Summary of spring constants ===\n');
for f = 1:length(results)
    fprintf('%s: k = %.4f N/mm\n', results(f).name, results(f).k);
end

