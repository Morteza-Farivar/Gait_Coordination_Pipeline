# Step 03: Extract Segment Data for Each Trial

This step extracts specific joint or segment kinematic data (e.g., thigh, shank, foot, pelvis, trunk) from each cleaned trial. The segment data will later be used for computing phase angles, CRP, and PCI.

---

## 🔍 Objective

To iterate through each subject and trial, and extract 3D angular position data (X, Y, Z) for the following body segments:
- Left Leg: thigh, shank, foot
- Right Leg: thigh, shank, foot
- Pelvis and Trunk
- Time column (for alignment)

Each segment is extracted into a dedicated cell array for future phase angle computations.

---

## ⚙️ Processing Steps

1. **Validate cleaned data** from Step 02 (`df_drop_nan` must exist).
2. For each file and trial:
   - Check that data exists and has enough columns
   - Extract relevant columns for each segment:
     - L_foot: Columns 14–16
     - L_thigh: Columns 17–19
     - L_shank: Columns 20–22
     - R_foot: Columns 23–25
     - R_thigh: Columns 26–28
     - R_shank: Columns 29–31
     - Trunk: Columns 32–34
     - Pelvis: Columns 35–37
   - Also extract Time column: Column 1
3. Store each extracted segment in a corresponding cell array.

---

## ✅ Key Concepts and Functions

- **Cell arrays** for storing each segment’s data by subject × trial
- `trial_data(:, X:Y)`: column slicing for extracting segment data
- **Validation checks** for missing or incomplete trials
- `isempty()` and `size()` for robust indexing
    end
end

disp('Step 3 completed: Joint angle data extracted successfully.');
