% this algorithm, for each particle on target will check whether or not it
% contains the head of th snake. 

clc
close all
clear all;

set(groot,'defaultfigureposition',[400 250 900 750])

%number of images in a folder
a = dir('snake/*.png');
noi = numel(a);

%number of particles
nop = 2000;
%first particles generation
particles = rand(nop,3);
particles = particles * [199 0 0; 0 199 0; 0 0 0];
particles(:,:) = int16(particles(:,:));
particles = (particles' + [ones(2,nop);zeros(1,nop)])';
target = 1;
meanSnake = zeros(2,1);
par2b = zeros(nop,3);
img_show = zeros(200,200);

end_pos=[0 0];
head_pos = [0 0];
prev_head = [0 0];

head_found = 0;

% gain = 100;
% measurement accuracy
% accuracy = 0.9;

for i = 1:noi
    %load the picture
    img = imread(join(['snake\snake_',sprintf( '%04d', i-1 ),'.png']));
    
    k = 1;
    meanSnake(:) = meanSnake(:).*(1/target).*2;
    meanSnake = uint16(meanSnake);
    max_target = target;
    
    % saving previous head position to check whether or not it is tracked
    prev_head = head_pos;
    
    % finding the head and creating particles
    if length(end_pos) == 3
        if uint16(img(end_pos(3,1), end_pos(3,2) ,1)) == 255
            head_pos = end_pos(3,:)
            head_found = 1;
        else
            head_pos = end_pos(2,:)
        end
        
        % if head found - place all the particles there
        for p = 1:2000 
            if ~(particles(p,1) == head_pos(1) && particles(p,2) == head_pos(2))
%            if particles(p,3) == 0
                    particles(p,:) = [head_pos 1];
            end
        end
        
    else    
        % create particles on snek if head not found - it is not perfect!!
        if target > 1
            while target > 1 
                if particles(k,3) == 0
                    particles(k,:) = par2b(max_target - target + 1,:);
                    %particles(k+1,:) = par2b(max_target - target + 2,:);
                    target = target - 1;
                end
                k = k + 1;
            end
        end
    end
    
       
    if length(end_pos) == 2 && head_found == 1
        head_pos = end_pos(2,:)
        
        % if head found - place all the particles there
        for p = 1:2000 
            if ~(particles(p,1) == head_pos(1) && particles(p,2) == head_pos(2))
%            if particles(p,3) == 0
                    particles(p,:) = [head_pos 1];
            end
        end
        

    end
    

        
    % coloring particles' pixels
    for k = 1:nop        
        img_show(particles(k,1),particles(k,2),1) = 0;
        img_show(particles(k,1),particles(k,2),2) = 0;
        img_show(particles(k,1),particles(k,2),3) = 255;
    end
    if head_found == 1
        img_show(head_pos(1), head_pos(2), 1) = 255;
        img_show(head_pos(1), head_pos(2), 2) = 255;
        img_show(head_pos(1), head_pos(2), 3) = 255;
    end
    
    % imshow
    if i > 1    
        imshow(img_show,'InitialMagnification','fit')
        truesize([400 400]);
    end
    
    % copy of an image to display the dots without altering the original
    % image
    img_show = img;
    
    target = 1;
    meanSnake(:) = [0 0];
    
    % head detection variables
    prev_end = zeros(2, int16(nop / 3 - 1));
    ends = 1;
    


    for k = 1:nop
        %prediction - moving a particle 1 random step
%         if meanSnake(1) == 0 && head_found == 0
            switch int8(rand(1,1)*4)
                case 0
                    if particles(k,1) < 200
                        particles(k,1) = particles(k,1) + 1;
                    else
                        particles(k,1) = 1;
                    end
                case 1 
                    if particles(k,1) > 1
                        particles(k,1) = particles(k,1) - 1;
                    else
                        particles(k,1) = 200;
                    end
                case 2 
                    if particles(k,2) < 200
                        particles(k,2) = particles(k,2) + 1;
                    else
                        particles(k,2) = 1;
                    end
                case 3
                    if particles(k,2) > 1
                        particles(k,2) = particles(k,2) - 1;
                    else
                        particles(k,2) = 200;
                    end
            end
%         elseif meanSnake(1) ~= 0 && head_found == 0
%             diff = [meanSnake(:); 0]' - uint16(particles(k,:));
%             % left
%             if diff(1) < 0
%                     if particles(k,1) < 200
%                         particles(k,1) = particles(k,1) + 1;
%                     else
%                         particles(k,1) = 1;
%                     end
%             % right    
%             elseif diff(1) > 0
%                     if particles(k,1) > 1
%                         particles(k,1) = particles(k,1) - 1;
%                     else
%                         particles(k,1) = 200;
%                     end
%             end
%             % top
%             if diff(2) < 0
%                     if particles(k,2) < 200
%                         particles(k,2) = particles(k,2) + 1;
%                     else
%                         particles(k,2) = 1;
%                     end
%             % botton    
%             elseif diff(2) > 0
%                     if particles(k,2) > 1
%                         particles(k,2) = particles(k,2) - 1;
%                     else
%                         particles(k,2) = 200;
%                     end
%             end
%         end    
        % scanning the map
        
        if img(particles(k,1),particles(k,2),1) == 255
            
            % checking if it is a head by summing red's value of pixels in
            % a cross pattern
            is_end = uint16(img(particles(k,1) + 1,particles(k,2),1)) + uint16(img(particles(k,1),particles(k,2) + 1,1)) + uint16(img(particles(k,1) - 1,particles(k,2),1)) + uint16(img(particles(k,1),particles(k,2) - 1,1));
            if(is_end == 255)
               prev_end(1, ends) = particles(k,1);
               prev_end(2, ends) = particles(k,2);
               ends = ends + 1;
            end    
                
            particles(k,3) = 1;
            
            if target < (nop / 3 - 1)
                par2b(target,:) = particles(k,:);
                par2b(target+1,:) = particles(k,:);
                target = target + 2;
                meanSnake(1) = meanSnake(1) + particles(k,1);
                meanSnake(2) = meanSnake(2) + particles(k,2);
                
            end
            
        else 
            particles(k,3) = 0; 
        end
        
    end
    
    % extracting the endpoints of a snake
    end_pos = unique(prev_end','rows');


    

end