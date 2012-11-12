clear all;close all;fclose all;clc;

params = set_params; 

source_file = fullfile(params.data_dir,'cam_a.mat');
fprintf('reading: %s\n', source_file);
load(source_file,'-mat');

source_file = fullfile(params.data_dir,'cam_b.mat');
fprintf('reading: %s\n', source_file);
load(source_file,'-mat');

for i = 1:params.num_images,
    for j = 1:3,
        images_a(i,:,:,j) = histeq(squeeze(images_a(i,:,:,j)/255))*255;
        images_b(i,:,:,j) = histeq(squeeze(images_b(i,:,:,j)/255))*255;
    end
end

target_file = fullfile(params.data_dir, 'cam_a_colorcrc.mat');
fprintf('writing: %s\n', target_file);
save(target_file,'images_a');

target_file = fullfile(params.data_dir, 'cam_b_colorcrc.mat');
fprintf('writing: %s\n', target_file);
save(target_file,'images_b');