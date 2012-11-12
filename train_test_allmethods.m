function [dists1,dists2, dists3, cmc1, cmc2, cmc3, M2, M3] = ...
    train_test_allmethods(split, feature_type, histeq_or_orig, num_pcs)
% [CMC1,CMC2,CMC3] = TRAIN_TEST_ALLMETHODS(SPLIT, FEATURE_TYPE, HISTEQ_OR_ORIG,
%   NUM_PCS)
%
%   Trains and tests 3 methods: 1) without learning, 2) large-margin NN,
%   3) large-margin NN w/ rejection.     
% 
%   SPLIT is a structure with fields "train_ind", "test_ind" and "ab". 
%   FEATURE_TYPE is one of "rgb", "hsv", or "rgb+hsv".
%   HISTEQ_OR_ORIG is either "colorcrc" or "orig".
%   NUM_PCS is the number of principal components used for dimension reduction. 
%

t0 = clock;

params = set_params;

% load the data:
if strcmp(feature_type, 'rgb') || strcmp(feature_type, 'hsv')
    load(fullfile(params.block_hist_dir, ...
        sprintf('%s_cam_a_y8_x24_b8_overlap_%s.mat', feature_type, ...
        histeq_or_orig)));
    set_a = block_histograms;

    load(fullfile(params.block_hist_dir, ...
        sprintf('%s_cam_b_y8_x24_b8_overlap_%s.mat', feature_type, ...
        histeq_or_orig)));
    set_b = block_histograms;
elseif strcmp(feature_type, 'rgb+hsv')
    load(fullfile(params.block_hist_dir, ...
        sprintf('rgb_cam_a_y8_x24_b8_overlap_%s.mat', histeq_or_orig)));
    h1 = block_histograms;
    load(fullfile(params.block_hist_dir, ...
        sprintf('hsv_cam_a_y8_x24_b8_overlap_%s.mat', histeq_or_orig)));
    h2 = block_histograms;
    set_a = cat(5, h1, h2);

    load(fullfile(params.block_hist_dir, ...
        sprintf('rgb_cam_b_y8_x24_b8_overlap_%s.mat', histeq_or_orig)));
    h1 = block_histograms;
    load(fullfile(params.block_hist_dir, ...
        sprintf('hsv_cam_b_y8_x24_b8_overlap_%s.mat', histeq_or_orig)));
    h2 = block_histograms;
    set_b = cat(5, h1, h2);
else
    error('Unknown feature type: %s\n',feature_type);
end


set_a = set_a(1:end,:);
set_b = set_b(1:end,:);


% do cam_a, cam_b assignments
for i=1:size(set_a,1)
    if ~split.ab(i)
        tmp = set_a(i,:);
        set_a(i,:) = set_b(i,:);
        set_b(i,:) = tmp;
    end
end

set_a_tr = set_a(split.train_ind,:,:,:,:);
set_b_tr = set_b(split.train_ind,:,:,:,:);

train_size = size(set_a_tr);

set_a_tr = reshape(set_a_tr, train_size(1), prod(train_size(2:end)));
set_b_tr = reshape(set_b_tr, train_size(1), prod(train_size(2:end)));

train_labels = [1:train_size(1), 1:train_size(1)];
train_set = [set_a_tr;set_b_tr];

data_mean = mean(train_set,1);

train_set = train_set - repmat(data_mean, [train_size(1)*2, 1]);

options.ReducedDim = num_pcs;
[evec, eval, elapse] = PCA(train_set, options);

train_set = (train_set*evec);

mags = sum(abs(train_set),2);

train_set = train_set / max(mags);
% % reduce dimension
% train_set = [set_a(split.train_ind,:) ; set_b(split.train_ind,:)];
% options.ReducedDim = num_pcs;
% [evec, eval, elapse] = PCA(train_set - repmat(mean(train_set), ...
%         size(train_set,1), 1), options);
% set_a = (set_a - repmat(mean(train_set), size(set_a,1), 1))*evec; 
% set_b = (set_b - repmat(mean(train_set), size(set_a,1), 1))*evec; 
% %[pcs, projected, eigvalues] = princomp(train_set);
% %set_a = (set_a - repmat(mean(train_set), size(set_a,1), 1))*pcs(:,1:num_pcs); 
% %set_b = (set_b - repmat(mean(train_set), size(set_a,1), 1))*pcs(:,1:num_pcs); 
% 
% % scale data
% mags = sum(abs(train_set),2);
% norm_const = max(mags);
% set_a = set_a / norm_const;
% set_b = set_b / norm_const;
% 
% 
% 
% 
%% METHOD 1: without learning
norm_const = max(mags);

