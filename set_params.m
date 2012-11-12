function [params] = set_params()

params.source_dir = pwd();

%params.emd_code_path = fullfile(params.source_dir, 'emd');

params.root_dir = fullfile(params.source_dir, '..'); %'/home/mert/Research/pedestrian_match/';

params.data_dir = fullfile(params.root_dir, 'VIPeR');
params.result_dir = fullfile(params.root_dir, 'results');
params.other_dir = fullfile(params.root_dir, 'other');
params.batch_dir = fullfile(params.root_dir, 'batch_results');
params.kernel_dir = fullfile(params.root_dir, 'kernels');
params.kernel_result_dir = fullfile(params.root_dir, 'kernel_training');

%feature related
params.clust_hist_dir = fullfile(params.root_dir, 'clust_hist');
params.segments_dir = fullfile(params.root_dir, 'segments');
params.features_dir = fullfile(params.root_dir, 'features');

params.block_hist_dir = fullfile(params.root_dir, 'block_hist');
params.bw_dist_dir = fullfile(params.root_dir, 'blockwise_distances');

params.image_list_file_a = fullfile(params.data_dir, 'cam_a.lst');
params.image_list_file_b = fullfile(params.data_dir, 'cam_b.lst');

params.image_list_a = read_list(params.image_list_file_a, params.data_dir);
params.image_list_b = read_list(params.image_list_file_b, params.data_dir);

params.all_viper_cam_a = fullfile(params.data_dir, 'cam_a.mat');
params.all_viper_cam_b = fullfile(params.data_dir, 'cam_b.mat');

params.all_viper_cam_a_hsv = fullfile(params.data_dir, 'cam_a_hsv.mat');
params.all_viper_cam_b_hsv = fullfile(params.data_dir, 'cam_b_hsv.mat');

params.all_viper_cam_a_hehsv = fullfile(params.data_dir, 'cam_a_hehsv.mat');
params.all_viper_cam_b_hehsv = fullfile(params.data_dir, 'cam_b_hehsv.mat');

params.num_images = length(params.image_list_a);
params.im_size = [128, 48];
params.num_channels = 3;

load(fullfile(params.other_dir, 'train_ind.mat'));
load(fullfile(params.other_dir, 'test_ind.mat'));
params.train_ind = train_ind;
params.test_ind = test_ind;

params.num_train = length(train_ind);
params.num_test = length(test_ind);

params.smooth_hinge_gamma = 100;

end

function [list] = read_list(filename, base_path)

    list = {};

    fid = fopen(filename);
    counter = 1;
    
    this_line = fgetl(fid);
    list{counter} = fullfile(base_path,this_line);
    
    while ~feof(fid)
        counter = counter+1;
        this_line = fgetl(fid);
        list{counter} = fullfile(base_path,this_line);
    end

    fclose(fid);
end