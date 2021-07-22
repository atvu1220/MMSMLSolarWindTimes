%Plots parameters for creating training files
tic
close all
clear

cd '/Users/andrewvu/Library/Mobile Documents/com~apple~CloudDocs/Research/Wind Analysis/MMSTraining'

load MMSTraining.mat

date_start = '20150901';
date_end   = '20150901';

ds = datetime(date_start,'inputformat','yyyyMMdd');
de = datetime(date_end,'inputformat','yyyyMMdd');

ndays = days(de-ds);
% xTrain = cell(1,ndays+1);
% yTrain = cell(size(xTrain));
% dateTrain = cell(size(xTrain));

for n=0:ndays
    date_current = datestr((ds + n),'yyyymmdd')
    
    if sum(contains(dateTrain,date_current)) > 0
        x = input('There already exists a completed training file for this date, continue to next date?','s')
        if isempty(x)
            continue;
        else
            dateIndextoReplace = find(contains(dateTrain,date_current)==1);
        end
    end
    
    [timedata,espectdata,energydata,ndata,vdata,tperpdata,tparadata,~,bdata,~,rdata] = ...
        load_mms_fast(date_current,date_current);
    
    %Random single data point holes in data need to be interpolated
    IndicesofDataHoles = find([1;diff(isnan(ndata));1]);
    %Assuming dataholes are not at the first and last data points, we only use 2:end-1 indices
    for i=2:2:(length(IndicesofDataHoles)-2)
        if IndicesofDataHoles(i+1) - IndicesofDataHoles(i) < 3
            ndata( IndicesofDataHoles(i)-4:IndicesofDataHoles(i+1)+3 ) = fillmissing(  ndata( IndicesofDataHoles(i)-4:IndicesofDataHoles(i+1)+3 ) , 'spline');
            vdata( IndicesofDataHoles(i)-4:IndicesofDataHoles(i+1)+3 ,:) = fillmissing(  vdata( IndicesofDataHoles(i)-4:IndicesofDataHoles(i+1)+3 ,:) , 'spline');
            tparadata( IndicesofDataHoles(i)-4:IndicesofDataHoles(i+1)+3 ,:) = fillmissing(  tparadata( IndicesofDataHoles(i)-4:IndicesofDataHoles(i+1)+3 ,:) , 'spline');
            tperpdata( IndicesofDataHoles(i)-4:IndicesofDataHoles(i+1)+3 ,:) = fillmissing(  tperpdata( IndicesofDataHoles(i)-4:IndicesofDataHoles(i+1)+3 ,:) , 'spline');
            espectdata( IndicesofDataHoles(i)-4:IndicesofDataHoles(i+1)+3 ,:) = fillmissing(  espectdata( IndicesofDataHoles(i)-4:IndicesofDataHoles(i+1)+3 ,:) , 'linear');
        else
            %yPred(IndicesofDataHoles(i):IndicesofDataHoles(i+1)) = 'none';
        end
    end
    
    close
    figure('Position',[0 400 1300 800])
    set(gcf,'color','w');
    sgtitle(strcat('MMS Classification - ',date_current));
    subplot(5,1,1)
    plot(timedata,bdata)
    ylim([-50 50])
    datetick
    xl = xlim;
    ylabel({'B';'[nT]'},'FontSize', 14)
    set(gca,'YMinorTick','on','XMinorTick','on','linewidth',1.25)
    subplot(5,1,2)
    plot(timedata,ndata);
    datetick
    xlim(xl)
    ylabel({'N';'[cm^{-3}]'},'FontSize', 14)
    set(gca,'YMinorTick','on','XMinorTick','on','linewidth',1.25)
    
    subplot(5,1,3)
    plot(timedata,vdata);
    datetick
    xlim(xl)
    ylabel({'Velocity';'[km/s]'},'FontSize', 14)
    set(gca,'YMinorTick','on','XMinorTick','on','linewidth',1.25)
    
    
    subplot(5,1,4)
    plot_espect(timedata,espectdata,energydata)
    datetick
    xlim(xl)
    toc
    Regions = {'Solar Wind';'Magnetosheath';'Magnetosphere'};
    Regions_Shortcut = {'sw';'bs';'ms'};
    Regions_Color = [1,2,3,4,0];
    RegionTime = strings(size(timedata));
    RegionColorTime = zeros(size(timedata));
    
    %First Region
    [startIndex] = getIndex('Start Position',timedata)
    [endIndex] = getIndex('End Position',timedata)
    Region = input('What Region is this?: ','s')
    while strcmp(Regions_Shortcut,Region) == 0
        Region = input('What Region is this?: ','s')
    end
    RegionTime(startIndex:endIndex) = Regions(strcmp(Regions_Shortcut,Region));
    RegionColorTime(startIndex:endIndex) =Regions_Color(strcmp(Regions_Shortcut,Region));
    
    AnotherRegion = input('Is there another region?: ');
    
    while isempty(AnotherRegion)
        figure(gcf)
        datacursormode toggle
        datacursormode toggle
        [startIndex] = getIndex('Start Position',timedata)
        [endIndex] = getIndex('End Position',timedata)
        Region = input('What Region is this?: ','s');
        while strcmp(Regions_Shortcut,Region) == 0
            Region = input('What Region is this?: ','s')
        end
        RegionTime(startIndex:endIndex) = Regions(strcmp(Regions_Shortcut,Region));
        RegionColorTime(startIndex:endIndex) =Regions_Color(strcmp(Regions_Shortcut,Region));
        AnotherRegion = input('Is there another region?: ');
    end
    
    
    
    
    
    subplot(5,1,5)
    hold on
    
    for i=0:4
        Regionbar = RegionColorTime;
        Regionbar(Regionbar ~= i) = NaN;
        area(timedata,Regionbar);
    end
    
    hold off
    datetick
    xlim(xl)
    ylim([0 1])
    set(gca,'yticklabel',[])
    ylabel({'Regions'},'FontSize', 14)
    set(gca,'YMinorTick','on','XMinorTick','on','linewidth',1.25)
    box on
    figure(gcf)
    
    fileName = strcat('MMS_Classification',date_current);
    print(gcf,'-dpng','-r300', '-loose', strcat(fileName));
    
    RegionData = [bdata, ndata,vdata,espectdata,rdata];
    RegionTime = categorical(RegionTime);
    undefinedCats = isundefined(RegionTime);
    RegionTime(undefinedCats)= [];
    RegionData(undefinedCats,:) = [];
    RegionTime=RegionTime';
    RegionData=RegionData';
    
    
    previousDays = length(xTrain);
    
    if ~exist('dateIndextoReplace','var')
        dateTrain{previousDays+1} = date_current;
        xTrain{previousDays+1} = RegionData;
        yTrain{previousDays+1} = RegionTime;
        
    else
        dateTrain{dateIndextoReplace} = date_current;
        xTrain{dateIndextoReplace} = RegionData;
        yTrain{dateIndextoReplace} = RegionTime;
    end
    
    
    save('MMSTraining','dateTrain','xTrain','yTrain')
    clear dateIndextoReplace
    
    %     for i = 1:length(yTrain)
    %         blanks = cellfun(@isempty,yTrain{i});
    %         yTrain{i}(blanks) = 'undefined';
    %
    %
    %     end
    %
    % % for i=1:length(yTrain)
    % %     A = isundefined(yTrain{i});
    % %     yTrain{i}(A) = [];
    % %     yTrain{i} = yTrain{i}';
    % %     xTrain{i}(A,:) = [];
    % %     xTrain{i} = xTrain{i}';
    % % end
    
