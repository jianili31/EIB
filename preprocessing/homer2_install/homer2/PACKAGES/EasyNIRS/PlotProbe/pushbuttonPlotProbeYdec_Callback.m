function pushbuttonPlotProbeYdec_Callback(hObject, eventdata, handles)
global plotprobe

hFig   = plotprobe.objs.Figure.h;
hEditScl = getSclPanelEditHandle(plotprobe.objs.SclPanel.h);

plotprobe.axScl(2) = plotprobe.axScl(2) - 0.1;
set(hEditScl,'string', sprintf('%0.1f %0.1f',plotprobe.axScl) );
hData = plotProbeAndSetProperties(hFig);

plotprobe.objs.Data.h = hData;