function [rank_curve] = get_rank_curve(distance_mat)

[sorted_dist, dist_indexes] = sort(distance_mat, 2);

rank_mat = zeros(size(distance_mat));

for i = 1:length(distance_mat),
    cur_rank = find(dist_indexes(i,:) == i);
    rank_mat(i, cur_rank) = 1;
end

rank_curve = cumsum(sum(rank_mat) / length(distance_mat));


end