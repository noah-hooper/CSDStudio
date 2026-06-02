classdef CSDStudio_2026a < handle
    % =====================================================================
    % CSDStudio 2026a OpenS V6
    %
    % MATLAB GUI for fitting crystal size distribution (CSD) data using
    % 2-Chamber, 3-Chamber, Growth-Law, and Linear CSD models.
    %
    % Noah Hooper, Luke Randall, and Yan Liang
    %#function lsqnonlin
    %#function optimoptions
    %#function optimset
    %#function fitnlm
    % =====================================================================

    properties
        % ================= UI =================
        UIFigure matlab.ui.Figure
        RootGrid matlab.ui.container.GridLayout

        LeftPanel matlab.ui.container.Panel
        LeftGrid matlab.ui.container.GridLayout

        RightPanel matlab.ui.container.Panel
        RightGrid matlab.ui.container.GridLayout

        PlotPanel matlab.ui.container.Panel
        PlotGrid matlab.ui.container.GridLayout

        % File selectors
        DataFileEdit matlab.ui.control.EditField
        DataBrowseButton matlab.ui.control.Button

        ResultsDirEdit matlab.ui.control.EditField
        ResultsDirBrowseButton matlab.ui.control.Button
        UseDataDirCheck matlab.ui.control.CheckBox

        ResultsNameEdit matlab.ui.control.EditField
        ResultsSheetEdit matlab.ui.control.EditField

        OutputFolderEdit matlab.ui.control.EditField
        SavePlotsCheck matlab.ui.control.CheckBox

        % Sample selection
        SampleModeDropDown matlab.ui.control.DropDown
        SheetDropDown matlab.ui.control.DropDown
        RunSheetSelectButton matlab.ui.control.Button
        RunSheetSelection string = string.empty
        RefreshSheetsButton matlab.ui.control.Button
   
        
        CombineSheetSelectButton matlab.ui.control.Button
        CombinedSheetSelection string = string.empty


        % Fit settings
        SolverDropDown matlab.ui.control.DropDown
        NStartsEdit matlab.ui.control.NumericEditField
        MaxIterEdit matlab.ui.control.NumericEditField
        FuncTolEdit matlab.ui.control.NumericEditField
        StepTolEdit matlab.ui.control.NumericEditField

        MCMCIterEdit matlab.ui.control.NumericEditField
        MCMCBurnInEdit matlab.ui.control.NumericEditField
        MCMCStepFracEdit matlab.ui.control.NumericEditField
        MCMCNoiseSigmaEdit matlab.ui.control.NumericEditField
        MCMCSeedEdit matlab.ui.control.NumericEditField
        MCMCSeedRandomizeButton matlab.ui.control.Button
        MCMCUIUpdateStrideEdit matlab.ui.control.NumericEditField
        MCMCPerSheetSeedOffsetCheck matlab.ui.control.CheckBox
        MCMCPlotModeDropDown matlab.ui.control.DropDown
        MCMCShowCredibleBandCheck matlab.ui.control.CheckBox

        ModelTypeDropDown matlab.ui.control.DropDown
        Alpha1Edit matlab.ui.control.NumericEditField
        Alpha2Edit matlab.ui.control.NumericEditField

        % 3-Chamber collapsible settings
        ChamberToggleButton matlab.ui.control.Button
        ChamberPanel matlab.ui.container.Panel
        ChamberGrid matlab.ui.container.GridLayout

        % Growth-Law collapsible settings
        GrowthLawToggleButton matlab.ui.control.Button
        GrowthLawPanel matlab.ui.container.Panel
        GrowthLawGrid matlab.ui.container.GridLayout
        GrowthLawFixN0Check matlab.ui.control.CheckBox
        GrowthLawLnN0Edit matlab.ui.control.NumericEditField

        % ---- piecewise init mode auto/manual ----
        ManualPiecewiseCheck matlab.ui.control.CheckBox

        % ---- manual exclusions ----
        ExcludePointsCheck matlab.ui.control.CheckBox
        PickExcludeButton matlab.ui.control.Button
        ClearExcludeButton matlab.ui.control.Button

        % Run controls
        RunButton matlab.ui.control.Button
        StopButton matlab.ui.control.Button

        % Solver collapsibles
        SolverToggleButton matlab.ui.control.Button
        SolverPanel matlab.ui.container.Panel
        SolverGrid matlab.ui.container.GridLayout
        MCMCSolverToggleButton matlab.ui.control.Button
        MCMCSolverPanel matlab.ui.container.Panel
        MCMCSolverGrid matlab.ui.container.GridLayout

        % Advanced collapsible
        AdvancedToggleButton matlab.ui.control.Button
        AdvancedPanel matlab.ui.container.Panel
        AdvancedGrid matlab.ui.container.GridLayout

        % Axis / style controls
        ClipXCheck matlab.ui.control.CheckBox
        XMinEdit matlab.ui.control.NumericEditField
        XMaxEdit matlab.ui.control.NumericEditField

        ClipYCheck matlab.ui.control.CheckBox
        YMinEdit matlab.ui.control.NumericEditField
        YMaxEdit matlab.ui.control.NumericEditField

        ExtendFitCheck matlab.ui.control.CheckBox
        FitXMaxEdit matlab.ui.control.NumericEditField
        ShowFitLineCheck matlab.ui.control.CheckBox
        StyleShowFitLineCheck matlab.ui.control.CheckBox

        StyleSampleDropDown matlab.ui.control.DropDown
        StyleDisplayNameEdit matlab.ui.control.EditField
        StyleMarkerFaceColorEdit matlab.ui.control.EditField
        StyleMarkerEdgeColorEdit matlab.ui.control.EditField
        StyleMarkerSizeEdit matlab.ui.control.NumericEditField
        StyleMarkerShapeDropDown matlab.ui.control.DropDown
        StyleLineColorEdit matlab.ui.control.EditField
        StyleLineWidthEdit matlab.ui.control.NumericEditField
        StyleLineStyleDropDown matlab.ui.control.DropDown
        GridOnCheck matlab.ui.control.CheckBox

        % Output views
        TabGroup matlab.ui.container.TabGroup
        TabFit matlab.ui.container.Tab
        TabResults matlab.ui.container.Tab
        TabLog matlab.ui.container.Tab

        % Fit tab UI
        FitAxes matlab.ui.control.UIAxes
        FitPlotCard matlab.ui.container.Panel
        ViewSampleDropDown matlab.ui.control.DropDown
        FitOverlayCheck matlab.ui.control.CheckBox
        OverlaySelectButton matlab.ui.control.Button
        OverlaySummaryLabel matlab.ui.control.Label
        PopOutFitButton matlab.ui.control.Button
        FitMetaLabel matlab.ui.control.Label
        ParamStatsPanel matlab.ui.container.Panel
        ParamStatsGrid matlab.ui.container.GridLayout
        ParamStatsLabel matlab.ui.control.Label
        ParamStatsTable matlab.ui.control.Table
        AppendResultsButton matlab.ui.control.Button
        ExportAppendedResultsButton matlab.ui.control.Button
        ExportPlotsButton matlab.ui.control.Button

        ResultsTable matlab.ui.control.Table
        LogTextArea matlab.ui.control.TextArea

        % Detached figure
        FitFigure matlab.ui.Figure
        FitFigureAxes matlab.graphics.axis.Axes
        FitFigureUserOpened logical = false

        % ---------------- Local State ----------------
        % rack the current session,
        % active results, manual selections, and plotting preferences.
        CancelRequested logical = false
        SheetNames string = string.empty
        SolverOpen logical = false
        MCMCSolverOpen logical = false
        ChamberOpen logical = false
        GrowthLawOpen logical = false
        AdvancedOpen logical = true
        PlotPanelOpen logical = true
        LastParamNames string = ["n₁⁰","G₁τ₁","n₂⁰","G₂τ₂","nₘᵢₓ⁰","Gₘᵢₓτₘᵢₓ"]

        % Store per-run results
        RunResults cell = {}
        OverlaySelection string = string.empty
        AppendedResultsData cell = {}
        AppendedResultsList cell = {}

        % Manual maps / style map
        ManualPWMap
        ExcludeMap
        SampleStyleMap
        LastParamStatsResizeWidth double = NaN
    end

    methods
        % Main app constructor. build the UI,
        % apply defaults/theme, then load sheets if a workbook is already set.
        function app = CSDStudio_2026a()
            app.buildUI();
            app.setDefaults();
            app.applyModernTheme();
            app.refreshSheetsSafe();
            app.refreshViewSampleList();
            app.updateParamStatsColumnWidths(false);
            app.log("Ready. Version CSDStudio 2026a.");
        end

        function delete(app)
            try
                if ~isempty(app.FitFigure) && isvalid(app.FitFigure)
                    delete(app.FitFigure);
                end
            catch
            end
            try
                if ~isempty(app.UIFigure) && isvalid(app.UIFigure)
                    delete(app.UIFigure);
                end
            catch
            end
        end
    end

    %% ====================== UI Base ======================
    methods (Access = private)
        % Build the main application window and place all controls in three panes.
        function buildUI(app)
            app.UIFigure = uifigure( ...
                "Name","CSDStudio 2026a", ...
                "Position",[45 55 1840 960]);
            try
                app.UIFigure.AutoResizeChildren = 'off';
                app.UIFigure.SizeChangedFcn = @(s,e)app.onFigureSizeChanged();
            catch
            end

            app.RootGrid = uigridlayout(app.UIFigure,[1 3]);
            app.RootGrid.ColumnWidth = {455,'1x',350};
            app.RootGrid.Padding = [6 6 6 6];
            app.RootGrid.ColumnSpacing = 7;
            try
                figPos = app.UIFigure.Position;
                app.RootGrid.Position = [1 1 figPos(3) figPos(4)];
            catch
            end

            % ---------------- Setup panel ----------------
            app.LeftPanel = uipanel(app.RootGrid,"Title","Setup");
            app.LeftPanel.Layout.Row = 1;
            app.LeftPanel.Layout.Column = 1;
            app.LeftPanel.Scrollable = 'on';

            app.LeftGrid = uigridlayout(app.LeftPanel,[30 3]);
            app.LeftGrid.ColumnWidth = {102,'1x',76};
            app.LeftGrid.RowHeight = { ...
                22,28,28,28,28,28, ...          % data import/export
                22,28,28,28,28, ...             % data selection
                22,28,28,28,1,28,1,28,1,28,1, ... % model/solver + collapsibles
                22,28,28,28, ...                % prep
                22,30,30, 1};                   % run controls + compact filler
            app.LeftGrid.RowSpacing = 6;
            app.LeftGrid.ColumnSpacing = 8;
            app.LeftGrid.Padding = [12 10 12 12];
            app.LeftGrid.Scrollable = 'on';

            r = 1;
            hdr = uilabel(app.LeftGrid,"Text","Data Import / Export","FontWeight","bold","HorizontalAlignment","left");
            hdr.Layout.Row = r; hdr.Layout.Column = [1 3]; r = r + 1;

            lbl = uilabel(app.LeftGrid,"Text","Data file:","HorizontalAlignment","right");
            lbl.Layout.Row = r; lbl.Layout.Column = 1;
            app.DataFileEdit = uieditfield(app.LeftGrid,"text");
            app.DataFileEdit.Layout.Row = r; app.DataFileEdit.Layout.Column = 2;
            app.DataBrowseButton = uibutton(app.LeftGrid,"Text","Browse","ButtonPushedFcn",@(s,e)app.browseData());
            app.DataBrowseButton.Layout.Row = r; app.DataBrowseButton.Layout.Column = 3;
            r = r + 1;

            lbl = uilabel(app.LeftGrid,"Text","Results dir:","HorizontalAlignment","right");
            lbl.Layout.Row = r; lbl.Layout.Column = 1;
            app.ResultsDirEdit = uieditfield(app.LeftGrid,"text");
            app.ResultsDirEdit.Layout.Row = r; app.ResultsDirEdit.Layout.Column = 2;
            app.ResultsDirBrowseButton = uibutton(app.LeftGrid,"Text","Browse","ButtonPushedFcn",@(s,e)app.browseResultsDir());
            app.ResultsDirBrowseButton.Layout.Row = r; app.ResultsDirBrowseButton.Layout.Column = 3;
            r = r + 1;

            app.UseDataDirCheck = uicheckbox(app.LeftGrid, ...
                "Text","Use data-file directory", ...
                "Value",true, ...
                "ValueChangedFcn",@(s,e)app.onUseDataDirChanged());
            app.UseDataDirCheck.Layout.Row = r; app.UseDataDirCheck.Layout.Column = [2 3];
            r = r + 1;

            lbl = uilabel(app.LeftGrid,"Text","Output folder:","HorizontalAlignment","right");
            lbl.Layout.Row = r; lbl.Layout.Column = 1;
            app.OutputFolderEdit = uieditfield(app.LeftGrid,"text");
            app.OutputFolderEdit.Layout.Row = r; app.OutputFolderEdit.Layout.Column = [2 3];
            r = r + 1;

            app.RefreshSheetsButton = uibutton(app.LeftGrid,"Text","Refresh sheets","ButtonPushedFcn",@(s,e)app.refreshSheetsSafe());
            app.RefreshSheetsButton.Layout.Row = r; app.RefreshSheetsButton.Layout.Column = [2 3];
            r = r + 1;

            hdr = uilabel(app.LeftGrid,"Text","Data Selection","FontWeight","bold","HorizontalAlignment","left");
            hdr.Layout.Row = r; hdr.Layout.Column = [1 3]; r = r + 1;

            lbl = uilabel(app.LeftGrid,"Text","Run mode:","HorizontalAlignment","right");
            lbl.Layout.Row = r; lbl.Layout.Column = 1;
            app.SampleModeDropDown = uidropdown(app.LeftGrid, ...
                "Items",{'Single sheet','Selected sheets','Combine sheets','All sheets'}, ...
                "Value",'Single sheet', ...
                "ValueChangedFcn",@(s,e)app.onModeChanged());
            app.SampleModeDropDown.Layout.Row = r; app.SampleModeDropDown.Layout.Column = [2 3];
            r = r + 1;

            lbl = uilabel(app.LeftGrid,"Text","Sheet:","HorizontalAlignment","right");
            lbl.Layout.Row = r; lbl.Layout.Column = 1;
            app.SheetDropDown = uidropdown(app.LeftGrid,"Items",{}, "ValueChangedFcn",@(s,e)app.previewSelectedSheet());
            app.SheetDropDown.Layout.Row = r; app.SheetDropDown.Layout.Column = [2 3];
            r = r + 1;

            lbl = uilabel(app.LeftGrid,"Text","","HorizontalAlignment","right");
            lbl.Layout.Row = r; lbl.Layout.Column = 1;
            app.RunSheetSelectButton = uibutton(app.LeftGrid, ...
                "Text","Choose run sheets", ...
                "Enable","off", ...
                "ButtonPushedFcn",@(s,e)app.chooseRunSheets());
            app.RunSheetSelectButton.Layout.Row = r; app.RunSheetSelectButton.Layout.Column = [2 3];
            r = r + 1;

            lbl = uilabel(app.LeftGrid,"Text","","HorizontalAlignment","right");
            lbl.Layout.Row = r; lbl.Layout.Column = 1;
            app.CombineSheetSelectButton = uibutton(app.LeftGrid, ...
                "Text","Choose combined sheets", ...
                "Enable","off", ...
                "ButtonPushedFcn",@(s,e)app.chooseCombinedSheets());
            app.CombineSheetSelectButton.Layout.Row = r; app.CombineSheetSelectButton.Layout.Column = [2 3];
            r = r + 1;

            hdr = uilabel(app.LeftGrid,"Text","Model and Solver Settings","FontWeight","bold","HorizontalAlignment","left");
            hdr.Layout.Row = r; hdr.Layout.Column = [1 3]; r = r + 1;

            lbl = uilabel(app.LeftGrid,"Text","Model:","HorizontalAlignment","right");
            lbl.Layout.Row = r; lbl.Layout.Column = 1;
            app.ModelTypeDropDown = uidropdown(app.LeftGrid, ...
                "Items",{'2-Chamber','3-Chamber','Growth-Law','Linear'}, ...
                "Value",'2-Chamber', ...
                "ValueChangedFcn",@(s,e)app.onModelTypeChanged());
            app.ModelTypeDropDown.Layout.Row = r; app.ModelTypeDropDown.Layout.Column = [2 3];
            r = r + 1;

            lbl = uilabel(app.LeftGrid,"Text","Solver:","HorizontalAlignment","right");
            lbl.Layout.Row = r; lbl.Layout.Column = 1;
            app.SolverDropDown = uidropdown(app.LeftGrid, ...
                "Items",{'NL Inversion','MCMC'}, ...
                "Value",'NL Inversion', ...
                "ValueChangedFcn",@(s,e)app.onSolverTypeChanged());
            app.SolverDropDown.Layout.Row = r; app.SolverDropDown.Layout.Column = [2 3];
            r = r + 1;

            app.ChamberToggleButton = uibutton(app.LeftGrid, ...
                "Text","3-Chamber settings ▸", ...
                "Enable","off", ...
                "ButtonPushedFcn",@(s,e)app.toggleChamberPanel());
            app.ChamberToggleButton.Layout.Row = r; app.ChamberToggleButton.Layout.Column = [2 3];
            r = r + 1;

            app.ChamberPanel = uipanel(app.LeftGrid,"Title","3-Chamber settings","Visible","off");
            app.ChamberPanel.Layout.Row = r; app.ChamberPanel.Layout.Column = [1 3];
            app.ChamberGrid = uigridlayout(app.ChamberPanel,[2 2]);
            app.ChamberGrid.ColumnWidth = {112,'1x'};
            app.ChamberGrid.RowHeight = {26,26};
            app.ChamberGrid.RowSpacing = 6;
            app.ChamberGrid.Padding = [10 8 10 10];
            lbl = uilabel(app.ChamberGrid,"Text","alpha1:","HorizontalAlignment","right");
            lbl.Layout.Row = 1; lbl.Layout.Column = 1;
            app.Alpha1Edit = uieditfield(app.ChamberGrid,"numeric", ...
                "Limits",[0 1], ...
                "ValueDisplayFormat","%.4g", ...
                "ValueChangedFcn",@(s,e)app.onAlpha1Changed());
            app.Alpha1Edit.Layout.Row = 1; app.Alpha1Edit.Layout.Column = 2;
            lbl = uilabel(app.ChamberGrid,"Text","alpha2:","HorizontalAlignment","right");
            lbl.Layout.Row = 2; lbl.Layout.Column = 1;
            app.Alpha2Edit = uieditfield(app.ChamberGrid,"numeric", ...
                "Editable","off", ...
                "ValueDisplayFormat","%.4g");
            app.Alpha2Edit.Layout.Row = 2; app.Alpha2Edit.Layout.Column = 2;
            r = r + 1;

            app.GrowthLawToggleButton = uibutton(app.LeftGrid, ...
                "Text","Growth-Law settings ▸", ...
                "Enable","off", ...
                "ButtonPushedFcn",@(s,e)app.toggleGrowthLawPanel());
            app.GrowthLawToggleButton.Layout.Row = r; app.GrowthLawToggleButton.Layout.Column = [2 3];
            r = r + 1;

            app.GrowthLawPanel = uipanel(app.LeftGrid,"Title","Growth-Law settings","Visible","off");
            app.GrowthLawPanel.Layout.Row = r; app.GrowthLawPanel.Layout.Column = [1 3];
            app.GrowthLawGrid = uigridlayout(app.GrowthLawPanel,[1 2]);
            app.GrowthLawGrid.ColumnWidth = {112,'1x'};
            app.GrowthLawGrid.RowHeight = {26};
            app.GrowthLawGrid.RowSpacing = 6;
            app.GrowthLawGrid.Padding = [10 8 10 10];
            app.GrowthLawFixN0Check = uicheckbox(app.GrowthLawGrid, ...
                "Text","Fix ln(n0)", ...
                "Value",false, ...
                "ValueChangedFcn",@(s,e)app.onGrowthLawFixN0Changed());
            app.GrowthLawFixN0Check.Layout.Row = 1; app.GrowthLawFixN0Check.Layout.Column = 1;
            app.GrowthLawLnN0Edit = uieditfield(app.GrowthLawGrid,"numeric", ...
                "ValueDisplayFormat","%.5g", ...
                "Enable","off", ...
                "ValueChangedFcn",@(s,e)app.onGrowthLawFixN0Changed());
            app.GrowthLawLnN0Edit.Layout.Row = 1; app.GrowthLawLnN0Edit.Layout.Column = 2;
            r = r + 1;

            app.SolverToggleButton = uibutton(app.LeftGrid, ...
                "Text","NL Solver Options ▸", ...
                "ButtonPushedFcn",@(s,e)app.toggleNLSolverPanel());
            app.SolverToggleButton.Layout.Row = r; app.SolverToggleButton.Layout.Column = [2 3];
            r = r + 1;

            app.SolverPanel = uipanel(app.LeftGrid,"Title","NL Solver Options","Visible","off");
            app.SolverPanel.Layout.Row = r; app.SolverPanel.Layout.Column = [1 3];
            app.SolverPanel.Scrollable = 'on';
            app.SolverGrid = uigridlayout(app.SolverPanel,[4 2]);
            app.SolverGrid.ColumnWidth = {118,'1x'};
            app.SolverGrid.RowHeight = repmat({26},1,4);
            app.SolverGrid.RowSpacing = 6;
            app.SolverGrid.Padding = [10 8 10 10];
            lbl = uilabel(app.SolverGrid,"Text","NL starts:","HorizontalAlignment","right");
            lbl.Layout.Row = 1; lbl.Layout.Column = 1;
            app.NStartsEdit = uieditfield(app.SolverGrid,"numeric","Limits",[1 inf],"RoundFractionalValues","on");
            app.NStartsEdit.Layout.Row = 1; app.NStartsEdit.Layout.Column = 2;
            lbl = uilabel(app.SolverGrid,"Text","NL max iter:","HorizontalAlignment","right");
            lbl.Layout.Row = 2; lbl.Layout.Column = 1;
            app.MaxIterEdit = uieditfield(app.SolverGrid,"numeric","Limits",[1 inf],"RoundFractionalValues","on");
            app.MaxIterEdit.Layout.Row = 2; app.MaxIterEdit.Layout.Column = 2;
            lbl = uilabel(app.SolverGrid,"Text","NL func tol:","HorizontalAlignment","right");
            lbl.Layout.Row = 3; lbl.Layout.Column = 1;
            app.FuncTolEdit = uieditfield(app.SolverGrid,"numeric","Limits",[0 inf],"ValueDisplayFormat","%.4g");
            app.FuncTolEdit.Layout.Row = 3; app.FuncTolEdit.Layout.Column = 2;
            lbl = uilabel(app.SolverGrid,"Text","NL step tol:","HorizontalAlignment","right");
            lbl.Layout.Row = 4; lbl.Layout.Column = 1;
            app.StepTolEdit = uieditfield(app.SolverGrid,"numeric","Limits",[0 inf],"ValueDisplayFormat","%.4g");
            app.StepTolEdit.Layout.Row = 4; app.StepTolEdit.Layout.Column = 2;
            r = r + 1;

            app.MCMCSolverToggleButton = uibutton(app.LeftGrid, ...
                "Text","MCMC Solver Options ▸", ...
                "Enable","off", ...
                "ButtonPushedFcn",@(s,e)app.toggleMCMCSolverPanel());
            app.MCMCSolverToggleButton.Layout.Row = r; app.MCMCSolverToggleButton.Layout.Column = [2 3];
            r = r + 1;

            app.MCMCSolverPanel = uipanel(app.LeftGrid,"Title","MCMC Solver Options","Visible","off");
            app.MCMCSolverPanel.Layout.Row = r; app.MCMCSolverPanel.Layout.Column = [1 3];
            app.MCMCSolverPanel.Scrollable = 'on';
            app.MCMCSolverGrid = uigridlayout(app.MCMCSolverPanel,[8 2]);
            app.MCMCSolverGrid.ColumnWidth = {118,'1x'};
            app.MCMCSolverGrid.RowHeight = repmat({26},1,8);
            app.MCMCSolverGrid.RowSpacing = 6;
            app.MCMCSolverGrid.Padding = [10 8 10 10];
            lbl = uilabel(app.MCMCSolverGrid,"Text","MCMC iterations:","HorizontalAlignment","right");
            lbl.Layout.Row = 1; lbl.Layout.Column = 1;
            app.MCMCIterEdit = uieditfield(app.MCMCSolverGrid,"numeric","Limits",[100 inf],"RoundFractionalValues","on");
            app.MCMCIterEdit.Layout.Row = 1; app.MCMCIterEdit.Layout.Column = 2;
            lbl = uilabel(app.MCMCSolverGrid,"Text","MCMC burn-in:","HorizontalAlignment","right");
            lbl.Layout.Row = 2; lbl.Layout.Column = 1;
            app.MCMCBurnInEdit = uieditfield(app.MCMCSolverGrid,"numeric","Limits",[0 inf],"RoundFractionalValues","on");
            app.MCMCBurnInEdit.Layout.Row = 2; app.MCMCBurnInEdit.Layout.Column = 2;
            lbl = uilabel(app.MCMCSolverGrid,"Text","MCMC step frac:","HorizontalAlignment","right");
            lbl.Layout.Row = 3; lbl.Layout.Column = 1;
            app.MCMCStepFracEdit = uieditfield(app.MCMCSolverGrid,"numeric","Limits",[1e-6 10],"ValueDisplayFormat","%.4g");
            app.MCMCStepFracEdit.Layout.Row = 3; app.MCMCStepFracEdit.Layout.Column = 2;
            lbl = uilabel(app.MCMCSolverGrid,"Text","MCMC noise σ:","HorizontalAlignment","right");
            lbl.Layout.Row = 4; lbl.Layout.Column = 1;
            app.MCMCNoiseSigmaEdit = uieditfield(app.MCMCSolverGrid,"numeric","Limits",[1e-12 inf],"ValueDisplayFormat","%.4g");
            app.MCMCNoiseSigmaEdit.Layout.Row = 4; app.MCMCNoiseSigmaEdit.Layout.Column = 2;
            lbl = uilabel(app.MCMCSolverGrid,"Text","MCMC seed:","HorizontalAlignment","right");
            lbl.Layout.Row = 5; lbl.Layout.Column = 1;
            app.MCMCSeedEdit = uieditfield(app.MCMCSolverGrid,"numeric","Limits",[0 2^31-1],"RoundFractionalValues","on");
            app.MCMCSeedEdit.Layout.Row = 5; app.MCMCSeedEdit.Layout.Column = 2;
            app.MCMCSeedRandomizeButton = uibutton(app.MCMCSolverGrid, ...
                "Text","Randomize MCMC seed", ...
                "ButtonPushedFcn",@(s,e)app.randomizeMCMCSeed());
            app.MCMCSeedRandomizeButton.Layout.Row = 6; app.MCMCSeedRandomizeButton.Layout.Column = [1 2];
            lbl = uilabel(app.MCMCSolverGrid,"Text","MCMC UI stride:","HorizontalAlignment","right");
            lbl.Layout.Row = 7; lbl.Layout.Column = 1;
            app.MCMCUIUpdateStrideEdit = uieditfield(app.MCMCSolverGrid,"numeric","Limits",[10 inf],"RoundFractionalValues","on","ValueDisplayFormat","%.0f");
            app.MCMCUIUpdateStrideEdit.Layout.Row = 7; app.MCMCUIUpdateStrideEdit.Layout.Column = 2;
            app.MCMCPerSheetSeedOffsetCheck = uicheckbox(app.MCMCSolverGrid, ...
                "Text","Offset seed per sheet", ...
                "Value",true);
            app.MCMCPerSheetSeedOffsetCheck.Layout.Row = 8; app.MCMCPerSheetSeedOffsetCheck.Layout.Column = [1 2];
            r = r + 1;

            hdr = uilabel(app.LeftGrid,"Text","Piecewise Initialization and Data Exclusion","FontWeight","bold","HorizontalAlignment","left");
            hdr.Layout.Row = r; hdr.Layout.Column = [1 3]; r = r + 1;

            app.ManualPiecewiseCheck = uicheckbox(app.LeftGrid, ...
                "Text","Manual piecewise (recommended)", ...
                "Value",false, ...
                "ValueChangedFcn",@(s,e)app.onManualPiecewiseChanged());
            app.ManualPiecewiseCheck.Layout.Row = r; app.ManualPiecewiseCheck.Layout.Column = [2 3];
            r = r + 1;

            app.ExcludePointsCheck = uicheckbox(app.LeftGrid, ...
                "Text","Exclude points (click to remove)", ...
                "Value",false, ...
                "ValueChangedFcn",@(s,e)app.onExcludePointsChanged());
            app.ExcludePointsCheck.Layout.Row = r; app.ExcludePointsCheck.Layout.Column = [2 3];
            r = r + 1;

            app.PickExcludeButton = uibutton(app.LeftGrid, ...
                "Text","Pick exclusions", ...
                "Enable","off", ...
                "ButtonPushedFcn",@(s,e)app.pickExcludePressed());
            app.PickExcludeButton.Layout.Row = r; app.PickExcludeButton.Layout.Column = 2;
            app.ClearExcludeButton = uibutton(app.LeftGrid, ...
                "Text","Clear", ...
                "Enable","off", ...
                "ButtonPushedFcn",@(s,e)app.clearExcludePressed());
            app.ClearExcludeButton.Layout.Row = r; app.ClearExcludeButton.Layout.Column = 3;
            r = r + 1;

            hdr = uilabel(app.LeftGrid,"Text","Run Controls","FontWeight","bold","HorizontalAlignment","left");
            hdr.Layout.Row = r; hdr.Layout.Column = [1 3]; r = r + 1;

            app.RunButton = uibutton(app.LeftGrid, ...
                "Text","Run", ...
                "ButtonPushedFcn",@(s,e)app.runPressed());
            app.RunButton.Layout.Row = r; app.RunButton.Layout.Column = [2 3];
            r = r + 1;

            app.StopButton = uibutton(app.LeftGrid, ...
                "Text","Stop", ...
                "Enable","off", ...
                "ButtonPushedFcn",@(s,e)app.stopPressed());
            app.StopButton.Layout.Row = r; app.StopButton.Layout.Column = [2 3];

            % ---------------- Plotting panel ----------------
            app.buildPlottingPanel();

            % ---------------- Workspace panel ----------------
            app.RightPanel = uipanel(app.RootGrid,"Title","Workspace");
            app.RightPanel.Layout.Row = 1;
            app.RightPanel.Layout.Column = 2;

            app.RightGrid = uigridlayout(app.RightPanel,[1 1]);
            app.RightGrid.Padding = [4 4 4 4];
            app.RightGrid.RowSpacing = 0;
            app.RightGrid.ColumnSpacing = 0;

            app.TabGroup = uitabgroup(app.RightGrid);
            app.TabFit     = uitab(app.TabGroup,"Title","Fit");
            app.TabResults = uitab(app.TabGroup,"Title","Results");
            app.TabLog     = uitab(app.TabGroup,"Title","Log");

            fitTabGrid = uigridlayout(app.TabFit,[3 1]);
            fitTabGrid.RowHeight = {210,68,'1x'};
            fitTabGrid.ColumnWidth = {'1x'};
            fitTabGrid.RowSpacing = 5;
            fitTabGrid.Padding = [6 6 6 6];

            app.ParamStatsPanel = uipanel(fitTabGrid,"Title","Parameter Summary");
            app.ParamStatsPanel.Layout.Row = 1;
            app.ParamStatsPanel.Layout.Column = 1;
            app.ParamStatsGrid = uigridlayout(app.ParamStatsPanel,[2 2]);
            paramStatsGrid = app.ParamStatsGrid;
            paramStatsGrid.RowHeight = {24,'1x'};
            paramStatsGrid.ColumnWidth = {'1x',150};
            paramStatsGrid.RowSpacing = 4;
            paramStatsGrid.ColumnSpacing = 8;
            paramStatsGrid.Padding = [10 6 10 8];

            app.ParamStatsLabel = uilabel(paramStatsGrid, ...
                "Text","Run a fit to show parameter estimates, uncertainty metrics, and diagnostics.", ...
                "HorizontalAlignment","left", ...
                "FontWeight","bold");
            app.ParamStatsLabel.Layout.Row = 1;
            app.ParamStatsLabel.Layout.Column = [1 2];
            app.ParamStatsTable = uitable(paramStatsGrid);
            app.ParamStatsTable.Layout.Row = 2;
            app.ParamStatsTable.Layout.Column = 1;

            actionGrid = uigridlayout(paramStatsGrid,[4 1]);
            actionGrid.Layout.Row = 2;
            actionGrid.Layout.Column = 2;
            actionGrid.RowHeight = {28,28,28,'1x'};
            actionGrid.ColumnWidth = {'1x'};
            actionGrid.RowSpacing = 6;
            actionGrid.Padding = [0 0 0 0];
            app.AppendResultsButton = uibutton(actionGrid, ...
                "Text","Append to Results", ...
                "ButtonPushedFcn",@(s,e)app.appendCurrentFitToResults());
            app.AppendResultsButton.Layout.Row = 1;
            app.AppendResultsButton.Layout.Column = 1;
            app.ExportAppendedResultsButton = uibutton(actionGrid, ...
                "Text","Export results", ...
                "ButtonPushedFcn",@(s,e)app.exportAppendedResultsToExcel());
            app.ExportAppendedResultsButton.Layout.Row = 2;
            app.ExportAppendedResultsButton.Layout.Column = 1;
            app.ExportPlotsButton = uibutton(actionGrid, ...
                "Text","Export plots", ...
                "ButtonPushedFcn",@(s,e)app.exportPlotsPressed());
            app.ExportPlotsButton.Layout.Row = 3;
            app.ExportPlotsButton.Layout.Column = 1;

            app.ParamStatsTable.ColumnEditable = false;
            app.ParamStatsTable.ColumnName = {'Sample','Parameter','Best Fit','SE','tStat','pValue'};
            app.ParamStatsTable.ColumnWidth = {240,260,150,150,150,150};
            app.ParamStatsTable.Data = {};
            app.ParamStatsTable.Visible = 'off';
            app.ParamStatsLabel.Text = "Complete a run to show fitted parameters.";
            app.updateParamStatsColumnWidths(false);

            topPanel = uipanel(fitTabGrid,"Title","Fit View");
            topPanel.Layout.Row = 2;
            topPanel.Layout.Column = 1;
            fitViewGrid = uigridlayout(topPanel,[1 6]);
            fitViewGrid.ColumnWidth = {55,260,90,150,'1x',130};
            fitViewGrid.RowHeight = {'1x'};
            fitViewGrid.ColumnSpacing = 8;
            fitViewGrid.Padding = [12 8 12 8];

            lbl = uilabel(fitViewGrid,"Text","View:", ...
                "HorizontalAlignment","left","FontWeight","bold");
            lbl.Layout.Row = 1; lbl.Layout.Column = 1;
            app.ViewSampleDropDown = uidropdown(fitViewGrid, ...
                "Items",{'(no results yet)'}, ...
                "Value",'(no results yet)', ...
                "Enable","off", ...
                "ValueChangedFcn",@(s,e)app.onViewSampleChanged());
            app.ViewSampleDropDown.Layout.Row = 1;
            app.ViewSampleDropDown.Layout.Column = 2;
            app.FitOverlayCheck = uicheckbox(fitViewGrid, ...
                "Text","Overlay", ...
                "Value",false, ...
                "ValueChangedFcn",@(s,e)app.onFitViewControlChanged());
            app.FitOverlayCheck.Layout.Row = 1;
            app.FitOverlayCheck.Layout.Column = 3;
            app.OverlaySelectButton = uibutton(fitViewGrid, ...
                "Text","Choose overlays", ...
                "Enable","off", ...
                "ButtonPushedFcn",@(s,e)app.chooseOverlaySamples());
            app.OverlaySelectButton.Layout.Row = 1;
            app.OverlaySelectButton.Layout.Column = 4;
            app.OverlaySummaryLabel = uilabel(fitViewGrid,"Text","", ...
                "HorizontalAlignment","left");
            app.OverlaySummaryLabel.Layout.Row = 1;
            app.OverlaySummaryLabel.Layout.Column = 5;
            app.PopOutFitButton = uibutton(fitViewGrid, ...
                "Text","Pop out", ...
                "ButtonPushedFcn",@(s,e)app.popOutFitPressed());
            app.PopOutFitButton.Layout.Row = 1;
            app.PopOutFitButton.Layout.Column = 6;

            app.FitPlotCard = uipanel(fitTabGrid,"Title","Model Fit");
            app.FitPlotCard.Layout.Row = 3;
            app.FitPlotCard.Layout.Column = 1;
            fitPlotGrid = uigridlayout(app.FitPlotCard,[2 1]);
            fitPlotGrid.RowHeight = {22,'1x'};
            fitPlotGrid.ColumnWidth = {'1x'};
            fitPlotGrid.RowSpacing = 5;
            fitPlotGrid.Padding = [14 8 14 14];
            app.FitMetaLabel = uilabel(fitPlotGrid,"Text","", ...
                "HorizontalAlignment","left");
            app.FitMetaLabel.Layout.Row = 1;
            app.FitMetaLabel.Layout.Column = 1;
            app.FitAxes = uiaxes(fitPlotGrid);
            app.FitAxes.Layout.Row = 2;
            app.FitAxes.Layout.Column = 1;
            app.FitAxes.FontSize = 15;
            app.FitAxes.Box = 'on';
            xlabel(app.FitAxes,"L (mm)");
            ylabel(app.FitAxes,"ln(n) mm^{-4}");

            resultsGrid = uigridlayout(app.TabResults,[1 1]);
            resultsGrid.Padding = [8 8 8 8];
            app.ResultsTable = uitable(resultsGrid);
            app.ResultsTable.Layout.Row = 1;
            app.ResultsTable.Layout.Column = 1;
            app.ResultsTable.ColumnEditable = false;
            app.ResultsTable.ColumnName = app.getAppendedResultsHeaders();
            app.ResultsTable.Data = {};

            logGrid = uigridlayout(app.TabLog,[1 1]);
            logGrid.Padding = [8 8 8 8];
            app.LogTextArea = uitextarea(logGrid,"Editable","off");
            app.LogTextArea.Layout.Row = 1;
            app.LogTextArea.Layout.Column = 1;
            app.LogTextArea.Value = "";

            fsLeft  = 14;
            fsRight = 14;
            setFontRecursive(app.LeftPanel, fsLeft);
            setFontRecursive(app.RightPanel, fsRight);
            setFontRecursive(app.PlotPanel, fsLeft);

            try
                app.onFigureSizeChanged();
            catch
            end

            function setFontRecursive(h, fs)
                if isempty(h) || ~isvalid(h); return; end
                try
                    if isprop(h,'FontSize'); h.FontSize = fs; end
                catch
                end
                try
                    kids = h.Children;
                catch
                    kids = [];
                end
                for kk = 1:numel(kids)
                    setFontRecursive(kids(kk), fs);
                end
            end
        end

        % Build the right-side plotting display
        function buildPlottingPanel(app)
            app.PlotPanel = uipanel(app.RootGrid,"Title","Plotting");
            app.PlotPanel.Layout.Row = 1;
            app.PlotPanel.Layout.Column = 3;
            app.PlotPanel.Scrollable = 'on';

            app.PlotGrid = uigridlayout(app.PlotPanel,[2 1]);
            app.PlotGrid.ColumnWidth = {'1x'};
            app.PlotGrid.RowHeight = {32,'1x'};
            app.PlotGrid.RowSpacing = 7;
            app.PlotGrid.Padding = [10 10 10 10];
            app.PlotGrid.Scrollable = 'on';

            app.AdvancedToggleButton = uibutton(app.PlotGrid, ...
                "Text","Collapse plotting ▸", ...
                "Tooltip","Collapse or expand the plotting inspector", ...
                "ButtonPushedFcn",@(s,e)app.toggleAdvanced());
            app.AdvancedToggleButton.Layout.Row = 1;
            app.AdvancedToggleButton.Layout.Column = 1;

            app.AdvancedPanel = uipanel(app.PlotGrid,"Title","Display Options","Visible","on");
            app.AdvancedPanel.Layout.Row = 2;
            app.AdvancedPanel.Layout.Column = 1;
            app.AdvancedPanel.Scrollable = 'on';
            app.AdvancedOpen = true;
            app.PlotPanelOpen = true;

            app.AdvancedGrid = uigridlayout(app.AdvancedPanel,[32 2]);
            app.AdvancedGrid.Scrollable = 'on';
            app.AdvancedGrid.ColumnWidth = {114,'1x'};
            app.AdvancedGrid.RowHeight = { ...
                22,28,28,28,28,28,28, ...       % axis
                22,28,28,28,28,28,28,28,28, ... % marker/sample
                22,28,28,28,28,28,28, ...       % line/fit
                22,28,28, ...                   % mcmc
                1,1,1,1,1,1};
            app.AdvancedGrid.RowSpacing = 5;
            app.AdvancedGrid.ColumnSpacing = 8;
            app.AdvancedGrid.Padding = [10 8 10 10];

            r = 1;
            hdr = uilabel(app.AdvancedGrid,"Text","Axis Limits","FontWeight","bold","HorizontalAlignment","left");
            hdr.Layout.Row = r; hdr.Layout.Column = [1 2]; r = r + 1;

            app.ClipXCheck = uicheckbox(app.AdvancedGrid, ...
                "Text","Clip X-axis", ...
                "Value",false, ...
                "ValueChangedFcn",@(s,e)app.onAxisControlChanged());
            app.ClipXCheck.Layout.Row = r; app.ClipXCheck.Layout.Column = [1 2]; r = r + 1;
            lbl = uilabel(app.AdvancedGrid,"Text","X min:","HorizontalAlignment","right");
            lbl.Layout.Row = r; lbl.Layout.Column = 1;
            app.XMinEdit = uieditfield(app.AdvancedGrid,"numeric","ValueDisplayFormat","%.4g", ...
                "ValueChangedFcn",@(s,e)app.onAxisControlChanged());
            app.XMinEdit.Layout.Row = r; app.XMinEdit.Layout.Column = 2; r = r + 1;
            lbl = uilabel(app.AdvancedGrid,"Text","X max:","HorizontalAlignment","right");
            lbl.Layout.Row = r; lbl.Layout.Column = 1;
            app.XMaxEdit = uieditfield(app.AdvancedGrid,"numeric","ValueDisplayFormat","%.4g", ...
                "ValueChangedFcn",@(s,e)app.onAxisControlChanged());
            app.XMaxEdit.Layout.Row = r; app.XMaxEdit.Layout.Column = 2; r = r + 1;
            app.ClipYCheck = uicheckbox(app.AdvancedGrid, ...
                "Text","Clip Y-axis", ...
                "Value",false, ...
                "ValueChangedFcn",@(s,e)app.onAxisControlChanged());
            app.ClipYCheck.Layout.Row = r; app.ClipYCheck.Layout.Column = [1 2]; r = r + 1;
            lbl = uilabel(app.AdvancedGrid,"Text","Y min:","HorizontalAlignment","right");
            lbl.Layout.Row = r; lbl.Layout.Column = 1;
            app.YMinEdit = uieditfield(app.AdvancedGrid,"numeric","ValueDisplayFormat","%.4g", ...
                "ValueChangedFcn",@(s,e)app.onAxisControlChanged());
            app.YMinEdit.Layout.Row = r; app.YMinEdit.Layout.Column = 2; r = r + 1;
            lbl = uilabel(app.AdvancedGrid,"Text","Y max:","HorizontalAlignment","right");
            lbl.Layout.Row = r; lbl.Layout.Column = 1;
            app.YMaxEdit = uieditfield(app.AdvancedGrid,"numeric","ValueDisplayFormat","%.4g", ...
                "ValueChangedFcn",@(s,e)app.onAxisControlChanged());
            app.YMaxEdit.Layout.Row = r; app.YMaxEdit.Layout.Column = 2; r = r + 1;

            hdr = uilabel(app.AdvancedGrid,"Text","Marker Style","FontWeight","bold","HorizontalAlignment","left");
            hdr.Layout.Row = r; hdr.Layout.Column = [1 2]; r = r + 1;

            lbl = uilabel(app.AdvancedGrid,"Text","Sample:","HorizontalAlignment","right");
            lbl.Layout.Row = r; lbl.Layout.Column = 1;
            app.StyleSampleDropDown = uidropdown(app.AdvancedGrid, ...
                "Items",{'(no results yet)'}, ...
                "Value",'(no results yet)', ...
                "Enable","off", ...
                "ValueChangedFcn",@(s,e)app.onStyleSampleChanged());
            app.StyleSampleDropDown.Layout.Row = r; app.StyleSampleDropDown.Layout.Column = 2; r = r + 1;
            lbl = uilabel(app.AdvancedGrid,"Text","Display name:","HorizontalAlignment","right");
            lbl.Layout.Row = r; lbl.Layout.Column = 1;
            app.StyleDisplayNameEdit = uieditfield(app.AdvancedGrid,"text", ...
                "ValueChangedFcn",@(s,e)app.onStyleControlChanged());
            app.StyleDisplayNameEdit.Layout.Row = r; app.StyleDisplayNameEdit.Layout.Column = 2; r = r + 1;
            lbl = uilabel(app.AdvancedGrid,"Text","Marker face:","HorizontalAlignment","right");
            lbl.Layout.Row = r; lbl.Layout.Column = 1;
            app.StyleMarkerFaceColorEdit = uieditfield(app.AdvancedGrid,"text", ...
                "ValueChangedFcn",@(s,e)app.onStyleControlChanged());
            app.StyleMarkerFaceColorEdit.Layout.Row = r; app.StyleMarkerFaceColorEdit.Layout.Column = 2; r = r + 1;
            lbl = uilabel(app.AdvancedGrid,"Text","Marker edge:","HorizontalAlignment","right");
            lbl.Layout.Row = r; lbl.Layout.Column = 1;
            app.StyleMarkerEdgeColorEdit = uieditfield(app.AdvancedGrid,"text", ...
                "ValueChangedFcn",@(s,e)app.onStyleControlChanged());
            app.StyleMarkerEdgeColorEdit.Layout.Row = r; app.StyleMarkerEdgeColorEdit.Layout.Column = 2; r = r + 1;
            lbl = uilabel(app.AdvancedGrid,"Text","Marker size:","HorizontalAlignment","right");
            lbl.Layout.Row = r; lbl.Layout.Column = 1;
            app.StyleMarkerSizeEdit = uieditfield(app.AdvancedGrid,"numeric", ...
                "Limits",[1 inf], ...
                "ValueChangedFcn",@(s,e)app.onStyleControlChanged());
            app.StyleMarkerSizeEdit.Layout.Row = r; app.StyleMarkerSizeEdit.Layout.Column = 2; r = r + 1;
            lbl = uilabel(app.AdvancedGrid,"Text","Marker shape:","HorizontalAlignment","right");
            lbl.Layout.Row = r; lbl.Layout.Column = 1;
            app.StyleMarkerShapeDropDown = uidropdown(app.AdvancedGrid, ...
                "Items",{'o','s','d','^','v','>','<','p','h','x','+','*'}, ...
                "Value",'o', ...
                "ValueChangedFcn",@(s,e)app.onStyleControlChanged());
            app.StyleMarkerShapeDropDown.Layout.Row = r; app.StyleMarkerShapeDropDown.Layout.Column = 2; r = r + 1;
            app.StyleShowFitLineCheck = uicheckbox(app.AdvancedGrid, ...
                "Text","Show fit line for selected run", ...
                "Value",true, ...
                "ValueChangedFcn",@(s,e)app.onStyleControlChanged());
            app.StyleShowFitLineCheck.Layout.Row = r; app.StyleShowFitLineCheck.Layout.Column = [1 2]; r = r + 1;
            app.GridOnCheck = uicheckbox(app.AdvancedGrid, ...
                "Text","Show grid", ...
                "Value",true, ...
                "ValueChangedFcn",@(s,e)app.onAxisControlChanged());
            app.GridOnCheck.Layout.Row = r; app.GridOnCheck.Layout.Column = [1 2]; r = r + 1;

            hdr = uilabel(app.AdvancedGrid,"Text","Line and Fit Style","FontWeight","bold","HorizontalAlignment","left");
            hdr.Layout.Row = r; hdr.Layout.Column = [1 2]; r = r + 1;

            lbl = uilabel(app.AdvancedGrid,"Text","Line color:","HorizontalAlignment","right");
            lbl.Layout.Row = r; lbl.Layout.Column = 1;
            app.StyleLineColorEdit = uieditfield(app.AdvancedGrid,"text", ...
                "ValueChangedFcn",@(s,e)app.onStyleControlChanged());
            app.StyleLineColorEdit.Layout.Row = r; app.StyleLineColorEdit.Layout.Column = 2; r = r + 1;
            lbl = uilabel(app.AdvancedGrid,"Text","Line width:","HorizontalAlignment","right");
            lbl.Layout.Row = r; lbl.Layout.Column = 1;
            app.StyleLineWidthEdit = uieditfield(app.AdvancedGrid,"numeric", ...
                "Limits",[0.1 inf], ...
                "ValueChangedFcn",@(s,e)app.onStyleControlChanged());
            app.StyleLineWidthEdit.Layout.Row = r; app.StyleLineWidthEdit.Layout.Column = 2; r = r + 1;
            lbl = uilabel(app.AdvancedGrid,"Text","Line style:","HorizontalAlignment","right");
            lbl.Layout.Row = r; lbl.Layout.Column = 1;
            app.StyleLineStyleDropDown = uidropdown(app.AdvancedGrid, ...
                "Items",{'-','--',':','-.'}, ...
                "Value",'-', ...
                "ValueChangedFcn",@(s,e)app.onStyleControlChanged());
            app.StyleLineStyleDropDown.Layout.Row = r; app.StyleLineStyleDropDown.Layout.Column = 2; r = r + 1;
            app.ExtendFitCheck = uicheckbox(app.AdvancedGrid, ...
                "Text","Extend fit", ...
                "Value",false, ...
                "ValueChangedFcn",@(s,e)app.onAxisControlChanged());
            app.ExtendFitCheck.Layout.Row = r; app.ExtendFitCheck.Layout.Column = [1 2]; r = r + 1;
            lbl = uilabel(app.AdvancedGrid,"Text","Fit X max:","HorizontalAlignment","right");
            lbl.Layout.Row = r; lbl.Layout.Column = 1;
            app.FitXMaxEdit = uieditfield(app.AdvancedGrid,"numeric", ...
                "ValueDisplayFormat","%.4g", ...
                "ValueChangedFcn",@(s,e)app.onAxisControlChanged());
            app.FitXMaxEdit.Layout.Row = r; app.FitXMaxEdit.Layout.Column = 2; r = r + 1;
            app.ShowFitLineCheck = uicheckbox(app.AdvancedGrid, ...
                "Text","Show fit line", ...
                "Value",true, ...
                "ValueChangedFcn",@(s,e)app.onAxisControlChanged());
            app.ShowFitLineCheck.Layout.Row = r; app.ShowFitLineCheck.Layout.Column = [1 2]; r = r + 1;

            hdr = uilabel(app.AdvancedGrid,"Text","MCMC Display","FontWeight","bold","HorizontalAlignment","left");
            hdr.Layout.Row = r; hdr.Layout.Column = [1 2]; r = r + 1;

            lbl = uilabel(app.AdvancedGrid,"Text","MCMC line:","HorizontalAlignment","right");
            lbl.Layout.Row = r; lbl.Layout.Column = 1;
            app.MCMCPlotModeDropDown = uidropdown(app.AdvancedGrid, ...
                "Items",{'Best fit (MAP)','Mean'}, ...
                "Value",'Best fit (MAP)', ...
                "ValueChangedFcn",@(s,e)app.onMCMCPlotModeChanged());
            app.MCMCPlotModeDropDown.Layout.Row = r; app.MCMCPlotModeDropDown.Layout.Column = 2; r = r + 1;
            app.MCMCShowCredibleBandCheck = uicheckbox(app.AdvancedGrid, ...
                "Text","Show 95% CI for mean fit", ...
                "Value",false, ...
                "Enable","off", ...
                "ValueChangedFcn",@(s,e)app.onAxisControlChanged());
            app.MCMCShowCredibleBandCheck.Layout.Row = r; app.MCMCShowCredibleBandCheck.Layout.Column = [1 2];
        end


        % Default states
        function setDefaults(app)
            app.DataFileEdit.Value = "";
            app.ResultsDirEdit.Value = pwd;

            app.OutputFolderEdit.Value = "CSDStudio_Output";

            app.SampleModeDropDown.Value = "Single sheet";
            app.FitOverlayCheck.Value = false;
            app.OverlaySelection = string.empty;
            app.OverlaySummaryLabel.Text = "";
            app.OverlaySelectButton.Enable = "off";

            app.SolverDropDown.Value = "NL Inversion";
            app.NStartsEdit.Value = 1;
            app.MaxIterEdit.Value = 10000;
            app.FuncTolEdit.Value = 1e-10;
            app.StepTolEdit.Value = 1e-10;

            app.MCMCIterEdit.Value = 100000;
            app.MCMCBurnInEdit.Value = 10000;
            app.MCMCStepFracEdit.Value = 0.03;
            app.MCMCNoiseSigmaEdit.Value = 0.1;
            app.MCMCSeedEdit.Value = 12345;
            app.MCMCUIUpdateStrideEdit.Value = 500;
            app.MCMCPerSheetSeedOffsetCheck.Value = true;
            app.MCMCPlotModeDropDown.Value = 'Best fit (MAP)';
            app.MCMCShowCredibleBandCheck.Value = false;
            app.MCMCShowCredibleBandCheck.Enable = 'off';

            app.ModelTypeDropDown.Value = "2-Chamber";
            app.Alpha1Edit.Value = 0.5;
            app.Alpha2Edit.Value = 0.5;
            app.GrowthLawFixN0Check.Value = false;
            app.GrowthLawLnN0Edit.Value = 0;
            app.GrowthLawLnN0Edit.Enable = "off";

            app.GridOnCheck.Value = true;

            app.StyleShowFitLineCheck.Value = true;

            app.ClipXCheck.Value = false;
            app.XMinEdit.Value = 0;
            app.XMaxEdit.Value = 1;

            app.ClipYCheck.Value = false;
            app.YMinEdit.Value = -20;
            app.YMaxEdit.Value = 20;

            app.ExtendFitCheck.Value = false;
            app.FitXMaxEdit.Value = 1;
            app.ShowFitLineCheck.Value = true;

            app.RunSheetSelection = string.empty;
            app.CombinedSheetSelection = string.empty;
            
            app.RunSheetSelectButton.Enable = "off";
            app.CombineSheetSelectButton.Enable = "off";

            app.UseDataDirCheck.Value = true;
            app.onUseDataDirChanged();
            app.onModeChanged();

            app.ManualPiecewiseCheck.Value = true;

            app.ExcludePointsCheck.Value = false;
            app.PickExcludeButton.Enable = "off";
            app.ClearExcludeButton.Enable = "off";

            app.ManualPWMap = containers.Map('KeyType','char','ValueType','any');
            app.ExcludeMap  = containers.Map('KeyType','char','ValueType','any');
            app.SampleStyleMap = containers.Map('KeyType','char','ValueType','any');
            app.onModelTypeChanged();
            app.onSolverTypeChanged();

            app.RunResults = {};
            app.OverlaySelection = string.empty;
            app.AppendedResultsData = {};
            app.AppendedResultsList = {};
            app.resetCollapsiblePanels();
            app.refreshViewSampleList();
        end

        % UI colors, fonts, and button styling. This keeps the app
        function applyModernTheme(app)
            if ispc
                fontName = "Segoe UI";
            else
                fontName = "Helvetica Neue";
            end

            C.window      = [0.938 0.946 0.958];
            C.sidebar     = [0.938 0.946 0.958];
            C.workspace   = [0.938 0.946 0.958];
            C.plotting    = [0.938 0.946 0.958];
            C.card        = [0.965 0.970 0.980];
            C.cardAlt     = [0.985 0.988 0.994];
            C.subtle      = [0.905 0.918 0.940];
            C.border      = [0.770 0.805 0.865];
            C.text        = [0.075 0.090 0.125];
            C.muted       = [0.345 0.400 0.500];
            C.blue        = [0.000 0.365 0.760];
            C.blueSoft    = [0.875 0.915 0.982];
            C.redSoft     = [0.986 0.920 0.925];
            C.input       = [0.990 0.992 0.996];
            C.inputAlt    = [0.972 0.978 0.988];
            C.plotCard    = [0.938 0.946 0.958];
            C.plotBg      = [1.000 1.000 1.000];
            C.grid        = [0.810 0.835 0.890];

            try
                app.UIFigure.Color = C.window;
            catch
            end
            try
                app.RootGrid.BackgroundColor = C.window;
            catch
            end
            try
                app.LeftPanel.BackgroundColor = C.sidebar;
            catch
            end
            try
                app.LeftPanel.ForegroundColor = C.text;
            catch
            end
            try
                app.RightPanel.BackgroundColor = C.workspace;
            catch
            end
            try
                app.RightPanel.ForegroundColor = C.text;
            catch
            end
            try
                app.PlotPanel.BackgroundColor = C.plotting;
            catch
            end
            try
                app.PlotPanel.ForegroundColor = C.text;
            catch
            end
            try
                app.LeftGrid.BackgroundColor = C.sidebar;
            catch
            end
            try
                app.RightGrid.BackgroundColor = C.workspace;
            catch
            end
            try
                app.PlotGrid.BackgroundColor = C.plotting;
            catch
            end
            try
                app.TabGroup.BackgroundColor = C.workspace;
            catch
            end
            try
                app.TabFit.BackgroundColor = C.workspace;
            catch
            end
            try
                app.TabResults.BackgroundColor = C.workspace;
            catch
            end
            try
                app.TabLog.BackgroundColor = C.workspace;
            catch
            end
            try
                app.FitPlotCard.BackgroundColor = C.plotCard;
            catch
            end
            try
                app.FitPlotCard.ForegroundColor = C.border;
            catch
            end
            try
                app.FitPlotCard.BackgroundColor = C.workspace;
            catch
            end
            try
                app.ParamStatsPanel.BackgroundColor = C.workspace;
            catch
            end

            try
                app.LeftPanel.BorderType = 'none';
            catch
            end
            try
                app.RightPanel.BorderType = 'none';
            catch
            end
            try
                app.PlotPanel.BorderType = 'none';
            catch
            end
            try
                app.ParamStatsPanel.BorderType = 'none';
            catch
            end
            try
                app.FitPlotCard.BorderType = 'none';
            catch
            end

            styleTree(app.UIFigure);
            stylePrimaryButton(app.RunButton);
            styleDangerButton(app.StopButton);
            styleNeutralButton(app.RefreshSheetsButton);
            styleNeutralButton(app.RunSheetSelectButton);
            styleNeutralButton(app.CombineSheetSelectButton);
            styleNeutralButton(app.DataBrowseButton);
            styleNeutralButton(app.ResultsDirBrowseButton);
            styleNeutralButton(app.PopOutFitButton);
            styleNeutralButton(app.OverlaySelectButton);
            styleNeutralButton(app.PickExcludeButton);
            styleNeutralButton(app.ClearExcludeButton);
            styleNeutralButton(app.AppendResultsButton);
            styleSecondaryButton(app.ExportAppendedResultsButton);
            styleSecondaryButton(app.ExportPlotsButton);
            styleNeutralButton(app.SolverToggleButton);
            styleNeutralButton(app.MCMCSolverToggleButton);
            styleNeutralButton(app.ChamberToggleButton);
            styleNeutralButton(app.GrowthLawToggleButton);
            styleNeutralButton(app.AdvancedToggleButton);
            try
                app.AdvancedToggleButton.BackgroundColor = [0.968 0.974 0.984];
                app.AdvancedToggleButton.FontColor = [0.102 0.122 0.160];
            catch
            end
            styleNeutralButton(app.MCMCSeedRandomizeButton);

            try
                app.FitMetaLabel.FontColor = C.muted;
                app.FitMetaLabel.FontSize = 14;
                app.FitMetaLabel.FontName = fontName;
                app.FitMetaLabel.FontWeight = 'normal';
            catch
            end
            try
                app.ParamStatsPanel.BackgroundColor = C.workspace;
                app.ParamStatsPanel.ForegroundColor = C.text;
                app.ParamStatsLabel.FontColor = C.text;
                app.ParamStatsLabel.FontSize = 14;
                app.ParamStatsLabel.FontName = fontName;
                app.ParamStatsTable.BackgroundColor = [C.card; C.cardAlt];
                app.ParamStatsTable.ForegroundColor = C.text;
                app.ParamStatsTable.FontName = fontName;
                app.ParamStatsTable.FontSize = 13;
            catch
            end
            try
                app.OverlaySummaryLabel.FontColor = C.muted;
                app.OverlaySummaryLabel.FontSize = 13;
                app.OverlaySummaryLabel.FontName = fontName;
            catch
            end
            try
                app.ResultsTable.BackgroundColor = [C.card; C.cardAlt];
                app.ResultsTable.ForegroundColor = C.text;
                app.ResultsTable.FontName = fontName;
                app.ResultsTable.FontSize = 14;
                app.ResultsTable.SelectionBackgroundColor = C.blue;
                app.ResultsTable.SelectionForegroundColor = [1 1 1];
            catch
            end
            try
                app.LogTextArea.BackgroundColor = C.card;
                app.LogTextArea.FontColor = C.text;
                app.LogTextArea.FontName = fontName;
                app.LogTextArea.FontSize = 14;
            catch
            end
            try
                styleAxes(app.FitAxes);
            catch
            end
            try
                flattenPanelFrames(app.UIFigure);
            catch
            end

            function flattenPanelFrames(~)

            end

            function styleTree(h)
                if isempty(h) || ~isvalid(h)
                    return;
                end
                try
                    if isa(h,'matlab.ui.container.Panel')
                        if h == app.LeftPanel
                            h.BackgroundColor = C.sidebar;
                            try
                                h.BorderType = 'none';
                            catch
                            end
                        elseif h == app.RightPanel
                            h.BackgroundColor = C.workspace;
                            try
                                h.BorderType = 'none';
                            catch
                            end
                        elseif h == app.PlotPanel
                            h.BackgroundColor = C.plotting;
                            try
                                h.BorderType = 'none';
                            catch
                            end
                        elseif h == app.ParamStatsPanel || h == app.FitPlotCard
                            h.BackgroundColor = C.workspace;
                            try
                                h.BorderType = 'none';
                            catch
                            end
                        else

                            h.BackgroundColor = C.card;
                            try
                                h.BorderType = 'line';
                            catch
                            end
                        end
                        h.ForegroundColor = C.text;
                        try
                            h.FontName = fontName;
                        catch
                        end
                        try
                            h.FontSize = 13;
                        catch
                        end
                        try
                            h.FontWeight = 'bold';
                        catch
                        end
                        try
                            h.HighlightColor = C.border;
                        catch
                        end
                    elseif isa(h,'matlab.ui.container.Tab')
                        try
                            h.BackgroundColor = C.workspace;
                        catch
                        end
                    elseif isa(h,'matlab.ui.container.GridLayout')
                        try
                            if h == app.LeftGrid
                                h.BackgroundColor = C.sidebar;
                            elseif h == app.RightGrid
                                h.BackgroundColor = C.workspace;
                            elseif h == app.PlotGrid
                                h.BackgroundColor = C.plotting;
                            else
                    
                                try
                                    h.BackgroundColor = h.Parent.BackgroundColor;
                                catch
                                    h.BackgroundColor = C.card;
                                end
                            end
                        catch
                        end
                    elseif isa(h,'matlab.ui.control.Label')
                        h.FontName = fontName;
                        if strcmp(string(h.FontWeight),"bold")
                            h.FontSize = 15;
                            h.FontColor = [0.12 0.15 0.22];
                        else
                            h.FontSize = 14;
                            h.FontColor = [0.36 0.41 0.50];
                        end
                    elseif isa(h,'matlab.ui.control.EditField') || ...
                           isa(h,'matlab.ui.control.NumericEditField') || ...
                           isa(h,'matlab.ui.control.DropDown') || ...
                           isa(h,'matlab.ui.control.ListBox')
                        try
                            h.BackgroundColor = C.input;
                        catch
                        end
                        try
                            h.FontColor = C.text;
                        catch
                        end
                        try
                            h.FontName = fontName;
                        catch
                        end
                        try
                            h.FontSize = 13;
                        catch
                        end
                    elseif isa(h,'matlab.ui.control.CheckBox')
                        try
                            h.BackgroundColor = h.Parent.BackgroundColor;
                        catch
                            h.BackgroundColor = C.card;
                        end
                        try
                            h.FontColor = C.text;
                        catch
                        end
                        try
                            h.FontName = fontName;
                        catch
                        end
                        try
                            h.FontSize = 13;
                        catch
                        end
                    elseif isa(h,'matlab.ui.control.TextArea')
                        try
                            h.BackgroundColor = C.input;
                        catch
                        end
                        try
                            h.FontColor = C.text;
                        catch
                        end
                        try
                            h.FontName = fontName;
                        catch
                        end
                        try
                            h.FontSize = 13;
                        catch
                        end
                    elseif isa(h,'matlab.ui.control.Button')
                        try
                            h.FontName = fontName;
                        catch
                        end
                        try
                            h.FontWeight = 'bold';
                        catch
                        end
                        try
                            h.FontSize = 12;
                        catch
                        end
                    elseif isa(h,'matlab.ui.control.UIAxes')
                        styleAxes(h);
                    end
                catch
                end
                try
                    kids = h.Children;
                catch
                    kids = [];
                end
                for kk = 1:numel(kids)
                    styleTree(kids(kk));
                end
            end

            function stylePrimaryButton(btn)
                if isempty(btn) || ~isvalid(btn)
                    return;
                end
                try
                    btn.BackgroundColor = C.blue;
                catch
                end
                try
                    btn.FontColor = [1 1 1];
                catch
                end
                try
                    btn.FontWeight = 'bold';
                catch
                end
                try
                    btn.FontName = fontName;
                catch
                end
                try
                    btn.FontSize = 12;
                catch
                end
            end

            function styleSecondaryButton(btn)
                if isempty(btn) || ~isvalid(btn)
                    return;
                end
                try
                    btn.BackgroundColor = C.blueSoft;
                catch
                end
                try
                    btn.FontColor = C.blue;
                catch
                end
                try
                    btn.FontWeight = 'bold';
                catch
                end
                try
                    btn.FontName = fontName;
                catch
                end
                try
                    btn.FontSize = 12;
                catch
                end
            end

            function styleDangerButton(btn)
                if isempty(btn) || ~isvalid(btn)
                    return;
                end
                try
                    btn.BackgroundColor = C.redSoft;
                catch
                end
                try
                    btn.FontColor = [0.62 0.16 0.20];
                catch
                end
                try
                    btn.FontWeight = 'bold';
                catch
                end
                try
                    btn.FontName = fontName;
                catch
                end
                try
                    btn.FontSize = 12;
                catch
                end
            end

            function styleNeutralButton(btn)
                if isempty(btn) || ~isvalid(btn)
                    return;
                end
                try
                    btn.BackgroundColor = [0.968 0.974 0.984];
                catch
                end
                try
                    btn.FontColor = C.text;
                catch
                end
                try
                    btn.FontWeight = 'bold';
                catch
                end
                try
                    btn.FontName = fontName;
                catch
                end
                try
                    btn.FontSize = 12;
                catch
                end
            end

            function styleAxes(ax)
                if isempty(ax) || ~isvalid(ax)
                    return;
                end
                try
                    ax.Color = C.plotBg;
                catch
                end
                try
                    ax.XColor = C.text;
                catch
                end
                try
                    ax.YColor = C.text;
                catch
                end
                try
                    ax.GridColor = C.grid;
                catch
                end
                try
                    ax.MinorGridColor = C.grid;
                catch
                end
                try
                    ax.GridAlpha = 0.40;
                catch
                end
                try
                    ax.MinorGridAlpha = 0.12;
                catch
                end
                try
                    ax.FontName = fontName;
                catch
                end
                try
                    ax.FontSize = 15;
                catch
                end
                try
                    ax.Box = 'on';
                catch
                end
                try
                    ax.LineWidth = 1.35;
                catch
                end
                try
                    ax.Toolbar.Visible = 'off';
                catch
                end
                try
                    title(ax,'');
                catch
                end
                try
                    xlabel(ax, ax.XLabel.String, 'Color', C.text);
                catch
                end
                try
                    ylabel(ax, ax.YLabel.String, 'Color', C.text);
                catch
                end
            end
        end

        function onUseDataDirChanged(app)
            if app.UseDataDirCheck.Value
                d = fileparts(string(app.DataFileEdit.Value));
                if strlength(d) > 0
                    app.ResultsDirEdit.Value = d;
                end
                app.ResultsDirEdit.Editable = "off";
                app.ResultsDirBrowseButton.Enable = "off";
            else
                app.ResultsDirEdit.Editable = "on";
                app.ResultsDirBrowseButton.Enable = "on";
            end
        end

        function onModeChanged(app)
            mode = string(app.SampleModeDropDown.Value);
        
            switch mode
                case "All sheets"
                    app.SheetDropDown.Enable = "off";
                    app.RunSheetSelectButton.Enable = "off";
                    app.CombineSheetSelectButton.Enable = "off";
        
                case "Single sheet"
                    app.SheetDropDown.Enable = "on";
                    app.RunSheetSelectButton.Enable = "off";
                    app.CombineSheetSelectButton.Enable = "off";
        
                case "Selected sheets"
                    app.SheetDropDown.Enable = "off";
                    app.RunSheetSelectButton.Enable = "on";
                    app.CombineSheetSelectButton.Enable = "off";
        
                case "Combine sheets"
                    app.SheetDropDown.Enable = "off";
                    app.RunSheetSelectButton.Enable = "off";
                    app.CombineSheetSelectButton.Enable = "on";
            end

            app.updateExcludeButtonText();
        end

        function updateExcludeButtonText(app)
            try
                mode = string(app.SampleModeDropDown.Value);
                switch mode
                    case "Single sheet"
                        app.PickExcludeButton.Text = "Pick exclusions (current sheet)";
                        app.ClearExcludeButton.Text = "Clear";
                    case "Selected sheets"
                        app.PickExcludeButton.Text = "Pick exclusions (selected sheets)";
                        app.ClearExcludeButton.Text = "Clear";
                    case "Combine sheets"
                        app.PickExcludeButton.Text = "Pick exclusions (combined sheets)";
                        app.ClearExcludeButton.Text = "Clear";
                    case "All sheets"
                        app.PickExcludeButton.Text = "Pick exclusions (all sheets)";
                        app.ClearExcludeButton.Text = "Clear";
                end
            catch
            end
        end

        % Model-dependent UI logic. Any new model should be registered here so the
        % solver list, settings panels, and initialization behavior stay synchronized.
        function onModelTypeChanged(app)
            modelType = app.normalizeModelType(string(app.ModelTypeDropDown.Value));

            try
                if any(strcmp(app.ModelTypeDropDown.Items, char(modelType)))
                    app.ModelTypeDropDown.Value = char(modelType);
                end
            catch
            end

            is3 = strcmp(modelType, "3-Chamber");
            isGrowth = strcmp(modelType, "Growth-Law");
            isLinear = strcmp(modelType, "Linear");

            % The Linear model is NL-only. 
            try
                if isLinear
                    app.SolverDropDown.Items = {'NL Inversion'};
                    app.SolverDropDown.Value = 'NL Inversion';
                else
                    app.SolverDropDown.Items = {'NL Inversion','MCMC'};
                    if ~any(strcmp(app.SolverDropDown.Items, char(app.SolverDropDown.Value)))
                        app.SolverDropDown.Value = 'NL Inversion';
                    end
                end
            catch
            end

            % 3-Chamber settings are available only for the 3-Chamber model.
            try
                app.ChamberToggleButton.Enable = ternaryOnOff(is3);
            catch
            end
            try
                app.Alpha1Edit.Enable = ternaryOnOff(is3);
            catch
            end
            try
                app.Alpha2Edit.Enable = 'off';
            catch
            end
            if ~is3
                try
                    app.ChamberOpen = false;
                    app.ChamberToggleButton.Text = "3-Chamber settings ▸";
                    app.ChamberPanel.Visible = "off";
                    app.ChamberPanel.Parent.RowHeight{app.ChamberPanel.Layout.Row} = 1;
                catch
                end
                try
                    app.Alpha1Edit.Value = 0.5;
                catch
                end
            end

            % Growth-Law settings are available only for the Growth-Law model.
            try
                app.GrowthLawToggleButton.Enable = ternaryOnOff(isGrowth);
            catch
            end
            try
                app.GrowthLawFixN0Check.Enable = ternaryOnOff(isGrowth);
            catch
            end
            if ~isGrowth
                try
                    app.GrowthLawOpen = false;
                    app.GrowthLawToggleButton.Text = "Growth-Law settings ▸";
                    app.GrowthLawPanel.Visible = "off";
                    app.GrowthLawPanel.Parent.RowHeight{app.GrowthLawPanel.Layout.Row} = 1;
                catch
                end
            end
            app.onGrowthLawFixN0Changed();

            % Manual piecewise is only meaningful for 2 or 3 chamber models
            try
                if isGrowth || isLinear
                    app.ManualPiecewiseCheck.Value = false;
                    app.ManualPiecewiseCheck.Enable = 'off';
                else
                    app.ManualPiecewiseCheck.Enable = 'on';
                end
            catch
            end

            app.onAlpha1Changed();
            if isLinear
                app.onSolverTypeChanged();
            end

            function out = ternaryOnOff(tf)
                if tf, out = 'on'; else, out = 'off'; end
            end
        end

        % Convert loose model labels into hardcoded names used everywhere else.
        function modelType = normalizeModelType(~, modelType)
            s = lower(strtrim(string(modelType)));
            s = replace(s, "_", " ");
            s = replace(s, "-", " ");
            s = regexprep(s, '\s+', ' ');

            if any(strcmp(s, ["growth law", "growthlaw", "growth law model", "growthlaw model", ...
                              "power law", "powerlaw", "power law model", "powerlaw model"]))
                modelType = "Growth-Law";
            elseif any(strcmp(s, ["linear", "linear model", "single exponential", "single exponential model", ...
                                  "one exponential", "one exponential model", "classic csd", "classic csd model"]))
                modelType = "Linear";
            elseif any(strcmp(s, ["3 chamber", "3chamber", "three chamber", "3 chamber model"]))
                modelType = "3-Chamber";
            else
                modelType = "2-Chamber";
            end
        end

        function solverType = normalizeSolverType(~, solverType)
            s = lower(strtrim(string(solverType)));
            s = replace(s, "_", " ");
            s = replace(s, "-", " ");
            s = regexprep(s, '\s+', ' ');

            if contains(s, "mcmc")
                solverType = "MCMC";
            else
                solverType = "NL Inversion";
            end
        end

        % Solver UI logic.
        function onSolverTypeChanged(app)
            solverType = app.normalizeSolverType(string(app.SolverDropDown.Value));
            try
                app.SolverDropDown.Value = char(solverType);
            catch
            end

            isMCMC = strcmp(solverType, "MCMC");
            try
                modelTypeNow = app.normalizeModelType(string(app.ModelTypeDropDown.Value));
                if strcmp(modelTypeNow, "Linear") && isMCMC
                    solverType = "NL Inversion";
                    isMCMC = false;
                    app.SolverDropDown.Value = 'NL Inversion';
                    app.log("Linear model selected: MCMC is disabled; using NL Inversion.");
                end
            catch
            end
            nlEnable = 'on';
            mcmcEnable = 'off';
            if isMCMC
                nlEnable = 'off';
                mcmcEnable = 'on';
            end

            % Grey out the inactive solver-options dropdown.
            try
                app.SolverToggleButton.Enable = nlEnable;
            catch
            end
            try
                app.MCMCSolverToggleButton.Enable = mcmcEnable;
            catch
            end
            if isMCMC
                app.closeNLSolverPanel();
            else
                app.closeMCMCSolverPanel();
            end

            try
                app.NStartsEdit.Enable = nlEnable;
            catch
            end
            try
                app.MaxIterEdit.Enable = nlEnable;
            catch
            end
            try
                app.FuncTolEdit.Enable = nlEnable;
            catch
            end
            try
                app.StepTolEdit.Enable = nlEnable;
            catch
            end

            try
                app.MCMCIterEdit.Enable = mcmcEnable;
            catch
            end
            try
                app.MCMCBurnInEdit.Enable = mcmcEnable;
            catch
            end
            try
                app.MCMCStepFracEdit.Enable = mcmcEnable;
            catch
            end
            try
                app.MCMCNoiseSigmaEdit.Enable = mcmcEnable;
            catch
            end
            try
                app.MCMCSeedEdit.Enable = mcmcEnable;
            catch
            end
            try
                app.MCMCSeedRandomizeButton.Enable = mcmcEnable;
            catch
            end
            try
                app.MCMCUIUpdateStrideEdit.Enable = mcmcEnable;
            catch
            end
            try
                app.MCMCPerSheetSeedOffsetCheck.Enable = mcmcEnable;
            catch
            end
            try
                app.MCMCPlotModeDropDown.Enable = mcmcEnable;
            catch
            end
            try
                if isMCMC && strcmp(string(app.MCMCPlotModeDropDown.Value), "Mean")
                    app.MCMCShowCredibleBandCheck.Enable = 'on';
                else
                    app.MCMCShowCredibleBandCheck.Enable = 'off';
                end
            catch
            end

            try
                if isempty(app.RunResults)
                    app.updateParamStatsView([]);
                end
            catch
            end

            if isMCMC
                app.log("Solver set to MCMC. MCMC Solver Options are active; NL Solver Options are disabled.");
            else
                app.log("Solver set to NL Inversion. NL Solver Options are active; MCMC Solver Options are disabled.");
            end
        end

        function onAlpha1Changed(app)
            a1 = app.Alpha1Edit.Value;
            if ~isfinite(a1)
                a1 = 0.5;
            end
            a1 = min(max(a1, 0), 1);
            app.Alpha1Edit.Value = a1;
            app.Alpha2Edit.Value = 1 - a1;
        end

        function onGrowthLawFixN0Changed(app)
            try
                isGrowth = strcmp(app.normalizeModelType(string(app.ModelTypeDropDown.Value)), "Growth-Law");
                if isGrowth && app.GrowthLawFixN0Check.Value
                    app.GrowthLawLnN0Edit.Enable = 'on';
                else
                    app.GrowthLawLnN0Edit.Enable = 'off';
                end
            catch
            end
        end

        function toggleNLSolverPanel(app)
            if strcmp(app.SolverToggleButton.Enable, 'off')
                return;
            end
            app.SolverOpen = ~app.SolverOpen;
            row = app.SolverPanel.Layout.Row;

            if app.SolverOpen
                app.SolverToggleButton.Text = "NL Solver Options ▾";
                app.SolverPanel.Visible = "on";
                app.SolverPanel.Parent.RowHeight{row} = 178;
            else
                app.closeNLSolverPanel();
            end
        end

        function closeNLSolverPanel(app)
            try
                app.SolverOpen = false;
                app.SolverToggleButton.Text = "NL Solver Options ▸";
                app.SolverPanel.Visible = "off";
                app.SolverPanel.Parent.RowHeight{app.SolverPanel.Layout.Row} = 1;
            catch
            end
        end

        function toggleMCMCSolverPanel(app)
            if strcmp(app.MCMCSolverToggleButton.Enable, 'off')
                return;
            end
            app.MCMCSolverOpen = ~app.MCMCSolverOpen;
            row = app.MCMCSolverPanel.Layout.Row;

            if app.MCMCSolverOpen
                app.MCMCSolverToggleButton.Text = "MCMC Solver Options ▾";
                app.MCMCSolverPanel.Visible = "on";
                app.MCMCSolverPanel.Parent.RowHeight{row} = 300;
            else
                app.closeMCMCSolverPanel();
            end
        end

        function closeMCMCSolverPanel(app)
            try
                app.MCMCSolverOpen = false;
                app.MCMCSolverToggleButton.Text = "MCMC Solver Options ▸";
                app.MCMCSolverPanel.Visible = "off";
                app.MCMCSolverPanel.Parent.RowHeight{app.MCMCSolverPanel.Layout.Row} = 1;
            catch
            end
        end

        function toggleChamberPanel(app)
            if strcmp(app.ChamberToggleButton.Enable, 'off')
                return;
            end
            app.ChamberOpen = ~app.ChamberOpen;
            row = app.ChamberPanel.Layout.Row;

            if app.ChamberOpen
                app.ChamberToggleButton.Text = "3-Chamber settings ▾";
                app.ChamberPanel.Visible = "on";
                app.ChamberPanel.Parent.RowHeight{row} = 106;
            else
                app.ChamberOpen = false;
                app.ChamberToggleButton.Text = "3-Chamber settings ▸";
                app.ChamberPanel.Visible = "off";
                app.ChamberPanel.Parent.RowHeight{row} = 1;
            end
        end

        function toggleGrowthLawPanel(app)
            if strcmp(app.GrowthLawToggleButton.Enable, 'off')
                return;
            end
            app.GrowthLawOpen = ~app.GrowthLawOpen;
            row = app.GrowthLawPanel.Layout.Row;

            if app.GrowthLawOpen
                app.GrowthLawToggleButton.Text = "Growth-Law settings ▾";
                app.GrowthLawPanel.Visible = "on";
                app.GrowthLawPanel.Parent.RowHeight{row} = 68;
            else
                app.GrowthLawOpen = false;
                app.GrowthLawToggleButton.Text = "Growth-Law settings ▸";
                app.GrowthLawPanel.Visible = "off";
                app.GrowthLawPanel.Parent.RowHeight{row} = 1;
            end
        end

        function toggleAdvanced(app)
            % Collapse/expand the entire right plotting inspector.  
            app.PlotPanelOpen = ~app.PlotPanelOpen;
            app.AdvancedOpen = app.PlotPanelOpen;
            app.applyPlotPanelCollapseState();
        end

        function applyPlotPanelCollapseState(app)
            % Collapse/expand the right plotting inspector
            try
                if app.PlotPanelOpen
                    app.RootGrid.ColumnWidth = {430,'1x',350};
                    app.PlotPanel.Title = "Plotting";
                    app.PlotPanel.Scrollable = 'on';

                    app.PlotGrid.RowHeight = {32,'1x'};
                    app.PlotGrid.RowSpacing = 7;
                    app.PlotGrid.Padding = [10 10 10 10];

                    app.AdvancedToggleButton.Visible = "on";
                    app.AdvancedToggleButton.Text = "Hide Display Options";
                    app.AdvancedToggleButton.Tooltip = "Collapse plotting options";
                    app.AdvancedToggleButton.FontSize = 13;
                    app.AdvancedToggleButton.FontWeight = 'bold';

                    app.AdvancedPanel.Visible = "on";
                else
                    app.RootGrid.ColumnWidth = {455,'1x',48};
                    app.PlotPanel.Title = "";
                    app.PlotPanel.Scrollable = 'off';

                    app.PlotGrid.RowHeight = {'1x',1};
                    app.PlotGrid.RowSpacing = 0;
                    app.PlotGrid.Padding = [5 10 5 10];

                    app.AdvancedToggleButton.Visible = "on";
                    app.AdvancedToggleButton.Text = "◂";
                    app.AdvancedToggleButton.Tooltip = "Open plotting options";
                    app.AdvancedToggleButton.FontSize = 22;
                    app.AdvancedToggleButton.FontWeight = 'bold';

                    app.AdvancedPanel.Visible = "off";
                end
                drawnow limitrate;
                app.LastParamStatsResizeWidth = NaN;
                app.updateParamStatsColumnWidths(true);
                app.scheduleParamStatsColumnResize();
            catch ME
                try
                    app.log("Plotting panel resize failed: " + string(ME.message));
                catch
                end
            end
        end

        function onManualPiecewiseChanged(app)
            if app.ManualPiecewiseCheck.Value
                app.log("Manual piecewise enabled. Point picking will occur during Run.");
            else
                app.log("Manual piecewise disabled. Auto breakpoint search is available but less reliable than manual picks for curved/sparse CSDs.");
            end
        end

        function onExcludePointsChanged(app)
            if app.ExcludePointsCheck.Value
                app.PickExcludeButton.Enable = "on";
                app.ClearExcludeButton.Enable = "on";
                app.log("Point exclusions enabled. Stored exclusions will be applied to preview + fits.");
            else
                app.PickExcludeButton.Enable = "off";
                app.ClearExcludeButton.Enable = "off";
                app.log("Point exclusions disabled. All points will be used.");
            end
            app.previewSelectedSheet();
        end

        function onAxisControlChanged(app)
            try
                if app.ViewSampleDropDown.Enable == "on" && ~strcmp(app.ViewSampleDropDown.Value,'(no results yet)')
                    app.updateCurrentFitView();
                else
                    app.previewSelectedSheet();
                end
            catch ME
                app.log("Axis/style refresh failed: " + ME.message);
            end
        end

        function onMCMCPlotModeChanged(app)
            try
                if strcmp(app.normalizeSolverType(string(app.SolverDropDown.Value)), "MCMC") && strcmp(string(app.MCMCPlotModeDropDown.Value), "Mean")
                    app.MCMCShowCredibleBandCheck.Enable = 'on';
                else
                    app.MCMCShowCredibleBandCheck.Enable = 'off';
                end
                app.onAxisControlChanged();
            catch ME
                app.log("MCMC plot-mode refresh failed: " + ME.message);
            end
        end

        function xRight = getFitCurveXRight(app, xData, cfg)
            % Fit curves are drawn beyond the last measured data point. If the "Extend fit" option is enabled,
            % Fit X max can extend the curve farther.
            if nargin < 3
                cfg = [];
            end

            xData = double(xData(:));
            xData = xData(isfinite(xData));
            if isempty(xData)
                xBase = 1;
            else
                xBase = max(xData);
            end

            if ~isfinite(xBase)
                xBase = 1;
            end

            if xBase > 0
                xRight = 1.15 .* xBase;
            else
                if isempty(xData)
                    span = 1;
                else
                    span = max(xData) - min(xData);
                end
                scale = max([abs(xBase), abs(span), 1]);
                xRight = xBase + 0.15 .* scale;
            end

            try
                if isstruct(cfg)
                    if isfield(cfg,'extendFit') && cfg.extendFit && ...
                            isfield(cfg,'fitXMax') && isfinite(cfg.fitXMax)
                        xRight = max(xRight, cfg.fitXMax);
                    end
                else
                    if app.ExtendFitCheck.Value && isfinite(app.FitXMaxEdit.Value)
                        xRight = max(xRight, app.FitXMaxEdit.Value);
                    end
                end
            catch
            end

            if ~isfinite(xRight) || xRight <= 0
                xRight = 1;
            end
        end

        function applyAxisControls(app, ax)
            if isempty(ax) || ~isvalid(ax); return; end

            if app.ClipXCheck.Value
                x1 = app.XMinEdit.Value;
                x2 = app.XMaxEdit.Value;
                if isfinite(x1) && isfinite(x2) && x1 < x2
                    xlim(ax,[x1 x2]);
                end
            end

            if app.ClipYCheck.Value
                y1 = app.YMinEdit.Value;
                y2 = app.YMaxEdit.Value;
                if isfinite(y1) && isfinite(y2) && y1 < y2
                    ylim(ax,[y1 y2]);
                end
            end
        end

        function applyGridState(app, ax)
            if isempty(ax) || ~isvalid(ax); return; end
            if app.GridOnCheck.Value
                grid(ax,'on');
            else
                grid(ax,'off');
            end
        end

        % Refreshing a workbook should behave like starting a new session
        function resetAppForSheetRefresh(app, dataFile)
            dataFile = string(dataFile);

            try
                app.CancelRequested = false;
                app.RunButton.Enable = "on";
                app.StopButton.Enable = "off";
            catch
            end

            try
                app.setDefaults();
            catch
            end

            try
                app.DataFileEdit.Value = dataFile;
                if app.UseDataDirCheck.Value
                    d = fileparts(dataFile);
                    if strlength(d) > 0
                        app.ResultsDirEdit.Value = d;
                    end
                    app.ResultsDirEdit.Editable = "off";
                    app.ResultsDirBrowseButton.Enable = "off";
                end
            catch
            end

            app.clearWorkspaceState();
        end

        % Clear plots, tables, appended results, and detached figures without changing
        % model settings. 
        function clearWorkspaceState(app)
            % Clear visible outputs and any detached fit window.
            try
                cla(app.FitAxes,'reset');
                app.FitAxes.FontSize = 15;
                app.FitAxes.Box = 'on';
                xlabel(app.FitAxes,"L (mm)");
                ylabel(app.FitAxes,"ln(n) mm^{-4}");
                title(app.FitAxes,"");
                app.applyGridState(app.FitAxes);
            catch
            end

            try
                app.FitMetaLabel.Text = "";
            catch
            end

            try
                app.AppendedResultsData = {};
                app.AppendedResultsList = {};
                app.ResultsTable.Data = {};
                app.ResultsTable.ColumnName = app.getAppendedResultsHeaders();
            catch
            end

            try
                app.ParamStatsLabel.Text = "Complete a run to show fitted parameters.";
                app.ParamStatsTable.Data = {};
                app.ParamStatsTable.Visible = 'off';
                app.updateParamStatsColumnWidths(false);
            catch
            end

            try
                app.LogTextArea.Value = "";
            catch
            end

            try
                app.FitFigureUserOpened = false;
            catch
            end
            try
                if ~isempty(app.FitFigure) && isvalid(app.FitFigure)
                    delete(app.FitFigure);
                end
                app.FitFigure = [];
                app.FitFigureAxes = [];
            catch
            end
        end

        function resetCollapsiblePanels(app)
            % Return collapsible panels to their default closed state.
            app.closeNLSolverPanel();
            app.closeMCMCSolverPanel();

            try
                app.ChamberOpen = false;
                app.ChamberToggleButton.Text = "3-Chamber settings ▸";
                app.ChamberPanel.Visible = "off";
                app.ChamberPanel.Parent.RowHeight{app.ChamberPanel.Layout.Row} = 1;
            catch
            end

            try
                app.GrowthLawOpen = false;
                app.GrowthLawToggleButton.Text = "Growth-Law settings ▸";
                app.GrowthLawPanel.Visible = "off";
                app.GrowthLawPanel.Parent.RowHeight{app.GrowthLawPanel.Layout.Row} = 1;
            catch
            end

            try
                app.PlotPanelOpen = true;
                app.AdvancedOpen = true;
                app.applyPlotPanelCollapseState();
            catch
            end
        end

        function browseData(app)
            [f,p] = uigetfile({'*.xlsx;*.xlsm;*.xls','Excel workbooks (*.xlsx,*.xlsm,*.xls)'}, ...
                "Select data workbook");
            if isequal(f,0); return; end
            app.DataFileEdit.Value = fullfile(string(p), string(f));
            if app.UseDataDirCheck.Value
                app.ResultsDirEdit.Value = string(p);
            end
            app.ManualPWMap = containers.Map('KeyType','char','ValueType','any');
            app.ExcludeMap  = containers.Map('KeyType','char','ValueType','any');
            app.refreshSheetsSafe();
        end

        function browseResultsDir(app)
            p = uigetdir(string(app.ResultsDirEdit.Value),"Select results output directory");
            if isequal(p,0); return; end
            app.ResultsDirEdit.Value = string(p);
        end

        function refreshSheetsSafe(app)
            try
                f = string(app.DataFileEdit.Value);
                if strlength(f) == 0 || ~isfile(f)
                    app.log("Data file not found: " + f);
                    return;
                end

                app.resetAppForSheetRefresh(f);
                f = string(app.DataFileEdit.Value);

                if app.UseDataDirCheck.Value
                    d = fileparts(f);
                    if strlength(d) > 0
                        app.ResultsDirEdit.Value = d;
                    end
                end

                app.SheetNames = string(sheetnames(f));
                app.RunSheetSelection = string.empty;
                app.CombinedSheetSelection = string.empty;
                if isempty(app.SheetNames)
                    app.log("No sheets found in data workbook.");
                    return;
                end

                app.SheetDropDown.Items = cellstr(app.SheetNames);
                app.SheetDropDown.Value = app.SheetDropDown.Items{1};

                app.ManualPWMap = containers.Map('KeyType','char','ValueType','any');
                app.ExcludeMap  = containers.Map('KeyType','char','ValueType','any');

                app.refreshViewSampleList();
                app.log("Full app refresh complete. Loaded " + numel(app.SheetNames) + " sheets.");
                app.previewSelectedSheet();
            catch ME
                app.log("ERROR refreshing sheets: " + ME.message);
                app.log(getReport(ME,'basic','hyperlinks','off'));
            end
        end

        function previewSelectedSheet(app)
            if isempty(app.SheetNames); return; end
            if app.SampleModeDropDown.Value ~= "Single sheet"; return; end

            try
                sheet = string(app.SheetDropDown.Value);
                useExcl = logical(app.ExcludePointsCheck.Value);
                [x,y,idxExcl,rawN] = app.readSheetXY(string(app.DataFileEdit.Value), sheet, useExcl);

                cla(app.FitAxes);
                scatter(app.FitAxes, x, y, 140, "filled");
                if useExcl
                    title(app.FitAxes, sprintf("Preview: %s | used=%d / raw=%d (excluded=%d)", sheet, numel(x), rawN, numel(idxExcl)));
                else
                    title(app.FitAxes, sprintf("Preview: %s | raw=%d", sheet, rawN));
                end
                xlabel(app.FitAxes,'L (mm)');
                ylabel(app.FitAxes,'ln(n) mm^{-4}');
                box(app.FitAxes,'on');
                app.applyGridState(app.FitAxes);
                app.applyAxisControls(app.FitAxes);
                drawnow;
            catch ME
                app.log("Preview failed: " + ME.message);
            end
        end

        function log(app, msg)
            msg = string(msg);
            tstamp = string(datetime("now","Format","HH:mm:ss"));
            line = "[" + tstamp + "] " + msg;

            v = app.LogTextArea.Value;
            if ischar(v)
                v = string(v);
            elseif iscell(v)
                v = string(v(:));
            else
                v = string(v(:));
            end

            if isscalar(v) && strlength(v) == 0
                v = line;
            else
                v(end+1,1) = line;
            end
            app.LogTextArea.Value = v;
            drawnow limitrate;
        end
    end

    %% ====================== Manual tools ======================
    methods (Access = private)
        % Interactive point exclusion. 
        function pickExcludePressed(app)
            try
                if isempty(app.SheetNames)
                    app.log("No sheets loaded.");
                    return;
                end

                sheets = app.getExclusionTargetSheets(true);
                if isempty(sheets)
                    app.log("No sheets selected for exclusion picking.");
                    return;
                end

                sheets = app.chooseExclusionEditSheets(sheets, "Choose sheets for exclusion picking");
                if isempty(sheets)
                    app.log("Exclusion picking canceled.");
                    return;
                end

                nEdited = 0;
                totalExcluded = 0;

                for ii = 1:numel(sheets)
                    sheet = string(sheets(ii));
                    [x_raw,y_raw] = app.readSheetXYRaw(string(app.DataFileEdit.Value), sheet);

                    key = char(sheet);
                    pre = [];
                    if isKey(app.ExcludeMap, key)
                        pre = app.ExcludeMap(key);
                    end

                    pickLabel = sheet;
                    if numel(sheets) > 1
                        pickLabel = sheet + " (" + string(ii) + "/" + string(numel(sheets)) + ")";
                    end

                    idxExcl = app.manualPickExcludePoints(x_raw, y_raw, pickLabel, pre);
                    app.ExcludeMap(key) = idxExcl(:).';
                    nEdited = nEdited + 1;
                    totalExcluded = totalExcluded + numel(idxExcl);

                    if isKey(app.ManualPWMap, key)
                        remove(app.ManualPWMap, key);
                        app.log("Cleared manual piecewise picks for " + sheet + " (exclusions changed indexing).");
                    end

                    app.log(sprintf("Stored exclusions for %s: excluded=%d (of %d raw points).", sheet, numel(idxExcl), numel(x_raw)));
                    drawnow limitrate;
                end

                app.log(sprintf("Exclusion picking complete: edited %d sheet(s), total excluded points=%d.", nEdited, totalExcluded));
                app.previewSelectedSheet();
            catch ME
                app.log("Exclude pick failed: " + ME.message);
                app.log(getReport(ME,'basic','hyperlinks','off'));
            end
        end

        function clearExcludePressed(app)
            try
                if isempty(app.SheetNames); return; end

                sheets = app.getExclusionTargetSheets(true);
                if isempty(sheets)
                    app.log("No sheets selected for clearing exclusions.");
                    return;
                end

                sheets = app.chooseExclusionEditSheets(sheets, "Choose sheets to clear exclusions", "Stored exclusions and dependent manual piecewise picks will be cleared for the selected sheets.");
                if isempty(sheets)
                    app.log("Clear exclusions canceled.");
                    return;
                end

                nCleared = 0;
                nPWCleared = 0;
                for ii = 1:numel(sheets)
                    sheet = string(sheets(ii));
                    key = char(sheet);

                    if isKey(app.ExcludeMap, key)
                        remove(app.ExcludeMap, key);
                        nCleared = nCleared + 1;
                    end

                    if isKey(app.ManualPWMap, key)
                        remove(app.ManualPWMap, key);
                        nPWCleared = nPWCleared + 1;
                    end
                end

                if nCleared == 0 && nPWCleared == 0
                    app.log("No exclusions or manual piecewise picks were stored for the selected sheet set.");
                else
                    app.log(sprintf("Cleared exclusions for %d sheet(s) and manual piecewise picks for %d sheet(s).", nCleared, nPWCleared));
                end

                app.previewSelectedSheet();
            catch ME
                app.log("Clear exclusions failed: " + ME.message);
            end
        end

        function sheets = getExclusionTargetSheets(app, allowPrompt)
            if nargin < 2
                allowPrompt = false;
            end

            sheets = string.empty;
            mode = string(app.SampleModeDropDown.Value);

            switch mode
                case "Single sheet"
                    if ~isempty(app.SheetDropDown.Items)
                        sheets = string(app.SheetDropDown.Value);
                    end

                case "Selected sheets"
                    if isempty(app.RunSheetSelection) && allowPrompt
                        app.log("No selected run sheets are stored. Choose sheets before continuing.");
                        app.chooseRunSheets();
                    end
                    sheets = app.RunSheetSelection;

                case "Combine sheets"
                    if isempty(app.CombinedSheetSelection) && allowPrompt
                        app.log("No combined sheets are stored. Choose combined sheets before continuing.");
                        app.chooseCombinedSheets();
                    end
                    sheets = app.CombinedSheetSelection;

                case "All sheets"
                    sheets = app.SheetNames;
            end

            sheets = string(sheets(:)).';
            sheets = sheets(strlength(sheets) > 0);

            % Keep only valid workbook sheets and preserve workbook/order-selection order.
            if ~isempty(sheets) && ~isempty(app.SheetNames)
                valid = ismember(sheets, app.SheetNames);
                sheets = sheets(valid);
                [~, ia] = unique(cellstr(sheets), 'stable');
                sheets = sheets(sort(ia));
            end
        end

        function sheetsOut = chooseExclusionEditSheets(app, sheetsIn, promptTitle, detailText)
            if nargin < 4
                detailText = "The exclusion editor will open one sheet at a time.";
            end

            sheetsIn = string(sheetsIn(:)).';
            sheetsIn = sheetsIn(strlength(sheetsIn) > 0);
            sheetsOut = sheetsIn;

            if isempty(sheetsIn)
                return;
            end

            if isscalar(sheetsIn)
                return;
            end

            items = cellstr(sheetsIn);
            [idx, ok] = listdlg( ...
                'ListString', items, ...
                'SelectionMode', 'multiple', ...
                'InitialValue', 1:numel(items), ...
                'ListSize', [420 300], ...
                'PromptString', {char(promptTitle), char(detailText)});

            if ~ok || isempty(idx)
                sheetsOut = string.empty;
            else
                sheetsOut = string(items(idx));
            end
        end
    end

    %% ====================== Fit view / styles ======================
    methods (Access = private)
        function result = assignResultIdentity(app, result)
            % Give every stored fit a unique display label. 
            runNumber = numel(app.RunResults) + 1;
            result.RunNumber = runNumber;
            result.ResultID = "Run_" + string(runNumber);
            result.ResultLabel = app.makeResultDisplayLabel(result, runNumber);
        end

        function labels = getResultListLabels(app)
            labels = strings(1, numel(app.RunResults));
            for kk = 1:numel(app.RunResults)
                labels(kk) = app.getResultDisplayLabel(app.RunResults{kk}, kk);
            end
        end

        function label = getResultDisplayLabel(app, result, idx)
            if isfield(result,'ResultLabel') && strlength(string(result.ResultLabel)) > 0
                label = string(result.ResultLabel);
                return;
            end
            if nargin < 3 || isempty(idx) || ~isfinite(double(idx))
                idx = app.findResultIndexBySheetModel(result);
            end
            if isempty(idx) || ~isfinite(double(idx))
                idx = numel(app.RunResults) + 1;
            end
            label = app.makeResultDisplayLabel(result, idx);
        end

        function label = makeResultDisplayLabel(~, result, idx)
            sheetName = "Result";
            modelName = "Model";
            solverName = "";
            if isfield(result,'Sheet')
                sheetName = string(result.Sheet);
            end
            if isfield(result,'ModelType')
                modelName = string(result.ModelType);
            end
            if isfield(result,'SolverType')
                solverName = string(result.SolverType);
            elseif isfield(result,'Fit') && isfield(result.Fit,'solver')
                solverName = string(result.Fit.solver);
            end

            if strlength(solverName) > 0
                label = sheetName + " | " + modelName + " | " + solverName + " | Run " + string(idx);
            else
                label = sheetName + " | " + modelName + " | Run " + string(idx);
            end
        end

        function idx = findResultIndexByLabel(app, label)
            idx = [];
            label = string(label);
            if strlength(label) == 0 || isempty(app.RunResults)
                return;
            end

            % Primary match: unique result label.
            for kk = 1:numel(app.RunResults)
                if app.getResultDisplayLabel(app.RunResults{kk}, kk) == label
                    idx = kk;
                    return;
                end
            end

            % fallback 
            for kk = numel(app.RunResults):-1:1
                if isfield(app.RunResults{kk},'Sheet') && string(app.RunResults{kk}.Sheet) == label
                    idx = kk;
                    return;
                end
            end
        end

        function idx = findResultIndexBySheetModel(app, result)
            idx = [];
            if isempty(app.RunResults) || ~isfield(result,'Sheet')
                return;
            end
            sheetName = string(result.Sheet);
            modelName = "";
            if isfield(result,'ModelType')
                modelName = string(result.ModelType);
            end
            for kk = numel(app.RunResults):-1:1
                r = app.RunResults{kk};
                if isfield(r,'Sheet') && string(r.Sheet) == sheetName
                    if strlength(modelName) == 0 || (isfield(r,'ModelType') && string(r.ModelType) == modelName)
                        idx = kk;
                        return;
                    end
                end
            end
        end

        % Labels include model, solver,
        % and run number so repeated fits to the same sheet stay distinguishable.
        function refreshViewSampleList(app)
            if isempty(app.RunResults)
                app.ViewSampleDropDown.Items  = {'(no results yet)'};
                app.ViewSampleDropDown.Value  = '(no results yet)';
                app.ViewSampleDropDown.Enable = "off";

                app.OverlaySelection = string.empty;
                app.OverlaySelectButton.Enable = "off";
                app.OverlaySummaryLabel.Text = "";

                app.StyleSampleDropDown.Items = {'(no results yet)'};
                app.StyleSampleDropDown.Value = '(no results yet)';
                app.StyleSampleDropDown.Enable = "off";

                app.FitMetaLabel.Text = "";
                try
                    app.ParamStatsLabel.Text = "Complete a run to show fitted parameters.";
                    app.ParamStatsTable.Data = {};
                    app.ParamStatsTable.Visible = 'off';
                    app.updateParamStatsColumnWidths(false);
                catch
                end
                return;
            end

            labels = app.getResultListLabels();
            for k = 1:numel(app.RunResults)
                app.getResultPlotStyle(app.RunResults{k}, k);
                if isfield(app.RunResults{k},'Sheet')
                    app.getSamplePlotStyle(string(app.RunResults{k}.Sheet));
                end
            end

            items = cellstr(labels);

            app.ViewSampleDropDown.Items  = items;
            app.ViewSampleDropDown.Enable = "on";
            cur = string(app.ViewSampleDropDown.Value);
            if ~any(strcmp(items, cur))
                app.ViewSampleDropDown.Value = items{end};
            end

            keep = app.OverlaySelection(ismember(cellstr(app.OverlaySelection), items));
            if isempty(keep)
                app.OverlaySelection = string(app.ViewSampleDropDown.Value);
            else
                app.OverlaySelection = keep;
            end

            app.OverlaySelectButton.Enable = "on";
            app.updateOverlaySummary();
            app.refreshStyleSampleList();
        end
        function refreshStyleSampleList(app)
            if isempty(app.RunResults) || strcmp(app.ViewSampleDropDown.Value,'(no results yet)')
                app.StyleSampleDropDown.Items = {'(no results yet)'};
                app.StyleSampleDropDown.Value = '(no results yet)';
                app.StyleSampleDropDown.Enable = "off";
                return;
            end

            results = app.getCurrentViewResults();
            if isempty(results)
                app.StyleSampleDropDown.Items = {'(no results yet)'};
                app.StyleSampleDropDown.Value = '(no results yet)';
                app.StyleSampleDropDown.Enable = "off";
                return;
            end

            names = strings(1,0);
            for ii = 1:numel(results)
                r = results{ii};
                runLabel = app.getResultDisplayLabel(r, NaN);
                names(end+1) = runLabel; 
                app.getSamplePlotStyle(runLabel);

                if isfield(r,'IsCombined') && r.IsCombined && isfield(r,'Components') && ~isempty(r.Components)
                    for j = 1:numel(r.Components)
                        compName = "Component: " + string(r.Components(j).Sheet);
                        names(end+1) = compName;
                        app.getSamplePlotStyle(compName);
                    end
                end
            end

            names = unique(names,'stable');
            items = cellstr(names);
            app.StyleSampleDropDown.Items = items;
            app.StyleSampleDropDown.Enable = "on";

            cur = string(app.StyleSampleDropDown.Value);
            if ~any(strcmp(items, cur))
                app.StyleSampleDropDown.Value = items{1};
            end
            app.onStyleSampleChanged();
        end

        function onViewSampleChanged(app)
            app.refreshStyleSampleList();
            app.updateCurrentFitView();
        end

        function onFitViewControlChanged(app)
            app.updateOverlaySummary();
            app.refreshStyleSampleList();
            app.updateCurrentFitView();
        end

        function chooseOverlaySamples(app)
            if isempty(app.RunResults)
                return;
            end

            labels = app.getResultListLabels();
            items = cellstr(labels);

            initSel = find(ismember(items, cellstr(app.OverlaySelection)));
            if isempty(initSel)
                initSel = find(strcmp(items, char(app.ViewSampleDropDown.Value)));
            end
            if isempty(initSel)
                initSel = numel(items);
            end

            [idx, ok] = listdlg( ...
                'ListString', items, ...
                'SelectionMode', 'multiple', ...
                'InitialValue', initSel, ...
                'ListSize', [520 300], ...
                'PromptString', 'Choose fits to overlay');

            if ~ok
                return;
            end

            if isempty(idx)
                app.OverlaySelection = string(app.ViewSampleDropDown.Value);
            else
                app.OverlaySelection = string(items(idx));
            end

            app.updateOverlaySummary();
            app.refreshStyleSampleList();
            if app.FitOverlayCheck.Value
                app.updateCurrentFitView();
            end
        end

        function chooseRunSheets(app)
            if isempty(app.SheetNames)
                app.log("No sheets loaded.");
                return;
            end
        
            items = cellstr(app.SheetNames);
        
            initSel = find(ismember(items, cellstr(app.RunSheetSelection)));
            if isempty(initSel)
                initSel = 1:min(numel(items),3);
            end
        
            [idx, ok] = listdlg( ...
                'ListString', items, ...
                'SelectionMode', 'multiple', ...
                'InitialValue', initSel, ...
                'ListSize', [320 260], ...
                'PromptString', 'Choose sheets to run');
        
            if ~ok
                return;
            end
        
            if isempty(idx)
                app.RunSheetSelection = string.empty;
                app.log("No run sheets selected.");
            else
                app.RunSheetSelection = string(items(idx));
                app.log("Selected run sheets: " + strjoin(cellstr(app.RunSheetSelection), ", "));
            end
        end


        function chooseCombinedSheets(app)
            if isempty(app.SheetNames)
                app.log("No sheets loaded.");
                return;
            end
        
            items = cellstr(app.SheetNames);
        
            initSel = find(ismember(items, cellstr(app.CombinedSheetSelection)));
            if isempty(initSel)
                initSel = 1:min(numel(items),3);
            end
        
            [idx, ok] = listdlg( ...
                'ListString', items, ...
                'SelectionMode', 'multiple', ...
                'InitialValue', initSel, ...
                'ListSize', [320 260], ...
                'PromptString', 'Choose sheets to combine');
        
            if ~ok
                return;
            end
        
            if isempty(idx)
                app.CombinedSheetSelection = string.empty;
                app.log("No combined sheets selected.");
            else
                app.CombinedSheetSelection = string(items(idx));
                app.log("Selected combined sheets: " + strjoin(cellstr(app.CombinedSheetSelection), ", "));
            end
        end


        function updateOverlaySummary(app)
            if isempty(app.RunResults)
                app.OverlaySummaryLabel.Text = '';
                app.OverlaySelectButton.Enable = 'off';
                return;
            end

            app.OverlaySelectButton.Enable = 'on';
            if ~app.FitOverlayCheck.Value
                app.OverlaySummaryLabel.Text = 'Overlay off';
                return;
            end

            labels = app.OverlaySelection;
            if isempty(labels)
                labels = string(app.ViewSampleDropDown.Value);
            end

            if isscalar(labels)
                app.OverlaySummaryLabel.Text = "1 selected: " + labels(1);
            elseif numel(labels) == 2
                app.OverlaySummaryLabel.Text = "2 selected: " + labels(1) + ", " + labels(2);
            else
                app.OverlaySummaryLabel.Text = sprintf('%d selected fits', numel(labels));
            end
        end

        function updateFitMetaLine(app, result)
            if isfield(result,'Fit')
                label = app.getResultDisplayLabel(result, NaN);
                if isfield(result,'MCMC') && isfield(result.MCMC,'acceptRate')
                    rmsePlot = result.Fit.rmse;
                    r2Plot = result.Fit.r2;
                    try
                        yPlot = app.getDisplayedFitCurve(result, result.x(:));
                        [rmsePlot, r2Plot] = app.computeRmseR2(result.y_obs(:), yPlot(:));
                    catch
                    end
                    app.FitMetaLabel.Text = sprintf("%s | solver=%s | plotted=%s | accept=%.2f%% | RMSE=%.4g | R^2=%.4f", ...
                        label, result.Fit.solver, char(app.getDisplayedFitLegendSuffix(result)), result.MCMC.acceptRate, rmsePlot, r2Plot);
                else
                    app.FitMetaLabel.Text = sprintf("%s | solver=%s | RMSE=%.4g | R^2=%.4f ", ...
                        label, result.Fit.solver, result.Fit.rmse, result.Fit.r2);
                end
            else
                app.FitMetaLabel.Text = "";
            end
        end

        function onFigureSizeChanged(app)
            try
                if ~isempty(app.UIFigure) && isvalid(app.UIFigure) && ~isempty(app.RootGrid) && isvalid(app.RootGrid)
                    figPos = app.UIFigure.Position;
                    app.RootGrid.Position = [1 1 max(figPos(3),1) max(figPos(4),1)];
                end
            catch
            end

           
            try
                app.updateParamStatsColumnWidths(false);
            catch
            end
        end

        function scheduleParamStatsColumnResize(app)
            try
                t = timer( ...
                    'StartDelay',0.12, ...
                    'ExecutionMode','singleShot', ...
                    'TimerFcn',@(~,~)app.updateParamStatsColumnWidths(true), ...
                    'StopFcn',@(src,~)delete(src));
                start(t);
            catch
                try
                    app.updateParamStatsColumnWidths(true);
                catch
                end
            end
        end

        function updateParamStatsColumnWidths(app, forceLayout)
            try
                if nargin < 2
                    forceLayout = false;
                end
                if isempty(app.ParamStatsTable) || ~isvalid(app.ParamStatsTable)
                    return;
                end

                if forceLayout
                    try
                        drawnow limitrate;
                    catch
                    end
                end

                figW = NaN;
                try
                    figW = app.UIFigure.Position(3);
                catch
                end
                leftW = 455;
                plotW = 350;
                try
                    cw = app.RootGrid.ColumnWidth;
                    if iscell(cw) && numel(cw) >= 3
                        if isnumeric(cw{1}), leftW = double(cw{1}); end
                        if isnumeric(cw{3}), plotW = double(cw{3}); end
                    end
                catch
                end

                rootPad = [6 6 6 6];
                rootGap = 7;
                try
                    rootPad = app.RootGrid.Padding;
                catch
                end
                try
                    rootGap = app.RootGrid.ColumnSpacing;
                catch
                end

                % Workspace width available to the entire middle region.
                workspaceW = figW - rootPad(1) - rootPad(3) - 2*rootGap - leftW - plotW;

                actionW = 150;
                try
                    pgcw = app.ParamStatsGrid.ColumnWidth;
                    if iscell(pgcw) && numel(pgcw) >= 2 && isnumeric(pgcw{2})
                        actionW = double(pgcw{2});
                    end
                catch
                end

                targetW = workspaceW - actionW - 78;
                try
                    tp = app.ParamStatsTable.Position;
                    if numel(tp) >= 3 && isfinite(tp(3)) && tp(3) > 300
                        targetW = max(targetW, tp(3) - 18);
                    end
                catch
                end

                if ~isfinite(targetW) || targetW < 600
                    targetW = 1050;
                end
                targetW = floor(max(targetW, 760));

                % Avoid tiny repeated changes during live window dragging.
                if ~forceLayout && isfinite(app.LastParamStatsResizeWidth) && abs(targetW - app.LastParamStatsResizeWidth) < 8
                    return;
                end
                app.LastParamStatsResizeWidth = targetW;

                colNames = string(app.ParamStatsTable.ColumnName);
                nCols = max(1, numel(colNames));

                if any(strcmp(colNames, "-95% CI")) || any(strcmp(colNames, "+95% CI"))
                    weights = [0.27 0.18 0.13 0.13 0.10 0.095 0.095];
                    minW    = [185 135  95   95   80   90    90];
                elseif nCols == 6
                    % NL table. 
                    weights = [0.30 0.23 0.14 0.12 0.10 0.11];
                    minW    = [190 170 100  90  85  95];
                else
                    weights = ones(1,nCols) ./ nCols;
                    minW = repmat(90,1,nCols);
                    if nCols >= 1, minW(1) = 170; end
                    if nCols >= 2, minW(2) = 150; end
                end

                if numel(weights) ~= nCols
                    weights = ones(1,nCols) ./ nCols;
                    minW = repmat(90,1,nCols);
                end

                widths = max(round(targetW .* weights), minW);

                % Exact-fill correction.
                delta = round(targetW - sum(widths));
                if delta > 0
                    % most extra width into the text columns, with a small
                    % amount going to the last numeric column to reach the edge.
                    grow = ones(1,nCols);
                    if nCols >= 1, grow(1) = 2.8; end
                    if nCols >= 2, grow(2) = 2.1; end
                    if nCols >= 6, grow(end) = 1.4; end
                    grow = grow ./ sum(grow);
                    add = floor(delta .* grow);
                    add(end) = add(end) + (delta - sum(add));
                    widths = widths + add;
                elseif delta < 0
                    need = -delta;
                    room = max(widths - minW, 0);
                    while need > 0 && any(room > 0)
                        [~, ii] = max(room);
                        widths(ii) = widths(ii) - 1;
                        room(ii) = room(ii) - 1;
                        need = need - 1;
                    end
                end

                app.ParamStatsTable.ColumnWidth = num2cell(max(widths, minW));
            catch
            end
        end

        % Populate the parameter table for the selected run or overlay. NL and MCMC
        % use different table layouts
        function updateParamStatsView(app, results)
            try
                if isempty(results)
                    app.ParamStatsLabel.Text = "Complete a run to show fitted parameters.";
                    if strcmp(app.normalizeSolverType(string(app.SolverDropDown.Value)), "MCMC")
                        app.ParamStatsTable.ColumnName = {'Sample','Parameter','Posterior Mean','Best Fit','SD','-95% CI','+95% CI'};
                    else
                        app.ParamStatsTable.ColumnName = {'Sample','Parameter','Best Fit','SE','tStat','pValue'};
                    end
                    app.ParamStatsTable.Data = {};
                    app.ParamStatsTable.Visible = 'off';
                    app.updateParamStatsColumnWidths(false);
                    return;
                end

                if ~iscell(results)
                    results = {results};
                end

                isMCMC = false(1,numel(results));
                for rr = 1:numel(results)
                    isMCMC(rr) = app.isMCMCResult(results{rr});
                end
                useMCMCTable = any(isMCMC);

                rows = {};
                for rr = 1:numel(results)
                    result = results{rr};
                    if isempty(result) || ~isstruct(result) || ~isfield(result,'b_fit')
                        continue;
                    end

                    names = app.getParamDisplayNames(result.ModelType);
                    nP = min(numel(names), numel(result.b_fit));

                    stats = struct();
                    if isfield(result,'Fit') && isfield(result.Fit,'paramStats')
                        stats = result.Fit.paramStats;
                    end

                    sampleName = char(app.getResultDisplayLabel(result, NaN));

                    if useMCMCTable
                        for ii = 1:nP
                            if app.isMCMCResult(result)
                                meanVal = app.getMCMCStatValue(result, stats, 'mean', ii);
                                bestVal = app.getMCMCStatValue(result, stats, 'best', ii);
                                sdVal   = app.getMCMCStatValue(result, stats, 'sd', ii);
                                ciLow   = app.getMCMCStatValue(result, stats, 'ciLow', ii);
                                ciHigh  = app.getMCMCStatValue(result, stats, 'ciHigh', ii);
                            else
                                % Mixed overlays:
                                % show NL estimates in the MCMC
                                % style with
                                % unavailable posterior-only columns left as NaN.
                                meanVal = app.paramOrNaN(result.b_fit, ii);
                                bestVal = app.paramOrNaN(result.b_fit, ii);
                                sdVal   = app.getStatField(stats, 'se', ii);
                                ciLow   = app.getStatField(stats, 'ciLow', ii);
                                ciHigh  = app.getStatField(stats, 'ciHigh', ii);
                            end

                            ciMinus = max(meanVal - ciLow, 0);
                            ciPlus  = max(ciHigh - meanVal, 0);

                            rows(end+1,:) = { ... 
                                sampleName, ...
                                char(names(ii)), ...
                                app.formatStat(meanVal), ...
                                app.formatStat(bestVal), ...
                                app.formatStat(sdVal), ...
                                app.formatStat(ciMinus), ...
                                app.formatStat(ciPlus)};
                        end
                    else
                        for ii = 1:nP
                            rows(end+1,:) = { ... 
                                sampleName, ...
                                char(names(ii)), ...
                                app.formatStat(result.b_fit(ii)), ...
                                app.formatStat(app.getStatField(stats, 'se', ii)), ...
                                app.formatStat(app.getStatField(stats, 'tStat', ii)), ...
                                app.formatStat(app.getStatField(stats, 'pValue', ii))};
                        end
                    end
                end

                if useMCMCTable
                    app.ParamStatsTable.ColumnName = {'Sample','Parameter','Posterior Mean','Best Fit','SD','-95% CI','+95% CI'};
                else
                    app.ParamStatsTable.ColumnName = {'Sample','Parameter','Best Fit','SE','tStat','pValue'};
                end
                app.ParamStatsTable.Data = rows;
                app.LastParamStatsResizeWidth = NaN;
                if isempty(rows)
                    app.ParamStatsTable.Visible = 'off';
                    app.ParamStatsLabel.Text = "Complete a run to show fitted parameters.";
                else
                    app.ParamStatsTable.Visible = 'on';
                end
                app.LastParamStatsResizeWidth = NaN;
                app.updateParamStatsColumnWidths(false);
                if strcmp(string(app.ParamStatsTable.Visible), "on")
                    app.scheduleParamStatsColumnResize();
                end

                if isscalar(results)
                    app.ParamStatsLabel.Text = "Current sample: " + app.getResultDisplayLabel(results{1}, NaN);
                else
                    app.ParamStatsLabel.Text = sprintf("Overlay comparison | %d selected fits", numel(results));
                end
            catch ME
                try
                    app.ParamStatsLabel.Text = "Could not display fitted parameter statistics: " + string(ME.message);
                    app.ParamStatsTable.Data = {};
                    app.ParamStatsTable.Visible = 'off';
                    app.updateParamStatsColumnWidths(false);
                catch
                end
            end
        end

        function appendCurrentFitToResults(app)
            try
                results = app.getCurrentViewResults();
                if isempty(results)
                    app.log("No current fit to append.");
                    return;
                end

                rows = {};
                for ii = 1:numel(results)
                    rows = [rows; app.buildAppendedParamRows(results{ii})]; 
                end

                if isempty(rows)
                    app.log("No fitted-parameter rows were available to append.");
                    return;
                end

                for ii = 1:numel(results)
                    app.AppendedResultsList{end+1} = results{ii}; 
                end

                if isempty(app.AppendedResultsData)
                    app.AppendedResultsData = rows;
                else
                    app.AppendedResultsData = [app.AppendedResultsData; rows];
                end

                app.ResultsTable.ColumnName = app.getAppendedResultsHeaders();
                app.ResultsTable.Data = app.AppendedResultsData;
                app.TabGroup.SelectedTab = app.TabResults;
                app.log(sprintf("Appended %d fitted-parameter rows to the Results window.", size(rows,1)));
            catch ME
                app.log("Append to results failed: " + string(ME.message));
                app.log(getReport(ME,'basic','hyperlinks','off'));
            end
        end

        function exportAppendedResultsToExcel(app)
            try
                if isempty(app.AppendedResultsList)
                    app.log("No appended results to export. Use 'Append to Results' first.");
                    return;
                end

                cfg = app.getConfig();
                outDir = app.ensureOutputDir(cfg);
                defaultFile = fullfile(outDir, "CSDStudio_Appended_Results_" + string(datetime("now","Format","yyyyMMdd_HHmmss")) + ".xlsx");

                [f,p] = uiputfile({'*.xlsx','Excel workbook (*.xlsx)'}, ...
                    'Export appended results', char(defaultFile));
                if isequal(f,0)
                    return;
                end

                outFile = fullfile(string(p), string(f));
                [~,~,ext] = fileparts(outFile);
                if strlength(string(ext)) == 0
                    outFile = outFile + ".xlsx";
                end

                for ii = 1:numel(app.AppendedResultsList)
                    result = app.AppendedResultsList{ii};
                    if isempty(result) || ~isstruct(result)
                        continue;
                    end

                    sheetName = app.excelSafeSheetName(result.Sheet, outFile);
                    app.writeAppendedResultSheet(outFile, sheetName, result);
                end

                app.log("Exported appended results to: " + outFile);
            catch ME
                app.log("Export results to Excel failed: " + string(ME.message));
                app.log(getReport(ME,'basic','hyperlinks','off'));
            end
        end

        % Write one result to a worksheet. Fit-line data are kept on the left and
        % summary/parameter tables are placed to the right.
        function writeAppendedResultSheet(app, outFile, sheetName, result)
            timestamp = string(datetime("now","Format","yyyy-MM-dd HH:mm:ss"));

            runLabel = app.getResultDisplayLabel(result, NaN);
            runNumber = NaN;
            try
                if isfield(result,'RunNumber')
                    runNumber = double(result.RunNumber);
                end
            catch
                runNumber = NaN;
            end

            % Export layout:
            %   A:B (or A:D for MCMC) = fit-line data
            %   one blank separator column
            %   summary + fitted-parameter table start to the right
            %
 
            [fitHeaders, fitData] = app.buildFitLineExportData(result);
            nFitCols = numel(fitHeaders);

            if nFitCols > 0
                writecell({'Fit-line data'}, outFile, "Sheet", sheetName, "Range", "A1");
                writecell(fitHeaders,       outFile, "Sheet", sheetName, "Range", "A2");
                if ~isempty(fitData)
                    writecell(fitData,      outFile, "Sheet", sheetName, "Range", "A3");
                end
            end

            if nFitCols > 0
                % +2 gives one blank column between fit-line data and summary.
                % NL fits use A:B, so summary starts in D.
                % MCMC fits use A:D, so summary starts in F.
                summaryStartCol = nFitCols + 2;
            else
                summaryStartCol = 1;
            end
            summaryStart = localExcelColumnName(summaryStartCol);

            summaryHeaders = {'Result','Sample','Model','Solver','Run','RMSE','R2','alpha1','alpha2','Exported'};
            summaryValues = { ...
                char(runLabel), ...
                char(result.Sheet), ...
                char(result.ModelType), ...
                char(result.Fit.solver), ...
                runNumber, ...
                double(result.Fit.rmse), ...
                double(result.Fit.r2), ...
                double(result.alpha1), ...
                double(result.alpha2), ...
                timestamp};

            writecell(summaryHeaders, outFile, "Sheet", sheetName, "Range", summaryStart + "1");
            writecell(summaryValues,  outFile, "Sheet", sheetName, "Range", summaryStart + "2");

            [paramHeaders, paramRows] = app.buildFittedParameterExportTable(result);
            paramHeaderRow = 5;
            writecell({'Fitted parameter table'}, outFile, "Sheet", sheetName, "Range", summaryStart + "4");
            writecell(paramHeaders, outFile, "Sheet", sheetName, "Range", summaryStart + string(paramHeaderRow));
            if ~isempty(paramRows)
                writecell(paramRows, outFile, "Sheet", sheetName, "Range", summaryStart + string(paramHeaderRow + 1));
            end

            function colName = localExcelColumnName(colNum)
                colNum = max(1, round(double(colNum)));
                chars = "";
                while colNum > 0
                    remVal = mod(colNum - 1, 26);
                    chars = string(char(65 + remVal)) + chars;
                    colNum = floor((colNum - 1) / 26);
                end
                colName = chars;
            end
        end

        function [headers, data] = buildFitLineExportData(app, result)
            headers = {};
            data = {};
            try
                x = result.xx(:);
                if isempty(x) || any(~isfinite(x))
                    x = linspace(0, max(result.x(:)), 200).';
                end
                modelType = app.normalizeModelType(string(result.ModelType));

                if app.isMCMCResult(result)
                    bBest = app.getBestFitVector(result);
                    yMean = app.getPosteriorMeanModelCurve(result, x, true);
                    if isempty(yMean) || numel(yMean) ~= numel(x) || any(~isfinite(yMean))
                        bMean = app.getMeanFitVector(result);
                        yMean = result.Model(bMean, x);
                    end
                    yBest = result.Model(bBest, x);
                    headers = {'L_mean_mm','ln_n_posterior_mean_model','L_best_mm','ln_n_best_fit'};
                    data = num2cell([x(:), yMean(:), x(:), yBest(:)]);
                else
                    bBest = app.getBestFitVector(result);
                    yBest = result.Model(bBest, x);
                    if strcmp(modelType, "Growth-Law")
                        headers = {'L_mm','ln_n_growth_law_best_fit'};
                    elseif strcmp(modelType, "Linear")
                        headers = {'L_mm','ln_n_linear_best_fit'};
                    else
                        headers = {'L_mm','ln_n_fit'};
                    end
                    data = num2cell([x(:), yBest(:)]);
                end
            catch ME
                app.log("Fit-line export failed for " + string(result.Sheet) + ": " + string(ME.message));
                headers = {};
                data = {};
            end
        end

        function b = getMeanFitVector(~, result)
            b = result.b_fit;
            try
                if isfield(result,'b_mean') && ~isempty(result.b_mean)
                    b = result.b_mean;
                elseif isfield(result,'MCMC') && isfield(result.MCMC,'b_mean') && ~isempty(result.MCMC.b_mean)
                    b = result.MCMC.b_mean;
                end
            catch
                b = result.b_fit;
            end
            b = double(b(:)).';
        end

        function b = getBestFitVector(~, result)
            b = result.b_fit;
            try
                if isfield(result,'b_map') && ~isempty(result.b_map)
                    b = result.b_map;
                elseif isfield(result,'MCMC') && isfield(result.MCMC,'b_map') && ~isempty(result.MCMC.b_map)
                    b = result.MCMC.b_map;
                end
            catch
                b = result.b_fit;
            end
            b = double(b(:)).';
        end

        function exportPlotsPressed(app)
            try
                cfg = app.getConfig();
                app.ensureOutputDir(cfg);

                if ~isempty(app.AppendedResultsList)
                    results = app.AppendedResultsList;
                else
                    results = app.getCurrentViewResults();
                    if isempty(results)
                        app.log("No appended/current results to export plots for.");
                        return;
                    end
                end

                for ii = 1:numel(results)
                    if isempty(results{ii}) || ~isstruct(results{ii})
                        continue;
                    end
                    app.savePlotArtifacts(cfg, results{ii});
                end
                app.log("Exported plots to: " + cfg.OutputDir);
            catch ME
                app.log("Export plots failed: " + string(ME.message));
                app.log(getReport(ME,'basic','hyperlinks','off'));
            end
        end

        function rows = buildAppendedParamRows(app, result)
            % Results window export uses a single readable layout so mixed
            % NL/MCMC appends can coexist.
            rows = {};
            if isempty(result) || ~isstruct(result) || ~isfield(result,'b_fit')
                return;
            end

            [paramHeaders, paramRows] = app.buildFittedParameterExportTable(result);
            if isempty(paramRows)
                return;
            end

            for ii = 1:size(paramRows,1)
                paramName = '';
                bestFit = NaN;
                se = NaN;
                tStat = NaN;
                pValue = NaN;
                posteriorMean = NaN;
                sd = NaN;
                ciMinus = NaN;
                ciPlus = NaN;
                ciLow = NaN;
                ciHigh = NaN;

                if app.isMCMCResult(result)
                    % MCMC fitted-parameter table schema:
                    % Sample | Parameter | Posterior Mean | Best Fit | SD | -95% CI | +95% CI
                    paramName = paramRows{ii,2};
                    posteriorMean = paramRows{ii,3};
                    bestFit = paramRows{ii,4};
                    sd = paramRows{ii,5};
                    ciMinus = paramRows{ii,6};
                    ciPlus = paramRows{ii,7};

                    % Also retain absolute interval bounds for spreadsheet use.
                    try
                        ciLow = posteriorMean - ciMinus;
                        ciHigh = posteriorMean + ciPlus;
                    catch
                    end
                else
                    % NL fitted-parameter table schema:
                    % Sample | Parameter | Best Fit | SE | tStat | pValue
                    paramName = paramRows{ii,2};
                    bestFit = paramRows{ii,3};
                    se = paramRows{ii,4};
                    tStat = paramRows{ii,5};
                    pValue = paramRows{ii,6};
                end

                rows(end+1,:) = { ... 
                    char(app.getResultDisplayLabel(result, NaN)), ...
                    char(result.Sheet), ...
                    char(result.ModelType), ...
                    char(result.Fit.solver), ...
                    char(paramName), ...
                    bestFit, ...
                    se, ...
                    tStat, ...
                    pValue, ...
                    posteriorMean, ...
                    sd, ...
                    ciMinus, ...
                    ciPlus, ...
                    ciLow, ...
                    ciHigh};
            end
        end

        function headers = getAppendedResultsHeaders(~)
            headers = {'Result','Sample','Model','Solver','Parameter', ...
                'Best Fit','SE','tStat','pValue', ...
                'Posterior Mean','SD','-95% CI','+95% CI','CI Low','CI High'};
        end

        function [headers, rows] = buildFittedParameterExportTable(app, result)
            % Build the exact fittedparameter table used for one exported
            % result sheet. NL and MCMC intentionally have different headers,
            % matching the fitted-parameter window.
            rows = {};
            if app.isMCMCResult(result)
                headers = {'Sample','Parameter','Posterior Mean','Best Fit','SD','-95% CI','+95% CI'};
            else
                headers = {'Sample','Parameter','Best Fit','SE','tStat','pValue'};
            end

            if isempty(result) || ~isstruct(result) || ~isfield(result,'b_fit')
                return;
            end

            names = app.getParamDisplayNames(result.ModelType);
            nP = min(numel(names), numel(result.b_fit));
            stats = struct();
            if isfield(result,'Fit') && isfield(result.Fit,'paramStats')
                stats = result.Fit.paramStats;
            end
            sampleName = char(app.getResultDisplayLabel(result, NaN));

            for ii = 1:nP
                if app.isMCMCResult(result)
                    meanVal = app.getMCMCStatValue(result, stats, 'mean', ii);
                    bestVal = app.getMCMCStatValue(result, stats, 'best', ii);
                    sdVal   = app.getMCMCStatValue(result, stats, 'sd', ii);
                    ciLow   = app.getMCMCStatValue(result, stats, 'ciLow', ii);
                    ciHigh  = app.getMCMCStatValue(result, stats, 'ciHigh', ii);
                    ciMinus = max(meanVal - ciLow, 0);
                    ciPlus  = max(ciHigh - meanVal, 0);

                    rows(end+1,:) = { ... 
                        sampleName, ...
                        char(names(ii)), ...
                        double(meanVal), ...
                        double(bestVal), ...
                        double(sdVal), ...
                        double(ciMinus), ...
                        double(ciPlus)};
                else
                    rows(end+1,:) = { ... 
                        sampleName, ...
                        char(names(ii)), ...
                        app.paramOrNaN(result.b_fit, ii), ...
                        app.fitStatOrNaN(result,'se',ii), ...
                        app.fitStatOrNaN(result,'tStat',ii), ...
                        app.fitStatOrNaN(result,'pValue',ii)};
                end
            end
        end

        function names = getParamDisplayNames(app, modelType)
            modelType = app.normalizeModelType(string(modelType));
            if strcmp(modelType, "3-Chamber")
                names = ["n₁⁰", "G₁τ₁", "n₂⁰", "G₂τ₂", "nₘ⁰", "Gₘτₘ"];
            elseif strcmp(modelType, "Growth-Law")
                names = ["n⁰", "b", "G₀τ₀"];
            elseif strcmp(modelType, "Linear")
                names = ["n⁰", "Gτ"];
            else
                names = ["n₁⁰", "G₁τ₁", "nₘ⁰", "Gₘτₘ"];
            end
        end
        function names = getParamLatexDisplayNames(app, modelType)
            modelType = app.normalizeModelType(string(modelType));
            if strcmp(modelType, "3-Chamber")
                names = ["$n_1^0$", "$G_1\tau_1$", "$n_2^0$", "$G_2\tau_2$", "$n_m^0$", "$G_m\tau_m$"];
            elseif strcmp(modelType, "Growth-Law")
                names = ["$n^0$", "$b$", "$G_0\tau_0$"];
            elseif strcmp(modelType, "Linear")
                names = ["$n^0$", "$G\tau$"];
            else
                names = ["$n_1^0$", "$G_1\tau_1$", "$n_m^0$", "$G_m\tau_m$"];
            end
        end
        function label = getParamEquationLabel(app, modelType)
            modelType = app.normalizeModelType(string(modelType));
            if strcmp(modelType, "3-Chamber")
                label = "3-Chamber parameters: n₁⁰, G₁τ₁, n₂⁰, G₂τ₂, nₘᵢₓ⁰, Gₘᵢₓτₘᵢₓ; α₁ and α₂ are fixed.";
            elseif strcmp(modelType, "Growth-Law")
                label = "Growth-Law parameters: n⁰, b, G₀τ₀; a is constrained internally so aG₀τ₀ = 1.";
            elseif strcmp(modelType, "Linear")
                label = "Linear parameters: n⁰ and Gτ, where ln(n) = ln(n⁰) - L/(Gτ).";
            else
                label = "2-Chamber parameters: n₁⁰, G₁τ₁, nₘᵢₓ⁰, Gₘᵢₓτₘᵢₓ.";
            end
        end
        function s = formatStat(~, v)
            if isempty(v) || ~isnumeric(v) || ~isfinite(v)
                s = 'NaN';
            elseif abs(v) >= 1e4 || (abs(v) > 0 && abs(v) < 1e-3)
                s = sprintf('%.4e', double(v));
            else
                s = sprintf('%.5g', double(v));
            end
        end

        function v = getStatField(~, stats, fieldName, idx)
            v = NaN;
            try
                if isstruct(stats) && isfield(stats, fieldName)
                    arr = stats.(fieldName);
                    if numel(arr) >= idx
                        v = double(arr(idx));
                    end
                end
            catch
                v = NaN;
            end
        end

        function tf = isMCMCResult(~, result)
            tf = false;
            try
                if isstruct(result)
                    if isfield(result,'MCMC') && ~isempty(result.MCMC)
                        tf = true;
                        return;
                    end
                    if isfield(result,'SolverType') && contains(lower(string(result.SolverType)), "mcmc")
                        tf = true;
                        return;
                    end
                    if isfield(result,'Fit') && isfield(result.Fit,'solver') && contains(lower(string(result.Fit.solver)), "mcmc")
                        tf = true;
                        return;
                    end
                end
            catch
                tf = false;
            end
        end

        function v = getMCMCStatValue(app, result, stats, fieldName, idx)
            v = NaN;
            fieldName = string(fieldName);
            try
                if isstruct(stats) && isfield(stats, char(fieldName))
                    arr = stats.(char(fieldName));
                    if numel(arr) >= idx
                        v = double(arr(idx));
                        return;
                    end
                end
            catch
            end

            try
                if isfield(result,'MCMC') && isstruct(result.MCMC)
                    switch fieldName
                        case "mean"
                            if isfield(result.MCMC,'b_mean'); v = app.paramOrNaN(result.MCMC.b_mean, idx); return; end
                        case "best"
                            if isfield(result.MCMC,'b_map'); v = app.paramOrNaN(result.MCMC.b_map, idx); return; end
                        case "sd"
                            if isfield(result.MCMC,'b_std'); v = app.paramOrNaN(result.MCMC.b_std, idx); return; end
                        case "ciLow"
                            if isfield(result.MCMC,'ciLow'); v = app.paramOrNaN(result.MCMC.ciLow, idx); return; end
                        case "ciHigh"
                            if isfield(result.MCMC,'ciHigh'); v = app.paramOrNaN(result.MCMC.ciHigh, idx); return; end
                    end
                end
            catch
            end

            try
                switch fieldName
                    case "mean"
                        if isfield(result,'b_mean'); v = app.paramOrNaN(result.b_mean, idx); else, v = app.paramOrNaN(result.b_fit, idx); end
                    case "best"
                        if isfield(result,'b_map'); v = app.paramOrNaN(result.b_map, idx); else, v = app.paramOrNaN(result.b_fit, idx); end
                    case "sd"
                        if isfield(result,'b_std'); v = app.paramOrNaN(result.b_std, idx); else, v = app.getStatField(stats, 'se', idx); end
                    case "ciLow"
                        v = app.getStatField(stats, 'ciLow', idx);
                    case "ciHigh"
                        v = app.getStatField(stats, 'ciHigh', idx);
                end
            catch
                v = NaN;
            end
        end

        function s = formatPMCI(app, centerVal, ciLow, ciHigh)
            if isempty(centerVal) || isempty(ciLow) || isempty(ciHigh) || ...
                    ~isnumeric(centerVal) || ~isnumeric(ciLow) || ~isnumeric(ciHigh) || ...
                    ~isfinite(centerVal) || ~isfinite(ciLow) || ~isfinite(ciHigh)
                s = 'NaN';
                return;
            end

            lo = max(double(centerVal) - double(ciLow), 0);
            hi = max(double(ciHigh) - double(centerVal), 0);
            s = ['-' app.formatStat(lo) ' / +' app.formatStat(hi)];
        end

        % Refresh the embedded fit plot and parameter table.
        function updateCurrentFitView(app)
            results = app.getCurrentViewResults();
            if isempty(results)
                cla(app.FitAxes);
                app.FitMetaLabel.Text = "";
                app.updateParamStatsView([]);
                return;
            end

            app.drawFitAxes(app.FitAxes, results);
            drawnow limitrate;

            if isscalar(results)
                app.updateFitMetaLine(results{1});
                app.updateParamStatsView(results{1});
            else
                app.updateParamStatsView(results);
                names = strings(1,numel(results));
                for i = 1:numel(results)
                    names(i) = app.getResultDisplayLabel(results{i}, NaN);
                end
                app.FitMetaLabel.Text = sprintf("Overlay mode | n=%d | %s", numel(results), strjoin(cellstr(names), ", "));
            end

            % Do not create, refresh, or raise the detached fit figure from
            % automatic view updates. 

            app.TabGroup.SelectedTab = app.TabFit;
        end

        function results = getCurrentViewResults(app)
            results = {};
            if isempty(app.RunResults); return; end

            if app.FitOverlayCheck.Value
                labels = app.OverlaySelection;
                if isempty(labels)
                    labels = string(app.ViewSampleDropDown.Value);
                end
            else
                labels = string(app.ViewSampleDropDown.Value);
            end

            for i = 1:numel(labels)
                idx = app.findResultIndexByLabel(labels(i));
                if ~isempty(idx)
                    results{end+1} = app.RunResults{idx}; 
                end
            end
        end

        % Create or refresh the detached figure only when asked for it.
        function popOutFitPressed(app)
            results = app.getCurrentViewResults();
            if isempty(results); return; end
            app.FitFigureUserOpened = true;
            app.ensureFitFigure();
            app.drawFitAxes(app.FitFigureAxes, results);
            try
                app.FitFigure.Visible = 'on';
            catch
            end
            figure(app.FitFigure);
        end

        % Prepare the detached figure in the background. It stays hidden until the
        % Pop out callback makes it visible and brings it forward.
        function ensureFitFigure(app)
            % only prepares the detached figure. 
            if isempty(app.FitFigure) || ~isvalid(app.FitFigure)
                app.FitFigure = figure( ...
                    'Name','CSD Fit Plot', ...
                    'Visible','off', ...
                    'Color','w', ...
                    'Position',[220 120 1000 700], ...
                    'CloseRequestFcn',@(src,evt)app.closeFitFigure(src));
                app.FitFigureAxes = axes(app.FitFigure);
            elseif isempty(app.FitFigureAxes) || ~isvalid(app.FitFigureAxes)
                clf(app.FitFigure);
                app.FitFigureAxes = axes(app.FitFigure);
            end
        end

        function closeFitFigure(app, src)
            try
                app.FitFigureUserOpened = false;
            catch
            end
            try
                delete(src);
            catch
            end
            try
                app.FitFigure = [];
                app.FitFigureAxes = [];
            catch
            end
        end

        % Shared plotting routine for the embedded axes, detached figure, and exports.
      
        function drawFitAxes(app, ax, results, useFullMCMCChainForEnvelope)
            if nargin < 4
                useFullMCMCChainForEnvelope = false;
            end
            try
                legend(ax,'off');
            catch
            end
            try
                delete(ax.Children);
            catch
            end
            cla(ax,'reset');
            hold(ax,'on');
        
            legHandles = gobjects(0);
            legLabels  = {};
            usedLegendKeys  = strings(0,1);
            plottedDataKeys = strings(0,1);

            % Pre-count the simple fit labels. If two overlaid fits would have
            % the same cleaned label, only then append a compact model tag so
            % the fit lines remain distinguishable without messy look.
            fitBaseLabels = strings(1,numel(results));
            for ii = 1:numel(results)
                fitBaseLabels(ii) = app.makeLegendFitLabel(results{ii});
            end
        
            for i = 1:numel(results)
                r = results{i};
        
                if isfield(r,'IsCombined') && r.IsCombined
                    % ----- build plotting x-grid for combined fit -----
                    xRight = app.getFitCurveXRight(r.x);
                    xPlot = linspace(0, xRight, numel(r.xx)).';
                    yPred = app.getDisplayedFitCurve(r, xPlot, useFullMCMCChainForEnvelope);
        
                    % ----- plot component data -----
                    for j = 1:numel(r.Components)
                        part = r.Components(j);
                        dataLabel = app.makeLegendDataLabel(part.Sheet);
                        dataKey = app.makeLegendKey("data:" + dataLabel);

                        % In overlay mode: Plot and label that data only
                        % once so the legend does not repeat marker entries.
                        if any(plottedDataKeys == dataKey)
                            continue;
                        end
                        plottedDataKeys(end+1,1) = dataKey; 

                        styPart = app.getSamplePlotStyle("Component: " + string(part.Sheet));
        
                        mf = app.parsePlotColor(styPart.MarkerFaceColor, 'y');
                        me = app.parsePlotColor(styPart.MarkerEdgeColor, 'b');
        
                        % excluded points
                        if isfield(part,'x_excl') && ~isempty(part.x_excl)
                            xex = part.x_excl(:);
                            yex = part.y_excl(:);
                            nex = min(numel(xex), numel(yex));
                            xex = xex(1:nex);
                            yex = yex(1:nex);
        
                            scatter(ax, xex, yex, max(60, 0.45*styPart.MarkerSize), ...
                                styPart.MarkerShape, ...
                                'MarkerFaceColor', [0.72 0.72 0.72], ...
                                'MarkerEdgeColor', [0.45 0.45 0.45], ...
                                'LineWidth', 1.2, ...
                                'HandleVisibility','off');
                        end
        
                        % included points
                        xp = part.x(:);
                        yp = part.y_obs(:);
                        np = min(numel(xp), numel(yp));
                        xp = xp(1:np);
                        yp = yp(1:np);
        
                        scatter(ax, xp, yp, styPart.MarkerSize, ...
                            styPart.MarkerShape, ...
                            'MarkerFaceColor', mf, ...
                            'MarkerEdgeColor', me, ...
                            'LineWidth', 2.0, ...
                            'HandleVisibility','off');
        
                        hLeg = plot(ax, nan, nan, styPart.MarkerShape, ...
                            'MarkerFaceColor', mf, ...
                            'MarkerEdgeColor', me, ...
                            'MarkerSize', 16, ...
                            'LineWidth', 2.0);
                        legHandles(end+1) = hLeg; 
                        legLabels{end+1} = char(dataLabel); 
                        usedLegendKeys(end+1,1) = app.makeLegendKey(dataLabel); 
                    end
        
                    % ----- combined fit line -----
                    styModel = app.getResultPlotStyle(r, NaN);
                    lcModel = app.parsePlotColor(styModel.LineColor, 'k');
        
                    if isfield(styModel,'ShowFitLine') && styModel.ShowFitLine
                        if app.shouldPlotMCMCCredibleBand(r, useFullMCMCChainForEnvelope)
                            app.plotMCMCCredibleBand(ax, r, xPlot, lcModel, useFullMCMCChainForEnvelope);
                        end

                        plot(ax, xPlot, yPred, ...
                            'LineStyle', char(styModel.LineStyle), ...
                            'Color', lcModel, ...
                            'LineWidth', styModel.LineWidth, ...
                            'HandleVisibility','off');
        
                        hLeg = plot(ax, nan, nan, ...
                            'LineStyle', char(styModel.LineStyle), ...
                            'Color', lcModel, ...
                            'LineWidth', styModel.LineWidth);

                        fitLabel = app.makeLegendFitLabel(r);
                        if nnz(fitBaseLabels == fitLabel) > 1
                            fitLabel = fitLabel + " (" + string(r.ModelType) + ")";
                        end
                        fitLabel = app.makeUniqueLegendLabel(fitLabel, r, usedLegendKeys);

                        legHandles(end+1) = hLeg; 
                        legLabels{end+1} = char(fitLabel); 
                        usedLegendKeys(end+1,1) = app.makeLegendKey(fitLabel); 
                    end
        
                else
                    % ----- single-sheet plotting grid for fit only -----
                    xRight = app.getFitCurveXRight(r.x);
                    xPlot = linspace(0, xRight, numel(r.xx)).';
                    yPred = app.getDisplayedFitCurve(r, xPlot, useFullMCMCChainForEnvelope);
        
                    sty = app.getResultPlotStyle(r, NaN);
                    mf = app.parsePlotColor(sty.MarkerFaceColor, 'y');
                    me = app.parsePlotColor(sty.MarkerEdgeColor, 'b');
                    lc = app.parsePlotColor(sty.LineColor, 'k');

                    dataLabel = app.makeLegendDataLabel(r.Sheet);
                    dataKey = app.makeLegendKey("data:" + dataLabel);
        
                    if ~any(plottedDataKeys == dataKey)
                        plottedDataKeys(end+1,1) = dataKey; 

                        % excluded points
                        if isfield(r,'Exclusions') && isfield(r.Exclusions,'x_excl') && ~isempty(r.Exclusions.x_excl)
                            xex = r.Exclusions.x_excl(:);
                            yex = r.Exclusions.y_excl(:);
                            nex = min(numel(xex), numel(yex));
                            xex = xex(1:nex);
                            yex = yex(1:nex);
        
                            scatter(ax, xex, yex, max(60, 0.45*sty.MarkerSize), ...
                                sty.MarkerShape, ...
                                'MarkerFaceColor', [0.72 0.72 0.72], ...
                                'MarkerEdgeColor', [0.45 0.45 0.45], ...
                                'LineWidth', 1.2, ...
                                'HandleVisibility','off');
                        end
        
                        % included data point
                        xr = r.x(:);
                        yr = r.y_obs(:);
                        nr = min(numel(xr), numel(yr));
                        xr = xr(1:nr);
                        yr = yr(1:nr);
        
                        scatter(ax, xr, yr, sty.MarkerSize, ...
                            sty.MarkerShape, ...
                            'MarkerFaceColor', mf, ...
                            'MarkerEdgeColor', me, ...
                            'LineWidth', 2.0, ...
                            'HandleVisibility','off');
        
                        hLeg = plot(ax, nan, nan, sty.MarkerShape, ...
                            'MarkerFaceColor', mf, ...
                            'MarkerEdgeColor', me, ...
                            'MarkerSize', 16, ...
                            'LineWidth', 2.0);
                        legHandles(end+1) = hLeg; 
                        legLabels{end+1} = char(dataLabel); 
                        usedLegendKeys(end+1,1) = app.makeLegendKey(dataLabel); 
                    end
        
                    % fit line:
                    if isfield(sty,'ShowFitLine') && sty.ShowFitLine
                        if app.shouldPlotMCMCCredibleBand(r, useFullMCMCChainForEnvelope)
                            app.plotMCMCCredibleBand(ax, r, xPlot, lc, useFullMCMCChainForEnvelope);
                        end

                        plot(ax, xPlot, yPred, ...
                            'LineStyle', char(sty.LineStyle), ...
                            'Color', lc, ...
                            'LineWidth', sty.LineWidth, ...
                            'HandleVisibility','off');
        
                        hLeg = plot(ax, nan, nan, ...
                            'LineStyle', char(sty.LineStyle), ...
                            'Color', lc, ...
                            'LineWidth', sty.LineWidth);

                        fitLabel = app.makeLegendFitLabel(r);
                        if nnz(fitBaseLabels == fitLabel) > 1
                            fitLabel = fitLabel + " (" + string(r.ModelType) + ")";
                        end
                        fitLabel = app.makeUniqueLegendLabel(fitLabel, r, usedLegendKeys);

                        legHandles(end+1) = hLeg; 
                        legLabels{end+1} = char(fitLabel); 
                        usedLegendKeys(end+1,1) = app.makeLegendKey(fitLabel); 
                    end
                end
            end
        
            xlabel(ax,'L (mm)','FontSize',14);
            ylabel(ax,'ln(n) mm^{-4}','FontSize',14);
            title(ax,'');
        
            if ~isempty(legHandles)
                lgd = legend(ax, legHandles, legLabels, 'Location','northeast');
                lgd.FontSize = 18;
                try
                    lgd.Color = [1 1 1];
                catch
                end
                try
                    lgd.EdgeColor = [0 0 0];
                catch
                end
                try
                    lgd.TextColor = [0.10 0.12 0.16];
                catch
                end
            end
        
            try
                ax.Title.Color = [0.10 0.12 0.16];
            catch
            end
            try
                ax.XLabel.Color = [0.10 0.12 0.16];
            catch
            end
            try
                ax.YLabel.Color = [0.10 0.12 0.16];
            catch
            end
            box(ax,'on');
            app.applyGridState(ax);
            ax.XMinorTick = 'on';
            ax.YMinorTick = 'on';
            ax.TickLength = [0.02 0.02];
            ax.FontSize = 28;
            ax.LineWidth = 3;
        
            app.applyAxisControls(ax);
            hold(ax,'off');
        end

        function label = makeLegendDataLabel(~, rawName)
            label = string(rawName);
            if strlength(label) == 0
                label = "Data";
            end
            label = erase(label, "Component: ");
            label = regexprep(label, '\s*\|.*$', '');
            label = strtrim(label);
        end

        function label = makeLegendFitLabel(app, result)
            if isfield(result,'IsCombined') && result.IsCombined
                baseName = "Combined";
            elseif isfield(result,'Sheet')
                baseName = app.makeLegendDataLabel(result.Sheet);
            else
                baseName = "Fit";
            end

            suffix = app.getDisplayedFitLegendSuffix(result);
            label = strtrim(baseName + " " + suffix);
            label = regexprep(label, '\s*\|.*$', '');
        end

        function key = makeLegendKey(~, label)
            key = lower(strtrim(string(label)));
            key = regexprep(key, '\s+', ' ');
        end

        function labelOut = makeUniqueLegendLabel(app, labelIn, result, usedLegendKeys)
            labelOut = string(labelIn);
            if ~any(usedLegendKeys == app.makeLegendKey(labelOut))
                return;
            end

            modelTag = "";
            runTag = "";
            try
                if isfield(result,'ModelType')
                    modelTag = string(result.ModelType);
                end
            catch
            end
            try
                if isfield(result,'RunNumber') && isfinite(double(result.RunNumber))
                    runTag = "Run " + string(result.RunNumber);
                end
            catch
            end

            candidates = strings(0,1);
            if strlength(modelTag) > 0
                candidates(end+1,1) = labelOut + " (" + modelTag + ")"; 
            end
            if strlength(runTag) > 0
                candidates(end+1,1) = labelOut + " (" + runTag + ")"; 
            end
            if strlength(modelTag) > 0 && strlength(runTag) > 0
                candidates(end+1,1) = labelOut + " (" + modelTag + ", " + runTag + ")"; 
            end

            for ii = 1:numel(candidates)
                if ~any(usedLegendKeys == app.makeLegendKey(candidates(ii)))
                    labelOut = candidates(ii);
                    return;
                end
            end

            n = 2;
            while any(usedLegendKeys == app.makeLegendKey(labelOut + " " + string(n)))
                n = n + 1;
            end
            labelOut = labelOut + " " + string(n);
        end

        function b = getDisplayedFitParameters(app, result)
            % For MCMC runs, the plotted curve can be either the MAP/best
            % sample or the posterior mean. NL runs always use
            % result.b_fit.
            b = result.b_fit;
            try
                if ~app.isMCMCResult(result)
                    return;
                end

                mode = app.getMCMCPlotMode();
                if strcmp(mode, "Mean")
                    if isfield(result,'b_mean') && ~isempty(result.b_mean)
                        b = result.b_mean;
                    elseif isfield(result,'MCMC') && isfield(result.MCMC,'b_mean')
                        b = result.MCMC.b_mean;
                    end
                else
                    if isfield(result,'b_map') && ~isempty(result.b_map)
                        b = result.b_map;
                    elseif isfield(result,'MCMC') && isfield(result.MCMC,'b_map')
                        b = result.MCMC.b_map;
                    end
                end
            catch
                b = result.b_fit;
            end
            b = double(b(:)).';
        end

        function yPred = getDisplayedFitCurve(app, result, xPlot, useFullMCMCChainForEnvelope)
            if nargin < 4
                useFullMCMCChainForEnvelope = false;
            end
            % Return the curve shown in the fit window/exported fit plots.
            % For MCMC mean mode, the embedded  view uses a thinned
            % posterior copy for speed; exported plots can use the full
            % post-burn-in chain.
            yPred = [];
            xPlot = xPlot(:);

            try
                if app.isMCMCResult(result) && strcmp(app.getMCMCPlotMode(), "Mean")
                    yMean = app.getPosteriorMeanModelCurve(result, xPlot, useFullMCMCChainForEnvelope);
                    if ~isempty(yMean) && numel(yMean) == numel(xPlot) && all(isfinite(yMean))
                        yPred = yMean(:);
                        return;
                    end
                end
            catch
            end

            bPlot = app.getDisplayedFitParameters(result);
            yPred = result.Model(bPlot, xPlot);
            yPred = yPred(:);
        end

        function suffix = getDisplayedFitLegendSuffix(app, result)
            if app.isMCMCResult(result)
                if strcmp(app.getMCMCPlotMode(), "Mean")
                    suffix = "mean fit";
                else
                    suffix = "MAP fit";
                end
            else
                suffix = "fit";
            end
        end

        function mode = getMCMCPlotMode(app)
            mode = "Best fit (MAP)";
            try
                mode = string(app.MCMCPlotModeDropDown.Value);
            catch
            end
            if strcmpi(mode, "Mean")
                mode = "Mean";
            else
                mode = "Best fit (MAP)";
            end
        end

        function tf = shouldPlotMCMCCredibleBand(app, result, useFullChain)
            if nargin < 3
                useFullChain = false;
            end
            tf = false;
            try
                if ~app.isMCMCResult(result)
                    return;
                end
                if ~strcmp(app.getMCMCPlotMode(), "Mean")
                    return;
                end
                if ~logical(app.MCMCShowCredibleBandCheck.Value)
                    return;
                end
                samplesForBand = app.getMCMCPosteriorSamplesForEnvelope(result, useFullChain);
                if ~isempty(samplesForBand)
                    tf = true;
                end
            catch
                tf = false;
            end
        end

        function plotMCMCCredibleBand(app, ax, result, xPlot, lineColor, useFullChain)
            if nargin < 6
                useFullChain = false;
            end
            try
                [~, yLow, yHigh] = app.computeMCMCModelEnvelope(result, xPlot, useFullChain);
                if isempty(yLow) || isempty(yHigh)
                    return;
                end

                good = isfinite(xPlot(:)) & isfinite(yLow(:)) & isfinite(yHigh(:));
                if nnz(good) < 3
                    return;
                end

                xg = xPlot(good);
                yl = yLow(good);
                yh = yHigh(good);
                rgb = app.plotColorToRGB(lineColor);
                hp = fill(ax, [xg(:); flipud(xg(:))], [yl(:); flipud(yh(:))], rgb, ...
                    'FaceAlpha',0.16, ...
                    'EdgeColor','none', ...
                    'HandleVisibility','off');
                try
                    uistack(hp,'bottom');
                catch
                end
            catch
             
            end
        end

        function [yMean, yLow, yHigh] = computeMCMCModelEnvelope(app, result, xPlot, useFullChain)
            if nargin < 4
                useFullChain = true;
            end
            yMean = [];
            yLow  = [];
            yHigh = [];

            try
                samplesPost = app.getMCMCPosteriorSamplesForEnvelope(result, useFullChain);
                if isempty(samplesPost)
                    return;
                end

                xPlot = xPlot(:);
                nDraw = size(samplesPost,1);
                yDraw = nan(numel(xPlot), nDraw);

                for jj = 1:nDraw
                    yj = result.Model(samplesPost(jj,:), xPlot);
                    if numel(yj) == numel(xPlot) && all(isfinite(yj))
                        yDraw(:,jj) = yj(:);
                    end
                end

                keep = all(isfinite(yDraw),1);
                yDraw = yDraw(:,keep);
                if size(yDraw,2) < 5
                    return;
                end

                yMean = mean(yDraw, 2, 'omitnan');
                yLow  = app.rowPercentile(yDraw, 2.5);
                yHigh = app.rowPercentile(yDraw, 97.5);
            catch
                yMean = [];
                yLow  = [];
                yHigh = [];
            end
        end

        function yMean = getPosteriorMeanModelCurve(app, result, xPlot, useFullChain)
            if nargin < 4
                useFullChain = true;
            end
            yMean = [];
            try
                [yMean, ~, ~] = app.computeMCMCModelEnvelope(result, xPlot, useFullChain);
            catch
                yMean = [];
            end
        end

        function samplesPost = getMCMCPosteriorSamplesForEnvelope(~, result, useFullChain)
            if nargin < 3
                useFullChain = false;
            end
            samplesPost = [];
            try
                if useFullChain
                    if isfield(result,'MCMC') && isfield(result.MCMC,'samplesPost') && ~isempty(result.MCMC.samplesPost)
                        samplesPost = result.MCMC.samplesPost;
                        return;
                    end
                else
                    if isfield(result,'MCMC') && isfield(result.MCMC,'samplesPostThin') && ~isempty(result.MCMC.samplesPostThin)
                        samplesPost = result.MCMC.samplesPostThin;
                        return;
                    end
                    % Fallback for short chains 
                    if isfield(result,'MCMC') && isfield(result.MCMC,'samplesPost') && ~isempty(result.MCMC.samplesPost)
                        samplesPost = result.MCMC.samplesPost;
                        return;
                    end
                end
            catch
                samplesPost = [];
            end
        end

        function q = rowPercentile(~, x, pct)
            if isempty(x)
                q = [];
                return;
            end
            x = sort(x, 2);
            n = size(x,2);
            p = max(0, min(100, pct)) ./ 100;
            pos = 1 + (n - 1) .* p;
            lo = floor(pos);
            hi = ceil(pos);
            w = pos - lo;
            lo = max(1, min(n, lo));
            hi = max(1, min(n, hi));
            q = (1 - w) .* x(:,lo) + w .* x(:,hi);
        end

        function rgb = plotColorToRGB(~, c)
            if isnumeric(c) && numel(c) == 3
                rgb = double(c(:)).';
                rgb = max(0, min(1, rgb));
                return;
            end
            s = lower(strtrim(string(c)));
            switch s
                case {"y","yellow"}
                    rgb = [1 1 0];
                case {"m","magenta"}
                    rgb = [1 0 1];
                case {"b","blue"}
                    rgb = [0 0 1];
                case {"k","black"}
                    rgb = [0 0 0];
                case {"r","red"}
                    rgb = [1 0 0];
                case {"g","green"}
                    rgb = [0 0.5 0];
                case {"c","cyan"}
                    rgb = [0 1 1];
                case {"w","white"}
                    rgb = [1 1 1];
                otherwise
                    nums = str2num(char(s)); 
                    if isnumeric(nums) && numel(nums) == 3 && all(nums >= 0) && all(nums <= 1)
                        rgb = nums(:).';
                    else
                        rgb = [0 0 0];
                    end
            end
        end

        function sty = getResultPlotStyle(app, result, idx)
            if nargin < 3 || isempty(idx)
                idx = NaN;
            end
            key = app.getResultDisplayLabel(result, idx);
            sty = app.getSamplePlotStyle(key);
            if ~isfield(sty,'DisplayName') || strlength(string(sty.DisplayName)) == 0
                sty.DisplayName = key;
            end
            app.SampleStyleMap(char(key)) = sty;
        end

        function sty = getSamplePlotStyle(app, sheet)
            key = char(sheet);

            if isKey(app.SampleStyleMap, key)
                sty = app.SampleStyleMap(key);
                if ~isfield(sty,'LineStyle')
                    sty.LineStyle = '-';
                    app.SampleStyleMap(key) = sty;
                end
                return;
            end

            defaults = {
                struct('DisplayName',string(sheet),'MarkerFaceColor',"y",'MarkerEdgeColor',"b",'MarkerSize',200,'MarkerShape','o','LineColor',"k",'LineWidth',3,'LineStyle','-','ShowFitLine',true), ...
                struct('DisplayName',string(sheet),'MarkerFaceColor',"m",'MarkerEdgeColor',"k",'MarkerSize',200,'MarkerShape','s','LineColor',"k",'LineWidth',3,'LineStyle','-','ShowFitLine',true), ...
                struct('DisplayName',string(sheet),'MarkerFaceColor',"[0.301 0.745 0.933]",'MarkerEdgeColor',"k",'MarkerSize',200,'MarkerShape','d','LineColor',"k",'LineWidth',3,'LineStyle','-','ShowFitLine',true), ...
                struct('DisplayName',string(sheet),'MarkerFaceColor',"[0.466 0.674 0.188]",'MarkerEdgeColor',"k",'MarkerSize',200,'MarkerShape','^','LineColor',"k",'LineWidth',3,'LineStyle','-','ShowFitLine',true), ...
                struct('DisplayName',string(sheet),'MarkerFaceColor',"[0.850 0.325 0.098]",'MarkerEdgeColor',"k",'MarkerSize',200,'MarkerShape','v','LineColor',"k",'LineWidth',3,'LineStyle','-','ShowFitLine',true) ...
                
            };

            idx = mod(app.SampleStyleMap.Count, numel(defaults)) + 1;
            sty = defaults{idx};
            sty.DisplayName = string(sheet);
            app.SampleStyleMap(key) = sty;
        end

        function onStyleSampleChanged(app)
            if isempty(app.RunResults) || strcmp(app.StyleSampleDropDown.Value,'(no results yet)')
                return;
            end

            sheet = string(app.StyleSampleDropDown.Value);
            sty = app.getSamplePlotStyle(sheet);

            app.StyleDisplayNameEdit.Value       = char(sty.DisplayName);
            app.StyleMarkerFaceColorEdit.Value   = char(string(sty.MarkerFaceColor));
            app.StyleMarkerEdgeColorEdit.Value   = char(string(sty.MarkerEdgeColor));
            app.StyleMarkerSizeEdit.Value        = sty.MarkerSize;
            app.StyleMarkerShapeDropDown.Value   = char(string(sty.MarkerShape));
            app.StyleLineColorEdit.Value         = char(string(sty.LineColor));
            app.StyleLineWidthEdit.Value         = sty.LineWidth;
            if isfield(sty,'LineStyle')
                app.StyleLineStyleDropDown.Value = char(string(sty.LineStyle));
            else
                app.StyleLineStyleDropDown.Value = '-';
            end
            if isfield(sty,'ShowFitLine')
                app.StyleShowFitLineCheck.Value = logical(sty.ShowFitLine);
            else
                app.StyleShowFitLineCheck.Value = true;
            end
        end

        function onStyleControlChanged(app)
            if isempty(app.RunResults) || strcmp(app.StyleSampleDropDown.Value,'(no results yet)')
                return;
            end

            sheet = string(app.StyleSampleDropDown.Value);
            sty = app.getSamplePlotStyle(sheet);

            sty.DisplayName      = string(app.StyleDisplayNameEdit.Value);
            sty.MarkerFaceColor  = string(app.StyleMarkerFaceColorEdit.Value);
            sty.MarkerEdgeColor  = string(app.StyleMarkerEdgeColorEdit.Value);
            sty.MarkerSize       = app.StyleMarkerSizeEdit.Value;
            sty.MarkerShape      = string(app.StyleMarkerShapeDropDown.Value);
            sty.LineColor        = string(app.StyleLineColorEdit.Value);
            sty.LineWidth        = app.StyleLineWidthEdit.Value;
            sty.LineStyle        = string(app.StyleLineStyleDropDown.Value);
            sty.ShowFitLine = logical(app.StyleShowFitLineCheck.Value);

            app.SampleStyleMap(char(sheet)) = sty;
            app.updateCurrentFitView();
        end

        function c = parsePlotColor(~, raw, fallback)
            if isnumeric(raw) && numel(raw)==3
                c = raw;
                return;
            end

            s = strtrim(string(raw));
            if strlength(s) == 0
                c = fallback;
                return;
            end

            named = ["y","m","b","k","r","g","c","w", ...
                     "yellow","magenta","blue","black","red","green","cyan","white"];

            if any(strcmpi(s, named))
                c = char(s);
                return;
            end

            nums = str2num(char(s)); 
            if isnumeric(nums) && numel(nums)==3 && all(nums>=0) && all(nums<=1)
                c = nums;
            else
                c = fallback;
            end
        end
    end

    %% ====================== Run / Stop ======================
    methods (Access = private)
        % Main run. This handles mode selection, progress dialogs, result
        % storage, and view refresh; the actual fitting is delegated to runOne/runCombined.
        function runPressed(app)
            dlg = [];
            try
                app.CancelRequested = false;
                app.RunButton.Enable = "off";
                app.StopButton.Enable = "on";

                cfg = app.getConfig();
                app.validateConfig(cfg);
                app.log("Output folder: " + cfg.OutputDir);

                if cfg.Mode == "Combine sheets"
                    sheets = string(cfg.CombinedSheets);
                    app.log("Selected combined sheets: " + strjoin(cellstr(sheets), ", "));
                    if isempty(sheets)
                        error("Select at least two sheets in 'Combine sheets'.");
                    end
                    if numel(sheets) < 2
                        error("Combined fit requires at least two sheets.");
                    end

                    dlg = uiprogressdlg(app.UIFigure, ...
                        "Title","Running combined CSD solver", ...
                        "Message","Initializing combined fit...", ...
                        "Cancelable","on", ...
                        "Indeterminate","off", ...
                        "Value",0);

                    result = app.runCombinedFit(cfg, sheets, dlg);

                    if isempty(result)
                        app.log("Combined run canceled.");
                    else
                        result = app.assignResultIdentity(result);
                        app.RunResults{end+1} = result; 
                        app.getResultPlotStyle(result, numel(app.RunResults));

                        latestLabel = char(app.getResultDisplayLabel(result, numel(app.RunResults)));
                        app.refreshViewSampleList();
                        app.ViewSampleDropDown.Value = latestLabel;
                        app.FitOverlayCheck.Value = false;
                        app.OverlaySelection = string(latestLabel);
                        app.refreshStyleSampleList();
                        app.updateCurrentFitView();
                        app.TabGroup.SelectedTab = app.TabFit;
                        drawnow;

                        app.log("Combined fit complete: " + result.Sheet);
                    end
                else
                    sheetsToRun = app.getSheetsToRun(cfg);
                    if isempty(sheetsToRun)
                        error("No sheets selected.");
                    end

                    dlg = uiprogressdlg(app.UIFigure, ...
                        "Title","Running CSD solver", ...
                        "Message","Initializing...", ...
                        "Cancelable","on", ...
                        "Indeterminate","off", ...
                        "Value",0);

                    for k = 1:numel(sheetsToRun)
                        if (isvalid(dlg) && dlg.CancelRequested) || app.CancelRequested
                            app.log("Run canceled by user.");
                            break;
                        end

                        sheet = sheetsToRun(k);
                        dlg.Value = (k-1)/max(1,numel(sheetsToRun));
                        dlg.Message = sprintf("Running %s (%d/%d)", sheet, k, numel(sheetsToRun));
                        app.log("Running sheet: " + sheet);

                        try
                            result = app.runOneSampleFit(cfg, sheet, k, dlg);
                        catch ME_sheet
                            app.log("ERROR in sheet " + sheet + ": " + ME_sheet.message);
                            app.log(getReport(ME_sheet,'basic','hyperlinks','off'));
                            continue;
                        end

                        if ~isempty(result)
                            result = app.assignResultIdentity(result);
                            app.RunResults{end+1} = result; 
                            app.getResultPlotStyle(result, numel(app.RunResults));
                        end
                    end

                    if ~isempty(app.RunResults)
                        latestLabel = char(app.getResultDisplayLabel(app.RunResults{end}, numel(app.RunResults)));
                        app.refreshViewSampleList();
                        app.ViewSampleDropDown.Value = latestLabel;
                        app.FitOverlayCheck.Value = false;
                        app.OverlaySelection = string(latestLabel);
                        app.refreshStyleSampleList();
                        app.updateCurrentFitView();
                        app.TabGroup.SelectedTab = app.TabFit;
                        drawnow;
                    end

                    app.log("Run complete.");
                end
            catch ME
                app.log("Run failed: " + ME.message);
                app.log(getReport(ME,'basic','hyperlinks','off'));
            end

            try
                if ~isempty(dlg) && isvalid(dlg)
                    close(dlg);
                end
            catch
            end

            app.RunButton.Enable = "on";
            app.StopButton.Enable = "off";
        end

        function stopPressed(app)
            app.CancelRequested = true;
            app.log("Stop requested.");
        end

        function randomizeMCMCSeed(app)
            app.MCMCSeedEdit.Value = randi([0 2^31-1]);
            app.log("MCMC seed randomized to " + string(app.MCMCSeedEdit.Value));
        end

        function outDir = getOutputDir(~, cfg)
            resultsDir = string(cfg.ResultsDir);
            outputFolder = string(cfg.OutputFolder);
            if strlength(outputFolder) == 0
                outputFolder = "CSDStudio_Output";
            end
            if startsWith(outputFolder, filesep) || ~isempty(regexp(outputFolder, '^[A-Za-z]:[\\/]', 'once'))
                outDir = outputFolder;
            else
                outDir = fullfile(resultsDir, outputFolder);
            end
        end

        function outDir = ensureOutputDir(app, cfg)
            outDir = app.getOutputDir(cfg);
            if ~exist(outDir, "dir")
                mkdir(outDir);
            end
        end

        % Snapshot all current UI settings 
        function cfg = getConfig(app)
            cfg.DataFile      = string(app.DataFileEdit.Value);
            cfg.ResultsDir    = string(app.ResultsDirEdit.Value);
            cfg.OutputFolder  = string(app.OutputFolderEdit.Value);
            if strlength(cfg.OutputFolder) == 0
                cfg.OutputFolder = "CSDStudio_Output";
            end
            cfg.OutputDir     = app.getOutputDir(cfg);
            cfg.ResultsName   = "CSDStudio_Results";
            cfg.ResultsSheet  = "Summary";
            cfg.ResultsFile   = fullfile(cfg.OutputDir, cfg.ResultsName + ".xlsx");
            cfg.SavePlots     = false;

            cfg.Mode          = string(app.SampleModeDropDown.Value);
            cfg.SingleSheet   = string(app.SheetDropDown.Value);
            cfg.SelectedSheets = app.RunSheetSelection;
            cfg.CombinedSheets = app.CombinedSheetSelection;

            cfg.SolverType    = app.normalizeSolverType(string(app.SolverDropDown.Value));
            if strcmp(cfg.SolverType, "MCMC")
                cfg.solver    = "MCMC";
            else
                cfg.solver    = "fitnlm";
            end
            cfg.nStarts       = app.NStartsEdit.Value;
            cfg.maxIter       = app.MaxIterEdit.Value;
            cfg.funcTol       = app.FuncTolEdit.Value;
            cfg.stepTol       = app.StepTolEdit.Value;

            cfg.mcmcIter      = round(app.MCMCIterEdit.Value);
            cfg.mcmcBurnIn    = round(app.MCMCBurnInEdit.Value);
            cfg.mcmcStepFrac  = app.MCMCStepFracEdit.Value;
            cfg.mcmcNoiseSigma = app.MCMCNoiseSigmaEdit.Value;
            cfg.mcmcSeed      = round(app.MCMCSeedEdit.Value);
            cfg.mcmcUIStride  = round(app.MCMCUIUpdateStrideEdit.Value);
            cfg.mcmcPerSheetSeedOffset = logical(app.MCMCPerSheetSeedOffsetCheck.Value);
            cfg.mcmcPlotMode = string(app.MCMCPlotModeDropDown.Value);
            cfg.mcmcShowCredibleBand = logical(app.MCMCShowCredibleBandCheck.Value);

            cfg.ModelType     = app.normalizeModelType(string(app.ModelTypeDropDown.Value));
            if strcmp(cfg.ModelType, "Linear")
                cfg.SolverType = "NL Inversion";
                cfg.solver = "fitnlm";
            end
            cfg.alpha1        = app.Alpha1Edit.Value;
            cfg.alpha2        = 1 - cfg.alpha1;
            cfg.growthFixN0 = false;
            cfg.growthFixedLnN0 = NaN;
            cfg.growthFixedN0 = NaN;
            if strcmp(cfg.ModelType, "Growth-Law")
                cfg.growthFixN0 = logical(app.GrowthLawFixN0Check.Value);
                cfg.growthFixedLnN0 = app.GrowthLawLnN0Edit.Value;
                if cfg.growthFixN0 && isfinite(cfg.growthFixedLnN0)
                    cfg.growthFixedN0 = exp(cfg.growthFixedLnN0);
                end
            end

            cfg.manualPiecewise = logical(app.ManualPiecewiseCheck.Value);
            cfg.useExclusions   = logical(app.ExcludePointsCheck.Value);


            cfg.clipX         = logical(app.ClipXCheck.Value);
            cfg.xMin          = app.XMinEdit.Value;
            cfg.xMax          = app.XMaxEdit.Value;
            cfg.clipY         = logical(app.ClipYCheck.Value);
            cfg.yMin          = app.YMinEdit.Value;
            cfg.yMax          = app.YMaxEdit.Value;
            cfg.extendFit   = logical(app.ExtendFitCheck.Value);
            cfg.fitXMax     = app.FitXMaxEdit.Value;
            cfg.showFitLine = logical(app.ShowFitLineCheck.Value);

            cfg.ParamNames    = app.getParamNames(cfg.ModelType);
        end

        % Catch invalid settings before a run starts. 
        function validateConfig(app, cfg)
            if strlength(cfg.DataFile) == 0 || ~isfile(cfg.DataFile)
                error("Choose a valid Excel data file.");
            end
            if strlength(cfg.ResultsDir) == 0 || ~isfolder(cfg.ResultsDir)
                error("Choose a valid results directory.");
            end
            if cfg.Mode == "Selected sheets" && isempty(cfg.SelectedSheets)
                error("Choose at least one sheet in 'Choose run sheets'.");
            end
            
            if cfg.Mode == "Combine sheets" && numel(cfg.CombinedSheets) < 2
                error("Choose at least two sheets in 'Choose combined sheets'.");
            end
            if cfg.nStarts < 1
                error("Number of normal starts must be >= 1.");
            end
            if cfg.maxIter < 1
                error("Max iterations must be >= 1.");
            end
            if cfg.funcTol < 0 || cfg.stepTol < 0
                error("Tolerance values must be >= 0.");
            end
            if strcmp(app.normalizeModelType(string(cfg.ModelType)), "Linear") && strcmp(cfg.SolverType, "MCMC")
                error("The Linear model is NL-only. Select NL Inversion.");
            end
            if strcmp(cfg.SolverType, "MCMC")
                if cfg.mcmcIter < 100
                    error("MCMC iterations must be >= 100.");
                end
                if cfg.mcmcBurnIn < 0 || cfg.mcmcBurnIn >= cfg.mcmcIter
                    error("MCMC burn-in must satisfy 0 <= burn-in < iterations.");
                end
                if cfg.mcmcStepFrac <= 0 || ~isfinite(cfg.mcmcStepFrac)
                    error("MCMC step fraction must be finite and > 0.");
                end
                if cfg.mcmcNoiseSigma <= 0 || ~isfinite(cfg.mcmcNoiseSigma)
                    error("MCMC noise sigma must be finite and > 0.");
                end
                if cfg.mcmcUIStride < 10
                    error("MCMC UI stride must be >= 10.");
                end
            end
            if strcmp(app.normalizeModelType(string(cfg.ModelType)), "3-Chamber")
                if ~isfinite(cfg.alpha1) || cfg.alpha1 <= 0 || cfg.alpha1 >= 1
                    error("alpha1 must be between 0 and 1 for the 3-Chamber model.");
                end
            end
            if strcmp(app.normalizeModelType(string(cfg.ModelType)), "Growth-Law") && isfield(cfg,'growthFixN0') && cfg.growthFixN0
                if ~isfinite(cfg.growthFixedLnN0)
                    error("Fixed ln(n0) must be finite for Growth-Law when fixed n0 is enabled.");
                end
                if ~isfinite(cfg.growthFixedN0) || cfg.growthFixedN0 <= 0
                    error("Fixed Growth-Law n0 must be positive. Check the fixed ln(n0) value.");
                end
            end
            if cfg.clipX
                if ~isfinite(cfg.xMin) || ~isfinite(cfg.xMax) || cfg.xMin >= cfg.xMax
                    error("X-axis limits must satisfy xMin < xMax.");
                end
            end
            if cfg.clipY
                if ~isfinite(cfg.yMin) || ~isfinite(cfg.yMax) || cfg.yMin >= cfg.yMax
                    error("Y-axis limits must satisfy yMin < yMax.");
                end
            end
            if cfg.extendFit
                if ~isfinite(cfg.fitXMax) || cfg.fitXMax <= 0
                    error("Fit X max must be a finite value > 0.");
                end
            end

            if strlength(cfg.OutputFolder) == 0
                error("Output folder cannot be blank.");
            end
            if ~exist(cfg.OutputDir,"dir")
                mkdir(cfg.OutputDir);
            end
        end

        function sheets = getSheetsToRun(~, cfg)
            allSheets = string(sheetnames(cfg.DataFile));
        
            switch cfg.Mode
                case "All sheets"
                    sheets = allSheets;
        
                case "Single sheet"
                    sheets = cfg.SingleSheet;
        
                case "Selected sheets"
                    sheets = cfg.SelectedSheets;
        
                case "Combine sheets"
                    sheets = cfg.CombinedSheets;
        
                otherwise
                    error("Unknown run mode: %s", cfg.Mode);
            end
        end
    end

    %% ====================== Compute ======================
    methods (Access = private)
        % Read one worksheet using the expected CSD format: L in column A and ln(n) in column B.
        % Extra columns are ignored here but can remain in the workbook.
        function [x_raw, y_raw] = readSheetXYRaw(~, dataFile, sheet)
            data = readmatrix(dataFile, "Sheet", sheet, "Range", "A2:D200");
            x_raw = rmmissing(data(:,1));
            y_raw = rmmissing(data(:,2));

            n = min(numel(x_raw), numel(y_raw));
            x_raw = x_raw(1:n);
            y_raw = y_raw(1:n);

            if isempty(x_raw) || isempty(y_raw)
                error("Data in sheet %s appears empty.", sheet);
            end
        end

        % Apply stored point exclusions to a raw worksheet. The raw count is retained
        % so the preview and export can report how many points were removed.
        function [x, y_obs, idxExcl, rawN] = readSheetXY(app, dataFile, sheet, useExclusions)
            [x_raw, y_raw] = app.readSheetXYRaw(dataFile, sheet);
            rawN = numel(x_raw);

            idxExcl = [];
            x = x_raw;
            y_obs = y_raw;

            if useExclusions
                key = char(string(sheet));
                if isKey(app.ExcludeMap, key)
                    idxExcl = unique(app.ExcludeMap(key));
                    idxExcl = idxExcl(isfinite(idxExcl) & idxExcl >= 1 & idxExcl <= rawN);
                    mask = true(rawN,1);
                    mask(idxExcl) = false;
                    x = x_raw(mask);
                    y_obs = y_raw(mask);
                end
            end

            if isempty(x) || isempty(y_obs)
                error("After exclusions, no data remain in sheet %s.", sheet);
            end
        end

        % NL fit for one worksheet. 
        function result = runOneSampleNLFit(app, cfg, sheet, sheetIndex, dlg)
            [x, y_obs, idxExcl, rawN] = app.readSheetXY(cfg.DataFile, sheet, cfg.useExclusions);
            [x_raw, y_raw] = app.readSheetXYRaw(cfg.DataFile, sheet);
        
            % force column vectors
            x     = x(:);
            y_obs = y_obs(:);
            x_raw = x_raw(:);
            y_raw = y_raw(:);
        
            x_excl = [];
            y_excl = [];
            if ~isempty(idxExcl)
                idxExcl = idxExcl(:);
                idxExcl = idxExcl(idxExcl >= 1 & idxExcl <= numel(x_raw));
                x_excl = x_raw(idxExcl);
                y_excl = y_raw(idxExcl);
            end
        
            % build plottinggrid for model curve
            xRight = app.getFitCurveXRight(x, cfg);
            xx = linspace(0, xRight, 200).';
        
            [b_init, piece] = app.getInitialGuess(cfg, sheet, x, y_obs, xx);
        
            if app.CancelRequested || (isvalid(dlg) && dlg.CancelRequested)
                result = [];
                return;
            end
        
            dlg.Message = sprintf("Solving %s (sheet %d)", sheet, sheetIndex);
        
            fit = app.solveNonlinearFit(x, y_obs, b_init, cfg);
            app.assertParameterCountMatchesModel(fit.b_fit, cfg.ModelType, sheet);
        
            y_fit_obs = app.evalModel(fit.b_fit, x, cfg);
            [fit_rmse, fit_r2] = app.computeRmseR2(y_obs, y_fit_obs);
        
            y_pw_obs = app.predictPiecewiseAtX(piece, x);
            pw_rmse = sqrt(mean((y_obs - y_pw_obs).^2));
            piece.rmse = pw_rmse;
        
            result = struct();
            result.Sheet = string(sheet);
            result.SeedUsed = NaN;
        
            % store all plotting vectors as columns
            result.x = x;
            result.y_obs = y_obs;
            result.xx = xx;
        
            result.b_init = b_init;
            result.b_fit = fit.b_fit;
            result.Piecewise = piece;
            result.ModelType = cfg.ModelType;
            result.SolverType = cfg.SolverType;
            result.alpha1 = cfg.alpha1;
            result.alpha2 = cfg.alpha2;
            result.Model = @(b,xx_) app.evalModel(b, xx_, cfg);
        
            result.Fit = struct( ...
                'rmse', fit_rmse, ...
                'r2', fit_r2, ...
                'resnorm', fit.resnorm, ...
                'residual', fit.residual, ...
                'exitflag', fit.exitflag, ...
                'output', fit.output, ...
                'solver', fit.solver, ...
                'paramStats', fit.paramStats, ...
                'fitnlmModel', fit.fitnlmModel, ...
                'fitnlmCoefficients', fit.fitnlmCoefficients);
        
            result.Exclusions = struct( ...
                'enabled', cfg.useExclusions, ...
                'rawN', rawN, ...
                'excludedIdx', idxExcl(:).', ...
                'usedN', numel(x), ...
                'x_excl', x_excl(:), ...
                'y_excl', y_excl(:));
        
            app.log(sprintf("%s: solver=%s | exitflag=%d | RMSE=%.4g", ...
                sheet, fit.solver, fit.exitflag, fit_rmse));
        end

        % NL fit for a combined dataset. 
        function result = runCombinedNLFit(app, cfg, sheets, dlg)
            xAll = [];
            yAll = [];
            parts = struct('Sheet',{},'x',{},'y_obs',{},'excludedIdx',{}, ...
                           'rawN',{},'x_excl',{},'y_excl',{});
        
            nSheets = numel(sheets);
        
            for i = 1:nSheets
                if (isvalid(dlg) && dlg.CancelRequested) || app.CancelRequested
                    result = [];
                    return;
                end
        
                sh = string(sheets(i));
                dlg.Value = 0.10 * (i-1)/max(1,nSheets);
                dlg.Message = sprintf("Loading %s (%d/%d)", sh, i, nSheets);
        
                [x_i, y_i, idxExcl_i, rawN_i] = app.readSheetXY(cfg.DataFile, sh, cfg.useExclusions);
                [x_raw_i, y_raw_i] = app.readSheetXYRaw(cfg.DataFile, sh);
        
                % force column vectors
                x_i     = x_i(:);
                y_i     = y_i(:);
                x_raw_i = x_raw_i(:);
                y_raw_i = y_raw_i(:);
        
                x_excl_i = [];
                y_excl_i = [];
                if ~isempty(idxExcl_i)
                    idxExcl_i = idxExcl_i(:);
                    idxExcl_i = idxExcl_i(idxExcl_i >= 1 & idxExcl_i <= numel(x_raw_i));
                    x_excl_i = x_raw_i(idxExcl_i);
                    y_excl_i = y_raw_i(idxExcl_i);
                end
        
                parts(i).Sheet = sh;
                parts(i).x = x_i;
                parts(i).y_obs = y_i;
                parts(i).excludedIdx = idxExcl_i(:).';
                parts(i).rawN = rawN_i;
                parts(i).x_excl = x_excl_i(:);
                parts(i).y_excl = y_excl_i(:);
        
                xAll = [xAll; x_i]; 
                yAll = [yAll; y_i]; 
                drawnow limitrate;
            end
        
            [xAll, order] = sort(xAll(:));
            yAll = yAll(:);
            yAll = yAll(order);
        
            if numel(xAll) < 6
                error("Too few combined points after exclusions. Need >= 6.");
            end
        
            xRight = app.getFitCurveXRight(xAll, cfg);
            xx = linspace(0, xRight, 200).';
        
            comboName = "Combined: " + strjoin(cellstr(sheets), " + ");
        
            [b_init, piece] = app.getInitialGuess(cfg, comboName, xAll, yAll, xx);
        
            if (isvalid(dlg) && dlg.CancelRequested) || app.CancelRequested
                result = [];
                return;
            end
        
            dlg.Value = 0.15;
            dlg.Message = "Optimizing combined fit...";
        
            fit = app.solveNonlinearFit(xAll, yAll, b_init, cfg);
            app.assertParameterCountMatchesModel(fit.b_fit, cfg.ModelType, comboName);
        
            y_fit_obs = app.evalModel(fit.b_fit, xAll, cfg);
            [fit_rmse, fit_r2] = app.computeRmseR2(yAll, y_fit_obs);
        
            y_pw_obs = app.predictPiecewiseAtX(piece, xAll);
            pw_rmse = sqrt(mean((yAll - y_pw_obs).^2));
            piece.rmse = pw_rmse;
        
            result = struct();
            result.Sheet = comboName;
            result.SourceSheets = sheets;
            result.IsCombined = true;
            result.Components = parts;
        
            result.SeedUsed = NaN;
            result.x = xAll;
            result.y_obs = yAll;
            result.xx = xx;
        
            result.b_init = b_init;
            result.b_fit = fit.b_fit;
            result.Piecewise = piece;
            result.ModelType = cfg.ModelType;
            result.SolverType = cfg.SolverType;
            result.alpha1 = cfg.alpha1;
            result.alpha2 = cfg.alpha2;
            result.Model = @(b,xx_) app.evalModel(b, xx_, cfg);
        
            result.Fit = struct( ...
                'rmse', fit_rmse, ...
                'r2', fit_r2, ...
                'resnorm', fit.resnorm, ...
                'residual', fit.residual, ...
                'exitflag', fit.exitflag, ...
                'output', fit.output, ...
                'solver', fit.solver, ...
                'paramStats', fit.paramStats, ...
                'fitnlmModel', fit.fitnlmModel, ...
                'fitnlmCoefficients', fit.fitnlmCoefficients);
        
            app.log(sprintf("%s: solver=%s | exitflag=%d | RMSE=%.4g", ...
                comboName, fit.solver, fit.exitflag, fit_rmse));
        end

        % Route a single-sheet run to the selected solver. 
        function result = runOneSampleFit(app, cfg, sheet, sheetIndex, dlg)
            if strcmp(app.normalizeModelType(string(cfg.ModelType)), "Linear") && strcmp(app.normalizeSolverType(cfg.SolverType), "MCMC")
                error("The Linear model is NL-only. Select NL Inversion.");
            end
            if strcmp(app.normalizeSolverType(cfg.SolverType), "MCMC")
                result = app.runOneSampleMCMCFit(cfg, sheet, sheetIndex, dlg);
            else
                result = app.runOneSampleNLFit(cfg, sheet, sheetIndex, dlg);
            end
        end

        % Route a combined run to the selected solver
        function result = runCombinedFit(app, cfg, sheets, dlg)
            if strcmp(app.normalizeModelType(string(cfg.ModelType)), "Linear") && strcmp(app.normalizeSolverType(cfg.SolverType), "MCMC")
                error("The Linear model is NL-only. Select NL Inversion.");
            end
            if strcmp(app.normalizeSolverType(cfg.SolverType), "MCMC")
                result = app.runCombinedMCMCFit(cfg, sheets, dlg);
            else
                result = app.runCombinedNLFit(cfg, sheets, dlg);
            end
        end

        % MCMC fit for one worksheet. 
        function result = runOneSampleMCMCFit(app, cfg, sheet, sheetIndex, dlg)
            [x, y_obs, idxExcl, rawN] = app.readSheetXY(cfg.DataFile, sheet, cfg.useExclusions);
            [x_raw, y_raw] = app.readSheetXYRaw(cfg.DataFile, sheet);

            x     = x(:);
            y_obs = y_obs(:);
            x_raw = x_raw(:);
            y_raw = y_raw(:);

            if numel(x) < numel(app.getParamNames(cfg.ModelType)) + 2
                error("Too few points in %s after exclusions for MCMC. Used=%d.", string(sheet), numel(x));
            end

            x_excl = [];
            y_excl = [];
            if ~isempty(idxExcl)
                idxExcl = idxExcl(:);
                idxExcl = idxExcl(idxExcl >= 1 & idxExcl <= numel(x_raw));
                x_excl = x_raw(idxExcl);
                y_excl = y_raw(idxExcl);
            end

            xRight = app.getFitCurveXRight(x, cfg);
            xx = linspace(0, xRight, 200).';

            [b_init, piece] = app.getInitialGuess(cfg, sheet, x, y_obs, xx);

            if app.CancelRequested || (isvalid(dlg) && dlg.CancelRequested)
                result = [];
                return;
            end

            dlg.Message = sprintf("Running MCMC for %s (sheet %d)", sheet, sheetIndex);

            seedUsed = cfg.mcmcSeed;
            if cfg.mcmcPerSheetSeedOffset
                seedUsed = seedUsed + (sheetIndex - 1);
            end

            fit = app.solveMCMCFit(x, y_obs, b_init, cfg, dlg, string(sheet), seedUsed);
            if isempty(fit)
                result = [];
                return;
            end
            app.assertParameterCountMatchesModel(fit.b_fit, cfg.ModelType, sheet);

            y_fit_obs = app.evalModel(fit.b_fit, x, cfg);
            [fit_rmse, fit_r2] = app.computeRmseR2(y_obs, y_fit_obs);

            y_pw_obs = app.predictPiecewiseAtX(piece, x);
            pw_rmse = sqrt(mean((y_obs - y_pw_obs).^2,'omitnan'));
            piece.rmse = pw_rmse;

            result = struct();
            result.Sheet = string(sheet);
            result.SeedUsed = seedUsed;
            result.x = x;
            result.y_obs = y_obs;
            result.xx = xx;

            result.b_init = b_init;
            result.b_fit = fit.b_fit;
            result.b_mean = fit.b_mean;
            result.b_std = fit.b_std;
            result.b_map = fit.b_map;
            result.Piecewise = piece;
            result.ModelType = cfg.ModelType;
            result.SolverType = cfg.SolverType;
            result.alpha1 = cfg.alpha1;
            result.alpha2 = cfg.alpha2;
            result.Model = @(b,xx_) app.evalModel(b, xx_, cfg);

            result.Fit = struct( ...
                'rmse', fit_rmse, ...
                'r2', fit_r2, ...
                'resnorm', fit.resnorm, ...
                'residual', fit.residual, ...
                'exitflag', fit.exitflag, ...
                'output', fit.output, ...
                'solver', fit.solver, ...
                'paramStats', fit.paramStats, ...
                'fitnlmModel', [], ...
                'fitnlmCoefficients', table());

            result.MCMC = fit.mcmcSummary;
            result.MCMCDisplay = struct( ...
                'plotMode', cfg.mcmcPlotMode, ...
                'showCredibleBand', cfg.mcmcShowCredibleBand);

            result.Exclusions = struct( ...
                'enabled', cfg.useExclusions, ...
                'rawN', rawN, ...
                'excludedIdx', idxExcl(:).', ...
                'usedN', numel(x), ...
                'x_excl', x_excl(:), ...
                'y_excl', y_excl(:));

            app.log(sprintf("%s: solver=%s | accept=%.2f%% | RMSE=%.4g", ...
                sheet, fit.solver, result.MCMC.acceptRate, fit_rmse));
        end

        % MCMC fit for a combined dataset. 
        function result = runCombinedMCMCFit(app, cfg, sheets, dlg)
            xAll = [];
            yAll = [];
            parts = struct('Sheet',{},'x',{},'y_obs',{},'excludedIdx',{}, ...
                           'rawN',{},'x_excl',{},'y_excl',{});

            nSheets = numel(sheets);

            for i = 1:nSheets
                if (isvalid(dlg) && dlg.CancelRequested) || app.CancelRequested
                    result = [];
                    return;
                end

                sh = string(sheets(i));
                dlg.Value = 0.10 * (i-1)/max(1,nSheets);
                dlg.Message = sprintf("Loading %s (%d/%d)", sh, i, nSheets);

                [x_i, y_i, idxExcl_i, rawN_i] = app.readSheetXY(cfg.DataFile, sh, cfg.useExclusions);
                [x_raw_i, y_raw_i] = app.readSheetXYRaw(cfg.DataFile, sh);

                x_i     = x_i(:);
                y_i     = y_i(:);
                x_raw_i = x_raw_i(:);
                y_raw_i = y_raw_i(:);

                x_excl_i = [];
                y_excl_i = [];
                if ~isempty(idxExcl_i)
                    idxExcl_i = idxExcl_i(:);
                    idxExcl_i = idxExcl_i(idxExcl_i >= 1 & idxExcl_i <= numel(x_raw_i));
                    x_excl_i = x_raw_i(idxExcl_i);
                    y_excl_i = y_raw_i(idxExcl_i);
                end

                parts(i).Sheet = sh;
                parts(i).x = x_i;
                parts(i).y_obs = y_i;
                parts(i).excludedIdx = idxExcl_i(:).';
                parts(i).rawN = rawN_i;
                parts(i).x_excl = x_excl_i(:);
                parts(i).y_excl = y_excl_i(:);

                xAll = [xAll; x_i]; 
                yAll = [yAll; y_i]; 
                drawnow limitrate;
            end

            [xAll, order] = sort(xAll(:));
            yAll = yAll(:);
            yAll = yAll(order);

            if numel(xAll) < numel(app.getParamNames(cfg.ModelType)) + 2
                error("Too few combined points after exclusions for MCMC. Need more observations than parameters.");
            end

            xRight = app.getFitCurveXRight(xAll, cfg);
            xx = linspace(0, xRight, 200).';

            comboName = "Combined: " + strjoin(cellstr(sheets), " + ");

            [b_init, piece] = app.getInitialGuess(cfg, comboName, xAll, yAll, xx);

            if (isvalid(dlg) && dlg.CancelRequested) || app.CancelRequested
                result = [];
                return;
            end

            dlg.Value = 0.15;
            dlg.Message = "Running combined MCMC...";

            seedUsed = cfg.mcmcSeed;
            fit = app.solveMCMCFit(xAll, yAll, b_init, cfg, dlg, comboName, seedUsed);
            if isempty(fit)
                result = [];
                return;
            end
            app.assertParameterCountMatchesModel(fit.b_fit, cfg.ModelType, comboName);

            y_fit_obs = app.evalModel(fit.b_fit, xAll, cfg);
            [fit_rmse, fit_r2] = app.computeRmseR2(yAll, y_fit_obs);

            y_pw_obs = app.predictPiecewiseAtX(piece, xAll);
            pw_rmse = sqrt(mean((yAll - y_pw_obs).^2,'omitnan'));
            piece.rmse = pw_rmse;

            result = struct();
            result.Sheet = comboName;
            result.SourceSheets = sheets;
            result.IsCombined = true;
            result.Components = parts;

            result.SeedUsed = seedUsed;
            result.x = xAll;
            result.y_obs = yAll;
            result.xx = xx;

            result.b_init = b_init;
            result.b_fit = fit.b_fit;
            result.b_mean = fit.b_mean;
            result.b_std = fit.b_std;
            result.b_map = fit.b_map;
            result.Piecewise = piece;
            result.ModelType = cfg.ModelType;
            result.SolverType = cfg.SolverType;
            result.alpha1 = cfg.alpha1;
            result.alpha2 = cfg.alpha2;
            result.Model = @(b,xx_) app.evalModel(b, xx_, cfg);

            result.Fit = struct( ...
                'rmse', fit_rmse, ...
                'r2', fit_r2, ...
                'resnorm', fit.resnorm, ...
                'residual', fit.residual, ...
                'exitflag', fit.exitflag, ...
                'output', fit.output, ...
                'solver', fit.solver, ...
                'paramStats', fit.paramStats, ...
                'fitnlmModel', [], ...
                'fitnlmCoefficients', table());

            result.MCMC = fit.mcmcSummary;
            result.MCMCDisplay = struct( ...
                'plotMode', cfg.mcmcPlotMode, ...
                'showCredibleBand', cfg.mcmcShowCredibleBand);

            app.log(sprintf("%s: solver=%s | accept=%.2f%% | RMSE=%.4g", ...
                comboName, fit.solver, result.MCMC.acceptRate, fit_rmse));
        end

        % Random-walk Metropolis solver in log-parameter space. All fitted parameters
        % are kept positive by sampling theta = log(b).
        function fit = solveMCMCFit(app, x, y_obs, b_init, cfg, dlg, runLabel, seedUsed)
            fit = [];

            rng(seedUsed, "twister");

            [lb, ub] = app.getHybridBounds(cfg);
            lbFit = max(lb, 1e-300);
            ub = max(ub, lbFit .* (1 + 1e-12));

            b_init = app.projectToBoundsForHybrid(b_init, lbFit, ub, cfg);
            theta_lb = log(lbFit);
            theta_ub = log(ub);
            theta_current = min(max(log(b_init), theta_lb), theta_ub);

            p = numel(theta_current);
            nIter = cfg.mcmcIter;
            burnIn = cfg.mcmcBurnIn;
            sigmaObs = cfg.mcmcNoiseSigma;
            stepTheta = cfg.mcmcStepFrac .* ones(1,p);
            fixedGrowthN0 = strcmp(app.normalizeModelType(string(cfg.ModelType)), "Growth-Law") && ...
                isfield(cfg,'growthFixN0') && cfg.growthFixN0 && ...
                isfield(cfg,'growthFixedN0') && isfinite(cfg.growthFixedN0) && cfg.growthFixedN0 > 0;
            if fixedGrowthN0 && p >= 1
                theta_current(1) = log(cfg.growthFixedN0);
                theta_lb(1) = theta_current(1);
                theta_ub(1) = theta_current(1);
                stepTheta(1) = 0;
            end
            stride = max(10, cfg.mcmcUIStride);

            logPostCurrent = app.logPosteriorTheta(theta_current, x, y_obs, cfg, theta_lb, theta_ub, sigmaObs);
            if ~isfinite(logPostCurrent)
                [theta_current, logPostCurrent] = app.findFeasibleMCMCStart(theta_current, x, y_obs, cfg, theta_lb, theta_ub, sigmaObs);
            end
            if ~isfinite(logPostCurrent)
                error("MCMC could not find a finite starting point for %s. Try manual piecewise initialization or run NL Inversion first to diagnose the fit.", string(runLabel));
            end

            samples = zeros(nIter, p);
            logPostTrace = nan(nIter,1);
            acceptCount = 0;

            for ii = 1:nIter
                if (isvalid(dlg) && dlg.CancelRequested) || app.CancelRequested
                    return;
                end

                thetaProp = theta_current + stepTheta .* randn(1,p);
                logPostProp = app.logPosteriorTheta(thetaProp, x, y_obs, cfg, theta_lb, theta_ub, sigmaObs);

                if isfinite(logPostProp) && (log(rand) < (logPostProp - logPostCurrent))
                    theta_current = thetaProp;
                    logPostCurrent = logPostProp;
                    acceptCount = acceptCount + 1;
                end

                samples(ii,:) = app.applyFixedGrowthLawN0(exp(theta_current), cfg);
                logPostTrace(ii) = logPostCurrent;

                if mod(ii, stride) == 0
                    try
                        dlg.Message = sprintf("MCMC %s: iter %d / %d", runLabel, ii, nIter);
                    catch
                    end
                    drawnow limitrate;
                end
            end

            idxPost = (burnIn + 1):nIter;
            samplesPost = samples(idxPost,:);
            logPostPost = logPostTrace(idxPost);

            % Keep the full post-burn-in chain for posterior summaries and
            % exported MCMC diagnostics. A thinned post-burn-in copy is also
            % retained for interactive confidence-band drawing so the app stays
            % responsive when long chains are used.
            maxStoredPosteriorForUI = 2000;
            thinStep = max(1, ceil(size(samplesPost,1) ./ maxStoredPosteriorForUI));
            samplesPostThin = samplesPost(1:thinStep:end, :);

            samplesTrace = samples;
            iterTrace = (1:nIter).';

            b_mean = mean(samplesPost, 1, 'omitnan');
            b_std = std(samplesPost, 0, 1, 'omitnan');
            b_median = median(samplesPost, 1, 'omitnan');
            if fixedGrowthN0 && p >= 1
                b_mean(1) = cfg.growthFixedN0;
                b_median(1) = cfg.growthFixedN0;
                b_std(1) = 0;
            end

            [~, idxMap] = max(logPostPost);
            if isempty(idxMap) || ~isfinite(idxMap)
                idxMap = 1;
            end
            b_map = samplesPost(idxMap,:);
            if fixedGrowthN0 && p >= 1
                b_map(1) = cfg.growthFixedN0;
            end

            % Posterior mean 
            b_fit = b_mean;
            y_fit = app.evalModel(b_fit, x, cfg);
            residual = y_obs - y_fit;
            sse = sum(residual.^2, 'omitnan');

            ciLow = app.columnPercentile(samplesPost, 2.5);
            ciHigh = app.columnPercentile(samplesPost, 97.5);
            if fixedGrowthN0 && p >= 1
                ciLow(1) = cfg.growthFixedN0;
                ciHigh(1) = cfg.growthFixedN0;
            end

            paramStats = app.makeMCMCParameterStats(samplesPost, b_mean, b_map, b_std, ciLow, ciHigh, numel(y_obs));

            acceptRate = 100 * acceptCount / nIter;

            fit = struct();
            fit.b_fit = b_fit(:).';
            fit.b_mean = b_mean(:).';
            fit.b_std = b_std(:).';
            fit.b_median = b_median(:).';
            fit.b_map = b_map(:).';
            fit.resnorm = sse;
            fit.residual = residual(:);
            fit.exitflag = 1;
            fit.output = struct( ...
                'Method','random-walk Metropolis MCMC', ...
                'Parameterization','log-space', ...
                'Iterations',nIter, ...
                'BurnIn',burnIn, ...
                'StepFrac',cfg.mcmcStepFrac, ...
                'NoiseSigma',sigmaObs, ...
                'Seed',seedUsed);
            fit.solver = "MCMC";
            fit.paramStats = paramStats;
            fit.mcmcSummary = struct( ...
                'acceptRate', acceptRate, ...
                'seed', seedUsed, ...
                'nIter', nIter, ...
                'burnIn', burnIn, ...
                'stepFrac', cfg.mcmcStepFrac, ...
                'noiseSigma', sigmaObs, ...
                'b_mean', b_mean(:).', ...
                'b_std', b_std(:).', ...
                'b_median', b_median(:).', ...
                'b_map', b_map(:).', ...
                'ciLow', ciLow(:).', ...
                'ciHigh', ciHigh(:).', ...
                'samplesPost', samplesPost, ...
                'samplesPostThin', samplesPostThin, ...
                'logPostPost', logPostPost, ...
                'samplesTrace', samplesTrace, ...
                'iterTrace', iterTrace, ...
                'logPostTrace', logPostTrace);
        end

        % Gaussian log posterior used by the MCMC solver. 
        function logp = logPosteriorTheta(app, theta, x, y_obs, cfg, theta_lb, theta_ub, sigmaObs)
            if any(~isfinite(theta)) || any(theta < theta_lb) || any(theta > theta_ub)
                logp = -Inf;
                return;
            end

            b = exp(theta);
            r = app.nlResidual(b, x, y_obs, cfg);
            if isempty(r) || any(~isfinite(r)) || any(abs(r) > 1e8)
                logp = -Inf;
                return;
            end

            logp = -sum((r(:).^2) ./ (2 .* sigmaObs.^2), 'omitnan');
        end

        % If the piecewise start is not finite, jitter in log-space until a feasible
        % MCMC starting point is found.
        function [thetaBest, logPostBest] = findFeasibleMCMCStart(app, theta0, x, y_obs, cfg, theta_lb, theta_ub, sigmaObs)
            thetaBest = theta0;
            logPostBest = app.logPosteriorTheta(thetaBest, x, y_obs, cfg, theta_lb, theta_ub, sigmaObs);

            if isfinite(logPostBest)
                return;
            end

            % Local jitter around the piecewise start first.
            for kk = 1:250
                thetaTry = theta0 + 0.25 .* randn(size(theta0));
                thetaTry = min(max(thetaTry, theta_lb), theta_ub);
                lp = app.logPosteriorTheta(thetaTry, x, y_obs, cfg, theta_lb, theta_ub, sigmaObs);
                if isfinite(lp)
                    thetaBest = thetaTry;
                    logPostBest = lp;
                    return;
                end
            end

            % Broader log-space fallback.
            span = theta_ub - theta_lb;
            finiteSpan = isfinite(span) & span > 0;
            for kk = 1:500
                thetaTry = theta0;
                thetaTry(finiteSpan) = theta_lb(finiteSpan) + rand(size(theta0(finiteSpan))) .* min(span(finiteSpan), 80);
                thetaTry = min(max(thetaTry, theta_lb), theta_ub);
                lp = app.logPosteriorTheta(thetaTry, x, y_obs, cfg, theta_lb, theta_ub, sigmaObs);
                if isfinite(lp)
                    thetaBest = thetaTry;
                    logPostBest = lp;
                    return;
                end
            end
        end

        function stats = makeMCMCParameterStats(app, samplesPost, b_mean, b_best, b_std, ciLow, ciHigh, nObs)
            p = size(samplesPost, 2);
            ciMinus = nan(1,p);
            ciPlus  = nan(1,p);
            try
                ciMinus = max(b_mean(:).' - ciLow(:).', 0);
                ciPlus  = max(ciHigh(:).' - b_mean(:).', 0);
            catch
            end

            stats = struct( ...
                'mean', b_mean(:).', ...
                'best', b_best(:).', ...
                'sd', b_std(:).', ...
                'ciMinus', ciMinus, ...
                'ciPlus', ciPlus, ...
                'se', b_std(:).', ...
                'seLog', nan(1,p), ...
                'tStat', nan(1,p), ...
                'pValue', nan(1,p), ...
                'ciLow', ciLow(:).', ...
                'ciHigh', ciHigh(:).', ...
                'ciLowLog', nan(1,p), ...
                'ciHighLog', nan(1,p), ...
                'dof', max(nObs - p, 0), ...
                'sigma2', NaN, ...
                'fitScale', "mcmc-posterior-physical-b-space", ...
                'coefficientTable', table(), ...
                'bFit', b_mean(:).', ...
                'thetaFit', log(max(b_mean(:).', realmin)));

            try
                stats.tStat = b_mean(:).' ./ max(b_std(:).', eps);
            catch
            end
        end

        function q = columnPercentile(~, x, pct)
            if isempty(x)
                q = [];
                return;
            end
            x = sort(x, 1);
            n = size(x,1);
            p = max(0, min(100, pct)) ./ 100;
            pos = 1 + (n - 1) .* p;
            lo = floor(pos);
            hi = ceil(pos);
            w = pos - lo;
            lo = max(1, min(n, lo));
            hi = max(1, min(n, hi));
            q = (1 - w) .* x(lo,:) + w .* x(hi,:);
        end

        function assertParameterCountMatchesModel(app, b, modelType, sheetName)
            modelType = app.normalizeModelType(modelType);
            expected = numel(app.getParamDisplayNames(modelType));
            actual = numel(b);
            if actual ~= expected
                error("Parameter-count mismatch for %s. Model=%s expects %d fitted parameters but received %d. This prevents accidental fall-through to the wrong model branch.", ...
                    string(sheetName), modelType, expected, actual);
            end
        end

        % Build the model-specific initial guess. Chamber models use piecewise lines;
        
        function [b_init, piece] = getInitialGuess(app, cfg, sheet, x, y_obs, xx)
            if strcmp(app.normalizeModelType(string(cfg.ModelType)), "Growth-Law")
                [b_init, piece] = app.computeInitialGuessGrowthLaw(x, y_obs, xx);
                b_init = app.applyFixedGrowthLawN0(b_init, cfg);
                if isfield(cfg,'growthFixN0') && cfg.growthFixN0
                    try
                        piece.c = cfg.growthFixedLnN0;
                        piece.y1 = piece.m .* xx + piece.c;
                    catch
                    end
                    app.log("Growth-Law initialization used for " + string(sheet) + ". n⁰ fixed from ln(n⁰) = " + string(cfg.growthFixedLnN0) + ".");
                else
                    app.log("Growth-Law initialization used for " + string(sheet) + ". Fitted parameters are n⁰, b, and G₀τ₀ with aG₀τ₀ constrained to 1.");
                end
                return;
            end

            if strcmp(app.normalizeModelType(string(cfg.ModelType)), "Linear")
                [b_init, piece] = app.computeInitialGuessLinear(x, y_obs, xx);
                app.log("Linear initialization used for " + string(sheet) + ". Fitted parameters are n⁰ and Gτ.");
                return;
            end

            nSeg = app.getNumSegments(cfg);
            if ~cfg.manualPiecewise
                app.log("Auto piecewise initialization is being used for " + string(sheet) + ". If the fit is poor, enable Manual piecewise; manual picks are more reliable for sparse/curved CSDs.");
                [b_init, piece] = app.computeInitialGuessPiecewiseN(x, y_obs, xx, nSeg);
                return;
            end

            key = char(sheet);
            needPrompt = true;
            if isKey(app.ManualPWMap, key)
                S = app.ManualPWMap(key);
                if isfield(S,'segments')
                    segIdx = S.segments;
                    good = numel(segIdx) == nSeg;
                    if good
                        for ii = 1:nSeg
                            good = good && all(segIdx{ii} >= 1 & segIdx{ii} <= numel(x)) && numel(unique(segIdx{ii})) >= 2;
                        end
                    end
                    if good
                        needPrompt = false;
                    end
                end
            end
            if needPrompt
                app.log("Manual piecewise: need point picks for " + string(sheet) + " (prompting now).");
                segIdx = app.manualPickSegments(x, y_obs, sheet, nSeg);
                app.ManualPWMap(key) = struct('segments',{segIdx});
            end
            [b_init, piece] = app.computeInitialGuessPiecewiseManualN(x, y_obs, xx, segIdx);
        end

        function fit = solveNonlinearFit(app, x, y_obs, b_init, cfg)
            % NL workflow:
            %   Chamber models: bounded lsqnonlin initialization -> fitnlm
            %   statistics. (better for auto piecewise)
            %   Growth-Law and Linear: direct fitnlm in log-parameter space
            if strcmp(app.normalizeModelType(string(cfg.ModelType)), "Growth-Law")
                fit = app.solveGrowthLawFitNLMDirect(x, y_obs, b_init, cfg);
                return;
            elseif strcmp(app.normalizeModelType(string(cfg.ModelType)), "Linear")
                fit = app.solveLinearFitNLMDirect(x, y_obs, b_init, cfg);
                return;
            end

            if ~(license('test','optimization_toolbox') && exist('lsqnonlin','file') == 2)
                error("lsqnonlin requires Optimization Toolbox and was not found.");
            end

            [lb, ub] = app.getHybridBounds(cfg);
            tiny = 1e-300;
            lbFit = max(lb, tiny);
            ub = max(ub, lbFit .* (1 + 1e-12));

            b_init = app.projectToBoundsForHybrid(b_init, lbFit, ub, cfg);
            theta_init = log(b_init);
            theta_lb = log(lbFit);
            theta_ub = log(ub);
            starts = app.makeStartGuessesLogHybrid(theta_init, theta_lb, theta_ub, cfg.nStarts);

            bestLSQ = [];
            bestSSE = inf;
            failMessages = strings(0,1);

            optsLSQ = optimoptions('lsqnonlin', ...
                'Display','off', ...
                'MaxIterations', cfg.maxIter, ...
                'FunctionTolerance', cfg.funcTol, ...
                'StepTolerance', cfg.stepTol);

            for k = 1:size(starts,1)
                theta0 = starts(k,:);
                try
                    [theta_lsq,resnorm,residual,exitflag,output,~,jacobianTheta] = lsqnonlin( ...
                        @(theta) app.nlResidualThetaBounded(theta, x, y_obs, cfg, theta_lb, theta_ub), ...
                        theta0, theta_lb, theta_ub, optsLSQ);

                    b_lsq = exp(theta_lsq);
                    y_lsq = app.evalModel(b_lsq, x, cfg);
                    residual = y_obs - y_lsq;
                    sse = sum(residual.^2, 'omitnan');

                    if isfinite(sse) && sse < bestSSE
                        bestSSE = sse;
                        bestLSQ = struct( ...
                            'theta_fit', theta_lsq(:).', ...
                            'b_fit', b_lsq(:).', ...
                            'resnorm', resnorm, ...
                            'residual', residual(:), ...
                            'exitflag', exitflag, ...
                            'output', output, ...
                            'jacobian', jacobianTheta, ...
                            'jacobianScale', "log-parameter", ...
                            'bounds_lb', lb, ...
                            'bounds_ub', ub, ...
                            'adaptiveN0High', NaN, ...
                            'adaptiveN0Used', false, ...
                            'solver', "fitnlm");
                    end
                catch ME_lsq
                    failMessages(end+1,1) = "lsq start " + string(k) + ": " + string(ME_lsq.message); 
                end
            end

            if isempty(bestLSQ)
                if isempty(failMessages)
                    error("Bounded lsqnonlin failed for all start points.");
                else
                    error("Bounded lsqnonlin failed for all start points. First failure: %s", failMessages(1));
                end
            end

            fit = app.runFitNLMFromLSQ(x, y_obs, bestLSQ, cfg);
        end

        % Direct Growth-Law fit in log-parameter space. handles the optional
        % fixed ln(n0) case 
        function fit = solveGrowthLawFitNLMDirect(app, x, y_obs, b_init, cfg)
            if ~(exist('fitnlm','file') == 2)
                error("Growth-Law NL inversion requires fitnlm from the Statistics and Machine Learning Toolbox.");
            end

            [lb, ub] = app.getHybridBounds(cfg);
            lbFit = max(lb, 1e-300);
            ub = max(ub, lbFit .* (1 + 1e-12));
            b_init = app.projectToBoundsForHybrid(b_init, lbFit, ub, cfg);
            thetaFull0 = log(max(b_init(:).', realmin));

            fixedN0 = isfield(cfg,'growthFixN0') && cfg.growthFixN0 && ...
                isfield(cfg,'growthFixedN0') && isfinite(cfg.growthFixedN0) && cfg.growthFixedN0 > 0;

            if fixedN0
                theta0 = thetaFull0(2:3);
                modelfun = @(theta,xdata) app.evalGrowthLawForFitNLMTheta(theta, xdata, cfg, true);
            else
                theta0 = thetaFull0;
                modelfun = @(theta,xdata) app.evalGrowthLawForFitNLMTheta(theta, xdata, cfg, false);
            end

            try
                opts = statset('fitnlm');
            catch
                opts = statset('nlinfit');
            end
            try
                opts.Display = 'off';
            catch
            end
            try
                opts.MaxIter = cfg.maxIter;
            catch
            end
            try
                opts.TolFun = cfg.funcTol;
            catch
            end
            try
                opts.TolX = cfg.stepTol;
            catch
            end
            try
                opts.RobustWgtFun = 'bisquare';
            catch
            end

            oldWarn = warning;
            cleanup = onCleanup(@() warning(oldWarn)); 
            warning('off','all');

            mdl = fitnlm(x, y_obs, modelfun, theta0, 'Options', opts);
            thetaFree = mdl.Coefficients.Estimate(:).';

            if fixedN0
                b_fit = [cfg.growthFixedN0, exp(thetaFree(1)), exp(thetaFree(2))];
                thetaFull = log(max(b_fit, realmin));
            else
                b_fit = exp(thetaFree);
                b_fit = app.applyFixedGrowthLawN0(b_fit, cfg);
                thetaFull = log(max(b_fit, realmin));
            end

            y_fit = app.evalModel(b_fit, x, cfg);
            residual = y_obs - y_fit;
            sse = sum(residual.^2, 'omitnan');
            if ~isfinite(sse) || any(~isfinite(b_fit))
                error("Growth-Law fitnlm returned a non-finite solution.");
            end

            if fixedN0
                freeStats = app.computeParameterStatsFromFitNLM(mdl, b_fit(2:3), thetaFree, numel(y_obs));
                paramStats = app.expandGrowthLawFixedN0Stats(freeStats, b_fit, thetaFull, numel(y_obs));
            else
                paramStats = app.computeParameterStatsFromFitNLM(mdl, b_fit, thetaFull, numel(y_obs));
            end

            fit = struct();
            fit.theta_fit = thetaFull;
            fit.b_fit = b_fit(:).';
            fit.resnorm = sse;
            fit.residual = residual(:);
            fit.exitflag = 1;
            fit.output = struct( ...
                'Method','direct fitnlm for Growth-Law', ...
                'RobustWgtFun','bisquare', ...
                'Parameterization','log-space', ...
                'FixedN0',fixedN0);
            fit.fitnlmModel = mdl;
            fit.fitnlmCoefficients = mdl.Coefficients;
            fit.paramStats = paramStats;
            fit.solver = "fitnlm";
        end

        %  Linear fit. 
        function fit = solveLinearFitNLMDirect(app, x, y_obs, b_init, cfg)

            if ~(exist('fitnlm','file') == 2)
                error("Linear NL inversion requires fitnlm from the Statistics and Machine Learning Toolbox.");
            end

            [lb, ub] = app.getHybridBounds(cfg);
            lbFit = max(lb, 1e-300);
            ub = max(ub, lbFit .* (1 + 1e-12));
            b_init = app.projectToBoundsForHybrid(b_init, lbFit, ub, cfg);
            theta0 = log(max(b_init(:).', realmin));

            try
                opts = statset('fitnlm');
            catch
                opts = statset('nlinfit');
            end
            try
                opts.Display = 'off';
            catch
            end
            try
                opts.MaxIter = cfg.maxIter;
            catch
            end
            try
                opts.TolFun = cfg.funcTol;
            catch
            end
            try
                opts.TolX = cfg.stepTol;
            catch
            end
            try
                opts.RobustWgtFun = 'bisquare';
            catch
            end

            oldWarn = warning;
            cleanup = onCleanup(@() warning(oldWarn)); 
            warning('off','all');

            modelfun = @(theta,xdata) app.evalLinearForFitNLMTheta(theta, xdata, cfg);
            mdl = fitnlm(x, y_obs, modelfun, theta0, 'Options', opts);

            theta_fit = mdl.Coefficients.Estimate(:).';
            b_fit = exp(theta_fit);
            b_fit = app.projectToBoundsForHybrid(b_fit, lbFit, ub, cfg);
            theta_fit = log(max(b_fit, realmin));

            y_fit = app.evalModel(b_fit, x, cfg);
            residual = y_obs - y_fit;
            sse = sum(residual.^2, 'omitnan');
            if ~isfinite(sse) || any(~isfinite(b_fit))
                error("Linear fitnlm returned a non-finite solution.");
            end

            fit = struct();
            fit.theta_fit = theta_fit;
            fit.b_fit = b_fit(:).';
            fit.resnorm = sse;
            fit.residual = residual(:);
            fit.exitflag = 1;
            fit.output = struct( ...
                'Method','direct fitnlm for Linear', ...
                'RobustWgtFun','bisquare', ...
                'Parameterization','log-space', ...
                'MCMCEnabled',false);
            fit.fitnlmModel = mdl;
            fit.fitnlmCoefficients = mdl.Coefficients;
            fit.paramStats = app.computeParameterStatsFromFitNLM(mdl, b_fit, theta_fit, numel(y_obs));
            fit.solver = "fitnlm";
        end

        function y = evalLinearForFitNLMTheta(app, theta, xdata, cfg)
            xdata = xdata(:);
            theta = double(theta(:)).';
            if numel(theta) < 2 || any(~isfinite(theta))
                y = 1e8 .* ones(size(xdata));
                return;
            end

            b = exp(theta(1:2));
            y = app.evalModel(b, xdata, cfg);
            if isempty(y) || numel(y) ~= numel(xdata) || any(~isfinite(y)) || ~isreal(y)
                y = 1e8 .* ones(size(xdata));
                return;
            end
            y = real(y(:));
            bad = ~isfinite(y) | abs(y) > 1e8;
            if any(bad)
                y(bad) = 1e8;
            end
        end

        function y = evalGrowthLawForFitNLMTheta(app, theta, xdata, cfg, fixedN0)
            xdata = xdata(:);
            theta = double(theta(:)).';
            if any(~isfinite(theta))
                y = 1e8 .* ones(size(xdata));
                return;
            end

            if fixedN0
                if numel(theta) < 2 || ~isfield(cfg,'growthFixedN0') || ~isfinite(cfg.growthFixedN0) || cfg.growthFixedN0 <= 0
                    y = 1e8 .* ones(size(xdata));
                    return;
                end
                b = [cfg.growthFixedN0, exp(theta(1)), exp(theta(2))];
            else
                if numel(theta) < 3
                    y = 1e8 .* ones(size(xdata));
                    return;
                end
                b = exp(theta(1:3));
            end

            y = app.evalModel(b, xdata, cfg);
            if isempty(y) || numel(y) ~= numel(xdata) || any(~isfinite(y)) || ~isreal(y)
                y = 1e8 .* ones(size(xdata));
                return;
            end
            y = real(y(:));
            bad = ~isfinite(y) | abs(y) > 1e8;
            if any(bad)
                y(bad) = 1e8;
            end
        end

        function stats = expandGrowthLawFixedN0Stats(app, freeStats, b_fit, theta_fit, nObs)
            stats = app.makeNaNParameterStats(3, nObs, b_fit, theta_fit);
            try
                stats.se(1) = 0;
                stats.ciLow(1) = b_fit(1);
                stats.ciHigh(1) = b_fit(1);
                stats.seLog(1) = 0;
                stats.ciLowLog(1) = theta_fit(1);
                stats.ciHighLog(1) = theta_fit(1);
                stats.tStat(1) = NaN;
                stats.pValue(1) = NaN;
                fields = {'se','seLog','tStat','pValue','ciLow','ciHigh','ciLowLog','ciHighLog'};
                for ff = 1:numel(fields)
                    f = fields{ff};
                    if isfield(freeStats, f) && numel(freeStats.(f)) >= 2
                        stats.(f)(2:3) = freeStats.(f)(1:2);
                    end
                end
                stats.fitScale = "growth-law-fixed-n0-physical-b-space";
                stats.coefficientTable = freeStats.coefficientTable;
                stats.bFit = b_fit(:).';
                stats.thetaFit = theta_fit(:).';
            catch
            end
        end


        function fit = runFitNLMFromLSQ(app, x, y_obs, lsqFit, cfg)
            theta0 = lsqFit.theta_fit(:).';
            [lb, ub] = app.getHybridBounds(cfg);
            lbFit = max(lb, 1e-300);
            theta_lb = log(lbFit);
            theta_ub = log(max(ub, lbFit .* (1 + 1e-12)));
            theta0 = min(max(theta0, theta_lb), theta_ub);

            fit = lsqFit;
            fit.fitnlmModel = [];
            fit.fitnlmCoefficients = table();
            fit.paramStats = app.makeNaNParameterStats(numel(theta0), numel(y_obs), lsqFit.b_fit, theta0);
            fit.solver = "fitnlm";

            if ~(exist('fitnlm','file') == 2)
                return;
            end

            try
                try
                    opts = statset('fitnlm');
                catch
                    opts = statset('nlinfit');
                end
                try
                    opts.Display = 'off';
                catch
                end
                try
                    opts.MaxIter = cfg.maxIter;
                catch
                end
                try
                    opts.TolFun = cfg.funcTol;
                catch
                end
                try
                    opts.TolX = cfg.stepTol;
                catch
                end
                try
                    opts.RobustWgtFun = 'bisquare';
                catch
                end

                oldWarn = warning;
                cleanup = onCleanup(@() warning(oldWarn)); 
                warning('off','all');

                modelfun = @(theta,xdata) app.evalModelForFitnlmTheta(theta, xdata, cfg);
                mdl = fitnlm(x, y_obs, modelfun, theta0, 'Options', opts);

                theta_fit = mdl.Coefficients.Estimate(:).';
                theta_fit = min(max(theta_fit, theta_lb), theta_ub);
                b_fit = exp(theta_fit);
                y_fit = app.evalModel(b_fit, x, cfg);
                residual = y_obs - y_fit;
                sse = sum(residual.^2, 'omitnan');

                if isfinite(sse) && all(isfinite(b_fit))
                    fit.theta_fit = theta_fit;
                    fit.b_fit = b_fit;
                    fit.resnorm = sse;
                    fit.residual = residual(:);
                    fit.exitflag = 1;
                    fit.output = struct( ...
                        'Method','lsqnonlin-seeded fitnlm', ...
                        'RobustWgtFun','bisquare', ...
                        'Parameterization','log-space', ...
                        'LSQOutput',lsqFit.output);
                    fit.fitnlmModel = mdl;
                    fit.fitnlmCoefficients = mdl.Coefficients;
                    fit.paramStats = app.computeParameterStatsFromFitNLM(mdl, b_fit, theta_fit, numel(y_obs));
                    fit.solver = "fitnlm";
                end
            catch
              
            end
        end

        function stats = makeNaNParameterStats(~, p, nObs, b_fit, theta_fit)
            stats = struct( ...
                'se', nan(1,p), ...
                'seLog', nan(1,p), ...
                'tStat', nan(1,p), ...
                'pValue', nan(1,p), ...
                'ciLow', nan(1,p), ...
                'ciHigh', nan(1,p), ...
                'ciLowLog', nan(1,p), ...
                'ciHighLog', nan(1,p), ...
                'dof', max(nObs - p, 0), ...
                'sigma2', NaN, ...
                'fitScale', "physical-b-space", ...
                'coefficientTable', table(), ...
                'bFit', b_fit(:).', ...
                'thetaFit', theta_fit(:).');
        end

        %  bounds for all positive fitted parameters. 
        function [lb, ub] = getHybridBounds(app, cfg)
            modelType = app.normalizeModelType(string(cfg.ModelType));
            n0Low = 0.0;
            n0High = 1e14;
            gtLow = 1e-14;
            gtHigh = 1e14;

            if strcmp(modelType, "3-Chamber")
                lb = [n0Low, gtLow, n0Low, gtLow, n0Low, gtLow];
                ub = [n0High, gtHigh, n0High, gtHigh, n0High, gtHigh];
            elseif strcmp(modelType, "Growth-Law")
                lb = [n0Low, gtLow, gtLow];
                ub = [n0High, gtHigh, gtHigh];
                if isfield(cfg,'growthFixN0') && cfg.growthFixN0 && isfinite(cfg.growthFixedN0) && cfg.growthFixedN0 > 0
                    fixedN0 = max(cfg.growthFixedN0, realmin);
                    dN0 = max(abs(fixedN0) .* 1e-10, realmin);
                    lb(1) = max(realmin, fixedN0 - dN0);
                    ub(1) = fixedN0 + dN0;
                end
            elseif strcmp(modelType, "Linear")
                lb = [n0Low, gtLow];
                ub = [n0High, gtHigh];
            else
                lb = [n0Low, gtLow, n0Low, gtLow];
                ub = [n0High, gtHigh, n0High, gtHigh];
            end
        end

        function r = nlResidualThetaBounded(app, theta, x, y_obs, cfg, theta_lb, theta_ub)
            if any(~isfinite(theta)) || any(theta < theta_lb) || any(theta > theta_ub)
                r = 1e9 * ones(size(y_obs));
                return;
            end
            b = exp(theta);
            r = app.nlResidual(b, x, y_obs, cfg);
        end

        function starts = makeStartGuessesLogHybrid(~, theta_init, theta_lb, theta_ub, nStarts)
            % Multi-starts
            nStarts = max(1, round(nStarts));
            theta_init = min(max(theta_init(:).', theta_lb), theta_ub);
            starts = zeros(nStarts, numel(theta_init));
            starts(1,:) = theta_init;

            for k = 2:nStarts
                if k <= ceil(nStarts/2)
                    sigma = 0.35;
                else
                    sigma = 0.90;
                end
                trialTheta = theta_init + sigma .* randn(size(theta_init));
                starts(k,:) = min(max(trialTheta, theta_lb), theta_ub);
            end
        end

        function b = sanitizePositiveStart(app, b, cfg)
            b = double(b(:)).';
            b(~isfinite(b)) = 1;
            [lb, ub] = app.getHybridBounds(cfg);
            lbFit = max(lb, 1e-300);
            b = app.projectToBoundsForHybrid(b, lbFit, ub, cfg);
        end

        function b = projectToBoundsForHybrid(app, b, lb, ub, cfg)
            b = double(b(:)).';
            n = min([numel(b), numel(lb), numel(ub)]);
            if numel(b) < numel(lb)
                b(end+1:numel(lb)) = 1;
            end
            b = b(1:numel(lb));
            b(~isfinite(b)) = 1;
            b = min(max(b, lb .* (1 + 1e-12)), ub .* (1 - 1e-12));
            b = app.applyFixedGrowthLawN0(b, cfg);

            modelType = app.normalizeModelType(string(cfg.ModelType));
            if strcmp(modelType, "3-Chamber") && numel(b) >= 6
                if abs(b(2) - b(6)) < 1e-8
                    b(6) = min(ub(6), max(lb(6), b(6) * 1.10 + 1e-6));
                end
                if abs(b(4) - b(6)) < 1e-8
                    b(6) = min(ub(6), max(lb(6), b(6) * 1.20 + 2e-6));
                end
            elseif strcmp(modelType, "2-Chamber") && numel(b) >= 4
                if abs(b(2) - b(4)) < 1e-8
                    b(4) = min(ub(4), max(lb(4), b(4) * 1.10 + 1e-6));
                end
            end
        end

        function theta = sanitizeThetaStart(app, theta, cfg)
            theta = double(theta(:)).';
            theta(~isfinite(theta)) = 0;
            b = exp(theta);
            b = app.sanitizePositiveStart(b, cfg);
            theta = log(b);
        end

        function y = evalModelForFitnlmTheta(app, theta, xdata, cfg)
            xdata = xdata(:);
            theta = double(theta(:)).';
            if any(~isfinite(theta))
                y = 1e8 .* ones(size(xdata));
                return;
            end

            b = exp(theta);
            y = app.evalModel(b, xdata, cfg);

            if isempty(y) || numel(y) ~= numel(xdata) || any(~isfinite(y)) || ~isreal(y)
                y = 1e8 .* ones(size(xdata));
                return;
            end

            y = real(y(:));
            bad = ~isfinite(y) | abs(y) > 1e8;
            if any(bad)
                y(bad) = 1e8;
            end
        end

        function r = nlResidual(app, b, x, y_obs, cfg)
            if any(~isfinite(b))
                r = 1e9 * ones(size(y_obs));
                return;
            end
            modelType = app.normalizeModelType(string(cfg.ModelType));
            if strcmp(modelType, "2-Chamber")
                if numel(b) < 4 || abs(b(2) - b(4)) < 1e-10
                    r = 1e6 * ones(size(y_obs));
                    return;
                end
            elseif strcmp(modelType, "3-Chamber")
                if numel(b) < 6 || abs(b(2) - b(6)) < 1e-10 || abs(b(4) - b(6)) < 1e-10
                    r = 1e6 * ones(size(y_obs));
                    return;
                end
            elseif strcmp(modelType, "Growth-Law")
                b = app.applyFixedGrowthLawN0(b, cfg);
                if numel(b) < 3 || b(1) <= 0 || b(2) <= 0 || b(3) <= 0
                    r = 1e6 * ones(size(y_obs));
                    return;
                end
            elseif strcmp(modelType, "Linear")
                if numel(b) < 2 || b(1) <= 0 || b(2) <= 0
                    r = 1e6 * ones(size(y_obs));
                    return;
                end
            end
            y_pred = app.evalModel(b, x, cfg);
            if any(~isfinite(y_pred)) || ~isreal(y_pred)
                r = 1e9 * ones(size(y_obs));
                return;
            end
            r = y_obs - y_pred;
        end

        function sse = nlObjective(app, b, x, y_obs, cfg)
            r = app.nlResidual(b, x, y_obs, cfg);
            sse = sum(r.^2);
        end

        function stats = computeParameterStatsFromFitNLM(app, mdl, b_fit, theta_fit, nObs)
            coefs = mdl.Coefficients;
            p = height(coefs);
            stats = struct( ...
                'se', nan(1,p), ...
                'seLog', nan(1,p), ...
                'tStat', nan(1,p), ...
                'pValue', nan(1,p), ...
                'ciLow', nan(1,p), ...
                'ciHigh', nan(1,p), ...
                'ciLowLog', nan(1,p), ...
                'ciHighLog', nan(1,p), ...
                'dof', max(nObs - p, 0), ...
                'sigma2', NaN, ...
                'fitScale', "physical-b-space", ...
                'coefficientTable', coefs, ...
                'bFit', b_fit(:).', ...
                'thetaFit', theta_fit(:).');

            try
                stats.seLog = coefs.SE(:).';
            catch
            end
            try
                stats.sigma2 = mdl.MSE;
            catch
            end

            try
                ci = coefCI(mdl, 0.05);
                stats.ciLowLog = ci(:,1).';
                stats.ciHighLog = ci(:,2).';
            catch
            end

            % Convert coefficient uncertainty from theta=log(b) space back to
            % physical b-space. 
            try
                stats.se = abs(b_fit(:).') .* stats.seLog;
            catch
            end

            try
                bRow = b_fit(:).';
                stats.tStat = bRow ./ max(stats.se, eps);
                stats.pValue = 2 .* (1 - app.safeTCdf(abs(stats.tStat), stats.dof));
            catch
                try
                    stats.tStat = coefs.tStat(:).';
                catch
                end
                try
                    stats.pValue = coefs.pValue(:).';
                catch
                end
            end

            try
                stats.ciLow = exp(stats.ciLowLog);
                stats.ciHigh = exp(stats.ciHighLog);
            catch
            end
        end

        function p = safeTCdf(app, x, v)
            try
                p = tcdf(x, v);
                return;
            catch
            end

            p = arrayfun(@(xx) app.safeTCdfScalar(xx, v), x);
        end

        function p = safeTCdfScalar(~, x, v)
            if ~isfinite(x) || ~isfinite(v) || v <= 0
                p = NaN;
                return;
            end
            z = v ./ (v + x.^2);
            ib = betainc(z, v/2, 0.5);
            if x >= 0
                p = 1 - 0.5 * ib;
            else
                p = 0.5 * ib;
            end
        end

        function t = safeTInv(app, p, v)
            try
                t = tinv(p, v);
                return;
            catch
            end

            if ~isfinite(p) || ~isfinite(v) || v <= 0 || p <= 0 || p >= 1
                t = NaN;
                return;
            end

            try
                f = @(xx) app.safeTCdf(xx, v) - p;
                hi = 1;
                while f(hi) < 0 && hi < 1e6
                    hi = hi * 2;
                end
                t = fzero(f, [0 hi]);
            catch
                t = 1.96;
            end
        end

        % All fitting, plotting, export,
        % and diagnostics should call this rather than individual model functions.
        function y = evalModel(app, b, x, cfg)
            modelType = app.normalizeModelType(string(cfg.ModelType));
            if strcmp(modelType, "3-Chamber")
                y = app.threeChamberModel(b, x, cfg.alpha1);
            elseif strcmp(modelType, "Growth-Law")
                b = app.applyFixedGrowthLawN0(b, cfg);
                y = app.growthLawModel(b, x);
            elseif strcmp(modelType, "Linear")
                y = app.linearModel(b, x);
            else
                y = app.twoChamberModel(b, x);
            end
        end

        function names = getParamNames(app, modelType)
            names = app.getParamDisplayNames(modelType);
        end

        % Two-component chamber/mixing CSD model evaluated in log-space.
        function y = twoChamberModel(~, b, x)
            b1 = b(1); b2 = b(2); b3 = b(3); b4 = b(4);
            denom = (b2 - b4);
            if abs(denom) < 1e-12
                y = nan(size(x));
                return;
            end
            A = b1*b2/denom;
            B = b3 - A;
            inner = A.*exp(-x./b2) + B.*exp(-x./b4);
            y = nan(size(x));
            mask = inner > 0 & isfinite(inner);
            y(mask) = log(inner(mask));
        end

        % Three-component chamber/mixing CSD model. 
        function y = threeChamberModel(~, b, x, alpha1)
            % 6-parameter 3-Chamber model:
            % b1 = n₁⁰
            % b2 = G₁τ₁
            % b3 = n₂⁰
            % b4 = G₂τ₂
            % b5 = nₘᵢₓ⁰
            % b6 = Gₘᵢₓτₘᵢₓ
            alpha2 = 1 - alpha1;

            denom1 = b(2) - b(6);
            denom2 = b(4) - b(6);
            if abs(denom1) < 1e-12 || abs(denom2) < 1e-12
                y = nan(size(x));
                return;
            end

            A1 = alpha1 * b(1) * b(2) / denom1;
            A2 = alpha2 * b(3) * b(4) / denom2;
            A3 = b(5) - A1 - A2;

            inner = A1 .* exp(-x ./ b(2)) + ...
                    A2 .* exp(-x ./ b(4)) + ...
                    A3 .* exp(-x ./ b(6));

            y = nan(size(x));
            mask = inner > 0 & isfinite(inner);
            y(mask) = log(inner(mask));
        end


        function y = linearModel(~, b, x)
            % Linear/classic CSD model
            n0 = b(1);
            Gtau = b(2);

            x = x(:);
            y = nan(size(x));
            if ~isfinite(n0) || ~isfinite(Gtau) || n0 <= 0 || Gtau <= 0
                return;
            end

            y = log(n0) - x ./ Gtau;
        end


        function b = applyFixedGrowthLawN0(app, b, cfg)
            b = double(b(:)).';
            try
                if strcmp(app.normalizeModelType(string(cfg.ModelType)), "Growth-Law") && ...
                        isfield(cfg,'growthFixN0') && cfg.growthFixN0 && ...
                        isfield(cfg,'growthFixedN0') && isfinite(cfg.growthFixedN0) && cfg.growthFixedN0 > 0
                    if numel(b) < 3
                        b(end+1:3) = 1;
                    end
                    b(1) = cfg.growthFixedN0;
                end
            catch
            end
        end

     
        function y = growthLawModel(~, b, x)
            % Growth-law CSD model:
         
            n0 = b(1);
            beta = b(2);
            G0tau0 = b(3);

            x = x(:);
            y = nan(size(x));
            if ~isfinite(n0) || ~isfinite(beta) || ~isfinite(G0tau0) || n0 <= 0 || beta <= 0 || G0tau0 <= 0
                return;
            end

            u = 1 + x ./ G0tau0;
            good = u > 0 & isfinite(u);
            if ~any(good)
                return;
            end

            logu = log(u(good));
            delta = 1 - beta;
            if abs(delta) < 1e-8
                expoTerm = -logu;  % limiting form as beta -> 1
            else
                expoTerm = (1 - u(good).^delta) ./ delta;
            end

            y(good) = log(n0) - beta .* logu + expoTerm;
        end


        % Break a fitted model into chamber curves for diagnostic plots.
        function comp = computeModelComponents(app, b, x, modelType, alpha1)
            x = x(:);
            modelType = app.normalizeModelType(string(modelType));
            comp = struct();
            comp.x = x;
            comp.labels = strings(1,0);
            comp.n = [];
            comp.totalN = nan(size(x));
            comp.totalLn = nan(size(x));
            comp.amplitudes = [];

            if strcmp(modelType, "Growth-Law")
                yModel = app.growthLawModel(b, x);
                good = isfinite(yModel);
                comp.labels = "Growth-law model";
                comp.totalLn = yModel(:);
                comp.totalN = nan(size(x));
                comp.totalN(good) = exp(yModel(good));
                comp.n = comp.totalN(:);
                if numel(b) >= 3
                    comp.amplitudes = [b(1) b(2) b(3)];
                else
                    comp.amplitudes = [];
                end
                return;
            elseif strcmp(modelType, "Linear")
                yModel = app.linearModel(b, x);
                good = isfinite(yModel);
                comp.labels = "Linear model";
                comp.totalLn = yModel(:);
                comp.totalN = nan(size(x));
                comp.totalN(good) = exp(yModel(good));
                comp.n = comp.totalN(:);
                if numel(b) >= 2
                    comp.amplitudes = [b(1) b(2)];
                else
                    comp.amplitudes = [];
                end
                return;
            elseif strcmp(modelType, "3-Chamber")
                alpha2 = 1 - alpha1;
                denom1 = b(2) - b(6);
                denom2 = b(4) - b(6);
                if abs(denom1) < 1e-12 || abs(denom2) < 1e-12
                    return;
                end
                A1 = alpha1 * b(1) * b(2) / denom1;
                A2 = alpha2 * b(3) * b(4) / denom2;
                A3 = b(5) - A1 - A2;
                N1 = A1 .* exp(-x ./ b(2));
                N2 = A2 .* exp(-x ./ b(4));
                N3 = A3 .* exp(-x ./ b(6));
                comp.labels = ["Chamber 1", "Chamber 2", "Shallow Chamber"];
                comp.n = [N1(:), N2(:), N3(:)];
                comp.amplitudes = [A1 A2 A3];
            else
                denom = b(2) - b(4);
                if abs(denom) < 1e-12
                    return;
                end
                A1 = b(1) * b(2) / denom;
                A2 = b(3) - A1;
                N1 = A1 .* exp(-x ./ b(2));
                N2 = A2 .* exp(-x ./ b(4));
                comp.labels = ["Chamber 1", "Shallow Chamber"];
                comp.n = [N1(:), N2(:)];
                comp.amplitudes = [A1 A2];
            end

            comp.totalN = sum(comp.n, 2, 'omitnan');
            good = comp.totalN > 0 & isfinite(comp.totalN);
            comp.totalLn = nan(size(comp.totalN));
            comp.totalLn(good) = log(comp.totalN(good));
        end

        function [rmse, r2] = computeRmseR2(~, y_obs, y_pred)
            resid = y_obs - y_pred;
            rmse = sqrt(mean(resid.^2,'omitnan'));
            sse = sum(resid.^2,'omitnan');
            ybar = mean(y_obs,'omitnan');
            sst = sum((y_obs - ybar).^2,'omitnan');
            if sst <= 0
                r2 = NaN;
            else
                r2 = 1 - sse/sst;
            end
        end

        function nSeg = getNumSegments(app, cfg)
            modelType = app.normalizeModelType(string(cfg.ModelType));
            if strcmp(modelType, "3-Chamber")
                nSeg = 3;
            elseif strcmp(modelType, "Growth-Law") || strcmp(modelType, "Linear")
                nSeg = 1;
            else
                nSeg = 2;
            end
        end

        function y_pw = predictPiecewiseAtX(~, piece, x)
            y_pw = nan(size(x));
            if piece.nSeg == 1
                y_pw = piece.m(1).*x + piece.c(1);
                return;
            end
            if piece.nSeg == 2
                if isfield(piece,'manual') && piece.manual
                    m1 = piece.m(1); c1 = piece.c(1);
                    m2 = piece.m(2); c2 = piece.c(2);
                    if abs(m1 - m2) < 1e-12
                        x0 = median(x);
                    else
                        x0 = (c2 - c1) / (m1 - m2);
                    end
                    mask = x <= x0;
                    y_pw(mask) = m1 .* x(mask) + c1;
                    y_pw(~mask) = m2 .* x(~mask) + c2;
                else
                    idx = max(1, min(numel(x), round(piece.idx(1))));
                    y_pw(1:idx) = piece.m(1).*x(1:idx) + piece.c(1);
                    y_pw(idx:end) = piece.m(2).*x(idx:end) + piece.c(2);
                end
            else
                if isfield(piece,'manual') && piece.manual
                    s1 = max(x(piece.idxSegments{1}));
                    s2 = max(x(piece.idxSegments{2}));
                    for i = 1:numel(x)
                        if x(i) <= s1
                            k = 1;
                        elseif x(i) <= s2
                            k = 2;
                        else
                            k = 3;
                        end
                        y_pw(i) = piece.m(k).*x(i) + piece.c(k);
                    end
                else
                    idx1 = max(1, min(numel(x), round(piece.idx(1))));
                    idx2 = max(idx1+1, min(numel(x), round(piece.idx(2))));
                    y_pw(1:idx1) = piece.m(1).*x(1:idx1) + piece.c(1);
                    y_pw(idx1+1:idx2) = piece.m(2).*x(idx1+1:idx2) + piece.c(2);
                    if idx2 < numel(x)
                        y_pw(idx2+1:end) = piece.m(3).*x(idx2+1:end) + piece.c(3);
                    end
                end
            end
        end

        % Linear initial guess 
     
        function [b_init, piece] = computeInitialGuessLinear(~, x, y_obs, xx)
            x = x(:);
            y_obs = y_obs(:);
            good = isfinite(x) & isfinite(y_obs);
            x = x(good);
            y_obs = y_obs(good);

            if numel(x) < 2
                error("Need at least 2 data points for Linear initialization.");
            end

            [x, ord] = sort(x);
            y_obs = y_obs(ord);

            p = polyfit(x, y_obs, 1);
            m = p(1);
            c = p(2);
            yhat = polyval(p, x);
            ss_res = sum((y_obs - yhat).^2);
            ss_tot = sum((y_obs - mean(y_obs)).^2);
            if ss_tot <= 0
                r2 = NaN;
            else
                r2 = 1 - ss_res/ss_tot;
            end

            n0 = max(exp(c), eps);
            xPositive = x(x > 0 & isfinite(x));
            if isempty(xPositive)
                xScale = max(max(x) - min(x), 1);
            else
                xScale = median(xPositive);
            end
            xScale = max(xScale, eps);

            if isfinite(m) && m < -eps
                Gtau = max(-1 ./ m, eps);
            else
                Gtau = xScale;
            end

            b_init = [n0, Gtau];
            piece = struct( ...
                'manual', false, ...
                'nSeg', 1, ...
                'idx', 1, ...
                'm', m, ...
                'c', c, ...
                'r2', r2, ...
                'r2avg', r2, ...
                'y1', m.*xx + c);
        end

        % Growth-Law initial guess from the overall CSD trend. 
        function [b_init, piece] = computeInitialGuessGrowthLaw(~, x, y_obs, xx)
            x = x(:);
            y_obs = y_obs(:);
            good = isfinite(x) & isfinite(y_obs);
            x = x(good);
            y_obs = y_obs(good);

            if numel(x) < 2
                error("Need at least 2 data points for Growth-Law initialization.");
            end

            [x, ord] = sort(x);
            y_obs = y_obs(ord);

            p = polyfit(x, y_obs, 1);
            m = p(1);
            c = p(2);
            yhat = polyval(p, x);
            ss_res = sum((y_obs - yhat).^2);
            ss_tot = sum((y_obs - mean(y_obs)).^2);
            if ss_tot <= 0
                r2 = NaN;
            else
                r2 = 1 - ss_res/ss_tot;
            end

            n0 = max(exp(c), eps);
            xPositive = x(x > 0 & isfinite(x));
            if isempty(xPositive)
                xScale = max(max(x) - min(x), 1);
            else
                xScale = median(xPositive);
            end
            xScale = max(xScale, eps);

            beta0 = 1.0;
            if isfinite(m) && m < -eps
                % For beta ~ 1, the small-L slope is approximately -2/G0tau0.
                G0tau0 = max(-2 ./ m, eps);
            else
                G0tau0 = xScale;
            end

            b_init = [n0, beta0, G0tau0];
            piece = struct( ...
                'manual', false, ...
                'nSeg', 1, ...
                'idx', 1, ...
                'm', m, ...
                'c', c, ...
                'r2', r2, ...
                'r2avg', r2, ...
                'y1', m.*xx + c);
        end

        % Automatic piecewise initialization for chamber models. 
        function [b_init, piece] = computeInitialGuessPiecewiseN(~, x, y_obs, xx, nSeg)
            if nSeg == 2
                [b_init, piece] = localCompute2(x, y_obs, xx);
            else
                [b_init, piece] = localCompute3(x, y_obs, xx);
            end

            function [b_init, piece] = localCompute2(x, y_obs, xx)
                n = numel(x);
                if n < 6, error("Need at least 6 data points for automatic piecewise initialization."); end
                best = struct('r2avg',-inf,'idx',NaN,'m',[],'c',[],'r2',[]);
                for idx = 3:(n-2)
                    [m1,c1,r21] = localLineFit(x(1:idx), y_obs(1:idx));
                    [m2,c2,r22] = localLineFit(x(idx:n), y_obs(idx:n));
                    r2avg = mean([r21,r22]);
                    if r2avg > best.r2avg
                        best.r2avg = r2avg; best.idx = idx; best.m = [m1 m2]; best.c = [c1 c2]; best.r2 = [r21 r22];
                    end
                end
                b_init = [max(exp(best.c(1)),eps), max(-1/best.m(1),eps), max(exp(best.c(2)),eps), max(-1/best.m(2),eps)];
                piece = struct('manual',false,'nSeg',2,'idx',best.idx,'m',best.m,'c',best.c,'r2',best.r2,'r2avg',best.r2avg,'y1',best.m(1).*xx + best.c(1),'y2',best.m(2).*xx + best.c(2));
            end

            function [b_init, piece] = localCompute3(x, y_obs, xx)
                n = numel(x);
                if n < 9, error("Need at least 9 data points for 3-segment automatic initialization."); end
                best = struct('r2avg',-inf,'idx',[NaN NaN],'m',[],'c',[],'r2',[]);
                for idx1 = 3:(n-4)
                    for idx2 = (idx1+2):(n-2)
                        [m1,c1,r21] = localLineFit(x(1:idx1), y_obs(1:idx1));
                        [m2,c2,r22] = localLineFit(x(idx1+1:idx2), y_obs(idx1+1:idx2));
                        [m3,c3,r23] = localLineFit(x(idx2+1:n), y_obs(idx2+1:n));
                        r2avg = mean([r21,r22,r23]);
                        if r2avg > best.r2avg
                            best.r2avg = r2avg; best.idx = [idx1 idx2]; best.m = [m1 m2 m3]; best.c = [c1 c2 c3]; best.r2 = [r21 r22 r23];
                        end
                    end
                end
                b_init = [max(exp(best.c(1)),eps), max(-1/best.m(1),eps), max(exp(best.c(2)),eps), max(-1/best.m(2),eps), max(exp(best.c(3)),eps), max(-1/best.m(3),eps)];
                piece = struct('manual',false,'nSeg',3,'idx',best.idx,'m',best.m,'c',best.c,'r2',best.r2,'r2avg',best.r2avg,'y1',best.m(1).*xx + best.c(1),'y2',best.m(2).*xx + best.c(2),'y3',best.m(3).*xx + best.c(3));
            end

            function [m,c,r2] = localLineFit(xi, yi)
                p = polyfit(xi, yi, 1);
                m = p(1); c = p(2);
                yhat = polyval(p, xi);
                ss_res = sum((yi - yhat).^2);
                ss_tot = sum((yi - mean(yi)).^2);
                if ss_tot <= 0, r2 = NaN; else, r2 = 1 - ss_res/ss_tot; end
            end
        end

        % Convert manually selected segments into the starting parameters used by the
        % mixing-model solvers.
        function [b_init, piece] = computeInitialGuessPiecewiseManualN(~, x, y_obs, xx, segIdx)
            nSeg = numel(segIdx);
            m = nan(1,nSeg); c = nan(1,nSeg); r2 = nan(1,nSeg);
            for i = 1:nSeg
                idx = unique(segIdx{i}(:));
                if numel(idx) < 2
                    error("Manual piecewise requires >=2 points in each segment.");
                end
                p = polyfit(x(idx), y_obs(idx), 1);
                m(i) = p(1); c(i) = p(2);
                yhat = polyval(p, x(idx));
                r2(i) = 1 - sum((y_obs(idx)-yhat).^2) / max(sum((y_obs(idx)-mean(y_obs(idx))).^2), eps);
            end
            b_init = [];
            for i = 1:nSeg
                b_init = [b_init, max(exp(c(i)),eps), max(-1/m(i),eps)]; 
            end
            piece = struct('manual',true,'nSeg',nSeg,'idx',nan(1,max(1,nSeg-1)),'idxSegments',{segIdx},'m',m,'c',c,'r2',r2,'r2avg',mean(r2));
            for i = 1:nSeg
                piece.(sprintf('y%d',i)) = m(i).*xx + c(i);
                piece.(sprintf('idx%d',i)) = unique(segIdx{i}(:)).';
            end
        end

        %manual piecewise initialization. Segment
        % order follows the data order shown in the figure.
        function segIdx = manualPickSegments(~, x, y, sheet, nSeg)
            n = numel(x);
            sel = false(n,nSeg);
        
            % colors for segments 1, 2, 3
            colors = [
                1.00 0.84 0.00   % yellow
                1.00 0.00 1.00   % magenta
                0.00 1.00 1.00   % cyan
            ];
        
            fig = figure( ...
                "Name","Manual piecewise picks: " + string(sheet), ...
                "Color","w", ...
                "Position",[200 120 950 680]);
        
            ax = axes(fig);
        
            function redraw(currSeg)
                cla(ax);
                hold(ax,'on');
        
                % all points
                scatter(ax, x, y, 140, ...
                    'o', ...
                    'MarkerFaceColor',[0.35 0.35 0.35], ...
                    'MarkerEdgeColor',[0.35 0.35 0.35], ...
                    'LineWidth',1.0);
        
                % selected points by segment
                for k = 1:nSeg
                    if any(sel(:,k))
                        scatter(ax, x(sel(:,k)), y(sel(:,k)), 220, ...
                            'o', ...
                            'MarkerFaceColor', colors(k,:), ...
                            'MarkerEdgeColor', 'k', ...
                            'LineWidth', 1.8);
                    end
                end
        
                % dummy legend handles so legend order stays fixed
                h = gobjects(1, nSeg+1);
                labels = cell(1, nSeg+1);
        
                h(1) = plot(ax, nan, nan, 'o', ...
                    'MarkerFaceColor',[0.35 0.35 0.35], ...
                    'MarkerEdgeColor',[0.35 0.35 0.35], ...
                    'MarkerSize',10, ...
                    'LineStyle','none');
                labels{1} = 'All points';
        
                for k = 1:nSeg
                    h(k+1) = plot(ax, nan, nan, 'o', ...
                        'MarkerFaceColor', colors(k,:), ...
                        'MarkerEdgeColor','k', ...
                        'MarkerSize',10, ...
                        'LineStyle','none');
                    labels{k+1} = sprintf('Segment %d picks', k);
                end
        
                legend(ax, h, labels, 'Location','northeast');
                grid(ax,'on');
                box(ax,'on');
                xlabel(ax,'L (mm)');
                ylabel(ax,'ln(n) mm^{-4}');
        
                title(ax, sprintf('%s | Segment %d active. Click to add/remove points. Press Enter when done.', ...
                    sheet, currSeg));
        
                drawnow;
            end
        
            % pick each segment sequentially
            for s = 1:nSeg
                redraw(s);
        
                while true
                    [xc, yc, btn] = ginput(1);
        
                    % Enter finishes the current segment
                    if isempty(btn)
                        break;
                    end
        
                    [~, j] = min((x - xc).^2 + (y - yc).^2);
        
                    % toggle this point in the active segment only
                    if sel(j,s)
                        sel(j,s) = false;
                    else
                        sel(j,:) = false;   % a point belongs to only one segment
                        sel(j,s) = true;
                    end
        
                    redraw(s);
                    title(ax, sprintf('%s | Segment %d active. %d selected. Press Enter when done.', ...
                        sheet, s, nnz(sel(:,s))));
                end
            end
        
            segIdx = cell(1,nSeg);
            for s = 1:nSeg
                segIdx{s} = find(sel(:,s));
                if numel(segIdx{s}) < 2
                    close(fig);
                    error("Manual selection incomplete for %s. Need >=2 points in each segment.", sheet);
                end
            end
        
            close(fig);
        end

        %exclusion picker. 
        function idx = manualPickExcludePoints(app, x, y, sheet, pre)
            n = numel(x);
            excl = false(n,1);

            if ~isempty(pre)
                pre = unique(pre(:));
                pre = pre(pre>=1 & pre<=n);
                excl(pre) = true;
            end

            fig = figure("Name","Manual exclusions: " + string(sheet), ...
                         "Color","w","Position",[220 180 900 650]);
            ax = axes(fig);
            hold(ax,'on');
            grid(ax,'on'); box(ax,'on');
            xlabel(ax,"L (mm)"); ylabel(ax,"ln(n) mm^{-4}");

            hKeep = scatter(ax, nan, nan, 140, [0.3 0.3 0.3], 'filled');
            hExcl = scatter(ax, nan, nan, 180, 'x', 'LineWidth',2.0, 'MarkerEdgeColor','r');
            legend(ax, [hKeep hExcl], {"Kept points","Excluded points"}, "Location","northeast");

            function redraw()
                keep = ~excl;
                set(hKeep, 'XData', x(keep), 'YData', y(keep));
                if any(excl)
                    set(hExcl, 'XData', x(excl), 'YData', y(excl), 'Visible','on');
                else
                    set(hExcl, 'XData', nan, 'YData', nan, 'Visible','off');
                end
                title(ax, sprintf("%s | Click points to exclude/include. Press Enter when done. Excluded=%d", sheet, nnz(excl)));
                drawnow limitrate;
            end

            redraw();
            while true
                [xc, yc, btn] = ginput(1);
                if isempty(btn)
                    break
                end
                [~, j] = min((x - xc).^2 + (y - yc).^2);
                excl(j) = ~excl(j);
                redraw();
            end

            idx = find(excl);
            close(fig);
        end


        function idx = nearestPointIndices(~, x, y, xg, yg)
            idx = [];
            if isempty(xg); return; end
            for i = 1:numel(xg)
                d2 = (x - xg(i)).^2 + (y - yg(i)).^2;
                [~,k] = min(d2);
                idx(end+1,1) = k; 
            end
            idx = unique(idx);
        end
        function row = buildResultRow(app, result)
            row = { ...
                char(app.getResultDisplayLabel(result, NaN)), char(result.Sheet), char(result.ModelType), char(result.Fit.solver), double(result.Fit.exitflag), ...
                double(result.Fit.rmse), double(result.Fit.r2), double(result.Piecewise.rmse), double(result.alpha1), double(result.alpha2), ...
                app.paramOrNaN(result.b_init,1), app.paramOrNaN(result.b_init,2), app.paramOrNaN(result.b_init,3), app.paramOrNaN(result.b_init,4), app.paramOrNaN(result.b_init,5), app.paramOrNaN(result.b_init,6), ...
                app.paramOrNaN(result.b_fit,1),  app.paramOrNaN(result.b_fit,2),  app.paramOrNaN(result.b_fit,3),  app.paramOrNaN(result.b_fit,4), app.paramOrNaN(result.b_fit,5), app.paramOrNaN(result.b_fit,6), ...
                app.fitStatOrNaN(result,'pValue',1), app.fitStatOrNaN(result,'pValue',2), app.fitStatOrNaN(result,'pValue',3), app.fitStatOrNaN(result,'pValue',4), app.fitStatOrNaN(result,'pValue',5), app.fitStatOrNaN(result,'pValue',6) ...
                };
        end

        function headers = getResultTableHeaders(~)
            headers = { ...
                'Result','Sheet','Model','Solver','Exitflag','fit_RMSE','fit_R2','pw_RMSE','alpha1','alpha2', ...
                'param1_init','param2_init','param3_init','param4_init','param5_init','param6_init', ...
                'param1_fit','param2_fit','param3_fit','param4_fit','param5_fit','param6_fit', ...
                'p1','p2','p3','p4','p5','p6'};
        end

        function v = paramOrNaN(~, b, idx)
            if numel(b) >= idx
                v = double(b(idx));
            else
                v = NaN;
            end
        end

        function v = fitStatOrNaN(~, result, fieldName, idx)
            v = NaN;
            try
                if isfield(result,'Fit') && isfield(result.Fit,'paramStats') && isfield(result.Fit.paramStats,fieldName)
                    arr = result.Fit.paramStats.(fieldName);
                    if numel(arr) >= idx
                        v = double(arr(idx));
                    end
                end
            catch
                v = NaN;
            end
        end

        function v = getOptionalNumericField(~, S, fieldName, defaultValue)
            v = defaultValue;
            try
                if isstruct(S) && isfield(S, fieldName)
                    tmp = S.(fieldName);
                    if isnumeric(tmp) || islogical(tmp)
                        v = double(tmp);
                    end
                end
            catch
                v = defaultValue;
            end
        end

        function v = getOptionalStringField(~, S, fieldName, defaultValue)
            v = string(defaultValue);
            try
                if isstruct(S) && isfield(S, fieldName)
                    tmp = S.(fieldName);
                    if isstring(tmp) || ischar(tmp)
                        v = string(tmp);
                    end
                end
            catch
                v = string(defaultValue);
            end
        end

        function v = getOptionalLogicalField(~, S, fieldName, defaultValue)
            v = logical(defaultValue);
            try
                if isstruct(S) && isfield(S, fieldName)
                    tmp = S.(fieldName);
                    if islogical(tmp)
                        v = tmp;
                    elseif isnumeric(tmp)
                        v = tmp ~= 0;
                    elseif isstring(tmp) || ischar(tmp)
                        v = any(strcmpi(string(tmp), ["true","1","yes","on"]));
                    end
                end
            catch
                v = logical(defaultValue);
            end
        end
    end

    %% ====================== Output Helpers ======================
    methods (Access = private)
        % output helpers 
        function safeName = excelSafeSheetName(~, rawName, resultsFile)
            n = string(rawName);
            n = regexprep(n, '[:\/\?\*\[\]]', '_');
            n = strtrim(n);
            if strlength(n) == 0
                n = "Result";
            end
            if strlength(n) > 31
                n = extractBefore(n, 32);
            end

            existing = string.empty;
            if isfile(resultsFile)
                try
                    existing = string(sheetnames(resultsFile));
                catch
                    existing = string.empty;
                end
            end

            base = n;
            k = 1;
            while any(strcmpi(existing, n))
                suffix = "_" + string(k);
                maxBase = 31 - strlength(suffix);
                b = base;
                if strlength(b) > maxBase
                    b = extractBefore(b, maxBase + 1);
                end
                n = b + suffix;
                k = k + 1;
            end
            safeName = n;
        end

        function safe = safePathName(~, rawName)
            safe = string(rawName);
            safe = regexprep(safe, '[<>:"/\\|?*]', '_');
            safe = strtrim(safe);
            if strlength(safe) == 0
                safe = "Result";
            end
        end

        function tag = getPlotExportTag(app, result)
            sampleName = "Result";
            modelName  = "Model";
            solverName = "Solver";

            try
                sampleName = app.safePathName(result.Sheet);
            catch
            end
            try
                modelName = app.safePathName(result.ModelType);
            catch
            end
            try
                solverName = app.safePathName(result.Fit.solver);
            catch
            end

            tag = sampleName + " - " + modelName + " - " + solverName;
            try
                if isfield(result,'RunNumber') && isfinite(double(result.RunNumber))
                    tag = tag + " - Run" + string(double(result.RunNumber));
                end
            catch
            end
            tag = app.safePathName(tag);
        end

        % Export MCMC trace plots using the full stored chain, including burn-in.
        function saveMCMCTracePlot(app, outDir, plotTag, result)
            samplesTrace = [];
            iterTrace = [];
            try
                if isfield(result,'MCMC') && isfield(result.MCMC,'samplesTrace')
                    samplesTrace = result.MCMC.samplesTrace;
                end
                if isfield(result,'MCMC') && isfield(result.MCMC,'iterTrace')
                    iterTrace = result.MCMC.iterTrace;
                end
            catch
            end
            if isempty(samplesTrace)
                return;
            end
            if isempty(iterTrace) || numel(iterTrace) ~= size(samplesTrace,1)
                iterTrace = (1:size(samplesTrace,1)).';
            end

            names = app.getParamDisplayNames(result.ModelType);
            p = min(size(samplesTrace,2), numel(names));
            if p < 1; return; end

            figH = max(360, 165*p + 120);
            f = figure("Visible","off","Color","w","Position",[100 100 1050 figH]);
            tl = tiledlayout(f, p, 1, 'TileSpacing','compact','Padding','compact'); 
            for jj = 1:p
                ax = nexttile;
                plot(ax, iterTrace(:), samplesTrace(:,jj), '-', 'LineWidth', 0.7);
                ylabel(ax, char(names(jj)), 'Interpreter','none');
                grid(ax,'on'); box(ax,'on');
                if jj == 1
                    title(ax, string(result.Sheet) + " | MCMC trace plots", 'Interpreter','none');
                end
                if jj == p
                    xlabel(ax, 'Iteration');
                else
                    ax.XTickLabel = [];
                end
            end
            exportgraphics(f, fullfile(outDir, plotTag + "_MCMC_TracePlots.png"), "Resolution", 220);
            close(f);
        end

        % Export posterior marginal histograms with mean and MAP markers.
        function saveMCMCMarginalPlot(app, outDir, plotTag, result)
            samplesPost = app.getMCMCPosteriorSamplesForPlot(result);
            if isempty(samplesPost); return; end

            names = app.getParamDisplayNames(result.ModelType);
            latexNames = app.getParamLatexDisplayNames(result.ModelType);
            p = min([size(samplesPost,2), numel(names), numel(latexNames)]);
            if p < 1; return; end

            nCols = ceil(sqrt(p));
            nRows = ceil(p / nCols);
            f = figure("Visible","off","Color","w","Position",[120 120 360*nCols 300*nRows]);
            tiledlayout(f, nRows, nCols, 'TileSpacing','compact','Padding','compact');

            stats = struct();
            if isfield(result,'Fit') && isfield(result.Fit,'paramStats')
                stats = result.Fit.paramStats;
            end
            for jj = 1:p
                ax = nexttile;
                histogram(ax, samplesPost(:,jj), 35);
                hold(ax,'on');
                meanVal = app.getMCMCStatValue(result, stats, 'mean', jj);
                bestVal = app.getMCMCStatValue(result, stats, 'best', jj);

                legHandles = gobjects(0);
                legLabels = {};
                if isfinite(meanVal)
                    hMean = xline(ax, meanVal, '-', 'LineWidth', 1.8, ...
                        'Color', [0.494 0.184 0.556], ...
                        'DisplayName', 'Mean');
                    legHandles(end+1) = hMean; 
                    legLabels{end+1} = 'Mean';
                end
                if isfinite(bestVal)
                    hBest = xline(ax, bestVal, '--', 'LineWidth', 1.8, ...
                        'Color', [0.850 0.325 0.098], ...
                        'DisplayName', 'Best');
                    legHandles(end+1) = hBest;
                    legLabels{end+1} = 'Best'; 
                end

                title(ax, '');
                xlabel(ax, char(latexNames(jj)), 'Interpreter','latex');
                ylabel(ax, 'Count');
                if ~isempty(legHandles)
                    lgd = legend(ax, legHandles, legLabels, 'Location','northeast');
                    try
                        lgd.Box = 'on';
                    catch
                    end
                end
                grid(ax,'on'); box(ax,'on');
                hold(ax,'off');
            end
            exportgraphics(f, fullfile(outDir, plotTag + "_MCMC_PosteriorMarginals.png"), "Resolution", 220);
            close(f);
        end

        % Export pairwise posterior plots for parameter-correlation checks.
        function saveMCMCPairwisePlot(app, outDir, plotTag, result)
            samplesPost = app.getMCMCPosteriorSamplesForPlot(result);
            if isempty(samplesPost); return; end

            latexNames = app.getParamLatexDisplayNames(result.ModelType);
            p = min(size(samplesPost,2), numel(latexNames));
            if p < 2; return; end

            samplesPlot = samplesPost(:,1:p);

            f = figure("Visible","off","Color","w","Position",[140 140 max(750,180*p) max(700,180*p)]);
            tiledlayout(f, p, p, 'TileSpacing','compact','Padding','compact');
            for rr = 1:p
                for cc = 1:p
                    ax = nexttile;
                    if rr == cc
                        histogram(ax, samplesPlot(:,cc), 25);
                    elseif rr > cc
                        scatter(ax, samplesPlot(:,cc), samplesPlot(:,rr), 7, 'filled');
                    else
                        axis(ax,'off');
                        continue;
                    end
                    grid(ax,'on'); box(ax,'on');
                    if rr == p
                        xlabel(ax, char(latexNames(cc)), 'Interpreter','latex');
                    else
                        ax.XTickLabel = [];
                    end
                    if cc == 1 && rr ~= cc
                        ylabel(ax, char(latexNames(rr)), 'Interpreter','latex');
                    elseif cc ~= 1
                        ax.YTickLabel = [];
                    end
                    if rr == 1 && cc == 1
                        title(ax, string(result.Sheet) + " | Pairwise", 'Interpreter','none');
                    end
                end
            end
            exportgraphics(f, fullfile(outDir, plotTag + "_MCMC_Pairwise.png"), "Resolution", 220);
            close(f);
        end

        function samplesPost = getMCMCPosteriorSamplesForPlot(~, result)
            samplesPost = [];
            try
                if isfield(result,'MCMC') && isfield(result.MCMC,'samplesPost') && ~isempty(result.MCMC.samplesPost)
                    samplesPost = result.MCMC.samplesPost;
                end
            catch
                samplesPost = [];
            end
        end

        % Export it and diagnostic plots 
        function savePlotArtifacts(app, cfg, result)
            outRoot = app.getOutputDir(cfg);
            plotTag = app.getPlotExportTag(result);
            outDir  = fullfile(outRoot, plotTag);
            if ~exist(outDir,"dir"); mkdir(outDir); end

            % Model fit figure
            fitXLim = [];
            fitYLim = [];
            f = figure("Visible","off","Color","w","Position",[100 100 950 700]);
            ax = axes(f);
            app.drawFitAxes(ax, {result}, true);
            try
                fitXLim = xlim(ax);
                fitYLim = ylim(ax);
            catch
            end
            title(ax, result.Sheet + " | " + string(result.Fit.solver) + " fit", 'FontSize', 15);
            exportgraphics(f, fullfile(outDir, plotTag + "_ModelFit.png"), "Resolution", 220);
            close(f);

            % Residual figure
            f = figure("Visible","off","Color","w","Position",[120 120 900 500]);
            ax = axes(f); hold(ax,'on');
            bDisplay = app.getDisplayedFitParameters(result);
            yFit = result.Model(bDisplay, result.x);
            resid = result.y_obs - yFit;
            scatter(ax, result.x, resid, 110, 'filled');
            yline(ax, 0, '--k', 'LineWidth', 1.5);
            xlabel(ax,'L (mm)');
            ylabel(ax,'Residual (obs - fit)');
            title(ax, result.Sheet + " | Residuals");
            grid(ax,'on'); box(ax,'on');
            hold(ax,'off');
            exportgraphics(f, fullfile(outDir, plotTag + "_Residuals.png"), "Resolution", 220);
            close(f);

            % diagnostic figure: 
            try
                f = figure("Visible","off","Color","w","Position",[140 140 950 600]);
                ax = axes(f); hold(ax,'on');
                xMax = app.getFitCurveXRight(result.x);
                try
                    if ~isempty(fitXLim) && numel(fitXLim) == 2 && all(isfinite(fitXLim))
                        xMax = max(xMax, fitXLim(2));
                    end
                catch
                end
                xPlot = linspace(0, xMax, 300).';
                bDisplay = app.getDisplayedFitParameters(result);
                comp = app.computeModelComponents(bDisplay, xPlot, result.ModelType, result.alpha1);

                plot(ax, xPlot, comp.totalLn, '-k', 'LineWidth', 2.5, 'DisplayName','Total fit');
                for jj = 1:size(comp.n,2)
                    yj = nan(size(xPlot));
                    mask = comp.n(:,jj) > 0 & isfinite(comp.n(:,jj));
                    yj(mask) = log(comp.n(mask,jj));
                    if any(isfinite(yj))
                        plot(ax, xPlot, yj, '--', 'LineWidth', 1.8, 'DisplayName', char(comp.labels(jj)));
                    end
                end
                scatter(ax, result.x, result.y_obs, 70, 'filled', 'DisplayName','Data');
                xlabel(ax,'L (mm)');
                ylabel(ax,'ln(n) mm^{-4}');
                title(ax, 'Final Fit Decomposition');
                legend(ax,'Location','northeast');
                try
                    if ~isempty(fitXLim) && numel(fitXLim) == 2 && all(isfinite(fitXLim))
                        xlim(ax, fitXLim);
                    end
                    if ~isempty(fitYLim) && numel(fitYLim) == 2 && all(isfinite(fitYLim))
                        ylim(ax, fitYLim);
                    end
                catch
                end
                grid(ax,'on'); box(ax,'on');
                hold(ax,'off');
                exportgraphics(f, fullfile(outDir, plotTag + "_ComponentDiagnostics.png"), "Resolution", 220);
                close(f);
            catch ME_comp
                try
                    app.log("Component diagnostic plot failed: " + string(ME_comp.message));
                catch
                end
            end

            % MCMC-specific diagnostic plots. 
            if app.isMCMCResult(result)
                try
                    app.saveMCMCTracePlot(outDir, plotTag, result);
                catch ME_trace
                    try
                        app.log("MCMC trace plot failed: " + string(ME_trace.message));
                    catch
                    end
                end
                try
                    app.saveMCMCMarginalPlot(outDir, plotTag, result);
                catch ME_marg
                    try
                        app.log("MCMC marginal plot failed: " + string(ME_marg.message));
                    catch
                    end
                end
                try
                    app.saveMCMCPairwisePlot(outDir, plotTag, result);
                catch ME_pair
                    try
                        app.log("MCMC pairwise plot failed: " + string(ME_pair.message));
                    catch
                    end
                end
            end
        end
    end

end
