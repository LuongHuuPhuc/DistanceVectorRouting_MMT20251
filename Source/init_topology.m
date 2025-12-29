% Date: 2025/12/25
% LuongHuuPhuc
% brief: Chuc nang: Khoi tao Topo mang voi so Node co the thay doi
% Chi khai bao nhung link ton tai
% params:
% + numNodes: So Node trong trong network
% retval:
% + cost: "chi phi" de qua lai giua cac Node trong link
% thuat toan luon chon duong co tong cost nho nhat
%
function [cost] = init_topology(numNodes)
    INFINITY = Inf;
    cost = INFINITY * ones(numNodes);

    % Cost cua chinh no bang 0
    for i = 1 : numNodes
        cost(i, i) = 0;
    end


    % Danh sach cac lien ket (links) trong network
    % Moi dong mo ta "node nao noi den node nao" va ton bao nhieu "cost"
    % Muon mo rong bao nhieu node cung duoc
    %       [from - to - cost]
    links = [ 1 2 1;
              1 3 4;
              2 3 2;
              2 4 6;
              3 4 3;
              4 5 2;
              5 6 1;
            ];

    % Cho k duyet tung links co kich thuoc 1D
    for k = 1 : size(links, 1)
        i = links(k, 1);  % Node dau
        j = links(k, 2);  % Node cuoi
        w = links(k, 3);  % cost

        % Gia tri cost dau ra khi duyet
        cost(i, j) = w;
        cost(j, i) = w;  % Mang vo huong
    end
end
