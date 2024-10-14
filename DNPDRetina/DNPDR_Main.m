%% DNPDR_Main.m (ver 1.0.241012)
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

% PID, Sex, Age, YOB, Onset_year, Dx_year, Dx_month, UPDRS_year, UPDRS_month, MMSE_year, MMSE_month, KVHQ_year, KVHQ_month, PDSS_year, PDSS_month, Hue_year, Hue_month, VOG_year, VOG_month, OCT_year, OCT_month
DNPDRP_info = DNPDRP(:, [1:9, 76:77, 79:80, 101:102, 118:119, 122:123, 136:137]);
DNPDRP_duration = DNPDRP_info(:, 6) + DNPDRP_info(:, 7)/12 - DNPDRP_info(:, 5);
DNPDRP_updrsDuration = DNPDRP_info(:, 8) + DNPDRP_info(:, 9)/12 - DNPDRP_info(:, 5);
DNPDRP_mmseDuration = DNPDRP_info(:, 10) + DNPDRP_info(:, 11)/12 - DNPDRP_info(:, 5);
DNPDRP_kvhqDuration = DNPDRP_info(:, 12) + DNPDRP_info(:, 13)/12 - DNPDRP_info(:, 5);
DNPDRP_pdssDuration = DNPDRP_info(:, 14) + DNPDRP_info(:, 15)/12 - DNPDRP_info(:, 5);
DNPDRP_hueDuration = DNPDRP_info(:, 16) + DNPDRP_info(:, 17)/12 - DNPDRP_info(:, 5);
DNPDRP_vogDuration = DNPDRP_info(:, 18) + DNPDRP_info(:, 19)/12 - DNPDRP_info(:, 5);
DNPDRP_octDuration = DNPDRP_info(:, 20) + DNPDRP_info(:, 21)/12 - DNPDRP_info(:, 5);

DNPDRP_updrs = DNPDRP(:, 10:75);
DNPDRP_u1 = DNPDRP_updrs(:, 1:13); DNPDRP_u2 = DNPDRP_updrs(:, 14:26); DNPDRP_u3 = DNPDRP_updrs(:, 27:59); DNPDRP_u4 = DNPDRP_updrs(:, 60:63); DNPDRP_hy = DNPDRP_updrs(:, 64);
DNPDR_u1_items = ["Cognitive impairment", "Hallucinations and psychosis", "Depressed mood", "Anxious mood", "Apathy", "Dopamine dysregulation", "Sleep problems", "Daytime sleepiness", "Pain and others", "Urinary problems", ...
 "Constipation", "Light headedness", "Fatigue"];
DNPDR_u2_items = ["Speech", "Saliva drooling", "Chewing swallowing", "Eating tasks", "Dressing", "Hygiene", "Handwriting", "Doing hobbies", "Turning in bed", "Tremor", "Get out of bed", "Walking balance", "Freezing"];
DNPDR_u3_items = ["Speech", "Facial expression", "Rigidity (Neck)", "Rigidity (RUE)", "Rigidity (LUE)", "Rigidity (RLE)", "Rigidity (LLE)", "Finger tapping (R)", "Finger tapping (L)", "Hand movements (R)", "Hand movements (L)", ...
"Pronation/Supination (R)", "Pronation/Supination (L)", "Toe tapping (R)", "Toe tapping (L)", "Leg agility (R)", "Leg agility (L)", "Arising from chair", "Gait", "Freezing", "Postural stability", "Posture", "Bradykinesia", ...
"Postural tremor (R)", "Postural tremor (L)", "Kinetic tremor (R)", "Kinetic tremor (L)", "Rest tremor (RUE)", "Rest tremor (LUE)", "Rest tremor (RLE)", "Rest tremor (LLE)", "Rest tremor (Jaw)", "Rest tremor constancy"];
DNPDR_hy_items = "H-Y score";

DNPDRP_mmse = DNPDRP(:, 78);
DNPDR_mmse_items = "MMSE score";

