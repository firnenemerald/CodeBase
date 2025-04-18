%% Main Script for DNPDR Analysis

% SPDX-FileCopyrightText: © 2024 Chanhee Jeong <chanheejeong@snu.ac.kr>
% SPDX-License-Identifier: GPL-3.0-or-later

clear; close all;

%% Import and preprocess data
[DNPDRP, DNPDRC] = DNPDR_GetData(); % 78 DNPDRPs, 26 DNPDRCs

% Data cleaning
DNPDRP([2, 71], :) = []; % Exclude patients with outliers
DNPDRC([1, 14], :) = []; % Exclude controls with extensive missing data

% Console log
fprintf("=== Data loaded (DNPDRP: %d, DNPDRC: %d) ===\n", size(DNPDRP, 1), size(DNPDRC, 1));

%% Get patient/control demographics
% Patient information: Serial, Sex, Age, YOB, Onset_year, Dx_year, Dx_month
DNPDRP_info = table2array(DNPDRP(:, 2:7)); % Leave Serial out
DNPDRP_sex = DNPDRP_info(:, 1);
DNPDRP_age = DNPDRP_info(:, 2);
DNPDRP_onset_year = DNPDRP_info(:, 4);
DNPDRP_diagnosis = DNPDRP_info(:, 5) + DNPDRP_info(:, 6)/12;
DNPDRP_duration = DNPDRP_diagnosis - DNPDRP_onset_year;

% Control information: Serial, Sex, Age, YOB
DNPDRC_info = table2array(DNPDRC(:, 2:4)); % Leave Serial out
DNPDRC_sex = DNPDRC_info(:, 1);
DNPDRC_age = DNPDRC_info(:, 2);

%% Get patient/control UPDRS Scores
% Patient UPDRS: (68 variables) UPDRS_year, UPDRS_month, UPDRS_part1 x 13, UPDRS_part2 x 13, UPDRS_part3 x 33, UPDRS_part4 x 6, HY score
DNPDRP_updrs = table2array(DNPDRP(:, 8:75));
DNPDRP_updrs_year = DNPDRP_updrs(:, 1) + DNPDRP_updrs(:, 2)/12;
DNPDRP_updrs_duration = DNPDRP_updrs_year - DNPDRP_onset_year;
DNPDRP_u1 = DNPDRP_updrs(:, 3:15);
DNPDRP_u2 = DNPDRP_updrs(:, 16:28);
DNPDRP_u3 = DNPDRP_updrs(:, 29:61);
DNPDRP_u4 = DNPDRP_updrs(:, 62:67);
DNPDRP_hy = DNPDRP_updrs(:, 68);

% Account missing values for duration
P_updrs_duration = DNPDRP_updrs_duration(~FindNaN(DNPDRP_u1));
P_hy_duration = DNPDRP_updrs_duration(~FindNaN(DNPDRP_hy));

% Remove missing values
P_u1 = RemoveNaN(DNPDRP_u1);
P_u2 = RemoveNaN(DNPDRP_u2);
P_u3 = RemoveNaN(DNPDRP_u3);
P_u4 = RemoveNaN(DNPDRP_u4);
P_hy = RemoveNaN(DNPDRP_hy);

% Console log
fprintf("> Loaded Patient UPDRS part 1 scores, %d patients (%d missing values)\n", size(P_u1, 1), sum(FindNaN(DNPDRP_u1)));
fprintf("> Loaded Patient UPDRS part 2 scores, %d patients (%d missing values)\n", size(P_u2, 1), sum(FindNaN(DNPDRP_u2)));
fprintf("> Loaded Patient UPDRS part 3 scores, %d patients (%d missing values)\n", size(P_u3, 1), sum(FindNaN(DNPDRP_u3)));
fprintf("> Loaded Patient UPDRS part 4 scores, %d patients (%d missing values)\n", size(P_u4, 1), sum(FindNaN(DNPDRP_u4)));
fprintf("> Loaded Patient H-Y scores, %d patients (%d missing values)\n", size(P_hy, 1), sum(FindNaN(DNPDRP_hy)));

% Control UPDRS: (68 variables) UPDRS_year, UPDRS_month, UPDRS_part1 x 13, UPDRS_part2 x 13, UPDRS_part3 x 33, UPDRS_part4 x 6, HY score
DNPDRC_updrs = table2array(DNPDRC(:, 5:72)); % No need to consider control group's UPDRS year/month
DNPDRC_u1 = DNPDRC_updrs(:, 3:15);
DNPDRC_u2 = DNPDRC_updrs(:, 16:28);
DNPDRC_u3 = DNPDRC_updrs(:, 29:61);
DNPDRC_u4 = DNPDRC_updrs(:, 62:67);
DNPDRC_hy = DNPDRC_updrs(:, 68);

% Remove missing values
C_u1 = RemoveNaN(DNPDRC_u1);
C_u2 = RemoveNaN(DNPDRC_u2);
C_u3 = RemoveNaN(DNPDRC_u3);
C_u4 = RemoveNaN(DNPDRC_u4);
C_hy = RemoveNaN(DNPDRC_hy);

% Console log
fprintf("> Loaded Control UPDRS part 1 scores, %d controls (%d missing values)\n", size(C_u1, 1), sum(FindNaN(DNPDRC_u1)));
fprintf("> Loaded Control UPDRS part 2 scores, %d controls (%d missing values)\n", size(C_u2, 1), sum(FindNaN(DNPDRC_u2)));
fprintf("> Loaded Control UPDRS part 3 scores, %d controls (%d missing values)\n", size(C_u3, 1), sum(FindNaN(DNPDRC_u3)));
fprintf("> Loaded Control UPDRS part 4 scores, %d controls (%d missing values)\n", size(C_u4, 1), sum(FindNaN(DNPDRC_u4)));
fprintf("> Loaded Control H-Y scores, %d controls (%d missing values)\n", size(C_hy, 1), sum(FindNaN(DNPDRC_hy)));

% UPDRS item names
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

% % Visualize Patient group UPDRS score distribution
% DNPDR_DistributionBar(DNPDRP_u1, "UPDRS part 1", DNPDR_u1_items);  
% DNPDR_DistributionBar(DNPDRP_u2, "UPDRS part 2", DNPDR_u2_items);
% DNPDR_DistributionBar(DNPDRP_u3, "UPDRS part 3", DNPDR_u3_items);
% DNPDR_DistributionBar(DNPDRP_hy, "H-Y score", DNPDR_hy_items);

% % Visualize Control group UPDRS score distribution
% DNPDR_DistributionBar(DNPDRC_u1, "UPDRS part 1", DNPDR_u1_items);
% DNPDR_DistributionBar(DNPDRC_u2, "UPDRS part 2", DNPDR_u2_items);
% DNPDR_DistributionBar(DNPDRC_u3, "UPDRS part 3", DNPDR_u3_items);
% DNPDR_DistributionBar(DNPDRC_hy, "H-Y score", DNPDR_hy_items);

