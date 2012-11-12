function M = learn_full_M(data, labels, M, alpha, visual)

if nargin<3
    visual = false;
end

% weight of E_push. (E_pull's weight is 1-mu)
mu = 0.5;

% learning rate
%alpha = 1e-5; 

% tolerance on the difference of loss values. used for convergence
tol = 1e-2;

num_images = size(data,1);
num_dims = size(data,2);

% initial weights
diffloss = Inf;

if visual
    h = figure;
    h2 = figure;
end

loss = zeros(500,1);
avg_target_ranks = zeros(500,1);

iter = 0;

mean_data = mean(data,1);

while diffloss > tol
    iter = iter + 1;
    avg_target_ranks(iter) = 0;
    loss(iter) = 0;

    % compute pairwise distances
    [V,D] = eig(M);
    L = sqrt(D)*V';
    dists = pdist((L*data')').^2;
    dists = squareform(dists);

	target_idx = zeros(num_images,1);
	mean_dist_to_target = 0;
	mean_outer = zeros(num_dims);
	for i = 1:num_images,
		not_me = (1:num_images ~= i);
		% find the target 
		target_idx(i) = find( (labels==labels(i)) & not_me)  ;
		mean_dist_to_target = mean_dist_to_target + dists(i,target_idx(i))/num_images;

        tmp = data(i,:)' - data(target_idx(i),:)';
        trgt = tmp*tmp';
		mean_outer = mean_outer + trgt / num_images;
	end

    grdnt = zeros(size(M));
    for i=1:num_images
		not_me = (1:num_images ~= i);
        % distance to target
        dist_to_target = dists(i,target_idx(i));

        loss(iter) = loss(iter) + dist_to_target;

        tmp = data(i,:)' - data(target_idx(i),:)';
        trgt = tmp*tmp';
        grdnt = grdnt + (1-mu)*trgt;

        % find impostors (those that violate the hinge loss)
        impostors = find((dists(i,:) <= mean_dist_to_target + 1) & not_me);
		num_impostors = length(impostors);

        avg_target_ranks(iter) = avg_target_ranks(iter) + sum(dists(i,:)<dist_to_target);

		tmp = bsxfun(@minus, data(impostors,:), data(i,:));
		impst = tmp'*tmp;
		
		grdnt = grdnt + mu*(num_impostors * mean_outer - impst);

		loss(iter) = loss(iter) + num_impostors*(1 + mean_dist_to_target) - trace(M*impst);
	end
    % update M
    M_new = M - alpha*grdnt;

    % M must remain positive semidefinite
    positive_const = 0;

	%keyboard;

    while true 
		[V,D] = eig(M_new);
        D(D<0) = positive_const;
        
        % project
        M = V*D*V';
		M = ( M + M' ) / 2;
        [V,D] = eig(M);

        % check sanity. if any eigvalue is negative, increase the positive_const
        if any(diag(D)<0) || any(~isreal(D(:)))
            positive_const = positive_const + 1e-10;
        else 
            break;
        end
		%fprintf('positive const: %g\n', positive_const);
    end
    
    if iter>=2
        if loss(iter)<loss(iter-1)
            alpha = 1.01*alpha;
        else
            alpha = 0.7*alpha;
        end

        diffloss = abs(loss(iter) - loss(iter-1));
    end
    
    if visual
        figure(h);
        subplot(1,2,1),plot(avg_target_ranks(1:iter)/num_images), grid, ...
                title('Average rank of the target');
        subplot(1,2,2),plot(loss(1:iter)), grid, ...
                title(sprintf('loss diffence: %f alpha: %f',diffloss, alpha));
        xlabel(sprintf('loss: %f', loss(iter)));
        figure(h2)
		imshow(M,[], 'InitialMagnification','fit')
        drawnow
    end
    fprintf('iter %03d: avg_target_rank: %.2f  loss: %e   loss difference: %e  alpha: %e\n', ...
                iter, avg_target_ranks(iter)/num_images, loss(iter), diffloss, alpha);

	%if iter > 100 
	%	break
	%end
end