DNPDRP_kvhq = DNPDRP(:, 81:100);
DNPDRP_kvhq1 = DNPDRP_kvhq(:, 1:10); DNPDRP_kvhq2 = DNPDRP_kvhq(:, 11:20);
DNPDR_kvhq1_items = ["빛 번짐", "글자 안 보임", "직선이 곡선으로", "야간 시력 문제", "헤드라이트 반짝", "빠른 움직임 어려움", "깊이 인식 어려움", "채도 구분 어려움", "배경 위 글자", "조명 변화 글자"];
DNPDR_kvhq2_items = ["없는 사람이 보임", "시야 가장자리", "무언가 지나감", "그림자 형태", "다른 것으로 착각", "실제로 없는 물체", "실제가 아닌 소리", "실제가 아닌 촉감", "실제가 아닌 냄새", "실제가 아닌 맛"];

DNPDRP_pdss = DNPDRP(:, 103:117);
DNPDR_pdss_items = ["수면의 질", "입면 어려움", "수면 유지 어려움", "팔다리 불안", "팔다리 탈면", "이상한 꿈", "환청/환시", "야간뇨", "가위 눌림", "팔다리 통증", "팔다리 뭉침", "이상한 자세", "기상 시 떨림", "피곤함/졸림", "코골이 탈면"];

DNPDRP_hue = DNPDRP(:, 120:121);
DNPDRP_vog = DNPDRP(:, 124:135);
DNPDRP_oct = DNPDRP(:, 138:end);
DNPDRP_axl_od = DNPDRP_oct(:, 1); DNPDRP_wrt_od = DNPDRP_oct(:, 3:11); DNPDRP_rnfl_od = DNPDRP_oct(:, 12:20); DNPDRP_gcl_od = DNPDRP_oct(:, 21:29); DNPDRP_ipl_od = DNPDRP_oct(:, 30:38);
DNPDRP_axl_os = DNPDRP_oct(:, 2); DNPDRP_wrt_os = DNPDRP_oct(:, 39:47); DNPDRP_rnfl_os = DNPDRP_oct(:, 48:56); DNPDRP_gcl_os = DNPDRP_oct(:, 57:65); DNPDRP_ipl_os = DNPDRP_oct(:, 66:74);

% PID, Sex, Age, YOB, UPDRS_year, UPDRS_month, MMSE_year, MMSE_month, KVHQ_year, KVHQ_month, PDSS_year, PDSS_month, Hue_year, Hue_month
DNPDRC_info = DNPDRC(:, [1:6, 73:74, 76:77, 98:99, 115:116]);

DNPDRC_updrs = DNPDRC(:, 7:72);
DNPDRC_u1 = DNPDRC_updrs(:, 1:13); DNPDRC_u2 = DNPDRC_updrs(:, 14:26); DNPDRC_u3 = DNPDRC_updrs(:, 27:59); DNPDRC_u4 = DNPDRC_updrs(:, 60:63); DNPDRC_hy = DNPDRC_updrs(:, 64);
DNPDRC_mmse = DNPDRC(:, 75);
DNPDRC_kvhq = DNPDRC(:, 78:97);
DNPDRC_kvhq1 = DNPDRC_kvhq(:, 1:10); DNPDRC_kvhq2 = DNPDRC_kvhq(:, 11:20);
DNPDRC_pdss = DNPDRC(:, 100:114);
DNPDRC_hue = DNPDRC(:, 117:118);

%% Data summary
UPDRS_isnanP = ~isnan(DNPDRP_info(:, 8)); MMSE_isnanP = ~isnan(DNPDRP_info(:, 10)); KVHQ_isnanP = ~isnan(DNPDRP_info(:, 12)); PDSS_isnanP = ~isnan(DNPDRP_info(:, 14));
Hue_isnanP = ~isnan(DNPDRP_info(:, 16)); VOG_isnanP = ~isnan(DNPDRP_info(:, 18)); OCT_isnanP = ~isnan(DNPDRP_info(:, 20));
UPDRS_isnanC = ~isnan(DNPDRC_info(:, 5)); MMSE_isnanC = ~isnan(DNPDRC_info(:, 7)); KVHQ_isnanC = ~isnan(DNPDRC_info(:, 9));
PDSS_isnanC = ~isnan(DNPDRC_info(:, 11)); Hue_isnanC = ~isnan(DNPDRC_info(:, 13));
fprintf("== Data summary for PD patients ==\n");
fprintf("VOG (+), OCT (+) : %d\n", sum(VOG_isnanP .* OCT_isnanP));
fprintf("VOG (-), OCT (+) : %d\n", sum(~VOG_isnanP .* OCT_isnanP));
fprintf("VOG (+), OCT (-) : %d\n", sum(VOG_isnanP .* ~OCT_isnanP));
fprintf("VOG (-), OCT (-) : %d\n", sum(~VOG_isnanP .* ~OCT_isnanP));

