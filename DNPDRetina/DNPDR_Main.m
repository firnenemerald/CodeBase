%% DNPDR_Main.m (ver 1.1.241014)
% Main script for DNPDR analysis

% Copyright (C) 2024 Chanhee Jeong

% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.

% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.

% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <https://www.gnu.org/licenses/>.

clear; close all;

%% Import and preprocess data
[DNPDRP, DNPDRC] = DNPDR_GetData();

% Exclude subjects with extensive missing data
DNPDRC([1, 14], :) = [];

%% Patient info
% (subtotal 7 variables) Serial, Sex, Age, YOB, Onset_year, Dx_year, Dx_month
DNPDRP_info = table2array(DNPDRP(:, 2:7)); % Leave Serial out
fprintf("=== Patient Group (n=%d) ===\n", size(DNPDRP_info, 1));
P_Onset_year = DNPDRP_info(:, 4);
P_Dx_year = DNPDRP_info(:, 5) + DNPDRP_info(:, 6)/12;
P_Dx_duration = P_Dx_year - P_Onset_year;
P_sex = DNPDRP_info(:, 1); P_age = DNPDRP_info(:, 2);

%% UPDRS
% (subtotal 68 variables) UPDRS_year, UPDRS_month, UPDRS_part1 x 13, UPDRS_part2 x 13, UPDRS_part3 x 33, UPDRS_part4 x 6, HY
DNPDRP_updrs = table2array(DNPDRP(:, 8:75));
DNPDRP_u1 = DNPDRP_updrs(:, 3:15);
fprintf("Loaded UPDRS part 1 scores, %d missing values\n", sum(FindNaN(DNPDRP_u1)));
DNPDRP_u2 = DNPDRP_updrs(:, 16:28);
fprintf("Loaded UPDRS part 2 scores, %d missing values\n", sum(FindNaN(DNPDRP_u2)));
DNPDRP_u3 = DNPDRP_updrs(:, 29:61);
fprintf("Loaded UPDRS part 3 scores, %d missing values\n", sum(FindNaN(DNPDRP_u3)));
P_UPDRS_year = DNPDRP_updrs(:, 1) + DNPDRP_updrs(:, 2)/12;
P_UPDRS_duration = P_UPDRS_year - P_Onset_year;

DNPDRP_u1 = RemoveNaN(DNPDRP_u1);
DNPDRP_u2 = RemoveNaN(DNPDRP_u2);
DNPDRP_u3 = RemoveNaN(DNPDRP_u3);

DNPDRP_hy = DNPDRP_updrs(:, 68);
fprintf("Loaded H-Y scores, %d missing values\n", sum(FindNaN(DNPDRP_hy)));

P_HY_duration = P_UPDRS_duration(~FindNaN(DNPDRP_hy));
DNPDRP_hy = RemoveNaN(DNPDRP_hy);

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

%% MMSE
% (subtotal 3 variables) MMSE_year, MMSE_month, MMSE_score
DNPDRP_mmse = table2array(DNPDRP(:, 76:78));
fprintf("Loaded MMSE scores, %d missing values\n", sum(FindNaN(DNPDRP_mmse)));
P_MMSE_year = DNPDRP_mmse(:, 1) + DNPDRP_mmse(:, 2)/12;
P_MMSE_duration = P_MMSE_year - P_Onset_year;
P_MMSE_duration = P_MMSE_duration(~FindNaN(DNPDRP_mmse));

DNPDRP_mmse = RemoveNaN(DNPDRP_mmse);

DNPDR_mmse_items = "MMSE score";

%% KVHQ
% (subtotal 22 variables) KVHQ_year, KVHQ_month, KVHQ_part1 x 10, KVHQ_part2 x 10
DNPDRP_kvhq = table2array(DNPDRP(:, 79:100));
fprintf("Loaded KVHQ scores, %d missing values\n", sum(FindNaN(DNPDRP_kvhq)));
P_KVHQ_year = DNPDRP_kvhq(:, 1) + DNPDRP_kvhq(:, 2)/12;
P_KVHQ_duration = P_KVHQ_year - P_Onset_year;

