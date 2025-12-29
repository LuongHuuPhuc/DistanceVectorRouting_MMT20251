% Date: 2025/12/25
% LuongHuuPhuc
% brief: Dieu khien mo phong chinh & Cau hinh nang cao
% (vd: gay link failure, quan sat hoi tu, Count-to-Infinity)
% note: Mo phong cho thay thuat toan DVR gap hien tuong Count-to-Inifinity khi 
% xay ra link failure. Viec ap dung Split Horizon giup giam vong lap
% trong khi Posioned Reverse co the loai bo hoan toan hien tuong nay

clc; clear; close all;

addpath("plot_components\");

% ===== CAU HINH =====
numNodes = 6; % So Nodes (so Router)

% So lan cac Router trao doi bang dinh tuyen toi da (so lan cap nhat toi da cua thuat toan)
% Chinh la gioi han so vong cap nhat de tranh chay vo han khi mang khong hoi tu
MAX_ITER = 20; 

% So vong lap ma link bi failure (Khi nao mang bi link failure)
LINK_FAILURE_ITER = 6; % (UNUSED)
LINK_FAILURE_PROB = 0.2;  % Ty le Link bi dut (20 %)

% Bat/tat chuc nang
USE_SPLIT_HORIZION = false; % Giam Count-to-Infinity nhung chua triet de
USE_POISIONED_REVERSE = false; % Chong Count-to-Infinity manh nhat trong DVR

INFINITY = 999;

% ===== KHOI TAO TOPOLOGY =====
cost = init_topology(numNodes);
cost_before = cost; % Topology truoc khi link failure
cost_after = []; % Luu topology sau failure 
cost_history = zeros(MAX_ITER, 1); % Lich su hoi tu
N = numNodes;

% ===== KHOI TAO BANG DINH TUYEN (DISTANCE VECTOR ROUTE) =====
% Luu thong tin duong di va quyet dinh duong di tiep theo cho Router
DV = cost;
DV(DV == Inf) = INFINITY; % Thay vo cuc bang so lon huu han de de quan sat

NextHop = zeros(N); % Khoi tao bang NextHop ban dau (Router ke tiep) co N gia tri 0
% Ban dau chua biet duong di: 
% NextHop =
%      0   0   0   0
%      0   0   0   0
%      0   0   0   0
%      0   0   0   0


% Vong for khoi tao NextHop
for i = 1 : N
    for j = 1 : N

        % Khong xet duong tu node toi chinh no - chi xet cac node co ket noi truc tiep
        % Cost DV(i, j) chua den gia tri vo han
        if i ~= j && DV(i, j) < INFINITY
            % Neu router i noi truc tiep voi router j thi next hop de di toi chinh la j
            NextHop(i, j) = j; 
        end
    end
end

% ===== MO PHONG VONG LAP =====
for iter = 1 : MAX_ITER
    fprintf("\n===== INTERATION %d =====\n", iter);

    % ----- LINK FAILURE (RANDOM SHIT) -----
    if rand < LINK_FAILURE_PROB
        % Tim tat ca cac link dang ton tai (Chi lay nua tren ma tran)
        % cost ~= Inf -> Co link 
        % cost ~= 0 -> Khong phai la node voi chinh no 
        % triu(...) -> Tranh chon trung (i - j) va (j - i)
        [row, col] = find(cost ~= Inf & cost ~= 0 & triu(true(size(cost))));

        if ~isempty(row)
            % Chon ngau nhien 1 link 
            idx = randi(length(row));
            u = row(idx);
            v = col(idx);

            fprintf(">>> RANDOM LINK FAILURE: %d <-> %d\n", u, v);

            % Xoa link vat ly 
            cost(u, v) = Inf;
            cost(v, u) = Inf;

            % Cap nhat bang DV cuc bo
            DV(u, v) = INFINITY;
            DV(v, u) = INFINITY;

            cost_after = cost;
        end
    end


    % ----- CAP NHAT DISTANCE VECTOR -----
    [DV_new, NextHop] = distance_vector_step(...
        DV, cost, NextHop, ...
        USE_SPLIT_HORIZION, USE_POISIONED_REVERSE, INFINITY);

    % ----- IN BANG DINH TUYEN -----
    print_routing_table(DV_new, NextHop, INFINITY);

    % ----- KIEM TRA HOI TU -----
    if check_convergence(DV, DV_new)
        fprintf(">>> NETWORK CONVERGED");
        break;
    end

    % ----- VE DO THI TRUC QUAN HOA -----
    cost_history(iter) = sum(DV_new(DV_new < INFINITY), 'all');
    plot_network_analysis(cost_before, cost_after, cost, cost_history);

end