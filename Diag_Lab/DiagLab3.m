close all
clear
% Wczytanie danych
in1=load('In1.mat');
czas=in1.ans(1,:);
in1=in1.ans(2,:);

in2=load('In2.mat');
in2=in2.ans(2,:);

out1=load('Out1.mat');
zb1=out1.ans(2,:);
zb2=out1.ans(3,:);
zb3=out1.ans(4,:);

out2=load('Out2.mat');
zb4=out2.ans(2,:);
zb5=out2.ans(3,:);
zb6=out2.ans(4,:);

for i=1:2
    figure
    subplot(4,1,1)
    plot(czas,eval(sprintf('in%d',i)))
    
    grid on
    ylabel('Sygnal wejsciowy [%]')
    xlabel('Czas [s]')
    title(sprintf('Seria numer: %d',i))

    for j=1:3
        subplot(4,1,j+1)
        plot(czas,eval(sprintf('zb%d',j+3*(i-1))))
        
        grid on
        ylabel('Poz. [cm]')
        xlabel('Czas [s]')
        title(sprintf('Zbiornik nr.: %d',j))
    end
end


Ts1=czas(2)-czas(1); % 100 [Hz] probkowanie domyslne
%% Zmiana typu danych
% transpozycje ze wzgl na rozmiary
zbi1 = [zb1; zb2; zb3]';
zbi2 = [zb4; zb5; zb6]';

zbt1 = tonndata(zbi1,false,false);
zbt2 = tonndata(zbi2,false,false);

int1 = tonndata(in1,false,false);
int2 = tonndata(in2,false,false);

in1=in1';
in2=in2';

bledy=zeros(3,4);
%% Trening o parametrach domyslnych
net=netTrain(in1,zbi1,'trainlm',10,2,Ts1);

[x,xi,ai,t] = preparets(net,zbt1,{},int1);
y = net(x,xi,ai);
e = cell2mat(gsubtract(t,y));
bledy(:,1)=rms(e,2);

net=netReTrain(in2,zbi2,net);

[x,xi,ai,t] = preparets(net,zbt2,{},int2);
y = net(x,xi,ai);
e = cell2mat(gsubtract(t,y));
bledy(:,2)=rms(e,2);


%% Trening ze zmienionymi parametrami
clear net
net=netTrain(in1,zbi1,'trainbr',15,4,Ts1);

[x,xi,ai,t] = preparets(net,zbt1,{},int1);
y = net(x,xi,ai);
e = cell2mat(gsubtract(t,y));
bledy(:,3)=rms(e,2);

net=netReTrain(in2,zbi2,net);

[x,xi,ai,t] = preparets(net,zbt2,{},int2);
y = net(x,xi,ai);
e = cell2mat(gsubtract(t,y));
bledy(:,4)=rms(e,2);


%% Porównanie dokładności
figure
plot(sum(bledy))
title('Historia wartości rms(residuum)')
xlabel('Numer treningu [n]')
ylabel('Błąd rms [\circC]')

for a=1:3
    figure
    up=mean(e(a,:))+3*std(e(a,:))*ones(1,length(czas));
    dw=mean(e(a,:))-3*std(e(a,:)*ones(1,length(czas)));
    plot(czas,e(a,:),czas,up,'r--',czas,dw,'r--')
    xlabel('czas')
    title(['Sygnał residuum zbiornika nr.:' num2str(a)])
    legend({'Wielkość błędu','Próg uszkodzenia'})
end

%% Symulowanie uszkodzenia
% siec=cell2mat(y1);
% for a=2:3
%     figure
%     d_uszk=temp_new(1:(end-4),a);
%     up=mean(siec(a,:)-d_uszk')+3*std(siec(a,:)-d_uszk');
%     dw=mean(siec(a,:)-d_uszk')-3*std(siec(a,:)-d_uszk');
%     k=up.*ones(1,length(tt));
%     l=dw.*ones(1,length(tt));
%     subplot(2,1,1)
%     plot(tt,d_uszk,tt,siec(a,:))
%     title('Badanie uszkodzenia')
%     xlabel('Czas [s]')
%     ylabel('Temperatura [\circC]')
%     legend({'Sygnał uszkodzony','Sygnał referencyjny'})
%     subplot(2,1,2)
%     e=d_uszk'-siec(a,:);
%     
%     plot(tt,e,tt,k,'r--',tt,l,'r--')
%     title(['Sygnał residuum czujnika nr.:' num2str(a)])
%     legend({'Wielkość błędu','Próg uszkodzenia'})
% end
% 
% mkdir('Wykresy')
% n=input('Ile wykresów figure napisało? ');
% for i=1:n
%     figure(i)
%     print(sprintf('Wykresy/Wykres%d.png',i),'-dpng')
% end
