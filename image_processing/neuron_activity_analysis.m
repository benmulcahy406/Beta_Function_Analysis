%% Clear everything

clear; close all;

%% Load images

% Load tiff files
setup_proof_reading;
fprintf('tiff files loading finished. \n');

%% Register channels without existing geometric transformation object

close all;
figure; set(gcf, 'units', 'normalized',...
    'outerposition', [0.1 0.1 0.8 0.8]);
subplot(1,2,1); 
imshowpair(imagelist_g{1,1}, imagelist_r{1,1});
image_registration_tform; 
subplot(1,2,2); 
imshowpair(movingRegistered{1,1}, imagelist_r{1,1});
title('Press return to continue...');
pause;
close all;

save([filename(1:end-4) '_tform.mat'],...
    'tform', 'optimizer', 'metric');

fprintf('registration completed, transformation object saved. \n');

%% Register channels with existing geometric transformation object

transform = uigetfile('.mat', ...
    'Select geometric transformation object');
load(transform, 'tform');

movingRegistered = imagelist_g;
imagelistRegistered = imagelist;
for i = 1:size(imagelist_r, 1)
    
    movingRegistered{i} = imwarp(imagelist_g{i},tform,'OutputView',imref2d(size(imagelist_g{i})));
    imagelistRegistered{i,1} = [imagelist_r{i} movingRegistered{i}];
    
end

fprintf('registration completed. \n');

%% Track neuron and generate signal

imagelist = imagelistRegistered;
proof_reading(imagelist, [], filename, ...
    istart, iend, 1);

% %% Save data
% 
% prompt = {'Neuron analyzed just now: '};
% dlgtitle = ['Neuron name for ' filename];
% dims = [1 35];
% definput = {''};
% answer = inputdlg(prompt,dlgtitle,dims,definput);
% neuronname = answer{1};
% if isempty(neuronname)
%     data_path_end = [filename(1:end-4) '.mat'];
% else
%     data_path_end = [neuronname '_' filename(1:end-4) '.mat'];
% end
% 
% parts = strsplit(pathname, '\');
% data_path = fullfile(parts{1,1:end-3}, 'Alpha_Data_Raw', parts{1,end-1});
% warning('off'); mkdir(data_path);
% 
% data_path_name = fullfile(data_path, data_path_end);
% save(data_path_name, ...
%     'signal', 'signal_mirror', 'ratio', 'neuron_position_data', 'dual_position_data');
% 
% fprintf([data_path_end ' data saved. \n']);

%% Curvature analysis with three points

curvature_pts;

%% Write registered tiff file

for i = 1:length(imagelist)
    if i==1
        imwrite(imagelist{i,1}, [filename(1:end-4) '_reg.tif']);
    else
        imwrite(imagelist{i,1}, [filename(1:end-4) '_reg.tif'], 'writemode', 'append');
    end
end

fprintf('registered recording saved. \n');