import pandas as pd
import matplotlib.pyplot as plt

# 读取 CSV 文件
data = pd.read_csv("data_processed.csv")


# 设置时间戳为索引
data.set_index('processes', inplace=True)

# 绘制折线图
plt.figure(figsize=(20, 10))  # 设置画布大小
for column in data.columns:
    plt.plot(data.index, data[column], label=column)  # 逐列绘图

# 添加图例
plt.legend()

# 添加标题和标签
plt.title("Time taken Over processes")
plt.xlabel("processes")
plt.ylabel("Time taken")

# 美化 X 轴日期显示
plt.xticks(rotation=45)

# 显示网格
plt.grid(True)

# 调整布局
plt.tight_layout()

# 保存图像到当前文件夹，文件名为 'line_chart.png'
plt.savefig("line_chart.png", dpi=300)  # dpi=300 提高图像分辨率

# 显示图表（可选，如果不需要在脚本中显示可以注释掉）
plt.show()