%% Baseline characteristics
fprintf("\n== Baseline characteristics for PD patients ==\n");
VariableP = ["Sex"; "Age"; "Duration"; "UPDRS_part1"; "UPDRS_part2"; "UPDRS_part3"; "UPDRS_part4"; "MMSE_score"; "KVHQ_part1"; "KVHQ_part2"; "PDSS_score"; "Hue_score"];
tableHeaderP = table(VariableP);
tableDataP = vertcat(descvar(DNPDRP_info(:, 2), "table"), descvar(DNPDRP_info(:, 3), "table"), descvar(DNPDRP_duration, "table"), ...
            descvar(sum(DNPDRP_u1, 2), "table"), descvar(sum(DNPDRP_u2, 2), "table"), descvar(sum(DNPDRP_u3, 2), "table"), descvar(sum(DNPDRP_u4, 2), "table"), ...
            descvar(DNPDRP_mmse, "table"), descvar(sum(DNPDRP_kvhq1, 2), "table"), descvar(sum(DNPDRP_kvhq2, 2), "table"), ...
            descvar(sum(DNPDRP_pdss, 2), "table"), descvar(sum(DNPDRP_hue, 2), "table"));
tableDataP = horzcat(tableHeaderP, tableDataP);
disp(tableDataP);

VariableC = ["Sex"; "Age"; "UPDRS_part1"; "UPDRS_part2"; "UPDRS_part3"; "UPDRS_part4"; "MMSE_score"; "KVHQ_part1"; "KVHQ_part2"; "PDSS_score"; "Hue_score"];
tableHeaderC = table(VariableC);
tableDataC = vertcat(descvar(DNPDRC_info(:, 2), "table"), descvar(DNPDRC_info(:, 3), "table"), ...
            descvar(sum(DNPDRC_u1, 2), "table"), descvar(sum(DNPDRC_u2, 2), "table"), descvar(sum(DNPDRC_u3, 2), "table"), descvar(sum(DNPDRC_u4, 2), "table"), ...
            descvar(DNPDRC_mmse, "table"), descvar(sum(DNPDRC_kvhq1, 2), "table"), descvar(sum(DNPDRC_kvhq2, 2), "table"), ...
            descvar(sum(DNPDRC_pdss, 2), "table"), descvar(sum(DNPDRC_hue, 2), "table"));
tableDataC = horzcat(tableHeaderC, tableDataC);
disp(tableDataC);

%% Data visualization

% (Patient group) Plot bar chart for UPDRS part 1, 2, 3, H-Y score, MMSE score, KVHQ part 1, 2, PDSS score
%DNPDR_PlotBar(DNPDRP_u1, "UPDRS part 1", DNPDR_u1_items);
%DNPDR_PlotBar(DNPDRP_u2, "UPDRS part 2", DNPDR_u2_items);
%DNPDR_PlotBar(DNPDRP_u3, "UPDRS part 3", DNPDR_u3_items);
%DNPDR_PlotBar(DNPDRP_hy, "H-Y score", DNPDR_hy_items);
%DNPDR_PlotBar(DNPDRP_mmse, "MMSE score", DNPDR_mmse_items);
%DNPDR_PlotBar(DNPDRP_kvhq1, "KVHQ part 1", DNPDR_kvhq1_items);
%DNPDR_PlotBar(DNPDRP_kvhq2, "KVHQ part 2", DNPDR_kvhq2_items);
%DNPDR_PlotBar(DNPDRP_pdss, "PDSS score", DNPDR_pdss_items);

% (Control group) Plot bar chart for UPDRS part 1, 2, 3, MMSE score, KVHQ part 1, 2, PDSS score
%DNPDR_PlotBar(DNPDRC_u1, "UPDRS part 1", DNPDR_u1_items);
%DNPDR_PlotBar(DNPDRC_u2, "UPDRS part 2", DNPDR_u2_items);
%DNPDR_PlotBar(DNPDRC_u3, "UPDRS part 3", DNPDR_u3_items);
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