% % Visualize Patient vs Control UPDRS score boxplot with Mann–Whitney test
% DNPDR_SimpleBox(DNPDRP_u1, DNPDRC_u1, DNPDR_u1_items)
% DNPDR_SimpleBox(DNPDRP_u2, DNPDRC_u2, DNPDR_u2_items)
% DNPDR_SimpleBox(DNPDRP_hy, DNPDRC_hy, DNPDR_hy_items)

% Modified UPDRS part 3
DNPDRP_u3m = [DNPDRP_u3(:, [1, 2]), sum(DNPDRP_u3(:, 3:7), 2), sum(DNPDRP_u3(:, 8:9), 2), sum(DNPDRP_u3(:, 10:11), 2), sum(DNPDRP_u3(:, 12:13), 2), ...
sum(DNPDRP_u3(:, 14:15), 2), sum(DNPDRP_u3(:, 16:17), 2), DNPDRP_u3(:, 18:22), sum(DNPDRP_u3(:, 23:24), 2), sum(DNPDRP_u3(:, 25:26), 2), ...
sum(DNPDRP_u3(:, 27:31), 2), DNPDRP_u3(:, 32:33)];
DNPDRC_u3m = [DNPDRC_u3(:, [1, 2]), sum(DNPDRC_u3(:, 3:7), 2), sum(DNPDRC_u3(:, 8:9), 2), sum(DNPDRC_u3(:, 10:11), 2), sum(DNPDRC_u3(:, 12:13), 2), ...
sum(DNPDRC_u3(:, 14:15), 2), sum(DNPDRC_u3(:, 16:17), 2), DNPDRC_u3(:, 18:22), sum(DNPDRC_u3(:, 23:24), 2), sum(DNPDRC_u3(:, 25:26), 2), ...
sum(DNPDRC_u3(:, 27:31), 2), DNPDRC_u3(:, 32:33)];

% Modified UPDRS part 3 item names
DNPDR_u3m_items = ["Speech", "Facial expression", "Rigidity", "Finger tapping", "Hand movements", "Pronation/Supination", ...
"Toe tapping", "Leg agility", "Arising from chair", "Gait", "Freezing", "Postural stability", "Posture", "Bradykinesia", ...
"Postural tremor", "Kinetic tremor", "Rest tremor", "Rest tremor constancy"];

% % Visualize Patient group UPDRS score distribution
% DNPDR_DistributionBar(DNPDRP_u3m, "UPDRS part 3", DNPDR_u3m_items);
% % Visualize Patient vs Control UPDRS score boxplot with Mann–Whitney test
% DNPDR_SimpleBox(DNPDRP_u3m, DNPDRC_u3m, DNPDR_u3m_items)

% % Visualize Linear regression of Patient UPDRS p1, p2, p3, total (covariates: sex, age, duration)
% DNPDR_PlotLR(DNPDRP_info(:, 2), sum(DNPDRP_u1, 2), ["Sex", "UPDRS part1"]); DNPDR_PlotLR(DNPDRP_info(:, 3), sum(DNPDRP_u1, 2), ["Age", "UPDRS part1"]); DNPDR_PlotLR(DNPDRP_updrs_duration, sum(DNPDRP_u1, 2), ["Duration", "UPDRS part1"]);
% DNPDR_PlotLR(DNPDRP_info(:, 2), sum(DNPDRP_u2, 2), ["Sex", "UPDRS part2"]); DNPDR_PlotLR(DNPDRP_info(:, 3), sum(DNPDRP_u2, 2), ["Age", "UPDRS part2"]); DNPDR_PlotLR(DNPDRP_updrs_duration, sum(DNPDRP_u2, 2), ["Duration", "UPDRS part2"]);
% DNPDR_PlotLR(DNPDRP_info(:, 2), sum(DNPDRP_u3, 2), ["Sex", "UPDRS part3"]); DNPDR_PlotLR(DNPDRP_info(:, 3), sum(DNPDRP_u3, 2), ["Age", "UPDRS part3"]); DNPDR_PlotLR(DNPDRP_updrs_duration, sum(DNPDRP_u3, 2), ["Duration", "UPDRS part3"]);
% DNPDR_PlotLR(DNPDRP_info(:, 2), sum(DNPDRP_u1, 2) + sum(DNPDRP_u2, 2) + sum(DNPDRP_u3, 2), ["Sex", "UPDRS total"]);
% DNPDR_PlotLR(DNPDRP_info(:, 3), sum(DNPDRP_u1, 2) + sum(DNPDRP_u2, 2) + sum(DNPDRP_u3, 2), ["Age", "UPDRS total"]);
% DNPDR_PlotLR(DNPDRP_updrs_duration, sum(DNPDRP_u1, 2) + sum(DNPDRP_u2, 2) + sum(DNPDRP_u3, 2), ["Duration", "UPDRS total"]);

% % Visualize Linear regression of Control UPDRS p1, p2, p3, total (covariates: sex, age, duration)
% DNPDR_PlotLR(DNPDRC_info(:, 2), sum(DNPDRC_u1, 2), ["Sex", "UPDRS part1"]); DNPDR_PlotLR(DNPDRC_info(:, 3), sum(DNPDRC_u1, 2), ["Age", "UPDRS part1"]);
% DNPDR_PlotLR(DNPDRC_info(:, 2), sum(DNPDRC_u2, 2), ["Sex", "UPDRS part2"]); DNPDR_PlotLR(DNPDRC_info(:, 3), sum(DNPDRC_u2, 2), ["Age", "UPDRS part2"]);
% DNPDR_PlotLR(DNPDRC_info(:, 2), sum(DNPDRC_u3, 2), ["Sex", "UPDRS part3"]); DNPDR_PlotLR(DNPDRC_info(:, 3), sum(DNPDRC_u3, 2), ["Age", "UPDRS part3"]);
% DNPDR_PlotLR(DNPDRC_info(:, 2), sum(DNPDRC_u1, 2) + sum(DNPDRC_u2, 2) + sum(DNPDRC_u3, 2), ["Sex", "UPDRS total"]);
% DNPDR_PlotLR(DNPDRC_info(:, 3), sum(DNPDRC_u1, 2) + sum(DNPDRC_u2, 2) + sum(DNPDRC_u3, 2), ["Age", "UPDRS total"]);

%% Get Patient/Control MMSE Scores
% Patient MMSE: (3 variables) MMSE_year, MMSE_month, MMSE_score
DNPDRP_mmse = table2array(DNPDRP(:, 76:78));
DNPDRP_mmse_year = DNPDRP_mmse(:, 1) + DNPDRP_mmse(:, 2)/12;
DNPDRP_mmse_duration = DNPDRP_mmse_year - DNPDRP_onset_year;
DNPDRP_m = DNPDRP_mmse(:, 3);

% Account missing values for duration
P_mmse_duration = DNPDRP_mmse_duration(~FindNaN(DNPDRP_m));

% Remove missing values
P_m = RemoveNaN(DNPDRP_m);

% Console log
fprintf("> Loaded Patient MMSE scores, %d patients (%d missing values)\n", size(P_m, 1), sum(FindNaN(DNPDRP_m)));

