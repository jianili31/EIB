function menuItemViewOrigin_Callback(hObject, eventdata, handles)
global atlasViewer

axesv = atlasViewer.axesv; 

type = get(hObject,'type');
if strcmp(type, 'uimenu')
    checked_propname = 'checked';
    ia = 1;
elseif strcmp(type, 'uicontrol')
    checked_propname = 'value';
    ia = 2;
end

hAxes = axesv(ia).handles.axesSurfDisplay;
hOrigin = getappdata(hAxes, 'hOrigin');

if strcmp(get(hOrigin, 'visible'), 'off')
    if ia==1
        onoff = 'on';
    elseif ia==2
        onoff = 1;        
    end
elseif strcmp(get(hOrigin, 'visible'), 'on')
    if ia==1
        onoff = 'off';
    elseif ia==2
        onoff = 0;
    end
end
set(hObject, checked_propname, onoff);
viewOrigin(hAxes, [], 'donotredraw');