DNPDRP_kvhq1 = DNPDRP_kvhq(:, 3:12); DNPDRP_kvhq2 = DNPDRP_kvhq(:, 13:22);

DNPDR_kvhq1_items = ["빛 번짐", "글자 안 보임", "직선이 곡선으로", "야간 시력 문제", "헤드라이트 반짝", "빠른 움직임 어려움", ...
"깊이 인식 어려움", "채도 구분 어려움", "배경 위 글자", "조명 변화 글자"];
DNPDR_kvhq2_items = ["없는 사람이 보임", "시야 가장자리", "무언가 지나감", "그림자 형태", "다른 것으로 착각", "실제로 없는 물체", ...
"실제가 아닌 소리", "실제가 아닌 촉감", "실제가 아닌 냄새", "실제가 아닌 맛"];

%% PDSS
% (subtotal 17 variables) PDSS_year, PDSS_month, PDSS_score x 15
DNPDRP_pdss = table2array(DNPDRP(:, 101:117));
fprintf("Loaded PDSS scores, %d missing values\n", sum(FindNaN(DNPDRP_pdss)));
P_PDSS_year = DNPDRP_pdss(:, 1) + DNPDRP_pdss(:, 2)/12;
P_PDSS_duration = P_PDSS_year - P_Onset_year;
P_PDSS_duration = P_PDSS_duration(~FindNaN(DNPDRP_pdss));

DNPDRP_pdss = RemoveNaN(DNPDRP_pdss);

DNPDR_pdss_items = ["수면의 질", "입면 어려움", "수면 유지 어려움", "팔다리 불안", "팔다리 탈면", "이상한 꿈", "환청/환시", "야간뇨", ...
"가위 눌림", "팔다리 통증", "팔다리 뭉침", "이상한 자세", "기상 시 떨림", "피곤함/졸림", "코골이 탈면"];

%% Hue
% (subtotal 4 variables) Hue_year, Hue_month, Hue_Rt, Hue_Lt
DNPDRP_hue = table2array(DNPDRP(:, 118:121));
fprintf("Loaded Hue scores, %d missing values\n", sum(FindNaN(DNPDRP_hue)));
P_Hue_year = DNPDRP_hue(:, 1) + DNPDRP_hue(:, 2)/12;
P_Hue_duration = P_Hue_year - P_Onset_year;
P_Hue_duration = P_Hue_duration(~FindNaN(DNPDRP_hue));

DNPDRP_hue = RemoveNaN(DNPDRP_hue);

%% VOG
% (subtotal 14 variables) VOG_year, VOG_month, HS_Lat_OD_Rt, HS_Lat_OD_Lt, HS_Lat_OS_Rt, HS_Lat_OS_Lt, HS_Acc_OD_Rt, HS_Acc_OD_Lt, HS_Acc_OS_Rt, HS_Acc_OS_Lt, HP_Gain_OD_Rt, HP_Gain_OD_Lt, HP_Gain_OS_Rt, HP_Gain_OS_Lt
DNPDRP_vog = table2array(DNPDRP(:, 122:135));
fprintf("Loaded VOG scores, %d missing values\n", sum(FindNaN(DNPDRP_vog)));
P_VOG_year = DNPDRP_vog(:, 1) + DNPDRP_vog(:, 2)/12;
P_VOG_duration = P_VOG_year - P_Onset_year;
P_VOG_duration = P_VOG_duration(~FindNaN(DNPDRP_vog));

DNPDRP_hsl = DNPDRP_vog(:, 3:6); DNPDRP_hsa = DNPDRP_vog(:, 7:10); DNPDRP_hpg = DNPDRP_vog(:, 11:14);

DNPDR_vog_items = ["HS Latency (OD, Rt)", "HS Latency (OD, Lt)", "HS Latency (OS, Rt)", "HS Latency (OS, Lt)", "HS Accuracy (OD, Rt)", ...
"HS Accuracy (OD, Lt)", "HS Accuracy (OS, Rt)", "HS Accuracy (OS, Lt)", "HP Gain (OD, Rt)", "HP Gain (OD, Lt)", "HP Gain (OS, Rt)", "HP Gain (OS, Lt)"];

