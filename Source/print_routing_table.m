% Date: 2025/12/25
% LuongHuuPhuc
% brief: Hien thi bang dinh tuyen (Routing Table) cua tung Router
% trong thuat toan Distance Vector Routing
%
% Description: 
%   - In ra cost tu Router i den router j 
%   - In ra Router ke tiep (NextHop)
%   - Hien thi INF neu khong ton tai duong di
%
function print_routing_table(DV, NextHop, INFINITY)
    % Voi N Router trong mang
    N = size(DV, 1);

    % Duyet Router i tu 1 den N (Moi Router co 1 bang dinh tuyen rieng)
    for i = 1 : N
        fprintf('Router %d\r\n', i)
        % Duyet Router j dich (noi Router i can toi)
        for j = 1 : N
            % Khong xet toi chinh no
            if i ~= j
                % Neu khong co duong di (hoac bi dut do link-failure)
                if DV(i, j) >= INFINITY
                    fprintf(" -> %d | Cost = INF | NextHop = -\n", j);
                    
                % Neu co duong di hop le
                else
                    fprintf(" -> %d | Cost = %d | NextHop = %d\n", ...
                        j, DV(i, j), NextHop(i, j));
                end
            end
        end
    end
end