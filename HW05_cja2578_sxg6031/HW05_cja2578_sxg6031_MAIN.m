function HW05_cja2578_sxg6031_MAIN( )
    % Main function for program.

%     addpath( '../TEST_IMAGES' ); This line wont' work for some reason
    cd ../TEST_IMAGES/;
    % Find all files that match this regular expression:
    file_list = dir('*.jpg');
    for counter = 1 : length( file_list )
        fn = file_list(counter).name;
        find_dice_and_dots( fn );
    end
    cd ../HW05_cja2578_sxg6031/;
    
end 


function find_dice_and_dots( filename )

    im_orig = im2double( imread( filename ) );
    dims_orig   = size(im_orig);
    if(dims_orig(1) > dims_orig(2))
        im_orig = imrotate(im_orig, -90);
    end

    % Convert to binary image but first convert to grayscale (red channel
    % by itself is grayscale)
    im_binary = imbinarize(im_orig(:, :, 1));

    % Perform opening on the binary image
    se = strel('disk', 10);       
    im_open = imopen( im_binary, se);
    
    % Performs connected component analysis. It labels the white regions 
    % that are separated by black.
    [label_matrix, num_dice] = bwlabel(im_open);

    % Given a black and white image it automatically determines the 
    % properties of each contiguous white region that is 8-connected.
    % One of these particular properties is the centroid. This is 
    % also the centre of mass. Another one is Bounding Box
    stats = regionprops(im_open, 'BoundingBox');
    
    % Show the image after opening:
    figure;
    colormap(gray);
    imagesc( im_open );
    
    % Show the original image:
    figure();
    imagesc( im_orig );
    axis image; 		% Make the pixels square.

    % For every single dice in the image create a cyan box around it and
    % count the spots on each
    total_num_dots = 0;
    for idx = 1:num_dice  % could also use length(stats)
        dice = ismember(label_matrix, idx);
        [~, num_dots] = bwlabel(~dice);
        total_num_dots = total_num_dots + num_dots - 1;
        coordinates = stats(idx).BoundingBox;
        xs = [coordinates(1), coordinates(1) + coordinates(3), coordinates(1) + coordinates(3), coordinates(1), coordinates(1)];
        ys = [coordinates(2), coordinates(2), coordinates(2) + coordinates(4), coordinates(2) + coordinates(4), coordinates(2)];
        hold on;  
        plot( xs, ys, 'c-', 'LineWidth', 1 );
    end
    Fr = getframe( );
    imwrite( Fr.cdata, strcat('output_', filename));


end