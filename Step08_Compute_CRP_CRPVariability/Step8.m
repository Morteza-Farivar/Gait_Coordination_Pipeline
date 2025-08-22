%% Step 8: Compute and Store CRP and Variability for All Gait Cycles 

% Validate inputs
if ~exist('phase_angles', 'var') || isempty(phase_angles)
    error('Phase angles are missing. Ensure Step 7 runs successfully before Step 8.');
end

% Define segment couplings and axes
segment_couplings = {
    'L_thigh', 'L_shank'; ...
    'L_shank', 'L_foot'; ...
    'R_thigh', 'R_shank'; ...
    'R_shank', 'R_foot'; ...
    'R_thigh', 'pelvis'; ...
    'L_thigh', 'pelvis'; ...
    'trunk', 'pelvis'
};
axes = {'X', 'Y', 'Z'};

% Initialize output storage
num_files = size(phase_angles.(segment_couplings{1, 1}).(axes{1}), 1);
num_trials = size(phase_angles.(segment_couplings{1, 1}).(axes{1}), 2);
crp_all = struct();
crp_variability = struct();

for coupling_idx = 1:size(segment_couplings, 1)
    for ax = 1:numel(axes)
        coupling_name = [segment_couplings{coupling_idx, 1}, '_', segment_couplings{coupling_idx, 2}];
        crp_all.(coupling_name).(axes{ax}) = cell(num_files, num_trials);
        crp_variability.(coupling_name).(axes{ax}) = cell(num_files, num_trials);
    end
end

disp('Computing CRP and Variability for all gait cycles...');

% Loop through files and trials
for file_idx = 1:num_files
    for trial_idx = 1:num_trials
        % Skip if no data
        if isempty(phase_angles.(segment_couplings{1, 1}).(axes{1}){file_idx, trial_idx})
            fprintf('Skipping file %d, trial %d: No phase angle data.\n', file_idx, trial_idx);
            continue;
        end

        % Process each coupling and axis
        for coupling_idx = 1:size(segment_couplings, 1)
            for ax = 1:numel(axes)
                distal = segment_couplings{coupling_idx, 1};
                proximal = segment_couplings{coupling_idx, 2};
                axis_label = axes{ax};
                coupling_name = [distal, '_', proximal];

                % Get phase angles
                distal_angle = phase_angles.(distal).(axis_label){file_idx, trial_idx};
                proximal_angle = phase_angles.(proximal).(axis_label){file_idx, trial_idx};

                % Validate phase angles
                if isempty(distal_angle) || isempty(proximal_angle)
                    fprintf('Skipping file %d, trial %d, coupling %s: Missing phase data.\n', ...
                        file_idx, trial_idx, coupling_name);
                    continue;
                end

                % Check for invalid values
                has_extreme_distal = any(abs([distal_angle{:}]) > 360);
                has_extreme_proximal = any(abs([proximal_angle{:}]) > 360);

                if has_extreme_distal | has_extreme_proximal
                    warning('Extreme phase angle values detected in file %d, trial %d, segment %s, axis %s. Skipping this trial.\n', ...
                        file_idx, trial_idx, distal, axis_label);
                    continue;
                end

                % Compute CRP for all cycles
                num_cycles = numel(distal_angle);
                crp_cycles = zeros(num_cycles, 100);

                for cycle_idx = 1:num_cycles
                    crp_cycles(cycle_idx, :) = distal_angle{cycle_idx} - proximal_angle{cycle_idx};
                end

                % Wrap CRP to [-180, 180] degrees
                crp_cycles_deg = mod(crp_cycles + 180, 360) - 180;

                % Store CRP
                crp_all.(coupling_name).(axis_label){file_idx, trial_idx} = crp_cycles_deg;

                % Compute CRP variability (std of deviation from mean)
                crp_mean = mean(crp_cycles_deg, 1, 'omitnan');
                variability = std(crp_cycles_deg - crp_mean, 0, 1, 'omitnan');

                crp_variability.(coupling_name).(axis_label){file_idx, trial_idx} = variability;
            end
        end
    end
end

disp('CRP and Variability computation completed.');

% Save results to Workspace
assignin('base', 'crp_all', crp_all);
assignin('base', 'crp_variability', crp_variability);

disp('Step 8 completed: CRP and Variability data saved successfully.');