% Control MMSE: (3 variables) MMSE_year, MMSE_month, MMSE_score
DNPDRC_mmse = table2array(DNPDRC(:, 73:75)); % No need to consider control group's MMSE year/month
DNPDRC_m = DNPDRC_mmse(:, 3);

% Remove missing values
C_m = RemoveNaN(DNPDRC_m);

% Console log
fprintf("> Loaded Control MMSE scores, %d controls (%d missing values)\n", size(C_m, 1), sum(FindNaN(DNPDRC_m)));

% MMSE item strings
DNPDR_mmse_items = "MMSE score";

% % Visualize MMSE score distribution
% DNPDR_DistributionBar(DNPDRP_m, "MMSE score", DNPDR_mmse_items);
% DNPDR_DistributionBar(DNPDRC_m, "MMSE score", DNPDR_mmse_items);

% Subgroup MMSE < 24 as MCI
P_m_mci = P_m < 24; C_m_mci = C_m < 24;
P_m_mciratio = sum(P_m_mci, 1)/size(P_m_mci, 1); C_m_mciratio = sum(C_m_mci, 1)/size(C_m_mci, 1);

% % Visualize MCI ratio as percentage
% DNPDR_SimplePercentBar(P_m_mciratio*100, DNPDR_mmse_items, "MMSE < 24 (MCI) percentage", strcat("Patient MMSE (n=", num2str(size(P_m_mci, 1)), ")"));
% DNPDR_SimplePercentBar(C_m_mciratio*100, DNPDR_mmse_items, "MMSE < 24 (MCI) percentage", strcat("Control MMSE (n=", num2str(size(C_m_mci, 1)), ")"));

% % Display Patient vs Control MMSE score boxplot with Mann–Whitney test
% DNPDR_SimpleBox(DNPDRP_m, DNPDRC_m, DNPDR_mmse_items)

% % Visualize Linear regression of Patient MMSE (covariates: sex, age, duration)
% DNPDR_PlotLR(DNPDRP_info(:, 2), DNPDRP_m, ["Sex", "MMSE"]); DNPDR_PlotLR(DNPDRP_info(:, 3), DNPDRP_m, ["Age", "MMSE"]); DNPDR_PlotLR(DNPDRP_mmse_duration, DNPDRP_m, ["Duration", "MMSE"]);

% % Visualize Linear regression of Control MMSE (covariates: sex, age)
% DNPDR_PlotLR(DNPDRC_info(:, 2), DNPDRC_mmse, ["Sex", "MMSE"]); DNPDR_PlotLR(DNPDRC_info(:, 3), DNPDRC_mmse, ["Age", "MMSE"]);

%% Result 1: Show de-novo PD basic characteristics


%% Get Patient/Control KVHQ Scores
% Patient KVHQ: (22 variables) KVHQ_year, KVHQ_month, KVHQ_part1 x 10, KVHQ_part2 x 10
DNPDRP_kvhq = table2array(DNPDRP(:, 79:100));
DNPDRP_kvhq_year = DNPDRP_kvhq(:, 1) + DNPDRP_kvhq(:, 2)/12;
DNPDRP_kvhq_duration = DNPDRP_kvhq_year - DNPDRP_onset_year;
DNPDRP_k1 = DNPDRP_kvhq(:, 3:12);
DNPDRP_k2 = DNPDRP_kvhq(:, 13:22);

% Account missing values for duration
P_kvhq_duration = DNPDRP_kvhq_duration(~FindNaN(DNPDRP_k1));

% Remove missing values
P_k1 = RemoveNaN(DNPDRP_k1);
P_k2 = RemoveNaN(DNPDRP_k2);

% Console log
fprintf("> Loaded Patient KVHQ scores, %d patients (%d missing values)\n", size(P_k1, 1), sum(FindNaN(DNPDRP_k1)));

% Control KVHQ: (22 variables) KVHQ_year, KVHQ_month, KVHQ_part1 x 10, KVHQ_part2 x 10
DNPDRC_kvhq = table2array(DNPDRC(:, 76:97)); % No need to consider control group's KVHQ year/month
DNPDRC_k1 = DNPDRC_kvhq(:, 3:12);
DNPDRC_k2 = DNPDRC_kvhq(:, 13:22);

% Remove missing values
C_k1 = RemoveNaN(DNPDRC_k1);
C_k2 = RemoveNaN(DNPDRC_k2);

% Console log
fprintf("> Loaded Control KVHQ scores, %d controls (%d missing values)\n", size(C_k1, 1), sum(FindNaN(DNPDRC_k1)));

% KVHQ item names
DNPDR_kvhq1_items = ["빛 번짐", "글자 안 보임", "직선이 곡선으로", "야간 시력 문제", "헤드라이트 반짝", "빠른 움직임 어려움", ...
"깊이 인식 어려움", "채도 구분 어려움", "배경 위 글자", "조명 변화 글자"];
DNPDR_kvhq2_items = ["없는 사람이 보임", "시야 가장자리", "무언가 지나감", "그림자 형태", "다른 것으로 착각", "실제로 없는 물체", ...
"실제가 아닌 소리", "실제가 아닌 촉감", "실제가 아닌 냄새", "실제가 아닌 맛"];

% KVHQ symptom presence
DNPDRP_k1_presence = DNPDRP_k1 ~= 0; DNPDRP_k2_presence = DNPDRP_k2 ~= 0;
DNPDRC_k1_presence = DNPDRC_k1 ~= 0; DNPDRC_k2_presence = DNPDRC_k2 ~= 0;
P_k1_presence = P_k1 ~= 0; P_k2_presence = P_k2 ~= 0;
C_k1_presence = C_k1 ~= 0; C_k2_presence = C_k2 ~= 0;

% KVHQ symptom presence ratio
P_k1_ratio = sum(P_k1_presence, 1)/size(P_k1_presence, 1); P_k2_ratio = sum(P_k2_presence, 1)/size(P_k2_presence, 1);
C_k1_ratio = sum(C_k1_presence, 1)/size(C_k1_presence, 1); C_k2_ratio = sum(C_k2_presence, 1)/size(C_k2_presence, 1);

% % Visualize KVHQ symptom presence percentages
% DNPDR_SimplePercentBar(P_k1_ratio*100, DNPDR_kvhq1_items, "Symptom presence %", strcat("Patient K-VHQ part 1 (n=", num2str(size(P_k1_presence, 1)), ")"));
% DNPDR_SimplePercentBar(P_k2_ratio*100, DNPDR_kvhq2_items, "Symptom presence %", strcat("Patient K-VHQ part 2 (n=", num2str(size(P_k2_presence, 1)), ")"));
% DNPDR_SimplePercentBar(C_k1_ratio*100, DNPDR_kvhq1_items, "Symptom presence %", strcat("Control K-VHQ part 1 (n=", num2str(size(C_k1_presence, 1)), ")"));
% DNPDR_SimplePercentBar(C_k2_ratio*100, DNPDR_kvhq2_items, "Symptom presence %", strcat("Control K-VHQ part 2 (n=", num2str(size(C_k2_presence, 1)), ")"));

