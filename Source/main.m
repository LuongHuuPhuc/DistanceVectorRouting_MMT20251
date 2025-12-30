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
MAX_ITER = 50; 

% So vong lap ma link bi failure (Khi nao mang bi link failure)
LINK_FAILURE_ITER = 6; % (UNUSED)
LINK_FAILURE_PROB = 0.2;  % Ty le Link bi dut (20 %)

% Bat/tat chuc nang
USE_SPLIT_HORIZION = false; % Giam Count-to-Infinity nhung chua triet de
USE_POISIONED_REVERSE = false; % Chong Count-to-Infinity manh nhat trong DVR

% So lon huu han
INFINITY = 999;

% ===== PREALLOCATE LUU FAILURE =====
maxFailures = MAX_ITER;
failure_iter = zeros(maxFailures, 1);  % Luu iteration tuong ung
failure_links = zeros(maxFailures, 2); % Luu cap link bi dut (u, v)
cost_after_list = cell(maxFailures, 1); % Mang luu cac topology sau failure vi moi phan tu la 1 matrix NxN
failure_count = 0;

% ===== KHOI TAO TOPOLOGY =====
cost = init_topology(numNodes);
cost_before = cost; % Topology truoc khi link failure
cost_history = zeros(MAX_ITER, 1); % Lich su hoi tu

N = numNodes;

% ===== KHOI TAO BANG DINH TUYEN (DISTANCE VECTOR ROUTE) =====
% Luu thong tin duong di va quyet dinh duong di tiep theo cho Router
DV = cost;
DV(DV == Inf) = INFINITY; % Thay vo cuc bang so lon huu han de de quan sat

NextHop = zeros(N); % Khoi tao bang NextHop ban dau = 0 (Router ke tiep) kich thuoc (NxN = 6x6)
% Ban dau chua biet duong di: 
% NextHop[6,6] =
%      0   0   0   0   0   0 
%      0   0   0   0   0   0 
%      0   0   0   0   0   0 
%      0   0   0   0   0   0 
%      0   0   0   0   0   0 
%      0   0   0   0   0   0 

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

            % Luu lai topology sau moi lan failure 
            failure_count = failure_count + 1;

            cost_after_list{failure_count} = cost;
            failure_iter(failure_count) = iter;
            failure_links(failure_count, :) = [u, v]; 
        end
    end

    % Do topology co nhieu duong thay the nen it xay ra Count-to-Infinity
    % Count-to-Infinity chi xay ra khi topology ngheo duong du phong

    % ----- CAP NHAT BANG DINH TUYEN DISTANCE VECTOR -----
    [DV_new, NextHop] = distance_vector_step(...
        DV, cost, NextHop, ...
        USE_SPLIT_HORIZION, ...
        USE_POISIONED_REVERSE, ...
        INFINITY);
    
    cost_history(iter) = sum(DV_new(DV_new < INFINITY), 'all');

    % ----- IN BANG DINH TUYEN -----
    print_routing_table(DV_new, NextHop, INFINITY);

    % ----- KIEM TRA HOI TU -----
    if check_convergence(DV, DV_new)
        fprintf(">>> NETWORK CONVERGED");
        DV = DV_new;
        break;
    end

    % Cap nhat trang thai cho vong sau
    % Neu khong cap nhat -> 100 % xay ra Count-to-Infinity
    % Neu cap nhat -> Mang hoi tu ngay
    % Day chi la buoc cap nhat trang thai cua thuat toan DV sau moi vong lap
    DV = DV_new;
end

% ----- VE DO THI TRUC QUAN HOA TUNG LAN FAILURE -----
cost_history = cost_history(1 : iter);

if failure_count > 0
    % Cat phan du
    cost_after_list = cost_after_list(1 : failure_count);
    failure_iter = failure_iter(1 : failure_count);
    failure_links = failure_links(1 : failure_count, :); 
else
    cost_after_list = {};
    failure_iter = [];
    failure_links = [];
end

plot_network_analysis( ...
    cost_before, ...
    cost_after_list, ...
    cost, ...
    cost_history, ...
    failure_iter, ...
    failure_links);
