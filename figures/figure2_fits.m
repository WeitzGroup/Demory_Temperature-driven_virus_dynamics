%% A thermal trade-off between viral production and degradation drives phytoplankton-virus population dynamics
% Figure 2 -- Model fits for the six temperatures tested experimentally
% David Demory

% Main figure 2: strain 829 (MicB/MicV-B)
% Supplementary figures 1 and 2: strain 451 (MicA/MicV-A) and 834
% (MicC/MicV-C)

%% Load parameters and data
strain = 829; % Choose between 829 (MicB/MicV-B), 451 (MicA/MicV-A) or 834 (MicC/MicV-C)

d0 = 0;
df = 5;
dt = 0.01;

switch strain

    case 829 % MicB/MicV-B

        % Load experimental data
        y_data = experiments(strain,dt,d0);

        % Number of treatments
        nexp = 6;

        % Treatment and variable names
        t_names = {'t_95C','t_125C','t_20C','t_25C','t_275C','t_30C'};
        V_names = {'V_95C','V_125C','V_20C','V_25C','V_275C','V_30C'};
        H_names = {'H_95C','H_125C','H_20C','H_25C','H_275C','H_30C'};
        tV_names = {'tV_95C','tV_125C','tV_20C','tV_25C','tV_275C','tV_30C'};
        tH_names = {'tH_95C','tH_125C','tH_20C','tH_25C','tH_275C','tH_30C'};
        sdV_names = {'sdV_95C','sdV_125C','sdV_20C','sdV_25C','sdV_275C','sdV_30C'};
        sdH_names = {'sdH_95C','sdH_125C','sdH_20C','sdH_25C','sdH_275C','sdH_30C'};
        y_names = {'y_95C','y_125C','y_20C','y_25C','y_275C','y_30C'};

        % Experimental temperatures
        TT = [9.5,12.5,20,25,27.5,30];

        % Model parameters
        load('pmin_829.mat')

        % Load basal model parameters
        load('pmin_H0.mat')

    case 834 % MicC/MicV-C

        % Load experimental data
        y_data = experiments(strain,d0,dt);

        % Number of treatments
        nexp = 5;

        % Treatment and variable names
        t_names = {'t_125C','t_20C','t_25C','t_275C','t_30C'};
        V_names = {'V_125C','V_20C','V_25C','V_275C','V_30C'};
        H_names = {'H_125C','H_20C','H_25C','H_275C','H_30C'};
        tV_names = {'tV_125C','tV_20C','tV_25C','tV_275C','tV_30C'};
        tH_names = {'tH_125C','tH_20C','tH_25C','tH_275C','tH_30C'};
        y_names = {'y_125C','y_20C','y_25C','y_275C','y_30C'};

        % Experimental temperatures
        TT = [12.5,20,25,27.5,30];

        % Mode
        l parameters
        load('pmin_834.mat')

    case 451 % MicA/MicV-A

        % Load experimental data
        y_data = experiments(strain,d0,dt);

        % Number of treatments
        nexp = 5;

        % Treatment and variable names
        t_names = {'t_125C','t_20C','t_25C','t_275C','t_30C'};
        V_names = {'V_125C','V_20C','V_25C','V_275C','V_30C'};
        H_names = {'H_125C','H_20C','H_25C','H_275C','H_30C'};
        tV_names = {'tV_125C','tV_20C','tV_25C','tV_275C','tV_30C'};
        tH_names = {'tH_125C','tH_20C','tH_25C','tH_275C','tH_30C'};
        y_names = {'y_125C','y_20C','y_25C','y_275C','y_30C'};

        % Experimental temperatures
        TT = [12.5,20,25,27.5,30];

        % Model parameters
        load('parameters/pmin_451.mat')

end

% time of the simulation
t = d0:dt:df;

sumSSE=0;

hostfigid = [1,3,5,7,9,11];
virusfigid = [2,4,6,8,10,12];

% color
lightgrey = [0.85 0.85 0.85];
colH      = [26, 188, 156 ]/255;
colV      = [165, 105, 189]/255;

