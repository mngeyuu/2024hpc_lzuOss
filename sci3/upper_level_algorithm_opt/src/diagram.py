import os
import re
import matplotlib.pyplot as plt

# 设置日志目录
LOG_DIR = r"D:\2024秋学习\github\hpc\sci3\upper_level_algorithm_opt\src\logs"

# 提取日志中的运行时间
def extract_times(log_file):
    times = []
    try:
        with open(log_file, 'r') as f:
            for line in f:
                # 假设日志中包含 "耗时: <time> 秒"
                match = re.search(r"耗时: (\d+\.\d+) 秒", line)
                if match:
                    times.append(float(match.group(1)))
    except FileNotFoundError:
        print(f"日志文件 {log_file} 未找到")
    return times

# 生成图表
def generate_chart():
    files = [f for f in os.listdir(LOG_DIR) if f.endswith('.log')]
    program_names = []
    execution_times = []

    for file in files:
        log_file = os.path.join(LOG_DIR, file)
        times = extract_times(log_file)
        if times:
            program_names.append(file.replace('.log', ''))
            execution_times.append(sum(times) / len(times))  # 计算平均时间

    if program_names:
        plt.figure(figsize=(10, 6))
        plt.barh(program_names, execution_times, color='skyblue')
        plt.xlabel('平均运行时间 (秒)')
        plt.title('程序运行时间对比')
        plt.tight_layout()
        plt.savefig('execution_times.png')
        plt.show()
    else:
        print("未提取到有效的运行时间数据")

if __name__ == '__main__':
    generate_chart()
