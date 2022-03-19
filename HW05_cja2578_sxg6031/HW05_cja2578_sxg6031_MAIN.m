function HW05_cja2578_sxg6031_MAIN( )
    % Main function for program.

    % addpath( '../TEST_IMAGES' ); This line wont' work for some reason
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
    % Finds the number of dice in an image and the number of dots on each
    % dice.

    im_orig = im2double( imread( filename ) );
    dims_orig   = size(im_orig);
    if(dims_orig(1) > dims_orig(2))
        im_orig = imrotate(im_orig, -90);
    end

    % Noise removal via Gaussian filtering
    fltr        = fspecial( 'gauss', [15 15], 1.5 );
    im_orig        = imfilter( im_orig, fltr, 'same', 'repl' );

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
    
    % Show the original image:
    figure();
    imagesc( im_orig );
    axis image; 		% Make the pixels square.

    % For every single dice increate a cyan box around it and
    % count the spots on each
    total_num_dots = 0;
    ones = 0;
    twos = 0;
    threes = 0;
    fours = 0;
    fives = 0;
    sixes = 0;
    unknowns = 0;
    num_dots_arr = zeros(1, num_dice);
    for idx = 1:num_dice  % could also use length(stats)
       
        % Get each region/dice using label matrix from bwlablel.
        dice = ismember(label_matrix, idx);

        % Perform bwlabel again, but this time you need to invert the dice
        % to get the number of newly-white dots separated by black.
        [~, num_dots] = bwlabel(~dice);

        % You need to decrement the number of dots by 1 because it includes
        % the dice as a white blob as well
        total_num_dots = total_num_dots + num_dots - 1;

        % For histogram purposes
        num_dots_arr(idx) = num_dots-1;
        switch num_dots_arr(idx)
            case 1
                ones = ones + 1;
            case 2 
                twos = twos + 1;
            case 3 
                threes = threes + 1;
            case 4 
                fours = fours + 1;
            case 5
                fives = fives + 1;
            case 6
                sixes = sixes + 1;
            otherwise
                unknowns = unknowns + 1;
        end

        %The first 2 elements are the coordinates of the minimum corner of 
        % the box. The second 2 elements are the size of the box along 
        % each dimension.
        coordinates = stats(idx).BoundingBox;

        % Using coordinates, we can calculate the xy points of the box we
        % want to draw
        xs = [coordinates(1), coordinates(1) + coordinates(3), ...
              coordinates(1) + coordinates(3), coordinates(1), ...
              coordinates(1)];
        ys = [coordinates(2), coordinates(2), ...
              coordinates(2) + coordinates(4), ...
              coordinates(2) + coordinates(4), coordinates(2)];
        hold on;
        plot( xs, ys, 'c-', 'LineWidth', 1 );
    end
    Fr = getframe( );
    imwrite( Fr.cdata, strcat('output_', filename));
    figure;
    hgram = histogram(num_dots_arr); % plot the histogram
                

    % Output 
    fprintf('INPUT Filename:\t\t%s\n', filename);
    fprintf('Number of Dice:\t\t%d\n', num_dice);
    fprintf('Number of 1''s:\t\t%d\n', ones);
    fprintf('Number of 2''s:\t\t%d\n', twos);
    fprintf('Number of 3''s:\t\t%d\n', threes);
    fprintf('Number of 4''s:\t\t%d\n', fours);
    fprintf('Number of 5''s:\t\t%d\n', fives);
    fprintf('Number of 6''s:\t\t%d\n', sixes);
    fprintf('Number of Unknown:\t%d\n', unknowns);
    fprintf('Total of all dots:\t%d\n', total_num_dots);

end