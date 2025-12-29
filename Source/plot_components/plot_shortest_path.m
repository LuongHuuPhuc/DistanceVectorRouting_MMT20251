% Minh hoa ket qua dinh tuyen cho duong di ngan nhat
function plot_shotest_path(cost, src, dst)
adj = cost; 
adj(adj == Inf) = 0;

G = graph(adj, 'upper');
[path, dist] = shortestpath(G, src, dst);

p = plot(G, 'Layout', 'force');
highlight(p, path, 'EdgeColor', 'r', 'LineWidth', 3);

text(0.05, 0.05, ...
    sprintf('Cost = %d', dist), ...
    'Units','normalized', 'FontSize', 10);

end