%% OCT
% (subtotal 76 variables) OCT_year, OCT_month, OD_AXL, OS_AXL, OD_WRT x9, OD_RNFL x9, OD_GCL x9, OD_IPL x9, OS_WRT x9, OS_RNFL x9, OS_GCL x9, OS_IPL x9
DNPDRP_oct = table2array(DNPDRP(:, 136:211));
fprintf("Loaded OCT scores, %d missing values\n", sum(FindNaN(DNPDRP_oct)));
P_OCT_year = DNPDRP_oct(:, 1) + DNPDRP_oct(:, 2)/12;
P_OCT_duration = P_OCT_year - P_Onset_year;

DNPDRP_axl_od = DNPDRP_oct(:, 3); DNPDRP_axl_os = DNPDRP_oct(:, 4);
DNPDRP_wrt_od = mean(DNPDRP_oct(:, 5:13), 2); 
DNPDRP_rnfl_od = mean(DNPDRP_oct(:, 14:22), 2); 
DNPDRP_gcl_od = mean(DNPDRP_oct(:, 23:31), 2); 
DNPDRP_ipl_od = mean(DNPDRP_oct(:, 32:40), 2); 
DNPDRP_wrt_os = mean(DNPDRP_oct(:, 41:49), 2); 
DNPDRP_rnfl_os = mean(DNPDRP_oct(:, 50:58), 2); 
DNPDRP_gcl_os = mean(DNPDRP_oct(:, 59:67), 2); 
DNPDRP_ipl_os = mean(DNPDRP_oct(:, 68:76), 2);

DNPDR_eye_items = ["Axis length (OD)", "Axis length (OS)"];
DNPDR_oct_items = ["1", "2", "3", "4", "5", "6", "7", "8", "9"];

%% Control info
% (subtotal 4 variables) Serial, Sex, Age, YOB
DNPDRC_info = table2array(DNPDRC(:, 2:4)); % Leave Serial out
fprintf("\n=== Control Group (n=%d) ===\n", size(DNPDRC_info, 1));
C_sex = DNPDRC_info(:, 1); C_age = DNPDRC_info(:, 2);

%% UPDRS
% (subtotal 68 variables) UPDRS_year, UPDRS_month, UPDRS_part1 x 13, UPDRS_part2 x 13, UPDRS_part3 x 33, UPDRS_part4 x 6, HY
DNPDRC_updrs = table2array(DNPDRC(:, 5:72));
DNPDRC_u1 = DNPDRC_updrs(:, 3:15);
fprintf("Loaded UPDRS part 1 scores, %d missing values\n", sum(FindNaN(DNPDRC_u1)));
DNPDRC_u2 = DNPDRC_updrs(:, 16:28);
fprintf("Loaded UPDRS part 2 scores, %d missing values\n", sum(FindNaN(DNPDRC_u2)));
DNPDRC_u3 = DNPDRC_updrs(:, 29:61);
fprintf("Loaded UPDRS part 3 scores, %d missing values\n", sum(FindNaN(DNPDRC_u3)));

DNPDRC_u1 = RemoveNaN(DNPDRC_u1);
DNPDRC_u2 = RemoveNaN(DNPDRC_u2);
DNPDRC_u3 = RemoveNaN(DNPDRC_u3);

DNPDRC_hy = DNPDRC_updrs(:, 68);
fprintf("Loaded H-Y scores, %d missing values\n", sum(FindNaN(DNPDRC_hy)));

DNPDRC_hy = RemoveNaN(DNPDRC_hy);

%% MMSE
% (subtotal 3 variables) MMSE_year, MMSE_month, MMSE_score
DNPDRC_mmse = table2array(DNPDRC(:, 73:75));
fprintf("Loaded MMSE scores, %d missing values\n", sum(FindNaN(DNPDRC_mmse)));

DNPDRC_mmse = RemoveNaN(DNPDRC_mmse);

%% KVHQ
% (subtotal 22 variables) KVHQ_year, KVHQ_month, KVHQ_part1 x 10, KVHQ_part2 x 10
DNPDRC_kvhq = table2array(DNPDRC(:, 76:97));
fprintf("Loaded KVHQ scores, %d missing values\n", sum(FindNaN(DNPDRC_kvhq)));

