%% DNPDR_Main.m
% Main script for DNPDR analysis

% Copyright (C) 2024-2025 Chanhee Jeong

clear; close all;

%% Import and preprocess data
[DNPDRP, DNPDRC] = DNPDR_GetData(); % 78 DNPDRPs, 26 DNPDRCs

% Exclude subjects with extensive missing data
DNPDRC([1, 14], :) = []; % 24 DNPDRCs

% Console log
fprintf("=== Data loaded (DNPDRP: %d, DNPDRC: %d) ===\n", size(DNPDRP, 1), size(DNPDRC, 1));

%% Get Patient/Control information
% (Patient information: 7 variables) Serial, Sex, Age, YOB, Onset_year, Dx_year, Dx_month
DNPDRP_info = table2array(DNPDRP(:, 2:7)); % Leave Serial out
DNPDRP_sex = DNPDRP_info(:, 1);
DNPDRP_age = DNPDRP_info(:, 2);
DNPDRP_onset_year = DNPDRP_info(:, 4);
DNPDRP_diagnosis_year = DNPDRP_info(:, 5) + DNPDRP_info(:, 6)/12;
DNPDRP_duration = DNPDRP_diagnosis_year - DNPDRP_onset_year;

% (Control information: 4 variables) Serial, Sex, Age, YOB
DNPDRC_info = table2array(DNPDRC(:, 2:4)); % Leave Serial out
DNPDRC_sex = DNPDRC_info(:, 1);
DNPDRC_age = DNPDRC_info(:, 2);

%% Get Patient/Control UPDRS Scores
% (Patient UPDRS: 68 variables) UPDRS_year, UPDRS_month, UPDRS_part1 x 13, UPDRS_part2 x 13, UPDRS_part3 x 33, UPDRS_part4 x 6, HY score
DNPDRP_updrs = table2array(DNPDRP(:, 8:75));
DNPDRP_updrs_year = DNPDRP_updrs(:, 1) + DNPDRP_updrs(:, 2)/12;
DNPDRP_updrs_duration = DNPDRP_updrs_year - DNPDRP_onset_year;
DNPDRP_u1 = DNPDRP_updrs(:, 3:15);
DNPDRP_u2 = DNPDRP_updrs(:, 16:28);
DNPDRP_u3 = DNPDRP_updrs(:, 29:61);
DNPDRP_u4 = DNPDRP_updrs(:, 62:67);
DNPDRP_hy = DNPDRP_updrs(:, 68);

% Console log
fprintf("> Loaded Patient UPDRS part 1 scores, %d missing values\n", sum(FindNaN(DNPDRP_u1)));
fprintf("> Loaded Patient UPDRS part 2 scores, %d missing values\n", sum(FindNaN(DNPDRP_u2)));
fprintf("> Loaded Patient UPDRS part 3 scores, %d missing values\n", sum(FindNaN(DNPDRP_u3)));
fprintf("> Loaded Patient UPDRS part 4 scores, %d missing values\n", sum(FindNaN(DNPDRP_u4)));
fprintf("> Loaded Patient H-Y scores, %d missing values\n", sum(FindNaN(DNPDRP_hy)));

% Account missing values for duration
P_updrs_duration = DNPDRP_updrs_duration(~FindNaN(DNPDRP_u1));
P_hy_duration = DNPDRP_updrs_duration(~FindNaN(DNPDRP_hy));

% Remove missing values
P_u1 = RemoveNaN(DNPDRP_u1);
P_u2 = RemoveNaN(DNPDRP_u2);
P_u3 = RemoveNaN(DNPDRP_u3);
P_u4 = RemoveNaN(DNPDRP_u4);
P_hy = RemoveNaN(DNPDRP_hy);

% (Control UPDRS: 68 variables) UPDRS_year, UPDRS_month, UPDRS_part1 x 13, UPDRS_part2 x 13, UPDRS_part3 x 33, UPDRS_part4 x 6, HY score
DNPDRC_updrs = table2array(DNPDRC(:, 5:72)); % No need to consider control group's UPDRS year/month
DNPDRC_u1 = DNPDRC_updrs(:, 3:15);
DNPDRC_u2 = DNPDRC_updrs(:, 16:28);
DNPDRC_u3 = DNPDRC_updrs(:, 29:61);
DNPDRC_u4 = DNPDRC_updrs(:, 62:67);
DNPDRC_hy = DNPDRC_updrs(:, 68);

% Console log
fprintf("> Loaded Control UPDRS part 1 scores, %d missing values\n", sum(FindNaN(DNPDRC_u1)));
fprintf("> Loaded Control UPDRS part 2 scores, %d missing values\n", sum(FindNaN(DNPDRC_u2)));
fprintf("> Loaded Control UPDRS part 3 scores, %d missing values\n", sum(FindNaN(DNPDRC_u3)));
fprintf("> Loaded Control UPDRS part 4 scores, %d missing values\n", sum(FindNaN(DNPDRC_u4)));
fprintf("> Loaded Control H-Y scores, %d missing values\n", sum(FindNaN(DNPDRC_hy)));

% Remove missing values
C_u1 = RemoveNaN(DNPDRC_u1);
C_u2 = RemoveNaN(DNPDRC_u2);
C_u3 = RemoveNaN(DNPDRC_u3);
C_u4 = RemoveNaN(DNPDRC_u4);
C_hy = RemoveNaN(DNPDRC_hy);

