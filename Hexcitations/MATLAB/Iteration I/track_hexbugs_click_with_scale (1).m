function track_hexbugs_click_with_scale
% Track freely moving HexBugs from video only, initialized by user clicks.
% Adds a reference-scale step: click two points spanning a known length, then enter length & unit.
% Outputs: <video>_traj.csv with time_s, x_i(px), y_i(px), x_i(unit), y_i(unit), theta_i(rad)
% Requires: Image Processing Toolbox.

clear; close all;

% USER SETTINGS
boxsz            = 120;   % template/measurement crop size (px) around each bug
searchMargin     = 70;    % +/- px search window around last center
preBlurSigma     = 0.8;   % Gaussian blur before matching (0 = off)
estimateTheta    = true;  % compute theta; now robust with tuned optimizer + fallback
unwrapThetaFlag  = true;  % unwrap theta over time for continuity
makePreviewVideo = false; % write <video>_preview.mp4 with overlays
previewFPS       = 15;
maxFramesPerVid  = inf;   % e.g., 1500 for quick tests

% Theta smoothing controls
thetaSmoothEnable = true;   % turn on/off smoothing
thetaSmoothSec    = 0.20;   % Savitzky–Golay window length (seconds)
thetaOrder        = 3;      % SG polynomial order
thetaMedianSec    = 0.06;   % short median (or movmedian) window (seconds) for despiking
% ------------------------------------------------

% DIRECT FILE PATH, changed for each trial
file_list = dir('/Users/helenprimis/Downloads/2_bugs_cages.MOV');

