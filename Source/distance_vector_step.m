% Date: 2025/12/25
% LuongHuuPhuc
% brief: Thuc hien 1 buoc cap nhat bang dinh tuyen (Distance Vector Route)
% dua tren cong thuc cua dung thuat toan Bellman-Ford 
% Router x thu di toi moi dich y thong qua moi lang gieng v, neu tong chi phi
% nho hon thi cap nhat bang dinh tuyen
%
% Description: 
%   - Moi Router x nhan bang Distance Vector tu cac Router lang gieng v
%   - Cap nhat cost ngan nhat den moi dich y
%   - Ho tro cac co che nang cao: Split Horizon, Poisioned Reverse 
% Input: 
%   - DV: Ma tran Distance Vector hien tai (NxN)
%   - cost: Ma tran chi phi lien ket vat ly
%   - NextHop: Bang Next hop hien tai 
%   - USE_SPLIT_HORIZON: Bat/tat che do 
%   - USE_POISION_REVERSE: Bat/tat che do 
%   - INFINITY: Gia tri dai dien cho vo han (huu han lon)
% Output: 
%   - DV_new: Distance Vector sau khi cap nha
%   - NextHop: Bang Next Hop sau khi cap nhat
function [DV_new, NextHop] = distance_vector_step( ...
    DV, cost, NextHop, ...
    USE_SPLIT_HORIZON, USE_POISON_REVERSE, INFINITY)

    % So node (Router) trong mang
    N = size(DV, 1);
    DV_new = DV;  % Khoi tao DV moi = DV cu (chi update khi tim duoc duong tot hon)

    % Router x (Router dang cap nhat bang dinh tuyen cua no)
    for x = 1 : N 
        % Router v (Router lang gieng cua x)
        for v = 1 : N 
            % cost(x, v) ~= Inf -> Lang gieng truc tiep cua no
            % x ~= v -> Bo qua chinh no
            if(cost(x, v) ~= Inf && x ~= v)

                % Router x nhan bang DV tu router v
                for y = 1 : N
                    % Router v quang ba chi phi cua no den dich y
                    advertised_cost = DV(v, y);

                    % ----- SPLIT HORIZON -----
                    % Router v di toi y qua chinh Router x
                    if USE_SPLIT_HORIZON && NextHop(v, y) == x
                        % Router v khong duoc phep quang ba Route do cho Router x
                        % Muc tieu giam vong lap
                        continue;
                    end

                    % ----- POISIONED REVERSE -----
                    % Router v di toi y qua Router x
                    if USE_POISON_REVERSE && NextHop(v, y) == x
                        % Router v van quang ba nhung voi cost = ∞
                        advertised_cost = INFINITY;
                    end

                    % Tinh chi phi moi (Bellman-Ford)
                    new_cost = cost(x, v) + advertised_cost;

                    % So sanh chi phi cu va moi
                    if new_cost < DV_new(x, y)
                        DV_new(x, y) = new_cost; % Neu tot hon
                        NextHop(x, y) = v; % Dat next hop = router v
                    end
                end
            end
        end
    end
end