% UPDRS item strings
DNPDR_u1_items = ["Cognitive impairment", "Hallucinations and psychosis", "Depressed mood", "Anxious mood", "Apathy", "Dopamine dysregulation", ...
"Sleep problems", "Daytime sleepiness", "Pain and others", "Urinary problems", "Constipation", "Light headedness", "Fatigue"];
DNPDR_u2_items = ["Speech", "Saliva drooling", "Chewing swallowing", "Eating tasks", "Dressing", "Hygiene", "Handwriting", "Doing hobbies", ...
"Turning in bed", "Tremor", "Get out of bed", "Walking balance", "Freezing"];
DNPDR_u3_items = ["Speech", "Facial expression", "Rigidity (Neck)", "Rigidity (RUE)", "Rigidity (LUE)", "Rigidity (RLE)", "Rigidity (LLE)", ...
"Finger tapping (R)", "Finger tapping (L)", "Hand movements (R)", "Hand movements (L)", "Pronation/Supination (R)", "Pronation/Supination (L)", ...
"Toe tapping (R)", "Toe tapping (L)", "Leg agility (R)", "Leg agility (L)", "Arising from chair", "Gait", "Freezing", "Postural stability", ...
"Posture", "Bradykinesia", "Postural tremor (R)", "Postural tremor (L)", "Kinetic tremor (R)", "Kinetic tremor (L)", "Rest tremor (RUE)", ...
"Rest tremor (LUE)", "Rest tremor (RLE)", "Rest tremor (LLE)", "Rest tremor (Jaw)", "Rest tremor constancy"];
DNPDR_hy_items = "H-Y score";

% Result: Visualize UPDRS score distribution
% DNPDR_DistributionBar(DNPDRP_u1, "UPDRS part 1", DNPDR_u1_items);  
% DNPDR_DistributionBar(DNPDRP_u2, "UPDRS part 2", DNPDR_u2_items);
% DNPDR_DistributionBar(DNPDRP_hy, "H-Y score", DNPDR_hy_items);
% DNPDR_DistributionBar(DNPDRC_u1, "UPDRS part 1", DNPDR_u1_items);
% DNPDR_DistributionBar(DNPDRC_u2, "UPDRS part 2", DNPDR_u2_items);
% DNPDR_DistributionBar(DNPDRC_hy, "H-Y score", DNPDR_hy_items);

% Display boxplot after Mann–Whitney test
% DNPDR_SimpleBox(DNPDRP_u1, DNPDRC_u1, DNPDR_u1_items)
% DNPDR_SimpleBox(DNPDRP_u2, DNPDRC_u2, DNPDR_u2_items)
% DNPDR_SimpleBox(DNPDRP_hy, DNPDRC_hy, DNPDR_hy_items)

% UPDRS part 3 (modified)
DNPDRP_u3m = [DNPDRP_u3(:, [1, 2]), sum(DNPDRP_u3(:, 3:7), 2), sum(DNPDRP_u3(:, 8:9), 2), sum(DNPDRP_u3(:, 10:11), 2), sum(DNPDRP_u3(:, 12:13), 2), ...
sum(DNPDRP_u3(:, 14:15), 2), sum(DNPDRP_u3(:, 16:17), 2), DNPDRP_u3(:, 18:22), sum(DNPDRP_u3(:, 23:24), 2), sum(DNPDRP_u3(:, 25:26), 2), ...
sum(DNPDRP_u3(:, 27:31), 2), DNPDRP_u3(:, 32:33)];
DNPDRC_u3m = [DNPDRC_u3(:, [1, 2]), sum(DNPDRC_u3(:, 3:7), 2), sum(DNPDRC_u3(:, 8:9), 2), sum(DNPDRC_u3(:, 10:11), 2), sum(DNPDRC_u3(:, 12:13), 2), ...
sum(DNPDRC_u3(:, 14:15), 2), sum(DNPDRC_u3(:, 16:17), 2), DNPDRC_u3(:, 18:22), sum(DNPDRC_u3(:, 23:24), 2), sum(DNPDRC_u3(:, 25:26), 2), ...
sum(DNPDRC_u3(:, 27:31), 2), DNPDRC_u3(:, 32:33)];

DNPDR_u3m_items = ["Speech", "Facial expression", "Rigidity", "Finger tapping", "Hand movements", "Pronation/Supination", ...
"Toe tapping", "Leg agility", "Arising from chair", "Gait", "Freezing", "Postural stability", "Posture", "Bradykinesia", ...
"Postural tremor", "Kinetic tremor", "Rest tremor", "Rest tremor constancy"];

% Display boxplot after Mann–Whitney test
% DNPDR_SimpleBox(DNPDRP_u3m, DNPDRC_u3m, DNPDR_u3m_items)

% (Patient group) UPDRS part 1, 2, 3, total vs Sex, Age, Duration
% DNPDR_PlotLR(DNPDRP_info(:, 2), sum(DNPDRP_u1, 2), ["Sex", "UPDRS part1"]); DNPDR_PlotLR(DNPDRP_info(:, 3), sum(DNPDRP_u1, 2), ["Age", "UPDRS part1"]); DNPDR_PlotLR(DNPDRP_updrs_duration, sum(DNPDRP_u1, 2), ["Duration", "UPDRS part1"]);
% DNPDR_PlotLR(DNPDRP_info(:, 2), sum(DNPDRP_u2, 2), ["Sex", "UPDRS part2"]); DNPDR_PlotLR(DNPDRP_info(:, 3), sum(DNPDRP_u2, 2), ["Age", "UPDRS part2"]); DNPDR_PlotLR(DNPDRP_updrs_duration, sum(DNPDRP_u2, 2), ["Duration", "UPDRS part2"]);
% DNPDR_PlotLR(DNPDRP_info(:, 2), sum(DNPDRP_u3, 2), ["Sex", "UPDRS part3"]); DNPDR_PlotLR(DNPDRP_info(:, 3), sum(DNPDRP_u3, 2), ["Age", "UPDRS part3"]); DNPDR_PlotLR(DNPDRP_updrs_duration, sum(DNPDRP_u3, 2), ["Duration", "UPDRS part3"]);
% DNPDR_PlotLR(DNPDRP_info(:, 2), sum(DNPDRP_u1, 2) + sum(DNPDRP_u2, 2) + sum(DNPDRP_u3, 2), ["Sex", "UPDRS total"]); DNPDR_PlotLR(DNPDRP_info(:, 3), sum(DNPDRP_u1, 2) + sum(DNPDRP_u2, 2) + sum(DNPDRP_u3, 2), ["Age", "UPDRS total"]); DNPDR_PlotLR(DNPDRP_updrs_duration, sum(DNPDRP_u1, 2) + sum(DNPDRP_u2, 2) + sum(DNPDRP_u3, 2), ["Duration", "UPDRS total"]);