for jj = 1:numel(file_list)
    % Build full video path and base name
    videoPath = fullfile(file_list(jj).folder, file_list(jj).name);
    [~, base, ~] = fileparts(file_list(jj).name);

    % Open video
    v  = VideoReader(videoPath);
    total_frames = min([floor(v.Duration * v.FrameRate), maxFramesPerVid]);
    fprintf('\n[%s] frames ~ %d at %.2f fps\n', file_list(jj).name, total_frames, v.FrameRate);

    % First frame and shift to gray scale for contrasdt
    frame1    = readFrame(v);
    firstGray = toGray(frame1);

    %SCALE: Click reference ruler with two slicks on either end
    hFig = figure('Name','Click TWO points that span a known length','Color','w','NumberTitle','off');
    imshow(firstGray, 'InitialMagnification','fit');
    title({'Click TWO points spanning a known length.','Press Enter to finish, or Esc to skip.'});
    set(hFig,'Pointer','crosshair'); drawnow;
    try
        [xr, yr, btn] = ginput(2);
    catch
        xr = []; yr = []; btn = 27;
    end
    close(hFig);

    haveScale = numel(xr)==2 && ~any(btn==27);
    unitsStr  = 'px';
    unitPerPx = 1.0; % default if no scale is properly selected

    % identify scale by number and dimension
    if haveScale
        dpx = hypot(xr(2)-xr(1), yr(2)-yr(1));   % pixel distance
        prompt  = {'Real length (numeric):','Units (e.g., mm, cm, in):'};
        dlgttl  = 'Reference scale';
        defans  = {'100','mm'};
        answ    = inputdlg(prompt, dlgttl, 1, defans);
        if isempty(answ)
            warning('Scale entry canceled. Positions will be in pixels only.');
        else
            realLen = str2double(answ{1});
            if ~isfinite(realLen) || realLen <= 0
                warning('Invalid real length. Positions will be in pixels only.');
            else
                unitsStr  = strtrim(answ{2});
                unitsStr  = regexprep(unitsStr, '\W+', ''); % sanitize for table var names
                if isempty(unitsStr), unitsStr = 'units'; end
                unitPerPx = realLen / dpx;
                fprintf('Scale set: 1 px = %.6g %s\n', unitPerPx, unitsStr);
            end
        end
    else
        fprintf('No valid ruler selected. Positions remain in pixels.\n');
    end

    %% MANUAL INIT: Click each bug once and hit enter when done
    figure('Name','Click each bug once (press Enter when done)'); imshow(firstGray, 'InitialMagnification','fit');
    title('Click each HexBug center; press Enter when done');
    [x0,y0] = ginput; close;
    centers0 = [x0(:) y0(:)];
    num_particles = size(centers0,1);
    if num_particles < 1
        error('No clicks provided. Click each bug center, then press Enter.');
    end
    fprintf('Initialized %d bug(s) from clicks.\n', num_particles);

    % Per-bug templates from frame 1 
    templates = cell(1, num_particles);
    for k = 1:num_particles
        roi = safeCrop(firstGray, centers0(k,1), centers0(k,2), boxsz);
        if preBlurSigma > 0, roi = imgaussfilt(roi, preBlurSigma); end
        templates{k} = roi;
    end

    % Configure for theta with optimization settings
    if estimateTheta
        [optimizer, metric] = imregconfig('monomodal');

        % TUNE OPTIMIZER + metric for robustness
        if isa(optimizer,'images.registration.RegularStepGradientDescent')
            optimizer.MaximumIterations  = 80;
            optimizer.MaximumStepLength  = 0.05;
            optimizer.MinimumStepLength  = 1e-4;
            optimizer.RelaxationFactor   = 0.5;
        elseif isa(optimizer,'images.registration.OnePlusOneEvolutionary')
            optimizer.GrowthFactor       = 1.01;
            optimizer.InitialRadius      = 0.004;
            optimizer.Epsilon            = 1.5e-6;
            optimizer.MaximumIterations  = 80;
        end
        % More "illumination-robust metric" to handle theta optimizer
        metric = registration.metric.MattesMutualInformation;

        % Mute the diverged warning error
        warning('off','images:imregtform:registrationDiverged');
    end

    % Read indexed proceeding frames
    v2 = VideoReader(videoPath);

    % Preallocate to what we identified above
    Xpx  = nan(total_frames, num_particles);
    Ypx  = nan(total_frames, num_particles);
    TH   = nan(total_frames, num_particles);

    % Seed frame 1 with clicks
    Xpx(1,:)  = centers0(:,1).';
    Ypx(1,:)  = centers0(:,2).';
    TH(1,:)   = 0;

    % Preview writer
    if makePreviewVideo
        previewPath = fullfile(file_list(jj).folder, [base '_preview.mp4']);
        vw = VideoWriter(previewPath, 'MPEG-4');
        vw.FrameRate = previewFPS; open(vw);
        frameOut = drawOverlay(frame1, centers0, TH(1,:), boxsz);
        writeVideo(vw, frameOut);
    end

    % Main tracking loop
    for ii = 2:total_frames
        frame = read(v2, [ii ii]);
        gray  = toGray(frame);
        if preBlurSigma > 0
            grayForMatch = imgaussfilt(gray, preBlurSigma);
        else
            grayForMatch = gray;
        end

        for k = 1:num_particles
            % 1) center tracking by local template match
            cx0 = Xpx(ii-1,k); cy0 = Ypx(ii-1,k);
            win = searchMargin + boxsz/2;
            search = safeCrop(grayForMatch, cx0, cy0, 2*win);

            [dx, dy, ok] = bestOffsetNormXCorr(templates{k}, search);
            if ~ok
                cx = cx0; cy = cy0;   % fallback: hold previous
            else
                cx = cx0 + dx; cy = cy0 + dy;
            end
            Xpx(ii,k) = cx; Ypx(ii,k) = cy;

            % 2) orientation (θ) with robust fallback
            if estimateTheta
                meas = safeCrop(gray, cx, cy, boxsz);
                try
                    tmpl  = im2single(templates{k});
                    measS = im2single(meas);
                    % Hist-match for illumination changes (helps MI metric too)
                    try
                        measS = imhistmatch(measS, tmpl);
                    catch
                        % older releases may not have imhistmatch
                    end
                    tform = imregtform(tmpl, measS, 'rigid', optimizer, metric);
                    TH(ii,k) = atan2(tform.T(2,1), tform.T(1,1));
                catch
                    % Fallback: orientation from blob moments in the crop
                    try
                        bw = imbinarize(meas, 'adaptive', 'ForegroundPolarity','dark', 'Sensitivity',0.55);
                        bw = bwareafilt(bw, [50, inf]);  % drop noise
                        s  = regionprops(bw, 'Area','Orientation');
                        if ~isempty(s)
                            [~,idx] = max([s.Area]);
                            TH(ii,k) = deg2rad(s(idx).Orientation);
                        else
                            TH(ii,k) = TH(ii-1,k);
                        end
                    catch
                        TH(ii,k) = TH(ii-1,k);
                    end
                end
            else
                TH(ii,k) = TH(ii-1,k);
            end
        end

        if makePreviewVideo
            frameOut = drawOverlay(frame, [Xpx(ii,:).' Ypx(ii,:).'], TH(ii,:), boxsz);
            writeVideo(vw, frameOut);
        end

        if mod(ii, max(1, round(v2.FrameRate)))==0
            fprintf('  frame %d / %d\r', ii, total_frames);
        end
    end
    fprintf('\n');

    % Unwrap data + smoothing for theta 
    if estimateTheta
        % unwrap first
        for k = 1:num_particles
            TH(:,k) = unwrap(TH(:,k));
        end

        if thetaSmoothEnable
            Fs   = v.FrameRate;
            medN = max(1, round(thetaMedianSec * Fs));
            sgN  = max(3, 2*floor((thetaSmoothSec * Fs)/2) + 1); % force odd

            % Keep a copy in case you also want to save raw by
            % uncommenting:
            % TH_raw = TH;

            %help from AI with the smoothing

            % 1) despike: median (or movmedian if medfilt1 missing)
            if exist('medfilt1','file')
                TH = medfilt1(TH, medN, [], 1, 'omitnan', 'truncate');
            else
                TH = movmedian(TH, medN, 1, 'omitnan');
            end

            % 2) smooth: Savitzky–Golay (fallback to movmean)
            if exist('sgolayfilt','file')
                for k = 1:num_particles
                    TH(:,k) = sgolayfilt(TH(:,k), thetaOrder, sgN);
                end
            else
                TH = smoothdata(TH, 1, 'movmean', sgN);
            end

            % Optional: wrap to [-pi, pi] for neater plots
            TH = mod(TH + pi, 2*pi) - pi;
        end
    end

