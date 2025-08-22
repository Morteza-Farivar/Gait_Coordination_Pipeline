%% Step 4: Clean Extracted Data for Each Trial (Refined Without findpeaks)

% Validate input
if ~exist('df_drop_nan', 'var') || isempty(df_drop_nan)
    error('df_drop_nan is undefined or empty. Ensure Steps 2 and 3 run successfully before Step 4.');
end

disp('Step 4: Detecting Heel Strikes (without findpeaks)...');

num_files = size(df_drop_nan, 1);
num_trials = size(df_drop_nan, 2);

LHeel_Y_all = cell(num_files, num_trials);
RHeel_Y_all = cell(num_files, num_trials);
Lheel_strikes_all = cell(num_files, num_trials);
Rheel_strikes_all = cell(num_files, num_trials);
gait_cycles_count = struct();

% Helper function to detect peaks manually
function peak_indices = detect_peaks(signal, min_peak_height, min_peak_distance)
    % Find indices where the signal goes from increasing to decreasing
    peak_indices = [];
    for i = 2:length(signal)-1
        if signal(i) > min_peak_height && signal(i) > signal(i-1) && signal(i) > signal(i+1)
            if isempty(peak_indices) || (i - peak_indices(end)) >= min_peak_distance
                peak_indices(end+1) = i; %#ok<AGROW>
            end
        end
    end
end

% Process each file and trial
for file_idx = 1:num_files
    for trial_idx = 1:num_trials
        trial_data = df_drop_nan{file_idx, trial_idx};
        if ~isempty(trial_data) && size(trial_data, 2) >= 9
            LHeel_Y = trial_data(:, 3); % Column 3: Left Heel Y
            RHeel_Y = trial_data(:, 9); % Column 9: Right Heel Y

            LHeel_Y_all{file_idx, trial_idx} = LHeel_Y;
            RHeel_Y_all{file_idx, trial_idx} = RHeel_Y;

            % Thresholds for peak detection
            threshold_L = 0.3 * max(LHeel_Y);
            threshold_R = 0.3 * max(RHeel_Y);
            min_distance = 50;

            % Detect peaks manually
            L_peaks = detect_peaks(LHeel_Y, threshold_L, min_distance);
            R_peaks = detect_peaks(RHeel_Y, threshold_R, min_distance);

            Lheel_strikes_all{file_idx, trial_idx} = L_peaks;
            Rheel_strikes_all{file_idx, trial_idx} = R_peaks;

            % Store Gait Cycle Count
            subject_key = sprintf('Subject_%d', file_idx);
            trial_key = sprintf('Trial_%d', trial_idx);
            if ~isfield(gait_cycles_count, subject_key)
                gait_cycles_count.(subject_key) = struct();
            end
            gait_cycles_count.(subject_key).(trial_key) = struct( ...
                'LeftHeelStrikes', length(L_peaks), ...
                'RightHeelStrikes', length(R_peaks) ...
            );
        else
            fprintf('Skipping trial %d in file %d: Not enough columns or no data.\n', trial_idx, file_idx);
        end
    end
end

% Save results to workspace
assignin('base', 'LHeel_Y_all', LHeel_Y_all);
assignin('base', 'RHeel_Y_all', RHeel_Y_all);
assignin('base', 'Lheel_strikes_all', Lheel_strikes_all);
assignin('base', 'Rheel_strikes_all', Rheel_strikes_all);
assignin('base', 'gait_cycles_count', gait_cycles_count);

disp('Step 4 completed: Heel strike detection (manual) done for all trials.');