set_a_te = set_a(split.test_ind,:,:,:,:);
set_b_te = set_b(split.test_ind,:,:,:,:);

test_size = size(set_a_te);

set_a_te = reshape(set_a_te, test_size(1), prod(test_size(2:end)));
set_b_te = reshape(set_b_te, test_size(1), prod(test_size(2:end)));

set_a_te = set_a_te - repmat(data_mean, [test_size(1), 1]);
set_b_te = set_b_te - repmat(data_mean, [test_size(1), 1]);

set_a_te = set_a_te * evec;
set_b_te = set_b_te * evec;

dists1 = pw_dist_ssd(set_a_te, set_b_te);
cmc1 = get_rank_curve(dists1);


%% METHOD 2: large margin NN
% trainset = [set_a(split.train_ind,:) ; set_b(split.train_ind,:)];
% labels = [1:length(split.train_ind) , 1:length(split.train_ind)];
M = learn_full_M_faster(train_set, train_labels,eye(num_pcs),2,0);


[V,D] = eig(M);
L = sqrt(D)*V';

norm_const = max(mags);

set_a_te = set_a(split.test_ind,:,:,:,:);
set_b_te = set_b(split.test_ind,:,:,:,:);

test_size = size(set_a_te);

set_a_te = reshape(set_a_te, test_size(1), prod(test_size(2:end)));
set_b_te = reshape(set_b_te, test_size(1), prod(test_size(2:end)));

set_a_te = set_a_te - repmat(data_mean, [test_size(1), 1]);
set_b_te = set_b_te - repmat(data_mean, [test_size(1), 1]);

set_a_te = set_a_te * evec;
set_b_te = set_b_te * evec;

set_a_te = L*set_a_te';
set_b_te = L*set_b_te';

dists2 = pw_dist_ssd(set_a_te', set_b_te');
figure();
cmc2 = get_rank_curve(dists2);
plot(cmc2);
grid()
% 
% [V,D] = eig(M);
% L = sqrt(D)*V';
% set_a_te = (L*set_a(split.test_ind,:)')';
% set_b_te = (L*set_b(split.test_ind,:)')';
% dists2 = pw_dist_ssd(set_a_te, set_b_te);
% cmc2 = get_rank_curve(dists2);
M2 = M;


%% METHOD 3: large margin NN
% trainset = [set_a(split.train_ind,:) ; set_b(split.train_ind,:)];
% labels = [1:length(split.train_ind) , 1:length(split.train_ind)];
M = learn_full_M_rejection(train_set, train_labels, eye(num_pcs),2,0);
% [V,D] = eig(M);
% L = sqrt(D)*V';
% set_a_te = (L*set_a(split.test_ind,:)')';
% set_b_te = (L*set_b(split.test_ind,:)')';
% dists3 = pw_dist_ssd(set_a_te, set_b_te);
% cmc3 = get_rank_curve(dists3);
M3 = M;


[V,D] = eig(M);
L = sqrt(D)*V';

norm_const = max(mags);

set_a_te = set_a(split.test_ind,:,:,:,:);
set_b_te = set_b(split.test_ind,:,:,:,:);

test_size = size(set_a_te);

set_a_te = reshape(set_a_te, test_size(1), prod(test_size(2:end)));
set_b_te = reshape(set_b_te, test_size(1), prod(test_size(2:end)));

set_a_te = set_a_te - repmat(data_mean, [test_size(1), 1]);
set_b_te = set_b_te - repmat(data_mean, [test_size(1), 1]);

set_a_te = set_a_te * evec;
set_b_te = set_b_te * evec;

set_a_te = L*set_a_te';
set_b_te = L*set_b_te';

dists3 = pw_dist_ssd(set_a_te', set_b_te');
figure();
cmc3 = get_rank_curve(dists3);
plot(cmc3);
grid()



fprintf('Elapsed time: %.2f seconds',etime(clock, t0));

fprintf('method 1, CMC@50: %.3f\n', cmc1(50));
fprintf('method 2, CMC@50: %.3f\n', cmc2(50));
fprintf('method 3, CMC@50: %.3f\n', cmc3(50));