% Convert theta from radians to degrees
TH = rad2deg(TH);

    % Convert pixels -> physical units identified from before
    Xunit = Xpx * unitPerPx;
    Yunit = Ypx * unitPerPx;

    % Save a CSV
    t = (0:total_frames-1)'/v.FrameRate;
    T = array2table(t, 'VariableNames', {'time_s'});
    for k = 1:num_particles
        T.(['x' num2str(k) '_px'])        = Xpx(:,k);
        T.(['y' num2str(k) '_px'])        = Ypx(:,k);
        T.(['x' num2str(k) '_' unitsStr]) = Xunit(:,k);
        T.(['y' num2str(k) '_' unitsStr]) = Yunit(:,k);
        T.(['theta' num2str(k) '_deg'])   = TH(:,k);  
        % If you want both raw and smoothedtheta , uncomment: 
        % T.(['theta' num2str(k) '_raw_rad']) = TH_raw(:,k);
    end

    out_csv = fullfile(file_list(jj).folder, [base '_traj.csv']);
    fid = fopen(out_csv, 'w');
    if fid ~= -1
        fprintf(fid, '%% scale: 1 px = %.10g %s\n', unitPerPx, unitsStr);
        fprintf(fid, '%% video_fps: %.6g\n', v.FrameRate);
        fprintf(fid, '%% theta_smoothing: enable=%d, median_s=%.3g, sgolay_s=%.3g, order=%d\n', ...
            thetaSmoothEnable, thetaMedianSec, thetaSmoothSec, thetaOrder);
        fclose(fid);
    end
    writetable(T, out_csv, 'WriteMode','Append');
    fprintf('Saved: %s\n', out_csv);

    % Plots for trajectory and Theta