% (Control group) UPDRS part 1, 2, 3, total vs Sex, Age
%DNPDR_PlotLR(DNPDRC_info(:, 2), sum(DNPDRC_u1, 2), ["Sex", "UPDRS part1"]); DNPDR_PlotLR(DNPDRC_info(:, 3), sum(DNPDRC_u1, 2), ["Age", "UPDRS part1"]);
%DNPDR_PlotLR(DNPDRC_info(:, 2), sum(DNPDRC_u2, 2), ["Sex", "UPDRS part2"]); DNPDR_PlotLR(DNPDRC_info(:, 3), sum(DNPDRC_u2, 2), ["Age", "UPDRS part2"]);
%DNPDR_PlotLR(DNPDRC_info(:, 2), sum(DNPDRC_u3, 2), ["Sex", "UPDRS part3"]); DNPDR_PlotLR(DNPDRC_info(:, 3), sum(DNPDRC_u3, 2), ["Age", "UPDRS part3"]);
%DNPDR_PlotLR(DNPDRC_info(:, 2), sum(DNPDRC_u1, 2) + sum(DNPDRC_u2, 2) + sum(DNPDRC_u3, 2), ["Sex", "UPDRS total"]); DNPDR_PlotLR(DNPDRC_info(:, 3), sum(DNPDRC_u1, 2) + sum(DNPDRC_u2, 2) + sum(DNPDRC_u3, 2), ["Age", "UPDRS total"]);

%% Get Patient/Control MMSE Scores
% (Patient MMSE: 3 variables) MMSE_year, MMSE_month, MMSE_score
DNPDRP_mmse = table2array(DNPDRP(:, 76:78));
DNPDRP_mmse_year = DNPDRP_mmse(:, 1) + DNPDRP_mmse(:, 2)/12;
DNPDRP_mmse_duration = DNPDRP_mmse_year - DNPDRP_onset_year;
DNPDRP_m = DNPDRP_mmse(:, 3);

% Console log
fprintf("> Loaded Patient MMSE scores, %d missing values\n", sum(FindNaN(DNPDRP_m)));

% Account missing values for duration
P_mmse_duration = DNPDRP_mmse_duration(~FindNaN(DNPDRP_m));

% Remove missing values
P_m = RemoveNaN(DNPDRP_m);

% (Control MMSE: 3 variables) MMSE_year, MMSE_month, MMSE_score
DNPDRC_mmse = table2array(DNPDRC(:, 73:75)); % No need to consider control group's MMSE year/month
DNPDRC_m = DNPDRC_mmse(:, 3);

% Console log
fprintf("> Loaded Control MMSE scores, %d missing values\n", sum(FindNaN(DNPDRC_m)));

% Remove missing values
C_m = RemoveNaN(DNPDRC_m);

% MMSE item strings
DNPDR_mmse_items = "MMSE score";

% Result: Visualize MMSE score distribution
% DNPDR_DistributionBar(DNPDRP_m, "MMSE score", DNPDR_mmse_items);
% DNPDR_DistributionBar(DNPDRC_m, "MMSE score", DNPDR_mmse_items);

P_m_mci = P_m < 24;
C_m_mci = C_m < 24;

P_m_mciratio = sum(P_m_mci, 1)/size(P_m_mci, 1);
C_m_mciratio = sum(C_m_mci, 1)/size(C_m_mci, 1);

% DNPDR_SimplePercentBar(P_m_mciratio*100, DNPDR_mmse_items, "MMSE <24 percentage", strcat("Patient MMSE (n=", num2str(size(P_m_mci, 1)), ")"));
% DNPDR_SimplePercentBar(C_m_mciratio*100, DNPDR_mmse_items, "MMSE <24 percentage", strcat("Control MMSE (n=", num2str(size(C_m_mci, 1)), ")"));

% Display boxplot after Mann–Whitney test
% DNPDR_SimpleBox(DNPDRP_m, DNPDRC_m, DNPDR_mmse_items)

% (Patient group) MMSE vs Sex, Age, Duration
% DNPDR_PlotLR(DNPDRP_info(:, 2), DNPDRP_m, ["Sex", "MMSE"]); DNPDR_PlotLR(DNPDRP_info(:, 3), DNPDRP_m, ["Age", "MMSE"]); DNPDR_PlotLR(DNPDRP_mmse_duration, DNPDRP_m, ["Duration", "MMSE"]);

% (Control group) MMSE vs Sex, Age
% DNPDR_PlotLR(DNPDRC_info(:, 2), DNPDRC_mmse, ["Sex", "MMSE"]); DNPDR_PlotLR(DNPDRC_info(:, 3), DNPDRC_mmse, ["Age", "MMSE"]);

%% Get Patient/Control KVHQ Scores
% (Patient KVHQ: 22 variables) KVHQ_year, KVHQ_month, KVHQ_part1 x 10, KVHQ_part2 x 10
DNPDRP_kvhq = table2array(DNPDRP(:, 79:100));
DNPDRP_kvhq_year = DNPDRP_kvhq(:, 1) + DNPDRP_kvhq(:, 2)/12;
DNPDRP_kvhq_duration = DNPDRP_kvhq_year - DNPDRP_onset_year;
DNPDRP_k1 = DNPDRP_kvhq(:, 3:12);
DNPDRP_k2 = DNPDRP_kvhq(:, 13:22);

% Console log
fprintf("> Loaded Patient KVHQ scores, %d missing values\n", sum(FindNaN(DNPDRP_k1)));

% Account missing values for duration
P_kvhq_duration = DNPDRP_kvhq_duration(~FindNaN(DNPDRP_k1));

% Remove missing values
P_k1 = RemoveNaN(DNPDRP_k1);
P_k2 = RemoveNaN(DNPDRP_k2);

