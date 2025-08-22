%% Step 9a: Calculate Toe-Off, Stride Time, Step Time, and Swing Time for Right and Left Legs (Refined)

% Validate input
if ~exist('df_drop_nan', 'var') || ~exist('Lheel_strikes_all', 'var') || ~exist('Rheel_strikes_all', 'var')
    error('Required variables (df_drop_nan, Lheel_strikes_all, Rheel_strikes_all) are missing. Ensure previous steps are completed.');
end

% Toolbox-free local minima detector
function minima_idx = find_local_minima(signal)
    % Assumes signal is a column vector
    signal = signal(:);
    minima_idx = find([false; diff(signal(1:end-1)) < 0 & diff(signal(2:end)) > 0; false]);
end

% Initialize storage
num_files = size(df_drop_nan, 1);
num_trials = size(df_drop_nan, 2);
toe_off_left = cell(num_files, num_trials);
toe_off_right = cell(num_files, num_trials);
stride_time_left = cell(num_files, num_trials);
stride_time_right = cell(num_files, num_trials);
step_time_left = cell(num_files, num_trials);
step_time_right = cell(num_files, num_trials);
swing_time_left = cell(num_files, num_trials);
swing_time_right = cell(num_files, num_trials);

disp('Step 10: Calculating Toe-Off, Stride Time, Step Time, and Swing Time for Right and Left Legs...');

for file_idx = 1:num_files
    for trial_idx = 1:num_trials
        if isempty(df_drop_nan{file_idx, trial_idx})
            fprintf('Skipping file %d, Trial %d: Missing raw data.\n', file_idx, trial_idx);
            continue;
        end

        % Extract columns: 6 = Left Toe, 12 = Right Toe
        left_column = df_drop_nan{file_idx, trial_idx}(:, 6);
        right_column = df_drop_nan{file_idx, trial_idx}(:, 12);

        % Detect toe-off (local minima)
        toe_off_left_idx = find_local_minima(left_column);
        toe_off_right_idx = find_local_minima(right_column);

        toe_off_left{file_idx, trial_idx} = toe_off_left_idx;
        toe_off_right{file_idx, trial_idx} = toe_off_right_idx;

        % Extract heel strikes
        Lheel_strikes = Lheel_strikes_all{file_idx, trial_idx};
        Rheel_strikes = Rheel_strikes_all{file_idx, trial_idx};

        % Stride time
        stride_time_left{file_idx, trial_idx} = diff(Lheel_strikes);
        stride_time_right{file_idx, trial_idx} = diff(Rheel_strikes);

        % Step time
        min_len = min(length(Lheel_strikes), length(Rheel_strikes));
        step_time_left_trial = zeros(min_len - 1, 1);
        step_time_right_trial = zeros(min_len - 1, 1);

        for i = 1:(min_len - 1)
            step_time_left_trial(i) = abs(Rheel_strikes(i) - Lheel_strikes(i));
            step_time_right_trial(i) = abs(Lheel_strikes(i) - Rheel_strikes(i));
        end

        step_time_left{file_idx, trial_idx} = step_time_left_trial;
        step_time_right{file_idx, trial_idx} = step_time_right_trial;

        % Swing time
        swing_time_left_trial = nan(length(toe_off_left_idx), 1);
        swing_time_right_trial = nan(length(toe_off_right_idx), 1);

        for i = 1:length(toe_off_left_idx)
            next_heel_idx = find(Lheel_strikes > toe_off_left_idx(i), 1);
            if ~isempty(next_heel_idx)
                swing_time_left_trial(i) = Lheel_strikes(next_heel_idx) - toe_off_left_idx(i);
            end
        end

        for i = 1:length(toe_off_right_idx)
            next_heel_idx = find(Rheel_strikes > toe_off_right_idx(i), 1);
            if ~isempty(next_heel_idx)
                swing_time_right_trial(i) = Rheel_strikes(next_heel_idx) - toe_off_right_idx(i);
            end
        end

        swing_time_left{file_idx, trial_idx} = swing_time_left_trial;
        swing_time_right{file_idx, trial_idx} = swing_time_right_trial;

        fprintf('File %d, Trial %d: Toe-Off, Stride, Step, and Swing Times Calculated.\n', file_idx, trial_idx);
    end
end

% Save to workspace
assignin('base', 'toe_off_left', toe_off_left);
assignin('base', 'toe_off_right', toe_off_right);
assignin('base', 'stride_time_left', stride_time_left);
assignin('base', 'stride_time_right', stride_time_right);
assignin('base', 'step_time_left', step_time_left);
assignin('base', 'step_time_right', step_time_right);
assignin('base', 'swing_time_left', swing_time_left);
assignin('base', 'swing_time_right', swing_time_right);

