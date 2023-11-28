# pre 脚本
## 可直接执行
## 第一个参数是 username，第二个参数是 password

#!/bin/bash
set -euxo pipefail

# 0 下载数据库的账号
## 使用临时变量：下面这行输入自己用户名和密码。
username=$1
password=$2

# 安装 conda
mkdir -p ~/miniconda3
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda3/miniconda.sh
bash ~/miniconda3/miniconda.sh -b -u -p ~/miniconda3
rm -rf ~/miniconda3/miniconda.sh
~/miniconda3/bin/conda init bash
source ~/.bashrc

# 下载代码
git clone https://github.com/xuanhao44/SUAPCD.git
mv ~/SUAPCD/assessment_plan_modeling ~/assessment_plan_modeling
rm -rf SUAPCD

# 安装依赖
conda create -n apenv python=3.9 -y
conda activate apenv

pip config set global.index-url https://mirrors.aliyun.com/pypi/simple/
pip install --upgrade pip
pip install -r assessment_plan_modeling/requirements.txt

conda install -c conda-forge cudatoolkit=11.8 cudnn=8.9.2.26 -y
mkdir -p $CONDA_PREFIX/etc/conda/activate.d
echo 'export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$CONDA_PREFIX/lib/' > $CONDA_PREFIX/etc/conda/activate.d/env_vars.sh
## 检查
python3 -c "import tensorflow as tf; print(tf.config.list_physical_devices('GPU'))"
conda deactivate

# 下载数据集
wget -r -N -c -np --user $username --password $password https://physionet.org/files/mimiciii/1.4/NOTEEVENTS.csv.gz
gzip -d physionet.org/files/mimiciii/1.4/NOTEEVENTS.csv.gz
mv physionet.org/files/mimiciii/1.4/NOTEEVENTS.csv assessment_plan_modeling/data/notes.csv
rm -rf physionet.org