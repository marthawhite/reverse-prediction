function [n_data, k_data, tu_data, dataLoaders, filenames] = getDataInfo(DataNames)
% Returns the information about the given datasets
% Returns default values for unlabelled data, tu
%
% To obtain the Set datasets, go to:
    
AllRegressionNames = {'Gaussian-Reg','Cube','Exp','Log','Softmax-Reg','Kin32fh','Pumadyn8fh', ...
            'CalHousing','Parkinsons','Pumadyn8nm'};
tu_data_reg = [ 200, 200, 200, 200, 200, 100, 100, 300, 200, 400];
n_data_reg = [30, 20, 5, 5, 10, 34, 8, 5, 19, 8];
k_data_reg = [5, 3, 1,1,4,1,1,1,1,1];
fileName = {'/synthetic/gaussian-reg,n=30,k=5,sigma=1,t=10000,labeled=1000.mat',...
            '/synthetic/cube,n=20,k=3,sigma=0,t=10000,labeled=1000.mat',...
            '/synthetic/exp,n=5,k=1,sigma=1,t=10000,labeled=1000.mat',...
            '/synthetic/log,n=5,k=1,sigma=0.1,t=10000,labeled=1000.mat',...
            '/synthetic/softmax-reg,n=10,k=4,sigma=1,t=10000,labeled=1000.mat',...
            '/misc/kin32fh-splits.mat', ...
            '/misc/pumadyn8fh-splits.mat', ...
            '/misc/calhousingnorm-splits.mat', ...
            '/misc/parkinsonsk1-splits.mat', ...
            '/misc/pumadyn8nm-splits2.mat'};
AllRegInfo = [];
for i = 1:length(AllRegressionNames)
    info_nku = [n_data_reg(i) k_data_reg(i) tu_data_reg(i)];
    AllRegInfo = [AllRegInfo  {{{fileName{i}} , info_nku}}];  
end    

AllClassNames = {'Gaussian-Class','Sigmoid','Softmax','Set8','Set4', 'WBC', 'Ion', 'Set3','COIL', ...
            'LINK','Set1','Set5', 'Yeast'};

gaussian_info = {'/synthetic/gaussian-class,n=30,k=5,sigma=1.5,t=10000,labeled=1000.mat'};
gaussian_nku = [30,5,300];
sigmoid_info = {'/synthetic/sigmoid,n=10,k=4,sigma=1.5,t=10000,labeled=1000.mat'}; % generate forward
sigmoid_nku = [10,4,200];
%sigmoid_info = {'/synthetic/sigmoid,n=10,k=4,sigma=0.5,t=10000,labeled=1000.mat'};
%sigmoid_nku = [10,4,200];
softmax_info = {'/synthetic/softmax,n=10,k=3,sigma=1,t=10000,labeled=1000.mat'}; % generated forward
softmax_nku = [10,3,100];
set8_info = {'/SSL/SSL,set=8,data.mat','/SSL/SSL,set=8,splits,labeled=100.mat'}; % SetStr
set8_nku = [15,2,300];
set4_info = {'/SSL/SSL,set=4,data.mat','/SSL/SSL,set=4,splits,labeled=10.mat'};
set4_nku = [117,2,200];
set1_info = {'/SSL/SSL,set=1,data.mat','/SSL/SSL,set=1,splits,labeled=100.mat'};
set1_nku = [241,2,200];
set5_info = {'/SSL/SSL,set=5,data.mat','/SSL/SSL,set=5,splits,labeled=100.mat'};
set5_nku = [241,2,200];
WBC_info = {'/misc/wbc-splits.mat'};
WBC_nku = [10,2,50];
ion_info = {'/misc/ionosphere.mat', '/ionosphere/ionosphere,labeled=10.mat'};
ion_nku = [34,2,300];
set3_info = {'/SSL/SSL,set=3,data.mat', '/SSL/SSL,set=3,splits,labeled=10.mat'};
set3_nku = [241 2 100];
COIL_info = {'/misc/COIL-splits.mat'};
COIL_nku = [1024 20 200];
LINK_info = {'/misc/LINK4.mat'};
LINK_nku = [1051 2 200];
Yeast_info = {'/misc/yeast-splits.mat'};
Yeast_nku = [8 10 200];

AllNames = [AllRegressionNames AllClassNames];

AllClassInfo = {{gaussian_info,gaussian_nku},{sigmoid_info,sigmoid_nku},{softmax_info,softmax_nku}, ...
           {set8_info,set8_nku},{set4_info,set4_nku},{WBC_info,WBC_nku},{ion_info,ion_nku},{set3_info,set3_nku},... 
                {COIL_info,COIL_nku},{LINK_info,LINK_nku}, {set1_info,set1_nku},{set5_info,set5_nku}, {Yeast_info,Yeast_nku}};

AllInfo = [AllRegInfo AllClassInfo];

numDG = length(DataNames);
n_data = []; k_data = []; tu_data = []; dataLoaders = [];  filenames = {};
for i = 1:numDG
    ind = isSubset(DataNames{i},AllNames);
    if isempty(ind)
        error('getDataInfo -> Invalid Dataname! %s\n', DataNames{i});
    end
    % Check if classification dataset or regression
    is_class = 0;
    if ind > length(AllRegInfo)
        is_class = 1;
    end

    % Get the info for that dataset
    infoc = AllInfo{ind}{1};
    nku = AllInfo{ind}{2};
    n_data = [n_data nku(1)]; k_data =[k_data nku(2)]; tu_data = [tu_data nku(3)];
    
    if (length(infoc) == 2)
        dataLoaders = [dataLoaders {@(tl,tu,tt,rep)(loadData(infoc{1},infoc{2},tl,tu,tt,rep,is_class))}];
    else
        dataLoaders = [dataLoaders {@(tl,tu,tt,rep)(loadData(infoc{1},[],tl,tu,tt,rep,is_class))}];      
    end
    
    filenames = [filenames {infoc}];
end  


end