% % Visualize K-VHQ symptom presence ratios relative difference
% PC_k1_diff = (P_k1_ratio - C_k1_ratio) ./ (C_k1_ratio + 1);
% PC_k2_diff = (P_k2_ratio - C_k2_ratio) ./ (C_k2_ratio + 1);
% DNPDR_SimpleValueBar(PC_k1_diff, DNPDR_kvhq1_items, "(Patient - Control) / (Control + 1)", "K-VHQ part 1 presence ratio relative difference");
% DNPDR_SimpleValueBar(PC_k2_diff, DNPDR_kvhq2_items, "(Patient - Control) / Control + 1)", "K-VHQ part 2 presence ratio relative difference");


%% Get Patient/Control PDSS scores
% Patient PDSS: (17 variables) PDSS_year, PDSS_month, PDSS_score x 15
DNPDRP_pdss = table2array(DNPDRP(:, 101:117));
DNPDRP_pdss_year = DNPDRP_pdss(:, 1) + DNPDRP_pdss(:, 2)/12;
DNPDRP_pdss_duration = DNPDRP_pdss_year - DNPDRP_onset_year;
DNPDRP_p = DNPDRP_pdss(:, 3:17);

% Account missing values for duration
P_pdss_duration = DNPDRP_pdss_duration(~FindNaN(DNPDRP_p));

% Remove missing values
P_p = RemoveNaN(DNPDRP_p);

% Console log
fprintf("> Loaded Patient PDSS scores, %d patients (%d missing values)\n", size(P_p, 1), sum(FindNaN(DNPDRP_p)));

% Control PDSS: (17 variables) PDSS_year, PDSS_month, PDSS_score x 15
DNPDRC_pdss = table2array(DNPDRC(:, 98:114)); % No need to consider control group's PDSS year/month
DNPDRC_p = DNPDRC_pdss(:, 3:17);

% Remove missing values
C_p = RemoveNaN(DNPDRC_p);

% Console log
fprintf("> Loaded Control PDSS scores, %d controls (%d missing values)\n", size(C_p, 1), sum(FindNaN(DNPDRC_p)));

% PDSS item strings
DNPDR_pdss_items = ["수면의 질", "입면 어려움", "수면 유지 어려움", "팔다리 불안", "팔다리 탈면", "이상한 꿈", "환청/환시", "야간뇨", ...
"가위 눌림", "팔다리 통증", "팔다리 뭉침", "이상한 자세", "기상 시 떨림", "피곤함/졸림", "코골이 탈면"];

% % Visualize PDSS score distribution
% DNPDR_DistributionBar(DNPDRP_p, "PDSS score", DNPDR_pdss_items);
% DNPDR_DistributionBar(DNPDRC_p, "PDSS score", DNPDR_pdss_items);

% % Display Patient vs Control PDSS score boxplot with Mann–Whitney test
% DNPDR_SimpleBox(DNPDRP_p, DNPDRC_p, DNPDR_pdss_items)

% % Visualize Linear regression of Patient PDSS (covariates: sex, age, duration)
% DNPDR_PlotLR(DNPDRP_info(:, 2), sum(DNPDRP_pdss, 2), ["Sex", "PDSS total"]); DNPDR_PlotLR(DNPDRP_info(:, 3), sum(DNPDRP_pdss, 2), ["Age", "PDSS total"]); DNPDR_PlotLR(DNPDRP_pdssDuration, sum(DNPDRP_pdss, 2), ["Duration", "PDSS total"]);

% % Visualize Linear regression of Control PDSS (covariates: sex, age)
% DNPDR_PlotLR(DNPDRC_info(:, 2), sum(DNPDRC_pdss, 2), ["Sex", "PDSS total"]); DNPDR_PlotLR(DNPDRC_info(:, 3), sum(DNPDRC_pdss, 2), ["Age", "PDSS total"]);

%% Get Patient/Control Hue scores
% Patient Hue: (4 variables) Hue_year, Hue_month, Hue_Rt, Hue_Lt
DNPDRP_hue = table2array(DNPDRP(:, 118:121));
DNPDRP_hue_year = DNPDRP_hue(:, 1) + DNPDRP_hue(:, 2)/12;
DNPDRP_hue_duration = DNPDRP_hue_year - DNPDRP_onset_year;
DNPDRP_h = DNPDRP_hue(:, 3:4);

% Account missing values for duration
P_hue_duration = DNPDRP_hue_duration(~FindNaN(DNPDRP_h));

% Remove missing values
P_h = RemoveNaN(DNPDRP_h);

% Console log
fprintf("> Loaded Patient Hue scores, %d patients (%d missing values)\n", size(P_h, 1), sum(FindNaN(DNPDRP_h)));

% Control Hue: (4 variables) Hue_year, Hue_month, Hue_Rt, Hue_Lt
DNPDRC_hue = table2array(DNPDRC(:, 115:118));
DNPDRC_h = DNPDRC_hue(:, 3:4);

% Remove missing values
C_h = RemoveNaN(DNPDRC_h);

% Console log
fprintf("> Loaded Control Hue scores, %d controls (%d missing values)\n", size(C_h, 1), sum(FindNaN(DNPDRC_h)));

% % Visualize Linear regression of Patient Hue (covariates: sex, age, duration)
% DNPDR_PlotLR(DNPDRP_info(:, 2), sum(DNPDRP_hue, 2), ["Sex", "Hue total"]); 
% DNPDR_PlotLR(DNPDRP_info(:, 3), sum(DNPDRP_hue, 2), ["Age", "Hue total"]);
% DNPDR_PlotLR(DNPDRP_hueDuration, sum(DNPDRP_hue, 2), ["Duration", "Hue total"]);

% % Visualize Linear regression of Control Hue (covariates: sex, age)
% DNPDR_PlotLR(DNPDRC_info(:, 2), sum(DNPDRC_hue, 2), ["Sex", "Hue total"]);
% DNPDR_PlotLR(DNPDRC_info(:, 3), sum(DNPDRC_hue, 2), ["Age", "Hue total"]);

%% Get Patient VOG scores
% Patient VOG: (14 variables) VOG_year, VOG_month, HS_Lat_OD_Rt, HS_Lat_OD_Lt, HS_Lat_OS_Rt, HS_Lat_OS_Lt, HS_Acc_OD_Rt, HS_Acc_OD_Lt, HS_Acc_OS_Rt, HS_Acc_OS_Lt, HP_Gain_OD_Rt, HP_Gain_OD_Lt, HP_Gain_OS_Rt, HP_Gain_OS_Lt
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

% Account missing values for duration
P_vog_duration = DNPDRP_vog_duration(~FindNaN(DNPDRP_v));

% Remove missing values
P_v = RemoveNaN(DNPDRP_v);

% Console log
fprintf("> Loaded Patient VOG scores, %d patients (%d missing values)\n", size(P_v, 1), sum(FindNaN(DNPDRP_v)));

