

dura=2e4;
fre=25;
rate=2.5;
t=0:1/dura:2-1/dura;
m=[1, length(t)];
avgg=0;         %平均值
stdd=0.8;       %差值

phase_offset = 0;        % 定义相位偏移量

NoiseSignal1 = 0.25 * sin(2 * pi * fre * t + phase_offset) + 0 .* sin(3.27 * pi * fre * t + phase_offset);

NoiseSignal2=1*rate*normrnd(avgg,stdd,m)+0*sin(7.27*pi*fre*t);

NoiseSignal=NoiseSignal1+0.15*NoiseSignal2;

% 定义卷积核
kernel = ones(1, 5) / 5;

% 对信号进行卷积操作
FilteredSignal = conv(NoiseSignal, kernel, 'same');

% 计算自相关函数
[autocorr, lags] = xcorr(FilteredSignal, 'coeff');

% 找到自相关函数的峰值位置
[~, maxIndex] = max(autocorr);
delay = 7;  % 重新计算最佳延迟时间
% 打印最佳延迟时间
disp(['最佳延迟时间: ', num2str(delay)]);


ini=1;
dura1=0.9*length(t);
noise=NoiseSignal(ini:ini+dura1)';                      % 取Signal矩阵的一列数据的长度
data=NoiseSignal(ini+delay:ini+dura1+delay)';                           % 将噪声的延迟信号作为
N=length(data);                            % 语音长度
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
mu=0.001;
M=150;                                   % 设置滤波器阶数M和步长mu
fai=1e-6;
W=zeros(1,M);                              %滤波器参数初始化


for(iloop=1:N-M-1)
    if(iloop<M+1)
        y(iloop)=0;
    else
        y(iloop)=W*noise(iloop-M+1:iloop);
        e(iloop)=data(iloop)-y(iloop);
        
        nx=noise(iloop-M+1:iloop)'*noise(iloop-M+1:iloop);
        
%          W=W+mu*e(iloop)*noise(iloop-M+1:iloop)';
        
        W=W+mu*e(iloop)*noise(iloop-M+1:iloop)'/(fai+nx);
        
        if(iloop>3e3)
            if(mu>1e-3)
                mu=mu*0.90;
            end
        end
    end
    
end
 %output=e;                               % LMS滤波输出
output=y;   

figure(1)
ylim=1.5;
xlim=0.7*2;
t1=0:1/dura:xlim;
subplot 311; plot(t1,NoiseSignal1(1:length(t1)),'k'); ylabel('归一化幅值') 
axis([0 xlim -1*ylim, ylim]); title('受扰前正弦信号'); grid on;
subplot 312;  plot(t1,NoiseSignal(1:length(t1)),'k'); ylabel('归一化幅值') 
axis([0 xlim -1*ylim, 1*ylim]); title('受干扰的实测信号');grid on;
subplot 313;  plot(t1,output(1:length(t1)),'k'); 
axis([0 xlim -1*ylim, 1*ylim]); title('实测信号中提取出的信号');grid on;
xlabel('时间/s'); ylabel('归一化幅值')

figure(2)
plot(t1,output(1:length(t1))-NoiseSignal1(1:length(t1)));
title('误差值');

% 打印最终的滤波器权重 W
disp('最终的滤波器权重 W:');
disp(W);

% 保存 W 到 CSV 文件
fileID = fopen('filter_weights.csv', 'a');

% 写入新的 W 向量到 CSV 文件
fprintf(fileID, '%f,', W);
fprintf(fileID, '\n');

% 关闭文件
fclose(fileID);

