 function varargout = iris(varargin)
% IRIS MATLAB code for iris.fig
%      IRIS, by itself, creates a new IRIS or raises the existing
%      singleton*.
%
%      H = IRIS returns the handle to a new IRIS or the handle to
%      the existing singleton*.
%
%      IRIS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IRIS.M with the given input arguments.
%
%      IRIS('Property','Value',...) creates a new IRIS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before iris_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to iris_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help iris

% Last Modified by GUIDE v2.5 28-Dec-2019 16:40:07

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @iris_OpeningFcn, ...
                   'gui_OutputFcn',  @iris_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
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


% --- Executes just before iris is made visible.
function iris_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to iris (see VARARGIN)

% Choose default command line output for iris
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
han = axes('unit','normalized','position',[0 0 1 1]);
new = imread('A.jpg');
imagesc(new);
set(han,'handlevisibility','on','visible','off');
uistack(han,'top');

% UIWAIT makes iris wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = iris_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global gray x pwLBP
img = adapthisteq(gray,'clipLimit',0.02,'Distribution','rayleigh');
nFiltSize=8;    
nFiltRadius=1;
filtR=generateRadialFilterLBP(nFiltSize, nFiltRadius);

fprintf('Here is our filter:\n')
disp(filtR);

% Test regular LBP vs RI-LBP
effLBP   = efficientLBP(img, 'filtR', filtR, 'isRotInv', false, 'isChanWiseRot', false);
effRILBP = efficientLBP(img, 'filtR', filtR, 'isRotInv', true,  'isChanWiseRot', false);

uniqueRotInvLBP=findUniqValsRILBP(nFiltSize);
tightValsRILBP=1:length(uniqueRotInvLBP);
% Use this function with caution- it is relevant only if 'isChanWiseRot' is false, or the
% input image is single-color/grayscale
effTightRILBP=tightHistImg(effRILBP, 'inMap', uniqueRotInvLBP, 'outMap', tightValsRILBP);

binsRange=(1:2^nFiltSize)-1;
figure;
subplot(2,1,1)
hist(single( effLBP(:) ), binsRange);
axis tight;
title('Regular LBP hsitogram', 'fontSize', 16);

subplot(2,2,3)
hist(single( effRILBP(:) ), binsRange);
axis tight;
title('RI-LBP sparse hsitogram', 'fontSize', 16);

subplot(2,2,4)
hist(single( effTightRILBP(:) ), tightValsRILBP);
axis tight;
title('RI-LBP tight hsitogram', 'fontSize', 16);


% Verify 'efficientLBP' and 'pixelwiseLBP' act alike, 
% just with different run time and memory utilization
tic;
 % note this filter dimentions aren't legete...
effLBP= efficientLBP(x, 'filtR', filtR, 'isRotInv', true, 'isChanWiseRot', false);
effTime=toc;

% verify pixel wise implementation returns same results
tic;
% same parameters as before
pwLBP=pixelwiseLBP(x, 'filtR', filtR, 'isRotInv', true, 'isChanWiseRot', false); 
inEffTime=toc;
fprintf('\nRun time ratio %.2f. Same result equality chesk: %o.\n', inEffTime/effTime,...
   isequal(effLBP, pwLBP));

figure;
subplot(1, 3, 1)
imshow(x);
title('Original image', 'fontSize', 18);

subplot(1, 3, 2)
imshow( effLBP );
title('Efficeint LBP image', 'fontSize', 18);

subplot(1, 3, 3)
imshow( pwLBP );
title('Pixel-wise LBP image', 'fontSize', 18);

% --- Executes on button press in pushbutton3.x
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global x gray
gray=rgb2gray(x);
axes(handles.axes2);
imshow(gray);
title('gray scale image');

% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global gray
Iblur = imgaussfilt(gray,2);
axes(handles.axes2);
imshow(Iblur);
title('filtered image');

% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global x
[filename,filepath]=uigetfile('file selector');
a=strcat(filepath,filename);
x=imread(a);
axes(handles.axes1);
imshow(x);


% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global x
imageFolder = fullfile('imagedata');
imds = imageDatastore(imageFolder, 'LabelSource', 'foldernames', 'IncludeSubfolders',true);
[trainData] =imds;
numTrainImages = numel(trainData.Labels);
idx = randperm(numTrainImages,10);
figure;
for i = 1:10
    subplot(4,4,i)
    I = readimage(trainData,idx(i));
%     I=imresize(I,[128 128]);
    imshow(I)
    title('training')
end


layers = [imageInputLayer([240 320 3])
    
          convolution2dLayer(5,20)
          
          reluLayer
          
          maxPooling2dLayer(2,'Stride',2)
          
          convolution2dLayer(5,20)
          
          reluLayer
          
          maxPooling2dLayer(2,'Stride',2)
          fullyConnectedLayer(2)
          softmaxLayer
          classificationLayer()];

options = trainingOptions('sgdm','MaxEpochs',1, ...
	'InitialLearnRate',0.0001);  
convnet = trainNetwork(trainData,layers,options);

 
net=convnet;
net.Layers
inputSize = net.Layers(1).InputSize;

augimdsTrain = augmentedImageDatastore(inputSize(1:2),trainData);
% augimdsTest = augmentedImageDatastore(inputSize(1:2),imdsTest);

layer = 'fc';
featuresTrain = activations(net,augimdsTrain,layer,'OutputAs','rows');
% aa1=imread('C:\Users\ADHI\Desktop\New folder (2)\imagedata\authorized\aeval1.bmp');
% featuresTest1 = activations(net,aa1,layer,'OutputAs','rows');
aa2=x;
aa2=imresize(aa2,[240 320]);
featuresTest2 = activations(net,aa2,layer,'OutputAs','rows');
% 
% % Extract the class labels from the training and test data.
YTrain = trainData.Labels;
% YTest = imdsTest.Labels;

t = templateNaiveBayes('DistributionNames','kernel');
% Mdl = fitcecoc(meas,species,'Learners',t);
% 
% Fit Image Classifier
% Use the features extracted from the training images as predictor variables and fit a multiclass support vector machine (SVM) using fitcecoc (Statistics and Machine Learning Toolbox).
classifier = fitcecoc(featuresTrain,YTrain,'Learners',t);


% Classify Test Images
% Classify the test images using the trained SVM model the features extracted from the test images.
% YPred1= predict(classifier,featuresTest1);
YPred2 = predict(classifier,featuresTest2);


net=convnet;
 
layer =7;
name = net.Layers(layer).Name;

channels = 1:15;

I = deepDreamImage(net,layer,channels, ...
    'PyramidLevels',3);
figure
montage(I);
title(['Layer ',name,' Features'])


net=convnet;
 
layer =4;
name = net.Layers(layer).Name;

channels = 1:15;

I1 = deepDreamImage(net,layer,channels, ...
    'PyramidLevels',3);

if YPred2=='authorized'
    msgbox('VERIFIED ')
    s = inputdlg(' Do you want to view the files(y/n):');
    if s{1,1}== 'y' 
        javaaddpath([matlabroot,'/java/jarext/mysql-connector-java-8.0.19.jar'])
        conn=database('berlindb','berlinuname','berlinpass','com.mysql.jdbc.Driver','jdbc:mysql://db4free.net:3306/berlindb');
        query=exec(conn,'select * from identity');
        query=fetch(query);
        query.Data;
        display(query.Data);
    end
else
    msgbox('NOT VERIFIED')
end