% (Control KVHQ: 22 variables) KVHQ_year, KVHQ_month, KVHQ_part1 x 10, KVHQ_part2 x 10
DNPDRC_kvhq = table2array(DNPDRC(:, 76:97)); % No need to consider control group's KVHQ year/month
DNPDRC_k1 = DNPDRC_kvhq(:, 3:12);
DNPDRC_k2 = DNPDRC_kvhq(:, 13:22);

% Console log
fprintf("> Loaded Control KVHQ scores, %d missing values\n", sum(FindNaN(DNPDRC_k1)));

% Remove missing values
C_k1 = RemoveNaN(DNPDRC_k1);
C_k2 = RemoveNaN(DNPDRC_k2);

% KVHQ item strings
DNPDR_kvhq1_items = ["빛 번짐", "글자 안 보임", "직선이 곡선으로", "야간 시력 문제", "헤드라이트 반짝", "빠른 움직임 어려움", ...
"깊이 인식 어려움", "채도 구분 어려움", "배경 위 글자", "조명 변화 글자"];
DNPDR_kvhq2_items = ["없는 사람이 보임", "시야 가장자리", "무언가 지나감", "그림자 형태", "다른 것으로 착각", "실제로 없는 물체", ...
"실제가 아닌 소리", "실제가 아닌 촉감", "실제가 아닌 냄새", "실제가 아닌 맛"];

% KVHQ symptom presence
DNPDRP_k1_presence = DNPDRP_k1 ~= 0;
DNPDRP_k2_presence = DNPDRP_k2 ~= 0;
DNPDRC_k1_presence = DNPDRC_k1 ~= 0;
DNPDRC_k2_presence = DNPDRC_k2 ~= 0;

P_k1_presence = P_k1 ~= 0;
P_k2_presence = P_k2 ~= 0;
C_k1_presence = C_k1 ~= 0;
C_k2_presence = C_k2 ~= 0;

% KVHQ symptom presence ratio
P_k1_ratio = sum(P_k1_presence, 1)/size(P_k1_presence, 1);
P_k2_ratio = sum(P_k2_presence, 1)/size(P_k2_presence, 1);
C_k1_ratio = sum(C_k1_presence, 1)/size(C_k1_presence, 1);
C_k2_ratio = sum(C_k2_presence, 1)/size(C_k2_presence, 1);

% Result: Visualize KVHQ symptom presence percentages
% DNPDR_SimplePercentBar(P_k1_ratio*100, DNPDR_kvhq1_items, "Symptom presence %", strcat("Patient K-VHQ part 1 (n=", num2str(size(P_k1_presence, 1)), ")"));
% DNPDR_SimplePercentBar(P_k2_ratio*100, DNPDR_kvhq2_items, "Symptom presence %", strcat("Patient K-VHQ part 2 (n=", num2str(size(P_k2_presence, 1)), ")"));
% DNPDR_SimplePercentBar(C_k1_ratio*100, DNPDR_kvhq1_items, "Symptom presence %", strcat("Control K-VHQ part 1 (n=", num2str(size(C_k1_presence, 1)), ")"));
% DNPDR_SimplePercentBar(C_k2_ratio*100, DNPDR_kvhq2_items, "Symptom presence %", strcat("Control K-VHQ part 2 (n=", num2str(size(C_k2_presence, 1)), ")"));

% Result: Visualize K-VHQ symptom presence ratios' relative difference
PC_k1_diff = (P_k1_ratio - C_k1_ratio) ./ (C_k1_ratio + 1);
PC_k2_diff = (P_k2_ratio - C_k2_ratio) ./ (C_k2_ratio + 1);
% DNPDR_SimpleValueBar(PC_k1_diff, DNPDR_kvhq1_items, "(Patient - Control) / (Control + 1)", "K-VHQ part 1 presence ratio relative difference");
% DNPDR_SimpleValueBar(PC_k2_diff, DNPDR_kvhq2_items, "(Patient - Control) / Control + 1)", "K-VHQ part 2 presence ratio relative difference");

% Result: Chi-Square Tests
P_k1_count = sum(P_k1_presence, 1);
P_k2_count = sum(P_k2_presence, 1);
C_k1_count = sum(C_k1_presence, 1);
C_k2_count = sum(C_k2_presence, 1);

k1_observed = [P_k1_count; C_k1_count];
% DNPDR_SimpleTable(k1_observed, DNPDR_kvhq1_items, ["Patient", "Control"], "K-VHQ part 1 presence count contingency table");
k1_rowTotals = sum(k1_observed, 2);
k1_colTotals = sum(k1_observed, 1);
k1_allTotals = sum(k1_colTotals);

k1_expected = k1_rowTotals * k1_colTotals / k1_allTotals;
k1_chisquare = sum((k1_observed - k1_expected).^2 ./ k1_expected, 'all');
k1_dof = (size(k1_observed, 1) - 1) * (size(k1_observed, 2) - 1);
k1_pvalue = 1 - chi2cdf(k1_chisquare, k1_dof);
fprintf(">> KVHQ patient vs control Chi-Square test p-value = %.3f\n", k1_pvalue);

k2_observed = [P_k2_count; C_k2_count];
% DNPDR_SimpleTable(k2_observed, DNPDR_kvhq2_items, ["Patient", "Control"], "K-VHQ part 2 presence count contingency table");
k2_observed = k2_observed + 1; % Consider zero values
k2_rowTotals = sum(k2_observed, 2);
k2_colTotals = sum(k2_observed, 1);
k2_allTotals = sum(k2_colTotals);

k2_expected = k2_rowTotals * k2_colTotals / k2_allTotals;
k2_chisquare = sum((k2_observed - k2_expected).^2 ./ k2_expected, 'all');
k2_dof = (size(k2_observed, 1) - 1) * (size(k2_observed, 2) - 1);
k2_pvalue = 1 - chi2cdf(k2_chisquare, k2_dof);
fprintf(">> KVHQ patient vs control Chi-Square test p-value = %.3f\n", k2_pvalue);

