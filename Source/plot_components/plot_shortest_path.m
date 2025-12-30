% Minh hoa ket qua dinh tuyen cho duong di ngan nhat
function plot_shortest_path(cost, src, dst, ax)
    adj = cost; 
    adj(adj == Inf) = 0;
    
    G = graph(adj, 'upper');
    
    cla(ax);
    p = plot(G, 'Layout', 'circle', 'LineWidth', 1.2);
    
    if src ~= dst && numnodes(G) >= max(src, dst)
        [path, dist] = shortestpath(G, src, dst);
    
        if ~isempty(path)
            highlight(p, path, 'LineWidth', 3, 'EdgeColor', 'red');
            text(ax, 0.05, 0.05, ...
                sprintf('Cost = %d', dist), ...
                'Units','normalized', 'FontSize', 10);
        else
            text(ax, 0.05, 0.05, 'No path', 'Units', 'normalized');
        end
    end
end