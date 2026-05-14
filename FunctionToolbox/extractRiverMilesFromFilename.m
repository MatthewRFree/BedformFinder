function riverMiles = extractRiverMilesFromFilename(filename)
% EXTRACTRIVERMILESFROMFILENAME Extracts the start and end river mile
%   EXTRACTRIVERMILESFROMFILENAME takes a filename from a survey and
%   returns the River Mile start and end information that it finds based on
%   preformatted strings.
%
%   RIVERMILES = EXTRACTRIVERMILESFROMFILENAME(FILENAME) takes a filename
%   FILENAME and returns the two river miles RIVERMILES.
%
%   Other Functions Referenced:
%       regexp(...), find(...), cellfun(...), length(...), isempty(...),
%       floor(...), mod(...), str2double(...), error(...)
%
%
% -- Matthew Free 07/2025 --


%% Arguments
    arguments
        filename string
    end

%% Extract Numbers
    % Get all numbers
        numbers = regexp(filename, '\d+', 'match');

    % Find when the date occurs and take numbers after
        dateIndex = find(cellfun(@(x) length(x) == 8, numbers), 1, 'first');
        if isempty(dateIndex)
            riverMiles = [nan,nan];
            return
        end
        numbers = numbers(dateIndex+1:end);

    % One Eight digit RM
    if length(numbers{1}) == 8
        numbers = numbers{1};
        firstNumber = str2double(numbers(1:4));
        secondNumber = str2double(numbers(5:8));
        riverMiles = [floor(firstNumber/10) + mod(firstNumber,10)/10, floor(secondNumber/10) + mod(secondNumber,10)/10];

    % Two Four digit RM
    elseif length(numbers{1}) == 4
        firstNumber = str2double(numbers{1});
        secondNumber = str2double(numbers{2});
        riverMiles = [floor(firstNumber/10) + mod(firstNumber,10)/10, floor(secondNumber/10) + mod(secondNumber,10)/10];

    % Four Numbers RM
    elseif length(numbers) >= 4
        firstNumber = str2double(numbers{1}) + str2double(numbers{2})/10;
        secondNumber = str2double(numbers{3}) + str2double(numbers{4})/10;
        riverMiles = [firstNumber,secondNumber];
    
    % Three Numbers RM
    elseif length(numbers) == 3
        if numbers{1} > numbers{2}
            firstNumber = str2double(numbers{1}) + str2double(numbers{2})/10;
            secondNumber = str2double(numbers{3});
        else
            firstNumber = str2double(numbers{1});
            secondNumber = str2double(numbers{2}) + str2double(numbers{3})/10;
        end
        riverMiles = [firstNumber,secondNumber];
    
    % Two Numbers RM
    elseif length(numbers) == 2
        firstNumber = str2double(numbers{1});
        secondNumber = str2double(numbers{2});
        riverMiles = [firstNumber,secondNumber];
    else
        riverMiles = [nan,nan];
    end
end