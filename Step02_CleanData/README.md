# Step 02: Clean Gait Data by Removing NaN Rows

This step ensures the integrity of the gait data by removing any rows with missing values (`NaN`) from each trial. Cleaning the data at this early stage is critical for accurate segmentation, normalization, and downstream computation of CRP and PCI.

---

## 🔍 Objective

To clean each trial dataset by:
- Iterating through all subject-trial combinations
- Identifying and removing any rows that contain missing values
- Returning a clean version of the dataset for further processing

---

## ⚙️ Processing Steps

1. Validate that the data structure `df_list` (from Step 01) exists.
2. Iterate over each file and each trial within the `df_list` cell array.
3. For each non-empty table:
   - Convert the table to a numeric array (if needed)
   - Remove any rows that contain `NaN` values
4. Store cleaned data in a new variable `df_drop_nan`.

---

## ✅ Key Concepts and Functions

- `isnan()`: Checks for missing values
- `any(..., 2)`: Detects if any value in a row is `NaN`
- `table2array()`: Converts table to numeric array for processing
- `cell`: Data is stored in a 2D cell array by subject × trial
- `assignin('base', ...)`: Stores the cleaned result in the MATLAB base workspace

---

## 💡 Why This Step Is Important

- Ensures that no invalid or partial data skews results
- Prevents errors during signal filtering, gait cycle detection, and phase angle computation
- Makes the analysis reproducible and robust, especially for batch processing

---

## 🧪 Code Snippet (demonstration only)

```matlab
function cleaned_trials = clean_data(data_list)
    cleaned_trials = cell(size(data_list));

    for trial_idx = 1:numel(data_list)
        if ~isempty(data_list{trial_idx})
            trial_data = data_list{trial_idx};

            if istable(trial_data)
                trial_data = table2array(trial_data);
            end

            cleaned_trials{trial_idx} = trial_data(~any(isnan(trial_data), 2), :);
        else
            cleaned_trials{trial_idx} = [];
        end
    end
end
