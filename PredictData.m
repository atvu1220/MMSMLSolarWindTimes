function [yPred,datesdata,classdata] = PredictData(date_start,date_end,model)
    %Predicts regions on days of MMS from trained Model
    
    cd  '/Users/andrewvu/Library/Mobile Documents/com~apple~CloudDocs/Research/MLMMS/MMSPrediction'
    
    % load MMSTraining201711.mat
    %     load fineKNN201711.mat
    %     date_start = '20171201';
    %     date_end   = '20171231';
    %     date_start = '20180101';
    %     date_end   = '20180427';
    
    ds = datetime(date_start,'inputformat','yyyyMMdd');
    de = datetime(date_end,'inputformat','yyyyMMdd');
    datesdata = [];
    classdata = [];
    ndays = days(de-ds);
    % xTrain = cell(1,ndays+1);
    % yTrain = cell(size(xTrain));
    % dateTrain = cell(size(xTrain));
    date_current = date_start;
    
    while ~strcmp(date_current,datestr((datetime(date_end,'inputformat','yyyyMMdd') + 1),'yyyymmdd'))
        %% Plot Regions per Day
        %         date_current = datestr((ds + n),'yyyymmdd')
%         if date_current == '20190212'
%             date_current = '20190217';
%         elseif date_current == '20190218'
%             date_current = '20190219';
%         elseif date_current =='20190220'
%             date_current = '20190221';
%         elseif date_current =='20190311'
%             date_current = '20190312';
%         elseif date_current == '20180427' %Skip nightside
%             date_current = '20181021';
%             
%             
%             %             A = ['20190212','20190213','20190214','20190215','20190216','20190218','20190220'];
%         end
        close
        
        date_current
        [timedata,espectdata,energydata,ndata,vdata,tperpdata,tparadata,~,bdata,~,rdata] = ...
            load_mms_fast(date_current,date_current);
        if (ndata) == 0
             %Update to next day
        date_current = datestr((datetime(date_current,'inputformat','yyyyMMdd') + 1),'yyyymmdd');
            continue
        end
        massflux = ndata.*vdata(:,4);
        
        T=array2table([bdata,ndata,vdata,espectdata,rdata,massflux,energydata],'VariableNames',{'Bx' 'By' 'Bz' 'Bmag' 'N' 'Vx' 'Vy' 'Vz' 'Vmag',...
    'e1','e2','e3','e4','e5','e6','e7','e8','e9','e10','e11','e12','e13','e14','e15','e16','e17','e18','e19','e20','e21','e22','e23','e24','e25','e26','e27','e28','e29','e30','e31','e32',...
    'Rx' 'Ry' 'Rz' 'R',...
    'massflux',...
    'c1','c2','c3','c4','c5','c6','c7','c8','c9','c10','c11','c12','c13','c14','c15','c16','c17','c18','c19','c20','c21','c22','c23','c24','c25','c26','c27','c28','c29','c30','c31','c32'});
        
        %Random single data point holes in data need to be interpolated
        IndicesofDataHoles = find([1;diff(isnan(ndata));1]);
        %Assuming dataholes are not at the first and last data points, we only use 2:end-1 indices
        for i=2:2:(length(IndicesofDataHoles)-2)
            if IndicesofDataHoles(i+1) - IndicesofDataHoles(i) < 3
                ndata( IndicesofDataHoles(i)-3:IndicesofDataHoles(i+1)+2 ) = fillmissing(  ndata( IndicesofDataHoles(i)-3:IndicesofDataHoles(i+1)+2 ) , 'spline');
                vdata( IndicesofDataHoles(i)-3:IndicesofDataHoles(i+1)+2 ,:) = fillmissing(  vdata( IndicesofDataHoles(i)-3:IndicesofDataHoles(i+1)+2 ,:) , 'spline');
                tparadata( IndicesofDataHoles(i)-3:IndicesofDataHoles(i+1)+2 ,:) = fillmissing(  tparadata( IndicesofDataHoles(i)-3:IndicesofDataHoles(i+1)+2 ,:) , 'spline');
                tperpdata( IndicesofDataHoles(i)-3:IndicesofDataHoles(i+1)+2 ,:) = fillmissing(  tperpdata( IndicesofDataHoles(i)-3:IndicesofDataHoles(i+1)+2 ,:) , 'spline');
                espectdata( IndicesofDataHoles(i)-3:IndicesofDataHoles(i+1)+2 ,:) = fillmissing(  espectdata( IndicesofDataHoles(i)-3:IndicesofDataHoles(i+1)+2 ,:) , 'linear');
            else
                %yPred(IndicesofDataHoles(i):IndicesofDataHoles(i+1)) = 'none';
            end
        end
        
        
        yPred = model.predictFcn(T);
        yPred(isnan(ndata)) = 'none';
        %Save for SW times
        datesdata = [datesdata; timedata];
        classdata = [classdata; yPred];
        
        
        %acc = sum(yPred == responseCol')./numel(responseCol')
        
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
        
        
        
        subplot(5,1,5)
        hold on
        area(timedata,double(yPred=='Solar Wind'))
        area(timedata,double(yPred=='Magnetosheath'))
        area(timedata,double(yPred=='Magnetosphere'))
        area(timedata,double(yPred=='NightSide'))
        
        
        
        hold off
        datetick
        xlim(xl)
        ylim([0 1])
        set(gca,'yticklabel',[])
        ylabel({'Predicted Regions'},'FontSize', 14)
        legend({'Solar Wind', 'Magnetosheath', 'Magnetosphere','NightSide'},'FontSize',12)
        legend('Location', 'north', 'orientation', 'horizontal')
        set(gca,'YMinorTick','on','XMinorTick','on','linewidth',1.25,'Layer','top')
        box on
        figure(gcf)
        
        fileName = strcat('MMS_Prediction',date_current);
        print(gcf,'-dpng','-r300', '-loose', strcat(fileName));
        
        %Update to next day
        date_current = datestr((datetime(date_current,'inputformat','yyyyMMdd') + 1),'yyyymmdd');
    end
end