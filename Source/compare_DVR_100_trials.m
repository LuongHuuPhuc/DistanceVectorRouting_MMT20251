clc; clear; close all;
addpath("plot_components\");

rng(0);  % Co dinh seed de so sanh cong bang

%% ===== CAU HINH CHUNG =====
numNodes = 6;
MAX_ITER = 100;
NUM_TRIALS = 100;
LINK_FAILURE_PROB = 0.2;
INFINITY = 999;

%% ===== DINH NGHIA 3 CHE DO (TRIAD) =====
modes = {
    struct('name','Plain DV', 'split',false,'poison',false)
    struct('name','DV using Split Horizon',   'split',true, 'poison',false)
    struct('name','DV using Poisoned Reverse','split',false,'poison',true)
};

%% ===== PREALLOCATE KET QUA =====
results = table();

%% =================== BAT DAU CHAY SO SANH ===================
for m = 1:length(modes)

    MODE_NAME = modes{m}.name;
    USE_SPLIT_HORIZION = modes{m}.split;
    USE_POISIONED_REVERSE = modes{m}.poison;

    fprintf("\n==============================\n");
    fprintf("MODE: %s\n", MODE_NAME);
    fprintf("==============================\n");

    connected_cnt = 0;
    reachability_list = zeros(NUM_TRIALS,1);
    final_cost_list = zeros(NUM_TRIALS,1);
    max_cost_list = zeros(NUM_TRIALS,1);
    increase_event_list = zeros(NUM_TRIALS,1);

    ConnectedBinary{m} = zeros(NUM_TRIALS,1);
    FinalCostDist{m}   = zeros(NUM_TRIALS,1);
    MaxCostDist{m}     = zeros(NUM_TRIALS,1);
    IncEventDist{m}    = zeros(NUM_TRIALS,1);


    %% ===== LAP 100 LAN THU =====
    for trial = 1:NUM_TRIALS

        % ===== KHOI TAO TOPOLOGY =====
        cost = init_topology(numNodes);
        DV = cost;
        DV(DV == Inf) = INFINITY;

        N = numNodes;
        NextHop = zeros(N);
        for i=1:N
            for j=1:N
                if i~=j && DV(i,j)<INFINITY
                    NextHop(i,j) = j;
                end
            end
        end

        total_cost_hist = zeros(MAX_ITER,1);
        inc_events = 0;

        %% ===== MO PHONG DVR =====
        for iter = 1:MAX_ITER

            % ---- RANDOM LINK FAILURE ----
            if rand < LINK_FAILURE_PROB
                [row,col] = find(cost ~= Inf & cost ~= 0 & triu(true(size(cost))));
                if ~isempty(row)
                    idx = randi(length(row));
                    u = row(idx); v = col(idx);

                    % KHONG doi topology that
                    % chi doi niem tin cuc bo
                    DV(u,v) = INFINITY;
                    DV(v,u) = INFINITY;
                end
            end

            DV_old = DV;

            % ---- DVR UPDATE ----
            [DV_new, NextHop] = distance_vector_step( ...
                DV, cost, NextHop, ...
                USE_SPLIT_HORIZION, ...
                USE_POISIONED_REVERSE, ...
                INFINITY);

            % ---- DEM SO LAN COST TANG (COUNT-TO-INF) ----
            inc_mask = (DV_new > DV_old) & ...
                       (DV_old < INFINITY) & ...
                       (DV_new < INFINITY);
            inc_events = inc_events + nnz(inc_mask);

            total_cost_hist(iter) = sum(DV_new(DV_new < INFINITY),'all');

            DV = DV_new;
        end

        %% ===== THONG KE CUOI TRIAL =====
        reachable = DV < INFINITY;
        reachable(1:N+1:end) = true;

        reach_ratio = nnz(reachable)/(N*N);
        reachability_list(trial) = reach_ratio;
        final_cost_list(trial) = total_cost_hist(end);
        max_cost_list(trial) = max(total_cost_hist);
        increase_event_list(trial) = inc_events;

        if all(reachable(:))
            connected_cnt = connected_cnt + 1;
        end

        ConnectedBinary{m}(trial) = all(reachable(:));
        FinalCostDist{m}(trial)   = total_cost_hist(end);
        MaxCostDist{m}(trial)     = max(total_cost_hist);
        IncEventDist{m}(trial)    = inc_events;
    end

    %% ===== TONG HOP KET QUA MODE =====
    results = [results;
        table( ...
            string(MODE_NAME), ...
            connected_cnt/NUM_TRIALS*100, ...
            mean(reachability_list)*100, ...
            mean(final_cost_list), ...
            std(final_cost_list), ...
            mean(max_cost_list), ...
            mean(increase_event_list), ...
            'VariableNames',{ ...
                'Mode', ...
                'ConnectedRate_pct', ...
                'Reachability_pct', ...
                'FinalCost_mean', ...
                'FinalCost_std', ...
                'MaxCost_mean', ...
                'IncEvents_mean' ...
            })];
end

%% ===== HIEN THI BANG SO SANH =====
disp("===============================================");
disp("SO SANH DVR SAU 100 LAN THU");
disp("===============================================");
disp(results);

%% =================== VE DO THI TRUC QUAN ====================

figure('Name','DVR Statistical Comparison','Color','w');

%% ========== (A) CONNECTED vs DISCONNECTED ==========
for m = 1:length(modes)
    subplot(4,3,m);
    bar([ ...
        sum(ConnectedBinary{m}==1), ...
        sum(ConnectedBinary{m}==0) ...
    ] / NUM_TRIALS);
    
    set(gca,'XTickLabel',{'Conn','Disc'});
    ylim([0 1]);
    title(modes{m}.name);
    if m==1
        ylabel('Connected Rate');
    end
    grid on;
end

%% ========== (B) FINAL COST DISTRIBUTION ==========
for m = 1:length(modes)
    subplot(4,3,3+m);
    histogram(FinalCostDist{m}, ...
        'Normalization','probability','BinMethod','fd');
    if m==1
        ylabel('Final Cost PDF');
    end
    grid on;
end

%% ========== (C) MAX COST (COUNT-TO-INFINITY) ==========
for m = 1:length(modes)
    subplot(4,3,6+m);
    histogram(MaxCostDist{m}, ...
        'Normalization','probability','BinMethod','fd');
    if m==1
        ylabel('Max Cost PDF');
    end
    grid on;
end

%% ========== (D) COST INCREASE EVENTS ==========
for m = 1:length(modes)
    subplot(4,3,9+m);
    histogram(IncEventDist{m}, ...
        'Normalization','probability','BinMethod','integers');
    if m==1
        ylabel('Inc Events PDF');
    end
    xlabel('Value');
    grid on;
end
