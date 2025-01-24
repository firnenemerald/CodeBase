% Gaitome parameter extractor
% JH Shin 2022.12

% This code extracts spatiotemporal gait parameters, turning related
% variables, posture and arm swing asymmetry

clear, close all
% load('C:\Users\neosj\Dropbox\MATLAB\ODPCC\color_setting\color_set.mat')
% 6.3853  21.31017406 48377966

sessionFolder = {'C:\Users\chanh\Downloads\Gaitome_test'};

cd(char(sessionFolder))
list = dir;

tdata = [];
tdatat = [];
tdatap = [];
tlist = {};

for session = 3:length(list)
    cd([char(sessionFolder), '/', list(session).name])
    xtempFile = FindFiles('*.xlsx','CheckSubdirs',1);
    if length(xtempFile)>5 %xlsx파일의 개수가 6개 이상부터

        slist =find(contains(xtempFile,'step_length_list'));
        FS = readcell(xtempFile{slist},'UseExcel',true,'Sheet','Forward Walk'); FS = cell2mat(FS(2:end,:));
        BS = readcell(xtempFile{slist},'UseExcel',true,'Sheet','Backward Walk');BS = cell2mat(BS(2:end,:));
        TS = readcell(xtempFile{slist},'UseExcel',true,'Sheet','Turn');TS = TS(2:end,:);
        mask = cellfun(@ismissing, TS, 'UniformOutput', false);
        TS(cell2mat(mask)) = [];TS = cell2mat(TS); %결측치 제거
        Turntime = readcell(xtempFile{slist},'UseExcel',true,'Sheet','Turning frame info. ');Turntime = Turntime(2:end,:);    
        nTurn = size(Turntime,1); %Turntime의 column개수

        match = ["'", "[","]"];
        Turnt = erase(Turntime(:,2), match);        % "'"  "["   "]" 를 제거하는 과정
        for k = 1:nTurn
            Turnt2(k,1:2) = str2num(cell2mat(Turnt(k)));
            Turnt2(k,3) = (Turnt2(k,2)-Turnt2(k,1))*0.033;  %30 frame
        end

        wlist =find(contains(xtempFile,'step_width_list'));
        % stepwidth
        FSW = readcell(xtempFile{wlist},'UseExcel',true,'Sheet','Forward Walk');FSW = cell2mat(FSW(2:end,:));
        BSW = readcell(xtempFile{wlist},'UseExcel',true,'Sheet','Backward Walk');BSW = cell2mat(BSW(2:end,:));
        TSW = readcell(xtempFile{wlist},'UseExcel',true,'Sheet','Turn');TSW = cell2mat(TSW(2:end,:));

        timelist =find(contains(xtempFile,'time_list'));
        %Time
        % Time = xlsread(xtempFile{4});
        FST = readcell(xtempFile{timelist},'UseExcel',true,'Sheet','Forward Walk Time');FST = cell2mat(FST(2:end,:));
        BST = readcell(xtempFile{timelist},'UseExcel',true,'Sheet','Backward Walk Time');BST = cell2mat(BST(2:end,:));
        TST = readcell(xtempFile{timelist},'UseExcel',true,'Sheet','Turn Time');TST = cell2mat(TST(2:end,:));

        % trial by trial
        perlist =find(contains(xtempFile,'per'));
        sheets = sheetnames(xtempFile{perlist});x=[];
        x = strmatch("turn", sheets); %find "turn" in the sheets
        tind=[];
        for kk=1:length(x)
            TRV = readcell(xtempFile{perlist},'UseExcel',true,'Sheet',sheets(x(kk)));
            if length(TRV)>1
                mask = cellfun(@ismissing, TRV, 'UniformOutput', false);
                rm = cell2mat(mask(2:end,2));
                if(sum(rm)>0)
                    TRV((rm==1)+1,:)=[];
                else
                    TRV = cell2mat(TRV(2:end,:));
                    temp = ones(size(TRV,1),1)*kk;
                    nsT(kk,1) = size(TRV,1);
                    tind = [tind;temp];
                    temp=[];
                end
            end
        end
        %% Gait (non-turning phase)
        AS = [FS;BS];
        AST = [FST;BST];
        ASW = [FSW;BSW];
        cind = AS(:,2) > 0.05;% cind = AS(:,2) > 0; % include all or not...
        AS2 = AS(cind,:); AST2 = AST (cind,:); ASW2 = ASW(cind,:);

        % cadence, velocity
        bsumlist =find(contains(xtempFile,'backward_'));
        fsumlist =find(contains(xtempFile,'forward_'));
        GA = readcell(xtempFile{bsumlist},'UseExcel',true);
        cad1 = cell2mat(GA(2,9)); v1 = cell2mat(GA(2,10));

        GA2 = readcell(xtempFile{fsumlist},'UseExcel',true);
        cad2 = cell2mat(GA2(2,9)); v2 = cell2mat(GA2(2,10));

        cad = mean([cad1 cad2]); vel = mean([v1 v2]);

        % step length asymmetry.. (preliminary)
        y = strmatch("forward", sheets);
        tind=[];
        for kk=1:length(y)
            TRV = readcell(xtempFile{perlist},'UseExcel',true,'Sheet',sheets(y(kk)));
            TRV = cell2mat(TRV(2:end,:));
            l = (length(TRV));
            if l > 0
                if mod(l,2) ==0 & l > 2
                    ls = TRV ([1:2:l],2);, lr = TRV(2:2:l-1,2); %odd,even --> left,right index
                    lsind = ls > 0.05;lrind = lr > 0.05;
                    lsm = mean(ls(lsind));lrm = mean(lr(lrind));
                    ssyms(kk,1) = abs(lsm-lrm)/(abs(lsm+lrm)); %Calculate the asymmetry of the step length
                elseif mod(l,2) == 1 & l > 2
                    ls = TRV ([1:2:l-1],2);, lr = TRV(2:2:l-2,2);
                    lsind = ls > 0.05;lrind = lr > 0.05;
                    lsm = mean(ls(lsind));lrm = mean(lr(lrind));
                    ssyms(kk,1) = abs(lsm-lrm)/(abs(lsm+lrm));
                end
            else
                ssyms(kk,1) = -100;
            end
        end

        % arm swing asymmetry
        % extracting the forward and backward phase
        % Turnt2 phase만 deletion
        % Right shoulder 3, Right wrist 4, left shoulder 6, left wrist 8
        xtempFile2 = FindFiles('*.csv','CheckSubdirs',1);
        totcord = readcell(xtempFile2{1});
        totcords = size(totcord);
        theta = 180; % to rotate 180 counterclockwise
        R = [cosd(theta) -sind(theta); sind(theta) cosd(theta)]; 
        tempdat2 = [];

        for l=[3 4 6 8] 
            for k=1:totcords(1)
                tempdat(k,:) = str2num(totcord{k,l});
            end
            tempdat2 = [tempdat2 tempdat];tempdat=[];
        end
        % Relative movement of wrist compared to shoulder
        tempdat3r = abs((tempdat2(:,3)-tempdat2(:,1)) + i*(tempdat2(:,4)-tempdat2(:,2)));
        tempdat3l = abs((tempdat2(:,7)-tempdat2(:,5)) + i*(tempdat2(:,8)-tempdat2(:,6)));
        tempdata3 = [tempdat3r tempdat3l];
        fs = 30;
        for i=1:2
            data = tempdata3(:,i);

            L = length(data);
            t = 0:1/fs:1/fs*(L-1); 
            y = fft(data); %fourier transform
            P2 = abs(y/L); %obtain the spectral size
            P1 = P2(1:L/2+1); %Select positive frequency components only
            P1(2:end-1) = 2*P1(2:end-1); %Double the positive frequency component
            f = fs*(0:(L/2))/L;
            P3 = smoothdata(P1,'gaussian',15);
            temp_arms(:,i) = sum((P3(find(f>1 & f<3))));
        end
        asyms = abs(temp_arms(2)-temp_arms(1))/(temp_arms(2)+temp_arms(1));
        %Compare the energy difference between the two arms

        % step length % step length variability, step time, step width % cadence % velocity
        tempdata = [mean(AS2(:,2)*100) std(AS2(:,2)*100)/mean(AS2(:,2)*100) mean(AST2(:,2)*100) std(AST2(:,2)*100)/mean(AST2(:,2)*100) mean(ASW2(:,2)*100) std(ASW2(:,2)*100)/mean(ASW2(:,2)*100) cad vel nanmean(ssyms(ssyms>0)) asyms];

        %% Turning analysis
        %number of turn, mean turning time, var turning time, mean turning step,
        %var turning step, mean turning step time, var turning step time,
        % mean step width , var step width during turning
        % mean number of steps, var number of steps for turning

        % 5cm미만 length는 삭제
        bind = TS(:,2) > 0.05;%bind = TS(:,2) > 0;
        TS2 = TS(bind,:);TST2 = TST(bind,:);TSW2 = TSW(bind,:);

        tsumlist = find(contains(xtempFile,'turning_'));

        % turning velocity
        TA2 = readcell(xtempFile{tsumlist},'UseExcel',true);
        TA2(1,:)=[];
        tv = cell2mat(TA2(1,10));
        tc = cell2mat(TA2(1,9));

        tempdatat = [nTurn mean(Turnt2(:,3)) std(Turnt2(:,3))/mean(Turnt2(:,3)) mean(TS2(:,2)) std(TS2(:,2))/mean(TS2(:,2)) mean(TST2(:,2)) std(TST2(:,2))/mean(TST2(:,2)) mean(TSW2(:,2)) std(TSW2(:,2))/mean(TSW2(:,2)) mean(nsT) std(nsT)/mean(nsT) tc tv];


        %% posture extrator
        plist = find(contains(xtempFile,'posture_'));
        Posture = readcell(xtempFile{plist},'UseExcel',true);
        Posture = (Posture(2:end,3:end)); Ps = size(Posture);
        theta = 180; % to rotate 180 counterclockwise
        R = [cosd(theta) -sind(theta); sind(theta) cosd(theta)];
        tempdat2 = [];
        for l=1:Ps(2)
            for k=1:Ps(1)
                tempdat(k,:) = str2num(Posture{k,l});
            end
            tempdat2 = [tempdat2 tempdat];tempdat=[];
        end
        cord = tempdat2;tempdat2=[];

        for k=1:size(cord,1);
            if cord(k,3)==0 & size(cord,1)==1;
                cordt = cord(k,[1 2 5 6 9 10 13 14]);
                for j=1:4
                    cordt2(j,:) = [cordt(2*j-1), cordt(2*j)];
                    xtemp = mean(cordt2(:,1));
                    cordt2(:,1) = 2*xtemp - cordt2(:,1); %Symmetric transformation of x coordinates
                end
            elseif cord(k,1) == 0 & size(cord,1)==1; %Right ear visible 오른쪽 쳐다보고 있는 상황
                cordt = cord(k,[3 4 7 8 11 12 15 16]); % ear, shoulder, hip, ankle
                for j=1:4
                    cordt2(j,:) = [cordt(2*j-1), cordt(2*j)];
                end
            elseif cord(k,1) == 0 & cord(k,16) > mean(cord(:,16)); % Right ear visible 오른쪽 쳐다보고 있는 상황
                cordt = cord(k,[3 4 7 8 11 12 15 16]); % ear, shoulder, hip, ankle
                for j=1:4
                    cordt2(j,:) = [cordt(2*j-1), cordt(2*j)];
                end
            elseif cord(k,3)==0 & cord(k,16) > mean(cord(:,16));
                cordt = cord(k,[1 2 5 6 9 10 13 14]);
                for j=1:4
                    cordt2(j,:) = [cordt(2*j-1), cordt(2*j)];

                end
            else
                cordt2 = zeros (4,2);
            end
            cordt2(:,1) = cordt2(:,1) - cordt2(1,1);

            cordt2 = cordt2*R;

            % facing left ==> facing right conversion
            if cordt2(2,1) > cordt2(1,1)
                cordt2(:,1) = 2*mean(cordt2(:,1))-cordt2(:,1)
            end
            slopesA = (cordt2(3,2) - cordt2(2,2)) ./ (cordt2(3,1) - cordt2(2,1)); % hip-shoulder
            slopesB = (cordt2(2,2) - cordt2(1,2)) ./ (cordt2(2,1) - cordt2(1,1)); % ear-shoulder
            slopesC = (cordt2(4,2) - cordt2(3,2)) ./ (cordt2(4,1) - cordt2(3,1)); % hip-ankle
            ang(k,2) = abs(atand(slopesA))- (abs(atand(slopesB))); %dropped head angle

            %anterior flexion angle
            if atand(slopesA)>0
                ang(k,1) = abs(90-abs(atand(slopesA)));
            else
                ang(k,1) = abs(abs(atand(slopesA))-90);
            end

            if atand(slopesC)>0
                ang(k,3) = ang(k,1) + atand(slopesC) - 90;
            else
                ang(k,3) = ang(k,1) + atand(slopesC) + 90;
            end
            cordt2=[];cordt=[];
        end

        % tang = nanmean(ang(find(ang(:,3)>0),:));
        if size(ang,1) > 1
            tang = nanmean(ang);
        else
            tang =ang;
        end

        tdata = [tdata;tempdata];
        tdatat = [tdatat;tempdatat];
        tdatap = [tdatap;tang];
        tlist = [tlist;(list(session).name)];
        tempdata=[];tempdatat=[];tang=[];
        ['Gait extract for ' list(session).name ' completed']
        clear AS AST ASW cind AS2 AST2 ASW2 TS TS2 TSW2 TST2 TSW TST ang
        % else
        %     tempdata=[];tempdatat=[];
        %     tdata = [tdata;tempdata];
        %     tdatat = [tdatat;tempdatat];
        %     clear AS AST ASW cind AS2 AST2 ASW2 TS TS2 TSW2 TST2 TSW TST ang

    end
end

PDtdat = [tdata tdatat tdatap];