% First: XY trajectories 
figure('Name', sprintf('Two Hexbug Test with Cages— XY Trajectories (%s)', base, unitsStr), 'Color', 'w'); hold on

for k = 1:num_particles
    plot(Xunit(:,k), Yunit(:,k), 'LineWidth', 1.5);
    plot(Xunit(1,k), Yunit(1,k), 'o', 'HandleVisibility','off');
end

axis equal
xlabel(sprintf('x (%s)', unitsStr), 'Interpreter','latex', 'FontSize', 14);
ylabel(sprintf('y (%s)', unitsStr), 'Interpreter','latex', 'FontSize', 14);
title(sprintf('Two Hexbug Test with Cages - XY Trajectories'), 'Interpreter','latex', 'FontSize', 16);
legend(arrayfun(@(k)sprintf('Bug %d',k),1:num_particles,'UniformOutput',false), ...
       'Interpreter','latex', 'FontSize', 12, 'Location','best');

% adding format recommendation per Jack's advice
box on; grid on;
set(gca, 'LineWidth', 0.7, ...
         'FontName', 'Times New Roman', ...
         'FontSize', 12, ...
         'TickLabelInterpreter','latex');
hold off


% Second Theta vs Time 
figure('Name', sprintf('Two Hexbug Test with Cages — %s (%s)', base, unitsStr), ...
       'Color','w', 'NumberTitle','off'); hold on

for k = 1:num_particles
    plot(t, TH(:,k), 'LineWidth', 1.5);
end
xlabel('Time (s)', 'Interpreter','latex', 'FontSize', 14);
ylabel('Theta (degrees)', 'Interpreter','latex', 'FontSize', 14);
title(sprintf('Two Hexbug Test with Cages - Orientation vs Time'), 'Interpreter','latex', 'FontSize', 16);
legend(arrayfun(@(k)sprintf('Bug %d',k),1:num_particles,'UniformOutput',false), ...
       'Interpreter','latex', 'FontSize', 12, 'Location','best');

% Similar formatting to above
box on; grid on;
set(gca, 'LineWidth', 0.7, ...
         'FontName', 'Times New Roman', ...
         'FontSize', 12, ...
         'TickLabelInterpreter','latex');
hold off

%x and y plots wrt to t for debugging purposes
    % Helpful x(t) and y(t) plots to uncomment if 
    % figure('Name', sprintf('%s - x vs time (%s)', base, unitsStr), 'Color','w'); hold on
    % for k = 1:num_particles, plot(t, Xunit(:,k), 'LineWidth', 1.3); end
    % grid on; xlabel('Time (s)'); ylabel(sprintf('x (%s)', unitsStr));
    % title(sprintf('%s - x vs time (%s)', base, unitsStr));
    % legend(arrayfun(@(k)sprintf('Bug %d',k),1:num_particles,'UniformOutput',false),'Location','best');
    % 
    % figure('Name', sprintf('%s - y vs time (%s)', base, unitsStr), 'Color','w'); hold on
    % for k = 1:num_particles, plot(t, Yunit(:,k), 'LineWidth', 1.3); end
    % grid on; xlabel('Time (s)'); ylabel(sprintf('y (%s)', unitsStr));
    % title(sprintf('%s - y vs time (%s)', base, unitsStr));
    % legend(arrayfun(@(k)sprintf('Bug %d',k),1:num_particles,'UniformOutput',false),'Location','best');
    % 
    % % Pixel debugging recommendation from AI to identify other issues in
    % the code
    % figure('Name', sprintf('%s - x vs time (px)', base), 'Color','w'); hold on
    % for k = 1:num_particles, plot(t, Xpx(:,k), 'LineWidth', 1.3); end
    % grid on; xlabel('Time (s)'); ylabel('x (px)');
    % title(sprintf('%s - x vs time (px)', base));
    % legend(arrayfun(@(k)sprintf('Bug %d',k),1:num_particles,'UniformOutput',false),'Location','best');
    % 
    % figure('Name', sprintf('%s - y vs time (px)', base), 'Color','w'); hold on
    % for k = 1:num_particles, plot(t, Ypx(:,k), 'LineWidth', 1.3); end
    % grid on; xlabel('Time (s)'); ylabel('y (px)');
    % title(sprintf('%s - y vs time (px)', base));
    % legend(arrayfun(@(k)sprintf('Bug %d',k),1:num_particles,'UniformOutput',false),'Location','best');
