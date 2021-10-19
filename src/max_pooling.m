function [dst_img] = max_pooling(img,win_size)
fun = @(block_struct) max(block_struct.data(:));
X=win_size; Y=win_size; %window sizes
dst_img = blockproc (img, [X Y], fun);
end