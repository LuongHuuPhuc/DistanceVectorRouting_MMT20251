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
%   - DV_new: Distance Vector cua cac Router sau khi cap nha
%   - NextHop: Bang Next Hop sau khi cap nhat
function [DV_new, NextHop] = distance_vector_step_for_demo( ...
    DV, cost, NextHop, ...
    USE_SPLIT_HORIZON, USE_POISONED_REVERSE, INFINITY, x_update)

    % So node (Router) trong mang
    N = size(DV, 1);
    DV_new = DV;  % Khoi tao DV moi = DV cu (chi update khi tim duoc duong tot hon)

    % Chi Update 1 Router (Bat dong bo)
    x = x_update;

    % Router v (Router lang gieng cua x)
    for v = 1 : N 

        % Bellman-Ford phan tan:
        % + DV(x, v) < INFINITY -> Router x chi dua vao niem tin cua
        %                          chinh no de toi v (Khong quan tam link con hay khong)
        if(DV(x, v) < INFINITY && x ~= v)
        % ===================================================== % 
        % Bellman-Ford ly tuong: 
        % + cost(x, v) ~= Inf -> Router x va v con link vat ly truc tiep
        %                        Neu ta cap nhat cost cua Topology chua thong tin ve link vat 
        %                        ly giua Router u-v sau moi iter la Inf thi moi lan cap nhat bang dinh tuyen, 
        %                        cost(u, v) ~= Inf se bo qua no => Link vat ly mat di (khong thuc te)
        % if(cost(x, v) ~= Inf && x ~= v)

            % Router v chia se bang dinh tuyen DV cua no cho Router x route toi y
            for y = 1 : N

                % Router v quang ba chi phi cua no den Router y nao do
                advertised_cost = DV(v, y);

                % ----- SPLIT HORIZON -----
                % Neu Router v di toi y qua chinh Router x 
                % Day la co che phan ung cua network
                % Ban dau kich hoat no khong chan gi ca ma cho den khi
                % mot Router hoc route quay nguoc lai chinh 
                % NextHop(v, y) == x la kich hoat 
                if USE_SPLIT_HORIZON && NextHop(v, y) == x
                    % Router v khong duoc phep quang ba Route do cho Router x
                    % Muc tieu giam vong lap
                    continue;
                end

                % ----- POISIONED REVERSE -----
                % Router v di toi y qua Router x
                % Khi Router v khi gui DV cua no den Router x 
                % Neu route toi y  
                if USE_POISONED_REVERSE && NextHop(v, y) == x
                    % Router v van quang ba nhung voi cost = ∞
                    advertised_cost = INFINITY;
                end

                % Chi phi moi cua Router x (theo cong thuc Bellman-Ford)
                % Router x dang nhin truc tiep vao cost(x, v) ma cost la
                % ma tran toan cuc, shared cho tat cac Router
                % Mat tinh thuc te cua DVR khi cai no cung cap chi la
                % niem tin moi trong khi dong nay no cung cap ca thong tin DV toan cuc

                % new_cost = cost(x, v) + advertised_cost; % Bellman-Ford ly tuong
                new_cost = DV(x, v) + advertised_cost; % Bellman-Ford phan tan
                old_cost = DV_new(x, y);

                % So sanh chi phi cu va moi (Bellman-Ford ly tuong)
                % de lay gia tri tot hon va sau do cap nhat bang dinh
                % tuyen (niem tin) moi cho cac Router 
                if new_cost < old_cost
                    DV_new(x, y) = new_cost; 
                    NextHop(x, y) = v; % Dat Router x toi y qua Router v

                % Con khong neu next hop cua x den y phai v va van phai chap nhan gia tri new_cost
                % co the lon hon old_cost
                elseif NextHop(x, y) == v && new_cost ~= old_cost
                    DV_new(x, y) = new_cost;
                end
            end
        end
    end
end