DNPDRC_kvhq = RemoveNaN(DNPDRC_kvhq);
DNPDRC_kvhq1 = DNPDRC_kvhq(:, 3:12); DNPDRC_kvhq2 = DNPDRC_kvhq(:, 13:22);

%% PDSS
% (subtotal 17 variables) PDSS_year, PDSS_month, PDSS_score x 15
DNPDRC_pdss = table2array(DNPDRC(:, 98:114));
fprintf("Loaded PDSS scores, %d missing values\n", sum(FindNaN(DNPDRC_pdss)));

%% Hue
% (subtotal 4 variables) Hue_year, Hue_month, Hue_Rt, Hue_Lt
DNPDRC_hue = table2array(DNPDRC(:, 115:118));
fprintf("Loaded Hue scores, %d missing values\n", sum(FindNaN(DNPDRC_hue)));

%% Baseline characteristics
fprintf("\n== Baseline characteristics ==\n");
% N
fprintf("Patient N = %d\n", size(DNPDRP_info, 1));
fprintf("Control N = %d\n", size(DNPDRC_info, 1));
% Age
fprintf("Patient age = %.1f ± %.1f\n", mean(P_age), std(P_age));
fprintf("Control age = %.1f ± %.1f\n", mean(C_age), std(C_age));
% Sex
fprintf("Patient sex (M/F) = %d/%d\n", sum(P_sex==1, "all"), sum(P_sex==2, "all"));
fprintf("Control sex (M/F) = %d/%d\n", sum(C_sex==1, "all"), sum(C_sex==2, "all"));
% UPDRS
fprintf("Patient u1 = %.1f ± %.1f, u2 = %.1f ± %.1f, u3 = %.1f ± %.1f\n", mean(sum(DNPDRP_u1, 2)), std(sum(DNPDRP_u1, 2)), mean(sum(DNPDRP_u2, 2)), std(sum(DNPDRP_u2, 2)), mean(sum(DNPDRP_u3, 2)), std(sum(DNPDRP_u3, 2)));
fprintf("Control u1 = %.1f ± %.1f, u2 = %.1f ± %.1f, u3 = %.1f ± %.1f\n", mean(sum(DNPDRC_u1, 2)), std(sum(DNPDRC_u1, 2)), mean(sum(DNPDRC_u2, 2)), std(sum(DNPDRC_u2, 2)), mean(sum(DNPDRC_u3, 2)), std(sum(DNPDRC_u3, 2)));
% H-Y
fprintf("Patient H-Y score = %.1f ± %.1f\n", mean(DNPDRP_hy), std(DNPDRP_hy));
fprintf("Control H-Y score = %.1f ± %.1f\n", mean(DNPDRC_hy), std(DNPDRC_hy));
% MMSE
fprintf("Patient MMSE score = %.1f ± %.1f\n", mean(DNPDRP_mmse(:, 3)), std(DNPDRP_mmse(:, 3)));
fprintf("Control MMSE score = %.1f ± %.1f\n", mean(DNPDRC_mmse(:, 3)), std(DNPDRC_mmse(:, 3)));

