function example = qMRusage(Model,mstr)
% QMRUSAGE usage and example for qMR objects methods
%   qMRusage(obj) display the usage of all methods available for Model 'obj' 
%
%   qMRusage(obj,MethodName) display only usage of the method MethodName (e.g. fit)
%   
%   Example
%     Model = MWF;
%     qMRusage(Model)
%     qMRusage(Model,'equation')
% 
if nargout, example = ''; end
if nargin<1, help qMRusage, return; end
if nargin<2, mstr=methods(Model); disp(['<strong>Methods available in Model=' class(Model) ':</strong>']); end
if ischar(mstr) && ~moxunit_util_platform_is_octave
    mlist = methods(Model);
    mstr = mlist(~cellfun(@isempty,regexp(mlist,mstr))); 
elseif moxunit_util_platform_is_octave
    mstr = {mstr};
end
try st = Model.st;
catch, try st = (Model.ub + Model.lb)/2; end
end

for im=1:length(mstr)
    mess = {};
    switch mstr{im}
        case 'equation'

            mess = {'Compute MR signal',...
                'USAGE:',...
                '  Smodel = Model.equation(x)',...
                'INPUT:',...
               ['  x: [struct] OR [vector] containing Model (' class(Model) ') parameters: ' cell2str_v2(Model.xnames)],...
                'EXAMPLE:',...
               ['      Model = ' class(Model)],...
               ['      x = struct;']};
            for ix=1:length(Model.xnames)
                mess = {mess{:},...
               ['      x.' Model.xnames{ix} ' = ' num2str(st(ix)) ';']};
            end
            mess = {mess{:},...
                '      Model.equation(x)'};

            
        case 'fit'
            mess = {'Fit experimental data',...
                'USAGE:',...
                '  FitResults = Model.fit(data)',...
                'INPUT:',...
                ['  data: [struct] containing: ' cell2str_v2(Model.MRIinputs)]};
                if Model.voxelwise
                    mess = {mess{:},'NOTE: data are 1D. For 4D datasets use FitData(data,Model)'};
                end
                mess={mess{:},...
                'EXAMPLE:',...
                ['      Model = ' class(Model)],...
                 '      %% LOAD DATA'};
            for ix=1:length(Model.MRIinputs)
                mess = {mess{:},...
                ['      data.' Model.MRIinputs{ix} ' = load_nii_data(''' Model.MRIinputs{ix} '.nii.gz'');']};
            end
                mess = {mess{:},...
                 '      %% FIT A SINGLE VOXEL',...
                 '      % Specific voxel:         datavox = extractvoxel(data,voxel);',...
                 '      % Interactive selection:  datavox = extractvoxel(data);',...
                ['      voxel       = round(size(data.' Model.MRIinputs{1} '(:,:,:,1))/2); % pick FOV center'],...
                 '      datavox     = extractvoxel(data,voxel);',...
                 '      FitResults  = Model.fit(datavox);',...
                 '      Model.plotModel(FitResults, datavox); % plot fit results',...
                 '      %% FIT all voxels',...
                 '      FitResults = FitData(data,Model);',...
                 '      % SAVE results to NIFTI',...
                ['      FitResultsSave_nii(FitResults,''' Model.MRIinputs{1} '.nii.gz''); % use header from ''' Model.MRIinputs{1} '.nii.gz''']};
                %['      Model = ' class(Model)],...
            
        case 'plotModel'

            mess = {'Plot model equation (and fitting)',...
                'USAGE:',...
                '       Model.plotModel(obj, x)',...
                '       Model.plotModel(obj, x, data)',...
                'INPUT:',...
                ['  x: [struct] OR [vector] containing Model (' class(Model) ') parameters: ' cell2str_v2(Model.xnames)],...
                ['  data: [struct] containing: ' cell2str_v2(Model.MRIinputs)],...
                'EXAMPLE:',...
                ['      Model = ' class(Model)],...
                ['      x = struct;']};
            for ix=1:length(Model.xnames)
                mess = {mess{:},...
                ['      x.' Model.xnames{ix} ' = ' num2str(st(ix)) ';']};
            end
            mess = {mess{:},...
                '      Model.plotModel(x)'};
            
        case 'Sim_Single_Voxel_Curve'
            Opt.SNR=50;
            
            try
                Opt = button2opts(Model.Sim_Single_Voxel_Curve_buttons);
                isfieldopt = true;
            catch
                isfieldopt = false;
            end

            mess = {'Simulates Single Voxel curves:',...
                '   (1) use equation to generate synthetic MRI data',...
                '   (2) add rician noise',...
                '   (3) fit and plot curve',...
                'USAGE:',...
                '  FitResults = Model.Sim_Single_Voxel_Curve(x)',...
                '  FitResults = Model.Sim_Single_Voxel_Curve(x, Opt,display)',...
                'INPUT:',...
                ['  x: [struct] OR [vector] containing fit results: ' cell2str_v2(Model.xnames)],...
                 '  display: [binary] 1=display, 0=nodisplay',... 
                 strrep(evalc('Opt'),sprintf(['\nOpt = \n\n']),'  Opt:'),...
                 'EXAMPLE:',...
                ['      Model = ' class(Model)],...
                 '      x = struct;'};
            for ix=1:length(Model.xnames)
                mess = {mess{:},...
                ['      x.' Model.xnames{ix} ' = ' num2str(st(ix)) ';']};
            end
            if isfieldopt
                mess = {mess{:},...
                 '      % Get all possible options',...
                 '      Opt = button2opts(Model.Sim_Single_Voxel_Curve_buttons,1);'};
            else
                mess = {mess{:},...
                '       Opt.SNR = 50;'};
            end
            mess = {mess{:},...
                '      % run simulation using options `Opt(1)`',...
                '      FitResult = Model.Sim_Single_Voxel_Curve(x,Opt(1));'};
            
        case 'Sim_Sensitivity_Analysis'
            Opt.SNR=50;
            try
                Opt = button2opts([Model.Sim_Single_Voxel_Curve_buttons, Model.Sim_Sensitivity_Analysis_buttons]);
                isfieldopt = true;
            catch
                isfieldopt = false;
            end
            mess = {'Simulates sensitivity to fitted parameters:',...
                '   (1) vary fitting parameters from lower (lb) to upper (ub) bound in 10 steps',...
                '   (2) run Sim_Single_Voxel_Curve Nofruns times',...
                '   (3) Compute mean and std across runs',...
                'USAGE:',...
                '  SimVaryResults = Model.Sim_Sensitivity_Analysis(OptTable, Opt);',...
                'INPUT:',...
                '  OptTable: [struct] nominal value and range for each parameter.',... 
               ['     st: [vector] nominal values for ' cell2str_v2(Model.xnames)],...
                '     fx: [binary vector] do not vary this parameter?',...
                '     lb: [vector] vary from lb...',...
                '     ub: [vector] up to ub',...
                 strrep(evalc('Opt'),sprintf(['\nOpt = \n\n']),sprintf('  Opt: [struct] Options of the simulation with fields:\n')),...
                 'EXAMPLE:',...
                ['      Model = ' class(Model)],...
                ['      %              ' sprintf('%-14s',Model.xnames{:})],...
                ['      OptTable.st = [' num2str(st,'%-14.2g') ']; % nominal values'],...
                ['      OptTable.fx = [' num2str([false true(1,length(Model.xnames)-1)],'%-14.0g') ']; %vary ' Model.xnames{1} '...'],...
                ['      OptTable.lb = [' num2str(Model.lb,'%-14.2g') ']; %...from ' num2str(Model.lb(1))],...
                ['      OptTable.ub = [' num2str(Model.ub,'%-14.2g') ']; %...to ' num2str(Model.ub(1))],...
                 };
            if isfieldopt
                mess = {mess{:},...
                 '      % Get all possible options',...
                 '      Opt = button2opts([Model.Sim_Single_Voxel_Curve_buttons, Model.Sim_Sensitivity_Analysis_buttons],1);'};
            else
                mess = {mess{:},...
                '       Opt.SNR = 50;',...
                '       Opt.Nofrun = 5;'};
            end
            mess = {mess{:},...
                '      % run simulation using options `Opt(1)`',...
                '      SimResults = Model.Sim_Sensitivity_Analysis(OptTable,Opt(1));',...
               ['      SimVaryPlot(SimResults, ''' Model.xnames{1} ''' ,''' Model.xnames{1} ''' );']};
    end
    if ~isempty(mess)
        disp(['<strong>' mstr{im} '</strong>'])
        for imess=1:length(mess)
            disp(['   ' mess{imess}])
        end
        disp(' ')
    end
    if nargout
        example = mess((find(~cellfun(@isempty,strfind(mess,'EXAMPLE:')))+1):end);
        example = cell2str_v3(example,sprintf('\n'));
    end
    
end

