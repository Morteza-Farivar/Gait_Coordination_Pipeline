%% Step 4: Determining Gait Cycle based on Toe Strike

% Validate input
if ~exist('df_drop_nan', 'var') || isempty(df_drop_nan)
    error('df_drop_nan is undefined or empty. Ensure Steps 2 and 3 run successfully before Step 4.');
end

% Debugging: Check the structure of df_drop_nan
disp('Debugging df_drop_nan structure:');
disp(['Number of trials in df_drop_nan: ', num2str(length(df_drop_nan))]);

% Preallocate cell arrays for all files and trials
num_files = size(df_drop_nan, 1); % Number of files
num_trials = size(df_drop_nan, 2); % Number of trials per file

LToe_Y_all = cell(num_files, num_trials); % Preallocated Left Toe Y-coordinates
RToe_Y_all = cell(num_files, num_trials); % Preallocated Right Toe Y-coordinates
Ltoe_strikes_all = cell(num_files, num_trials); % Preallocated Left Toe strikes
Rtoe_strikes_all = cell(num_files, num_trials); % Preallocated Right Toe strikes

% Initialize structure to count gait cycles
gait_cycles_count = struct();

% Filter parameters
[b, a] = butter(4, 10 / (250 / 2), 'low'); % Low-pass filter design (10Hz cutoff)

% Process each file and trial
disp('Processing Toe Strike data for each file and trial...');
for file_idx = 1:num_files
    for trial_idx = 1:num_trials
        % Ensure the trial contains valid data
        if ~isempty(df_drop_nan{file_idx, trial_idx}) && size(df_drop_nan{file_idx, trial_idx}, 2) >= 12
            % Extract raw Y-coordinates for Left and Right Toe
            LToe_Y_raw = df_drop_nan{file_idx, trial_idx}(:, 6); % Column 6: Left Toe
            RToe_Y_raw = df_drop_nan{file_idx, trial_idx}(:, 12); % Column 12: Right Toe

            % Apply low-pass filter to smooth the data
            LToe_Y_filtered = filtfilt(b, a, LToe_Y_raw);
            RToe_Y_filtered = filtfilt(b, a, RToe_Y_raw);

            % Compute dynamic thresholds based on mean and standard deviation
            threshold_L = mean(LToe_Y_filtered) - 0.5 * std(LToe_Y_filtered);
            threshold_R = mean(RToe_Y_filtered) - 0.5 * std(RToe_Y_filtered);

            % Define dynamic MinPeakDistance based on walking speed (e.g., 0.6 seconds interval)
            MinPeakDistance = round(0.6 * 250); % Assuming 250Hz sampling rate

            % Detect Toe Strikes for Left and Right using findpeaks
            [~, Ltoe_strikes] = findpeaks(-LToe_Y_filtered, ...
                'MinPeakHeight', -threshold_L, 'MinPeakDistance', MinPeakDistance);
            [~, Rtoe_strikes] = findpeaks(-RToe_Y_filtered, ...
                'MinPeakHeight', -threshold_R, 'MinPeakDistance', MinPeakDistance);

            % Store results in preallocated cells
            LToe_Y_all{file_idx, trial_idx} = LToe_Y_filtered;
            RToe_Y_all{file_idx, trial_idx} = RToe_Y_filtered;
            Ltoe_strikes_all{file_idx, trial_idx} = Ltoe_strikes;
            Rtoe_strikes_all{file_idx, trial_idx} = Rtoe_strikes;

            % Count Gait Cycles
            num_Ltoe_strikes = length(Ltoe_strikes);
            num_Rtoe_strikes = length(Rtoe_strikes);

            % Store Gait Cycle Count
            subject_key = sprintf('Subject_%d', file_idx);
            trial_key = sprintf('Trial_%d', trial_idx);

            if ~isfield(gait_cycles_count, subject_key)
                gait_cycles_count.(subject_key) = struct();
            end
            gait_cycles_count.(subject_key).(trial_key) = struct(...
                'LeftToeStrikes', num_Ltoe_strikes, ...
                'RightToeStrikes', num_Rtoe_strikes);
        else
            fprintf('Skipping trial %d in file %d: Not enough columns or no data.\n', trial_idx, file_idx);
            LToe_Y_all{file_idx, trial_idx} = [];
            RToe_Y_all{file_idx, trial_idx} = [];
            Ltoe_strikes_all{file_idx, trial_idx} = [];
            Rtoe_strikes_all{file_idx, trial_idx} = [];
        end
    end
end

disp('Toe Strike detection for all files and trials completed.');

% Save results to Workspace
assignin('base', 'LToe_Y_all', LToe_Y_all);
assignin('base', 'RToe_Y_all', RToe_Y_all);
assignin('base', 'Ltoe_strikes_all', Ltoe_strikes_all);
assignin('base', 'Rtoe_strikes_all', Rtoe_strikes_all);

% Save Gait Cycle Counts
assignin('base', 'gait_cycles_count', gait_cycles_count);

disp('Step 4 completed: Data for all files and trials saved successfully.');
disp('Gait Cycle Counts saved to Workspace.');