DNPDR_vog_items = ["HS Latency (OD, Rt)", "HS Latency (OD, Lt)", "HS Latency (OS, Rt)", "HS Latency (OS, Lt)", "HS Accuracy (OD, Rt)", ...
"HS Accuracy (OD, Lt)", "HS Accuracy (OS, Rt)", "HS Accuracy (OS, Lt)", "HP Gain (OD, Rt)", "HP Gain (OD, Lt)", "HP Gain (OS, Rt)", "HP Gain (OS, Lt)"];

% % Visualize VOG score distribution
% DNPDR_DistributionBar(DNPDRP_v, "VOG score", DNPDR_vog_items, false);

%% Get Patient OCT scores
% Patient OCT: (76 variables) OCT_year, OCT_month, OD_AXL, OS_AXL, OD_WRT x9, OD_RNFL x9, OD_GCL x9, OD_IPL x9, OS_WRT x9, OS_RNFL x9, OS_GCL x9, OS_IPL x9
DNPDRP_oct = table2array(DNPDRP(:, 136:211));
DNPDRP_oct_year = DNPDRP_oct(:, 1) + DNPDRP_oct(:, 2)/12;
DNPDRP_oct_duration = DNPDRP_oct_year - DNPDRP_onset_year;

% Axial length
DNPDRP_axl_od = DNPDRP_oct(:, 3);
DNPDRP_axl_os = DNPDRP_oct(:, 4);
DNPDRP_axl_m = mean([DNPDRP_axl_od, DNPDRP_axl_os], 2);

% WRT thickness
DNPDRP_wrt_od = mean(DNPDRP_oct(:, 5:13), 2);
DNPDRP_wrt_od_O = mean(DNPDRP_oct(:, 5:8), 2);
DNPDRP_wrt_od_I = mean(DNPDRP_oct(:, 9:12), 2);
DNPDRP_wrt_od_R = mean(DNPDRP_oct(:, 5:12), 2);
DNPDRP_wrt_od_C = mean(DNPDRP_oct(:, 13), 2);
DNPDRP_wrt_os = mean(DNPDRP_oct(:, 41:49), 2);
DNPDRP_wrt_os_O = mean(DNPDRP_oct(:, 41:44), 2);
DNPDRP_wrt_os_I = mean(DNPDRP_oct(:, 45:48), 2);
DNPDRP_wrt_os_R = mean(DNPDRP_oct(:, 41:48), 2);
DNPDRP_wrt_os_C = mean(DNPDRP_oct(:, 49), 2);
DNPDRP_wrt_m = mean([DNPDRP_wrt_od, DNPDRP_wrt_os], 2);
DNPDRP_wrt_m_O = mean([DNPDRP_wrt_od_O, DNPDRP_wrt_os_O], 2);
DNPDRP_wrt_m_I = mean([DNPDRP_wrt_od_I, DNPDRP_wrt_os_I], 2);
DNPDRP_wrt_m_R = mean([DNPDRP_wrt_od, DNPDRP_wrt_os], 2);
DNPDRP_wrt_m_C = mean([DNPDRP_wrt_od_C, DNPDRP_wrt_os_C], 2);

% RNFL thickness
DNPDRP_rnfl_od = mean(DNPDRP_oct(:, 14:22), 2);
DNPDRP_rnfl_od_O = mean(DNPDRP_oct(:, 14:17), 2);
DNPDRP_rnfl_od_I = mean(DNPDRP_oct(:, 18:21), 2);
DNPDRP_rnfl_od_R = mean(DNPDRP_oct(:, 14:21), 2);
DNPDRP_rnfl_od_C = mean(DNPDRP_oct(:, 22), 2);
DNPDRP_rnfl_os = mean(DNPDRP_oct(:, 50:58), 2);
DNPDRP_rnfl_os_O = mean(DNPDRP_oct(:, 50:53), 2);
DNPDRP_rnfl_os_I = mean(DNPDRP_oct(:, 54:57), 2);
DNPDRP_rnfl_os_R = mean(DNPDRP_oct(:, 50:57), 2);
DNPDRP_rnfl_os_C = mean(DNPDRP_oct(:, 58), 2);
DNPDRP_rnfl_m = mean([DNPDRP_rnfl_od, DNPDRP_rnfl_os], 2);
DNPDRP_rnfl_m_O = mean([DNPDRP_rnfl_od_O, DNPDRP_rnfl_os_O], 2);
DNPDRP_rnfl_m_I = mean([DNPDRP_rnfl_od_I, DNPDRP_rnfl_os_I], 2);
DNPDRP_rnfl_m_R = mean([DNPDRP_rnfl_od_R,  DNPDRP_rnfl_os_R], 2);
DNPDRP_rnfl_m_C = mean([DNPDRP_rnfl_od_C, DNPDRP_rnfl_os_C], 2);

% GCL thickness
DNPDRP_gcl_od = mean(DNPDRP_oct(:, 23:31), 2);
DNPDRP_gcl_od_O = mean(DNPDRP_oct(:, 23:26), 2);
DNPDRP_gcl_od_I = mean(DNPDRP_oct(:, 27:30), 2);
DNPDRP_gcl_od_R = mean(DNPDRP_oct(:, 23:30), 2);
DNPDRP_gcl_od_C = mean(DNPDRP_oct(:, 31), 2);
DNPDRP_gcl_os = mean(DNPDRP_oct(:, 59:67), 2);
DNPDRP_gcl_os_O = mean(DNPDRP_oct(:, 59:62), 2);
DNPDRP_gcl_os_I = mean(DNPDRP_oct(:, 63:66), 2);
DNPDRP_gcl_os_R = mean(DNPDRP_oct(:, 59:66), 2);
DNPDRP_gcl_os_C = mean(DNPDRP_oct(:, 67), 2);
DNPDRP_gcl_m = mean([DNPDRP_gcl_od, DNPDRP_gcl_os], 2);
DNPDRP_gcl_m_O = mean([DNPDRP_gcl_od_O, DNPDRP_gcl_os_O], 2);
DNPDRP_gcl_m_I = mean([DNPDRP_gcl_od_I, DNPDRP_gcl_os_I], 2);
DNPDRP_gcl_m_R = mean([DNPDRP_gcl_od_R, DNPDRP_gcl_os_R], 2);
DNPDRP_gcl_m_C = mean([DNPDRP_gcl_od_C, DNPDRP_gcl_os_C], 2);

