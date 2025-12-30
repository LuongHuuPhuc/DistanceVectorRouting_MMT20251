clc; clear; close all;

INFINITY = 999;

% ===== TOPOLOGY: A(1) - B(2) - C(3) =====
N = 3; % Gia su co 3 Router
cost = INFINITY * ones(N);
cost(1,1)=0; cost(2,2)=0; cost(3,3)=0;

% Chi phi di lai
cost(1,2)=1; cost(2,1)=1;
cost(2,3)=1; cost(3,2)=1;

% ===== DV ban dau (router chi biet cost toi neighbor) =====
DV = cost;

% Cho hoi tu ban dau (dong bo) de co A->C = 2
% (o topology 3 nut nay, chi can 2-3 vong la du)
for k = 1:5
    DV_new = DV;
    for x = 1:N
        for y = 1:N
            if x==y, continue; end
            % Bellman-Ford: min_{v neighbor} c(x,v) + Dv(y)
            best = DV(x,y);
            for v = 1:N
                if cost(x,v) < INFINITY && x ~= v
                    best = min(best, cost(x,v) + DV(v,y));
                end
            end
            DV_new(x,y) = best;
        end
    end
    DV = DV_new;
end

% Luc nay DV(1,3)=2 va DV(2,3)=1
fprintf("Before failure: A->C=%d, B->C=%d\n", DV(1,3), DV(2,3));

% ===== LINK FAILURE: dut B(2) - C(3) =====
cost(2,3) = INFINITY;
cost(3,2) = INFINITY;

% Quan trong: chi B biet link toi C dut (cap nhat local link cost)
DV(2,3) = INFINITY;
DV(3,2) = INFINITY;

% A van tin route cu (A->C=2 qua B) trong 1 thoi gian
% => day la "thong tin loi thoi" de gay count-to-infinity

K = 20; % so iteration de ve
AtoC = zeros(K,1);
BtoC = zeros(K,1);

for iter = 1:K
    % ===== ASYNCHRONOUS UPDATE (co chu y) =====
    % (1) B cap nhat duong toi C dua tren thong tin tu A (A chua biet dut)
    DV(2,3) = min( cost(2,1) + DV(1,3), INFINITY );  % chi con duong qua A

    % (2) A cap nhat duong toi C dua tren thong tin tu B
    DV(1,3) = min( cost(1,2) + DV(2,3), INFINITY );

    AtoC(iter) = DV(1,3);
    BtoC(iter) = DV(2,3);
end

% ===== VE HINH MINH HOA =====
figure('Name','Count-to-Infinity Demo','NumberTitle','off');
plot(1:K, AtoC, '-o', 'LineWidth', 2); hold on;
plot(1:K, BtoC, '-o', 'LineWidth', 2);
grid on;
xlabel('Iteration');
ylabel('Metric to C (cost)');
title('Count-to-Infinity: Metric tăng dần do thông tin lỗi thời');
legend('A(1) \rightarrow C(3)', 'B(2) \rightarrow C(3)', 'Location','northwest');