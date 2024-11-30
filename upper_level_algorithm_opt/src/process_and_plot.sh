#!/bin/bash

# Step 1: 使用 sed 去除表头
sed '1d' data.csv > data_no_header.csv

# Step 2: 使用 awk 提取需要的列（时间和数值）
awk -F',' '{print $1, $2}' data_no_header.csv > data_processed.csv

# Step 3: 调用 Python 脚本生成图表
python3 plot_data.py data_processed.csv