%% Results - KVHQ
% K-VHQ symptom presence percentage simple bar graph
% P_kvhq1_ratio = sum(DNPDRP_kvhq1 ~= 0, 1)/size(DNPDRP_kvhq1, 1);
% P_kvhq2_ratio = sum(DNPDRP_kvhq2 ~= 0, 1)/size(DNPDRP_kvhq2, 1);
% C_kvhq1_ratio = sum(DNPDRC_kvhq1 ~= 0, 1)/size(DNPDRC_kvhq1, 1);
% C_kvhq2_ratio = sum(DNPDRC_kvhq2 ~= 0, 1)/size(DNPDRC_kvhq2, 1);
% DNPDR_SimplePercentBar(P_kvhq1_ratio*100, DNPDR_kvhq1_items, "Symptom presence %", strcat("Patient K-VHQ part 1 (n=", num2str(size(DNPDRP_kvhq1, 1)), ")"));
% DNPDR_SimplePercentBar(P_kvhq2_ratio*100, DNPDR_kvhq2_items, "Symptom presence %", strcat("Patient K-VHQ part 2 (n=", num2str(size(DNPDRP_kvhq2, 1)), ")"));
% DNPDR_SimplePercentBar(C_kvhq1_ratio*100, DNPDR_kvhq1_items, "Symptom presence %", strcat("Control K-VHQ part 1 (n=", num2str(size(DNPDRC_kvhq1, 1)), ")"));
% DNPDR_SimplePercentBar(C_kvhq2_ratio*100, DNPDR_kvhq2_items, "Symptom presence %", strcat("Control K-VHQ part 2 (n=", num2str(size(DNPDRC_kvhq2, 1)), ")"));
% % K-VHQ symptom presence percentage difference ratio bar graph
% PC_kvhq1_diff = (P_kvhq1_ratio - C_kvhq1_ratio)./(C_kvhq1_ratio + 1);
% PC_kvhq2_diff = (P_kvhq2_ratio - C_kvhq2_ratio)./(C_kvhq2_ratio + 1);
% DNPDR_SimpleValueBar(PC_kvhq1_diff, DNPDR_kvhq1_items, "(Patient - Control) / Control value", "K-VHQ part 1 presence ratio difference");
% DNPDR_SimpleValueBar(PC_kvhq2_diff, DNPDR_kvhq2_items, "(Patient - Control) / Control value", "K-VHQ part 2 presence ratio difference");

% Covariables - Age (age), Disease duration (dur), Axial length mean (axl)
age = DNPDRP_info(:, 2); dur = DNPDRP_info(:, 6); axl = EagerMean(DNPDRP_axl_od, DNPDRP_axl_os);

%% Results - VOG
vog_hsl = mean(DNPDRP_hsl, 2);
vog_hsa = mean(DNPDRP_hsa, 2);
vog_hpg = mean(DNPDRP_hpg, 2);

%% Results - KVHQ
kvhq1 = DNPDRP_kvhq1; kvhq2 = DNPDRP_kvhq2;

%% Results - OCT
% Multiple linear regression (MLR)
oct_wrt = EagerMean(DNPDRP_wrt_od, DNPDRP_wrt_os);
oct_rnfl = EagerMean(DNPDRP_rnfl_od, DNPDRP_rnfl_os);
oct_gcl = EagerMean(DNPDRP_gcl_od, DNPDRP_gcl_os);
oct_ipl = EagerMean(DNPDRP_ipl_od, DNPDRP_ipl_os);

wrt = DNPDR_MLR(oct_wrt, ["WRT(um)"], age, dur, axl, false);
rnfl = DNPDR_MLR(oct_rnfl, ["RNFL(um)"], age, dur, axl, false);
gcl = DNPDR_MLR(oct_gcl, ["GCL(um)"], age, dur, axl, false);
ipl = DNPDR_MLR(oct_ipl, ["IPL(um)"], age, dur, axl, false);

%% Results - KVHQ score vs VOG
% DNPDR_Corr(kvhq1, DNPDR_kvhq1_items, [vog_hsl, vog_hsa, vog_hpg], ["HS Latency", "HS Accuracy", "HP Gain"], true)

%% Results - KVHQ score vs OCT
% DNPDR_Corr(kvhq1, DNPDR_kvhq1_items, [wrt, rnfl, gcl, ipl], ["WRT", "RNFL", "GCL", "IPL"], true)
% DNPDR_Corr(kvhq2, DNPDR_kvhq2_items, [wrt, rnfl, gcl, ipl], ["WRT", "RNFL", "GCL", "IPL"], true)

%% Results - KVHQ positivity vs OCT
% DNPDR_Cohen(kvhq1, DNPDR_kvhq1_items, [wrt, rnfl, gcl, ipl], ["WRT", "RNFL", "GCL", "IPL"], true)
% DNPDR_Cohen(kvhq2, DNPDR_kvhq2_items, [wrt, rnfl, gcl, ipl], ["WRT", "RNFL", "GCL", "IPL"], true)