%% Plot
hfig = figure;
% Subplots (treatments)
for i = 1:nexp;

    % Temperature of the treament i
    T = TT(i);

    % Data
    H_data = y_data.(H_names{i});   % concentration host data
    tH_data = y_data.(tH_names{i}); % time host data
    V_data = y_data.(V_names{i});   % concentration virus data
    tV_data = y_data.(tV_names{i}); % time virus data

    % ODE Integration
    % initial condition
    Hinistat_std=std(H_data(1:3));   % std initial condition host
    Vinistat_std=std(V_data(1:3));   % std initial condition virus
    Hinistat_mean=mean(H_data(1:3)); % mean initial condition host
    Vinistat_mean=mean(V_data(1:3)); % mean initial condition virus

    % ODE options
    options = odeset('reltol',1E-3,'abstol',1E-3);

    % Variable for the fill areas
    yHplus=[]; yHmin = [];yVmoins=[]; yVplus = [];

    % Temperature variation \pm 1
    dx = 0.001; % paper version
    dx = 0.1;
    for deltaT=-1:dx:1

        % host initial condition
        Hini=max(0,Hinistat_mean+randn(1)*Hinistat_std);

        % virus initial condition
        Vini=max(0,Vinistat_mean+0.3*randn(1)*Vinistat_std);

        % if no variation of temperature the initial condition is equal to
        % the experimental concentration at t0
        if deltaT==0
            Hini=H_data(1);
            Vini=V_data(1);
        end

        % initial conditions for ode45
        Ci = [Hini,0,Vini,0];

        % Calculate the parameters for T+deltaT
        [mu,K,phi,lambda,epsilon,beta,sigma,delta,omega,m]=Tdriven_fct(T+deltaT,pmin);

        % Integration using ode45 at T+deltaT
        [tmod,ymod] = ode45(@SIV2_v2,t,Ci,options,pmin,T+deltaT);

        % Use the H0 for the comparison with strain 829
        if strain == 829
            % Integration
            [tfit0,yfit0] = ode45(@SIV2_v2_H0,t, [H_data(1),0,V_data(1),0], [], pmin0, T);
            % Total Host = S+I
            ysol0H = yfit0(:,1)+yfit0(:,2);
            % Total Virus = Vi+Vni
            ysol0V = yfit0(:,3)+yfit0(:,4);
        end

        % Calcul on the envelops
        if deltaT==0;
            simnominaleH=ymod(:,1)+ymod(:,2);
            simnominaleV=ymod(:,3)+ymod(:,4);
        end

        if isempty(yHplus);
            yHplus= ymod(:,1)+ymod(:,2);
            yHmin= ymod(:,1)+ymod(:,2);
            yVplus= ymod(:,3)+ymod(:,4);
            yVmoins= ymod(:,3)+ymod(:,4);
        else
            yHplus=max(yHplus,ymod(:,1)+ymod(:,2));
            yHmin=min(yHmin,ymod(:,1)+ymod(:,2));
            yVplus=max(yVplus,ymod(:,3)+ymod(:,4));
            yVmoins=min(yVmoins,ymod(:,3)+ymod(:,4));
        end


    end


    %% Plots

    % -- Host
    subplot(6,2,hostfigid(i))
    hold on

    % fill area
    ttmod = [tmod' fliplr(tmod')];
    inBetweenH = [yHmin' fliplr(yHplus')];
    fill(ttmod, log(inBetweenH),colH,'EdgeColor','none','Facealpha',0.3);

    % data
    ind=~isnan(H_data);
    tH_data=tH_data(ind);
    H_data=H_data(ind);
    dotH(i) = plot(tH_data,log(H_data),'.k','MarkerSize',30);

    % Model
    plot(tmod,log(simnominaleH),'-','linewidth',3,'color',colH);

    % H0 model
    if strain == 829
        plot(tfit0,log(ysol0H),':','LineWidth',3,'color',colH);
    end

    hold off

    % Axis limits and labels
    % Strain 820
    if i == 1 || i == 2
        ylim([12 16])
        yticks([12 14 16])
        set(gca,'XtickLabel','')
    elseif i == 3
        ylim([8 15])
        yticks([9 12 15])
        ylabel('Host concentration (Cell/mL)')
        set(gca,'XtickLabel','')
    elseif i == 4
        ylim([8 15])
        yticks([9 12 15])
        set(gca,'XtickLabel','')
    elseif i == 5
        ylim([11 17])
        yticks([11 14 17])
        set(gca,'XtickLabel','')
    elseif i == 6
        ylim([11 17])
        yticks([11 14 17])
        xlabel('Time (day)')
        xticks([0 2.5 5])
    end
    %Strain 451 and 834
    if strain == 451
        ylim([6 18])
        yticks([6 12 18])
    elseif strain == 834
        ylim([11.5 16])
        yticks([12 14 16])
    end

    % -- Virus
    subplot(6,2,virusfigid(i))
    hold on

    % Fill
    inBetweenV = [yVmoins' fliplr(yVplus')];
    fill(ttmod, log(inBetweenV),colV,'EdgeColor','none','Facealpha',0.3);

    % Data
    ind=~isnan(V_data);
    tV_data=tV_data(ind);
    V_data=V_data(ind);
    dotV(i) = plot(tV_data,log(V_data),'.k','MarkerSize',30);

    % Model
    plot(tmod,log(simnominaleV),'-','linewidth',3,'color',colV);

    % H0 model
    if strain == 829
        plot(tfit0,log(ysol0V),':','LineWidth',3,'color',colV);
    end

    hold off

    % Axis limits and labels
    % Strain 829
    if i == 1 || i == 2
        ylim([14 18])
        yticks([14 16 18])
        set(gca,'XtickLabel','')
    elseif i == 3
        ylim([14 18])
        yticks([14 16 18])
        ylabel('Virus concentration (Virus/mL)')
        set(gca,'XtickLabel','')
    elseif i == 5 || i == 4
        ylim([15 20])
        yticks([15 17.5 20])
        set(gca,'XtickLabel','')
    elseif i == 6
        ylim([14 18])
        yticks([14 16 18])
        xticks([0 2.5 5])
    end
    % Strain 451 and 834
    if strain == 451
        ylim([14 20])
        yticks([14 17 20])
    elseif strain == 834
        ylim([14 20.5])
        yticks([14 17 20])
    end

    %% AIC and BIC estimations
    if strain == 829
        % Interpolation ysim
        ysim_intH=interp1(tmod,ymod(:,1)+ymod(:,2),tH_data);
        ysim_intV=interp1(tmod,ymod(:,3)+ymod(:,4),tV_data);
        ysim_int0H=interp1(tmod,yfit0(:,1)+yfit0(:,2),tH_data);
        ysim_int0V=interp1(tmod,yfit0(:,3)+yfit0(:,4),tV_data);

        % SSE
        ecartR_H = sum((ysim_intH-H_data).^2);
        ecartR_V = sum((ysim_intV-V_data).^2);
        ecartR0_H = sum((ysim_int0H-H_data).^2);
        ecartR0_V = sum((ysim_int0V-V_data).^2);

        % number of parameters
        k0 = 10; % Basal model
        kT = 19; % Temperature-driven model

        % data size
        nH = length(H_data);
        nV = length(V_data);

        % AIC
        AIC_T = 2*kT + nH*log(ecartR_H/nH) + nV*log(ecartR_V/nV);
        AIC_0 = 2*k0 + nH*log(ecartR0_H/nH) + nV*log(ecartR0_V/nV);

        % BIC
        BIC_T = kT*log(nH+nV) + nH*log(ecartR_H/nH) + nV*log(ecartR_V/nV);
        BIC_0 = k0*log(nH+nV) + nH*log(ecartR0_H/nH) + nV*log(ecartR0_V/nV);

        % Print AIC and BIC results
        disp('################################################################################')
        disp(sprintf(' Temperature:  %1.2f',T))
        disp(sprintf(' Temperature-driven model:  AIC_T = %0.5g,   BIC_T =%0.5g',[AIC_T BIC_T]))
        disp(sprintf(' Basal-driven model:  AIC_0 = %0.5g,   BIC_0 =%0.5g',[AIC_0 BIC_0]))
    end
end

%% Figure clean up
% Figure color and size
set(gcf,'color','white','position',[0 0 650 900])

% title
subplot(6,2,1)
title('Host')
subplot(6,2,2)
title('Virus')

% Fontsize
set(findall(gcf,'-property','FontSize'),'FontSize',18)

% Save figure
print(hfig,'-depsc','-r600','outputs/Figure2_fits.eps')