% Result: Mann–Whitney U test using ranksum
[k1_pValue, ~, k1_stats] = ranksum(P_k1_ratio, C_k1_ratio);
k1_zValue = k1_stats.zval; 
k1_r = abs(k1_zValue) / sqrt(length(P_k1_ratio) + length(C_k1_ratio));

fprintf('>> Patient Group K-VHQ part 1 presence ratio median: %.3f\n', median(P_k1_ratio));
fprintf('>> Control Group K-VHQ part 1 presence ratio median: %.3f\n', median(C_k1_ratio));
fprintf('>> K-VHQ part 1 Mann–Whitney U test p-value: %.4f\n', k1_pValue);
fprintf('>> K-VHQ part 1 Effect size (r): %.3f\n', k1_r);

[k2_pValue, ~, k2_stats] = ranksum(P_k2_ratio, C_k2_ratio);
k2_zValue = k2_stats.zval;
k2_r = abs(k2_zValue) / sqrt(length(P_k2_ratio) + length(C_k2_ratio));

fprintf('>> Patient Group K-VHQ part 2 presence ratio median: %.3f\n', median(P_k2_ratio));
fprintf('>> Control Group K-VHQ part 2 presence ratio median: %.3f\n', median(C_k2_ratio));
fprintf('>> K-VHQ part 2 Mann–Whitney U test p-value: %.4f\n', k2_pValue);
fprintf('>> K-VHQ part 2 Effect size (r): %.3f\n', k2_r);

% (Patient group) KVHQ part 1, 2, total vs Sex, Age, Duration (deprecated)
%DNPDR_PlotLR(DNPDRP_info(:, 2), sum(DNPDRP_k1, 2), ["Sex", "KVHQ part1"]); DNPDR_PlotLR(DNPDRP_info(:, 3), sum(DNPDRP_k1, 2), ["Age", "KVHQ part1"]); DNPDR_PlotLR(DNPDRP_kvhq_duration, sum(DNPDRP_k1, 2), ["Duration", "KVHQ part1"]);
%DNPDR_PlotLR(DNPDRP_info(:, 2), sum(DNPDRP_k2, 2), ["Sex", "KVHQ part2"]); DNPDR_PlotLR(DNPDRP_info(:, 3), sum(DNPDRP_k2, 2), ["Age", "KVHQ part2"]); DNPDR_PlotLR(DNPDRP_kvhq_duration, sum(DNPDRP_k2, 2), ["Duration", "KVHQ part2"]);
%DNPDR_PlotLR(DNPDRP_info(:, 2), sum(DNPDRP_k1, 2) + sum(DNPDRP_k2, 2), ["Sex", "KVHQ total"]); DNPDR_PlotLR(DNPDRP_info(:, 3), sum(DNPDRP_k1, 2) + sum(DNPDRP_k2, 2), ["Age", "KVHQ total"]); DNPDR_PlotLR(DNPDRP_kvhq_duration, sum(DNPDRP_k1, 2) + sum(DNPDRP_k2, 2), ["Duration", "KVHQ total"]);


% (Control group) KVHQ part 1, 2, total vs Sex, Age
%DNPDR_PlotLR(DNPDRC_info(:, 2), sum(DNPDRC_k1, 2), ["Sex", "KVHQ part1"]); DNPDR_PlotLR(DNPDRC_info(:, 3), sum(DNPDRC_k1, 2), ["Age", "KVHQ part1"]);
%DNPDR_PlotLR(DNPDRC_info(:, 2), sum(DNPDRC_k2, 2), ["Sex", "KVHQ part2"]); DNPDR_PlotLR(DNPDRC_info(:, 3), sum(DNPDRC_k2, 2), ["Age", "KVHQ part2"]);
%DNPDR_PlotLR(DNPDRC_info(:, 2), sum(DNPDRC_k1, 2) + sum(DNPDRC_k2, 2), ["Sex", "KVHQ total"]); DNPDR_PlotLR(DNPDRC_info(:, 3), sum(DNPDRC_k1, 2) + sum(DNPDRC_k2, 2), ["Age", "KVHQ total"]);


%% Get Patient/Control PDSS scores
% (Patient PDSS: 17 variables) PDSS_year, PDSS_month, PDSS_score x 15
DNPDRP_pdss = table2array(DNPDRP(:, 101:117));
DNPDRP_pdss_year = DNPDRP_pdss(:, 1) + DNPDRP_pdss(:, 2)/12;
DNPDRP_pdss_duration = DNPDRP_pdss_year - DNPDRP_onset_year;
DNPDRP_p = DNPDRP_pdss(:, 3:17);

% Console log
fprintf("> Loaded Patient PDSS scores, %d missing values\n", sum(FindNaN(DNPDRP_p)));

% Account missing values for duration
P_pdss_duration = DNPDRP_pdss_duration(~FindNaN(DNPDRP_p));

% Remove missing values
P_p = RemoveNaN(DNPDRP_p);

% (Control PDSS: 17 variables) PDSS_year, PDSS_month, PDSS_score x 15
DNPDRC_pdss = table2array(DNPDRC(:, 98:114)); % No need to consider control group's PDSS year/month
DNPDRC_p = DNPDRC_pdss(:, 3:17);

% Console log
fprintf("> Loaded Control PDSS scores, %d missing values\n", sum(FindNaN(DNPDRC_p)));

% Remove missing values
C_p = RemoveNaN(DNPDRC_p);

% PDSS item strings
DNPDR_pdss_items = ["수면의 질", "입면 어려움", "수면 유지 어려움", "팔다리 불안", "팔다리 탈면", "이상한 꿈", "환청/환시", "야간뇨", ...
"가위 눌림", "팔다리 통증", "팔다리 뭉침", "이상한 자세", "기상 시 떨림", "피곤함/졸림", "코골이 탈면"];

% Result: Visualize PDSS score distribution
% DNPDR_DistributionBar(DNPDRP_p, "PDSS score", DNPDR_pdss_items);
% DNPDR_DistributionBar(DNPDRC_p, "PDSS score", DNPDR_pdss_items);