% (Patient group) Plot bar chart for UPDRS part 1, 2, 3, H-Y score, MMSE score, KVHQ part 1, 2, PDSS score
%DNPDR_PlotBar(DNPDRP_u1, "UPDRS part 1", DNPDR_u1_items);  
%DNPDR_PlotBar(DNPDRP_u2, "UPDRS part 2", DNPDR_u2_items);
%DNPDR_PlotBar(DNPDRP_u3, "UPDRS part 3", DNPDR_u3_items);
%DNPDR_PlotBar(DNPDRP_hy, "H-Y score", DNPDR_hy_items);
%DNPDR_PlotBar(DNPDRP_mmse, "MMSE score", DNPDR_mmse_items);
%DNPDR_PlotBar(DNPDRP_kvhq1, "KVHQ part 1", DNPDR_kvhq1_items);
%DNPDR_PlotBar(DNPDRP_kvhq2, "KVHQ part 2", DNPDR_kvhq2_items);
%DNPDR_PlotBar(DNPDRP_pdss, "PDSS score", DNPDR_pdss_items);
%DNPDR_PlotBar(DNPDRP_vog, "VOG score", DNPDR_vog_items, false);
%DNPDR_PlotBar([DNPDRP_axl_od, DNPDRP_axl_os], "Eye axial length", DNPDR_eye_items, false);
%DNPDR_PlotBar(DNPDRP_wrt_od, "OCT, WRT layer, OD", DNPDR_oct_items, false);
%DNPDR_PlotBar(DNPDRP_wrt_os, "OCT, WRT layer, OS", DNPDR_oct_items, false);
%DNPDR_PlotBar(DNPDRP_rnfl_od, "OCT, RNFL layer, OD", DNPDR_oct_items, false);
%DNPDR_PlotBar(DNPDRP_rnfl_os, "OCT, RNFL layer, OS", DNPDR_oct_items, false);
%DNPDR_PlotBar(DNPDRP_gcl_od, "OCT, GCL layer, OD", DNPDR_oct_items, false);
%DNPDR_PlotBar(DNPDRP_gcl_os, "OCT, GCL layer, OS", DNPDR_oct_items, false);
%DNPDR_PlotBar(DNPDRP_ipl_od, "OCT, IPL layer, OD", DNPDR_oct_items, false);
%DNPDR_PlotBar(DNPDRP_ipl_os, "OCT, IPL layer, OS", DNPDR_oct_items, false);

% (Control group) Plot bar chart for UPDRS part 1, 2, 3, MMSE score, KVHQ part 1, 2, PDSS score
%DNPDR_PlotBar(DNPDRC_u1, "UPDRS part 1", DNPDR_u1_items);
%DNPDR_PlotBar(DNPDRC_u2, "UPDRS part 2", DNPDR_u2_items);
%DNPDR_PlotBar(DNPDRC_u3, "UPDRS part 3", DNPDR_u3_items);
%DNPDR_PlotBar(DNPDRC_hy, "H-Y score", DNPDR_hy_items);
%DNPDR_PlotBar(DNPDRC_mmse, "MMSE score", DNPDR_mmse_items);
%DNPDR_PlotBar(DNPDRC_kvhq1, "KVHQ part 1", DNPDR_kvhq1_items);
%DNPDR_PlotBar(DNPDRC_kvhq2, "KVHQ part 2", DNPDR_kvhq2_items);
%DNPDR_PlotBar(DNPDRC_pdss, "PDSS score", DNPDR_pdss_items);

%% Basic linear regression analysis