% IPL thickness
DNPDRP_ipl_od = mean(DNPDRP_oct(:, 32:40), 2);
DNPDRP_ipl_od_O = mean(DNPDRP_oct(:, 32:35), 2);
DNPDRP_ipl_od_I = mean(DNPDRP_oct(:, 36:39), 2);
DNPDRP_ipl_od_R = mean(DNPDRP_oct(:, 32:39), 2);
DNPDRP_ipl_od_C = mean(DNPDRP_oct(:, 40), 2);
DNPDRP_ipl_os = mean(DNPDRP_oct(:, 68:76), 2);
DNPDRP_ipl_os_O = mean(DNPDRP_oct(:, 68:71), 2);
DNPDRP_ipl_os_I = mean(DNPDRP_oct(:, 72:75), 2);
DNPDRP_ipl_os_R = mean(DNPDRP_oct(:, 68:75), 2);
DNPDRP_ipl_os_C = mean(DNPDRP_oct(:, 76), 2);
DNPDRP_ipl_m = mean([DNPDRP_ipl_od, DNPDRP_ipl_os], 2);
DNPDRP_ipl_m_O = mean([DNPDRP_ipl_od_O, DNPDRP_ipl_os_O], 2);
DNPDRP_ipl_m_I = mean([DNPDRP_ipl_od_I, DNPDRP_ipl_os_I], 2);
DNPDRP_ipl_m_R = mean([DNPDRP_ipl_od_R, DNPDRP_ipl_os_R], 2);
DNPDRP_ipl_m_C = mean([DNPDRP_ipl_od_C, DNPDRP_ipl_os_C], 2);

% Account missing values for duration
P_oct_duration = DNPDRP_oct_duration(~FindNaN(DNPDRP_wrt_od));

% Remove missing values
P_axl_od = RemoveNaN(DNPDRP_axl_od);
P_axl_os = RemoveNaN(DNPDRP_axl_os);
P_axl_m = RemoveNaN(DNPDRP_axl_m);

P_wrt_od = RemoveNaN(DNPDRP_wrt_od);
P_wrt_os = RemoveNaN(DNPDRP_wrt_os);
P_wrt_m = RemoveNaN(DNPDRP_wrt_m);
P_wrt_m_O = RemoveNaN(DNPDRP_wrt_m_O);
P_wrt_m_I = RemoveNaN(DNPDRP_wrt_m_I);
P_wrt_m_R = RemoveNaN(DNPDRP_wrt_m_R);
P_wrt_m_C = RemoveNaN(DNPDRP_wrt_m_C);

P_rnfl_od = RemoveNaN(DNPDRP_rnfl_od);
P_rnfl_os = RemoveNaN(DNPDRP_rnfl_os);
P_rnfl_m = RemoveNaN(DNPDRP_rnfl_m);
P_rnfl_m_O = RemoveNaN(DNPDRP_rnfl_m_O);
P_rnfl_m_I = RemoveNaN(DNPDRP_rnfl_m_I);
P_rnfl_m_R = RemoveNaN(DNPDRP_rnfl_m_R);
P_rnfl_m_C = RemoveNaN(DNPDRP_rnfl_m_C);

P_gcl_od = RemoveNaN(DNPDRP_gcl_od);
P_gcl_os = RemoveNaN(DNPDRP_gcl_os);
P_gcl_m = RemoveNaN(DNPDRP_gcl_m);
P_gcl_m_O = RemoveNaN(DNPDRP_gcl_m_O);
P_gcl_m_I = RemoveNaN(DNPDRP_gcl_m_I);
P_gcl_m_R = RemoveNaN(DNPDRP_gcl_m_R);
P_gcl_m_C = RemoveNaN(DNPDRP_gcl_m_C);

P_ipl_od = RemoveNaN(DNPDRP_ipl_od);
P_ipl_os = RemoveNaN(DNPDRP_ipl_os);
P_ipl_m = RemoveNaN(DNPDRP_ipl_m);
P_ipl_m_O = RemoveNaN(DNPDRP_ipl_m_O);
P_ipl_m_I = RemoveNaN(DNPDRP_ipl_m_I);
P_ipl_m_R = RemoveNaN(DNPDRP_ipl_m_R);
P_ipl_m_C = RemoveNaN(DNPDRP_ipl_m_C);

% Console log
fprintf("> Loaded Patient OCT scores, %d patients (%d missing values)\n", size(P_wrt_m, 1), sum(FindNaN(DNPDRP_wrt_od)));

% OCT item strings
DNPDR_eye_items = ["Axis length (OD)", "Axis length (OS)"];
DNPDR_oct_items = ["1", "2", "3", "4", "5", "6", "7", "8", "9"];

% % Visualize OCT thickness distribution
% DNPDR_DistributionBar([P_wrt_m, P_rnfl_m, P_gcl_m, P_ipl_m], "OCT layer thickness", ["WRT", "RNFL", "GCL", "IPL"], false);

% Covariables for MLR - Age (age), Disease duration (dur), Axial length mean (axl)
age = DNPDRP_info(:, 2); dur = DNPDRP_info(:, 6); axl = EagerMean(DNPDRP_axl_od, DNPDRP_axl_os);

% Multiple linear regression (MLR)
oct_wrt = EagerMean(DNPDRP_wrt_od, DNPDRP_wrt_os);
oct_rnfl = EagerMean(DNPDRP_rnfl_od, DNPDRP_rnfl_os);
oct_gcl = EagerMean(DNPDRP_gcl_od, DNPDRP_gcl_os);
oct_ipl = EagerMean(DNPDRP_ipl_od, DNPDRP_ipl_os);

oct_wrt_O = EagerMean(DNPDRP_wrt_od_O, DNPDRP_wrt_os_O);
oct_rnfl_O = EagerMean(DNPDRP_rnfl_od_O, DNPDRP_rnfl_os_O);
oct_gcl_O = EagerMean(DNPDRP_gcl_od_O, DNPDRP_gcl_os_O);
oct_ipl_O = EagerMean(DNPDRP_ipl_od_O, DNPDRP_ipl_os_O);

oct_wrt_I = EagerMean(DNPDRP_wrt_od_I, DNPDRP_wrt_os_I);
oct_rnfl_I = EagerMean(DNPDRP_rnfl_od_I, DNPDRP_rnfl_os_I);
oct_gcl_I = EagerMean(DNPDRP_gcl_od_I, DNPDRP_gcl_os_I);
oct_ipl_I = EagerMean(DNPDRP_ipl_od_I, DNPDRP_ipl_os_I);

oct_wrt_R = EagerMean(DNPDRP_wrt_od_R, DNPDRP_wrt_os_R);
oct_rnfl_R = EagerMean(DNPDRP_rnfl_od_R, DNPDRP_rnfl_os_R);
oct_gcl_R = EagerMean(DNPDRP_gcl_od_R, DNPDRP_gcl_os_R);
oct_ipl_R = EagerMean(DNPDRP_ipl_od_R, DNPDRP_ipl_os_R);

oct_wrt_C = EagerMean(DNPDRP_wrt_od_C, DNPDRP_wrt_os_C);
oct_rnfl_C = EagerMean(DNPDRP_rnfl_od_C, DNPDRP_rnfl_os_C);
oct_gcl_C = EagerMean(DNPDRP_gcl_od_C, DNPDRP_gcl_os_C);
oct_ipl_C = EagerMean(DNPDRP_ipl_od_C, DNPDRP_ipl_os_C);