end



%% Functions
function [clicked_index] = getIndex(dispString,timedata)
    % Enable data cursor mode
    datacursormode on
    dcm_obj = datacursormode(gcf);
    % Set update function
    set(dcm_obj,'UpdateFcn',{@myupdatefcn,timedata})
    % Wait while the user to click
    disp(dispString)
    pause
    % Export cursor to workspace
    info_struct = getCursorInfo(dcm_obj);
    
    while isempty(info_struct)
        % Enable data cursor mode
        datacursormode on
        dcm_obj = datacursormode(gcf);
        % Set update function
        set(dcm_obj,'UpdateFcn',{@myupdatefcn,timedata})
        % Wait while the user to click
        disp(dispString)
        pause
        % Export cursor to workspace
        info_struct = getCursorInfo(dcm_obj);
    end
    
    
    if isfield(info_struct, 'Position')
        %         disp('Clicked position is')
        %         disp(info_struct.Position)
        clicked_index = find(timedata == info_struct.Position(1))
    end
    delete(findall(gcf,'Type','hggroup'));
end

function output_txt = myupdatefcn(~,event_obj,timedata)
    % ~            Currently not used (empty)
    % event_obj    Object containing event data structure
    % output_txt   Data cursor text
    pos = get(event_obj, 'Position');
    
    %   output_txt = {['x: ' num2str(pos(1))], ['y: ' num2str(pos(2))]};
    output_txt = {['x: ' num2str(find(timedata == pos(1)))], ['y: ' num2str(pos(2))]};
end
