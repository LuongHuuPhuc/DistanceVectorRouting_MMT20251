% File dinh nghia Topology cua 3 Router nham muc dich 
% tai hien lai ro hon co che cua Poison Reverse
function [cost] = init_topology_3nodes(numNodes)
    INFINITY = Inf;
    cost = INFINITY * ones(numNodes);

    for i = 1:numNodes
        cost(i,i) = 0;
    end

    % ===== TOPOLOGY 3 NODE LINE =====
    % 1 -- 2 -- 3
    links = [
        1 2 1;
        2 3 1;
    ];

    for k = 1:size(links,1)
        i = links(k,1);
        j = links(k,2);
        w = links(k,3);
        cost(i,j) = w;
        cost(j,i) = w;
    end
end