wrt = DNPDR_MLR(oct_wrt, ["WRT(um)"], age, dur, axl, false);
rnfl = DNPDR_MLR(oct_rnfl, ["RNFL(um)"], age, dur, axl, false);
gcl = DNPDR_MLR(oct_gcl, ["GCL(um)"], age, dur, axl, false);
ipl = DNPDR_MLR(oct_ipl, ["IPL(um)"], age, dur, axl, false);

wrt_O = DNPDR_MLR(oct_wrt_O, ["WRT(um)"], age, dur, axl, false);
rnfl_O = DNPDR_MLR(oct_rnfl_O, ["RNFL(um)"], age, dur, axl, false);
gcl_O = DNPDR_MLR(oct_gcl_O, ["GCL(um)"], age, dur, axl, false);
ipl_O = DNPDR_MLR(oct_ipl_O, ["IPL(um)"], age, dur, axl, false);

wrt_I = DNPDR_MLR(oct_wrt_I, ["WRT(um)"], age, dur, axl, false);
rnfl_I = DNPDR_MLR(oct_rnfl_I, ["RNFL(um)"], age, dur, axl, false);
gcl_I = DNPDR_MLR(oct_gcl_I, ["GCL(um)"], age, dur, axl, false);
ipl_I = DNPDR_MLR(oct_ipl_I, ["IPL(um)"], age, dur, axl, false);

wrt_R = DNPDR_MLR(oct_wrt_R, ["WRT(um)"], age, dur, axl, false);
rnfl_R = DNPDR_MLR(oct_rnfl_R, ["RNFL(um)"], age, dur, axl, false);
gcl_R = DNPDR_MLR(oct_gcl_R, ["GCL(um)"], age, dur, axl, false);
ipl_R = DNPDR_MLR(oct_ipl_R, ["IPL(um)"], age, dur, axl, false);

wrt_C = DNPDR_MLR(oct_wrt_C, ["WRT(um)"], age, dur, axl, false);
rnfl_C = DNPDR_MLR(oct_rnfl_C, ["RNFL(um)"], age, dur, axl, false);
gcl_C = DNPDR_MLR(oct_gcl_C, ["GCL(um)"], age, dur, axl, false);
ipl_C = DNPDR_MLR(oct_ipl_C, ["IPL(um)"], age, dur, axl, false);

%% Results 1 - Baseline characteristics
fprintf("\n=== Baseline characteristics ===\n");
% N
fprintf("Patient N = %d\n", size(DNPDRP_info, 1));
fprintf("Control N = %d\n", size(DNPDRC_info, 1));
% Age
fprintf("Patient age = %.1f ± %.1f\n", mean(DNPDRP_age), std(DNPDRP_age));
fprintf("Control age = %.1f ± %.1f\n", mean(DNPDRC_age), std(DNPDRC_age));
[~, p] = ttest2(DNPDRP_age, DNPDRC_age);
fprintf("Age two sample t-test p = %.4f\n", p);
% Sex
fprintf("Patient sex (M/F) = %d/%d\n", sum(DNPDRP_sex==1, "all"), sum(DNPDRP_sex==2, "all"));
fprintf("Control sex (M/F) = %d/%d\n", sum(DNPDRC_sex==1, "all"), sum(DNPDRC_sex==2, "all"));
% UPDRS score
fprintf("Patient updrs = %.1f ± %.1f, u1 = %.1f ± %.1f, u2 = %.1f ± %.1f, u3 = %.1f ± %.1f\n", mean(sum(P_u1, 2)+sum(P_u2, 2)+sum(P_u3, 2)), std(sum(P_u1, 2)+sum(P_u2, 2)+sum(P_u3, 2)), mean(sum(P_u1, 2)), std(sum(P_u1, 2)), mean(sum(P_u2, 2)), std(sum(P_u2, 2)), mean(sum(P_u3, 2)), std(sum(P_u3, 2)));
fprintf("Control updrs = %.1f ± %.1f, u1 = %.1f ± %.1f, u2 = %.1f ± %.1f, u3 = %.1f ± %.1f\n", mean(sum(C_u1, 2)+sum(C_u2, 2)+sum(C_u3, 2)), std(sum(C_u1, 2)+sum(C_u2, 2)+sum(C_u3, 2)), mean(sum(C_u1, 2)), std(sum(C_u1, 2)), mean(sum(C_u2, 2)), std(sum(C_u2, 2)), mean(sum(C_u3, 2)), std(sum(C_u3, 2)));
[~, p] = ttest2(sum(P_u1, 2)+sum(P_u2, 2)+sum(P_u3, 2), sum(C_u1, 2)+sum(C_u2, 2)+sum(C_u3, 2));
fprintf("UPDRS total two sample t-test p = %.4f\n", p);
[~, p] = ttest2(sum(P_u1, 2), sum(C_u1, 2));
fprintf("UPDRS part 1 two sample t-test p = %.4f\n", p);
[~, p] = ttest2(sum(P_u2, 2), sum(C_u2, 2));
fprintf("UPDRS part 2 two sample t-test p = %.4f\n", p);
[~, p] = ttest2(sum(P_u3, 2), sum(C_u3, 2));
fprintf("UPDRS part 3 two sample t-test p = %.4f\n", p);
% H-Y score
fprintf("Patient H-Y score = %.1f ± %.1f\n", mean(P_hy), std(P_hy));
fprintf("Control H-Y score = %.1f ± %.1f\n", mean(C_hy), std(C_hy));
[~, p] = ttest2(P_hy, C_hy);
fprintf("H-Y score two sample t-test p = %.4f\n", p);
% MMSE score
fprintf("Patient MMSE score = %.1f ± %.1f\n", mean(P_m), std(P_m));
fprintf("Control MMSE score = %.1f ± %.1f\n", mean(C_m), std(C_m));
[~, p] = ttest2(P_m, C_m);
fprintf("MMSE score two sample t-test p = %.4f\n", p);
% DNPDRP duration
fprintf("DNPDRP duration = %.1f ± %.1f\n", mean(DNPDRP_duration), std(DNPDRP_duration));

% Analyzed sample pairs
UPDRS_nan = FindNaN(DNPDRP_p);
OCT_nan = FindNaN(DNPDRP_wrt_od);
VOG_nan = FindNaN(DNPDRP_v);
UPDRS_OCT_nan = UPDRS_nan | OCT_nan;
UPDRS_VOG_nan = UPDRS_nan | VOG_nan;
OCT_VOG_nan = OCT_nan | VOG_nan;
ALL_nan = UPDRS_nan | OCT_nan | VOG_nan;

fprintf("Patients with both UPDRS and OCT data: %d patients (%d missing values)\n", sum(~UPDRS_OCT_nan), sum(UPDRS_OCT_nan));
fprintf("Patients with both UPDRS and VOG data: %d patients (%d missing values)\n", sum(~UPDRS_VOG_nan), sum(UPDRS_VOG_nan));
fprintf("Patients with both OCT and VOG data: %d patients (%d missing values)\n", sum(~OCT_VOG_nan), sum(OCT_VOG_nan));
fprintf("Patients with all UPDRS, OCT, and VOG data: %d patients (%d missing values)\n", sum(~ALL_nan), sum(ALL_nan));

