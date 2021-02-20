clc; close all; clear all;
%% Simple example: simpletest.m	
% This example demonstrates how to setup a simple photon transport
% simulation, run it and visualise the result.

%%Compile updated cpp file
mex   -DUSE_OMP cpp/2d/MC2Dmex.cpp COMPFLAGS='\$COMPFLAGS -fopenmp' CXXFLAGS='\$CXXFLAGS -fopenmp' LDFLAGS='\$LDFLAGS -fopenmp'
mex   -DUSE_OMP cpp/3d/MC3Dmex.cpp COMPFLAGS='\$COMPFLAGS -fopenmp' CXXFLAGS='\$CXXFLAGS -fopenmp' LDFLAGS='\$LDFLAGS -fopenmp'


%% Create a triangular mesh
% Function createRectangularMesh is used to setup a simple triangular mesh. The
% mesh is visualised in the figure below. Each element (a triangle) and
% boundary element (a line) in the mesh has a unique index that can be
% used to set their properties. The indices of the boundary elements are
% shown in the figure.
%
% <<edge.png>>
%

xsize =  20;	% width of the region [mm]
ysize =  10;	% height of the region [mm]
dh = 0.1;         % discretisation size [mm]
vmcmesh = createRectangularMesh(xsize, ysize, dh);

%% Give optical parameters
% Constant optical parameters are set troughout the medium.

vmcmedium.absorption_coefficient = 0.001;     % absorption coefficient [1/mm]
vmcmedium.scattering_coefficient = 0.1;      % scattering coefficient [1/mm]
vmcmedium.scattering_anisotropy = 0.001;       % anisotropy parameter g of
                                             % the Heneye-Greenstein scattering
                                             % phase function [unitless]
vmcmedium.refractive_index = 1.3333;            % refractive index [unitless]
vmcmedium = createMedium(vmcmesh,vmcmedium);
% Select elements from the mesh meduium modified by ultra sound
radius = 1;                 % [mm]
centercoord = [-8.0  0.0];     % [mm]
elements_of_the_circle = findElements(vmcmesh, 'circle', centercoord, radius);
%modified lower refractive index
radius = 1;                 % [mm]
centercoord = [-6.0  0.0];     % [mm]
elements_of_the_circle2 = findElements(vmcmesh, 'circle', centercoord, radius);


% Assign a unique absorption coefficient to the selected elements
vmcmedium.refractive_index(elements_of_the_circle) = 1.3334;
vmcmedium.refractive_index(elements_of_the_circle2) = 1.3332;
figure;

patch('Faces', vmcmesh.H, 'Vertices',vmcmesh.r, 'FaceVertexCData', ...
      vmcmedium.refractive_index, 'FaceColor', 'flat', 'EdgeColor','none');
xlabel('[mm]');
ylabel('[mm]');
c = colorbar;                             % create a colorbar
c.Label.String = 'Absorption coefficient';

%% Create a light source
% Set up a 'cosinic' light source to boundary elements number 4,5,6 and 7.
% This means that the initial propagation direction with respect to the surface
% normal follows a cosine distribution. The photons are launched from random locations
% at these boundary elements.

vmcboundary.lightsource(47:53) = {'gaussian'};
vmcboundary.lightsource_gaussian_sigma(47:53) = 0.1;

% options.export_filename = 'testnew'; 
options.photon_count= 1e6;
% Run the Monte Carlo simulation
% Use the parameters that were generated to run the simulation in the mesh.
solution = ValoMC(vmcmesh, vmcmedium, vmcboundary,options);

%% Plot the solution
% The solution is given as an array in which the values represent a
% constant photon fluence in each element.
% This array can be plotted with Matlab's built-in function patch
figure;

patch('Faces',vmcmesh.H,'Vertices',vmcmesh.r,'FaceVertexCData', log(solution.element_fluence), 'FaceColor', 'flat','LineStyle','none', 'LineWidth',1.5);

hold on;

xlabel('[mm]');
ylabel('[mm]');
c = colorbar;                       % create a colorbar
c.Label.String = ' Log Fluence [W/mm^2]';
hold off
figure;
patch('Faces',vmcmesh.H,'Vertices',vmcmesh.r,'FaceVertexCData', log(1+solution.element_fluence), 'FaceColor', 'flat','LineStyle','none', 'LineWidth',1.5);
w
hold on;

xlabel('[mm]');
ylabel('[mm]');
c = colorbar;                       % create a colorbar
c.Label.String = '1+Fluence [W/mm^2]';
hold off

figure;
patch('Faces',vmcmesh.H,'Vertices',vmcmesh.r,'FaceVertexCData', solution.element_fluence, 'FaceColor', 'flat','LineStyle','none', 'LineWidth',1.5);


hold on;

xlabel('[mm]');
ylabel('[mm]');
c = colorbar;                       % create a colorbar
c.Label.String = 'Fluence [W/mm^2]';
hold off