disp('Step 9a completed: Toe-Off, Stride, Step, and Swing Times saved to Workspace.');

%% Step 9b: Calculate Average Phase (φ), φ_ABS, φ_CV, and PCI for Both Legs
% Validate inputs
if ~exist('stride_time_right', 'var') || ~exist('step_time_right', 'var') || ...
   ~exist('step_time_left', 'var') || ~exist('stride_time_left', 'var')
    error('Required stride and step time variables are missing. Ensure previous steps are completed.');
end

% Initialize result containers
num_files = size(stride_time_right, 1);
num_trials = size(stride_time_right, 2);
R_phi = cell(num_files, num_trials);
L_phi = cell(num_files, num_trials);
R_phi_abs = cell(num_files, num_trials);
L_phi_abs = cell(num_files, num_trials);
R_phi_cv = cell(num_files, num_trials);
L_phi_cv = cell(num_files, num_trials);
R_pci = cell(num_files, num_trials);
L_pci = cell(num_files, num_trials);

disp('✅ Step 10b: Calculating average φ, φ_ABS, φ_CV, and PCI for both legs...');

for file_idx = 1:num_files
    for trial_idx = 1:num_trials
        % Check data availability
        if isempty(stride_time_right{file_idx, trial_idx}) || isempty(step_time_right{file_idx, trial_idx}) || ...
           isempty(step_time_left{file_idx, trial_idx}) || isempty(stride_time_left{file_idx, trial_idx})
            fprintf('Skipping File %d, Trial %d: Incomplete timing data.\n', file_idx, trial_idx);
            continue;
        end

        % Get values
        stride_R = stride_time_right{file_idx, trial_idx};
        stride_L = stride_time_left{file_idx, trial_idx};
        step_R = step_time_right{file_idx, trial_idx};
        step_L = step_time_left{file_idx, trial_idx};

        % Trim lengths to match dimensions
        min_len_R = min([length(stride_R), length(step_R), length(step_L)]);
        min_len_L = min([length(stride_L), length(step_R), length(step_L)]);

        stride_R = stride_R(1:min_len_R);
        step_L = step_L(1:min_len_R);
        stride_L = stride_L(1:min_len_L);
        step_R = step_R(1:min_len_L);

        % --- Right Reference ---
        R_phase_all = mod((360 * step_L) ./ stride_R, 360);
        R_phase_all(R_phase_all > 180) = 360 - R_phase_all(R_phase_all > 180);
        R_phi_mean = mean(R_phase_all, 'omitnan');
        R_phi_abs_mean = mean(abs(R_phase_all - 180), 'omitnan');
        R_phi_cv_value = (std(R_phase_all, 'omitnan') / R_phi_mean) * 100;
        R_pci_value = R_phi_cv_value + (R_phi_abs_mean / 180) * 100;

        % --- Left Reference ---
        L_phase_all = mod((360 * step_R) ./ stride_L, 360);
        L_phase_all(L_phase_all > 180) = 360 - L_phase_all(L_phase_all > 180);
        L_phi_mean = mean(L_phase_all, 'omitnan');
        L_phi_abs_mean = mean(abs(L_phase_all - 180), 'omitnan');
        L_phi_cv_value = (std(L_phase_all, 'omitnan') / L_phi_mean) * 100;
        L_pci_value = L_phi_cv_value + (L_phi_abs_mean / 180) * 100;

        % Save SCALAR results into each cell
        R_phi{file_idx, trial_idx} = R_phi_mean;
        L_phi{file_idx, trial_idx} = L_phi_mean;
        R_phi_abs{file_idx, trial_idx} = R_phi_abs_mean;
        L_phi_abs{file_idx, trial_idx} = L_phi_abs_mean;
        R_phi_cv{file_idx, trial_idx} = R_phi_cv_value;
        L_phi_cv{file_idx, trial_idx} = L_phi_cv_value;
        R_pci{file_idx, trial_idx} = R_pci_value;
        L_pci{file_idx, trial_idx} = L_pci_value;

        % Optional: display summary
        fprintf('File %d, Trial %d → R_PCI = %.2f | L_PCI = %.2f\n', ...
                file_idx, trial_idx, R_pci_value, L_pci_value);
    end
end

% Save to Workspace
assignin('base', 'R_phi', R_phi);
assignin('base', 'L_phi', L_phi);
assignin('base', 'R_phi_abs', R_phi_abs);
assignin('base', 'L_phi_abs', L_phi_abs);
assignin('base', 'R_phi_cv', R_phi_cv);
assignin('base', 'L_phi_cv', L_phi_cv);
assignin('base', 'R_pci', R_pci);
assignin('base', 'L_pci', L_pci);

disp('✅ Step 9b complete: Scalar metrics saved to Workspace.');