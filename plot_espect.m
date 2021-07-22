function [] = plot_espect(timedata,espectdata,energydata)
    
    %Plots energy spectrum data
    imagesc(timedata,log10(energydata(1,:)'),log10(espectdata)')
%     color_bar = colorbar('Ticks', [3, 4, 5, 6, 7,8],...
%         'TickLabels', {'10^3', '10^4', '10^5', '10^6', '10^7','10^8'},'FontSize', 10);
%     ylabel(color_bar,{'keV/cm^2 s sr keV'},'FontSize', 8)
%     shading interp
    whitejet = [1 1 1; jet];
    colormap(whitejet);
    datetick
    xlim([timedata(1) timedata(end)])
    ylabel({'Energy';'[eV]'},'FontSize', 14)
    set(gca,'Ydir','normal','YMinorTick','on','XMinorTick','on','Yticklabels',[10 100 1000 10000],'linewidth',1.25)
    
    
    
end

