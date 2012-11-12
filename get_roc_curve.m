function [roc_curve] = get_roc_curve(distance_mat)

	sample_points = 200;

	num_vecs = size(distance_mat,1);

	min_distance = min(distance_mat(:));
	max_distance = max(distance_mat(:));
	
	thresholds = linspace(min_distance,max_distance,sample_points);

	mask = eye(num_vecs) > 0; 

	tp_rate = zeros(sample_points,1);
	fp_rate = zeros(sample_points,1);

	for tc = 1:sample_points,
		t=thresholds(tc);
		lessthan_t = distance_mat < t;	
		tp_rate(tc) = sum(diag(lessthan_t))/size(distance_mat,1);

		lessthan_t(mask) = 0;

		fp_rate(tc) = sum(lessthan_t(:)) / num_vecs / (num_vecs - 1);
	end

	roc_curve = [tp_rate, fp_rate];

end
