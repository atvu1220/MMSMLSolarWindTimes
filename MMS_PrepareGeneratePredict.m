%Prepares data using classified training files, generates model from training, then predicts data
close all
clear
date_start = '20150901';
%date_start = '20171021';
%date_end = '20200531';
% date_start = '20190510';
date_end   = '20200531';
% date_start = '20171114'
% date_end = '20171114'
load '/Users/andrewvu/Library/Mobile Documents/com~apple~CloudDocs/Research/MLMMS/Model.mat'
if exist('model','var') == 0
    %% Prepare Data
    [T] = PrepareData();   
    %% Generate Model
    [model, accuracy] = GenerateModel2(T)
    cd '/Users/andrewvu/Library/Mobile Documents/com~apple~CloudDocs/Research/MLMMS'
    save('Model','model','-v7.3' )
end

%% Predict Data
[~,datesdata,classdata] = PredictData(date_start,date_end,model);
MMS_Clasifications=[datestr(datesdata,'yyyymmdd HH:MM:SS.FFF'),string(classdata)];
% T = table(datestr(datesdata,'yyyymmdd HH:MM:SS.FFF'),string(classdata),'VariableNames',{'Date','Classification'});
% % writetable(T,'testing')
% T = table(datestr(classstarttimedata,'yyyymmdd HH:MM:SS.FFF'),datestr(classendtimedata,'yyyymmdd HH:MM:SS.FFF'));


%view(model.ClassificationEnsemble.Trained{50},'mode','graph')