%{
A function to import the Hypnogram txt files to MATLAB workspace
    * Input: Address of the file

    * Output: Data - size = 2*N ; N = number of alternation in the sleep
    state
        Data(1,:): onset time of each state in second
        Data(2,:): sleep state:
                    -1: ?
                    0: W
                    1: 1
                    2: 2
                    3: 3
                    4: 4
                    5: M
                    6: R
%}

function Data = AnnotExtract(Path)
    
    fileID = fopen(Path);
    C = textscan(fileID,'+%d   %s %s %s');	
    
    Data(1,:) = double(cell2mat(C(1)));
    for i = 1:length(Data)
        switch char(C{1,4}(i))
            case '?'
                Data(2,i) = -1;
            case 'W'
                Data(2,i) = 0;
            case 'R'
                Data(2,i) = 6;
            case '1'
                Data(2,i) = 1;
            case '2'
                Data(2,i) = 2;
            case '3'
                Data(2,i) = 3;
            case '4'
                Data(2,i) = 4;
            case 'M'
                Data(2,i) = 5;
            otherwise
                
        end
    end
    
end