% Display boxplot after Mann–Whitney test
% DNPDR_SimpleBox(DNPDRP_p, DNPDRC_p, DNPDR_pdss_items)

% (Patient group) PDSS total vs Sex, Age, Duration
%DNPDR_PlotLR(DNPDRP_info(:, 2), sum(DNPDRP_pdss, 2), ["Sex", "PDSS total"]); DNPDR_PlotLR(DNPDRP_info(:, 3), sum(DNPDRP_pdss, 2), ["Age", "PDSS total"]); DNPDR_PlotLR(DNPDRP_pdssDuration, sum(DNPDRP_pdss, 2), ["Duration", "PDSS total"]);

% (Control group) PDSS total vs Sex, Age
%DNPDR_PlotLR(DNPDRC_info(:, 2), sum(DNPDRC_pdss, 2), ["Sex", "PDSS total"]); DNPDR_PlotLR(DNPDRC_info(:, 3), sum(DNPDRC_pdss, 2), ["Age", "PDSS total"]);

%% Get Patient/Control Hue scores
% (Patient Hue: 4 variables) Hue_year, Hue_month, Hue_Rt, Hue_Lt
DNPDRP_hue = table2array(DNPDRP(:, 118:121));
DNPDRP_hue_year = DNPDRP_hue(:, 1) + DNPDRP_hue(:, 2)/12;
DNPDRP_hue_duration = DNPDRP_hue_year - DNPDRP_onset_year;
DNPDRP_h = DNPDRP_hue(:, 3:4);

% Console log
fprintf("> Loaded Patient Hue scores, %d missing values\n", sum(FindNaN(DNPDRP_h)));

% Account missing values for duration
P_hue_duration = DNPDRP_hue_duration(~FindNaN(DNPDRP_h));

% Remove missing values
P_h = RemoveNaN(DNPDRP_h);

% (Control Hue: 4 variables) Hue_year, Hue_month, Hue_Rt, Hue_Lt
DNPDRC_hue = table2array(DNPDRC(:, 115:118));
DNPDRC_h = DNPDRC_hue(:, 3:4);

% Console log
fprintf("> Loaded Control Hue scores, %d missing values\n", sum(FindNaN(DNPDRC_h)));

% Remove missing values
C_h = RemoveNaN(DNPDRC_h);

% (Patient group) Hue total vs Sex, Age, Duration
% DNPDR_PlotLR(DNPDRP_info(:, 2), sum(DNPDRP_hue, 2), ["Sex", "Hue total"]); 
% DNPDR_PlotLR(DNPDRP_info(:, 3), sum(DNPDRP_hue, 2), ["Age", "Hue total"]);
% DNPDR_PlotLR(DNPDRP_hueDuration, sum(DNPDRP_hue, 2), ["Duration", "Hue total"]);

% (Control group) Hue total vs Sex, Age
% DNPDR_PlotLR(DNPDRC_info(:, 2), sum(DNPDRC_hue, 2), ["Sex", "Hue total"]);
% DNPDR_PlotLR(DNPDRC_info(:, 3), sum(DNPDRC_hue, 2), ["Age", "Hue total"]);

%% Get Patient VOG scores
% (Patient VOG: 14 variables) VOG_year, VOG_month, HS_Lat_OD_Rt, HS_Lat_OD_Lt, HS_Lat_OS_Rt, HS_Lat_OS_Lt, HS_Acc_OD_Rt, HS_Acc_OD_Lt, HS_Acc_OS_Rt, HS_Acc_OS_Lt, HP_Gain_OD_Rt, HP_Gain_OD_Lt, HP_Gain_OS_Rt, HP_Gain_OS_Lt
DNPDRP_vog = table2array(DNPDRP(:, 122:135));
DNPDRP_vog_year = DNPDRP_vog(:, 1) + DNPDRP_vog(:, 2)/12;
DNPDRP_vog_duration = DNPDRP_vog_year - DNPDRP_onset_year;
DNPDRP_v = DNPDRP_vog(:, 3:14);
DNPDRP_hsl = DNPDRP_v(:, 1:4);
DNPDRP_hsa = DNPDRP_v(:, 5:8);
DNPDRP_hpg = DNPDRP_v(:, 9:12);
DNPDRP_hsl_m = mean(DNPDRP_hsl, 2);
DNPDRP_hsa_m = mean(DNPDRP_hsa, 2);
DNPDRP_hpg_m = mean(DNPDRP_hpg, 2);

% Console log
fprintf("> Loaded Patient VOG scores, %d missing values\n", sum(FindNaN(DNPDRP_v)));

% Account missing values for duration
P_vog_duration = DNPDRP_vog_duration(~FindNaN(DNPDRP_v));

% Remove missing values
P_v = RemoveNaN(DNPDRP_v);

DNPDR_vog_items = ["HS Latency (OD, Rt)", "HS Latency (OD, Lt)", "HS Latency (OS, Rt)", "HS Latency (OS, Lt)", "HS Accuracy (OD, Rt)", ...
"HS Accuracy (OD, Lt)", "HS Accuracy (OS, Rt)", "HS Accuracy (OS, Lt)", "HP Gain (OD, Rt)", "HP Gain (OD, Lt)", "HP Gain (OS, Rt)", "HP Gain (OS, Lt)"];

% DNPDR_DistributionBar(DNPDRP_v, "VOG score", DNPDR_vog_items, false);

%% Get Patient OCT scores
% (Patient OCT: 76 variables) OCT_year, OCT_month, OD_AXL, OS_AXL, OD_WRT x9, OD_RNFL x9, OD_GCL x9, OD_IPL x9, OS_WRT x9, OS_RNFL x9, OS_GCL x9, OS_IPL x9
DNPDRP_oct = table2array(DNPDRP(:, 136:211));
DNPDRP_oct_year = DNPDRP_oct(:, 1) + DNPDRP_oct(:, 2)/12;
DNPDRP_oct_duration = DNPDRP_oct_year - DNPDRP_onset_year;

