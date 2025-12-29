function plot_topology(cost)
    % Chuyen cost = Inf thanh 0 de tao graph
    adj = cost; 
    adj(adj == Inf) = 0;

    % Tao do thi vo huong 
    G = graph(adj, "upper");

    figure; 
    p = plot(G, 'Layout', 'force', 'LineWidth', 1.5);
    title('Network Topology');
    xlabel('Router');
    ylabel('Router');

    % Hien thi cost tren link 
    if ~isempty(G.Edges)
        labeledge(p, G.Edges.EndNodes(:, 1), ...
                     G.Edges.EndNodes(:, 2), ...
                     string(G.Edges.Weight));
    end

end