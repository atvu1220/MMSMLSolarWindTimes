function output_txt = getPlotTime(obj,event_obj)
% Display data cursor position in a data tip
% obj          Currently not used
% event_obj    Handle to event object
% output_txt   Data tip text, returned as a character vector or a cell array of character vectors

pos = event_obj.Position;

format='yyyy-mm-dd HH:MM:SS.FFF';
time = datestr(pos(1),format);
%time = time(12:end);
clipboard('copy',time)
% pos(1) = getTime(pos(1));
%********* Define the content of the data tip here *********%

% Display the x and y values:
%output_txt = getTime(pos(1));
output_txt = {['Time:',formatValue(time,event_obj)],...
              ['Value:',formatValue(pos(2),event_obj)]};
%***********************************************************%


% If there is a z value, display it:
if length(pos) > 2
    output_txt{end+1} = ['Z',formatValue(pos(3),event_obj)];
end

%***********************************************************%

function formattedValue = formatValue(value,event_obj)
% If you do not want TeX formatting in the data tip, uncomment the line below.
%event_obj.Interpreter = 'none';
if strcmpi(event_obj.Interpreter,'tex')
    valueFormat = ' \color[rgb]{0 0.5 1}\bf';
    removeValueFormat = '\color[rgb]{.15 .15 .15}\rm';
else
    valueFormat = ': ';
    removeValueFormat = '';
end
formattedValue = [valueFormat num2str(value,4) removeValueFormat];
