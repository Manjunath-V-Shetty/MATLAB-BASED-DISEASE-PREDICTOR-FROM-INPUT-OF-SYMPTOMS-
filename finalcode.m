%% Disease Recommender System in MATLAB

% Read CSV files with preserved original headers
description = readtable('description.csv', 'VariableNamingRule', 'preserve');
diets = readtable('diets.csv', 'VariableNamingRule', 'preserve');
medications = readtable('medications.csv', 'VariableNamingRule', 'preserve');
precautions = readtable('precautions_df.csv', 'VariableNamingRule', 'preserve');
symptoms_df = readtable('symtoms_df.csv', 'VariableNamingRule', 'preserve');
workouts = readtable('workout_df.csv', 'VariableNamingRule', 'preserve');
severity = readtable('Symptom-severity.csv', 'VariableNamingRule', 'preserve');
training = readtable('Training.csv', 'VariableNamingRule', 'preserve');

% Convert all column names to lowercase for consistency
description.Properties.VariableNames = lower(description.Properties.VariableNames);
diets.Properties.VariableNames = lower(diets.Properties.VariableNames);
medications.Properties.VariableNames = lower(medications.Properties.VariableNames);
precautions.Properties.VariableNames = lower(precautions.Properties.VariableNames);
symptoms_df.Properties.VariableNames = lower(symptoms_df.Properties.VariableNames);
workouts.Properties.VariableNames = lower(workouts.Properties.VariableNames);
severity.Properties.VariableNames = lower(severity.Properties.VariableNames);
training.Properties.VariableNames = lower(training.Properties.VariableNames);

%% Replace missing strings with 'None'
vars = training.Properties.VariableNames;
for i = 1:length(vars)
    col = training.(vars{i});
    if iscell(col) || isstring(col)
        idx = cellfun(@(x) isempty(x) || (isstring(x) && strlength(x) == 0), col);
        col(idx) = {'None'};
        training.(vars{i}) = col;
    end
end

%% Take user symptoms as input
user_input = input('Enter your symptoms (comma separated): ', 's');
input_symptoms = strtrim(strsplit(lower(user_input), ','));

%% Match symptoms to training data
match_scores = zeros(height(training), 1);

for i = 1:height(training)
    row_symptoms = lower(string(training{i, 1:end-1}));
    match_scores(i) = sum(ismember(input_symptoms, row_symptoms));
end

[~, best_match_idx] = max(match_scores);
predicted_disease = training{best_match_idx, end}{1};

fprintf('\n🔍 Predicted Disease: %s\n', predicted_disease);

%% Display information

% Description
desc_idx = strcmpi(description.disease, predicted_disease);
if any(desc_idx)
    fprintf('📝 Description: %s\n', description.description{desc_idx});
end

% Medications
med_idx = strcmpi(medications.disease, predicted_disease);
if any(med_idx)
    meds = medications{med_idx, 2:end};
    meds = meds(~cellfun('isempty', meds));
    fprintf('💊 Medications: %s\n', strjoin(meds, ', '));
end

% Precautions
prec_idx = strcmpi(precautions.disease, predicted_disease);
if any(prec_idx)
    pre = precautions{prec_idx, 2:end};
    pre = pre(~cellfun('isempty', pre));
    fprintf('⚠ Precautions: %s\n', strjoin(pre, ', '));
end

% Diets
diet_idx = strcmpi(diets.disease, predicted_disease);
if any(diet_idx)
    diet = diets{diet_idx, 2:end};
    diet = diet(~cellfun('isempty', diet));
    fprintf('🥗 Diets: %s\n', strjoin(diet, ', '));
end

% Workouts
work_idx = strcmpi(workouts.disease, predicted_disease);
if any(work_idx)
    work = workouts{work_idx, 2:end};
    work = work(~cellfun('isempty', work));
    fprintf('🏃 Workouts: %s\n', strjoin(work, ', '));
end