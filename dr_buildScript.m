clear
clc
close all

% Set the project root
    projectRoot = fileparts(which('BedformFinder'));
    cd(projectRoot);

% Create a unique name for each build
    number = 1;
    testDir = fullfile(projectRoot, "StandaloneWindowsApplication", "output" + string(number));
    while true
        if ~isfolder(testDir)
            break;
        end
        number = number + 1;
        testDir = fullfile(projectRoot, "StandaloneWindowsApplication", "output" + string(number));
    end

% Create target build options object, set build properties and build.
    buildOpts = compiler.build.StandaloneApplicationOptions(fullfile(projectRoot, "BedformFinder.mlapp"));
    buildOpts.AdditionalFiles = [fullfile(projectRoot, "App Dependancies"), fullfile(projectRoot, "FunctionToolbox")];
    buildOpts.AutoDetectDataFiles = true;
    buildOpts.OutputDir = fullfile(testDir, "build");
    buildOpts.ObfuscateArchive = false;
    buildOpts.Verbose = true;
    buildOpts.EmbedArchive = true;
    buildOpts.ExecutableIcon = fullfile(projectRoot, "App Dependancies", "Images", "iconLOWRES.png");
    buildOpts.ExecutableName = "Bedform_Finder";
    buildOpts.ExecutableSplashScreen = fullfile(projectRoot, "App Dependancies", "Images", "splashScreen.png");
    buildOpts.ExecutableVersion = "1.1";
    buildOpts.TreatInputsAsNumeric = false;
    buildResult = compiler.build.standaloneWindowsApplication(buildOpts);

% Create package options object, set package properties and package.
    packageOpts = compiler.package.InstallerOptions(buildResult);
    packageOpts.ApplicationName = "Bedform Finder";
    packageOpts.AuthorName = "Matthew Free";
    packageOpts.AuthorEmail = "mfree1015@gmail.com";
    packageOpts.AuthorCompany = "United States Army Corps of Engineers";
    packageOpts.Description = "This MATLAB-based application is designed for the analysis of river bathymetric data collected from multibeam sonar surveys, with a focus on identifying and characterizing bedforms such as dunes." + newline + "" + newline + "The workflow is organized around three core stages. First, the process begins by importing raw bathymetric data, either directly from the USACE eHydro platform or from user-provided datasets. Once loaded, the data is processed into parallel Bed Elevation Profiles (BEPs) along the dominent flow direction of the channel." + newline + "" + newline + "Second, the BEPs are processed using automated bedform detection algorithms that extract various parameters such as bedform height or length." + newline + "" + newline + "Third, the processed results are visualized using built-in plotting tools. These plots are used for inspection, interpretation, and quality control." + newline + "" + newline + "This tool also supports batch processing of multiple datasets, enabling efficient analysis of large survey collections. All outputs can be exported for use in external tools or further analysis workflows." + newline + "" + newline + "While originally developed for the Missouri River, the processing pipeline is fully general and can be applied to any river system worldwide where compatible multibeam raster bathymetry data is available.";
    packageOpts.InstallerIcon = fullfile(projectRoot, "App Dependancies", "Images", "iconLOWRES.png");
    packageOpts.InstallerLogo = fullfile(projectRoot, "App Dependancies", "Images", "sidebarImage.png");
    packageOpts.InstallerName = "Bedform_Finder_Installer";
    packageOpts.InstallerSplash = fullfile(projectRoot, "App Dependancies", "Images", "splashScreen.png");
    packageOpts.InstallationNotes = "This installer packages the application with the required MATLAB Runtime, so no separate MATLAB installation is needed to run the app." + newline + "" + newline + "During installation, the MATLAB Runtime will be installed automatically (if not already present on the system). This may take additional time on first setup." + newline + "" + newline + "Ensure sufficient disk space is available for both the application and the MATLAB Runtime components." + newline + "" + newline + "No additional toolboxes or external dependencies are required beyond the packaged runtime environment.";
    packageOpts.OutputDir = fullfile(testDir, "package");
    packageOpts.RuntimeDelivery = "web";
    packageOpts.Summary = "Imports raw river bathymetric data (from USACE eHydro or user input), processes it using automated bedform detection, and visualizes results.";
    packageOpts.Verbose = true;
    packageOpts.Version = "1.0";
    compiler.package.installer(buildResult, "Options", packageOpts);