% (Patient group) UPDRS part 1, 2, 3, total vs Sex, Age, Duration
%DNPDR_PlotLR(DNPDRP_info(:, 2), sum(DNPDRP_u1, 2), ["Sex", "UPDRS part1"]); DNPDR_PlotLR(DNPDRP_info(:, 3), sum(DNPDRP_u1, 2), ["Age", "UPDRS part1"]); DNPDR_PlotLR(DNPDRP_updrsDuration, sum(DNPDRP_u1, 2), ["Duration", "UPDRS part1"]);
%DNPDR_PlotLR(DNPDRP_info(:, 2), sum(DNPDRP_u2, 2), ["Sex", "UPDRS part2"]); DNPDR_PlotLR(DNPDRP_info(:, 3), sum(DNPDRP_u2, 2), ["Age", "UPDRS part2"]); DNPDR_PlotLR(DNPDRP_updrsDuration, sum(DNPDRP_u2, 2), ["Duration", "UPDRS part2"]);
%DNPDR_PlotLR(DNPDRP_info(:, 2), sum(DNPDRP_u3, 2), ["Sex", "UPDRS part3"]); DNPDR_PlotLR(DNPDRP_info(:, 3), sum(DNPDRP_u3, 2), ["Age", "UPDRS part3"]); DNPDR_PlotLR(DNPDRP_updrsDuration, sum(DNPDRP_u3, 2), ["Duration", "UPDRS part3"]);
%DNPDR_PlotLR(DNPDRP_info(:, 2), sum(DNPDRP_u1, 2) + sum(DNPDRP_u2, 2) + sum(DNPDRP_u3, 2), ["Sex", "UPDRS total"]); DNPDR_PlotLR(DNPDRP_info(:, 3), sum(DNPDRP_u1, 2) + sum(DNPDRP_u2, 2) + sum(DNPDRP_u3, 2), ["Age", "UPDRS total"]); DNPDR_PlotLR(DNPDRP_updrsDuration, sum(DNPDRP_u1, 2) + sum(DNPDRP_u2, 2) + sum(DNPDRP_u3, 2), ["Duration", "UPDRS total"]);

% (Patient group) MMSE vs Sex, Age, Duration
%DNPDR_PlotLR(DNPDRP_info(:, 2), DNPDRP_mmse, ["Sex", "MMSE"]); DNPDR_PlotLR(DNPDRP_info(:, 3), DNPDRP_mmse, ["Age", "MMSE"]); DNPDR_PlotLR(DNPDRP_mmseDuration, DNPDRP_mmse, ["Duration", "MMSE"]);

% (Patient group) KVHQ part 1, 2, total vs Sex, Age, Duration
%DNPDR_PlotLR(DNPDRP_info(:, 2), sum(DNPDRP_kvhq1, 2), ["Sex", "KVHQ part1"]); DNPDR_PlotLR(DNPDRP_info(:, 3), sum(DNPDRP_kvhq1, 2), ["Age", "KVHQ part1"]); DNPDR_PlotLR(DNPDRP_kvhqDuration, sum(DNPDRP_kvhq1, 2), ["Duration", "KVHQ part1"]);
%DNPDR_PlotLR(DNPDRP_info(:, 2), sum(DNPDRP_kvhq2, 2), ["Sex", "KVHQ part2"]); DNPDR_PlotLR(DNPDRP_info(:, 3), sum(DNPDRP_kvhq2, 2), ["Age", "KVHQ part2"]); DNPDR_PlotLR(DNPDRP_kvhqDuration, sum(DNPDRP_kvhq2, 2), ["Duration", "KVHQ part2"]);
%DNPDR_PlotLR(DNPDRP_info(:, 2), sum(DNPDRP_kvhq1, 2) + sum(DNPDRP_kvhq2, 2), ["Sex", "KVHQ total"]); DNPDR_PlotLR(DNPDRP_info(:, 3), sum(DNPDRP_kvhq1, 2) + sum(DNPDRP_kvhq2, 2), ["Age", "KVHQ total"]); DNPDR_PlotLR(DNPDRP_kvhqDuration, sum(DNPDRP_kvhq1, 2) + sum(DNPDRP_kvhq2, 2), ["Duration", "KVHQ total"]);

% (Patient group) PDSS total vs Sex, Age, Duration
%DNPDR_PlotLR(DNPDRP_info(:, 2), sum(DNPDRP_pdss, 2), ["Sex", "PDSS total"]); DNPDR_PlotLR(DNPDRP_info(:, 3), sum(DNPDRP_pdss, 2), ["Age", "PDSS total"]); DNPDR_PlotLR(DNPDRP_pdssDuration, sum(DNPDRP_pdss, 2), ["Duration", "PDSS total"]);