DNPDRP_axl_od = DNPDRP_oct(:, 3);
DNPDRP_axl_os = DNPDRP_oct(:, 4);
DNPDRP_axl_m = mean([DNPDRP_axl_od, DNPDRP_axl_os], 2);
DNPDRP_wrt_od = mean(DNPDRP_oct(:, 5:13), 2);
DNPDRP_wrt_os = mean(DNPDRP_oct(:, 41:49), 2);
DNPDRP_wrt_m = mean([DNPDRP_wrt_od, DNPDRP_wrt_os], 2);
DNPDRP_rnfl_od = mean(DNPDRP_oct(:, 14:22), 2);
DNPDRP_rnfl_os = mean(DNPDRP_oct(:, 50:58), 2);
DNPDRP_rnfl_m = mean([DNPDRP_rnfl_od, DNPDRP_rnfl_os], 2);
DNPDRP_gcl_od = mean(DNPDRP_oct(:, 23:31), 2);
DNPDRP_gcl_os = mean(DNPDRP_oct(:, 59:67), 2);
DNPDRP_gcl_m = mean([DNPDRP_gcl_od, DNPDRP_gcl_os], 2);
DNPDRP_ipl_od = mean(DNPDRP_oct(:, 32:40), 2);
DNPDRP_ipl_os = mean(DNPDRP_oct(:, 68:76), 2);
DNPDRP_ipl_m = mean([DNPDRP_ipl_od, DNPDRP_ipl_os], 2);

% Console log
fprintf("> Loaded Patient OCT scores, %d missing values\n", sum(FindNaN(DNPDRP_wrt_od)));

% Account missing values for duration
P_oct_duration = DNPDRP_oct_duration(~FindNaN(DNPDRP_wrt_od));

% Remove missing values
P_axl_od = RemoveNaN(DNPDRP_axl_od);
P_axl_os = RemoveNaN(DNPDRP_axl_os);
P_axl_m = RemoveNaN(DNPDRP_axl_m);
P_wrt_od = RemoveNaN(DNPDRP_wrt_od);
P_wrt_os = RemoveNaN(DNPDRP_wrt_os);
P_wrt_m = RemoveNaN(DNPDRP_wrt_m);
P_rnfl_od = RemoveNaN(DNPDRP_rnfl_od);
P_rnfl_os = RemoveNaN(DNPDRP_rnfl_os);
P_rnfl_m = RemoveNaN(DNPDRP_rnfl_m);
P_gcl_od = RemoveNaN(DNPDRP_gcl_od);
P_gcl_os = RemoveNaN(DNPDRP_gcl_os);
P_gcl_m = RemoveNaN(DNPDRP_gcl_m);
P_ipl_od = RemoveNaN(DNPDRP_ipl_od);
P_ipl_os = RemoveNaN(DNPDRP_ipl_os);
P_ipl_m = RemoveNaN(DNPDRP_ipl_m);

% OCT item strings
DNPDR_eye_items = ["Axis length (OD)", "Axis length (OS)"];
DNPDR_oct_items = ["1", "2", "3", "4", "5", "6", "7", "8", "9"];

% DNPDR_DistributionBar([P_wrt_m, P_rnfl_m, P_gcl_m, P_ipl_m], "OCT layer thickness", ["WRT", "RNFL", "GCL", "IPL"], false);

% Covariables for MLR - Age (age), Disease duration (dur), Axial length mean (axl)
age = DNPDRP_info(:, 2); dur = DNPDRP_info(:, 6); axl = EagerMean(DNPDRP_axl_od, DNPDRP_axl_os);
% Multiple linear regression (MLR)
oct_wrt = EagerMean(DNPDRP_wrt_od, DNPDRP_wrt_os);
oct_rnfl = EagerMean(DNPDRP_rnfl_od, DNPDRP_rnfl_os);
oct_gcl = EagerMean(DNPDRP_gcl_od, DNPDRP_gcl_os);
oct_ipl = EagerMean(DNPDRP_ipl_od, DNPDRP_ipl_os);

wrt = DNPDR_MLR(oct_wrt, ["WRT(um)"], age, dur, axl, false);
rnfl = DNPDR_MLR(oct_rnfl, ["RNFL(um)"], age, dur, axl, false);
gcl = DNPDR_MLR(oct_gcl, ["GCL(um)"], age, dur, axl, false);
ipl = DNPDR_MLR(oct_ipl, ["IPL(um)"], age, dur, axl, false);

%% Results - Baseline characteristics
fprintf("\n=== Baseline characteristics ===\n");
% N
fprintf("Patient N = %d\n", size(DNPDRP_info, 1));
fprintf("Control N = %d\n", size(DNPDRC_info, 1));
% Age
fprintf("Patient age = %.1f ± %.1f\n", mean(DNPDRP_age), std(DNPDRP_age));
fprintf("Control age = %.1f ± %.1f\n", mean(DNPDRC_age), std(DNPDRC_age));
% Sex
fprintf("Patient sex (M/F) = %d/%d\n", sum(DNPDRP_sex==1, "all"), sum(DNPDRP_sex==2, "all"));
fprintf("Control sex (M/F) = %d/%d\n", sum(DNPDRC_sex==1, "all"), sum(DNPDRC_sex==2, "all"));
% UPDRS score
fprintf("Patient u1 = %.1f ± %.1f, u2 = %.1f ± %.1f, u3 = %.1f ± %.1f\n", mean(sum(P_u1, 2)), std(sum(P_u1, 2)), mean(sum(P_u2, 2)), std(sum(P_u2, 2)), mean(sum(P_u3, 2)), std(sum(P_u3, 2)));
fprintf("Control u1 = %.1f ± %.1f, u2 = %.1f ± %.1f, u3 = %.1f ± %.1f\n", mean(sum(C_u1, 2)), std(sum(C_u1, 2)), mean(sum(C_u2, 2)), std(sum(C_u2, 2)), mean(sum(C_u3, 2)), std(sum(C_u3, 2)));
% H-Y score
fprintf("Patient H-Y score = %.1f ± %.1f\n", mean(P_hy), std(P_hy));
fprintf("Control H-Y score = %.1f ± %.1f\n", mean(C_hy), std(C_hy));
% MMSE score
fprintf("Patient MMSE score = %.1f ± %.1f\n", mean(P_m), std(P_m));
fprintf("Control MMSE score = %.1f ± %.1f\n", mean(C_m), std(C_m));

