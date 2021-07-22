MSdateStart=[];
MSdateEnd = [];
MStimeRange = {};% {char('Start Time'),char('End Time')};
Region = 'Solar Wind'
for i=1:length(datesdata)
    if strcmp(string(classdata(i)),Region) % If Magnetosheath time point, then
        
        if isempty(MSdateStart) %If first, make it the starting point
            MSdateStart = datestr(datesdata(i),'yyyymmdd HH:MM:SS.FFF'); %Set start point
            ndataPoints = 1;
        elseif ~isempty(MSdateStart) %If not first, keep going with loop
            %Check to see if there is a gap in the data
            previousString = datestr(datesdata(i-1),'yyyymmdd HH:MM:SS.FFF');
            previousTime = datetime(previousString,'inputformat','yyyyMMdd HH:mm:ss.SSS');
            currentString = datestr(datesdata(i),'yyyymmdd HH:MM:SS.FFF');
            currentTime = datetime(currentString,'inputformat','yyyyMMdd HH:mm:ss.SSS');
            if (currentTime > (previousTime + seconds(5))) %There is a gap
                MSdateEnd = previousString; %set the previous datapoint as endpoint
            else
                ndataPoints = ndataPoints + 1;
                continue;
            end
        end
        
    else %If it is not magnetosheath
        
        if ~isempty(MSdateStart) %If there was magnetosheath times immediately before, then break
            MSdateEnd = datestr(datesdata(i-1),'yyyymmdd HH:MM:SS.FFF');
        else
            continue; %If there was no magnetosheath before,keep going with loop
            ndataPoint=0;
        end
    end
    
    %If there is a start and end time defined,
    if ~isempty(MSdateStart) && ~isempty(MSdateEnd)
        if ndataPoints > 66 %5minutes
            previousEntries = size(MStimeRange,1);
            MStimeRange{previousEntries+1,1} = char(MSdateStart);
            MStimeRange{previousEntries+1,2} = char(MSdateEnd);
        end
        ndataPoints = 0;
        MSdateStart = [];
        MSdateEnd = [];
    else
        continue;
    end
    
end
T = table
for i=1:length(MStimeRange)
%add = table(string(datestr(MStimeRange{i,1},'yyyymmdd HH:MM:SS.FFF')),string(datestr(MStimeRange{i,2},'yyyymmdd HH:MM:SS.FFF')));
add = table(string(MStimeRange{i,1}),string(MStimeRange{i,2}));
T = [T;add];
end
writetable(T,'MStimes')