% (Patient group) Hue total vs Sex, Age, Duration
%DNPDR_PlotLR(DNPDRP_info(:, 2), sum(DNPDRP_hue, 2), ["Sex", "Hue total"]); DNPDR_PlotLR(DNPDRP_info(:, 3), sum(DNPDRP_hue, 2), ["Age", "Hue total"]); DNPDR_PlotLR(DNPDRP_hueDuration, sum(DNPDRP_hue, 2), ["Duration", "Hue total"]);

% (Control group) UPDRS part 1, 2, 3, total vs Sex, Age
%DNPDR_PlotLR(DNPDRC_info(:, 2), sum(DNPDRC_u1, 2), ["Sex", "UPDRS part1"]); DNPDR_PlotLR(DNPDRC_info(:, 3), sum(DNPDRC_u1, 2), ["Age", "UPDRS part1"]);
%DNPDR_PlotLR(DNPDRC_info(:, 2), sum(DNPDRC_u2, 2), ["Sex", "UPDRS part2"]); DNPDR_PlotLR(DNPDRC_info(:, 3), sum(DNPDRC_u2, 2), ["Age", "UPDRS part2"]);
%DNPDR_PlotLR(DNPDRC_info(:, 2), sum(DNPDRC_u3, 2), ["Sex", "UPDRS part3"]); DNPDR_PlotLR(DNPDRC_info(:, 3), sum(DNPDRC_u3, 2), ["Age", "UPDRS part3"]);
%DNPDR_PlotLR(DNPDRC_info(:, 2), sum(DNPDRC_u1, 2) + sum(DNPDRC_u2, 2) + sum(DNPDRC_u3, 2), ["Sex", "UPDRS total"]); DNPDR_PlotLR(DNPDRC_info(:, 3), sum(DNPDRC_u1, 2) + sum(DNPDRC_u2, 2) + sum(DNPDRC_u3, 2), ["Age", "UPDRS total"]);

% (Control group) MMSE vs Sex, Age
%DNPDR_PlotLR(DNPDRC_info(:, 2), DNPDRC_mmse, ["Sex", "MMSE"]); DNPDR_PlotLR(DNPDRC_info(:, 3), DNPDRC_mmse, ["Age", "MMSE"]);

% (Control group) KVHQ part 1, 2, total vs Sex, Age
%DNPDR_PlotLR(DNPDRC_info(:, 2), sum(DNPDRC_kvhq1, 2), ["Sex", "KVHQ part1"]); DNPDR_PlotLR(DNPDRC_info(:, 3), sum(DNPDRC_kvhq1, 2), ["Age", "KVHQ part1"]);
%DNPDR_PlotLR(DNPDRC_info(:, 2), sum(DNPDRC_kvhq2, 2), ["Sex", "KVHQ part2"]); DNPDR_PlotLR(DNPDRC_info(:, 3), sum(DNPDRC_kvhq2, 2), ["Age", "KVHQ part2"]);
%DNPDR_PlotLR(DNPDRC_info(:, 2), sum(DNPDRC_kvhq1, 2) + sum(DNPDRC_kvhq2, 2), ["Sex", "KVHQ total"]); DNPDR_PlotLR(DNPDRC_info(:, 3), sum(DNPDRC_kvhq1, 2) + sum(DNPDRC_kvhq2, 2), ["Age", "KVHQ total"]);

% (Control group) PDSS total vs Sex, Age
%DNPDR_PlotLR(DNPDRC_info(:, 2), sum(DNPDRC_pdss, 2), ["Sex", "PDSS total"]); DNPDR_PlotLR(DNPDRC_info(:, 3), sum(DNPDRC_pdss, 2), ["Age", "PDSS total"]);

% (Control group) Hue total vs Sex, Age
%DNPDR_PlotLR(DNPDRC_info(:, 2), sum(DNPDRC_hue, 2), ["Sex", "Hue total"]); DNPDR_PlotLR(DNPDRC_info(:, 3), sum(DNPDRC_hue, 2), ["Age", "Hue total"]);

%% Correlation analysis and heatmap


% UPDRS vs VHQ


%% GEE analysis

%% Mixed-effects model analysis


