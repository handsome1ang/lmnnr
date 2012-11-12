function [distances_ssd] = pw_dist_ssd(set_a, set_b)

verbose = 0;

num_a = size(set_a,1);
num_b = size(set_b,1);

distances_ssd = inf(num_a,num_b);

for ac = 1:num_a
	if verbose
   		fprintf('%d ', ac);
	end
    for bc = 1:num_b
        pw_diff = sum( (set_a(ac,:) - set_b(bc,:) ) .^2 );
        dist = sqrt(pw_diff);
        distances_ssd(ac,bc) = dist;
    end
end

end
