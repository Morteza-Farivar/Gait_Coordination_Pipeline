%% Step 5: Process, Center, Normalize, and Filter Gait Cycles for All Trials (No toolboxes)

% Validate input
if ~exist('df_drop_nan', 'var') || isempty(df_drop_nan) || ...
   ~exist('Lheel_strikes_all', 'var') || isempty(Lheel_strikes_all) || ...
   ~exist('Rheel_strikes_all', 'var') || isempty(Rheel_strikes_all)
    error('Required variables are missing or undefined. Ensure Steps 2, 3, and 4 run successfully before Step 5.');
end

% Parameters
num_points = 100;       % Number of points for normalization
window_size = 5;        % Moving average window size (must be odd)

% Preallocate
num_files = size(df_drop_nan, 1);
num_trials = size(df_drop_nan, 2);
centered_cycles_all = cell(num_files, num_trials);
normalized_cycles_all = cell(num_files, num_trials);

% Moving average filter
moving_avg_filter = @(data, w) conv(data, ones(w,1)/w, 'same');

disp('Processing, centering, normalizing, and filtering gait cycles (no toolboxes)...');

for file_idx = 1:num_files
    for trial_idx = 1:num_trials
        if ~isempty(df_drop_nan{file_idx, trial_idx}) && ...
           ~isempty(Lheel_strikes_all{file_idx, trial_idx}) && ...
           length(Lheel_strikes_all{file_idx, trial_idx}) > 1

            trial_data = df_drop_nan{file_idx, trial_idx};
            Lheel_strikes = Lheel_strikes_all{file_idx, trial_idx};
            Rheel_strikes = Rheel_strikes_all{file_idx, trial_idx};

            num_cycles = length(Lheel_strikes) - 1;
            centered_cycles = cell(num_cycles, 1);
            normalized_cycles = cell(num_cycles, 1);

            for cycle_idx = 1:num_cycles
                start_idx = Lheel_strikes(cycle_idx);
                end_idx = Lheel_strikes(cycle_idx + 1);

                if end_idx <= size(trial_data, 1)
                    current_cycle = trial_data(start_idx:end_idx, :);
                    centered_cycle = current_cycle - mean(current_cycle, 1, 'omitnan');

                    % Interpolate (normalize) to 100 points
                    original_len = size(centered_cycle, 1);
                    x_old = linspace(0, 1, original_len);
                    x_new = linspace(0, 1, num_points);
                    normalized_cycle = zeros(num_points, size(centered_cycle, 2));
                    for col_idx = 1:size(centered_cycle, 2)
                        normalized_cycle(:, col_idx) = interp1(x_old, centered_cycle(:, col_idx), x_new, 'linear');
                    end

                    % Apply moving average filter to each column
                    filtered_cycle = zeros(size(normalized_cycle));
                    for col_idx = 1:size(normalized_cycle, 2)
                        filtered_cycle(:, col_idx) = moving_avg_filter(normalized_cycle(:, col_idx), window_size);
                    end

                    centered_cycles{cycle_idx} = centered_cycle;
                    normalized_cycles{cycle_idx} = struct( ...
                        'L_thigh_X', filtered_cycle(:, 17)', ...
                        'L_thigh_Y', filtered_cycle(:, 18)', ...
                        'L_thigh_Z', filtered_cycle(:, 19)', ...
                        'L_shank_X', filtered_cycle(:, 20)', ...
                        'L_shank_Y', filtered_cycle(:, 21)', ...
                        'L_shank_Z', filtered_cycle(:, 22)', ...
                        'L_foot_X', filtered_cycle(:, 14)', ...
                        'L_foot_Y', filtered_cycle(:, 15)', ...
                        'L_foot_Z', filtered_cycle(:, 16)', ...
                        'R_thigh_X', filtered_cycle(:, 26)', ...
                        'R_thigh_Y', filtered_cycle(:, 27)', ...
                        'R_thigh_Z', filtered_cycle(:, 28)', ...
                        'R_shank_X', filtered_cycle(:, 29)', ...
                        'R_shank_Y', filtered_cycle(:, 30)', ...
                        'R_shank_Z', filtered_cycle(:, 31)', ...
                        'R_foot_X', filtered_cycle(:, 23)', ...
                        'R_foot_Y', filtered_cycle(:, 24)', ...
                        'R_foot_Z', filtered_cycle(:, 25)', ...
                        'pelvis_X', filtered_cycle(:, 35)', ...
                        'pelvis_Y', filtered_cycle(:, 36)', ...
                        'pelvis_Z', filtered_cycle(:, 37)', ...
                        'trunk_X', filtered_cycle(:, 32)', ...
                        'trunk_Y', filtered_cycle(:, 33)', ...
                        'trunk_Z', filtered_cycle(:, 34)' ...
                    );
                else
                    fprintf('Skipping cycle %d in file %d, trial %d: Data range insufficient.\n', ...
                        cycle_idx, file_idx, trial_idx);
                end
            end

            centered_cycles_all{file_idx, trial_idx} = centered_cycles;
            normalized_cycles_all{file_idx, trial_idx} = normalized_cycles;
        else
            fprintf('Skipping file %d, trial %d: Missing or insufficient heel strikes.\n', file_idx, trial_idx);
        end
    end
end

disp('Gait cycle centering, normalization, and filtering completed for all files and trials (toolbox-free).');

% Save to Workspace
assignin('base', 'centered_cycles_all', centered_cycles_all);
assignin('base', 'normalized_cycles_all', normalized_cycles_all);

disp('Step 5 completed: Centered, normalized, and filtered data saved successfully.');
