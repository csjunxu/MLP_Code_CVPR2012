
%--------------------------------------------------------------------------
clc;
clear;

addpath model;
setname          = 'Real_NoisyImage';
method           =  'MLP';
ref_folder       =  fullfile('C:\Users\csjunxu\Desktop\CVPR2017\1_Results\',setname);

den_folder       =  ['Results_',setname,'_',method];
if ~isdir(den_folder)
    mkdir(den_folder)
end

noise_levels     =  [10];
images           =  dir(fullfile(ref_folder,'*.png'));
format compact;

for i = 1 : numel(images)
    [~, name, exte]  =  fileparts(images(i).name);
    IM =   double(imread( fullfile(ref_folder,images(i).name) ));
    [h,w,ch] = size(IM);
    % color or gray image
    for j = 1 : numel(noise_levels)
        disp([i,j]);
        nSig               =    noise_levels(j);
        model = {};
        % width of the Gaussian window for weighting output pixels
        model.weightsSig = 2;
        % the denoising stride. Smaller is better, but is computationally
        % more expensive.
        model.step = 3;
        IMout = zeros(size(IM));
        for c = 1:ch
            %% denoising
            IMoutcc = fdenoiseNeural(IM(:,:,c), nSig, model);
            IMout(:,:,c) = IMoutcc;
        end
        imwrite(IMout/255, ['C:/Users/csjunxu/Desktop/ICCV2017/1nc_Results/Real_' method '/' method '_Real_' num2str(noise_levels) '_' name '.png']);
    end
end


