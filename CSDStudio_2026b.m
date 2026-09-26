classdef CSDStudio_2026b < handle
    % =====================================================================
    % CSDStudio 2026b
    %
    % MATLAB GUI for fitting crystal size distribution (CSD) data using
    % 2-Reservoir, 3-Reservoir, Growth-Law, and Linear CSD models.
    %
    % Noah Hooper and Yan Liang

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
        MaxIterEdit matlab.ui.control.NumericEditField
        FuncTolEdit matlab.ui.control.NumericEditField
        StepTolEdit matlab.ui.control.NumericEditField

        MCMCIterEdit matlab.ui.control.NumericEditField
        MCMCBurnInEdit matlab.ui.control.NumericEditField
        MCMCStepFracEdit matlab.ui.control.NumericEditField
        MCMCNoiseSigmaEdit matlab.ui.control.NumericEditField
        MCMCSeedEdit matlab.ui.control.NumericEditField
        MCMCSeedRandomizeButton matlab.ui.control.Button
        MCMCPerSheetSeedOffsetCheck matlab.ui.control.CheckBox
        MCMCPlotModeDropDown matlab.ui.control.DropDown
        MCMCUncertaintyBandDropDown matlab.ui.control.DropDown

        ModelTypeDropDown matlab.ui.control.DropDown
        Alpha1Edit matlab.ui.control.NumericEditField
        Alpha2Edit matlab.ui.control.NumericEditField

        % Reservoir-model collapsible settings
        ReservoirToggleButton matlab.ui.control.Button
        ReservoirPanel matlab.ui.container.Panel
        ReservoirGrid matlab.ui.container.GridLayout
        ReservoirFixNm0Check matlab.ui.control.CheckBox
        ReservoirLnNm0Edit matlab.ui.control.NumericEditField

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
        StyleShowFitLineCheck matlab.ui.control.CheckBox
        StyleShowMarkersCheck matlab.ui.control.CheckBox

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
        SquarePopOutAxesCheck matlab.ui.control.CheckBox
        PopOutFitButton matlab.ui.control.Button
        FitMetaLabel matlab.ui.control.Label
        ParamStatsPanel matlab.ui.container.Panel
        ParamStatsGrid matlab.ui.container.GridLayout
        ParamStatsLabel matlab.ui.control.Label
        ParamStatsTable matlab.ui.control.Table
        AppendResultsButton matlab.ui.control.Button
        ExportAppendedResultsButton matlab.ui.control.Button
        ExportPlotsButton matlab.ui.control.Button
        ExportPlotDataButton matlab.ui.control.Button

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
        ReservoirOpen logical = false
        GrowthLawOpen logical = false
        AdvancedOpen logical = true
        PlotPanelOpen logical = true
        ShowingSheetPreview logical = false
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
        % Main app builder. build the UI,
        % apply defaults/theme, then load sheets if a workbook is already set.
        function app = CSDStudio_2026b()
            app.buildUI();
            app.setDefaults();
            app.applyModernTheme();
            app.refreshSheetsSafe();
            app.refreshViewSampleList();
            app.updateParamStatsColumnWidths(false);
            app.log("Ready. Version CSDStudio 2026b");
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
                "Name","CSDStudio 2026b", ...
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
                "Items",{'2-Reservoir','3-Reservoir','Growth-Law','Linear'}, ...
                "Value",'2-Reservoir', ...
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

            app.ReservoirToggleButton = uibutton(app.LeftGrid, ...
                "Text","Reservoir settings ▸", ...
                "Enable","off", ...
                "ButtonPushedFcn",@(s,e)app.toggleReservoirPanel());
            app.ReservoirToggleButton.Layout.Row = r; app.ReservoirToggleButton.Layout.Column = [2 3];
            r = r + 1;

            app.ReservoirPanel = uipanel(app.LeftGrid,"Title","Reservoir settings","Visible","off");
            app.ReservoirPanel.Layout.Row = r; app.ReservoirPanel.Layout.Column = [1 3];
            app.ReservoirGrid = uigridlayout(app.ReservoirPanel,[4 2]);
            app.ReservoirGrid.ColumnWidth = {112,'1x'};
            app.ReservoirGrid.RowHeight = {26,26,26,26};
            app.ReservoirGrid.RowSpacing = 6;
            app.ReservoirGrid.Padding = [10 8 10 10];
            lbl = uilabel(app.ReservoirGrid,"Text","w1:","HorizontalAlignment","right");
            lbl.Layout.Row = 1; lbl.Layout.Column = 1;
            app.Alpha1Edit = uieditfield(app.ReservoirGrid,"numeric", ...
                "Limits",[0 1], ...
                "ValueDisplayFormat","%.4g", ...
                "ValueChangedFcn",@(s,e)app.onAlpha1Changed());
            app.Alpha1Edit.Layout.Row = 1; app.Alpha1Edit.Layout.Column = 2;
            lbl = uilabel(app.ReservoirGrid,"Text","w2:","HorizontalAlignment","right");
            lbl.Layout.Row = 2; lbl.Layout.Column = 1;
            app.Alpha2Edit = uieditfield(app.ReservoirGrid,"numeric", ...
                "Editable","off", ...
                "ValueDisplayFormat","%.4g");
            app.Alpha2Edit.Layout.Row = 2; app.Alpha2Edit.Layout.Column = 2;
            app.ReservoirFixNm0Check = uicheckbox(app.ReservoirGrid, ...
                "Text","Fix intercept", ...
                "Value",false, ...
                "ValueChangedFcn",@(s,e)app.onReservoirFixNm0Changed());
            app.ReservoirFixNm0Check.Layout.Row = 3;
            app.ReservoirFixNm0Check.Layout.Column = [1 2];
            lbl = uilabel(app.ReservoirGrid, ...
                "Text", "ln(n_{mix}^{0}):", ...
                "Interpreter", "tex", ...
                "HorizontalAlignment", "right");
            lbl.Layout.Row = 4; lbl.Layout.Column = 1;
            app.ReservoirLnNm0Edit = uieditfield(app.ReservoirGrid,"numeric", ...
                "ValueDisplayFormat","%.6g", ...
                "Enable","off");
            app.ReservoirLnNm0Edit.Layout.Row = 4; app.ReservoirLnNm0Edit.Layout.Column = 2;
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
                "Text","NL solver options ▸", ...
                "ButtonPushedFcn",@(s,e)app.toggleNLSolverPanel());
            app.SolverToggleButton.Layout.Row = r; app.SolverToggleButton.Layout.Column = [2 3];
            r = r + 1;

            app.SolverPanel = uipanel(app.LeftGrid,"Title","NL solver options","Visible","off");
            app.SolverPanel.Layout.Row = r; app.SolverPanel.Layout.Column = [1 3];
            app.SolverPanel.Scrollable = 'off';
            app.SolverGrid = uigridlayout(app.SolverPanel,[3 2]);
            app.SolverGrid.ColumnWidth = {118,'1x'};
            app.SolverGrid.RowHeight = repmat({26},1,3);
            app.SolverGrid.RowSpacing = 6;
            app.SolverGrid.Padding = [10 8 10 10];
            lbl = uilabel(app.SolverGrid,"Text","NL max iter:","HorizontalAlignment","right");
            lbl.Layout.Row = 1; lbl.Layout.Column = 1;
            app.MaxIterEdit = uieditfield(app.SolverGrid,"numeric","Limits",[1 inf],"RoundFractionalValues","on");
            app.MaxIterEdit.Layout.Row = 1; app.MaxIterEdit.Layout.Column = 2;
            lbl = uilabel(app.SolverGrid,"Text","NL func tol:","HorizontalAlignment","right");
            lbl.Layout.Row = 2; lbl.Layout.Column = 1;
            app.FuncTolEdit = uieditfield(app.SolverGrid,"numeric","Limits",[0 inf],"ValueDisplayFormat","%.4g");
            app.FuncTolEdit.Layout.Row = 2; app.FuncTolEdit.Layout.Column = 2;
            lbl = uilabel(app.SolverGrid,"Text","NL step tol:","HorizontalAlignment","right");
            lbl.Layout.Row = 3; lbl.Layout.Column = 1;
            app.StepTolEdit = uieditfield(app.SolverGrid,"numeric","Limits",[0 inf],"ValueDisplayFormat","%.4g");
            app.StepTolEdit.Layout.Row = 3; app.StepTolEdit.Layout.Column = 2;
            r = r + 1;

            app.MCMCSolverToggleButton = uibutton(app.LeftGrid, ...
                "Text","MCMC solver options ▸", ...
                "Enable","off", ...
                "ButtonPushedFcn",@(s,e)app.toggleMCMCSolverPanel());
            app.MCMCSolverToggleButton.Layout.Row = r; app.MCMCSolverToggleButton.Layout.Column = [2 3];
            r = r + 1;

            app.MCMCSolverPanel = uipanel(app.LeftGrid,"Title","MCMC solver options","Visible","off");
            app.MCMCSolverPanel.Layout.Row = r; app.MCMCSolverPanel.Layout.Column = [1 3];
            app.MCMCSolverPanel.Scrollable = 'off';
            app.MCMCSolverGrid = uigridlayout(app.MCMCSolverPanel,[7 2]);
            app.MCMCSolverGrid.ColumnWidth = {118,'1x'};
            app.MCMCSolverGrid.RowHeight = repmat({26},1,7);
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
            lbl = uilabel(app.MCMCSolverGrid, ...
                "Text","Initial step frac:", ...
                "HorizontalAlignment","right");
            lbl.Layout.Row = 3; lbl.Layout.Column = 1;
            app.MCMCStepFracEdit = uieditfield(app.MCMCSolverGrid,"numeric", ...
                "Limits",[1e-6 10], ...
                "ValueDisplayFormat","%.4g");
            app.MCMCStepFracEdit.Layout.Row = 3; app.MCMCStepFracEdit.Layout.Column = 2;
            lbl = uilabel(app.MCMCSolverGrid, ...
                "Text","Obs. σ in ln(n):", ...
                "HorizontalAlignment","right");
            lbl.Layout.Row = 4; lbl.Layout.Column = 1;
            app.MCMCNoiseSigmaEdit = uieditfield(app.MCMCSolverGrid,"numeric", ...
                "Limits",[1e-12 inf], ...
                "ValueDisplayFormat","%.4g");
            app.MCMCNoiseSigmaEdit.Layout.Row = 4; app.MCMCNoiseSigmaEdit.Layout.Column = 2;
            lbl = uilabel(app.MCMCSolverGrid,"Text","MCMC seed:","HorizontalAlignment","right");
            lbl.Layout.Row = 5; lbl.Layout.Column = 1;
            app.MCMCSeedEdit = uieditfield(app.MCMCSolverGrid,"numeric","Limits",[0 2^31-1],"RoundFractionalValues","on");
            app.MCMCSeedEdit.Layout.Row = 5; app.MCMCSeedEdit.Layout.Column = 2;
            app.MCMCSeedRandomizeButton = uibutton(app.MCMCSolverGrid, ...
                "Text","Randomize MCMC seed", ...
                "ButtonPushedFcn",@(s,e)app.randomizeMCMCSeed());
            app.MCMCSeedRandomizeButton.Layout.Row = 6; app.MCMCSeedRandomizeButton.Layout.Column = [1 2];
            app.MCMCPerSheetSeedOffsetCheck = uicheckbox(app.MCMCSolverGrid, ...
                "Text","Offset seed per sheet", ...
                "Value",true);
            app.MCMCPerSheetSeedOffsetCheck.Layout.Row = 7; app.MCMCPerSheetSeedOffsetCheck.Layout.Column = [1 2];
            r = r + 1;

            hdr = uilabel(app.LeftGrid,"Text","Model Initialization and Data Exclusion","FontWeight","bold","HorizontalAlignment","left");
            hdr.Layout.Row = r; hdr.Layout.Column = [1 3]; r = r + 1;

            app.ManualPiecewiseCheck = uicheckbox(app.LeftGrid, ...
                "Text","Manual piecewise initialization", ...
                "Value",false, ...
                "ValueChangedFcn",@(s,e)app.onManualPiecewiseChanged());
            app.ManualPiecewiseCheck.Layout.Row = r; app.ManualPiecewiseCheck.Layout.Column = [2 3];
            r = r + 1;

            app.ExcludePointsCheck = uicheckbox(app.LeftGrid, ...
                "Text","Exclude points ", ...
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
            actionGrid.RowHeight = {28,28,28,28};
            actionGrid.ColumnWidth = {'1x'};
            actionGrid.RowSpacing = 6;
            actionGrid.Padding = [0 0 0 0];
            app.AppendResultsButton = uibutton(actionGrid, ...
                "Text","Append to results", ...
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
            app.ExportPlotDataButton = uibutton(actionGrid, ...
                "Text","Export plot data", ...
                "ButtonPushedFcn",@(s,e)app.exportPlotDataPressed());
            app.ExportPlotDataButton.Layout.Row = 4;
            app.ExportPlotDataButton.Layout.Column = 1;

            app.ParamStatsTable.ColumnEditable = false;
            app.ParamStatsTable.ColumnName = {'Sample','Parameter','Best Fit','SE','95% Low','95% High','p-value'};
            app.ParamStatsTable.ColumnWidth = {220,240,135,120,135,135,120};
            app.ParamStatsTable.Data = {};
            app.ParamStatsTable.Visible = 'off';
            app.ParamStatsLabel.Text = "Complete a run to show fitted parameters.";
            app.updateParamStatsColumnWidths(false);

            topPanel = uipanel(fitTabGrid,"Title","Fit View");
            topPanel.Layout.Row = 2;
            topPanel.Layout.Column = 1;
            fitViewGrid = uigridlayout(topPanel,[1 7]);
            fitViewGrid.ColumnWidth = {55,260,90,150,'1x',110,130};
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
            app.SquarePopOutAxesCheck = uicheckbox(fitViewGrid, ...
                "Text","Square axis", ...
                "Value",false, ...
                "ValueChangedFcn",@(s,e)app.onPopOutSquareChanged());
            app.SquarePopOutAxesCheck.Layout.Row = 1;
            app.SquarePopOutAxesCheck.Layout.Column = 6;
            app.PopOutFitButton = uibutton(fitViewGrid, ...
                "Text","Pop out", ...
                "ButtonPushedFcn",@(s,e)app.popOutFitPressed());
            app.PopOutFitButton.Layout.Row = 1;
            app.PopOutFitButton.Layout.Column = 7;

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
                22,28,28,28,28,28,28,28,28,28, ... % marker/sample
                22,28,28,28,28,28, ...          % line/fit
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
                "ValueChangedFcn",@(s,e)app.onStyleControlChanged(s));
            app.StyleDisplayNameEdit.Layout.Row = r; app.StyleDisplayNameEdit.Layout.Column = 2; r = r + 1;
            lbl = uilabel(app.AdvancedGrid,"Text","Marker face:","HorizontalAlignment","right");
            lbl.Layout.Row = r; lbl.Layout.Column = 1;
            app.StyleMarkerFaceColorEdit = uieditfield(app.AdvancedGrid,"text", ...
                "ValueChangedFcn",@(s,e)app.onStyleControlChanged(s));
            app.StyleMarkerFaceColorEdit.Layout.Row = r; app.StyleMarkerFaceColorEdit.Layout.Column = 2; r = r + 1;
            lbl = uilabel(app.AdvancedGrid,"Text","Marker edge:","HorizontalAlignment","right");
            lbl.Layout.Row = r; lbl.Layout.Column = 1;
            app.StyleMarkerEdgeColorEdit = uieditfield(app.AdvancedGrid,"text", ...
                "ValueChangedFcn",@(s,e)app.onStyleControlChanged(s));
            app.StyleMarkerEdgeColorEdit.Layout.Row = r; app.StyleMarkerEdgeColorEdit.Layout.Column = 2; r = r + 1;
            lbl = uilabel(app.AdvancedGrid,"Text","Marker size:","HorizontalAlignment","right");
            lbl.Layout.Row = r; lbl.Layout.Column = 1;
            app.StyleMarkerSizeEdit = uieditfield(app.AdvancedGrid,"numeric", ...
                "Limits",[1 inf], ...
                "ValueChangedFcn",@(s,e)app.onStyleControlChanged(s));
            app.StyleMarkerSizeEdit.Layout.Row = r; app.StyleMarkerSizeEdit.Layout.Column = 2; r = r + 1;
            lbl = uilabel(app.AdvancedGrid,"Text","Marker shape:","HorizontalAlignment","right");
            lbl.Layout.Row = r; lbl.Layout.Column = 1;
            app.StyleMarkerShapeDropDown = uidropdown(app.AdvancedGrid, ...
                "Items",{'o','s','d','^','v','>','<','p','h','x','+','*'}, ...
                "Value",'o', ...
                "ValueChangedFcn",@(s,e)app.onStyleControlChanged(s));
            app.StyleMarkerShapeDropDown.Layout.Row = r; app.StyleMarkerShapeDropDown.Layout.Column = 2; r = r + 1;
            app.StyleShowFitLineCheck = uicheckbox(app.AdvancedGrid, ...
                "Text","Show fit", ...
                "Value",true, ...
                "ValueChangedFcn",@(s,e)app.onStyleControlChanged(s));
            app.StyleShowFitLineCheck.Layout.Row = r; app.StyleShowFitLineCheck.Layout.Column = [1 2]; r = r + 1;
            app.StyleShowMarkersCheck = uicheckbox(app.AdvancedGrid, ...
                "Text","Show markers", ...
                "Value",true, ...
                "ValueChangedFcn",@(s,e)app.onStyleControlChanged(s));
            app.StyleShowMarkersCheck.Layout.Row = r; app.StyleShowMarkersCheck.Layout.Column = [1 2]; r = r + 1;
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
                "ValueChangedFcn",@(s,e)app.onStyleControlChanged(s));
            app.StyleLineColorEdit.Layout.Row = r; app.StyleLineColorEdit.Layout.Column = 2; r = r + 1;
            lbl = uilabel(app.AdvancedGrid,"Text","Line width:","HorizontalAlignment","right");
            lbl.Layout.Row = r; lbl.Layout.Column = 1;
            app.StyleLineWidthEdit = uieditfield(app.AdvancedGrid,"numeric", ...
                "Limits",[0.1 inf], ...
                "ValueChangedFcn",@(s,e)app.onStyleControlChanged(s));
            app.StyleLineWidthEdit.Layout.Row = r; app.StyleLineWidthEdit.Layout.Column = 2; r = r + 1;
            lbl = uilabel(app.AdvancedGrid,"Text","Line style:","HorizontalAlignment","right");
            lbl.Layout.Row = r; lbl.Layout.Column = 1;
            app.StyleLineStyleDropDown = uidropdown(app.AdvancedGrid, ...
                "Items",{'-','--',':','-.'}, ...
                "Value",'-', ...
                "ValueChangedFcn",@(s,e)app.onStyleControlChanged(s));
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
            hdr = uilabel(app.AdvancedGrid,"Text","MCMC Display","FontWeight","bold","HorizontalAlignment","left");
            hdr.Layout.Row = r; hdr.Layout.Column = [1 2]; r = r + 1;

            lbl = uilabel(app.AdvancedGrid,"Text","MCMC line:","HorizontalAlignment","right");
            lbl.Layout.Row = r; lbl.Layout.Column = 1;
            app.MCMCPlotModeDropDown = uidropdown(app.AdvancedGrid, ...
                "Items",{'Best fit (MAP)','Mean','Both'}, ...
                "Value",'Best fit (MAP)', ...
                "ValueChangedFcn",@(s,e)app.onMCMCPlotModeChanged());
            app.MCMCPlotModeDropDown.Layout.Row = r; app.MCMCPlotModeDropDown.Layout.Column = 2; r = r + 1;
            lbl = uilabel(app.AdvancedGrid,"Text","Uncertainty band:","HorizontalAlignment","right");
            lbl.Layout.Row = r; lbl.Layout.Column = 1;
            app.MCMCUncertaintyBandDropDown = uidropdown(app.AdvancedGrid, ...
                "Items",{'None','95% Uncertainty'}, ...
                "Value",'None', ...
                "Enable","off", ...
                "ValueChangedFcn",@(s,e)app.onAxisControlChanged());
            app.MCMCUncertaintyBandDropDown.Layout.Row = r; app.MCMCUncertaintyBandDropDown.Layout.Column = 2;
        end


        % Default states
        function setDefaults(app)
            app.DataFileEdit.Value = "";
            app.ResultsDirEdit.Value = pwd;

            app.OutputFolderEdit.Value = "CSDStudio_Output";

            app.SampleModeDropDown.Value = "Single sheet";
            app.FitOverlayCheck.Value = false;
            app.SquarePopOutAxesCheck.Value = false;
            app.OverlaySelection = string.empty;
            app.OverlaySummaryLabel.Text = "";
            app.OverlaySelectButton.Enable = "off";

            app.SolverDropDown.Value = "NL Inversion";
            app.MaxIterEdit.Value = 10000;
            app.FuncTolEdit.Value = 1e-10;
            app.StepTolEdit.Value = 1e-10;

            app.MCMCIterEdit.Value = 100000;
            app.MCMCBurnInEdit.Value = 10000;
            app.MCMCStepFracEdit.Value = 0.03;
            app.MCMCNoiseSigmaEdit.Value = 0.1;
            app.MCMCSeedEdit.Value = 12345;
            app.MCMCPerSheetSeedOffsetCheck.Value = true;
            app.MCMCPlotModeDropDown.Value = 'Best fit (MAP)';
            app.MCMCUncertaintyBandDropDown.Value = 'None';
            app.MCMCUncertaintyBandDropDown.Enable = 'off';

            app.ModelTypeDropDown.Value = "2-Reservoir";
            app.Alpha1Edit.Value = 0.5;
            app.Alpha2Edit.Value = 0.5;
            app.ReservoirFixNm0Check.Value = false;
            app.ReservoirLnNm0Edit.Value = 0;
            app.ReservoirLnNm0Edit.Enable = "off";
            app.GrowthLawFixN0Check.Value = false;
            app.GrowthLawLnN0Edit.Value = 0;
            app.GrowthLawLnN0Edit.Enable = "off";

            app.GridOnCheck.Value = true;

            app.StyleShowFitLineCheck.Value = true;
            app.StyleShowMarkersCheck.Value = true;

            app.ClipXCheck.Value = false;
            app.XMinEdit.Value = 0;
            app.XMaxEdit.Value = 1;

            app.ClipYCheck.Value = false;
            app.YMinEdit.Value = -20;
            app.YMaxEdit.Value = 20;

            app.ExtendFitCheck.Value = false;
            app.FitXMaxEdit.Value = 1;

            app.RunSheetSelection = string.empty;
            app.CombinedSheetSelection = string.empty;
            
            app.RunSheetSelectButton.Enable = "off";
            app.CombineSheetSelectButton.Enable = "off";

            app.UseDataDirCheck.Value = true;
            app.onUseDataDirChanged();
            app.onModeChanged();

            app.ManualPiecewiseCheck.Value = false;

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
            app.ShowingSheetPreview = false;
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
            styleSecondaryButton(app.ExportPlotDataButton);
            styleNeutralButton(app.SolverToggleButton);
            styleNeutralButton(app.MCMCSolverToggleButton);
            styleNeutralButton(app.ReservoirToggleButton);
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
            app.previewSelectedSheet();
        end

        function updateExcludeButtonText(app)
            try
                % Keep the exclusion control label identical in every run mode.
                app.PickExcludeButton.Text = "Pick exclusions";
                app.ClearExcludeButton.Text = "Clear";
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

            is3 = strcmp(modelType, "3-Reservoir");
            isReservoir = any(strcmp(modelType,["2-Reservoir","3-Reservoir"]));
            isGrowth = strcmp(modelType, "Growth-Law");
            isLinear = strcmp(modelType, "Linear");

            % The Linear model is NL-only. 
            try
                if isLinear
                    app.SolverDropDown.Items = {'NL Inversion'};
                    app.SolverDropDown.Value = 'NL Inversion';
                else
                    app.SolverDropDown.Items = {'NL Inversion','MCMC Inversion'};
                    if ~any(strcmp(app.SolverDropDown.Items, char(app.SolverDropDown.Value)))
                        app.SolverDropDown.Value = 'NL Inversion';
                    end
                end
            catch
            end

            % Reservoir settings are available for both reservoir models. The
            % alpha controls remain specific to the three-reservoir model.
            try
                app.ReservoirToggleButton.Enable = ternaryOnOff(isReservoir);
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
            if ~isReservoir
                try
                    app.ReservoirOpen = false;
                    app.ReservoirToggleButton.Text = "Reservoir settings ▸";
                    app.ReservoirPanel.Visible = "off";
                    app.ReservoirPanel.Parent.RowHeight{app.ReservoirPanel.Layout.Row} = 1;
                catch
                end
            end
            if ~is3
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
            app.onReservoirFixNm0Changed();

            % Manual piecewise is only meaningful for 2 or 3 reservoir models
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
            elseif any(strcmp(s, ["3 reservoir", "3reservoir", "three reservoir", "3 reservoir model"]))
                modelType = "3-Reservoir";
            else
                modelType = "2-Reservoir";
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
                app.MCMCPerSheetSeedOffsetCheck.Enable = mcmcEnable;
            catch
            end
            try
                app.MCMCPlotModeDropDown.Enable = mcmcEnable;
            catch
            end
            try
                if isMCMC && any(strcmp(string(app.MCMCPlotModeDropDown.Value), ["Mean","Both"]))
                    app.MCMCUncertaintyBandDropDown.Enable = 'on';
                else
                    app.MCMCUncertaintyBandDropDown.Enable = 'off';
                end
            catch
            end

            app.onReservoirFixNm0Changed();

            try
                if isempty(app.RunResults)
                    app.updateParamStatsView([]);
                end
            catch
            end

            if isMCMC
                app.log("Solver set to MCMC Inversion. MCMC solver options are active; NL solver options are disabled.");
            else
                app.log("Solver set to NL Inversion. NL solver options are active; MCMC solver options are disabled.");
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

        function onReservoirFixNm0Changed(app)
            try
                modelType = app.normalizeModelType(string(app.ModelTypeDropDown.Value));
                isReservoir = any(strcmp(modelType,["2-Reservoir","3-Reservoir"]));
                if isReservoir
                    app.ReservoirFixNm0Check.Enable = 'on';
                else
                    app.ReservoirFixNm0Check.Enable = 'off';
                end
                if isReservoir && app.ReservoirFixNm0Check.Value
                    app.ReservoirLnNm0Edit.Enable = 'on';
                else
                    app.ReservoirLnNm0Edit.Enable = 'off';
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
                app.SolverToggleButton.Text = "NL solver options ▾";
                app.SolverPanel.Visible = "on";
                app.SolverPanel.Parent.RowHeight{row} = 140;
            else
                app.closeNLSolverPanel();
            end
        end

        function closeNLSolverPanel(app)
            try
                app.SolverOpen = false;
                app.SolverToggleButton.Text = "NL solver options ▸";
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
                app.MCMCSolverToggleButton.Text = "MCMC solver options ▾";
                app.MCMCSolverPanel.Visible = "on";
                app.MCMCSolverPanel.Parent.RowHeight{row} = 270;
            else
                app.closeMCMCSolverPanel();
            end
        end

        function closeMCMCSolverPanel(app)
            try
                app.MCMCSolverOpen = false;
                app.MCMCSolverToggleButton.Text = "MCMC solver options ▸";
                app.MCMCSolverPanel.Visible = "off";
                app.MCMCSolverPanel.Parent.RowHeight{app.MCMCSolverPanel.Layout.Row} = 1;
            catch
            end
        end

        function toggleReservoirPanel(app)
            if strcmp(app.ReservoirToggleButton.Enable, 'off')
                return;
            end
            app.ReservoirOpen = ~app.ReservoirOpen;
            row = app.ReservoirPanel.Layout.Row;

            if app.ReservoirOpen
                app.ReservoirToggleButton.Text = "Reservoir settings ▾";
                app.ReservoirPanel.Visible = "on";
                app.ReservoirPanel.Parent.RowHeight{row} = 170;
            else
                app.ReservoirOpen = false;
                app.ReservoirToggleButton.Text = "Reservoir settings ▸";
                app.ReservoirPanel.Visible = "off";
                app.ReservoirPanel.Parent.RowHeight{row} = 1;
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
                if app.ShowingSheetPreview
                    app.previewSelectedSheet();
                elseif app.ViewSampleDropDown.Enable == "on" && ~strcmp(app.ViewSampleDropDown.Value,'(no results yet)')
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
                if strcmp(app.normalizeSolverType(string(app.SolverDropDown.Value)), "MCMC") && ...
                        any(strcmp(string(app.MCMCPlotModeDropDown.Value), ["Mean","Both"]))
                    app.MCMCUncertaintyBandDropDown.Enable = 'on';
                else
                    app.MCMCUncertaintyBandDropDown.Enable = 'off';
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
                xRight = 1.05 .* xBase;
            else
                if isempty(xData)
                    span = 1;
                else
                    span = max(xData) - min(xData);
                end
                scale = max([abs(xBase), abs(span), 1]);
                xRight = xBase + 0.05 .* scale;
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

        function applyModelFitAxisControls(app, ax, results)
         
            app.applyAxisControls(ax);
            if app.ClipXCheck.Value || isempty(results)
                return;
            end

            allX = zeros(0,1);
            for ii = 1:numel(results)
                r = results{ii};
                if isfield(r,'IsCombined') && r.IsCombined && isfield(r,'Components')
                    for jj = 1:numel(r.Components)
                        part = r.Components(jj);
                        if isfield(part,'x'); allX = [allX; double(part.x(:))]; end  
                        if isfield(part,'x_excl'); allX = [allX; double(part.x_excl(:))]; end 
                    end
                else
                    if isfield(r,'x'); allX = [allX; double(r.x(:))]; end 
                    if isfield(r,'Exclusions') && isfield(r.Exclusions,'x_excl')
                        allX = [allX; double(r.Exclusions.x_excl(:))]; 
                    end
                end
            end

            allX = allX(isfinite(allX));
            if isempty(allX)
                return;
            end

            xOrigin = min(0, min(allX));
            totalL = max(allX) - xOrigin;
            if ~isfinite(totalL) || totalL <= 0
                totalL = max([abs(allX); 1]);
            end

            currentLimits = xlim(ax);
            xLeft = xOrigin - 0.03 .* totalL;
            if isfinite(xLeft) && isfinite(currentLimits(2)) && xLeft < currentLimits(2)
                xlim(ax, [xLeft currentLimits(2)]);
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
            app.ShowingSheetPreview = false;
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
                app.ReservoirOpen = false;
                app.ReservoirToggleButton.Text = "Reservoir settings ▸";
                app.ReservoirPanel.Visible = "off";
                app.ReservoirPanel.Parent.RowHeight{app.ReservoirPanel.Layout.Row} = 1;
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
            mode = string(app.SampleModeDropDown.Value);
            if mode == "Combine sheets"
                app.previewCombinedSheets();
                return;
            elseif mode ~= "Single sheet"
                return;
            end

            try
                sheet = string(app.SheetDropDown.Value);
                useExcl = logical(app.ExcludePointsCheck.Value);
                [x,y,idxExcl,rawN] = app.readSheetXY(string(app.DataFileEdit.Value), sheet, useExcl);

                % Enter an  preview state so later 
                % callbacks do not redraw a previously selected run.
                app.ShowingSheetPreview = true;
                app.FitOverlayCheck.Value = false;
                app.OverlaySelection = string.empty;
                app.updateOverlaySummary();

                % Fully reset the axes. 
                try
                    legend(app.FitAxes,'off');
                catch
                end
                try
                    delete(app.FitAxes.Children);
                catch
                end
                cla(app.FitAxes,'reset');
                hold(app.FitAxes,'off');
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
                app.FitMetaLabel.Text = "Sheet preview: " + sheet;
                drawnow;
            catch ME
                app.log("Preview failed: " + ME.message);
            end
        end

        function previewCombinedSheets(app)
            try
                sheets = string(app.CombinedSheetSelection(:)).';
                sheets = sheets(strlength(sheets) > 0);

                % Enter preview state and clear any loaded plot.
                app.ShowingSheetPreview = true;
                app.FitOverlayCheck.Value = false;
                app.OverlaySelection = string.empty;
                app.updateOverlaySummary();
                try
                    legend(app.FitAxes,'off');
                catch
                end
                try
                    delete(app.FitAxes.Children);
                catch
                end
                cla(app.FitAxes,'reset');

                if isempty(sheets)
                    xlabel(app.FitAxes,'L (mm)');
                    ylabel(app.FitAxes,'ln(n) mm^{-4}');
                    title(app.FitAxes,'Choose combined sheets to preview');
                    box(app.FitAxes,'on');
                    app.applyGridState(app.FitAxes);
                    app.applyAxisControls(app.FitAxes);
                    app.FitMetaLabel.Text = "Combined-sheet preview: no sheets selected";
                    drawnow;
                    return;
                end

                hold(app.FitAxes,'on');
                legHandles = gobjects(0);
                legLabels = {};
                totalUsed = 0;
                totalRaw = 0;
                totalExcluded = 0;
                useExcl = logical(app.ExcludePointsCheck.Value);

                for ii = 1:numel(sheets)
                    sheet = sheets(ii);
                    [x,y,idxExcl,rawN] = app.readSheetXY( ...
                        string(app.DataFileEdit.Value), sheet, useExcl);
                    sty = app.getSamplePlotStyle("Component: " + sheet);
                    mf = app.parsePlotColor(sty.MarkerFaceColor, 'y');
                    me = app.parsePlotColor(sty.MarkerEdgeColor, 'b');

                    dataLabel = string(sty.DisplayName);
                    if strlength(strtrim(dataLabel)) == 0
                        dataLabel = app.makeLegendDataLabel(sheet);
                    end

                    h = scatter(app.FitAxes, x, y, sty.MarkerSize, ...
                        sty.MarkerShape, ...
                        'MarkerFaceColor',mf, ...
                        'MarkerEdgeColor',me, ...
                        'LineWidth',2.0);
                    legHandles(end+1) = h;
                    legLabels{end+1} = char(dataLabel);

                    if useExcl && ~isempty(idxExcl)
                        [xRaw,yRaw] = app.readSheetXYRaw( ...
                            string(app.DataFileEdit.Value), sheet);
                        idxExcl = idxExcl(:);
                        idxExcl = idxExcl(idxExcl >= 1 & idxExcl <= numel(xRaw));
                        scatter(app.FitAxes, xRaw(idxExcl), yRaw(idxExcl), ...
                            max(60,0.45*sty.MarkerSize), sty.MarkerShape, ...
                            'MarkerFaceColor',[0.72 0.72 0.72], ...
                            'MarkerEdgeColor',[0.45 0.45 0.45], ...
                            'LineWidth',1.2, ...
                            'HandleVisibility','off');
                    end

                    totalUsed = totalUsed + numel(x);
                    totalRaw = totalRaw + rawN;
                    totalExcluded = totalExcluded + numel(idxExcl);
                end

                if ~isempty(legHandles)
                    legend(app.FitAxes,legHandles,legLabels,'Location','northeast');
                end
                if useExcl
                    title(app.FitAxes,sprintf( ...
                        'Preview: %d combined sheets | used=%d / raw=%d (excluded=%d)', ...
                        numel(sheets),totalUsed,totalRaw,totalExcluded));
                else
                    title(app.FitAxes,sprintf( ...
                        'Preview: %d combined sheets | raw=%d',numel(sheets),totalRaw));
                end
                xlabel(app.FitAxes,'L (mm)');
                ylabel(app.FitAxes,'ln(n) mm^{-4}');
                box(app.FitAxes,'on');
                app.applyGridState(app.FitAxes);
                app.applyAxisControls(app.FitAxes);
                hold(app.FitAxes,'off');
                app.FitMetaLabel.Text = sprintf( ...
                    'Combined-sheet preview: %d sheets, %d plotted points', ...
                    numel(sheets),totalUsed);
                drawnow;
            catch ME
                try
                    hold(app.FitAxes,'off');
                catch
                end
                app.log("Combined-sheet preview failed: " + string(ME.message));
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

                % global editor so exclusions can be
                % picked from all sheets on one shared plot.
                mode = string(app.SampleModeDropDown.Value);
                if mode == "Combine sheets" && numel(sheets) > 1
                    [action, sheetsPicked] = app.chooseCombineExclusionEditMode(sheets);
                    if action == "cancel"
                        app.log("Exclusion picking canceled.");
                        return;
                    elseif action == "global"
                        app.manualPickGlobalExcludePoints(sheets);
                        app.previewSelectedSheet();
                        return;
                    else
                        sheets = sheetsPicked;
                    end
                else
                    sheets = app.chooseExclusionEditSheets(sheets, "Choose sheets for exclusion picking");
                end

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

            % Keep only valid workbook sheets and preserve workbook/order
            if ~isempty(sheets) && ~isempty(app.SheetNames)
                valid = ismember(sheets, app.SheetNames);
                sheets = sheets(valid);
                [~, ia] = unique(cellstr(sheets), 'stable');
                sheets = sheets(sort(ia));
            end
        end

        function [action, sheetsOut] = chooseCombineExclusionEditMode(app, sheetsIn)
            sheetsIn = string(sheetsIn(:)).';
            sheetsIn = sheetsIn(strlength(sheetsIn) > 0);
            sheetsOut = string.empty;
            action = "cancel";
            if isempty(sheetsIn)
                return;
            end
            if isscalar(sheetsIn)
                action = "selected";
                sheetsOut = sheetsIn;
                return;
            end

            items = cellstr(sheetsIn);
            globalChosen = false;
            injector = [];

        
            try
                injector = timer( ...
                    'ExecutionMode','fixedSpacing', ...
                    'Period',0.05, ...
                    'StartDelay',0.05, ...
                    'TimerFcn',@injectGlobalButton);
                start(injector);
            catch
                injector = [];
            end

            [idx, ok] = listdlg( ...
                'ListString', items, ...
                'SelectionMode', 'multiple', ...
                'InitialValue', 1:numel(items), ...
                'ListSize', [420 300], ...
                'PromptString', {'Choose sheets for exclusion picking', ...
                    'The exclusion editor will open one sheet at a time.'});

            try
                if ~isempty(injector) && isvalid(injector)
                    stop(injector);
                    delete(injector);
                end
            catch
            end

            if globalChosen
                action = "global";
                sheetsOut = sheetsIn;
            elseif ~ok || isempty(idx)
                action = "cancel";
                sheetsOut = string.empty;
            else
                action = "selected";
                sheetsOut = string(items(idx));
            end

            function injectGlobalButton(~,~)
               
                figs = findall(groot,'Type','figure');
                for ff = reshape(figs,1,[])
                    try
                        if ~isvalid(ff) || isappdata(ff,'CSDStudioGlobalExclusionButton')
                            continue;
                        end
                        buttons = findall(ff,'Type','uicontrol','Style','pushbutton');
                        selectAll = gobjects(0);
                        for bb = 1:numel(buttons)
                            try
                                if strcmpi(strtrim(string(get(buttons(bb),'String'))),"Select all")
                                    selectAll = buttons(bb);
                                    break;
                                end
                            catch
                            end
                        end
                        listBox = findall(ff,'Type','uicontrol','Style','listbox');
                        if isempty(selectAll) || isempty(listBox)
                            continue;
                        end

                        % Make sure this is the chooser we just opened.
                        listStrings = string(get(listBox(1),'String'));
                        if numel(listStrings) ~= numel(items)
                            continue;
                        end

                        setappdata(ff,'CSDStudioGlobalExclusionButton',true);

       
                        oldFigUnits = ff.Units;
                        ff.Units = 'pixels';
                        figPos = ff.Position;
                        
                       
                        oldResizeFcn = [];
                        try
                            oldResizeFcn = ff.ResizeFcn;
                            ff.ResizeFcn = [];
                        catch
                        end
                        
                        oldSizeChangedFcn = [];
                        try
                            oldSizeChangedFcn = ff.SizeChangedFcn;
                            ff.SizeChangedFcn = [];
                        catch
                        end
                        
                 
                        kids = findall(ff,'Type','uicontrol');
                        
                        oldPos   = cell(size(kids));
                        oldUnits = cell(size(kids));
                        labels   = strings(size(kids));
                        
                        for kk = 1:numel(kids)
                            try
                                oldUnits{kk} = get(kids(kk),'Units');
                                set(kids(kk),'Units','pixels');
                                oldPos{kk} = get(kids(kk),'Position');
                        
                                try
                                    labels(kk) = strtrim(string(get(kids(kk),'String')));
                                catch
                                    labels(kk) = "";
                                end
                            catch
                                oldPos{kk} = [];
                                oldUnits{kk} = 'pixels';
                                labels(kk) = "";
                            end
                        end
                        
                    
                        set(selectAll(1),'Units','pixels');
                        selPos0 = get(selectAll(1),'Position');
                        
                        gap = 6;
                        
          
                        extra = selPos0(4) + 2*gap;
                        
                   
                        figPos(2) = figPos(2) - extra;
                        figPos(4) = figPos(4) + extra;
                        ff.Position = figPos;
                        
                        for kk = 1:numel(kids)
                            try
                                if isempty(oldPos{kk})
                                    continue;
                                end
                        
                                p = oldPos{kk};
                        
                                if ~any(strcmpi(labels(kk), ["OK","Cancel"]))
                                    p(2) = p(2) + extra;
                                end
                        
                                set(kids(kk),'Position',p);
                            catch
                            end
                        end
                        
                       
                        set(selectAll(1),'Units','pixels');
                        selPos = get(selectAll(1),'Position');
                        
                        
                        globalPos = [ ...
                            selPos(1), ...
                            selPos(2) - selPos(4) - gap, ...
                            selPos(3), ...
                            selPos(4)];
                        
                        uicontrol(ff, ...
                            'Style','pushbutton', ...
                            'String','Global exclusion', ...
                            'Units','pixels', ...
                            'Position',globalPos, ...
                            'Callback',@chooseGlobal);
                        
                        % Restore units.
                        for kk = 1:numel(kids)
                            try
                                set(kids(kk),'Units',oldUnits{kk});
                            catch
                            end
                        end

                        try
                            ff.Resize = 'off';
                        catch
                        end
                        
                        ff.Units = oldFigUnits;

                        try
                            stop(injector);
                        catch
                        end
                        return;
                    catch
                    end
                end
            end

            function chooseGlobal(src,~)
                globalChosen = true;
                try
                    ff = ancestor(src,'figure');
                    cancelBtn = findall(ff,'Type','uicontrol','Style','pushbutton','String','Cancel');
                    if ~isempty(cancelBtn)
                        cb = get(cancelBtn(1),'Callback');
                        if isa(cb,'function_handle')
                            cb(cancelBtn(1),[]);
                        elseif iscell(cb) && ~isempty(cb) && isa(cb{1},'function_handle')
                            fcn = cb{1};
                            extraArgs = cb(2:end);
                            fcn(cancelBtn(1),[],extraArgs{:});
                        else
                            close(ff);
                        end
                    else
                        close(ff);
                    end
                catch
                    try
                        close(ancestor(src,'figure'));
                    catch
                    end
                end
            end
        end

        function manualPickGlobalExcludePoints(app, sheets)
            % Edit exclusions for every sheet in a combined run on one plot.
            sheets = string(sheets(:)).';
            sheets = sheets(strlength(sheets) > 0);
            if isempty(sheets)
                return;
            end

            allX = zeros(0,1);
            allY = zeros(0,1);
            ownerSheet = zeros(0,1);
            ownerRawIdx = zeros(0,1);
            excl = false(0,1);

            for ii = 1:numel(sheets)
                sheet = sheets(ii);
                [xRaw,yRaw] = app.readSheetXYRaw(string(app.DataFileEdit.Value), sheet);
                xRaw = xRaw(:);
                yRaw = yRaw(:);
                n = min(numel(xRaw),numel(yRaw));
                xRaw = xRaw(1:n);
                yRaw = yRaw(1:n);

                offset = numel(allX);
                allX = [allX; xRaw]; 
                allY = [allY; yRaw]; 
                ownerSheet = [ownerSheet; repmat(ii,n,1)]; 
                ownerRawIdx = [ownerRawIdx; (1:n).']; 
                excl = [excl; false(n,1)]; 

                key = char(sheet);
                if isKey(app.ExcludeMap,key)
                    pre = double(app.ExcludeMap(key));
                    pre = unique(pre(:));
                    pre = pre(pre >= 1 & pre <= n & isfinite(pre));
                    excl(offset + pre) = true;
                end
            end

            if isempty(allX)
                app.log("No data points are available for global exclusion picking.");
                return;
            end

            fig = figure("Name","Global exclusions: combined sheets", ...
                         "Color","w","Position",[180 120 1050 720]);
            ax = axes(fig);
            hold(ax,'on');
            grid(ax,'on'); box(ax,'on');
            xlabel(ax,"L (mm)"); ylabel(ax,"ln(n) mm^{-4}");

            hKeep = gobjects(numel(sheets),1);
            legLabels = cell(1,numel(sheets)+1);
            for ii = 1:numel(sheets)
                sty = app.getSamplePlotStyle("Component: " + sheets(ii));
                mf = app.parsePlotColor(sty.MarkerFaceColor,'y');
                me = app.parsePlotColor(sty.MarkerEdgeColor,'b');
                hKeep(ii) = scatter(ax,nan,nan,sty.MarkerSize,sty.MarkerShape, ...
                    'MarkerFaceColor',mf,'MarkerEdgeColor',me,'LineWidth',1.8);
                legLabels{ii} = char(sheets(ii));
            end
            hExcl = scatter(ax,nan,nan,180,'x','LineWidth',2.0,'MarkerEdgeColor','r');
            legLabels{end} = 'Excluded points';
            legend(ax,[hKeep; hExcl],legLabels,'Location','northeast');

            function redraw()
                for jj = 1:numel(sheets)
                    mask = ownerSheet == jj & ~excl;
                    set(hKeep(jj),'XData',allX(mask),'YData',allY(mask));
                end
                if any(excl)
                    set(hExcl,'XData',allX(excl),'YData',allY(excl),'Visible','on');
                else
                    set(hExcl,'XData',nan,'YData',nan,'Visible','off');
                end
                title(ax,sprintf('Global exclusion | Click points to exclude/include. Press Enter when done. Excluded=%d',nnz(excl)));
                drawnow limitrate;
            end

            redraw();
            while isvalid(fig)
                [xc,yc,btn] = ginput(1);
                if isempty(btn)
                    break;
                end
                xl = xlim(ax); yl = ylim(ax);
                sx = max(abs(diff(xl)),eps);
                sy = max(abs(diff(yl)),eps);
                d2 = ((allX-xc)./sx).^2 + ((allY-yc)./sy).^2;
                [~,jj] = min(d2);
                excl(jj) = ~excl(jj);
                redraw();
            end

            if isvalid(fig)
                close(fig);
            end

            totalExcluded = 0;
            for ii = 1:numel(sheets)
                sheet = sheets(ii);
                mask = ownerSheet == ii & excl;
                idxExcl = unique(ownerRawIdx(mask));
                app.ExcludeMap(char(sheet)) = idxExcl(:).';
                totalExcluded = totalExcluded + numel(idxExcl);

                if isKey(app.ManualPWMap,char(sheet))
                    remove(app.ManualPWMap,char(sheet));
                    app.log("Cleared manual piecewise picks for " + sheet + " (exclusions changed indexing).");
                end
                nRaw = nnz(ownerSheet == ii);
                app.log(sprintf("Stored exclusions for %s: excluded=%d (of %d raw points).", ...
                    sheet,numel(idxExcl),nRaw));
            end
            app.log(sprintf("Global exclusion picking complete: %d sheet(s), total excluded points=%d.", ...
                numel(sheets),totalExcluded));
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
            if isfield(result,'IsCombined') && result.IsCombined
                if isfield(result,'SourceSheets')
                    sampleCount = numel(result.SourceSheets);
                elseif isfield(result,'Components')
                    sampleCount = numel(result.Components);
                else
                    sampleCount = numel(split(erase(sheetName, "Combined: "), " + "));
                end
                sheetName = "Combine: " + string(sampleCount) + " samples";
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

            % Primary match
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

                app.StyleSampleDropDown.ItemsData = {};
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
                app.StyleSampleDropDown.ItemsData = {};
                app.StyleSampleDropDown.Items = {'(no results yet)'};
                app.StyleSampleDropDown.Value = '(no results yet)';
                app.StyleSampleDropDown.Enable = "off";
                return;
            end

            results = app.getCurrentViewResults();
            if isempty(results)
                app.StyleSampleDropDown.ItemsData = {};
                app.StyleSampleDropDown.Items = {'(no results yet)'};
                app.StyleSampleDropDown.Value = '(no results yet)';
                app.StyleSampleDropDown.Enable = "off";
                return;
            end

            names = strings(1,0);
            for ii = 1:numel(results)
                r = results{ii};
                if isfield(r,'IsCombined') && r.IsCombined && isfield(r,'Components') && ~isempty(r.Components)
                  
                    for j = 1:numel(r.Components)
                        compName = "Component: " + string(r.Components(j).Sheet);
                        names(end+1) = compName;
                        app.getSamplePlotStyle(compName);
                    end
                else
                    runLabel = app.getResultDisplayLabel(r, NaN);
                    names(end+1) = runLabel;
                    app.getSamplePlotStyle(runLabel);
                end
            end

            names = unique(names,'stable');
            if isempty(names)
                app.StyleSampleDropDown.ItemsData = {};
                app.StyleSampleDropDown.Items = {'(no results yet)'};
                app.StyleSampleDropDown.Value = '(no results yet)';
                app.StyleSampleDropDown.Enable = "off";
                return;
            end
            items = cellstr(names);
            if numel(items) > 1
                items = [{'All Samples'}, items];
            end
            cur = string(app.StyleSampleDropDown.Value);
           
            displayItems = regexprep(items, '^Component: ', '');
            app.StyleSampleDropDown.ItemsData = {};
            app.StyleSampleDropDown.Items = displayItems;
            app.StyleSampleDropDown.ItemsData = items;
            app.StyleSampleDropDown.Enable = "on";
            if any(strcmp(items, cur))
                app.StyleSampleDropDown.Value = char(cur);
            else
                app.StyleSampleDropDown.Value = items{1};
            end
            app.onStyleSampleChanged();
        end

        function onViewSampleChanged(app)
            app.ShowingSheetPreview = false;
            app.refreshStyleSampleList();
            app.updateCurrentFitView();
        end

        function onFitViewControlChanged(app)
            app.ShowingSheetPreview = false;
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
            app.previewSelectedSheet();
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
                modelType = app.normalizeModelType(string(result.ModelType));
                showLmix = any(strcmp(modelType,["2-Reservoir","3-Reservoir"]));
                Lmix = NaN;
                if showLmix
                    Lmix = app.getMeanCrystalLength(result, app.getDisplayedFitParameters(result));
                end
                meanCrystalSizeText = "";
                if showLmix && isfinite(Lmix)
                    meanCrystalSizeText = sprintf(" | Mean crystal size = %.4g mm", Lmix);
                end

                if isfield(result,'MCMC') && isfield(result.MCMC,'acceptRate')
                    rmsePlot = result.Fit.rmse;
                    r2Plot = result.Fit.r2;
                    try
                        yPlot = app.getDisplayedFitCurve(result, result.x(:));
                        [rmsePlot, r2Plot] = app.computeRmseR2(result.y_obs(:), yPlot(:));
                    catch
                    end
                    app.FitMetaLabel.Text = sprintf("%s | plotted=%s | accept=%.2f%% | RMSE=%.4g | R²=%.4f%s", ...
                        label, char(app.getDisplayedFitLegendSuffix(result)), result.MCMC.acceptRate, rmsePlot, r2Plot, char(meanCrystalSizeText));
                else
                    app.FitMetaLabel.Text = sprintf("%s | RMSE=%.4g | R²=%.4f%s", ...
                        label, result.Fit.rmse, result.Fit.r2, char(meanCrystalSizeText));
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
                elseif any(strcmp(colNames, "p-value")) && nCols == 7
                    % NL table with standard errors, absolute confidence
                    % limits, and fitnlm coefficient p-values.
                    weights = [0.25 0.20 0.12 0.10 0.11 0.11 0.11];
                    minW    = [175 150  90   80   90   90   85];
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
                        app.ParamStatsTable.ColumnName = {'Sample','Parameter','Best Fit','SE','95% Low','95% High','p-value'};
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
                    if isfield(result,'reservoirFixNm0') && result.reservoirFixNm0
                        fixedIdx = app.getReservoirNm0Index(result.ModelType);
                        if isfinite(fixedIdx) && numel(names) >= fixedIdx
                            names(fixedIdx) = names(fixedIdx) + " (fixed)";
                        end
                    end
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
                                app.formatStat(app.getStatField(stats, 'ciLow', ii)), ...
                                app.formatStat(app.getStatField(stats, 'ciHigh', ii)), ...
                                app.formatStat(app.getStatField(stats, 'pValue', ii))};
                        end
                    end
                end

                if useMCMCTable
                    app.ParamStatsTable.ColumnName = {'Sample','Parameter','Posterior Mean','Best Fit','SD','-95% CI','+95% CI'};
                else
                    app.ParamStatsTable.ColumnName = {'Sample','Parameter','Best Fit','SE','95% Low','95% High','p-value'};
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
                    app.log("No appended results to export. Use 'Append to results' first.");
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

                    rawSheetName = string(result.Sheet);
                    if isfield(result,'IsCombined') && result.IsCombined
                        runNumber = ii;
                        if isfield(result,'RunNumber') && isscalar(result.RunNumber) && ...
                                isfinite(double(result.RunNumber))
                            runNumber = double(result.RunNumber);
                        end
                        rawSheetName = "Combined (Run " + string(runNumber) + ")";
                    end
                    sheetName = app.excelSafeSheetName(rawSheetName, outFile);
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
                
                % NL fits use A:B, so summary starts in D.
                % MCMC fits use A:D, so summary starts in F.
                summaryStartCol = nFitCols + 2;
            else
                summaryStartCol = 1;
            end
            summaryStart = localExcelColumnName(summaryStartCol);

            initializationMode = app.getStoredRunSetting(result, 'Initialization', ...
                app.getPiecewiseInitializationMode(result));
            mcmcIterations = app.getStoredRunSetting(result, 'MCMCIterations', NaN);
            mcmcBurnIn = app.getStoredRunSetting(result, 'MCMCBurnIn', NaN);
            mcmcStepFraction = app.getStoredRunSetting(result, 'MCMCStepFraction', NaN);
            mcmcSigma = app.getStoredRunSetting(result, 'MCMCSigmaLnN', NaN);
            mcmcSeed = app.getStoredRunSetting(result, 'MCMCSeed', result.SeedUsed);

            [w1, w2] = app.getExportReservoirWeights(result);
            LmixExport = app.getMeanCrystalLength(result, app.getBestFitVector(result));
            LmixExportCell = '';
            if isfinite(LmixExport)
                LmixExportCell = double(LmixExport);
            end
            summaryHeaders = {'Result','Sample','Model','Solver','Run','RMSE','R2','Mean crystal size (mm)','w1','w2', ...
                'Initialization','MCMC Iterations','MCMC Burn-in','MCMC Step Fraction', ...
                'MCMC Sigma ln(n)','MCMC Seed','Exported','CSDStudio version'};
            summaryValues = { ...
                char(runLabel), ...
                char(result.Sheet), ...
                char(result.ModelType), ...
                char(result.Fit.solver), ...
                runNumber, ...
                double(result.Fit.rmse), ...
                double(result.Fit.r2), ...
                LmixExportCell, ...
                w1, ...
                w2, ...
                char(string(initializationMode)), ...
                double(mcmcIterations), ...
                double(mcmcBurnIn), ...
                double(mcmcStepFraction), ...
                double(mcmcSigma), ...
                double(mcmcSeed), ...
                timestamp, ...
                'CSDStudio 2026b'};

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

        function value = getStoredRunSetting(~, result, fieldName, fallback)
            value = fallback;
            try
                if isfield(result,'RunSettings') && isstruct(result.RunSettings) && ...
                        isfield(result.RunSettings, fieldName)
                    value = result.RunSettings.(fieldName);
                end
            catch
                value = fallback;
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

      
        function exportPlotDataPressed(app)
            try
                cfg = app.getConfig();
                app.ensureOutputDir(cfg);

                if ~isempty(app.AppendedResultsList)
                    results = app.AppendedResultsList;
                else
                    results = app.getCurrentViewResults();
                    if isempty(results)
                        app.log("No appended/current results to export plot data for.");
                        return;
                    end
                end

                nWritten = 0;
                for ii = 1:numel(results)
                    if isempty(results{ii}) || ~isstruct(results{ii})
                        continue;
                    end
                    app.savePlotDataWorkbook(cfg, results{ii});
                    nWritten = nWritten + 1;
                end

                if nWritten > 0
                    app.log(sprintf("Exported plot-data workbook(s) for %d result(s) to: %s", ...
                        nWritten, string(cfg.OutputDir)));
                else
                    app.log("No valid results were available for plot-data export.");
                end
            catch ME
                app.log("Export plot data failed: " + string(ME.message));
                app.log(getReport(ME,'basic','hyperlinks','off'));
            end
        end

        function rows = buildAppendedParamRows(app, result)
            % Results window export uses a single layout 
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
                posteriorMean = NaN;
                sd = NaN;
                ciMinus = NaN;
                ciPlus = NaN;
                ciLow = NaN;
                ciHigh = NaN;
                pValue = NaN;

                if app.isMCMCResult(result)
                    % MCMC fitted-parameter table layout:
                    % Sample | Parameter | Posterior Mean | Best Fit | SD | -95% CI | +95% CI
                    paramName = paramRows{ii,2};
                    posteriorMean = paramRows{ii,3};
                    bestFit = paramRows{ii,4};
                    sd = paramRows{ii,5};
                    ciMinus = paramRows{ii,6};
                    ciPlus = paramRows{ii,7};

                    
                    try
                        ciLow = posteriorMean - ciMinus;
                        ciHigh = posteriorMean + ciPlus;
                    catch
                    end
                else
                    % NL fitted-parameter table layout:
                    % Sample | Parameter | Best Fit | SE | 95% Low | 95% High | p-value
                    paramName = paramRows{ii,2};
                    bestFit = paramRows{ii,3};
                    se = paramRows{ii,4};
                    ciLow = paramRows{ii,5};
                    ciHigh = paramRows{ii,6};
                    pValue = paramRows{ii,7};
                end

                rows(end+1,:) = { ... 
                    char(app.getResultDisplayLabel(result, NaN)), ...
                    char(result.Sheet), ...
                    char(result.ModelType), ...
                    char(result.Fit.solver), ...
                    char(paramName), ...
                    bestFit, ...
                    se, ...
                    ciLow, ...
                    ciHigh, ...
                    pValue, ...
                    posteriorMean, ...
                    sd, ...
                    ciMinus, ...
                    ciPlus};
            end
        end

        function headers = getAppendedResultsHeaders(~)
            headers = {'Result','Sample','Model','Solver','Parameter', ...
                'Best Fit','SE','95% Low','95% High','p-value', ...
                'Posterior Mean','SD','-95% CI','+95% CI'};
        end

        function [headers, rows] = buildFittedParameterExportTable(app, result)
            % Build the  fittedparameter table
            rows = {};
            if app.isMCMCResult(result)
                headers = {'Sample','Parameter','Posterior Mean','Best Fit','SD','-95% CI','+95% CI'};
            else
                headers = {'Sample','Parameter','Best Fit','SE','95% Low','95% High','p-value'};
            end

            if isempty(result) || ~isstruct(result) || ~isfield(result,'b_fit')
                return;
            end

            names = app.getParamDisplayNames(result.ModelType);
            if isfield(result,'reservoirFixNm0') && result.reservoirFixNm0
                fixedIdx = app.getReservoirNm0Index(result.ModelType);
                if isfinite(fixedIdx) && numel(names) >= fixedIdx
                    names(fixedIdx) = names(fixedIdx) + " (fixed)";
                end
            end
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
                        app.fitStatOrNaN(result,'ciLow',ii), ...
                        app.fitStatOrNaN(result,'ciHigh',ii), ...
                        app.fitStatOrNaN(result,'pValue',ii)};
                end
            end
        end

        function names = getParamDisplayNames(app, modelType)
            modelType = app.normalizeModelType(string(modelType));
            if strcmp(modelType, "3-Reservoir")
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
            if strcmp(modelType, "3-Reservoir")
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
            if strcmp(modelType, "3-Reservoir")
                label = "3-Reservoir parameters: n₁⁰, G₁τ₁, n₂⁰, G₂τ₂, nₘᵢₓ⁰, Gₘᵢₓτₘᵢₓ; α₁ and α₂ are fixed.";
            elseif strcmp(modelType, "Growth-Law")
                label = "Growth-Law parameters: n⁰, b, G₀τ₀; a is constrained internally so aG₀τ₀ = 1.";
            elseif strcmp(modelType, "Linear")
                label = "Linear parameters: n⁰ and Gτ, where ln(n) = ln(n⁰) - L/(Gτ).";
            else
                label = "2-Reservoir parameters: n₁⁰, G₁τ₁, nₘᵢₓ⁰, Gₘᵢₓτₘᵢₓ.";
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
            app.ShowingSheetPreview = false;
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
                app.FitMetaLabel.Text = sprintf("Overlay mode | samples = %d", app.countDisplayedSamples(results));
            end

           

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

        function n = countDisplayedSamples(~, results)
            sampleNames = strings(0,1);
            for ii = 1:numel(results)
                r = results{ii};
                if isfield(r,'IsCombined') && r.IsCombined && isfield(r,'Components')
                    for jj = 1:numel(r.Components)
                        sampleNames(end+1,1) = string(r.Components(jj).Sheet); 
                    end
                elseif isfield(r,'Sheet')
                    sampleNames(end+1,1) = string(r.Sheet); 
                end
            end
            sampleNames = sampleNames(strlength(strtrim(sampleNames)) > 0);
            n = numel(unique(sampleNames,'stable'));
        end

        % Create or refresh the detached figure 
        function popOutFitPressed(app)
            results = app.getCurrentViewResults();
            if isempty(results); return; end
            app.FitFigureUserOpened = true;
            app.ensureFitFigure();
            app.drawFitAxes(app.FitFigureAxes, results);
            app.applyPopOutAxisShape();
            try
                app.FitFigure.Visible = 'on';
            catch
            end
            figure(app.FitFigure);
        end

        % Toggle the detached fit plot between a square and automatic plot box.
        function onPopOutSquareChanged(app)
            app.applyPopOutAxisShape();
        end

        function applyPopOutAxisShape(app)
            if isempty(app.FitFigureAxes) || ~isvalid(app.FitFigureAxes)
                return;
            end

            if app.SquarePopOutAxesCheck.Value
                axis(app.FitFigureAxes,'square');
            else
                pbaspect(app.FitFigureAxes,'auto');
            end
            drawnow limitrate;
        end

        % Prepare the detached figure in the background. 
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

        % Shared plotting routine 
      
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
            useOverlayLineColors = app.FitOverlayCheck.Value && numel(results) > 1;

            % If two overlaid fits would have
            % the same cleaned label fallback
            fitBaseLabels = strings(1,numel(results));
            for ii = 1:numel(results)
                styForLabel = app.getResultPlotStyle(results{ii}, NaN);
                fitBaseLabels(ii) = app.makeLegendFitLabel(results{ii}, styForLabel.DisplayName);
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
                        styPart = app.getSamplePlotStyle("Component: " + string(part.Sheet));
                        dataLabel = string(styPart.DisplayName);
                        if strlength(strtrim(dataLabel)) == 0
                            dataLabel = app.makeLegendDataLabel(part.Sheet);
                        end
                        dataKey = app.makeLegendKey("data:" + dataLabel);

                        if isfield(styPart,'ShowMarkers') && ~styPart.ShowMarkers
                            continue;
                        end

                   
                        if any(plottedDataKeys == dataKey)
                            continue;
                        end
                        plottedDataKeys(end+1,1) = dataKey; 

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
                    lcModel = app.getDisplayedLineColor(styModel, i, useOverlayLineColors);
        
                    if isfield(styModel,'ShowFitLine') && styModel.ShowFitLine
                        [bandHandlesThis, bandLabelsThis] = app.plotMCMCUncertaintyBands( ...
                            ax, r, xPlot, lcModel, useFullMCMCChainForEnvelope);

                        [fitHandles, fitSuffixes] = app.plotDisplayedModelLines( ...
                            ax, r, xPlot, yPred, styModel, lcModel);
                        for kkLine = 1:numel(fitHandles)
                            % Combined fits are identified by run number in the
                            % legend. 
                            runNumberForLegend = i;
                            if isfield(r,'RunNumber') && isscalar(r.RunNumber) && ...
                                    isfinite(double(r.RunNumber))
                                runNumberForLegend = double(r.RunNumber);
                            end
                            fitLabel = "Combined (Run " + string(runNumberForLegend) + ")";
                            if numel(fitHandles) > 1
                                fitLabel = fitLabel + " " + fitSuffixes(kkLine);
                            end
                            fitLabel = app.makeUniqueLegendLabel(fitLabel, r, usedLegendKeys);
                            legHandles(end+1) = fitHandles(kkLine);
                            legLabels{end+1} = char(fitLabel);
                            usedLegendKeys(end+1,1) = app.makeLegendKey(fitLabel);
                        end
                        for kkBand = 1:numel(bandHandlesThis)
                            legHandles(end+1) = bandHandlesThis(kkBand);
                            legLabels{end+1} = char(bandLabelsThis{kkBand});
                            usedLegendKeys(end+1,1) = app.makeLegendKey(bandLabelsThis{kkBand});
                        end
                    end
        
                else
                    % ----- single-sheet plotting grid for fit only -----
                    xRight = app.getFitCurveXRight(r.x);
                    xPlot = linspace(0, xRight, numel(r.xx)).';
                    yPred = app.getDisplayedFitCurve(r, xPlot, useFullMCMCChainForEnvelope);
        
                    sty = app.getResultPlotStyle(r, NaN);
                    mf = app.parsePlotColor(sty.MarkerFaceColor, 'y');
                    me = app.parsePlotColor(sty.MarkerEdgeColor, 'b');
                    lc = app.getDisplayedLineColor(sty, i, useOverlayLineColors);

                    dataLabel = string(sty.DisplayName);
                    if strlength(strtrim(dataLabel)) == 0
                        dataLabel = app.makeLegendDataLabel(r.Sheet);
                    end
                    dataKey = app.makeLegendKey("data:" + dataLabel);

                    showMarkers = ~isfield(sty,'ShowMarkers') || logical(sty.ShowMarkers);
        
                    if showMarkers && ~any(plottedDataKeys == dataKey)
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
                        [bandHandlesThis, bandLabelsThis] = app.plotMCMCUncertaintyBands( ...
                            ax, r, xPlot, lc, useFullMCMCChainForEnvelope);

                        [fitHandles, fitSuffixes] = app.plotDisplayedModelLines( ...
                            ax, r, xPlot, yPred, sty, lc);
                        for kkLine = 1:numel(fitHandles)
                            fitLabel = strtrim(string(sty.DisplayName) + " " + fitSuffixes(kkLine));
                            if numel(fitHandles) == 1 && nnz(fitBaseLabels == app.makeLegendFitLabel(r, sty.DisplayName)) > 1
                                fitLabel = fitLabel + " (" + string(r.ModelType) + ")";
                            end
                            fitLabel = app.makeUniqueLegendLabel(fitLabel, r, usedLegendKeys);
                            legHandles(end+1) = fitHandles(kkLine);
                            legLabels{end+1} = char(fitLabel);
                            usedLegendKeys(end+1,1) = app.makeLegendKey(fitLabel);
                        end
                        for kkBand = 1:numel(bandHandlesThis)
                            legHandles(end+1) = bandHandlesThis(kkBand);
                            legLabels{end+1} = char(bandLabelsThis{kkBand});
                            usedLegendKeys(end+1,1) = app.makeLegendKey(bandLabelsThis{kkBand});
                        end
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
        
            app.applyModelFitAxisControls(ax, results);
            hold(ax,'off');
        end

        function [legendHandles, legendSuffixes] = plotDisplayedModelLines( ...
                app, ax, result, xPlot, yDisplayed, sty, lineColor)
            % Plot the selected MCMC summary. 
            legendHandles = gobjects(0);
            legendSuffixes = strings(0,1);
            isBoth = app.isMCMCResult(result) && strcmp(app.getMCMCPlotMode(), "Both");

            plot(ax, xPlot, yDisplayed, ...
                'LineStyle', char(sty.LineStyle), ...
                'Color', lineColor, ...
                'LineWidth', sty.LineWidth, ...
                'HandleVisibility','off');
            hMeanOrSelected = plot(ax, nan, nan, ...
                'LineStyle', char(sty.LineStyle), ...
                'Color', lineColor, ...
                'LineWidth', sty.LineWidth);
            legendHandles(end+1) = hMeanOrSelected;

            if isBoth
                legendSuffixes(end+1,1) = "mean fit";
                bMap = app.getBestFitVector(result);
                yMap = result.Model(bMap, xPlot);
                plot(ax, xPlot, yMap, '--', ...
                    'Color', [0.85 0.10 0.10], ...
                    'LineWidth', sty.LineWidth, ...
                    'HandleVisibility','off');
                hMap = plot(ax, nan, nan, '--', ...
                    'Color', [0.85 0.10 0.10], ...
                    'LineWidth', sty.LineWidth);
                legendHandles(end+1) = hMap;
                legendSuffixes(end+1,1) = "MAP fit";
            else
                legendSuffixes(end+1,1) = app.getDisplayedFitLegendSuffix(result);
            end
        end

        function lineColor = getDisplayedLineColor(app, sty, overlayIndex, useOverlayLineColors)
            lineColor = app.parsePlotColor(sty.LineColor, 'b');
            userSet = isfield(sty,'LineColorUserSet') && logical(sty.LineColorUserSet);
            if ~useOverlayLineColors || userSet
                return;
            end

           
            baseIndices = [6 5 4 7 10 3 8];
            if overlayIndex <= numel(baseIndices)
                lineColor = app.getDistinctSampleColor(baseIndices(overlayIndex));
            else
                lineColor = app.getDistinctSampleColor(overlayIndex + 13);
            end
        end

        function rgb = getDistinctSampleColor(~, index)
        
            index = double(index);
            % Extend the color palette 
            palette = [ ...
                1.000 1.000 0.000; ...
                1.000 0.000 1.000; ...
                0.301 0.745 0.933; ...
                0.466 0.674 0.188; ...
                0.850 0.325 0.098; ...
                0.000 0.447 0.741; ...
                0.494 0.184 0.556; ...
                0.635 0.078 0.184; ...
                0.000 0.600 0.500; ...
                0.929 0.694 0.125; ...
                0.900 0.500 0.650; ...
                0.450 0.450 0.450; ...
                0.550 0.350 0.150; ...
                0.100 0.200 0.450; ...
                0.600 0.500 0.850; ...
                0.250 0.750 0.650; ...
                0.950 0.550 0.200; ...
                0.350 0.500 0.100; ...
                0.750 0.250 0.400; ...
                0.200 0.650 0.800];
            if index <= size(palette,1)
                rgb = palette(index,:);
            else
                k = index - size(palette,1);
                hue = mod(k * (sqrt(5)-1)/2, 1);
                saturation = 0.55 + 0.30 * mod(k * (sqrt(2)-1), 1);
                value = 0.65 + 0.25 * mod(k * (sqrt(3)-1), 1);
                rgb = hsv2rgb([hue saturation value]);
            end
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

        function label = makeLegendFitLabel(app, result, displayName)
            if isfield(result,'IsCombined') && result.IsCombined
                label = "Combined fit";
                return;
            end
            if nargin >= 3 && strlength(strtrim(string(displayName))) > 0
                baseName = strtrim(string(displayName));
            elseif isfield(result,'IsCombined') && result.IsCombined
                baseName = "Combined";
            elseif isfield(result,'Sheet')
                baseName = app.makeLegendDataLabel(result.Sheet);
            else
                baseName = "Fit";
            end

            suffix = app.getDisplayedFitLegendSuffix(result);
            label = strtrim(baseName + " " + suffix);
            if nargin < 3 || strlength(strtrim(string(displayName))) == 0
                label = regexprep(label, '\s*\|.*$', '');
            end
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
                if any(strcmp(mode, ["Mean","Both"]))
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

        function Lmix = getMeanCrystalLength(app, result, b)
            % Mean crystal length for the steady-state reservoir models
            % (Liang Eq. 16c). CSDStudio stores n1^0/n2^0 plus w1/w2 for
            % the 3-reservoir model, so alpha1=w1*n1^0 and alpha2=w2*n2^0.
            Lmix = NaN;
            try
                modelType = app.normalizeModelType(string(result.ModelType));
                b = double(b(:)).';
                if strcmp(modelType,"2-Reservoir") && numel(b) >= 4
                    n10 = b(1); G1t1 = b(2);
                    nm0 = b(3); Gmtm = b(4);
                    NT = nm0.*Gmtm + n10.*G1t1;
                    if isfinite(NT) && NT > 0
                        Lmix = Gmtm + n10.*(G1t1.^2)./NT;
                    end
                elseif strcmp(modelType,"3-Reservoir") && numel(b) >= 6
                    n10 = b(1); G1t1 = b(2);
                    n20 = b(3); G2t2 = b(4);
                    nm0 = b(5); Gmtm = b(6);
                    w1 = double(result.alpha1);
                    if isfield(result,'alpha2') && isfinite(double(result.alpha2))
                        w2 = double(result.alpha2);
                    else
                        w2 = 1 - w1;
                    end
                    a1 = w1.*n10;
                    a2 = w2.*n20;
                    NT = nm0.*Gmtm + a1.*G1t1 + a2.*G2t2;
                    if isfinite(NT) && NT > 0
                        Lmix = Gmtm + (a1.*(G1t1.^2) + a2.*(G2t2.^2))./NT;
                    end
                end
            catch
                Lmix = NaN;
            end
        end

        function yPred = getDisplayedFitCurve(app, result, xPlot, useFullMCMCChainForEnvelope)
            if nargin < 4
                useFullMCMCChainForEnvelope = false;
            end
           
            % For MCMC mean mode, the embedded  view uses a thinned
            % posterior copy for speed; exported plots can use the full
            % post-burn-in chain.
            yPred = [];
            xPlot = xPlot(:);

            try
                if app.isMCMCResult(result) && any(strcmp(app.getMCMCPlotMode(), ["Mean","Both"]))
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
                if strcmp(app.getMCMCPlotMode(), "Both")
                    suffix = "mean and MAP fits";
                elseif strcmp(app.getMCMCPlotMode(), "Mean")
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
            if strcmpi(mode, "Both")
                mode = "Both";
            elseif strcmpi(mode, "Mean")
                mode = "Mean";
            else
                mode = "Best fit (MAP)";
            end
        end

        function mode = getMCMCUncertaintyBandMode(app)
            mode = "None";
            try
                mode = string(app.MCMCUncertaintyBandDropDown.Value);
            catch
            end
            allowed = ["None","95% Uncertainty"];
            if ~any(strcmp(mode, allowed))
                mode = "None";
            end
        end

        function [showCredible, showPredictive] = getMCMCUncertaintyBandFlags(app)
            mode = app.getMCMCUncertaintyBandMode();
            showCredible = false;
            showPredictive = strcmp(mode, "95% Uncertainty");
        end

        function tf = shouldPlotMCMCUncertaintyBand(app, result, bandType, useFullChain)
            if nargin < 4
                useFullChain = false;
            end
            tf = false;
            try
                if ~app.isMCMCResult(result) || ...
                        ~any(strcmp(app.getMCMCPlotMode(), ["Mean","Both"]))
                    return;
                end

                [showCredible, showPredictive] = app.getMCMCUncertaintyBandFlags();
                bandType = lower(string(bandType));
                if strcmp(bandType, "credible")
                    if ~showCredible
                        return;
                    end
                elseif strcmp(bandType, "predictive")
                    if ~showPredictive || ~isfinite(app.getStoredMCMCObservationSigma(result))
                        return;
                    end
                else
                    return;
                end

          
                selectedFit = string(app.StyleSampleDropDown.Value);
                if strlength(selectedFit) == 0 || strcmp(selectedFit, "(no results yet)")
                    return;
                end
                selectedForBand = strcmp(selectedFit, "All Samples") || ...
                    strcmp(app.getResultDisplayLabel(result, NaN), selectedFit);
                if ~selectedForBand && isfield(result,'IsCombined') && result.IsCombined && ...
                        isfield(result,'Components') && ~isempty(result.Components)
                    componentKeys = "Component: " + string({result.Components.Sheet});
                    selectedForBand = any(strcmp(componentKeys, selectedFit));
                end
                if ~selectedForBand
                    return;
                end

                samplesForBand = app.getMCMCPosteriorSamplesForEnvelope(result, useFullChain);
                tf = ~isempty(samplesForBand);
            catch
                tf = false;
            end
        end

        function tf = shouldPlotMCMCCredibleBand(app, result, useFullChain)
            if nargin < 3; useFullChain = false; end
            tf = app.shouldPlotMCMCUncertaintyBand(result, "credible", useFullChain);
        end

        function tf = shouldPlotMCMCPosteriorPredictiveInterval(app, result, useFullChain)
            if nargin < 3; useFullChain = false; end
            tf = app.shouldPlotMCMCUncertaintyBand(result, "predictive", useFullChain);
        end

        function [bandHandles, bandLabels] = plotMCMCUncertaintyBands( ...
                app, ax, result, xPlot, lineColor, useFullChain)
            if nargin < 6
                useFullChain = false;
            end
            bandHandles = gobjects(0);
            bandLabels = {};

            try
                showCredible = app.shouldPlotMCMCCredibleBand(result, useFullChain);
                showPredictive = app.shouldPlotMCMCPosteriorPredictiveInterval(result, useFullChain);
                if ~showCredible && ~showPredictive
                    return;
                end

                predLow = [];
                predHigh = [];
                if showPredictive
                    [~, credLow, credHigh, predLow, predHigh] = ...
                        app.computeMCMCUncertaintyEnvelopes(result, xPlot, useFullChain);
                else
                    [~, credLow, credHigh] = ...
                        app.computeMCMCModelEnvelope(result, xPlot, useFullChain);
                end
                rgb = app.plotColorToRGB(lineColor);
                credibleColor = 0.45 .* [1 1 1] + 0.55 .* rgb;
                predictiveColor = 0.72 .* [1 1 1] + 0.28 .* rgb;
                hpCredible = gobjects(0);
                hpPredictive = gobjects(0);

                if showPredictive && ~isempty(predLow) && ~isempty(predHigh)
                    good = isfinite(xPlot(:)) & isfinite(predLow(:)) & isfinite(predHigh(:));
                    if nnz(good) >= 3
                        xg = xPlot(good);
                        yl = predLow(good);
                        yh = predHigh(good);
                        hpPredictive = fill(ax, [xg(:); flipud(xg(:))], ...
                            [yl(:); flipud(yh(:))], predictiveColor, ...
                            'FaceAlpha',0.22, 'EdgeColor','none');
                    end
                end

                if showCredible && ~isempty(credLow) && ~isempty(credHigh)
                    good = isfinite(xPlot(:)) & isfinite(credLow(:)) & isfinite(credHigh(:));
                    if nnz(good) >= 3
                        xg = xPlot(good);
                        yl = credLow(good);
                        yh = credHigh(good);
                        hpCredible = fill(ax, [xg(:); flipud(xg(:))], ...
                            [yl(:); flipud(yh(:))], credibleColor, ...
                            'FaceAlpha',0.32, 'EdgeColor','none');
                    end
                end

                % Keep the predictive uncertainty region behind the
                % observations and fit line.
                try
                    if ~isempty(hpCredible); uistack(hpCredible,'bottom'); end
                    if ~isempty(hpPredictive); uistack(hpPredictive,'bottom'); end
                catch
                end

                if ~isempty(hpPredictive)
                    bandHandles(end+1) = hpPredictive;
                    bandLabels{end+1} = '95% Uncertainty';
                elseif ~isempty(hpCredible)
                    bandHandles(end+1) = hpCredible;
                    bandLabels{end+1} = '95% Uncertainty';
                end
            catch
                bandHandles = gobjects(0);
                bandLabels = {};
            end
        end

        function sigmaObs = getStoredMCMCObservationSigma(~, result)
            sigmaObs = NaN;
            try
                if isfield(result,'MCMC') && isstruct(result.MCMC) && ...
                        isfield(result.MCMC,'observationSigmaLnN')
                    sigmaObs = double(result.MCMC.observationSigmaLnN);
                elseif isfield(result,'MCMC') && isstruct(result.MCMC) && ...
                        isfield(result.MCMC,'noiseSigma')
                    sigmaObs = double(result.MCMC.noiseSigma);
                elseif isfield(result,'Fit') && isfield(result.Fit,'output') && ...
                        isfield(result.Fit.output,'ObservationSigmaLnN')
                    sigmaObs = double(result.Fit.output.ObservationSigmaLnN);
                elseif isfield(result,'Fit') && isfield(result.Fit,'output') && ...
                        isfield(result.Fit.output,'NoiseSigma')
                    sigmaObs = double(result.Fit.output.NoiseSigma);
                end
            catch
                sigmaObs = NaN;
            end
            if ~isscalar(sigmaObs) || ~isfinite(sigmaObs) || sigmaObs <= 0
                sigmaObs = NaN;
            end
        end

        function [yMean, credLow, credHigh, predLow, predHigh] = ...
                computeMCMCUncertaintyEnvelopes(app, result, xPlot, useFullChain)
            if nargin < 4
                useFullChain = true;
            end
            yMean = [];
            credLow = [];
            credHigh = [];
            predLow = [];
            predHigh = [];

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
                credLow = app.rowPercentile(yDraw, 2.5);
                credHigh = app.rowPercentile(yDraw, 97.5);

                sigmaObs = app.getStoredMCMCObservationSigma(result);
                if ~isfinite(sigmaObs)
                    return;
                end

              
                predictiveSeed = 24681357;
                try
                    if isfield(result,'MCMC') && isfield(result.MCMC,'seed')
                        predictiveSeed = double(result.MCMC.seed) + 104729;
                    elseif isfield(result,'SeedUsed')
                        predictiveSeed = double(result.SeedUsed) + 104729;
                    end
                catch
                end
                if ~isscalar(predictiveSeed) || ~isfinite(predictiveSeed)
                    predictiveSeed = 24681357;
                else
                    predictiveSeed = mod(round(predictiveSeed), 2^32 - 1);
                    if predictiveSeed < 0
                        predictiveSeed = 24681357;
                    end
                end
                stream = RandStream('mt19937ar','Seed',predictiveSeed);
                z = randn(stream, 1, size(yDraw,2));
                for jj = 1:size(yDraw,2)
                    yDraw(:,jj) = yDraw(:,jj) + sigmaObs .* z(jj);
                end
                predLow = app.rowPercentile(yDraw, 2.5);
                predHigh = app.rowPercentile(yDraw, 97.5);
            catch
                yMean = [];
                credLow = [];
                credHigh = [];
                predLow = [];
                predHigh = [];
            end
        end

        function [yMean, yLow, yHigh] = computeMCMCModelEnvelope(app, result, xPlot, useFullChain)
            if nargin < 4
                useFullChain = true;
            end
            yMean = [];
            yLow = [];
            yHigh = [];
            try
                samplesPost = app.getMCMCPosteriorSamplesForEnvelope(result, useFullChain);
                if isempty(samplesPost)
                    return;
                end
                xPlot = xPlot(:);
                yDraw = nan(numel(xPlot), size(samplesPost,1));
                for jj = 1:size(samplesPost,1)
                    yj = result.Model(samplesPost(jj,:), xPlot);
                    if numel(yj) == numel(xPlot) && all(isfinite(yj))
                        yDraw(:,jj) = yj(:);
                    end
                end
                yDraw = yDraw(:,all(isfinite(yDraw),1));
                if size(yDraw,2) < 5
                    return;
                end
                yMean = mean(yDraw, 2, 'omitnan');
                yLow = app.rowPercentile(yDraw, 2.5);
                yHigh = app.rowPercentile(yDraw, 97.5);
            catch
                yMean = [];
                yLow = [];
                yHigh = [];
            end
        end

        function [yLow, yHigh] = computeMCMCPosteriorPredictiveEnvelope(app, result, xPlot, useFullChain)
            if nargin < 4; useFullChain = true; end
            [~, ~, ~, yLow, yHigh] = app.computeMCMCUncertaintyEnvelopes( ...
                result, xPlot, useFullChain);
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
                end
                if ~isfield(sty,'ShowMarkers')
                    sty.ShowMarkers = true;
                end
                if ~isfield(sty,'LineColorUserSet')
                    sty.LineColorUserSet = false;
                end
                app.SampleStyleMap(key) = sty;
                return;
            end

            defaultDisplayName = app.makeLegendDataLabel(sheet);
            sampleIndex = double(app.SampleStyleMap.Count) + 1;
            rgb = app.getDistinctSampleColor(sampleIndex);
            markerShapes = {'o','s','d','^','v','>','<','p','h'};
            markerIndex = mod(sampleIndex-1, numel(markerShapes)) + 1;
            sty = struct('DisplayName',defaultDisplayName, ...
                'MarkerFaceColor',string(sprintf('[%.12g %.12g %.12g]',rgb)), ...
                'MarkerEdgeColor',"k",'MarkerSize',400, ...
                'MarkerShape',markerShapes{markerIndex}, ...
                'LineColor',"b",'LineWidth',3,'LineStyle','-', ...
                'ShowFitLine',true,'ShowMarkers',true,'LineColorUserSet',false);
            app.SampleStyleMap(key) = sty;
        end

        function onStyleSampleChanged(app)
            if isempty(app.RunResults) || strcmp(app.StyleSampleDropDown.Value,'(no results yet)')
                return;
            end

            selected = string(app.StyleSampleDropDown.Value);
            sheet = selected;
            if sheet == "All Samples"
                targets = app.getStyleTargetNames();
                if isempty(targets); return; end
                sheet = targets(1);
            end
            sty = app.getSamplePlotStyle(sheet);
            lineSty = sty;
            currentResults = app.getCurrentViewResults();
            lineResultIndex = NaN;

            if startsWith(sheet,"Component: ")
                componentSheet = erase(sheet,"Component: ");
                for ii = 1:numel(currentResults)
                    r = currentResults{ii};
                    if isfield(r,'IsCombined') && r.IsCombined && isfield(r,'Components') && ...
                            any(string({r.Components.Sheet}) == componentSheet)
                        lineSty = app.getResultPlotStyle(r, NaN);
                        lineResultIndex = ii;
                        break;
                    end
                end
            else
          
                for ii = 1:numel(currentResults)
                    r = currentResults{ii};
                    if app.getResultDisplayLabel(r, NaN) == sheet
                        lineSty = app.getResultPlotStyle(r, NaN);
                        lineResultIndex = ii;
                        break;
                    end
                end
            end

            displayedLineColor = lineSty.LineColor;
            if isfinite(lineResultIndex)
                useOverlayLineColors = app.FitOverlayCheck.Value && numel(currentResults) > 1;
                displayedLineColor = app.getDisplayedLineColor( ...
                    lineSty, lineResultIndex, useOverlayLineColors);
            end
            if isnumeric(displayedLineColor) && numel(displayedLineColor) == 3
                displayedLineColorText = sprintf('[%.12g %.12g %.12g]', ...
                    displayedLineColor(1), displayedLineColor(2), displayedLineColor(3));
            else
                displayedLineColorText = char(string(displayedLineColor));
            end

            app.StyleDisplayNameEdit.Value       = char(sty.DisplayName);
            app.StyleMarkerFaceColorEdit.Value   = char(string(sty.MarkerFaceColor));
            app.StyleMarkerEdgeColorEdit.Value   = char(string(sty.MarkerEdgeColor));
            app.StyleMarkerSizeEdit.Value        = sty.MarkerSize;
            app.StyleMarkerShapeDropDown.Value   = char(string(sty.MarkerShape));
            app.StyleLineColorEdit.Value         = displayedLineColorText;
            app.StyleLineWidthEdit.Value         = lineSty.LineWidth;
            if isfield(lineSty,'LineStyle')
                app.StyleLineStyleDropDown.Value = char(string(lineSty.LineStyle));
            else
                app.StyleLineStyleDropDown.Value = '-';
            end
            if isfield(lineSty,'ShowFitLine')
                app.StyleShowFitLineCheck.Value = logical(lineSty.ShowFitLine);
            else
                app.StyleShowFitLineCheck.Value = true;
            end
            if isfield(sty,'ShowMarkers')
                app.StyleShowMarkersCheck.Value = logical(sty.ShowMarkers);
            else
                app.StyleShowMarkersCheck.Value = true;
            end
            try
                if ~strcmp(app.getMCMCUncertaintyBandMode(), "None") && ~app.ShowingSheetPreview
                    app.updateCurrentFitView();
                end
            catch
            end
        end

        function onStyleControlChanged(app, source)
            if isempty(app.RunResults) || strcmp(app.StyleSampleDropDown.Value,'(no results yet)')
                return;
            end

            selected = string(app.StyleSampleDropDown.Value);
            if selected == "All Samples"
                targets = app.getStyleTargetNames();
            else
                targets = selected;
            end

            for ii = 1:numel(targets)
                sheet = targets(ii);
                sty = app.getSamplePlotStyle(sheet);
                if selected ~= "All Samples" || source == app.StyleDisplayNameEdit
                    sty.DisplayName = string(app.StyleDisplayNameEdit.Value);
                end
                if selected ~= "All Samples" || source == app.StyleLineColorEdit
                    sty.LineColor = string(app.StyleLineColorEdit.Value);
                    if source == app.StyleLineColorEdit
                        sty.LineColorUserSet = true;
                    end
                end
                if selected ~= "All Samples" || source == app.StyleMarkerFaceColorEdit
                    sty.MarkerFaceColor = string(app.StyleMarkerFaceColorEdit.Value);
                end
                if selected ~= "All Samples" || source == app.StyleMarkerEdgeColorEdit
                    sty.MarkerEdgeColor = string(app.StyleMarkerEdgeColorEdit.Value);
                end
                if selected ~= "All Samples" || source == app.StyleMarkerSizeEdit
                    sty.MarkerSize = app.StyleMarkerSizeEdit.Value;
                end
                if selected ~= "All Samples" || source == app.StyleMarkerShapeDropDown
                    sty.MarkerShape = string(app.StyleMarkerShapeDropDown.Value);
                end
                if selected ~= "All Samples" || source == app.StyleLineWidthEdit
                    sty.LineWidth = app.StyleLineWidthEdit.Value;
                end
                if selected ~= "All Samples" || source == app.StyleLineStyleDropDown
                    sty.LineStyle = string(app.StyleLineStyleDropDown.Value);
                end
                if selected ~= "All Samples" || source == app.StyleShowFitLineCheck
                    sty.ShowFitLine = logical(app.StyleShowFitLineCheck.Value);
                end
                if selected ~= "All Samples" || source == app.StyleShowMarkersCheck
                    sty.ShowMarkers = logical(app.StyleShowMarkersCheck.Value);
                end
                app.SampleStyleMap(char(sheet)) = sty;
            end

            isLineControl = source == app.StyleLineColorEdit || ...
                source == app.StyleLineWidthEdit || ...
                source == app.StyleLineStyleDropDown || ...
                source == app.StyleShowFitLineCheck;
            if isLineControl
                currentResults = app.getCurrentViewResults();
                for ii = 1:numel(currentResults)
                    r = currentResults{ii};
                    if ~(isfield(r,'IsCombined') && r.IsCombined && isfield(r,'Components'))
                        continue;
                    end
                    applies = selected == "All Samples";
                    if ~applies && startsWith(selected,"Component: ")
                        componentSheet = erase(selected,"Component: ");
                        applies = any(string({r.Components.Sheet}) == componentSheet);
                    end
                    if ~applies
                        continue;
                    end
                    resultKey = app.getResultDisplayLabel(r, NaN);
                    resultStyle = app.getResultPlotStyle(r, NaN);
                    if source == app.StyleLineColorEdit
                        resultStyle.LineColor = string(app.StyleLineColorEdit.Value);
                        resultStyle.LineColorUserSet = true;
                    elseif source == app.StyleLineWidthEdit
                        resultStyle.LineWidth = app.StyleLineWidthEdit.Value;
                    elseif source == app.StyleLineStyleDropDown
                        resultStyle.LineStyle = string(app.StyleLineStyleDropDown.Value);
                    elseif source == app.StyleShowFitLineCheck
                        resultStyle.ShowFitLine = logical(app.StyleShowFitLineCheck.Value);
                    end
                    app.SampleStyleMap(char(resultKey)) = resultStyle;
                end
            end
            if app.ShowingSheetPreview
                app.previewSelectedSheet();
            else
                app.updateCurrentFitView();
            end
        end

        function targets = getStyleTargetNames(app)
            targets = string(app.StyleSampleDropDown.ItemsData);
            if isempty(targets)
                targets = string(app.StyleSampleDropDown.Items);
            end
            targets = targets(targets ~= "All Samples" & targets ~= "(no results yet)");
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
            cfg.maxIter       = app.MaxIterEdit.Value;
            cfg.funcTol       = app.FuncTolEdit.Value;
            cfg.stepTol       = app.StepTolEdit.Value;

            cfg.mcmcIter      = round(app.MCMCIterEdit.Value);
            cfg.mcmcBurnIn    = round(app.MCMCBurnInEdit.Value);
            cfg.mcmcStepFrac  = app.MCMCStepFracEdit.Value;
            cfg.mcmcNoiseSigma = app.MCMCNoiseSigmaEdit.Value;
            cfg.mcmcSeed      = round(app.MCMCSeedEdit.Value);
            cfg.mcmcPerSheetSeedOffset = logical(app.MCMCPerSheetSeedOffsetCheck.Value);
            cfg.mcmcPlotMode = string(app.MCMCPlotModeDropDown.Value);
            cfg.mcmcUncertaintyBandMode = app.getMCMCUncertaintyBandMode();
            cfg.mcmcShowCredibleBand = false;
            cfg.mcmcShowPosteriorPredictiveInterval = strcmp(cfg.mcmcUncertaintyBandMode, "95% Uncertainty");

            cfg.ModelType     = app.normalizeModelType(string(app.ModelTypeDropDown.Value));
            if strcmp(cfg.ModelType, "Linear")
                cfg.SolverType = "NL Inversion";
                cfg.solver = "fitnlm";
            end
            cfg.alpha1        = app.Alpha1Edit.Value;
            cfg.alpha2        = 1 - cfg.alpha1;
            cfg.reservoirFixNm0 = false;
            cfg.reservoirFixedLnNm0 = NaN;
            cfg.reservoirFixedNm0 = NaN;
            if any(strcmp(cfg.ModelType,["2-Reservoir","3-Reservoir"]))
                cfg.reservoirFixNm0 = logical(app.ReservoirFixNm0Check.Value);
                cfg.reservoirFixedLnNm0 = app.ReservoirLnNm0Edit.Value;
                if cfg.reservoirFixNm0 && isfinite(cfg.reservoirFixedLnNm0)
                    cfg.reservoirFixedNm0 = exp(cfg.reservoirFixedLnNm0);
                end
            end
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
            cfg.enforceTurnoverOrdering = false;


            cfg.clipX         = logical(app.ClipXCheck.Value);
            cfg.xMin          = app.XMinEdit.Value;
            cfg.xMax          = app.XMaxEdit.Value;
            cfg.clipY         = logical(app.ClipYCheck.Value);
            cfg.yMin          = app.YMinEdit.Value;
            cfg.yMax          = app.YMaxEdit.Value;
            cfg.extendFit   = logical(app.ExtendFitCheck.Value);
            cfg.fitXMax     = app.FitXMaxEdit.Value;
            cfg.ParamNames    = app.getParamNames(cfg.ModelType);
        end

        function settings = makeStoredRunSettings(app, cfg, seedUsed)
            initialization = "Not applicable";
            modelType = app.normalizeModelType(string(cfg.ModelType));
            if any(strcmp(modelType, ["2-Reservoir","3-Reservoir"]))
                if cfg.manualPiecewise
                    initialization = "Manual piecewise";
                else
                    initialization = "Automatic piecewise";
                end
            end
            settings = struct( ...
                'Initialization', initialization, ...
                'NLMaxIterations', double(cfg.maxIter), ...
                'NLFunctionTolerance', double(cfg.funcTol), ...
                'NLStepTolerance', double(cfg.stepTol), ...
                'MCMCIterations', NaN, ...
                'MCMCBurnIn', NaN, ...
                'MCMCStepFraction', NaN, ...
                'MCMCSigmaLnN', NaN, ...
                'MCMCSeed', NaN, ...
                'FixReservoirLnNm0', false, ...
                'FixedReservoirLnNm0', NaN);
            settings.FixReservoirLnNm0 = logical(app.isFixedReservoirNm0(cfg));
            if settings.FixReservoirLnNm0
                settings.FixedReservoirLnNm0 = double(cfg.reservoirFixedLnNm0);
            end
            if strcmp(app.normalizeSolverType(string(cfg.SolverType)), "MCMC")
                settings.MCMCIterations = double(cfg.mcmcIter);
                settings.MCMCBurnIn = double(cfg.mcmcBurnIn);
                settings.MCMCStepFraction = double(cfg.mcmcStepFrac);
                settings.MCMCSigmaLnN = double(cfg.mcmcNoiseSigma);
                settings.MCMCSeed = double(seedUsed);
            end
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
                    error("Observation sigma in ln(n) must be finite and > 0.");
                end
            end
            if strcmp(app.normalizeModelType(string(cfg.ModelType)), "3-Reservoir")
                if ~isfinite(cfg.alpha1) || cfg.alpha1 <= 0 || cfg.alpha1 >= 1
                    error("w1 must be between 0 and 1 for the 3-Reservoir model.");
                end
            end
            if any(strcmp(app.normalizeModelType(string(cfg.ModelType)),["2-Reservoir","3-Reservoir"]))
                if isfield(cfg,'reservoirFixNm0') && cfg.reservoirFixNm0 && ...
                        (~isfield(cfg,'reservoirFixedLnNm0') || ~isfinite(cfg.reservoirFixedLnNm0))
                    error("Fixed ln(n_mix^0) must be finite.");
                end
                if isfield(cfg,'reservoirFixNm0') && cfg.reservoirFixNm0 && ...
                        (~isfield(cfg,'reservoirFixedNm0') || ~isfinite(cfg.reservoirFixedNm0) || cfg.reservoirFixedNm0 <= 0)
                    error("Fixed n_mix^0 must be positive. Check the fixed ln(n_mix^0) value.");
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
            xx = linspace(0, xRight, 2000).';
        
            [b_init, piece] = app.getInitialGuess(cfg, sheet, x, y_obs, xx);
            cfg = app.configureTurnoverBranch(cfg, x, y_obs, piece);
        
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
            result.RunSettings = app.makeStoredRunSettings(cfg, NaN);
            result.alpha1 = cfg.alpha1;
            result.alpha2 = cfg.alpha2;
            result.reservoirFixNm0 = app.isFixedReservoirNm0(cfg);
            result.reservoirFixedLnNm0 = cfg.reservoirFixedLnNm0;
            result.reservoirFixedNm0 = cfg.reservoirFixedNm0;
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
            xx = linspace(0, xRight, 2000).';
        
            comboName = "Combined: " + strjoin(cellstr(sheets), " + ");
        
            [b_init, piece] = app.getInitialGuess(cfg, comboName, xAll, yAll, xx);
            cfg = app.configureTurnoverBranch(cfg, xAll, yAll, piece);
        
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
            result.RunSettings = app.makeStoredRunSettings(cfg, NaN);
            result.alpha1 = cfg.alpha1;
            result.alpha2 = cfg.alpha2;
            result.reservoirFixNm0 = app.isFixedReservoirNm0(cfg);
            result.reservoirFixedLnNm0 = cfg.reservoirFixedLnNm0;
            result.reservoirFixedNm0 = cfg.reservoirFixedNm0;
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

            nFree = numel(app.getParamNames(cfg.ModelType)) - double(app.isFixedReservoirNm0(cfg));
            if numel(x) < nFree + 2
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
            xx = linspace(0, xRight, 2000).';

            [b_init, piece] = app.getInitialGuess(cfg, sheet, x, y_obs, xx);
            cfg = app.configureTurnoverBranch(cfg, x, y_obs, piece);

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
            result.RunSettings = app.makeStoredRunSettings(cfg, seedUsed);
            result.alpha1 = cfg.alpha1;
            result.alpha2 = cfg.alpha2;
            result.reservoirFixNm0 = app.isFixedReservoirNm0(cfg);
            result.reservoirFixedLnNm0 = cfg.reservoirFixedLnNm0;
            result.reservoirFixedNm0 = cfg.reservoirFixedNm0;
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
                'uncertaintyBandMode', cfg.mcmcUncertaintyBandMode, ...
                'showCredibleBand', cfg.mcmcShowCredibleBand, ...
                'showPosteriorPredictiveInterval', cfg.mcmcShowPosteriorPredictiveInterval, ...
                'observationSigmaLnN', fit.mcmcSummary.noiseSigma);

            result.Exclusions = struct( ...
                'enabled', cfg.useExclusions, ...
                'rawN', rawN, ...
                'excludedIdx', idxExcl(:).', ...
                'usedN', numel(x), ...
                'x_excl', x_excl(:), ...
                'y_excl', y_excl(:));

            app.log(sprintf("%s: solver=%s | post-burn accept=%.2f%% | overall accept=%.2f%% | RMSE=%.4g", ...
                sheet, fit.solver, result.MCMC.postBurnAcceptRate, result.MCMC.acceptRate, fit_rmse));
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

            nFree = numel(app.getParamNames(cfg.ModelType)) - double(app.isFixedReservoirNm0(cfg));
            if numel(xAll) < nFree + 2
                error("Too few combined points after exclusions for MCMC. Need more observations than parameters.");
            end

            xRight = app.getFitCurveXRight(xAll, cfg);
            xx = linspace(0, xRight, 2000).';

            comboName = "Combined: " + strjoin(cellstr(sheets), " + ");

            [b_init, piece] = app.getInitialGuess(cfg, comboName, xAll, yAll, xx);
            cfg = app.configureTurnoverBranch(cfg, xAll, yAll, piece);

            if (isvalid(dlg) && dlg.CancelRequested) || app.CancelRequested
                result = [];
                return;
            end

            dlg.Value = 0.15;
            dlg.Message = "MCMC Combined";

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
            result.RunSettings = app.makeStoredRunSettings(cfg, seedUsed);
            result.alpha1 = cfg.alpha1;
            result.alpha2 = cfg.alpha2;
            result.reservoirFixNm0 = app.isFixedReservoirNm0(cfg);
            result.reservoirFixedLnNm0 = cfg.reservoirFixedLnNm0;
            result.reservoirFixedNm0 = cfg.reservoirFixedNm0;
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
                'uncertaintyBandMode', cfg.mcmcUncertaintyBandMode, ...
                'showCredibleBand', cfg.mcmcShowCredibleBand, ...
                'showPosteriorPredictiveInterval', cfg.mcmcShowPosteriorPredictiveInterval, ...
                'observationSigmaLnN', fit.mcmcSummary.noiseSigma);

            app.log(sprintf("%s: solver=%s | post-burn accept=%.2f%% | overall accept=%.2f%% | RMSE=%.4g", ...
                comboName, fit.solver, result.MCMC.postBurnAcceptRate, result.MCMC.acceptRate, fit_rmse));
        end

        % random-walk Metropolis solver in log-parameter
        % space. All fitted parameters are kept positive by sampling
        % theta = log(b). The proposal covariance is learned only during
        % burn-in and is frozen before posterior samples are retained.
        function fit = solveMCMCFit(app, x, y_obs, b_init, cfg, dlg, runLabel, seedUsed)
            fit = [];

            rng(seedUsed, "twister");

            [lb, ub, mcmcBoundInfo] = app.getMCMCHybridBounds(x, y_obs, cfg);
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
            fixedReservoirNm0 = app.isFixedReservoirNm0(cfg);
            reservoirNm0Idx = app.getReservoirNm0Index(cfg.ModelType);
            if fixedReservoirNm0 && isfinite(reservoirNm0Idx) && p >= reservoirNm0Idx
                theta_current(reservoirNm0Idx) = cfg.reservoirFixedLnNm0;
                theta_lb(reservoirNm0Idx) = theta_current(reservoirNm0Idx);
                theta_ub(reservoirNm0Idx) = theta_current(reservoirNm0Idx);
                stepTheta(reservoirNm0Idx) = 0;
            end
            stride = 500;

           
            activeIdx = find(stepTheta > 0 & theta_ub > theta_lb);
            nActive = numel(activeIdx);
            diagonalMixProbability = 0.10;
            targetAcceptance = 0.234;
            if nActive == 1
                targetAcceptance = 0.44;
            end
            adaptiveEnabled = burnIn >= 200 && nActive >= 2;
            adaptStart = min(max(100, round(0.10 .* burnIn)), max(burnIn - 1, 1));
            adaptInterval = max(25, min(200, round(max(burnIn,1) ./ 100)));
            optimalScale = 1;
            if nActive > 0
                optimalScale = 2.38 ./ sqrt(nActive);
            end
            logAdaptiveScale = 0;
            adaptiveReady = false;
            adaptiveUpdateCount = 0;
            proposalCovBase = diag(max(stepTheta(activeIdx).^2, 1e-12));
            proposalCholBase = diag(max(stepTheta(activeIdx), 1e-6));
            adaptMomentCount = 0;
            adaptMean = zeros(1,nActive);
            adaptM2 = zeros(nActive,nActive);
            correlatedBlockProposals = 0;
            correlatedBlockAccepts = 0;
            correlatedTotalProposals = 0;
            correlatedTotalAccepts = 0;

            if adaptiveEnabled
                app.log(sprintf( ...
                    "Adaptive correlated MCMC proposal for %s.", ...
                    string(runLabel)));
            elseif nActive >= 2
                app.log(sprintf("Adaptive proposal disabled for %s because burn-in is shorter than 200 iterations; using the diagonal proposal.", string(runLabel)));
            end

       
            if isfield(cfg,'manualPiecewise') && logical(cfg.manualPiecewise)
                [logPostCurrent, ~] = app.logPosteriorTheta( ...
                    theta_current, x, y_obs, cfg, theta_lb, theta_ub, sigmaObs);
                if ~isfinite(logPostCurrent)
                    error("The freshly selected manual piecewise initialization is not a finite MCMC starting point for %s. Re-pick the manual segments.", string(runLabel));
                end
                startInfo = struct( ...
                    'scoutCount',0, ...
                    'temperedProposalCount',0, ...
                    'eliteCount',0, ...
                    'nearBestEliteCount',0, ...
                    'agreementToleranceLogPosterior',NaN, ...
                    'bestLogPosterior',logPostCurrent, ...
                    'bestTheta',theta_current);
                mcmcInitializationLabel = 'direct fresh manual piecewise seed; no global pre-search';
            else
             
                [theta_current, logPostCurrent, startInfo] = app.findIndependentMCMCStart( ...
                    theta_current, activeIdx, x, y_obs, cfg, theta_lb, theta_ub, sigmaObs);
                if ~isfinite(logPostCurrent)
                    error("MCMC initialization could not find a finite starting point for %s. Inspect the data and piecewise initialization.", string(runLabel));
                end
                mcmcInitializationLabel = 'optimizer-free stratified and tempered stochastic pre-search';
            end
            initialB = app.applyFixedModelParameters(exp(theta_current), cfg);

            samples = zeros(nIter, p);
            logPostTrace = nan(nIter,1);
            logLikelihoodTrace = nan(nIter,1);
            acceptCount = 0;
            burnInAcceptCount = 0;
            postBurnAcceptCount = 0;

         
            [~, logLikelihoodCurrent] = app.logPosteriorTheta( ...
                theta_current, x, y_obs, cfg, theta_lb, theta_ub, sigmaObs);

            for ii = 1:nIter
                if (isvalid(dlg) && dlg.CancelRequested) || app.CancelRequested
                    return;
                end

                
                thetaProp = theta_current;
                useCorrelatedMove = adaptiveEnabled && adaptiveReady && ...
                    (rand > diagonalMixProbability);
                if nActive > 0
                    if useCorrelatedMove
                        deltaActive = (exp(logAdaptiveScale) .* optimalScale .* ...
                            (proposalCholBase * randn(nActive,1))).';
                        correlatedBlockProposals = correlatedBlockProposals + 1;
                        correlatedTotalProposals = correlatedTotalProposals + 1;
                    else
                        deltaActive = stepTheta(activeIdx) .* randn(1,nActive);
                    end
                    thetaProp(activeIdx) = theta_current(activeIdx) + deltaActive;
                end
                [logPostProp, logLikelihoodProp] = app.logPosteriorTheta( ...
                    thetaProp, x, y_obs, cfg, theta_lb, theta_ub, sigmaObs);

                if isfinite(logPostProp) && (log(rand) < (logPostProp - logPostCurrent))
                    theta_current = thetaProp;
                    logPostCurrent = logPostProp;
                    logLikelihoodCurrent = logLikelihoodProp;
                    acceptCount = acceptCount + 1;
                    if ii <= burnIn
                        burnInAcceptCount = burnInAcceptCount + 1;
                    else
                        postBurnAcceptCount = postBurnAcceptCount + 1;
                    end
                    if useCorrelatedMove
                        correlatedBlockAccepts = correlatedBlockAccepts + 1;
                        correlatedTotalAccepts = correlatedTotalAccepts + 1;
                    end
                end

                samples(ii,:) = app.applyFixedModelParameters(exp(theta_current), cfg);
                logPostTrace(ii) = logPostCurrent;
                logLikelihoodTrace(ii) = logLikelihoodCurrent;

                % covariance update (Welford form). Adaptation occurs
                % during burn-in only. At burn-in completion, the last learned
                % covariance and scale are frozen for all retained samples.
                if adaptiveEnabled && ii <= burnIn
                    thetaActive = theta_current(activeIdx);
                    adaptMomentCount = adaptMomentCount + 1;
                    momentDelta = thetaActive - adaptMean;
                    adaptMean = adaptMean + momentDelta ./ adaptMomentCount;
                    momentDelta2 = thetaActive - adaptMean;
                    adaptM2 = adaptM2 + momentDelta(:) * momentDelta2(:).';

                    updateNow = ii >= adaptStart && ...
                        (mod(ii - adaptStart, adaptInterval) == 0 || ii == burnIn);
                    if updateNow && adaptMomentCount > nActive + 2
                        empiricalCov = adaptM2 ./ max(adaptMomentCount - 1, 1);
                        [proposalCholBase, proposalCovBase] = ...
                            app.regularizedProposalCholesky(empiricalCov, stepTheta(activeIdx));
                        adaptiveUpdateCount = adaptiveUpdateCount + 1;

                        % Robbins-Monro adjustment of the correlated proposal's
          
                        if correlatedBlockProposals > 0
                            blockRate = correlatedBlockAccepts ./ correlatedBlockProposals;
                            gain = min(0.5, 1 ./ sqrt(adaptiveUpdateCount));
                            logAdaptiveScale = logAdaptiveScale + ...
                                gain .* (blockRate - targetAcceptance);
                            logAdaptiveScale = min(max(logAdaptiveScale, log(0.05)), log(20));
                        end
                        correlatedBlockProposals = 0;
                        correlatedBlockAccepts = 0;
                        adaptiveReady = true;
                    end
                end

                if mod(ii, stride) == 0
                    try
                        if strcmp(string(cfg.Mode), "Combine sheets")
                            dlg.Message = "MCMC Combined";
                        else
                            dlg.Message = sprintf("MCMC %s: iter %d / %d", runLabel, ii, nIter);
                        end
                    catch
                    end
                    drawnow limitrate;
                end
            end

            idxPost = (burnIn + 1):nIter;
            samplesPost = samples(idxPost,:);
            logPostPost = logPostTrace(idxPost);
            logLikelihoodPost = logLikelihoodTrace(idxPost);

            % Keep the full post-burn-in chain for posterior summaries and
            % exported MCMC diagnostics. 
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
            if fixedReservoirNm0 && isfinite(reservoirNm0Idx) && p >= reservoirNm0Idx
                b_mean(reservoirNm0Idx) = cfg.reservoirFixedNm0;
                b_median(reservoirNm0Idx) = cfg.reservoirFixedNm0;
                b_std(reservoirNm0Idx) = 0;
            end

            % The prior is uniform in the bounded physical parameters
            [~, idxMap] = max(logLikelihoodPost);
            if isempty(idxMap) || ~isfinite(idxMap)
                idxMap = 1;
            end
            b_map = samplesPost(idxMap,:);
            if fixedGrowthN0 && p >= 1
                b_map(1) = cfg.growthFixedN0;
            end
            if fixedReservoirNm0 && isfinite(reservoirNm0Idx) && p >= reservoirNm0Idx
                b_map(reservoirNm0Idx) = cfg.reservoirFixedNm0;
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
            if fixedReservoirNm0 && isfinite(reservoirNm0Idx) && p >= reservoirNm0Idx
                ciLow(reservoirNm0Idx) = cfg.reservoirFixedNm0;
                ciHigh(reservoirNm0Idx) = cfg.reservoirFixedNm0;
            end

            paramStats = app.makeMCMCParameterStats(samplesPost, b_mean, b_map, b_std, ciLow, ciHigh, numel(y_obs));
            paramStats.dof = max(numel(y_obs) - nActive, 0);

            acceptRate = 100 * acceptCount / nIter;
            burnInAcceptRate = NaN;
            if burnIn > 0
                burnInAcceptRate = 100 .* burnInAcceptCount ./ burnIn;
            end
            nPost = nIter - burnIn;
            postBurnAcceptRate = 100 .* postBurnAcceptCount ./ max(nPost,1);
            correlatedAcceptRate = NaN;
            if correlatedTotalProposals > 0
                correlatedAcceptRate = 100 .* correlatedTotalAccepts ./ correlatedTotalProposals;
            end

            adaptiveApplied = adaptiveEnabled && adaptiveReady;
            finalProposalCovTheta = zeros(p,p);
            if nActive > 0
                if adaptiveApplied
                    finalActiveCov = (exp(logAdaptiveScale) .* optimalScale).^2 .* proposalCovBase;
                else
                    finalActiveCov = diag(stepTheta(activeIdx).^2);
                end
                finalProposalCovTheta(activeIdx,activeIdx) = finalActiveCov;
            end
            finalProposalCorrTheta = eye(p);
            if nActive > 0
                activeSD = sqrt(max(diag(finalProposalCovTheta(activeIdx,activeIdx)), realmin));
                activeCorr = finalProposalCovTheta(activeIdx,activeIdx) ./ (activeSD * activeSD.');
                activeCorr(1:nActive+1:end) = 1;
                finalProposalCorrTheta(activeIdx,activeIdx) = activeCorr;
            end

            if adaptiveApplied
                app.log(sprintf( ...
                    "Adaptive proposal frozen for %s after %d covariance updates. " + ...
                    "Acceptance: burn-in %.2f%%, post-burn-in %.2f%%, overall %.2f%%.", ...
                    string(runLabel), adaptiveUpdateCount, burnInAcceptRate, postBurnAcceptRate, acceptRate));
            end

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
                'Method','adaptive correlated random-walk Metropolis MCMC', ...
                'Parameterization','log-space', ...
                'Prior','uniform in bounded physical parameters; log-space sampling includes the change-of-variables Jacobian', ...
                'SamplingDensity','physical posterior transformed to log-parameter coordinates', ...
                'ReportedBestCriterion','maximum physical-space posterior density (equivalent to maximum likelihood for this prior)', ...
                'Iterations',nIter, ...
                'BurnIn',burnIn, ...
                'StepFrac',cfg.mcmcStepFrac, ...
                'InitialStepFrac',cfg.mcmcStepFrac, ...
                'NoiseSigma',sigmaObs, ...
                'ObservationSigmaLnN',sigmaObs, ...
                'FixedReservoirNm0',fixedReservoirNm0, ...
                'ReservoirNm0ParameterIndex',reservoirNm0Idx, ...
                'ReservoirLnNm0Value',cfg.reservoirFixedLnNm0, ...
                'ReservoirNm0Value',cfg.reservoirFixedNm0, ...
                'Seed',seedUsed, ...
                'AdaptiveProposalEnabled',adaptiveEnabled, ...
                'AdaptiveProposalApplied',adaptiveApplied, ...
                'AdaptationStart',adaptStart, ...
                'AdaptationInterval',adaptInterval, ...
                'AdaptationUpdates',adaptiveUpdateCount, ...
                'TargetAcceptance',targetAcceptance, ...
                'DiagonalMixtureProbability',diagonalMixProbability, ...
                'FinalAdaptiveScale',exp(logAdaptiveScale) .* optimalScale, ...
                'BurnInAcceptRate',burnInAcceptRate, ...
                'PostBurnAcceptRate',postBurnAcceptRate, ...
                'FinalProposalCovarianceLogSpace',finalProposalCovTheta, ...
                'FinalProposalCorrelationLogSpace',finalProposalCorrTheta, ...
                'MCMCInitialization',mcmcInitializationLabel, ...
                'MCMCUsesNLResult',false, ...
                'MCMCUsesNonlinearOptimizer',false, ...
                'MCMCScoutCount',startInfo.scoutCount, ...
                'MCMCTemperedProposalCount',startInfo.temperedProposalCount, ...
                'MCMCIndependentSearches',startInfo.eliteCount, ...
                'MCMCNearBestSearches',startInfo.nearBestEliteCount, ...
                'G1BoundsMode',mcmcBoundInfo.mode, ...
                'G1BoundsLower',mcmcBoundInfo.lower, ...
                'G1BoundsUpper',mcmcBoundInfo.upper);
            fit.solver = "MCMC";
            fit.paramStats = paramStats;
            fit.mcmcSummary = struct( ...
                'acceptRate', acceptRate, ...
                'seed', seedUsed, ...
                'nIter', nIter, ...
                'burnIn', burnIn, ...
                'stepFrac', cfg.mcmcStepFrac, ...
                'noiseSigma', sigmaObs, ...
                'observationSigmaLnN', sigmaObs, ...
                'prior', "uniform in bounded physical parameters; log-space sampling includes the change-of-variables Jacobian", ...
                'samplingDensity', "physical posterior transformed to log-parameter coordinates", ...
                'reportedBestCriterion', "maximum physical-space posterior density (maximum likelihood under the uniform physical prior)", ...
                'fixedReservoirNm0', fixedReservoirNm0, ...
                'reservoirNm0ParameterIndex', reservoirNm0Idx, ...
                'reservoirLnNm0Value', cfg.reservoirFixedLnNm0, ...
                'reservoirNm0Value', cfg.reservoirFixedNm0, ...
                'adaptiveProposalEnabled', adaptiveEnabled, ...
                'adaptiveProposalApplied', adaptiveApplied, ...
                'adaptationStart', adaptStart, ...
                'adaptationInterval', adaptInterval, ...
                'adaptationUpdates', adaptiveUpdateCount, ...
                'targetAcceptance', targetAcceptance, ...
                'diagonalMixtureProbability', diagonalMixProbability, ...
                'finalAdaptiveScale', exp(logAdaptiveScale) .* optimalScale, ...
                'burnInAcceptRate', burnInAcceptRate, ...
                'postBurnAcceptRate', postBurnAcceptRate, ...
                'correlatedAcceptRate', correlatedAcceptRate, ...
                'finalProposalCovTheta', finalProposalCovTheta, ...
                'finalProposalCorrTheta', finalProposalCorrTheta, ...
                'initialB', initialB(:).', ...
                'independentInitialization', true, ...
                'usesNLResult', false, ...
                'usesNonlinearOptimizer', false, ...
                'scoutCount', startInfo.scoutCount, ...
                'temperedProposalCount', startInfo.temperedProposalCount, ...
                'independentSearchCount', startInfo.eliteCount, ...
                'nearBestSearchCount', startInfo.nearBestEliteCount, ...
                'searchAgreementToleranceLogPosterior', startInfo.agreementToleranceLogPosterior, ...
                'startLogPosterior', startInfo.bestLogPosterior, ...
                'startB', exp(startInfo.bestTheta), ...
                'g1BoundsApplied', mcmcBoundInfo.applied, ...
                'g1BoundsMode', mcmcBoundInfo.mode, ...
                'g1Lower', mcmcBoundInfo.lower, ...
                'g1Upper', mcmcBoundInfo.upper, ...
                'g1MedianSpacing', mcmcBoundInfo.medianSpacing, ...
                'g1SizeSpan', mcmcBoundInfo.sizeSpan, ...
                'allGtauLower', mcmcBoundInfo.gtauLower, ...
                'allGtauUpper', mcmcBoundInfo.gtauUpper, ...
                'logN0Lower', mcmcBoundInfo.logN0Lower, ...
                'logN0Upper', mcmcBoundInfo.logN0Upper, ...
                'b_mean', b_mean(:).', ...
                'b_std', b_std(:).', ...
                'b_median', b_median(:).', ...
                'b_map', b_map(:).', ...
                'ciLow', ciLow(:).', ...
                'ciHigh', ciHigh(:).', ...
                'samplesPost', samplesPost, ...
                'samplesPostThin', samplesPostThin, ...
                'logPostPost', logPostPost, ...
                'logLikelihoodPost', logLikelihoodPost, ...
                'samplesTrace', samplesTrace, ...
                'iterTrace', iterTrace, ...
                'logPostTrace', logPostTrace, ...
                'logLikelihoodTrace', logLikelihoodTrace);
        end

    
        function [L, covRegularized] = regularizedProposalCholesky(~, empiricalCov, initialStep)
            empiricalCov = double(empiricalCov);
            empiricalCov = 0.5 .* (empiricalCov + empiricalCov.');
            empiricalCov(~isfinite(empiricalCov)) = 0;
            d = size(empiricalCov,1);
            if d == 0
                L = zeros(0,0);
                covRegularized = zeros(0,0);
                return;
            end

            initialStep = double(initialStep(:));
            varianceFloor = max(1e-10, 1e-4 .* initialStep.^2);
            covRegularized = empiricalCov + diag(varianceFloor);

            baseJitter = max(1e-12, 1e-10 .* mean(max(diag(covRegularized), 0)));
            success = false;
            for jj = 0:8
                jitter = (10.^jj) .* baseJitter;
                [L, flag] = chol(covRegularized + jitter .* eye(d), 'lower');
                if flag == 0 && all(isfinite(L), 'all')
                    covRegularized = covRegularized + jitter .* eye(d);
                    success = true;
                    break;
                end
            end

            if ~success
                [V,D] = eig(covRegularized, 'vector');
                eigenvalueFloor = max(min(varianceFloor), 1e-12);
                D = max(real(D), eigenvalueFloor);
                covRegularized = real(V * diag(D) * V.');
                covRegularized = 0.5 .* (covRegularized + covRegularized.');
                [L, flag] = chol(covRegularized, 'lower');
                if flag ~= 0 || any(~isfinite(L), 'all')
                    covRegularized = diag(max(initialStep.^2, 1e-8));
                    L = chol(covRegularized, 'lower');
                end
            end
        end

        % Gaussian posterior density evaluated in log-parameter coordinates.

        function [logp, logLikelihood] = logPosteriorTheta(app, theta, x, y_obs, cfg, theta_lb, theta_ub, sigmaObs)
            logLikelihood = -Inf;
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

            logLikelihood = -sum((r(:).^2) ./ (2 .* sigmaObs.^2), 'omitnan');
            activePriorIdx = theta_ub > theta_lb;
            logJacobian = sum(theta(activePriorIdx));
            logp = logLikelihood + logJacobian;
        end

        % global MCMC start. 
        function [thetaBest, logPostBest, info] = findIndependentMCMCStart( ...
                app, thetaSeed, activeIdx, x, y_obs, cfg, theta_lb, theta_ub, sigmaObs)
            thetaSeed = min(max(double(thetaSeed(:)).', theta_lb), theta_ub);
            nActive = numel(activeIdx);

            scoutCount = max(600, 180 .* max(nActive,1));
            localCount = min(round(0.40 .* scoutCount), scoutCount - 1);
            globalCount = scoutCount - localCount - 1;
            scouts = repmat(thetaSeed, scoutCount, 1);

            activeSpan = theta_ub(activeIdx) - theta_lb(activeIdx);
            activeSpan(~isfinite(activeSpan) | activeSpan <= 0) = 1;

            % local cloud around seed.
            localScalePattern = [0.05 0.12 0.25 0.50];
            for kk = 1:localCount
                frac = localScalePattern(1 + mod(kk-1,numel(localScalePattern)));
                delta = frac .* min(activeSpan, 4) .* randn(1,nActive);
                thetaTry = thetaSeed;
                thetaTry(activeIdx) = thetaSeed(activeIdx) + delta;
                scouts(1+kk,:) = app.reflectThetaIntoBounds(thetaTry, theta_lb, theta_ub, activeIdx);
            end

          
            if globalCount > 0
                globalRows = (localCount + 2):scoutCount;
                for jj = 1:nActive
                    bins = randperm(globalCount).';
                    u = (double(bins) - rand(globalCount,1)) ./ globalCount;
                    idx = activeIdx(jj);
                    scouts(globalRows,idx) = theta_lb(idx) + u .* (theta_ub(idx) - theta_lb(idx));
                end
            end

            scoutLogPost = -inf(scoutCount,1);
            for kk = 1:scoutCount
                scoutLogPost(kk) = app.logPosteriorTheta( ...
                    scouts(kk,:), x, y_obs, cfg, theta_lb, theta_ub, sigmaObs);
            end

            [sortedLogPost, order] = sort(scoutLogPost, 'descend');
            finiteOrder = order(isfinite(sortedLogPost));
            if isempty(finiteOrder)
                [thetaBest, logPostBest] = app.findFeasibleMCMCStart( ...
                    thetaSeed, x, y_obs, cfg, theta_lb, theta_ub, sigmaObs);
                info = struct('scoutCount',scoutCount, ...
                    'temperedProposalCount',0, ...
                    'eliteCount',0, ...
                    'nearBestEliteCount',0, ...
                    'agreementToleranceLogPosterior',NaN, ...
                    'eliteFinalLogPosterior',[], ...
                    'bestTheta',thetaBest, ...
                    'bestLogPosterior',logPostBest);
                return;
            end

            thetaBest = scouts(finiteOrder(1),:);
            logPostBest = scoutLogPost(finiteOrder(1));

         
            nEliteTarget = min(10, numel(finiteOrder));
            eliteRows = zeros(0,1);
            distanceScale = max(activeSpan, 1e-6);
            for kk = 1:numel(finiteOrder)
                row = finiteOrder(kk);
                if isempty(eliteRows)
                    eliteRows(end+1,1) = row;
                else
                    d = (scouts(row,activeIdx) - scouts(eliteRows,activeIdx)) ./ distanceScale;
                    if all(sqrt(sum(d.^2,2)) > 0.04)
                        eliteRows(end+1,1) = row;
                    end
                end
                if numel(eliteRows) >= nEliteTarget
                    break;
                end
            end
            if numel(eliteRows) < nEliteTarget
                addRows = setdiff(finiteOrder(1:min(numel(finiteOrder),nEliteTarget)), eliteRows, 'stable');
                eliteRows = [eliteRows; addRows(:)];
                eliteRows = eliteRows(1:min(nEliteTarget,numel(eliteRows)));
            end

            stepsPerElite = 180 + 20 .* nActive;
            baseStep = min(0.60, max(0.04, 0.08 .* activeSpan));
            temperedProposalCount = 0;
            eliteFinalLogPost = -inf(numel(eliteRows),1);
            for ee = 1:numel(eliteRows)
                thetaCurrent = scouts(eliteRows(ee),:);
                lpCurrent = scoutLogPost(eliteRows(ee));
                for ss = 1:stepsPerElite
                    progress = (ss - 1) ./ max(stepsPerElite - 1,1);
                    temperature = exp(log(12) .* (1 - progress));
                    thetaTry = thetaCurrent;
                    thetaTry(activeIdx) = thetaCurrent(activeIdx) + ...
                        sqrt(temperature) .* baseStep .* randn(1,nActive);
                    thetaTry = app.reflectThetaIntoBounds(thetaTry, theta_lb, theta_ub, activeIdx);
                    lpTry = app.logPosteriorTheta(thetaTry, x, y_obs, cfg, theta_lb, theta_ub, sigmaObs);
                    temperedProposalCount = temperedProposalCount + 1;
                    if isfinite(lpTry) && log(rand) < (lpTry - lpCurrent) ./ temperature
                        thetaCurrent = thetaTry;
                        lpCurrent = lpTry;
                    end
                    if lpCurrent > logPostBest
                        thetaBest = thetaCurrent;
                        logPostBest = lpCurrent;
                    end
                end
                eliteFinalLogPost(ee) = lpCurrent;
            end

            thetaBest = min(max(thetaBest, theta_lb), theta_ub);
            agreementTolerance = max(2, 0.5 .* nActive);
            nearBestEliteCount = sum(eliteFinalLogPost >= logPostBest - agreementTolerance);
            info = struct( ...
                'scoutCount',scoutCount, ...
                'localScoutCount',localCount, ...
                'globalScoutCount',globalCount, ...
                'eliteCount',numel(eliteRows), ...
                'nearBestEliteCount',nearBestEliteCount, ...
                'agreementToleranceLogPosterior',agreementTolerance, ...
                'eliteFinalLogPosterior',eliteFinalLogPost, ...
                'temperedProposalCount',temperedProposalCount, ...
                'bestTheta',thetaBest, ...
                'bestLogPosterior',logPostBest);
        end

       
        function theta = reflectThetaIntoBounds(~, theta, theta_lb, theta_ub, activeIdx)
            theta = double(theta(:)).';
            for jj = 1:numel(activeIdx)
                idx = activeIdx(jj);
                lo = theta_lb(idx);
                hi = theta_ub(idx);
                width = hi - lo;
                if ~isfinite(theta(idx)) || ~isfinite(width) || width <= 0
                    theta(idx) = min(max(theta(idx),lo),hi);
                    continue;
                end
                z = mod(theta(idx) - lo, 2 .* width);
                if z > width
                    z = 2 .* width - z;
                end
                theta(idx) = lo + z;
            end
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

        % Build the model-specific initial guess. Reservoir models use piecewise lines;
        
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
                if strcmp(app.normalizeSolverType(string(cfg.SolverType)), "MCMC")
                    app.log("MCMC initialization is being used for " + string(sheet) );
                else
                    app.log("Automatic model initialization is being used for " + string(sheet));
                end
                [b_init, piece] = app.computeInitialGuessPiecewiseN(x, y_obs, xx, nSeg, cfg);
                b_init = app.applyFixedReservoirNm0(b_init, cfg);
                if app.isFixedReservoirNm0(cfg)
                    app.log(sprintf("Reservoir initialization: ln(n_mix^0) is fixed at %.6g (n_mix^0 = %.6g).", cfg.reservoirFixedLnNm0, cfg.reservoirFixedNm0));
                end
                return;
            end

            % Manual mode always asks for a fresh set of picks on every run.
            
            key = char(sheet);
            app.log("Manual piecewise: select fresh segments for " + string(sheet));
            segIdx = app.manualPickSegments(x, y_obs, sheet, nSeg);
            app.ManualPWMap(key) = struct('segments',{segIdx});

            [b_init, piece] = app.computeInitialGuessPiecewiseManualN(x, y_obs, xx, segIdx, cfg);
            b_init = app.applyFixedReservoirNm0(b_init, cfg);
            if app.isFixedReservoirNm0(cfg)
                app.log(sprintf("Reservoir initialization: ln(n_mix^0) is fixed at %.6g (n_mix^0 = %.6g).", cfg.reservoirFixedLnNm0, cfg.reservoirFixedNm0));
            end
        end

        function fit = solveNonlinearFit(app, x, y_obs, b_init, cfg)
            % NL workflow
           
            if strcmp(app.normalizeModelType(string(cfg.ModelType)), "Growth-Law")
                fit = app.solveGrowthLawFitNLMDirect(x, y_obs, b_init, cfg);
                return;
            elseif strcmp(app.normalizeModelType(string(cfg.ModelType)), "Linear")
                fit = app.solveLinearFitNLMDirect(x, y_obs, b_init, cfg);
                return;
            elseif app.isFixedReservoirNm0(cfg)
                fit = app.solveReservoirFixedNmFit(x, y_obs, b_init, cfg);
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
            optsLSQ = optimoptions('lsqnonlin', ...
                'Display','off', ...
                'MaxIterations', cfg.maxIter, ...
                'FunctionTolerance', cfg.funcTol, ...
                'StepTolerance', cfg.stepTol);

            try
                [theta_lsq,resnorm,residual,exitflag,output,~,jacobianTheta] = lsqnonlin( ...
                    @(theta) app.nlResidualThetaBounded(theta, x, y_obs, cfg, theta_lb, theta_ub), ...
                    theta_init, theta_lb, theta_ub, optsLSQ);
            catch ME_lsq
                error("Bounded lsqnonlin failed from the model-aware initial solution: %s", ME_lsq.message);
            end

            b_lsq = exp(theta_lsq);
            y_lsq = app.evalModel(b_lsq, x, cfg);
            residual = y_obs - y_lsq;
            sse = sum(residual.^2, 'omitnan');
            if ~isfinite(sse)
                error("Bounded lsqnonlin returned a non-finite residual sum of squares.");
            end

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

            fit = app.runFitNLMFromLSQ(x, y_obs, bestLSQ, cfg);
        end

        function fit = solveReservoirFixedNmFit(app, x, y_obs, b_init, cfg)
            % Fit all free reservoir parameters while holding n_mix^0 exactly
            % fixed. This supports both the 2- and 3-Reservoir NL models.
            if ~(license('test','optimization_toolbox') && exist('lsqnonlin','file') == 2)
                error("Fixed-n_mix^0 reservoir inversion requires lsqnonlin from Optimization Toolbox.");
            end

            modelType = app.normalizeModelType(string(cfg.ModelType));
            [freeIdx, fixedIdx, nParams] = app.getFixedReservoirParameterLayout(cfg);
            [lb, ub] = app.getHybridBounds(cfg);
            lbFit = max(lb, 1e-300);
            ub = max(ub, lbFit .* (1 + 1e-12));
            b_init = app.projectToBoundsForHybrid(b_init, lbFit, ub, cfg);
            b_init = app.applyFixedReservoirNm0(b_init, cfg);
            if numel(b_init) ~= nParams
                error("Fixed-n_mix^0 %s inversion received an invalid parameter count.", modelType);
            end

            theta0 = log(max(b_init(freeIdx), realmin));
            thetaLb = log(lbFit(freeIdx));
            thetaUb = log(ub(freeIdx));
            optsLSQ = optimoptions('lsqnonlin', ...
                'Display','off', ...
                'MaxIterations',cfg.maxIter, ...
                'FunctionTolerance',cfg.funcTol, ...
                'StepTolerance',cfg.stepTol);

            residualFun = @(thetaFree) app.reservoirFixedNmResidual(thetaFree, x, y_obs, cfg);
            [thetaFree,~,~,exitflag,output,~,jacobianFree] = ...
                lsqnonlin(residualFun, theta0, thetaLb, thetaUb, optsLSQ);

            bFit = app.buildReservoirFixedNmParameters(thetaFree, cfg);
            yFit = app.evalModel(bFit, x, cfg);
            residual = y_obs - yFit;
            sse = sum(residual.^2, 'omitnan');
            if ~isfinite(sse) || any(~isfinite(bFit)) || ...
                    ~app.isTurnoverBranchValid(bFit,cfg)
                error("Fixed-n_mix^0 %s inversion returned a non-finite solution.", modelType);
            end

            thetaFull = log(max(bFit, realmin));
            freeStats = app.makeNaNParameterStats( ...
                numel(freeIdx), numel(y_obs), bFit(freeIdx), thetaFree);
            fitnlmModel = [];
            fitnlmCoefficients = table();

            
            if exist('fitnlm','file') == 2
                try
                    opts = statset('fitnlm');
                    opts.Display = 'off';
                    opts.MaxIter = cfg.maxIter;
                    opts.TolFun = cfg.funcTol;
                    opts.TolX = cfg.stepTol;
                    opts.RobustWgtFun = 'bisquare';
                    modelfun = @(theta,xdata) app.evalReservoirFixedNmForFitNLMTheta(theta, xdata, cfg);
                    fitnlmModel = fitnlm(x, y_obs, modelfun, thetaFree, 'Options', opts);
                    thetaCandidate = fitnlmModel.Coefficients.Estimate(:).';
                    bCandidate = app.buildReservoirFixedNmParameters(thetaCandidate, cfg);
                    yCandidate = app.evalModel(bCandidate, x, cfg);
                    sseCandidate = sum((y_obs - yCandidate).^2, 'omitnan');
                    if isfinite(sseCandidate) && all(isfinite(bCandidate)) && ...
                            app.isTurnoverBranchValid(bCandidate,cfg)
                        thetaFree = thetaCandidate;
                        bFit = bCandidate;
                        thetaFull = log(max(bFit, realmin));
                        residual = y_obs - yCandidate;
                        sse = sseCandidate;
                        freeStats = app.computeParameterStatsFromFitNLM( ...
                            fitnlmModel, bFit(freeIdx), thetaFree, numel(y_obs));
                        fitnlmCoefficients = fitnlmModel.Coefficients;
                    end
                catch ME
                    app.log("Fixed-n_mix^0 fitnlm statistics were unavailable; retaining bounded lsqnonlin result: " + string(ME.message));
                    fitnlmModel = [];
                    fitnlmCoefficients = table();
                end
            end

            paramStats = app.expandReservoirFixedNmStats( ...
                freeStats, bFit, thetaFull, freeIdx, fixedIdx, numel(y_obs));
            fit = struct( ...
                'theta_fit',thetaFull(:).', ...
                'b_fit',bFit(:).', ...
                'resnorm',sse, ...
                'residual',residual(:), ...
                'exitflag',exitflag, ...
                'output',struct('Method',char("bounded fixed-n_mix^0 " + modelType + " inversion"), ...
                    'FixedLnNm0',cfg.reservoirFixedLnNm0, ...
                    'FixedNm0',cfg.reservoirFixedNm0, ...
                    'LSQOutput',output), ...
                'jacobian',jacobianFree, ...
                'jacobianScale',"free log-parameters", ...
                'fitnlmModel',fitnlmModel, ...
                'fitnlmCoefficients',fitnlmCoefficients, ...
                'paramStats',paramStats, ...
                'solver',"fitnlm");
        end

        function [freeIdx, fixedIdx, nParams] = getFixedReservoirParameterLayout(app, cfg)
            modelType = app.normalizeModelType(string(cfg.ModelType));
            if strcmp(modelType,"3-Reservoir")
                freeIdx = [1 2 3 4 6];
                fixedIdx = 5;
                nParams = 6;
            elseif strcmp(modelType,"2-Reservoir")
                freeIdx = [1 2 4];
                fixedIdx = 3;
                nParams = 4;
            else
                error("A fixed n_mix^0 is only available for 2- and 3-Reservoir models.");
            end
        end

        function b = buildReservoirFixedNmParameters(app, thetaFree, cfg)
            [freeIdx, fixedIdx, nParams] = app.getFixedReservoirParameterLayout(cfg);
            thetaFree = double(thetaFree(:)).';
            if numel(thetaFree) ~= numel(freeIdx)
                b = nan(1,nParams);
                return;
            end
            b = ones(1,nParams);
            b(freeIdx) = exp(thetaFree);
            b(fixedIdx) = cfg.reservoirFixedNm0;
        end

        function r = reservoirFixedNmResidual(app, thetaFree, x, y_obs, cfg)
            b = app.buildReservoirFixedNmParameters(thetaFree, cfg);
            r = app.nlResidual(b, x, y_obs, cfg);
        end

        function y = evalReservoirFixedNmForFitNLMTheta(app, thetaFree, xdata, cfg)
            b = app.buildReservoirFixedNmParameters(thetaFree, cfg);
            if ~app.isTurnoverBranchValid(b, cfg)
                y = 1e8 .* ones(size(xdata(:)));
                return;
            end
            y = app.evalModel(b, xdata(:), cfg);
            if isempty(y) || numel(y) ~= numel(xdata) || any(~isfinite(y)) || ~isreal(y)
                y = 1e8 .* ones(size(xdata(:)));
            else
                y = real(y(:));
            end
        end

        function stats = expandReservoirFixedNmStats(app, freeStats, bFit, thetaFull, freeIdx, fixedIdx, nObs)
            nParams = numel(bFit);
            stats = app.makeNaNParameterStats(nParams, nObs, bFit, thetaFull);
            fields = {'se','seLog','tStat','pValue','ciLow','ciHigh','ciLowLog','ciHighLog'};
            for ff = 1:numel(fields)
                f = fields{ff};
                if isfield(freeStats,f) && numel(freeStats.(f)) >= numel(freeIdx)
                    stats.(f)(freeIdx) = freeStats.(f)(1:numel(freeIdx));
                end
            end
            stats.se(fixedIdx) = 0;
            stats.seLog(fixedIdx) = 0;
            stats.tStat(fixedIdx) = NaN;
            stats.pValue(fixedIdx) = NaN;
            stats.ciLow(fixedIdx) = bFit(fixedIdx);
            stats.ciHigh(fixedIdx) = bFit(fixedIdx);
            stats.ciLowLog(fixedIdx) = thetaFull(fixedIdx);
            stats.ciHighLog(fixedIdx) = thetaFull(fixedIdx);
            stats.dof = max(nObs - numel(freeIdx), 0);
            if isfield(freeStats,'sigma2'); stats.sigma2 = freeStats.sigma2; end
            stats.fitScale = "reservoir-fixed-nm0-physical-b-space";
            if isfield(freeStats,'coefficientTable')
                stats.coefficientTable = freeStats.coefficientTable;
            end
            stats.bFit = bFit(:).';
            stats.thetaFit = thetaFull(:).';
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

                if isfinite(sse) && all(isfinite(b_fit)) && ...
                        app.isTurnoverBranchValid(b_fit, cfg)
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

            if strcmp(modelType, "3-Reservoir")
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

        function [gtLow, gtHigh, deltaL, lSpan] = computeAdaptiveMCMCG1Bounds(~, x)
            x = double(x(:));
            x = x(isfinite(x) & x >= 0);
            x = unique(sort(x));
            if numel(x) < 2
                error("At least two distinct included L values are required for adaptive G1tau1 bounds.");
            end

            dL = diff(x);
            dL = dL(isfinite(dL) & dL > 0);
            if isempty(dL)
                error("No positive spacing exists between the included L values.");
            end

            deltaL = median(dL);
            lSpan = max(x) - min(x);
            if ~isfinite(deltaL) || deltaL <= 0 || ~isfinite(lSpan) || lSpan <= 0
                error("The included L values do not define a finite positive spacing and span.");
            end

            gtLow = max(0.1 * deltaL, 1e-300);
            gtHigh = max(10 * lSpan, gtLow * (1 + 1e-6));
        end

        function [lb, ub, info] = getMCMCHybridBounds(app, x, y_obs, cfg)
     
            [lb, ub] = app.getHybridBounds(cfg);
            modelType = app.normalizeModelType(string(cfg.ModelType));

            [gtLow, gtHigh, deltaL, lSpan] = app.computeAdaptiveMCMCG1Bounds(x);
            yFinite = double(y_obs(isfinite(y_obs)));
            if isempty(yFinite)
                error("MCMC bounds require at least one finite ln(n) observation.");
            end

 
            logMargin = 10;
            logN0Low = max(log(realmin), min(yFinite) - logMargin);
            logN0High = min(log(1e14), max(yFinite) + logMargin);
            if logN0High <= logN0Low
                logN0High = logN0Low + 2 .* logMargin;
            end
            n0Low = exp(logN0Low);
            n0High = exp(logN0High);

            if strcmp(modelType, "3-Reservoir")
                n0Idx = [1 3 5];
                gtIdx = [2 4 6];
            elseif strcmp(modelType, "2-Reservoir")
                n0Idx = [1 3];
                gtIdx = [2 4];
            elseif strcmp(modelType, "Growth-Law")
                n0Idx = 1;
                gtIdx = 3;
                
                lb(2) = max(lb(2), 1e-4);
                ub(2) = min(ub(2), 1e4);
            else
                n0Idx = 1;
                gtIdx = 2;
            end

            lb(n0Idx) = max(lb(n0Idx), n0Low);
            ub(n0Idx) = min(ub(n0Idx), n0High);
            lb(gtIdx) = max(lb(gtIdx), gtLow);
            ub(gtIdx) = min(ub(gtIdx), gtHigh);
            ub = max(ub, lb .* (1 + 1e-8));

            info = struct( ...
                'applied', true, ...
                'mode', "all-parameter data-scaled finite support", ...
                'lower', gtLow, ...
                'upper', gtHigh, ...
                'gtauLower', gtLow, ...
                'gtauUpper', gtHigh, ...
                'logN0Lower', logN0Low, ...
                'logN0Upper', logN0High, ...
                'logN0Margin', logMargin, ...
                'medianSpacing', deltaL, ...
                'sizeSpan', lSpan);
        end

        function r = nlResidualThetaBounded(app, theta, x, y_obs, cfg, theta_lb, theta_ub)
            if any(~isfinite(theta)) || any(theta < theta_lb) || any(theta > theta_ub)
                r = 1e9 * ones(size(y_obs));
                return;
            end
            b = exp(theta);
            r = app.nlResidual(b, x, y_obs, cfg);
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
            b = app.applyFixedModelParameters(b, cfg);

            modelType = app.normalizeModelType(string(cfg.ModelType));
            if strcmp(modelType, "3-Reservoir") && numel(b) >= 6
                if abs(b(2) - b(6)) < 1e-8
                    b(6) = min(ub(6), max(lb(6), b(6) * 1.10 + 1e-6));
                end
                if abs(b(4) - b(6)) < 1e-8
                    b(6) = min(ub(6), max(lb(6), b(6) * 1.20 + 2e-6));
                end
            elseif strcmp(modelType, "2-Reservoir") && numel(b) >= 4
                if abs(b(2) - b(4)) < 1e-8
                    b(4) = min(ub(4), max(lb(4), b(4) * 1.10 + 1e-6));
                end
            end
            b = app.projectToTurnoverBranch(b, lb, ub, cfg);
        end

        % Enable the positive-turnover branch only when a reservoir
        % CSD has a positive small-L segment
        function cfg = configureTurnoverBranch(app, cfg, x, y_obs, piece)
            cfg.enforceTurnoverOrdering = false;
            modelType = app.normalizeModelType(string(cfg.ModelType));
            if ~any(strcmp(modelType,["2-Reservoir","3-Reservoir"])) || ...
                    ~isfield(piece,'m') || isempty(piece.m) || ...
                    ~isfinite(piece.m(1)) || piece.m(1) <= 0 || ...
                    numel(piece.m) < 2 || ...
                    ~any(piece.m(2:end) < 0 & isfinite(piece.m(2:end)))
                return;
            end
            [~,peakInfo] = app.estimateObservedTurnover(x,y_obs);
            cfg.enforceTurnoverOrdering = peakInfo.valid;
        end

        % Check the constraints required by the effective two-reservoir
        % subsystem.
        function tf = isTurnoverBranchValid(app, b, cfg)
            tf = true;
            try
                enabled = isfield(cfg,'enforceTurnoverOrdering') && ...
                    logical(cfg.enforceTurnoverOrdering);
                if ~enabled
                    return;
                end
                b = double(b(:)).';
                relativeGap = 1e-8;
                modelType = app.normalizeModelType(string(cfg.ModelType));
                if strcmp(modelType,"2-Reservoir")
                    tf = numel(b) >= 4 && all(isfinite(b(1:4))) && ...
                        b(2) > b(4) .* (1 + relativeGap) && ...
                        b(1) > b(3) .* (1 + relativeGap);
                elseif strcmp(modelType,"3-Reservoir")
                    tf = numel(b) >= 6 && all(isfinite(b(1:6))) && ...
                        b(4) > b(6) .* (1 + relativeGap) && ...
                        b(3) > b(5) .* (1 + relativeGap);
                end
            catch
                tf = false;
            end
        end

    
        function b = projectToTurnoverBranch(app, b, lb, ub, cfg)
            if ~isfield(cfg,'enforceTurnoverOrdering') || ...
                    ~logical(cfg.enforceTurnoverOrdering)
                return;
            end
            modelType = app.normalizeModelType(string(cfg.ModelType));
            if strcmp(modelType,"2-Reservoir") && numel(b) >= 4
                b = app.projectStrictPositivePair(b,lb,ub,2,4);
                b = app.projectStrictPositivePair(b,lb,ub,1,3);
            elseif strcmp(modelType,"3-Reservoir") && numel(b) >= 6
                b = app.projectStrictPositivePair(b,lb,ub,4,6);
                b = app.projectStrictPositivePair(b,lb,ub,3,5);
            end
            b = app.applyFixedModelParameters(b,cfg);
        end

        function b = projectStrictPositivePair(~, b, lb, ub, upstreamIdx, shallowIdx)
            gap = 1e-4;
            if b(upstreamIdx) > b(shallowIdx) .* (1 + gap)
                return;
            end
            upperUpstream = ub(upstreamIdx) .* (1 - 1e-12);
            lowerUpstream = lb(upstreamIdx) .* (1 + 1e-12);
            upperShallow = ub(shallowIdx) .* (1 - 1e-12);
            lowerShallow = lb(shallowIdx) .* (1 + 1e-12);

            b(upstreamIdx) = min(upperUpstream, max(lowerUpstream, ...
                b(shallowIdx) .* (1 + 2 .* gap)));
            if b(upstreamIdx) <= b(shallowIdx) .* (1 + gap)
                b(shallowIdx) = max(lowerShallow, min(upperShallow, ...
                    b(upstreamIdx) ./ (1 + 2 .* gap)));
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
            if ~app.isTurnoverBranchValid(b, cfg)
                y = 1e8 .* ones(size(xdata));
                return;
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

        function r = nlResidual(app, b, x, y_obs, cfg)
            if any(~isfinite(b))
                r = 1e9 * ones(size(y_obs));
                return;
            end
            if ~app.isTurnoverBranchValid(b, cfg)
                r = 1e9 * ones(size(y_obs));
                return;
            end
            modelType = app.normalizeModelType(string(cfg.ModelType));
            if strcmp(modelType, "2-Reservoir")
                if numel(b) < 4 || abs(b(2) - b(4)) < 1e-10
                    r = 1e6 * ones(size(y_obs));
                    return;
                end
            elseif strcmp(modelType, "3-Reservoir")
                b = app.applyFixedReservoirNm0(b, cfg);
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

             % Convert uncertainty from theta = log(b) space to physical b-space.
            try
                stats.se = abs(b_fit(:).') .* stats.seLog;
            catch
            end
            
            try
                stats.ciLow = exp(stats.ciLowLog);
                stats.ciHigh = exp(stats.ciHighLog);
            catch
            end
            
            % Calculate p-values only for regular parameters.
            % Boundary or unidentified parameters are reported as NaN.
            stats.tStat(:) = NaN;
            stats.pValue(:) = NaN;
            
            try
                bRow = b_fit(:).';
            
                valid = ...
                    isfinite(bRow) & bRow > 0 & ...
                    isfinite(stats.se) & stats.se > 0 & ...
                    isfinite(stats.ciLow) & stats.ciLow > 0 & ...
                    isfinite(stats.ciHigh) & ...
                    stats.ciHigh > stats.ciLow;
            
                if any(valid)
                    stats.tStat(valid) = bRow(valid) ./ stats.se(valid);
                    stats.pValue(valid) = 2 .* ...
                        app.safeTCdf(-abs(stats.tStat(valid)), stats.dof);
                end
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
       
        function y = evalModel(app, b, x, cfg)
            modelType = app.normalizeModelType(string(cfg.ModelType));
            if strcmp(modelType, "3-Reservoir")
                b = app.applyFixedReservoirNm0(b, cfg);
                y = app.threeReservoirModel(b, x, cfg.alpha1);
            elseif strcmp(modelType, "Growth-Law")
                b = app.applyFixedGrowthLawN0(b, cfg);
                y = app.growthLawModel(b, x);
            elseif strcmp(modelType, "Linear")
                y = app.linearModel(b, x);
            else
                b = app.applyFixedReservoirNm0(b, cfg);
                y = app.twoReservoirModel(b, x);
            end
        end

        function names = getParamNames(app, modelType)
            names = app.getParamDisplayNames(modelType);
        end

        % Two- reservoir/mixing CSD model evaluated in log-space.
        function y = twoReservoirModel(~, b, x)
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

        % Three- reservoir/mixing CSD model.
        function y = threeReservoirModel(~, b, x, alpha1)
            % 6-parameter 3-Reservoir model:
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

        function tf = isFixedReservoirNm0(app, cfg)
            tf = false;
            try
                modelType = app.normalizeModelType(string(cfg.ModelType));
                tf = any(strcmp(modelType,["2-Reservoir","3-Reservoir"])) && ...
                    isfield(cfg,'reservoirFixNm0') && logical(cfg.reservoirFixNm0) && ...
                    isfield(cfg,'reservoirFixedNm0') && isfinite(cfg.reservoirFixedNm0) && cfg.reservoirFixedNm0 > 0;
            catch
                tf = false;
            end
        end

        function idx = getReservoirNm0Index(app, modelType)
            modelType = app.normalizeModelType(string(modelType));
            if strcmp(modelType,"3-Reservoir")
                idx = 5;
            elseif strcmp(modelType,"2-Reservoir")
                idx = 3;
            else
                idx = NaN;
            end
        end

        function b = applyFixedReservoirNm0(app, b, cfg)
            b = double(b(:)).';
            if app.isFixedReservoirNm0(cfg)
                idx = app.getReservoirNm0Index(cfg.ModelType);
                if numel(b) < idx
                    b(end+1:idx) = 1;
                end
                b(idx) = cfg.reservoirFixedNm0;
            end
        end

        function b = applyFixedModelParameters(app, b, cfg)
            b = app.applyFixedGrowthLawN0(b, cfg);
            b = app.applyFixedReservoirNm0(b, cfg);
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
            if strcmp(modelType, "3-Reservoir")
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
                    if isfield(piece,'breakX') && ~isempty(piece.breakX) && isfinite(piece.breakX(1))
                        mask1 = x <= piece.breakX(1);
                        y_pw(mask1) = piece.m(1).*x(mask1) + piece.c(1);
                        y_pw(~mask1) = piece.m(2).*x(~mask1) + piece.c(2);
                    else
                        idx = max(1, min(numel(x), round(piece.idx(1))));
                        y_pw(1:idx) = piece.m(1).*x(1:idx) + piece.c(1);
                        if idx < numel(x)
                            y_pw(idx+1:end) = piece.m(2).*x(idx+1:end) + piece.c(2);
                        end
                    end
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
                    if isfield(piece,'breakX') && numel(piece.breakX) >= 2 && all(isfinite(piece.breakX(1:2)))
                        mask1 = x <= piece.breakX(1);
                        mask2 = x > piece.breakX(1) & x <= piece.breakX(2);
                        mask3 = x > piece.breakX(2);
                        y_pw(mask1) = piece.m(1).*x(mask1) + piece.c(1);
                        y_pw(mask2) = piece.m(2).*x(mask2) + piece.c(2);
                        y_pw(mask3) = piece.m(3).*x(mask3) + piece.c(3);
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

        % Automatic reservoir initialization.  
        function [b_init, piece] = computeInitialGuessPiecewiseN(app, x, y_obs, xx, nSeg, cfg)
            piece = app.findAutomaticPiecewiseLines(x, y_obs, xx, nSeg);
            if strcmp(app.normalizeSolverType(string(cfg.SolverType)), "MCMC")
                [b_init, initInfo] = app.makeIndependentMCMCReservoirStart(x, y_obs, piece, cfg);
            else
                [b_init, initInfo] = app.makeModelAwareReservoirStart(x, y_obs, xx, piece, cfg);
            end
            piece.initializer = initInfo;

        end

        % Select automatic breakpoints by total piecewise SSE. Each segment
        % contains at least three points (four whenever the dataset permits)
        % and must span a finite portion of the measured L range. Positive
        % slopes are allowed 
        function piece = findAutomaticPiecewiseLines(app, x, y_obs, xx, nSeg)
            x = double(x(:));
            y_obs = double(y_obs(:));
            good = isfinite(x) & isfinite(y_obs);
            x = x(good);
            y_obs = y_obs(good);
            [x, ord] = sort(x);
            y_obs = y_obs(ord);

            n = numel(x);
            minPoints = min(4, max(3, floor(n ./ nSeg)));
            if n < nSeg .* 3
                error("Need at least %d data points for %d-segment automatic initialization.", nSeg .* 3, nSeg);
            end

            xu = unique(x);
            if numel(xu) < nSeg + 1
                error("Automatic piecewise initialization requires more distinct L values.");
            end
            dL = diff(xu);
            dL = dL(isfinite(dL) & dL > 0);
            lSpan = max(x) - min(x);
            if isempty(dL) || ~isfinite(lSpan) || lSpan <= 0
                error("Automatic piecewise initialization requires a finite positive L range.");
            end
            minSpanTarget = max(2 .* median(dL), 0.05 .* lSpan);

            best = struct('sse',inf,'idx',[],'breakX',[],'m',[],'c',[],'r2',[],'minSpan',NaN);
            spanPasses = unique([minSpanTarget, max(median(dL),0.01.*lSpan), max(min(dL),eps(lSpan))], 'stable');
            for spanPass = 1:numel(spanPasses)
                minSpan = spanPasses(spanPass);
                if nSeg == 2
                    for idx1 = minPoints:(n-minPoints)
                        idxSets = {1:idx1, (idx1+1):n};
                        if ~app.piecewiseSegmentsMeetSpan(x, idxSets, minSpan)
                            continue;
                        end
                        [m, c, r2, sse] = app.fitPiecewiseIndexSets(x, y_obs, idxSets);
                        if sse < best.sse
                            best = struct('sse',sse,'idx',idx1, ...
                                'breakX',0.5 .* (x(idx1) + x(idx1+1)), ...
                                'm',m,'c',c,'r2',r2,'minSpan',minSpan);
                        end
                    end
                else
                    for idx1 = minPoints:(n-2.*minPoints)
                        for idx2 = (idx1+minPoints):(n-minPoints)
                            idxSets = {1:idx1, (idx1+1):idx2, (idx2+1):n};
                            if ~app.piecewiseSegmentsMeetSpan(x, idxSets, minSpan)
                                continue;
                            end
                            [m, c, r2, sse] = app.fitPiecewiseIndexSets(x, y_obs, idxSets);
                            if sse < best.sse
                                best = struct('sse',sse,'idx',[idx1 idx2], ...
                                    'breakX',[0.5 .* (x(idx1) + x(idx1+1)), 0.5 .* (x(idx2) + x(idx2+1))], ...
                                    'm',m,'c',c,'r2',r2,'minSpan',minSpan);
                            end
                        end
                    end
                end
                if isfinite(best.sse)
                    break;
                end
            end

            if ~isfinite(best.sse)
                error("No valid automatic piecewise segmentation was found.");
            end

            piece = struct( ...
                'manual',false, ...
                'nSeg',nSeg, ...
                'idx',best.idx, ...
                'breakX',best.breakX, ...
                'm',best.m, ...
                'c',best.c, ...
                'r2',best.r2, ...
                'r2avg',mean(best.r2,'omitnan'), ...
                'sse',best.sse, ...
                'minPoints',minPoints, ...
                'minSpan',best.minSpan);
            for ii = 1:nSeg
                piece.(sprintf('y%d',ii)) = best.m(ii) .* xx + best.c(ii);
            end
        end

        function tf = piecewiseSegmentsMeetSpan(~, x, idxSets, minSpan)
            tf = true;
            if minSpan <= 0
                return;
            end
            for ii = 1:numel(idxSets)
                xi = x(idxSets{ii});
                if isempty(xi) || max(xi) - min(xi) < minSpan
                    tf = false;
                    return;
                end
            end
        end

        function [m, c, r2, totalSSE] = fitPiecewiseIndexSets(~, x, y, idxSets)
            nSeg = numel(idxSets);
            m = nan(1,nSeg);
            c = nan(1,nSeg);
            r2 = nan(1,nSeg);
            totalSSE = 0;
            for ii = 1:nSeg
                idx = idxSets{ii};
                p = polyfit(x(idx), y(idx), 1);
                m(ii) = p(1);
                c(ii) = p(2);
                yhat = polyval(p, x(idx));
                ssRes = sum((y(idx) - yhat).^2);
                ssTot = sum((y(idx) - mean(y(idx))).^2);
                totalSSE = totalSSE + ssRes;
                if ssTot > 0
                    r2(ii) = 1 - ssRes ./ ssTot;
                end
            end
        end

        % MANUAL piecewise initialization. The groups the user clicks

        function [b_init, piece] = computeInitialGuessPiecewiseManualN(app, x, y_obs, xx, segIdx, cfg)
            nSeg = numel(segIdx);
            centers = nan(1,nSeg);
            for ii = 1:nSeg
                idx = unique(segIdx{ii}(:));
                if numel(idx) < 2
                    error("Manual piecewise requires >=2 points in each segment.");
                end
                centers(ii) = median(x(idx),'omitnan');
            end
            [~, segOrder] = sort(centers);
            sortedCenters = centers(segOrder);
            segIdx = segIdx(segOrder);

            m = nan(1,nSeg);
            c = nan(1,nSeg);
            r2 = nan(1,nSeg);
            totalSSE = 0;
            for ii = 1:nSeg
                idx = unique(segIdx{ii}(:));
                p = polyfit(x(idx), y_obs(idx), 1);
                m(ii) = p(1);
                c(ii) = p(2);
                yhat = polyval(p, x(idx));
                ssRes = sum((y_obs(idx)-yhat).^2);
                ssTot = sum((y_obs(idx)-mean(y_obs(idx))).^2);
                totalSSE = totalSSE + ssRes;
                if ssTot > 0
                    r2(ii) = 1 - ssRes ./ ssTot;
                end
            end

            piece = struct( ...
                'manual',true, ...
                'nSeg',nSeg, ...
                'idx',nan(1,max(1,nSeg-1)), ...
                'idxSegments',{segIdx}, ...
                'm',m, ...
                'c',c, ...
                'r2',r2, ...
                'r2avg',mean(r2,'omitnan'), ...
                'sse',totalSSE, ...
                'segmentMedianL',sortedCenters, ...
                'selectionOrderToSortedOrder',segOrder);
            for ii = 1:nSeg
                piece.(sprintf('y%d',ii)) = m(ii).*xx + c(ii);
                piece.(sprintf('idx%d',ii)) = unique(segIdx{ii}(:)).';
            end

            [b_init, initInfo] = app.makeStrictManualReservoirStart(piece, cfg);
            piece.initializer = initInfo;
        end

   
        %
        % 2-Reservoir:
        %   small-L line supplies N(0)=n_mix^0 and dlnN/dL at L=0;
        %   large-L line supplies the deep exponential asymptote.
        %
        % 3-Reservoir:
        %   small-L line supplies N(0) and its limiting slope;
        %   middle- and large-L lines supply the Reservoir-2 and Reservoir-1
        %   exponential components, respectively.
        function [b_init, info] = makeStrictManualReservoirStart(app, piece, cfg)
            modelType = app.normalizeModelType(string(cfg.ModelType));
            m = double(piece.m(:)).';
            c = double(piece.c(:)).';

            if strcmp(modelType,"3-Reservoir")
                expectedSeg = 3;
            else
                expectedSeg = 2;
            end
            if numel(m) ~= expectedSeg || numel(c) ~= expectedSeg || ...
                    any(~isfinite(m)) || any(~isfinite(c))
                error("Manual piecewise initialization requires %d finite, auto-sorted fitted segments for %s.", expectedSeg, modelType);
            end

            % Segment 1 is always the smallest-L group after median-L sorting.
            % Use its extrapolated L=0 intercept unless n_mix^0 is explicitly fixed.
            if app.isFixedReservoirNm0(cfg)
                nMix = double(cfg.reservoirFixedNm0);
            else
                nMix = exp(c(1));
            end
            if ~isfinite(nMix) || nMix <= 0
                error("Manual small-L segment gives an invalid n_mix^0. Re-pick the manual segments.");
            end
            s0 = m(1);

            if strcmp(modelType,"2-Reservoir")
                % Auto-sorted segment 2 is the large-L/deep-reservoir segment.
                if m(2) >= 0
                    error("Manual 2-Reservoir initialization requires the auto-sorted large-L segment to have a negative slope. Re-pick the manual segments.");
                end
                g1 = -1 ./ m(2);
                A1 = exp(c(2));
                r1 = A1 ./ nMix;
                denom = s0 + r1 ./ g1;
                if ~isfinite(denom) || abs(denom) <= 100 .* eps(max(1,abs(s0)))
                    error("Manual 2-Reservoir segments imply a singular shallow-reservoir Gtau. Re-pick the manual segments.");
                end
                gMix = (r1 - 1) ./ denom;
                n1 = A1 .* (g1 - gMix) ./ g1;

                if any(~isfinite([n1 g1 nMix gMix])) || any([n1 g1 nMix gMix] <= 0) || g1 <= gMix
                    error("The selected manual 2-Reservoir segments do not map to a physically valid ordered reservoir start (required G1tau1 > Gmix taumix > 0 and positive n0 values). Re-pick the manual segments.");
                end
                b_init = [n1, g1, nMix, gMix];
                componentAmplitudes = [A1, nMix - A1];

            else
                % Auto-sorted segment 2 is intermediate L (Reservoir 2) and
                % segment 3 is large L (Reservoir 1). 
                if m(2) >= 0 || m(3) >= 0
                    error("Manual 3-Reservoir initialization requires the auto-sorted intermediate- and large-L segments to have negative slopes. Re-pick the manual segments.");
                end
                g2 = -1 ./ m(2);
                g1 = -1 ./ m(3);
                if g1 <= g2
                    error("The selected manual 3-Reservoir segments imply G1tau1 <= G2tau2. The large-L segment must represent the longer deep-reservoir scale. Re-pick the manual segments.");
                end

                A2 = exp(c(2));
                A1 = exp(c(3));
                r1 = A1 ./ nMix;
                r2 = A2 ./ nMix;
                denom = s0 + r1 ./ g1 + r2 ./ g2;
                if ~isfinite(denom) || abs(denom) <= 100 .* eps(max(1,abs(s0)))
                    error("Manual 3-Reservoir segments imply a singular shallow-reservoir Gtau. Re-pick the manual segments.");
                end
                gMix = (r1 + r2 - 1) ./ denom;

                alpha1 = double(cfg.alpha1);
                alpha2 = 1 - alpha1;
                if ~isfinite(alpha1) || ~isfinite(alpha2) || alpha1 <= 0 || alpha2 <= 0
                    error("Manual 3-Reservoir initialization requires 0 < w1 < 1 and w2 = 1-w1.");
                end
                n1 = A1 .* (g1 - gMix) ./ (alpha1 .* g1);
                n2 = A2 .* (g2 - gMix) ./ (alpha2 .* g2);

                if any(~isfinite([n1 g1 n2 g2 nMix gMix])) || ...
                        any([n1 g1 n2 g2 nMix gMix] <= 0) || ...
                        ~(g1 > g2 && g2 > gMix)
                    error("The selected manual 3-Reservoir segments do not map to a physically valid ordered reservoir start (required G1tau1 > G2tau2 > Gmix taumix > 0 and positive n0 values). Re-pick the manual segments.");
                end
                b_init = [n1, g1, n2, g2, nMix, gMix];
                componentAmplitudes = [A1, A2, nMix - A1 - A2];
            end

            [lb, ub] = app.getHybridBounds(cfg);
            if any(b_init <= max(lb,0)) || any(b_init >= ub)
                error("The selected manual segments imply starting parameters outside the configured model bounds. Re-pick the manual segments.");
            end

            info = struct( ...
                'method',"strict manual piecewise analytical conversion", ...
                'usesAutomaticBreakpoints',false, ...
                'usesCandidateEnumeration',false, ...
                'usesCompleteDataScreening',false, ...
                'usesNonlinearOptimizer',false, ...
                'segmentsAutoSortedByMedianL',true, ...
                'smallSizeSlope',s0, ...
                'componentAmplitudes',componentAmplitudes, ...
                'initialParameters',b_init);
        end

        % MCMC reservoir initializer. 
        function [b_init, info] = makeIndependentMCMCReservoirStart(app, x, y_obs, piece, cfg)
            [candidates, candidateInfo] = app.generateReservoirCandidates(x, y_obs, piece, cfg, []);
            [lbInit, ubInit] = app.getInitializationBounds(x, cfg);

            nCandidates = size(candidates,1);
            candidateSSE = inf(nCandidates,1);
            for ii = 1:nCandidates
                candidates(ii,:) = app.projectToBoundsForHybrid( ...
                    candidates(ii,:), lbInit, ubInit, cfg);
                candidateSSE(ii) = app.nlObjective(candidates(ii,:), x, y_obs, cfg);
            end

            [bestSSE, bestIdx] = min(candidateSSE);
            if isempty(bestIdx) || ~isfinite(bestSSE)
                error("MCMC initialization could not find a finite complete-model candidate.");
            end

            b_init = candidates(bestIdx,:);
            info = struct( ...
                'method',"MCMC-only deterministic complete-model screening", ...
                'usesNonlinearOptimizer',false, ...
                'usesNLResult',false, ...
                'positiveShallowSlope',piece.m(1) >= 0, ...
                'candidateInfo',candidateInfo, ...
                'candidateCount',nCandidates, ...
                'finiteCandidateCount',sum(isfinite(candidateSSE)), ...
                'bestScreeningSSE',bestSSE);
        end

   
        function [b_init, info] = makeModelAwareReservoirStart(app, x, y_obs, xx, piece, cfg)
            modelType = app.normalizeModelType(string(cfg.ModelType));
            positiveShallowSlope = ~isempty(piece.m) && isfinite(piece.m(1)) && piece.m(1) >= 0;

            if strcmp(modelType, "2-Reservoir")
                [candidates, candidateInfo] = app.generateReservoirCandidates(x, y_obs, piece, cfg, []);
                [b_init, refineInfo] = app.refineReservoirCandidates(x, y_obs, candidates, cfg, 8, 250);
                info = struct( ...
                    'method',"model-aware 2-Reservoir candidate prefit", ...
                    'hierarchical',false, ...
                    'positiveShallowSlope',positiveShallowSlope, ...
                    'candidateInfo',candidateInfo, ...
                    'refineInfo',refineInfo);
                return;
            end

            cfg2 = cfg;
            cfg2.ModelType = "2-Reservoir";
            cfg2.ParamNames = app.getParamNames("2-Reservoir");
            piece2 = app.findAutomaticPiecewiseLines(x, y_obs, xx, 2);
            [candidates2, candidateInfo2] = app.generateReservoirCandidates(x, y_obs, piece2, cfg2, []);
            [bTwo, refineInfo2] = app.refineReservoirCandidates(x, y_obs, candidates2, cfg2, 6, 200);

            gLong = max(bTwo(2), bTwo(4));
            gShort = min(bTwo(2), bTwo(4));
            gMiddle = sqrt(max(gLong .* gShort, realmin));
            extraScales = [gLong, gMiddle, gShort, ...
                0.5 .* (gLong + gMiddle), 0.5 .* (gMiddle + gShort)];
            [candidates3, candidateInfo3] = app.generateReservoirCandidates(x, y_obs, piece, cfg, extraScales);
            [b_init, refineInfo3] = app.refineReservoirCandidates(x, y_obs, candidates3, cfg, 12, 350);

            info = struct( ...
                'method',"hierarchical 2-Reservoir to 3-Reservoir model prefit", ...
                'hierarchical',true, ...
                'positiveShallowSlope',positiveShallowSlope, ...
                'twoReservoirStart',bTwo, ...
                'twoReservoirCandidateInfo',candidateInfo2, ...
                'twoReservoirRefineInfo',refineInfo2, ...
                'candidateInfo',candidateInfo3, ...
                'refineInfo',refineInfo3);
        end


        function [candidates, info] = generateReservoirCandidates(app, x, y_obs, piece, cfg, extraScales)
            x = double(x(:));
            y_obs = double(y_obs(:));
            good = isfinite(x) & isfinite(y_obs);
            x = x(good);
            y_obs = y_obs(good);
            [x, ord] = sort(x);
            y_obs = y_obs(ord);

            modelType = app.normalizeModelType(string(cfg.ModelType));
            if strcmp(modelType,"3-Reservoir")
                nComp = 3;
            else
                nComp = 2;
            end

            [~, ~, gLow, gHigh, deltaL, lSpan] = app.getInitializationBounds(x, cfg);
            slopeTol = max(1e-10, eps ./ max(lSpan,eps));
            negativeScale = -1 ./ piece.m(piece.m < -slopeTol & isfinite(piece.m));
            baseScales = [ ...
                gLow, 0.3.*deltaL, deltaL, 2.*deltaL, ...
                lSpan./50, lSpan./20, lSpan./10, lSpan./4, ...
                lSpan./2, lSpan, 2.*lSpan, 5.*lSpan, gHigh, ...
                negativeScale(:).', extraScales(:).'];
            baseScales = baseScales(isfinite(baseScales) & baseScales > 0);
            baseScales = min(max(baseScales, gLow), gHigh);
            scalePool = unique(sort(baseScales));

            % Prevent an unusually large user-supplied pool from making the
            %  enumeration  expensive.
            if numel(scalePool) > 18
                protectedScales = [negativeScale(:).', extraScales(:).'];
                protectedScales = protectedScales(isfinite(protectedScales) & protectedScales > 0);
                protectedScales = unique(min(max(protectedScales,gLow),gHigh));
                nBackground = max(6, 18 - numel(protectedScales));
                keepIdx = unique(round(linspace(1,numel(scalePool),nBackground)));
                scalePool = unique(sort([scalePool(keepIdx), protectedScales]));
            end

            Nobs = exp(min(max(y_obs,-700),700));
            candidates = zeros(0, 2.*nComp);
            rawCandidateCount = 0;

            if nComp == 2
                for iLong = numel(scalePool):-1:2
                    for iShort = 1:(iLong-1)
                        gt = [scalePool(iLong), scalePool(iShort)];
                        if gt(1) <= gt(2) .* (1 + 1e-5)
                            continue;
                        end
                        E = [exp(-x./gt(1)), exp(-x./gt(2))];
                        ampSeeds = app.makeAmplitudeSeeds(E, Nobs, piece, 2);
                        for aa = 1:size(ampSeeds,1)
                            b = app.amplitudesToReservoirParameters(ampSeeds(aa,:), gt, cfg);
                            if ~isempty(b)
                                candidates(end+1,:) = b; 
                                rawCandidateCount = rawCandidateCount + 1;
                            end
                        end
                    end
                end
            else
                for iLong = numel(scalePool):-1:3
                    for iMiddle = (iLong-1):-1:2
                        for iShort = 1:(iMiddle-1)
                            gt = [scalePool(iLong), scalePool(iMiddle), scalePool(iShort)];
                            if gt(1) <= gt(2).*(1+1e-5) || gt(2) <= gt(3).*(1+1e-5)
                                continue;
                            end
                            E = [exp(-x./gt(1)), exp(-x./gt(2)), exp(-x./gt(3))];
                            ampSeeds = app.makeAmplitudeSeeds(E, Nobs, piece, 3);
                            for aa = 1:size(ampSeeds,1)
                                b = app.amplitudesToReservoirParameters(ampSeeds(aa,:), gt, cfg);
                                if ~isempty(b)
                                    candidates(end+1,:) = b; 
                                    rawCandidateCount = rawCandidateCount + 1;
                                end
                            end
                        end
                    end
                end
            end

            % For a CSD that rises at small L and then turns downward
            [turnoverCandidates, turnoverInfo] = app.makeTurnoverEquationCandidates( ...
                x, y_obs, piece, cfg, gLow, gHigh);
            if ~isempty(turnoverCandidates)

                candidates = turnoverCandidates;
                rawCandidateCount = size(turnoverCandidates,1);
            end

            if isempty(candidates)
                error("Model-aware initialization could not construct a valid %s parameter candidate.", modelType);
            end

            [lbInit, ubInit] = app.getInitializationBounds(x, cfg);
            for ii = 1:size(candidates,1)
                candidates(ii,:) = app.projectToBoundsForHybrid(candidates(ii,:), lbInit, ubInit, cfg);
            end
            logKey = round(log(max(candidates,realmin)), 8);
            [~, uniqueIdx] = unique(logKey, 'rows', 'stable');
            candidates = candidates(uniqueIdx,:);

            info = struct( ...
                'scalePool',scalePool, ...
                'scaleLower',gLow, ...
                'scaleUpper',gHigh, ...
                'medianSpacing',deltaL, ...
                'sizeSpan',lSpan, ...
                'rawCandidateCount',rawCandidateCount, ...
                'uniqueCandidateCount',size(candidates,1), ...
                'positiveShallowSlope',piece.m(1) >= 0, ...
                'turnoverEquation',turnoverInfo);
        end

        % Construct initialization candidates from Liang et al. equations
        % 9a and 10. For the two-reservoir model, r = n_mix^0/n_1^0. For the
        % three-reservoir model, Reservoir 1 is initialized separately and
        % Reservoir 2 plus the shallow reservoir are treated as the effective
        % two-reservoir subsystem, so r = n_mix^0/n_2^0.
        function [candidates, info] = makeTurnoverEquationCandidates(app, x, y_obs, piece, cfg, gLow, gHigh)
            candidates = zeros(0, numel(app.getParamNames(cfg.ModelType)));
            info = struct( ...
                'used',false, ...
                'reason',"not evaluated", ...
                'smallSizeSlope',NaN, ...
                'turnoverL',NaN, ...
                'upstreamGtau',NaN, ...
                'mixGtau',NaN, ...
                'nMixToUpstreamRatio',NaN, ...
                'equationResidual',NaN, ...
                'candidateCount',0);

            if isempty(piece.m) || ~isfinite(piece.m(1)) || piece.m(1) <= 0
                info.reason = "small-size slope is not positive";
                return;
            end
            if numel(piece.m) < 2 || ~any(piece.m(2:end) < 0 & isfinite(piece.m(2:end)))
                info.reason = "no negative-slope segment follows the upturn";
                return;
            end

            [turnoverL, peakInfo] = app.estimateObservedTurnover(x, y_obs);
            info.smallSizeSlope = piece.m(1);
            info.turnoverL = turnoverL;
            if ~peakInfo.valid
                info.reason = peakInfo.reason;
                return;
            end

            modelType = app.normalizeModelType(string(cfg.ModelType));
            negativeScales = -1 ./ piece.m(piece.m < 0 & isfinite(piece.m));
            negativeScales = negativeScales(isfinite(negativeScales) & negativeScales > 0);
            negativeScales = sort(negativeScales, 'descend');
            if strcmp(modelType,"3-Reservoir")
                if numel(negativeScales) < 2
                    info.reason = "three-reservoir initialization needs two negative-slope scales";
                    return;
                end
                g1 = min(max(negativeScales(1),gLow),gHigh);
                g2 = min(max(negativeScales(2),gLow),gHigh);
                if g1 <= g2 .* (1 + 1e-5)
                    info.reason = "Reservoir 1 and Reservoir 2 scales are not ordered";
                    return;
                end
                upstreamGtau = g2;
            else
                if isempty(negativeScales)
                    info.reason = "two-reservoir initialization needs a negative large-L slope";
                    return;
                end
                upstreamGtau = min(max(negativeScales(1),gLow),gHigh);
                g1 = upstreamGtau;
            end

            [mixGtau, ratio, equationResidual, solved] = app.solveTurnoverEquations( ...
                upstreamGtau, piece.m(1), turnoverL, gLow, gHigh);
            info.upstreamGtau = upstreamGtau;
            info.mixGtau = mixGtau;
            info.nMixToUpstreamRatio = ratio;
            info.equationResidual = equationResidual;
            if ~solved
                info.reason = "equations 9a and 10 had no admissible solution within the initialization bounds";
                return;
            end

            x = double(x(:));
            y_obs = double(y_obs(:));
            good = isfinite(x) & isfinite(y_obs);
            x = x(good);
            y_obs = y_obs(good);
            Nobs = exp(min(max(y_obs,-700),700));

            if strcmp(modelType,"2-Reservoir")
                coeffLong = upstreamGtau ./ (upstreamGtau - mixGtau);
                shape = coeffLong .* exp(-x ./ upstreamGtau) + ...
                    (ratio - coeffLong) .* exp(-x ./ mixGtau);
                goodShape = shape > 0 & isfinite(shape);
                if all(goodShape)
                    logN1 = median(y_obs - log(shape), 'omitnan');
                    n1 = exp(min(max(logN1,log(realmin)),log(1e14)));
                    nMix = ratio .* n1;
                    if all(isfinite([n1 nMix])) && all([n1 nMix] > 0)
                        candidates(end+1,:) = [n1, upstreamGtau, nMix, mixGtau];
                    end
                end
            else
                alpha1 = cfg.alpha1;
                alpha2 = 1 - alpha1;
                if alpha1 > 0 && alpha2 > 0 && g2 > mixGtau
                    e1 = exp(-x ./ g1);
                    e2 = exp(-x ./ g2);
                    em = exp(-x ./ mixGtau);
                    C1 = alpha1 .* g1 ./ (g1 - mixGtau) .* (e1 - em);
                    C2 = alpha2 .* g2 ./ (g2 - mixGtau) .* (e2 - em) + ratio .* em;
                    C = [C1 C2];
                    populationSeeds = zeros(0,2);
                    try
                        populationSeeds(end+1,:) = (pinv(C) * Nobs).';
                    catch
                    end
                    try
                        floorN = max(max(Nobs) .* 1e-8, realmin);
                        w = 1 ./ max(Nobs,floorN);
                        populationSeeds(end+1,:) = (pinv(C .* w) * (Nobs .* w)).';
                    catch
                    end
                    if ~isempty(populationSeeds)
                        populationSeeds = [populationSeeds; abs(populationSeeds)];
                    end
                    for ii = 1:size(populationSeeds,1)
                        n1 = populationSeeds(ii,1);
                        n2 = populationSeeds(ii,2);
                        nMix = ratio .* n2;
                        if all(isfinite([n1 n2 nMix])) && all([n1 n2 nMix] > 0)
                            candidates(end+1,:) = [n1, g1, n2, g2, nMix, mixGtau];
                        end
                    end
                end
            end

            if ~isempty(candidates)
                logKey = round(log(max(candidates,realmin)),10);
                [~,ia] = unique(logKey,'rows','stable');
                candidates = candidates(ia,:);
                info.used = true;
                info.reason = "equations 9a and 10 supplied complete-model candidates";
                info.candidateCount = size(candidates,1);
            else
                info.reason = "equation solution was valid but candidate scaling was not finite";
            end
        end

        % Locate the measured maximum of the overturned CSD. 
        function [turnoverL, info] = estimateObservedTurnover(~, x, y_obs)
            x = double(x(:));
            y_obs = double(y_obs(:));
            good = isfinite(x) & isfinite(y_obs);
            x = x(good);
            y_obs = y_obs(good);
            [x,ord] = sort(x);
            y_obs = y_obs(ord);
            turnoverL = NaN;
            info = struct('valid',false,'reason',"turnover maximum was not found",'dataIndex',NaN,'quadraticRefined',false);
            if numel(x) < 3
                info.reason = "at least three observations are required to locate the turnover";
                return;
            end
            [~,idx] = max(y_obs);
            info.dataIndex = idx;
            if idx <= 1 || idx >= numel(x)
                info.reason = "the observed maximum lies at the edge of the measured L range";
                return;
            end
            turnoverL = x(idx);
            try
                use = (idx-1):(idx+1);
                q = polyfit(x(use),y_obs(use),2);
                if isfinite(q(1)) && q(1) < 0
                    vertex = -q(2) ./ (2 .* q(1));
                    if isfinite(vertex) && vertex >= x(idx-1) && vertex <= x(idx+1)
                        turnoverL = vertex;
                        info.quadraticRefined = true;
                    end
                end
            catch
            end
            if ~isfinite(turnoverL) || turnoverL <= 0
                info.reason = "the turnover location must be positive";
                return;
            end
            info.valid = true;
            info.reason = "interior CSD maximum located";
        end

    
        function [b, ratio, residual, solved] = solveTurnoverEquations(~, a, s0, turnoverL, gLow, gHigh)
            b = NaN;
            ratio = NaN;
            residual = NaN;
            solved = false;
            if any(~isfinite([a s0 turnoverL gLow gHigh])) || a <= 0 || s0 <= 0 || turnoverL <= 0
                return;
            end
            bLo = max([gLow, a .* 1e-8, realmin]);
            bHi = min(gHigh, a .* (1 - 1e-7));
            if ~isfinite(bLo) || ~isfinite(bHi) || bHi <= bLo
                return;
            end
            predictedPeak = @(z) (a .* z ./ (a - z)) .* ...
                log((1 + a .* s0) ./ (1 + z .* s0));
            objective = @(logz) (predictedPeak(exp(logz)) - turnoverL).^2;
            try
                logB = fminbnd(objective,log(bLo),log(bHi));
                bTry = exp(logB);
                residualTry = predictedPeak(bTry) - turnoverL;
            catch
                return;
            end
            % Reject a boundary approximation when the measured peak is
            % inconsistent with the two-reservoir turnover geometry.
            tolerance = max(0.05 .* turnoverL, 0.25 .* gLow);
            if ~isfinite(bTry) || ~isfinite(residualTry) || abs(residualTry) > tolerance
                return;
            end
            ratioTry = 1 ./ (1 + bTry .* s0);
            if ~isfinite(ratioTry) || ratioTry <= 0 || ratioTry >= 1 || bTry >= a
                return;
            end
            b = bTry;
            ratio = ratioTry;
            residual = residualTry;
            solved = true;
        end

        function ampSeeds = makeAmplitudeSeeds(~, E, Nobs, piece, nComp)
            ampSeeds = zeros(0,nComp);
            try
                Aordinary = pinv(E) * Nobs;
                ampSeeds(end+1,:) = Aordinary(:).';
            catch
            end
            try
                floorN = max(max(Nobs) .* 1e-8, realmin);
                w = 1 ./ max(Nobs, floorN);
                Ew = E .* w;
                Nw = Nobs .* w;
                Arelative = pinv(Ew) * Nw;
                ampSeeds(end+1,:) = Arelative(:).';
            catch
            end

            cUse = piece.c(:).';
            if numel(cUse) >= nComp
                ampMagnitude = exp(min(max(fliplr(cUse(1:nComp)),-60),log(1e13)));
                ampSeeds(end+1,:) = ampMagnitude;
                ampSigned = ampMagnitude;
                ampSigned(end) = -ampSigned(end);
                ampSeeds(end+1,:) = ampSigned;
                ampHalfSigned = ampMagnitude;
                ampHalfSigned(end) = -0.5 .* ampHalfSigned(end);
                ampSeeds(end+1,:) = ampHalfSigned;
            end

            originalSeeds = ampSeeds;
            for ii = 1:size(originalSeeds,1)
                A = originalSeeds(ii,:);
                A(1:max(nComp-1,1)) = abs(A(1:max(nComp-1,1)));
                ampSeeds(end+1,:) = A;
                ampSeeds(end+1,:) = abs(A);
            end
            ampSeeds = ampSeeds(all(isfinite(ampSeeds),2),:);
            if ~isempty(ampSeeds)
                [~, ia] = unique(round(ampSeeds,10),'rows','stable');
                ampSeeds = ampSeeds(ia,:);
            end
        end

       
        function b = amplitudesToReservoirParameters(app, A, gt, cfg)
            b = [];
            A = double(A(:)).';
            gt = double(gt(:)).';
            modelType = app.normalizeModelType(string(cfg.ModelType));

            if strcmp(modelType,"2-Reservoir")
                if numel(A) < 2 || numel(gt) < 2 || A(1) <= 0 || gt(1) <= gt(2)
                    return;
                end
                n1 = A(1) .* (gt(1) - gt(2)) ./ gt(1);
                nMix = A(1) + A(2);
                if ~isfinite(n1) || ~isfinite(nMix) || n1 <= 0 || nMix <= 0
                    return;
                end
                b = [n1, gt(1), nMix, gt(2)];
                return;
            end

            alpha1 = cfg.alpha1;
            alpha2 = 1 - alpha1;
            if numel(A) < 3 || numel(gt) < 3 || A(1) <= 0 || A(2) <= 0 || ...
                    gt(1) <= gt(2) || gt(2) <= gt(3) || alpha1 <= 0 || alpha2 <= 0
                return;
            end
            n1 = A(1) .* (gt(1) - gt(3)) ./ (alpha1 .* gt(1));
            n2 = A(2) .* (gt(2) - gt(3)) ./ (alpha2 .* gt(2));
            nMix = sum(A(1:3));
            if any(~isfinite([n1 n2 nMix])) || any([n1 n2 nMix] <= 0)
                return;
            end
            b = [n1, gt(1), n2, gt(2), nMix, gt(3)];
        end

        % Data-aware bounds used only during initialization. T
        function [lb, ub, gLow, gHigh, deltaL, lSpan] = getInitializationBounds(app, x, cfg)
            [lb, ub] = app.getHybridBounds(cfg);
            xu = unique(sort(double(x(isfinite(x)))));
            if numel(xu) < 2
                error("Model-aware initialization requires at least two distinct L values.");
            end
            dL = diff(xu);
            dL = dL(dL > 0 & isfinite(dL));
            deltaL = median(dL);
            lSpan = max(xu) - min(xu);
            gLow = max([0.1 .* deltaL, 1e-6 .* lSpan, 1e-12]);
            gHigh = max(10 .* lSpan, 100 .* gLow);
            gtIdx = 2:2:numel(lb);
            lb(gtIdx) = max(lb(gtIdx), gLow);
            ub(gtIdx) = min(ub(gtIdx), gHigh);
            lb = max(lb, realmin);
            ub = max(ub, lb .* (1 + 1e-8));
        end

 
        function [bestB, info] = refineReservoirCandidates(app, x, y_obs, candidates, cfg, maxRefine, maxIter)
            [lb, ub] = app.getInitializationBounds(x, cfg);
            nCandidates = size(candidates,1);
            candidateSSE = inf(nCandidates,1);
            for ii = 1:nCandidates
                b = app.projectToBoundsForHybrid(candidates(ii,:), lb, ub, cfg);
                candidates(ii,:) = b;
                candidateSSE(ii) = app.nlObjective(b, x, y_obs, cfg);
            end
            [candidateSSE, order] = sort(candidateSSE);
            candidates = candidates(order,:);
            finiteIdx = find(isfinite(candidateSSE));
            if isempty(finiteIdx)
                error("No finite complete-model candidate was found during reservoir initialization.");
            end

            bestB = candidates(finiteIdx(1),:);
            bestSSE = candidateSSE(finiteIdx(1));
            nRefined = 0;
            useLSQ = license('test','optimization_toolbox') && exist('lsqnonlin','file') == 2;
            if useLSQ
                thetaLB = log(max(lb,realmin));
                thetaUB = log(max(ub,lb.*(1+1e-8)));
                opts = optimoptions('lsqnonlin', ...
                    'Display','off', ...
                    'MaxIterations',maxIter, ...
                    'FunctionTolerance',1e-8, ...
                    'StepTolerance',1e-8);
                nTry = min(maxRefine,numel(finiteIdx));
                for kk = 1:nTry
                    theta0 = log(max(candidates(kk,:),realmin));
                    theta0 = min(max(theta0,thetaLB),thetaUB);
                    try
                        thetaFit = lsqnonlin( ...
                            @(theta) app.nlResidualThetaBounded(theta, x, y_obs, cfg, thetaLB, thetaUB), ...
                            theta0, thetaLB, thetaUB, opts);
                        bFit = exp(thetaFit);
                        sseFit = app.nlObjective(bFit, x, y_obs, cfg);
                        nRefined = nRefined + 1;
                        if isfinite(sseFit) && sseFit < bestSSE
                            bestSSE = sseFit;
                            bestB = bFit(:).';
                        end
                    catch
                    end
                end
            end

            bestB = app.projectToBoundsForHybrid(bestB, lb, ub, cfg);
            info = struct( ...
                'candidateCount',nCandidates, ...
                'finiteCandidateCount',numel(finiteIdx), ...
                'refinedCandidateCount',nRefined, ...
                'usedLsqnonlin',useLSQ, ...
                'bestSSE',bestSSE, ...
                'initializationBoundsLower',lb, ...
                'initializationBoundsUpper',ub);
        end

        % Manual piecewise point picker. 
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
        
                title(ax, sprintf('%s | Segment %d active (pick order does not matter). Click to add/remove points. Press Enter when done.', ...
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
        function [w1, w2] = getExportReservoirWeights(app, result)
            % Mixing weights do not apply to the two-reservoir model.
            w1 = '';
            w2 = '';
            if strcmp(app.normalizeModelType(string(result.ModelType)), "2-Reservoir")
                return;
            end
            w1 = double(result.alpha1);
            w2 = double(result.alpha2);
        end

        function row = buildResultRow(app, result)
            initMode = app.getStoredRunSetting(result, 'Initialization', app.getPiecewiseInitializationMode(result));
            mcmcIter = app.getStoredRunSetting(result, 'MCMCIterations', NaN);
            mcmcBurn = app.getStoredRunSetting(result, 'MCMCBurnIn', NaN);
            mcmcStep = app.getStoredRunSetting(result, 'MCMCStepFraction', NaN);
            mcmcSigma = app.getStoredRunSetting(result, 'MCMCSigmaLnN', NaN);
            mcmcSeed = app.getStoredRunSetting(result, 'MCMCSeed', result.SeedUsed);
            [w1, w2] = app.getExportReservoirWeights(result);
            row = { ...
                char(app.getResultDisplayLabel(result, NaN)), char(result.Sheet), char(result.ModelType), char(result.Fit.solver), double(result.Fit.exitflag), ...
                double(result.Fit.rmse), double(result.Fit.r2), double(result.Piecewise.rmse), w1, w2, ...
                char(string(initMode)), double(mcmcIter), double(mcmcBurn), double(mcmcStep), double(mcmcSigma), double(mcmcSeed), ...
                app.paramOrNaN(result.b_init,1), app.paramOrNaN(result.b_init,2), app.paramOrNaN(result.b_init,3), app.paramOrNaN(result.b_init,4), app.paramOrNaN(result.b_init,5), app.paramOrNaN(result.b_init,6), ...
                app.paramOrNaN(result.b_fit,1),  app.paramOrNaN(result.b_fit,2),  app.paramOrNaN(result.b_fit,3),  app.paramOrNaN(result.b_fit,4), app.paramOrNaN(result.b_fit,5), app.paramOrNaN(result.b_fit,6), ...
                app.fitStatOrNaN(result,'ciLow',1), app.fitStatOrNaN(result,'ciLow',2), app.fitStatOrNaN(result,'ciLow',3), app.fitStatOrNaN(result,'ciLow',4), app.fitStatOrNaN(result,'ciLow',5), app.fitStatOrNaN(result,'ciLow',6), ...
                app.fitStatOrNaN(result,'ciHigh',1), app.fitStatOrNaN(result,'ciHigh',2), app.fitStatOrNaN(result,'ciHigh',3), app.fitStatOrNaN(result,'ciHigh',4), app.fitStatOrNaN(result,'ciHigh',5), app.fitStatOrNaN(result,'ciHigh',6), ...
                app.nlPValueOrNaN(result,1), app.nlPValueOrNaN(result,2), app.nlPValueOrNaN(result,3), app.nlPValueOrNaN(result,4), app.nlPValueOrNaN(result,5), app.nlPValueOrNaN(result,6) ...
                };
        end

        function headers = getResultTableHeaders(~)
            headers = { ...
                'Result','Sheet','Model','Solver','Exitflag','fit_RMSE','fit_R2','pw_RMSE','w1','w2', ...
                'Initialization','MCMC_iterations','MCMC_burn_in','MCMC_step_fraction','MCMC_sigma_ln_n','MCMC_seed', ...
                'param1_init','param2_init','param3_init','param4_init','param5_init','param6_init', ...
                'param1_fit','param2_fit','param3_fit','param4_fit','param5_fit','param6_fit', ...
                'param1_95_low','param2_95_low','param3_95_low','param4_95_low','param5_95_low','param6_95_low', ...
                'param1_95_high','param2_95_high','param3_95_high','param4_95_high','param5_95_high','param6_95_high', ...
                'param1_p_value','param2_p_value','param3_p_value','param4_p_value','param5_p_value','param6_p_value'};
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

        function v = nlPValueOrNaN(app, result, idx)
            if app.isMCMCResult(result)
                v = NaN;
            else
                v = app.fitStatOrNaN(result, 'pValue', idx);
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
            safe = regexprep(safe, '[<>:"/\\|?*+]', '_');
            safe = regexprep(safe, '\s+', ' ');
            safe = regexprep(safe, '_+', '_');
            safe = strtrim(safe);
            if strlength(safe) == 0
                safe = "Result";
            end
        end

        function titleText = getResultPlotTitle(app, result)
            titleText = "Result";
            try
                if isfield(result,'IsCombined') && result.IsCombined
                    nSamples = 0;
                    if isfield(result,'SourceSheets') && ~isempty(result.SourceSheets)
                        nSamples = numel(result.SourceSheets);
                    elseif isfield(result,'Components') && ~isempty(result.Components)
                        nSamples = numel(result.Components);
                    end
                    runNumber = NaN;
                    if isfield(result,'RunNumber') && isfinite(double(result.RunNumber))
                        runNumber = double(result.RunNumber);
                    else
                        idx = app.findResultIndexBySheetModel(result);
                        if ~isempty(idx)
                            runNumber = double(idx);
                        end
                    end
                    if isfinite(runNumber)
                        titleText = sprintf("Combined Run (Run %d, %d samples)",round(runNumber),nSamples);
                    else
                        titleText = sprintf("Combined Run (%d samples)",nSamples);
                    end
                elseif isfield(result,'Sheet')
                    titleText = string(result.Sheet);
                end
            catch
                if isfield(result,'Sheet')
                    titleText = string(result.Sheet);
                end
            end
        end

        function tag = getPlotExportTag(app, result)
            sampleName = "Result";
            modelName  = "Model";
            solverName = "Solver";

            try
                if isfield(result,'IsCombined') && result.IsCombined
                    nSheets = 0;
                    if isfield(result,'Components') && ~isempty(result.Components)
                        nSheets = numel(result.Components);
                    end
                    if nSheets > 0
                        sampleName = "Combined_" + string(nSheets) + "_sheets";
                    else
                        sampleName = "Combined";
                    end
                else
                    sampleName = app.safePathName(result.Sheet);
                end
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

            runSuffix = "";
            try
                if isfield(result,'RunNumber') && isfinite(double(result.RunNumber))
                    runSuffix = " - Run" + string(double(result.RunNumber));
                end
            catch
            end

            % Keep the result folder and every exported filename 
            % below Windows/Excel path limits. The complete sample/sheet name
            % remains available inside the plot-data workbook metadata.
            tagBody = app.safePathName(sampleName + " - " + modelName + " - " + solverName);
            maxTagLength = 72;
            maxBodyLength = max(12, maxTagLength - strlength(runSuffix));
            if strlength(tagBody) > maxBodyLength
                tagBody = extractBefore(tagBody, maxBodyLength + 1);
                tagBody = regexprep(tagBody, '[ _-]+$', '');
            end
            tag = app.safePathName(tagBody + runSuffix);
        end

        % Write one workbook containing the numerical source data for every
        % plot exported for a result. The workbook is placed in the same
        % result-specific directory as the PNG files.
        function savePlotDataWorkbook(app, cfg, result)
            outRoot = app.getOutputDir(cfg);
            plotTag = app.getPlotExportTag(result);
            outDir  = fullfile(outRoot, plotTag);
            if ~exist(outDir,"dir"); mkdir(outDir); end

         
            outFile = fullfile(outDir, "CSDStudio_PlotData.xlsx");
            if isfile(outFile)
                delete(outFile);
            end

            isMCMC = app.isMCMCResult(result);
            fitMode = "NL best fit";
            if isMCMC
                fitMode = app.getMCMCPlotMode();
            end

            showFitLine = true;
            showMarkers = true;
            try
                sty = app.getResultPlotStyle(result, NaN);
                if isfield(sty,'ShowFitLine')
                    showFitLine = logical(sty.ShowFitLine);
                end
                if isfield(sty,'ShowMarkers')
                    showMarkers = logical(sty.ShowMarkers);
                end
                if isfield(result,'IsCombined') && result.IsCombined && ...
                        isfield(result,'Components') && ~isempty(result.Components)
                    showMarkers = false;
                    for jj = 1:numel(result.Components)
                        componentStyle = app.getSamplePlotStyle( ...
                            "Component: " + string(result.Components(jj).Sheet));
                        showMarkers = showMarkers || ~isfield(componentStyle,'ShowMarkers') || ...
                            logical(componentStyle.ShowMarkers);
                    end
                end
            catch
            end

            showCredibleBand = false;
            showPredictiveInterval = false;
            try
                showCredibleBand = app.shouldPlotMCMCCredibleBand(result, true);
                showPredictiveInterval = app.shouldPlotMCMCPosteriorPredictiveInterval(result, true);
            catch
            end
            uncertaintyBandMode = "None";
            observationSigmaLnN = NaN;
            if isMCMC
                uncertaintyBandMode = app.getMCMCUncertaintyBandMode();
                observationSigmaLnN = app.getStoredMCMCObservationSigma(result);
            end
            initializationMode = app.getStoredRunSetting(result, 'Initialization', ...
                app.getPiecewiseInitializationMode(result));
            mcmcIterations = app.getStoredRunSetting(result, 'MCMCIterations', NaN);
            mcmcBurnIn = app.getStoredRunSetting(result, 'MCMCBurnIn', NaN);
            mcmcStepFraction = app.getStoredRunSetting(result, 'MCMCStepFraction', NaN);
            mcmcSeed = app.getStoredRunSetting(result, 'MCMCSeed', result.SeedUsed);
            fixReservoirLnNm0 = app.getStoredRunSetting(result, 'FixReservoirLnNm0', false);
            fixedReservoirLnNm0 = app.getStoredRunSetting(result, 'FixedReservoirLnNm0', NaN);

            [w1, w2] = app.getExportReservoirWeights(result);
            metadata = { ...
                'CSDStudio version', 'CSDStudio 2026b'; ...
                'Result', char(app.getResultDisplayLabel(result, NaN)); ...
                'Sample', char(string(result.Sheet)); ...
                'Model', char(string(result.ModelType)); ...
                'Solver', char(string(result.Fit.solver)); ...
                'w1', w1; ...
                'w2', w2; ...
                'Initialization method', char(string(initializationMode)); ...
                'MCMC iterations', mcmcIterations; ...
                'MCMC burn-in', mcmcBurnIn; ...
                'MCMC step fraction', mcmcStepFraction; ...
                'MCMC sigma in ln(n)', observationSigmaLnN; ...
                'MCMC seed', mcmcSeed; ...
                'Fixed ln(n_mix^0)', logical(fixReservoirLnNm0); ...
                'Fixed ln(n_mix^0) value', fixedReservoirLnNm0; ...
                'Displayed fit mode', char(fitMode); ...
                'Fit line displayed', showFitLine; ...
                'Markers displayed', showMarkers; ...
                'Uncertainty band selection', char(uncertaintyBandMode); ...
                '95% uncertainty displayed', showPredictiveInterval; ...
                'Observation sigma in ln(n)', observationSigmaLnN; ...
                'Uncertainty intervals', 'Pointwise 95% intervals'; ...
                'Exported', char(string(datetime("now","Format","yyyy-MM-dd HH:mm:ss")))};
            writecell(metadata, outFile, "Sheet", "Contents", "Range", "A1");

            mapping = cell(0,2);

            initializationData = app.buildPiecewiseInitializationPlotDataTable(result);
            if ~isempty(initializationData)
                writetable(initializationData, outFile, "Sheet", "Initialization");
                mapping(end+1,:) = {char(plotTag + "_PiecewiseInitialization.png"), 'Initialization'};
            end

            modelFitData = app.buildModelFitPlotDataTable(result);
            writetable(modelFitData, outFile, "Sheet", "Model_Fit");
            mapping(end+1,:) = {char(plotTag + "_ModelFit.png"), 'Model_Fit'};

            residualData = app.buildResidualPlotDataTable(result);
            writetable(residualData, outFile, "Sheet", "Residuals");
            mapping(end+1,:) = {char(plotTag + "_Residuals.png"), 'Residuals'};

            if isMCMC
                [traceHeaders, traceData] = app.buildMCMCTracePlotData(result);
                traceSheets = app.writeNumericMatrixInExcelChunks(outFile, "MCMC_Trace", traceHeaders, traceData);
                for jj = 1:numel(traceSheets)
                    mapping(end+1,:) = {char(plotTag + "_MCMC_TracePlots.png"), char(traceSheets(jj))};
                end

                [sampleHeaders, sampleData] = app.buildMCMCPosteriorPlotData(result);
                sampleSheets = app.writeNumericMatrixInExcelChunks(outFile, "MCMC_Samples", sampleHeaders, sampleData);
                for jj = 1:numel(sampleSheets)
                    mapping(end+1,:) = {char(plotTag + "_MCMC_Pairwise.png"), char(sampleSheets(jj))};
                end

                histogramData = app.buildMCMCHistogramPlotDataTable(result);
                writetable(histogramData, outFile, "Sheet", "MCMC_Histograms");
                mapping(end+1,:) = {char(plotTag + "_MCMC_PosteriorMarginals.png"), 'MCMC_Histograms'};
                for jj = 1:numel(sampleSheets)
                    mapping(end+1,:) = {char(plotTag + "_MCMC_PosteriorMarginals.png"), char(sampleSheets(jj))};
                end
            end

            mapStartRow = size(metadata,1) + 3;
            writecell({'Exported plot file','Worksheet'}, outFile, ...
                "Sheet", "Contents", "Range", "A" + string(mapStartRow));
            if ~isempty(mapping)
                writecell(mapping, outFile, "Sheet", "Contents", ...
                    "Range", "A" + string(mapStartRow + 1));
            end
        end

        function mode = getPiecewiseInitializationMode(~, result)
            mode = "Not applicable";
            try
                if ~isfield(result,'Piecewise') || isempty(result.Piecewise) || ...
                        ~isfield(result.Piecewise,'nSeg') || result.Piecewise.nSeg < 2
                    return;
                end
                if isfield(result.Piecewise,'manual') && logical(result.Piecewise.manual)
                    mode = "Manual piecewise";
                else
                    mode = "Automatic piecewise";
                end
            catch
                mode = "Not applicable";
            end
        end

        function T = emptyPiecewiseInitializationTable(~)
            T = table(strings(0,1), strings(0,1), strings(0,1), zeros(0,1), ...
                false(0,1), zeros(0,1), zeros(0,1), zeros(0,1), ...
                zeros(0,1), zeros(0,1), ...
                'VariableNames', {'RecordType','Series','InitializationMode','Segment', ...
                'SelectedForSegment','L_mm','ln_n','Slope','Intercept','R2'});
        end

        % Return the segment associated with each included observation. Manual
        % mode retains only the points picked by the user; unselected points are
        % assigned zero. Automatic mode assigns every observation from the fitted
        % breakpoints. Segment numbering follows increasing median L, matching the
        % slopes and intercepts retained in result.Piecewise.
        function membership = getPiecewiseSegmentMembership(~, result)
            x = double(result.x(:));
            membership = zeros(size(x));
            piece = result.Piecewise;
            nSeg = max(0, round(double(piece.nSeg)));
            if nSeg < 1 || isempty(x)
                return;
            end

            isManual = isfield(piece,'manual') && logical(piece.manual);
            if isManual && isfield(piece,'idxSegments') && iscell(piece.idxSegments)
                for kk = 1:min(nSeg,numel(piece.idxSegments))
                    idx = unique(round(double(piece.idxSegments{kk}(:))));
                    idx = idx(isfinite(idx) & idx >= 1 & idx <= numel(x));
                    membership(idx) = kk;
                end
                return;
            end

            if isfield(piece,'breakX') && numel(piece.breakX) >= nSeg-1 && ...
                    all(isfinite(double(piece.breakX(1:nSeg-1))))
                edges = [-inf, double(piece.breakX(1:nSeg-1)), inf];
                for kk = 1:nSeg
                    membership(x > edges(kk) & x <= edges(kk+1)) = kk;
                end
                return;
            end

            % Compatibility fallback 
            [~, ord] = sort(x);
            cut = [];
            if isfield(piece,'idx')
                cut = round(double(piece.idx(:).'));
                cut = cut(isfinite(cut));
            end
            cut = max(1,min(numel(x),cut));
            cut = [0, cut(1:min(numel(cut),nSeg-1)), numel(x)];
            if numel(cut) == nSeg + 1
                for kk = 1:nSeg
                    if cut(kk) < cut(kk+1)
                        membership(ord(cut(kk)+1:cut(kk+1))) = kk;
                    end
                end
            end
        end


        function T = buildPiecewiseInitializationPlotDataTable(app, result)
            T = app.emptyPiecewiseInitializationTable();
            try
                if ~isfield(result,'Piecewise') || isempty(result.Piecewise) || ...
                        ~isfield(result.Piecewise,'nSeg') || result.Piecewise.nSeg < 2
                    return;
                end

                piece = result.Piecewise;
                nSeg = round(double(piece.nSeg));
                if numel(piece.m) < nSeg || numel(piece.c) < nSeg
                    return;
                end

                x = double(result.x(:));
                y = double(result.y_obs(:));
                n = min(numel(x),numel(y));
                x = x(1:n);
                y = y(1:n);
                membership = app.getPiecewiseSegmentMembership(result);
                membership = membership(1:min(n,numel(membership)));
                if numel(membership) < n
                    membership(end+1:n,1) = 0;
                end
                mode = app.getPiecewiseInitializationMode(result);

                obs = table( ...
                    repmat("Observation",n,1), ...
                    repmat("Observed CSD",n,1), ...
                    repmat(mode,n,1), ...
                    membership(:), membership(:) > 0, x, y, ...
                    nan(n,1), nan(n,1), nan(n,1), ...
                    'VariableNames', T.Properties.VariableNames);
                T = [T; obs];

                for kk = 1:nSeg
                    xSelected = x(membership == kk & isfinite(x));
                    if isempty(xSelected)
                        xSelected = x(isfinite(x));
                    end
                    if isempty(xSelected)
                        continue;
                    end
                    xMax = max(xSelected);
                    if ~isfinite(xMax)
                        continue;
                    end
                    xMin = 0;
                    if xMax <= xMin
                        xMax = max(1e-6, 0.01 .* max(1,abs(xMax)));
                    end
                    xLine = linspace(xMin,xMax,100).';
                    slope = double(piece.m(kk));
                    intercept = double(piece.c(kk));
                    yLine = slope .* xLine + intercept;
                    r2 = NaN;
                    if isfield(piece,'r2') && numel(piece.r2) >= kk
                        r2 = double(piece.r2(kk));
                    end
                    nLine = numel(xLine);
                    lineRows = table( ...
                        repmat("Piecewise line",nLine,1), ...
                        repmat("Initialization segment " + string(kk),nLine,1), ...
                        repmat(mode,nLine,1), repmat(kk,nLine,1), ...
                        false(nLine,1), xLine, yLine, ...
                        repmat(slope,nLine,1), repmat(intercept,nLine,1), ...
                        repmat(r2,nLine,1), ...
                        'VariableNames', T.Properties.VariableNames);
                    T = [T; lineRows];  
                end
            catch ME
                app.log("Piecewise initialization plot-data export failed for " + ...
                    string(result.Sheet) + ": " + string(ME.message));
                T = app.emptyPiecewiseInitializationTable();
            end
        end

        function T = emptyModelFitPlotTable(~)
            T = table(strings(0,1), strings(0,1), strings(0,1), ...
                false(0,1), false(0,1), ...
                zeros(0,1), zeros(0,1), zeros(0,1), zeros(0,1), zeros(0,1), ...
                'VariableNames', {'Series','PointType','Source','Plotted', ...
                '95% Uncertainty plotted','L_mm','ln_n', ...
                '95% Uncertainty low','95% Uncertainty high','Observation_sigma_ln_n'});
        end

        function T = makeModelFitPlotRows(app, seriesName, pointType, sourceName, ...
                plotted, x, y, uncertaintyLow, uncertaintyHigh, observationSigma, uncertaintyPlotted)
            if nargin < 11 || isempty(uncertaintyPlotted); uncertaintyPlotted = false; end
            if nargin < 10 || isempty(observationSigma); observationSigma = nan(size(y)); end
            if nargin < 9 || isempty(uncertaintyHigh); uncertaintyHigh = nan(size(y)); end
            if nargin < 8 || isempty(uncertaintyLow); uncertaintyLow = nan(size(y)); end
            x = double(x(:));
            y = double(y(:));
            uncertaintyLow = double(uncertaintyLow(:));
            uncertaintyHigh = double(uncertaintyHigh(:));
            observationSigma = double(observationSigma(:));
            if isscalar(observationSigma) && numel(y) > 1
                observationSigma = repmat(observationSigma, numel(y), 1);
            end
            n = min([numel(x), numel(y), numel(uncertaintyLow), ...
                numel(uncertaintyHigh), numel(observationSigma)]);
            if n < 1
                T = app.emptyModelFitPlotTable();
                return;
            end
            T = table( ...
                repmat(string(seriesName),n,1), ...
                repmat(string(pointType),n,1), ...
                repmat(string(sourceName),n,1), ...
                repmat(logical(plotted),n,1), ...
                repmat(logical(uncertaintyPlotted),n,1), ...
                x(1:n), y(1:n), uncertaintyLow(1:n), uncertaintyHigh(1:n), observationSigma(1:n), ...
                'VariableNames', {'Series','PointType','Source','Plotted', ...
                '95% Uncertainty plotted','L_mm','ln_n', ...
                '95% Uncertainty low','95% Uncertainty high','Observation_sigma_ln_n'});
        end

        function T = buildModelFitPlotDataTable(app, result)
            T = app.emptyModelFitPlotTable();

            if isfield(result,'IsCombined') && result.IsCombined && ...
                    isfield(result,'Components')
                for jj = 1:numel(result.Components)
                    part = result.Components(jj);
                    sourceName = string(part.Sheet);
                    dataName = app.makeLegendDataLabel(sourceName);
                    componentStyle = app.getSamplePlotStyle("Component: " + sourceName);
                    markersPlotted = ~isfield(componentStyle,'ShowMarkers') || logical(componentStyle.ShowMarkers);
                    T = [T; app.makeModelFitPlotRows(dataName, "Observed included", ...
                        sourceName, markersPlotted, part.x, part.y_obs, [], [])];  
                    if isfield(part,'x_excl') && isfield(part,'y_excl') && ~isempty(part.x_excl)
                        T = [T; app.makeModelFitPlotRows(dataName + " excluded", "Observed excluded", ...
                            sourceName, markersPlotted, part.x_excl, part.y_excl, [], [])];  
                    end
                end
            else
                sourceName = string(result.Sheet);
                dataName = app.makeLegendDataLabel(sourceName);
                dataStyle = app.getResultPlotStyle(result, NaN);
                markersPlotted = ~isfield(dataStyle,'ShowMarkers') || logical(dataStyle.ShowMarkers);
                T = [T; app.makeModelFitPlotRows(dataName, "Observed included", ...
                    sourceName, markersPlotted, result.x, result.y_obs, [], [])];  
                if isfield(result,'Exclusions') && isfield(result.Exclusions,'x_excl') && ...
                        isfield(result.Exclusions,'y_excl') && ~isempty(result.Exclusions.x_excl)
                    T = [T; app.makeModelFitPlotRows(dataName + " excluded", "Observed excluded", ...
                        sourceName, markersPlotted, result.Exclusions.x_excl, result.Exclusions.y_excl, [], [])];  
                end
            end

            xRight = app.getFitCurveXRight(result.x);
            nCurve = max(2, numel(result.xx));
            xPlot = linspace(0, xRight, nCurve).';
            yPlot = app.getDisplayedFitCurve(result, xPlot, true);

            showFitLine = true;
            try
                sty = app.getResultPlotStyle(result, NaN);
                if isfield(sty,'ShowFitLine')
                    showFitLine = logical(sty.ShowFitLine);
                end
            catch
            end

            uncertaintyLow = nan(size(xPlot));
            uncertaintyHigh = nan(size(xPlot));
            observationSigma = NaN;
            uncertaintyPlotted = false;
            try
                if app.isMCMCResult(result)
                    observationSigma = app.getStoredMCMCObservationSigma(result);
                    if showFitLine && app.shouldPlotMCMCPosteriorPredictiveInterval(result, true)
                        % Export only the interval labeled 95% Uncertainty in
                        % the plot, using the same full-chain export calculation.
                        [~, ~, ~, lowTry, highTry] = ...
                            app.computeMCMCUncertaintyEnvelopes(result, xPlot, true);
                        if numel(lowTry) == numel(xPlot) && numel(highTry) == numel(xPlot)
                            good = isfinite(xPlot(:)) & isfinite(lowTry(:)) & isfinite(highTry(:));
                            if nnz(good) >= 3
                                uncertaintyLow = lowTry(:);
                                uncertaintyHigh = highTry(:);
                                uncertaintyPlotted = true;
                            end
                        end
                    end
                end
            catch
            end

            fitName = app.getDisplayedFitLegendSuffix(result);
            if app.isMCMCResult(result) && strcmp(app.getMCMCPlotMode(), "Both")
                fitName = "mean fit";
            end
            T = [T; app.makeModelFitPlotRows(fitName, "Model curve", ...
                string(result.Sheet), showFitLine, xPlot, yPlot, ...
                uncertaintyLow, uncertaintyHigh, observationSigma, uncertaintyPlotted)];
            if app.isMCMCResult(result) && strcmp(app.getMCMCPlotMode(), "Both")
                bMap = app.getBestFitVector(result);
                yMap = result.Model(bMap, xPlot);
                T = [T; app.makeModelFitPlotRows("MAP fit", "Model curve", ...
                    string(result.Sheet), showFitLine, xPlot, yMap, ...
                    [], [], observationSigma, false)];
            end
        end

        function T = emptyResidualPlotTable(~)
            T = table(strings(0,1), zeros(0,1), zeros(0,1), zeros(0,1), zeros(0,1), ...
                'VariableNames', {'Source','L_mm','Observed_ln_n','Fitted_ln_n','Residual_obs_minus_fit'});
        end

        function T = makeResidualPlotRows(app, result, sourceName, x, y)
            x = double(x(:));
            y = double(y(:));
            n = min(numel(x), numel(y));
            if n < 1
                T = app.emptyResidualPlotTable();
                return;
            end
            x = x(1:n);
            y = y(1:n);
            bDisplay = app.getDisplayedFitParameters(result);
            yFit = result.Model(bDisplay, x);
            yFit = double(yFit(:));
            n = min(n, numel(yFit));
            x = x(1:n); y = y(1:n); yFit = yFit(1:n);
            T = table(repmat(string(sourceName),n,1), x, y, yFit, y-yFit, ...
                'VariableNames', {'Source','L_mm','Observed_ln_n','Fitted_ln_n','Residual_obs_minus_fit'});
        end

        function T = buildResidualPlotDataTable(app, result)
            T = app.emptyResidualPlotTable();
            if isfield(result,'IsCombined') && result.IsCombined && ...
                    isfield(result,'Components')
                for jj = 1:numel(result.Components)
                    part = result.Components(jj);
                    T = [T; app.makeResidualPlotRows(result, part.Sheet, part.x, part.y_obs)];  
                end
            else
                T = app.makeResidualPlotRows(result, result.Sheet, result.x, result.y_obs);
            end
        end

        function [headers, data] = buildMCMCTracePlotData(app, result)
            headers = strings(1,0);
            data = zeros(0,0);
            samplesTrace = [];
            iterTrace = [];
            logPostTrace = [];
            logLikelihoodTrace = [];
            try
                samplesTrace = double(result.MCMC.samplesTrace);
                iterTrace = double(result.MCMC.iterTrace(:));
                if isfield(result.MCMC,'logPostTrace')
                    logPostTrace = double(result.MCMC.logPostTrace(:));
                end
                if isfield(result.MCMC,'logLikelihoodTrace')
                    logLikelihoodTrace = double(result.MCMC.logLikelihoodTrace(:));
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
            if p < 1
                return;
            end
            idx = app.getMCMCFreeParameterIndices(result, p);
            headers = ["Iteration", names(idx)];
            data = [iterTrace, samplesTrace(:,idx)];
            if numel(logPostTrace) == size(samplesTrace,1)
                headers(end+1) = "LogPosteriorSamplingDensity";
                data(:,end+1) = logPostTrace;
            end
            if numel(logLikelihoodTrace) == size(samplesTrace,1)
                headers(end+1) = "LogLikelihoodPhysical";
                data(:,end+1) = logLikelihoodTrace;
            end
        end

        function [headers, data] = buildMCMCPosteriorPlotData(app, result)
            headers = strings(1,0);
            data = zeros(0,0);
            samplesPost = app.getMCMCPosteriorSamplesForPlot(result);
            if isempty(samplesPost)
                return;
            end
            names = app.getParamDisplayNames(result.ModelType);
            p = min(size(samplesPost,2), numel(names));
            if p < 1
                return;
            end
            idx = app.getMCMCFreeParameterIndices(result, p);
            headers = names(idx);
            data = double(samplesPost(:,idx));
        end

        function T = buildMCMCHistogramPlotDataTable(app, result)
            T = table(strings(0,1), zeros(0,1), zeros(0,1), zeros(0,1), ...
                zeros(0,1), zeros(0,1), zeros(0,1), ...
                'VariableNames', {'Parameter','BinLeft','BinRight','BinCenter','Count','PosteriorMean','BestFit'});
            samplesPost = app.getMCMCPosteriorSamplesForPlot(result);
            if isempty(samplesPost)
                return;
            end
            names = app.getParamDisplayNames(result.ModelType);
            p = min(size(samplesPost,2), numel(names));
            idx = app.getMCMCFreeParameterIndices(result, p);
            stats = struct();
            if isfield(result,'Fit') && isfield(result.Fit,'paramStats')
                stats = result.Fit.paramStats;
            end
            for kk = 1:numel(idx)
                jj = idx(kk);
                values = double(samplesPost(:,jj));
                values = values(isfinite(values));
                if isempty(values)
                    continue;
                end
                [counts, edges] = histcounts(values, 35);
                centers = 0.5 .* (edges(1:end-1) + edges(2:end));
                meanVal = app.getMCMCStatValue(result, stats, 'mean', jj);
                bestVal = app.getMCMCStatValue(result, stats, 'best', jj);
                nBins = numel(counts);
                Ti = table(repmat(string(names(jj)),nBins,1), edges(1:end-1).', edges(2:end).', ...
                    centers(:), counts(:), repmat(meanVal,nBins,1), repmat(bestVal,nBins,1), ...
                    'VariableNames', {'Parameter','BinLeft','BinRight','BinCenter','Count','PosteriorMean','BestFit'});
                T = [T; Ti];  
            end
        end

        % Excel permits 1,048,576 rows per worksheet. Reserve row 1 for
        % headers and split unusually long chains into numbered sheets.
        function sheetNames = writeNumericMatrixInExcelChunks(~, outFile, baseSheet, headers, data)
            maxDataRows = 1048575;
            headers = string(headers(:).');
            data = double(data);
            if isempty(headers)
                headers = "No_data_available";
                data = zeros(0,1);
            end
            nRows = size(data,1);
            nChunks = max(1, ceil(nRows ./ maxDataRows));
            sheetNames = strings(1,nChunks);

            for kk = 1:nChunks
                if nChunks == 1
                    sheetName = string(baseSheet);
                else
                    sheetName = string(baseSheet) + "_" + string(kk);
                end
                if strlength(sheetName) > 31
                    sheetName = extractBefore(sheetName, 32);
                end
                sheetNames(kk) = sheetName;
                headerCells = reshape(cellstr(headers), 1, []);
                writecell(headerCells, outFile, "Sheet", sheetName, "Range", "A1");

                i1 = (kk-1) .* maxDataRows + 1;
                i2 = min(kk .* maxDataRows, nRows);
                if nRows > 0 && i1 <= i2
                    writematrix(data(i1:i2,:), outFile, "Sheet", sheetName, "Range", "A2");
                end
            end
        end

        % Export a two-panel record of the piecewise initialization.
        function savePiecewiseInitializationPlot(app, outDir, plotTag, result)
            T = app.buildPiecewiseInitializationPlotDataTable(result);
            if isempty(T)
                return;
            end

            isObs = T.RecordType == "Observation";
            isLine = T.RecordType == "Piecewise line";
            if ~any(isObs) || ~any(isLine)
                return;
            end

            nSeg = max(T.Segment(isLine));
            if ~isfinite(nSeg) || nSeg < 2
                return;
            end
            nSeg = round(nSeg);
            colors = lines(nSeg);

            f = figure("Visible","off","Color","w","Position",[100 100 1250 560]);
            tl = tiledlayout(f,1,2,'TileSpacing','compact','Padding','compact');

            ax1 = nexttile(tl,1); hold(ax1,'on');
            scatter(ax1,T.L_mm(isObs),T.ln_n(isObs),70,'o', ...
                'MarkerFaceColor',[0.25 0.25 0.25], ...
                'MarkerEdgeColor',[0.10 0.10 0.10], ...
                'DisplayName','Observed CSD');
            for kk = 1:nSeg
                mask = isLine & T.Segment == kk;
                if any(mask)
                    plot(ax1,T.L_mm(mask),T.ln_n(mask),'-', ...
                        'Color',colors(kk,:),'LineWidth',2.2, ...
                        'DisplayName',char("Segment " + string(kk) + " line"));
                end
            end
            xlabel(ax1,'L (mm)');
            ylabel(ax1,'ln(n) mm^{-4}');
            title(ax1,'Piecewise lines used for initialization');
            legend(ax1,'Location','best');
            grid(ax1,'on'); box(ax1,'on');
            hold(ax1,'off');

            ax2 = nexttile(tl,2); hold(ax2,'on');
            scatter(ax2,T.L_mm(isObs),T.ln_n(isObs),70,'o', ...
                'MarkerFaceColor',[0.72 0.72 0.72], ...
                'MarkerEdgeColor',[0.45 0.45 0.45], ...
                'DisplayName','All observations');
            for kk = 1:nSeg
                mask = isObs & T.SelectedForSegment & T.Segment == kk;
                if any(mask)
                    scatter(ax2,T.L_mm(mask),T.ln_n(mask),125,'o', ...
                        'MarkerFaceColor',colors(kk,:), ...
                        'MarkerEdgeColor','k','LineWidth',1.2, ...
                        'DisplayName',char("Segment " + string(kk) + " selection"));
                end
            end
            xlabel(ax2,'L (mm)');
            ylabel(ax2,'ln(n) mm^{-4}');
            mode = app.getPiecewiseInitializationMode(result);
            title(ax2,mode + " segment selections");
            legend(ax2,'Location','best');
            grid(ax2,'on'); box(ax2,'on');
            hold(ax2,'off');

            try
                linkaxes([ax1 ax2],'xy');
            catch
            end
            sgtitle(tl,app.getResultPlotTitle(result) + " | " + mode + " initialization", ...
                'Interpreter','none');
            exportgraphics(f,fullfile(outDir,plotTag + "_PiecewiseInitialization.png"), ...
                "Resolution",220);
            close(f);
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
            idx = app.getMCMCFreeParameterIndices(result, p);
            pPlot = numel(idx);
            if pPlot < 1; return; end

            figH = max(360, 165*pPlot + 120);
            f = figure("Visible","off","Color","w","Position",[100 100 1050 figH]);
            tl = tiledlayout(f, pPlot, 1, 'TileSpacing','compact','Padding','compact'); 
            burnIn = app.getStoredRunSetting(result, 'MCMCBurnIn', NaN);
            if ~isfinite(burnIn) && isfield(result,'MCMC') && isfield(result.MCMC,'burnIn')
                burnIn = double(result.MCMC.burnIn);
            end
            for kk = 1:pPlot
                jj = idx(kk);
                ax = nexttile;
                plot(ax, iterTrace(:), samplesTrace(:,jj), '-', 'LineWidth', 0.7);
                if isfinite(burnIn) && burnIn > 0
                    hold(ax,'on');
                    xline(ax, burnIn, '--r', 'LineWidth', 1.5, ...
                        'HandleVisibility','off');
                    hold(ax,'off');
                end
                ylabel(ax, char(names(jj)), 'Interpreter','none');
                grid(ax,'on'); box(ax,'on');
                if kk == 1
                    title(ax, app.getResultPlotTitle(result) + " | MCMC trace plots", 'Interpreter','none');
                end
                if kk == pPlot
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
            idx = app.getMCMCFreeParameterIndices(result, p);
            pPlot = numel(idx);
            if pPlot < 1; return; end

            nCols = ceil(sqrt(pPlot));
            nRows = ceil(pPlot / nCols);
            f = figure("Visible","off","Color","w","Position",[120 120 360*nCols 300*nRows]);
            tiledlayout(f, nRows, nCols, 'TileSpacing','compact','Padding','compact');

            stats = struct();
            if isfield(result,'Fit') && isfield(result.Fit,'paramStats')
                stats = result.Fit.paramStats;
            end
            for kk = 1:pPlot
                jj = idx(kk);
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
            idx = app.getMCMCFreeParameterIndices(result, p);
            pPlot = numel(idx);
            if pPlot < 2; return; end

            samplesPlot = samplesPost(:,idx);
            latexPlotNames = latexNames(idx);

            stats = struct();
            if isfield(result,'Fit') && isfield(result.Fit,'paramStats')
                stats = result.Fit.paramStats;
            end
            meanPlot = nan(1,pPlot);
            ciLowPlot = nan(1,pPlot);
            ciHighPlot = nan(1,pPlot);
            mapPlot = nan(1,pPlot);
            for kk = 1:pPlot
                jj = idx(kk);
                meanPlot(kk) = app.getMCMCStatValue(result, stats, 'mean', jj);
                ciLowPlot(kk) = app.getMCMCStatValue(result, stats, 'ciLow', jj);
                ciHighPlot(kk) = app.getMCMCStatValue(result, stats, 'ciHigh', jj);
                mapPlot(kk) = app.getMCMCStatValue(result, stats, 'best', jj);
                finiteValues = samplesPlot(isfinite(samplesPlot(:,kk)),kk);
                if ~isfinite(meanPlot(kk)); meanPlot(kk) = mean(finiteValues,'omitnan'); end
                if ~isfinite(ciLowPlot(kk)); ciLowPlot(kk) = app.columnPercentile(finiteValues,2.5); end
                if ~isfinite(ciHighPlot(kk)); ciHighPlot(kk) = app.columnPercentile(finiteValues,97.5); end
                if ~isfinite(mapPlot(kk)); mapPlot(kk) = meanPlot(kk); end
            end

            f = figure("Visible","off","Color","w","Position",[140 140 max(750,180*pPlot) max(700,180*pPlot)]);
            tiledlayout(f, pPlot, pPlot, 'TileSpacing','compact','Padding','compact');
            for rr = 1:pPlot
                for cc = 1:pPlot
                    ax = nexttile;
                    if rr == cc
                        histogram(ax, samplesPlot(:,cc), 25);
                    elseif rr > cc
                        scatter(ax, samplesPlot(:,cc), samplesPlot(:,rr), 7, ...
                            [0 0.447 0.741], 'filled', ...
                            'MarkerFaceAlpha',0.16, 'MarkerEdgeAlpha',0.16);
                        hold(ax,'on');
                        purple = [0.494 0.184 0.556];
                        mapRed = [0.85 0.10 0.10];
                        plot(ax, [ciLowPlot(cc), ciHighPlot(cc)], ...
                            [meanPlot(rr), meanPlot(rr)], '-', 'Color',purple, ...
                            'LineWidth',1.8,'HandleVisibility','off');
                        plot(ax, [meanPlot(cc), meanPlot(cc)], ...
                            [ciLowPlot(rr), ciHighPlot(rr)], '-', ...
                            'Color',purple,'LineWidth',1.8,'HandleVisibility','off');
                        plot(ax, meanPlot(cc), meanPlot(rr), 'o', ...
                            'MarkerFaceColor',purple,'MarkerEdgeColor','k', ...
                            'MarkerSize',7,'LineWidth',1.0,'HandleVisibility','off');
                        plot(ax, mapPlot(cc), mapPlot(rr), 'd', ...
                            'MarkerFaceColor',mapRed,'MarkerEdgeColor','k', ...
                            'MarkerSize',8,'LineWidth',1.0,'HandleVisibility','off');
                        hold(ax,'off');
                    else
                        axis(ax,'off');
                        continue;
                    end
                    grid(ax,'on'); box(ax,'on');
                    if rr == pPlot
                        xlabel(ax, char(latexPlotNames(cc)), 'Interpreter','latex');
                    else
                        ax.XTickLabel = [];
                    end
                    if cc == 1 && rr ~= cc
                        ylabel(ax, char(latexPlotNames(rr)), 'Interpreter','latex');
                    elseif cc ~= 1
                        ax.YTickLabel = [];
                    end
                    if rr == 1 && cc == 1
                        title(ax, app.getResultPlotTitle(result) + " | Pairwise", 'Interpreter','none');
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

        function idx = getMCMCFreeParameterIndices(app, result, p)
            idx = 1:p;
            try
                if isfield(result,'reservoirFixNm0') && logical(result.reservoirFixNm0)
                    fixedIdx = app.getReservoirNm0Index(result.ModelType);
                    if isfinite(fixedIdx)
                        idx(idx == fixedIdx) = [];
                    end
                end
            catch
            end
        end

        % Export it and diagnostic plots 
        function savePlotArtifacts(app, cfg, result)
            outRoot = app.getOutputDir(cfg);
            plotTag = app.getPlotExportTag(result);
            outDir  = fullfile(outRoot, plotTag);
            if ~exist(outDir,"dir"); mkdir(outDir); end

            % Piecewise initialization figure (two- and three-reservoir models).
            try
                app.savePiecewiseInitializationPlot(outDir, plotTag, result);
            catch ME_init
                try
                    app.log("Piecewise initialization plot failed: " + string(ME_init.message));
                catch
                end
            end

            % Model fit figure
            f = figure("Visible","off","Color","w","Position",[100 100 950 700]);
            ax = axes(f);
            app.drawFitAxes(ax, {result}, true);
            title(ax, app.getResultPlotTitle(result) + " | " + string(result.Fit.solver) + " fit", 'FontSize', 15);
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
            title(ax, app.getResultPlotTitle(result) + " | Residuals");
            grid(ax,'on'); box(ax,'on');
            hold(ax,'off');
            exportgraphics(f, fullfile(outDir, plotTag + "_Residuals.png"), "Resolution", 220);
            close(f);

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
