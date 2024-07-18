import numpy as np
import matplotlib.pyplot as plt

dura = 2e4
fre = 25
rate = 2.5
t = np.arange(0, 2, 1/dura)
m = len(t)
avgg = 0  # 平均值
stdd = 0.8  # 差值

NoiseSignal1 = 0.25 * np.sin(2 * np.pi * fre * t) + 0. * np.sin(3.27 * np.pi * fre * t)  # 定义输入信号
NoiseSignal2 = 1 * rate * np.random.normal(avgg, stdd, m) + 0 * np.sin(7.27 * np.pi * fre * t)
NoiseSignal = NoiseSignal1 + 0.15 * NoiseSignal2

# 计算自相关函数
autocorr = np.correlate(NoiseSignal, NoiseSignal, mode='full') / np.max(np.correlate(NoiseSignal, NoiseSignal, mode='full'))
lags = np.arange(-len(NoiseSignal) + 1, len(NoiseSignal))

# 找到自相关函数的峰值位置
maxIndex = np.argmax(autocorr)
delay = 7  # 定义延迟
# 打印最佳延迟时间
print(f'最佳延迟时间: {delay}')

ini = 0
dura1 = int(0.9 * len(t))
noise = NoiseSignal[ini:ini + dura1]  # 取Signal矩阵的一列数据的长度
data = NoiseSignal[ini + delay:ini + dura1 + delay]  # 将噪声的延迟信号作为
N = len(data)  # 语音长度

mu = 0.001
M = 150  # 设置滤波器阶数M和步长mu
fai = 1e-6
W = np.zeros(M)  # 滤波器参数初始化

y = np.zeros(N)
e = np.zeros(N)

for iloop in range(N - M - 1):
    if iloop < M:
        y[iloop] = 0
    else:
        y[iloop] = np.dot(W, noise[iloop - M + 1:iloop + 1])
        e[iloop] = data[iloop] - y[iloop]
        
        nx = np.dot(noise[iloop - M + 1:iloop + 1], noise[iloop - M + 1:iloop + 1])
        
        W = W + mu * e[iloop] * noise[iloop - M + 1:iloop + 1] / (fai + nx)
        
        if iloop > 3000:
            if mu > 1e-3:
                mu = mu * 0.90

output = y

# 绘图
ylim = 1.5
xlim = 0.7 * 2
t1 = np.arange(0, xlim, 1/dura)

plt.figure(1)
plt.subplot(311)
plt.plot(t1, NoiseSignal1[:len(t1)], 'k')
plt.ylabel('归一化幅值')
plt.axis([0, xlim, -ylim, ylim])
plt.title('受扰前正弦信号')
plt.grid(True)

plt.subplot(312)
plt.plot(t1, NoiseSignal[:len(t1)], 'k')
plt.ylabel('归一化幅值')
plt.axis([0, xlim, -ylim, ylim])
plt.title('受干扰的实测信号')
plt.grid(True)

plt.subplot(313)
plt.plot(t1, output[:len(t1)], 'k')
plt.axis([0, xlim, -ylim, ylim])
plt.title('实测信号中提取出的信号')
plt.grid(True)
plt.xlabel('时间/s')
plt.ylabel('归一化幅值')

plt.figure(2)
plt.plot(t1, output[:len(t1)] - NoiseSignal1[:len(t1)])
plt.title('误差值')
plt.grid(True)

plt.show()