%% Results 2 - VOG vs OCT
% DNPDR_Corr([DNPDRP_hsl_m, DNPDRP_hsa_m, DNPDRP_hpg_m], ["HS Latency", "HS Accuracy", "HP Gain"], [wrt, rnfl, gcl, ipl], ["WRT", "RNFL", "GCL", "IPL"], true);
% DNPDR_Corr([DNPDRP_hsl_m, DNPDRP_hsa_m, DNPDRP_hpg_m], ["HS Latency", "HS Accuracy", "HP Gain"], [wrt_O, rnfl_O, gcl_O, ipl_O], ["WRT", "RNFL", "GCL", "IPL"], true);
% DNPDR_Corr([DNPDRP_hsl_m, DNPDRP_hsa_m, DNPDRP_hpg_m], ["HS Latency", "HS Accuracy", "HP Gain"], [wrt_I, rnfl_I, gcl_I, ipl_I], ["WRT", "RNFL", "GCL", "IPL"], true);
% DNPDR_Corr([DNPDRP_hsl_m, DNPDRP_hsa_m, DNPDRP_hpg_m], ["HS Latency", "HS Accuracy", "HP Gain"], [wrt_R, rnfl_R, gcl_R, ipl_R], ["WRT", "RNFL", "GCL", "IPL"], true);
% DNPDR_Corr([DNPDRP_hsl_m, DNPDRP_hsa_m, DNPDRP_hpg_m], ["HS Latency", "HS Accuracy", "HP Gain"], [wrt_C, rnfl_C, gcl_C, ipl_C], ["WRT", "RNFL", "GCL", "IPL"], true);

%% Results 3 - UPDRS vs VOG
% % UPDRS part 1
% var1 = DNPDRP_u1;
% var1name = DNPDR_u1_items;

% % Exclude dopamine dysregulation
% var1(:, 6) = [];
% var1name(:, 6) = [];

% % UPDRS part 2
% var1 = DNPDRP_u2;
% var1name = DNPDR_u2_items;

% var2 = [DNPDRP_hsl_m, DNPDRP_hsa_m, DNPDRP_hpg_m];
% var2name = ["HS Latency", "HS Accuracy", "HP Gain"];

% % Set plotOn = true to produce imagesc + scatter plots
% DNPDR_Corr(var1, var1name, var2, var2name, true);

%% Results 4 - UPDRS vs OCT
% % UPDRS part 1
% var1 = DNPDRP_u1;
% var1name = DNPDR_u1_items;

% % Exclude dopamine dysregulation
% var1(:, 6) = [];
% var1name(:, 6) = [];

% % % UPDRS part 2
% % var1 = DNPDRP_u2;
% % var1name = DNPDR_u2_items;

% % OCT data [WRT, RNFL, GCL, IPL]
% % var2 = [DNPDRP_wrt_m, DNPDRP_rnfl_m, DNPDRP_gcl_m, DNPDRP_ipl_m];
% % var2 = [DNPDRP_wrt_m_O, DNPDRP_rnfl_m_O, DNPDRP_gcl_m_O, DNPDRP_ipl_m_O];
% var2 = [DNPDRP_wrt_m_I, DNPDRP_rnfl_m_I, DNPDRP_gcl_m_I, DNPDRP_ipl_m_I];
% % var2 = [DNPDRP_wrt_m_R, DNPDRP_rnfl_m_R, DNPDRP_gcl_m_R, DNPDRP_ipl_m_R];
% % var2 = [DNPDRP_wrt_m_C, DNPDRP_rnfl_m_C, DNPDRP_gcl_m_C, DNPDRP_ipl_m_C];

% % Labels for OCT data
% % var2name = ["WRT","RNFL","GCL","IPL"];
% % var2name = ["WRT_O","RNFL_O","GCL_O","IPL_O"];
% var2name = ["WRT_I","RNFL_I","GCL_I","IPL_I"];
% % var2name = ["WRT_R","RNFL_R","GCL_R","IPL_R"];
% % var2name = ["WRT_C","RNFL_C","GCL_C","IPL_C"];

% % Set plotOn = true to generate imagesc + scatter plots
% DNPDR_Corr(var1, var1name, var2, var2name, true);

%% Results - KVHQ score vs VOG (deprecated)
% DNPDR_Corr(DNPDRP_k1, DNPDR_kvhq1_items, [DNPDRP_hsl_m, DNPDRP_hsa_m, DNPDRP_hpg_m], ["HS Latency", "HS Accuracy", "HP Gain"], true)
% DNPDR_Corr(DNPDRP_k2, DNPDR_kvhq2_items, [DNPDRP_hsl_m, DNPDRP_hsa_m, DNPDRP_hpg_m], ["HS Latency", "HS Accuracy", "HP Gain"], true)

%% Results - KVHQ positivity vs VOG (Cohen's d) (deprecated)
% DNPDR_Cohen(DNPDRP_k1_presence, DNPDR_kvhq1_items, [DNPDRP_hsl_m, DNPDRP_hsa_m, DNPDRP_hpg_m], ["HS Latency", "HS Accuracy", "HP Gain"], true)
% DNPDR_Cohen(DNPDRP_k2_presence, DNPDR_kvhq2_items, [DNPDRP_hsl_m, DNPDRP_hsa_m, DNPDRP_hpg_m], ["HS Latency", "HS Accuracy", "HP Gain"], true)

%% Results - KVHQ score vs OCT (deprecated)
% DNPDR_Corr(DNPDRP_k1, DNPDR_kvhq1_items, [wrt, rnfl, gcl, ipl], ["WRT", "RNFL", "GCL", "IPL"], true)
% DNPDR_Corr(DNPDRP_k2, DNPDR_kvhq2_items, [wrt, rnfl, gcl, ipl], ["WRT", "RNFL", "GCL", "IPL"], true)

%% Results - KVHQ positivity vs OCT (Cohen's d) (deprecated)
% DNPDR_Cohen(DNPDRP_k1, DNPDR_kvhq1_items, [wrt, rnfl, gcl, ipl], ["WRT", "RNFL", "GCL", "IPL"], true)
% DNPDR_Cohen(DNPDRP_k2, DNPDR_kvhq2_items, [wrt, rnfl, gcl, ipl], ["WRT", "RNFL", "GCL", "IPL"], true)

%% Results - KVHQ positivity vs OCT (deprecated)
% DNPDR_LogicalBox(DNPDRP_k1, DNPDR_kvhq1_items, [wrt, rnfl, gcl, ipl], ["WRT", "RNFL", "GCL", "IPL"], true)
% DNPDR_LogicalBox2(DNPDRP_k1, DNPDR_kvhq1_items, [wrt, rnfl, gcl, ipl], ["WRT", "RNFL", "GCL", "IPL"], true)
% DNPDR_LogicalBox2(DNPDRP_k2, DNPDR_kvhq2_items, [wrt, rnfl, gcl, ipl], ["WRT", "RNFL", "GCL", "IPL"], true)