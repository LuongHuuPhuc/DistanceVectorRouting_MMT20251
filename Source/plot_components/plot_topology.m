function plot_topology(cost, ax, titleStr)
    % Chuyen cost = Inf thanh 0 de tao graph
    adj = cost; 
    adj(adj == Inf) = 0;

    % Tao do thi vo huong 
    G = graph(adj, "upper");

    cla(ax); % Xoa noi dung cu tren subplot
    p = plot(G, 'Layout', 'force', 'LineWidth', 1.5);
    title(ax, titleStr);

    % Hien thi cost tren link 
    if numedges(G) > 0
        edgeIDs = 1 : numedges(G);
        labeledge(p, edgeIDs, string(G.Edges.Weight));
    end
end