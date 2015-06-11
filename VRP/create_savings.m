function [ m_distances ] = create_savings( distances )
m_distances = tril(create_distances_and_savings(distances));
m_distances = m_distances';
for i = 1: length(m_distances)
    for j = 1: length(m_distances)
        if m_distances(i,j) == 0 && j~=i
            m_distances(j,i) = 10*eps;
        else
            m_distances(j,i) = m_distances(i,j);
        end
    end
end
end