%% Results - KVHQ score vs VOG
% DNPDR_Corr(DNPDRP_k1, DNPDR_kvhq1_items, [DNPDRP_hsl_m, DNPDRP_hsa_m, DNPDRP_hpg_m], ["HS Latency", "HS Accuracy", "HP Gain"], true)
% DNPDR_Corr(DNPDRP_k2, DNPDR_kvhq2_items, [DNPDRP_hsl_m, DNPDRP_hsa_m, DNPDRP_hpg_m], ["HS Latency", "HS Accuracy", "HP Gain"], true)

%% Results - KVHQ positivity vs VOG
% DNPDR_Cohen(DNPDRP_k1_presence, DNPDR_kvhq1_items, [DNPDRP_hsl_m, DNPDRP_hsa_m, DNPDRP_hpg_m], ["HS Latency", "HS Accuracy", "HP Gain"], true)
% DNPDR_Cohen(DNPDRP_k2_presence, DNPDR_kvhq2_items, [DNPDRP_hsl_m, DNPDRP_hsa_m, DNPDRP_hpg_m], ["HS Latency", "HS Accuracy", "HP Gain"], true)

%% Results - KVHQ score vs OCT
% DNPDR_Corr(DNPDRP_k1, DNPDR_kvhq1_items, [wrt, rnfl, gcl, ipl], ["WRT", "RNFL", "GCL", "IPL"], true)
% DNPDR_Corr(DNPDRP_k2, DNPDR_kvhq2_items, [wrt, rnfl, gcl, ipl], ["WRT", "RNFL", "GCL", "IPL"], true)

%% Results - KVHQ positivity vs OCT
% DNPDR_Cohen(DNPDRP_k1, DNPDR_kvhq1_items, [wrt, rnfl, gcl, ipl], ["WRT", "RNFL", "GCL", "IPL"], true)
% DNPDR_Cohen(DNPDRP_k2, DNPDR_kvhq2_items, [wrt, rnfl, gcl, ipl], ["WRT", "RNFL", "GCL", "IPL"], true)

%% Restuls - VOG vs OCT
% DNPDR_Corr([DNPDRP_hsl_m, DNPDRP_hsa_m, DNPDRP_hpg_m], ["HS Latency", "HS Accuracy", "HP Gain"], [wrt, rnfl, gcl, ipl], ["WRT", "RNFL", "GCL", "IPL"], true);

%% Results - u1 vs OCT

% % UPDRS Part 1 data: (N x 13)
% var1 = DNPDRP_u1;  %  N patients, 13 items

% % OCT data: (N x 4) 
% %  [WRT, RNFL, GCL, IPL]
% var2 = [DNPDRP_wrt_m, DNPDRP_rnfl_m, DNPDRP_gcl_m, DNPDRP_ipl_m];

% % Labels for UPDRS Part 1
% var1name = [
%     "Cognitive impairment"
%     "Hallucinations and psychosis"
%     "Depressed mood"
%     "Anxious mood"
%     "Apathy"
%     "Dopamine dysregulation"
%     "Sleep problems"
%     "Daytime sleepiness"
%     "Pain and others"
%     "Urinary problems"
%     "Constipation"
%     "Light headedness"
%     "Fatigue"
% ];

% % Labels for OCT data
% var2name = ["WRT","RNFL","GCL","IPL"];

% % Set plotOn = true to generate imagesc + scatter plots
% DNPDR_Corr(var1, var1name, var2, var2name, true);

%% Results - u1 vs VOG

% var1 = DNPDRP_u1;  % where rows = patients, columns = 13 UPDRS Part 1 items
% var2 = [DNPDRP_hsl_m, DNPDRP_hsa_m, DNPDRP_hpg_m];

% var1name = [ ...
%     "Cognitive impairment", ...
%     "Hallucinations and psychosis", ...
%     "Depressed mood", ...
%     "Anxious mood", ...
%     "Apathy", ...
%     "Dopamine dysregulation", ...
%     "Sleep problems", ...
%     "Daytime sleepiness", ...
%     "Pain and others", ...
%     "Urinary problems", ...
%     "Constipation", ...
%     "Light headedness", ...
%     "Fatigue" ...
% ];

% var2name = ["HS Latency", "HS Accuracy", "HP Gain"];

% % Set plotOn = true to produce imagesc + scatter plots
% DNPDR_Corr(var1, var1name, var2, var2name, true);

%% Results - u1 vs khhq part 1

% --- UPDRS Part 1 data (N x 13) ---
var1 = DNPDRP_u1;  % numeric

% --- kvhq Part 1 presence (N x 10) ---
%     logical array -> convert to double if needed
var2 = double(DNPDRP_k1_presence);  % or you can leave it as logical

% --- Labels ---
var1name = [ ...
    "Cognitive impairment"
    "Hallucinations and psychosis"
    "Depressed mood"
    "Anxious mood"
    "Apathy"
    "Dopamine dysregulation"
    "Sleep problems"
    "Daytime sleepiness"
    "Pain and others"
    "Urinary problems"
    "Constipation"
    "Light headedness"
    "Fatigue"
];

var2name = [
    "빛 번짐"
    "글자 안 보임"
    "직선이 곡선으로"
    "야간 시력 문제"
    "헤드라이트 반짝"
    "빠른 움직임 어려움"
    "깊이 인식 어려움"
    "채도 구분 어려움"
    "배경 위 글자"
    "조명 변화 글자"
];

% 2) Call your correlation function
%    (set plotOn = true if you want the imagesc and scatter plots)

DNPDR_Corr(var1, var1name, var2, var2name, true);