function plot_network_analysis(cost_before, cost_after, cost_final, cost_history)

    figure('Name', "Distance Vector Routing Analysis", 'NumberTitle', 'off');

    %% ===== SUBPLOT 1: TOPLOLOGY TRUOC LINK FAILURE =====
    subplot(2, 2, 1);
    plot_topology(cost_before);
    title('Topology Before Link Failure');

    %% ===== SUBPLOT 2: TOPOLOGY SAU LINK FAILURE =====
    subplot(2, 2, 2);
    if isempty(cost_after)
        title('Topology After Link Failure (No failure yet)');
    else
        plot_topology(cost_after);
        title('Topology After Link Failure');
    end

    %% ===== SUBPLOT 3: SHORTEST PATH
    subplot(2, 2, 3);
    plot_shortest_path(cost_final, 1, size(cost_final, 1));
    title('Shortest Path (1 → N)');

    %% ==== SUBPLOT 4: CONVERGENCE 
    subplot(2, 2, 4);
    plot(cost_history, '-o', 'LineWidth', 2); 
    grid on; 
    xlabel('Iteration');
    ylabel('Total Network Cost');
    title('Distance Vector Convergence');
end