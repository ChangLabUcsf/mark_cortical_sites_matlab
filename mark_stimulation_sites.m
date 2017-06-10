function varargout = mark_stimulation_sites(varargin)
%MARK_STIMULATION_SITES M-file for mark_stimulation_sites.fig
%      MARK_STIMULATION_SITES, by itself, creates a new MARK_STIMULATION_SITES or raises the existing
%      singleton*.
%
%      H = MARK_STIMULATION_SITES returns the handle to a new MARK_STIMULATION_SITES or the handle to
%      the existing singleton*.
%
%      MARK_STIMULATION_SITES('Property','Value',...) creates a new MARK_STIMULATION_SITES using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to mark_stimulation_sites_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      MARK_STIMULATION_SITES('CALLBACK') and MARK_STIMULATION_SITES('CALLBACK',hObject,...) call the
%      local function named CALLBACK in MARK_STIMULATION_SITES.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help mark_stimulation_sites

% Last Modified by GUIDE v2.5 10-Apr-2017 13:35:41

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @mark_stimulation_sites_OpeningFcn, ...
                   'gui_OutputFcn',  @mark_stimulation_sites_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
   gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before mark_stimulation_sites is made visible.
function mark_stimulation_sites_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for mark_stimulation_sites
handles.output = hObject;

subject = varargin{1};
hem = varargin{2};
if length(varargin) > 2
    data_dir = varargin{3};
end

handles.varargin = varargin;


if ~exist('data_dir','var') || isempty(data_dir)
    data_dir = '/Users/bendichter/Desktop/data/';
end

% load([data_dir subject '/Imaging/Meshes/' subject '_' hem '_pial.mat'])
load([data_dir subject '_' hem '_pial.mat'])

axes(handles.axes1);
ctmr_gauss_plot(cortex,[0,0,0],0,hem);

handles.cortex = cortex;

if strcmp(hem,'lh')
    xlim([-100,0])
else
    xlim([0,100])
end
zlim([-30, 90])
zoom(1.5)

dcm_obj = datacursormode(gcf());
set(dcm_obj,'DisplayStyle','window','Enable','on');
handles.dcm_obj = dcm_obj;

handles.data = {};

uibuttongroup1_SelectionChangedFcn(hObject, eventdata, handles)

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes mark_stimulation_sites wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = mark_stimulation_sites_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes when selected object is changed in uibuttongroup1.
function uibuttongroup1_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uibuttongroup1 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if handles.arm_radio.Value
    handles.status = 'arm';
elseif handles.larynx_radio.Value
    handles.status = 'larynx';
elseif handles.mouth_radio.Value
    handles.status = 'mouth';
elseif handles.tongue_radio.Value
    handles.status = 'tongue';
elseif handles.SA_radio.Value
    handles.status = 'speech arrest';
elseif handles.MA_radio.Value
    handles.status = 'motor arrest';
elseif handles.SAMA_radio.Value
    handles.status = 'speech/motor arrest';    
else
    print('unrecognized radio')
end

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in mark_button.
function mark_button_Callback(hObject, eventdata, handles)
% hObject    handle to mark_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~isfield(handles.dcm_obj.getCursorInfo,'Position')
    print('choose point')
    return;
end

dcm_obj = handles.dcm_obj;
pos = dcm_obj.getCursorInfo.Position;

% make sure to get the right X-coordinate
nearby_Y_ind = find(handles.cortex.vert(:,2) > pos(1,2) - 0.5 &...
    handles.cortex.vert(:,2) < pos(1,2) + 0.5 &...
    handles.cortex.vert(:,3) > pos(1,3) - 0.5 &...
    handles.cortex.vert(:,3) < pos(1,3) + 0.5);
[Y, I ] = max(abs(handles.cortex.vert(nearby_Y_ind,1)));
pos = handles.cortex.vert(nearby_Y_ind(I),:);
%%%

hem = handles.varargin{2};

handles.data{end+1,1} = pos;
handles.data{end,2} = handles.status;

hold on
if handles.arm_radio.Value
    c='b';
elseif handles.larynx_radio.Value
    c='k';
elseif handles.mouth_radio.Value
    c='r';
elseif handles.tongue_radio.Value
    c='g';
elseif handles.SA_radio.Value
    c='b';
elseif handles.MA_radio.Value
    c='m';
elseif handles.SAMA_radio.Value
    c='m';
end

if strcmp(hem,'lh')
    handles.point = plot3(pos(1), pos(2), pos(3),'.','color',c,'MarkerSize',50);
else
    handles.point = plot3(pos(1), pos(2), pos(3),'.','color',c,'MarkerSize',50);
end

set(dcm_obj,'Enable','off')
set(dcm_obj,'Enable','on')

% Update handles structure
guidata(hObject, handles);



% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

elecmatrix = vertcat(handles.data{:,1});
eleclabels = handles.data(:,2);
save([handles.varargin{1}, '_stim_results'], 'elecmatrix','eleclabels')


% --- Executes on button press in debug_button.
function debug_button_Callback(hObject, eventdata, handles)
% hObject    handle to debug_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

keyboard


% --- Executes on button press in zoom_button.
function zoom_button_Callback(hObject, eventdata, handles)
% hObject    handle to zoom_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

zoom


% --- Executes on button press in undo_last.
function undo_last_Callback(hObject, eventdata, handles)
% hObject    handle to undo_last (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%remove last point
delete(handles.point(end))
handles.data = handles.data(1:end-1,:);

% Update handles structure
guidata(hObject, handles);
