clear all;close all;fclose all;clc;

params = set_params;

% block_sizes_y = [8 8 16];
% block_sizes_x = [12 24 24];
% histogram_sizes = [8 16];

block_sizes_y = [8];
block_sizes_x = [24];
histogram_sizes = [8];

for c_cor_flag = [false, true]
    if c_cor_flag
        c_cor = '_colorcrc';
    else
        c_cor = '_orig';
    end
    for bs = 1:length(block_sizes_y)
        for overlap = [true]%[true, false]
            for nb = 1:length(histogram_sizes)
                num_bins = histogram_sizes(nb);

                bin_boundaries = linspace(0,256/255,num_bins+1);
                
                block_size = [block_sizes_y(bs) block_sizes_x(bs)];
                
                if overlap
                    step_size = block_size/2;
                    overlap_suffix = '_overlap';
                else
                    step_size = block_size;
                    overlap_suffix = '';
                end
                
                cell_boundaries_y = 0:step_size(1):params.im_size(1)-block_size(1);
                cell_boundaries_x = 0:step_size(2):params.im_size(2)-block_size(2);
                
                num_cells = [length(cell_boundaries_y), length(cell_boundaries_x)];
                
                for set_selection = ['a','b']
                    
                    suffix = sprintf('_y%d_x%d_b%d%s%s.mat', block_size(1), block_size(2), num_bins, overlap_suffix, c_cor);
                    
                    switch set_selection
                        case 'a'
                            if c_cor_flag, 
                                file_name = sprintf('cam_a_hsv%s.mat', c_cor);
                            else
                                file_name = 'cam_a_hsv.mat'; 
                            end
                                
                            set_to_process = fullfile(params.data_dir, file_name);
                            % set_to_process = params.all_viper_cam_a_hsv;
                            
                            images = load(set_to_process);
                            images = images.images_a_hsv;
                            target_file = sprintf('hsv_cam_a%s', suffix);
                        case 'b'
                            if c_cor_flag, 
                                file_name = sprintf('cam_b_hsv%s.mat', c_cor);
                            else
                                file_name = 'cam_b_hsv.mat'; 
                            end
                            
                            set_to_process = fullfile(params.data_dir, file_name);
                            % set_to_process = params.all_viper_cam_b_hsv;
                            
                            images = load(set_to_process);
                            images = images.images_b_hsv;
                            target_file = sprintf('hsv_cam_b%s', suffix);
                    end
                    
                    fprintf('Source: %s\n', set_to_process);
                    fprintf('Target: %s\n', target_file);
                    
                    target_path = fullfile(params.block_hist_dir, target_file);
                    
                    %crate the output structure
                    block_histograms = zeros(params.num_images, ...
                        num_cells(1), num_cells(2), ...
                        params.num_channels, num_bins);
                    
                    for b = 1:num_bins
                        fprintf('%d ', b);
                        cur_bin = double( (images >= bin_boundaries(b)) & ...
                            (images < bin_boundaries(b+1)) ) ;
                        for i = 1:num_cells(1),
                            for j = 1:num_cells(2),
                                y_lo = cell_boundaries_y(i)+1;
                                y_hi = cell_boundaries_y(i) + block_size(1);
                                
                                x_lo = cell_boundaries_x(j)+1;
                                x_hi = cell_boundaries_x(j) + block_size(2);
                                
                                sub_sum = sum(sum(cur_bin(:,y_lo:y_hi,x_lo:x_hi,:),2),3);
                                
                                block_histograms(:,i,j,:,b) = sub_sum;
                            end
                        end
                    end
                    fprintf('\n');
                    save(target_path, 'block_histograms');
                end
            end
        end
    end
end
