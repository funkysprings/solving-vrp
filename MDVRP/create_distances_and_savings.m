function [ m_dist_saves ] = create_distances_and_savings( matrix_distances )
dim = length(matrix_distances);
m_dist_saves = matrix_distances;
for i = 1:dim
    for j = 1:dim
        if i == j || i > j
            continue;
        else
            m_dist_saves(i, j) = matrix_distances(1, i) + matrix_distances(1, j) - matrix_distances(i, j);
            if m_dist_saves(i, j) < 0
                m_dist_saves(i, j) = 0;
            end
        end
    end
end
m_dist_saves = m_dist_saves';
end