end
end

% Helpers --> recommended by AI to aid with the tracking sensitivity of our
% problem prompt

function I = toGray(frame)
    if size(frame,3)==3
        I = rgb2gray(frame);
    else
        I = frame;
    end
    I = im2uint8(I);
end

function crop = safeCrop(img, cx, cy, boxsz)
% Centered crop with padding (replicate) to avoid edge issues.
    half = boxsz/2;
    rect = [cx-half, cy-half, boxsz, boxsz];   % [x y w h]
    pad  = ceil(boxsz);
    imgP = padarray(img, [pad pad], 'replicate','both');
    rectP = rect + [pad pad 0 0];
    crop  = imcrop(imgP, rectP);
    if isempty(crop)
        rect2 = round(rectP);
        rect2(1) = max(1, rect2(1));
        rect2(2) = max(1, rect2(2));
        rect2(3) = min(rect2(3), size(imgP,2)-rect2(1));
        rect2(4) = min(rect2(4), size(imgP,1)-rect2(2));
        crop = imcrop(imgP, rect2);
    end
end

function [dx, dy, ok] = bestOffsetNormXCorr(template, search)
% Best (dx,dy) aligning template within search via normalized cross-correlation.
% Offsets are in pixels relative to the search center.
    ok = true;
    try
        tmp = im2double(template);
        sea = im2double(search);
        c = normxcorr2(tmp, sea);
        [~, imax] = max(c(:));
        [ypeak, xpeak] = ind2sub(size(c), imax);

        % Top-left of best match
        yoff = ypeak - size(tmp,1);
        xoff = xpeak - size(tmp,2);

        % Center of template coords
        cx_t = xoff + size(tmp,2)/2;
        cy_t = yoff + size(tmp,1)/2;

        % Offset relative to search center
        dx = cx_t - size(sea,2)/2;
        dy = cy_t - size(sea,1)/2;
    catch
        dx = 0; dy = 0; ok = false;
    end
end

function frameOut = drawOverlay(frameRGB, centers, thetas, boxsz)
% Draw centers, crop boxes, and orientation ticks from the initii.
    frameOut = frameRGB;
    if size(frameOut,3)==1, frameOut = repmat(frameOut,[1 1 3]); end
    L = 0.35 * boxsz;
    for k = 1:size(centers,1)
        cx = centers(k,1); cy = centers(k,2);
        rect = [cx - boxsz/2, cy - boxsz/2, boxsz, boxsz];
        frameOut = insertShape(frameOut, 'Rectangle', rect, 'LineWidth', 2);
        frameOut = insertMarker(frameOut, [cx cy], 'x', 'Color','yellow', 'Size', 8);
        th = thetas(k);
        x2 = cx + L*cos(th);
        y2 = cy + L*sin(th);
        frameOut = insertShape(frameOut, 'Line', [cx cy x2 y2], 'LineWidth', 3);
    end
end
