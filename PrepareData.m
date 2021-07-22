function [T] = PrepareData()
%%
cd '/Users/andrewvu/Library/Mobile Documents/com~apple~CloudDocs/Research/MLMMS/MMSTraining'
load MMSTraining.mat

% for i=1:length(xTrain)
%     xTrain{i}(10:41,:) = [];
% end
T1= array2table(cell2mat(xTrain)','VariableNames',{'Bx' 'By' 'Bz' 'Bmag' 'N' 'Vx' 'Vy' 'Vz' 'Vmag',...
    'e1','e2','e3','e4','e5','e6','e7','e8','e9','e10','e11','e12','e13','e14','e15','e16','e17','e18','e19','e20','e21','e22','e23','e24','e25','e26','e27','e28','e29','e30','e31','e32',...
    'Rx' 'Ry' 'Rz' 'R',...
    'massflux',...
    'c1','c2','c3','c4','c5','c6','c7','c8','c9','c10','c11','c12','c13','c14','c15','c16','c17','c18','c19','c20','c21','c22','c23','c24','c25','c26','c27','c28','c29','c30','c31','c32'});


responseCol = [];
for i=1:length(yTrain)
    responseCol = [responseCol yTrain{i}];
end

T2=table(responseCol');
T2.Properties.VariableNames = {'Response'};
T=[T1 T2];


clear T2
clear T1
clear responseCol
clear i
clear xTrain
clear yTrain
clear dateTrain
 
end
% load '/Users/andrewvu/Library/Mobile Documents/com~apple~CloudDocs/Research/Wind Analysis/MMSTraining/trainedModel_cosineKNN.mat'
% yPred =cosineKNN.predictFcn(T);
% acc = sum(yPred == responseCol')./numel(responseCol')

% %% 
% load MMSTraining201711.mat
% 
% for i=1:length(xTrain)
%     xTrain{i}(10:41,:) = [];
% end
% 
% %[bdata, ndata,vdata,espectdata,rdata]
% 
% 
% 
% T1= array2table(cell2mat(xTrain)','VariableNames',{'Bx' 'By' 'Bz' 'Bmag' 'N' 'Vx' 'Vy' 'Vz' 'Vmag' 'Rx' 'Ry' 'Rz' 'R'});
% 
% 
% responseCol = [];
% for i=1:length(yTrain)
%     responseCol = [responseCol yTrain{i}];
% end
% 
% T2=table(responseCol');
% T2.Properties.VariableNames = {'Response'};
% T11=[T1 T2];
% 
% 
% clear T2
% clear T1
% clear i
% 
% T1011 = [T10;T11];