# 0 下载数据库的账号：用户名设置
## 使用临时变量：下面这行输入自己用户名；请修改成自己的。
username=shirou

# 1 更新 & 安装一些包
sudo apt update
sudo apt upgrade -y
sudo apt autoremove -y
sudo apt install build-essential libssl-dev zlib1g-dev \
libbz2-dev libreadline-dev libsqlite3-dev curl \
libncursesw5-dev xz-utils libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev -y

# 2 Git 设置
cat << EOF >> /etc/hosts
# github
140.82.113.4 github.com
199.232.69.194 github.global.ssl.fastly.net
EOF

# 3 设置代码和数据
git clone https://github.com/xuanhao44/SUAPCD.git
mv ~/SUAPCD/assessment_plan_modeling ~/assessment_plan_modeling
rm -rf SUAPCD
wget -r -N -c -np --user $username --ask-password https://physionet.org/files/mimiciii/1.4/NOTEEVENTS.csv.gz <<< "$password"
gzip -d physionet.org/files/mimiciii/1.4/NOTEEVENTS.csv.gz
mv physionet.org/files/mimiciii/1.4/NOTEEVENTS.csv assessment_plan_modeling/data/notes.csv
rm -rf physionet.org

## 4 安装 pyenv
git clone https://github.com/pyenv/pyenv.git ~/.pyenv
echo '# pyenv' >> ~/.bashrc
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc
echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(pyenv init -)"' >> ~/.bashrc
exec "$SHELL"
git clone https://github.com/pyenv/pyenv-update.git $(pyenv root)/plugins/pyenv-update
git clone https://github.com/pyenv/pyenv-doctor.git $(pyenv root)/plugins/pyenv-doctor
git clone https://github.com/pyenv/pyenv-virtualenv.git $(pyenv root)/plugins/pyenv-virtualenv
echo 'eval "$(pyenv virtualenv-init -)"' >> ~/.bashrc
echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc
exec "$SHELL"

## 5 设置环境，安装依赖
pyenv install 3.9.9
pyenv global 3.9.9
pyenv virtualenv 3.9.9 apenv
pyenv activate apenv
pip config set global.index-url https://mirrors.aliyun.com/pypi/simple/
pip install --upgrade pip
pip install -r assessment_plan_modeling/requirements.txt

## 6 安装 CUDA（驱动，toolkit）
wget https://developer.download.nvidia.cn/compute/cuda/11.3.1/local_installers/cuda_11.3.1_465.19.01_linux.run
sudo sh cuda_11.3.1_465.19.01_linux.run

## 7 安装 libcuDNN
### 先把文件放进来
sudo cp cuda/include/cudnn.h /usr/local/cuda-11.3/include
sudo cp cuda/lib64/libcudnn* /usr/local/cuda-11.3/lib64
sudo chmod a+r /usr/local/cuda-11.3/include/cudnn.h /usr/local/cuda-11.3/lib64/libcudnn*
cd /usr/local/cuda-11.3/lib64/
sudo rm -rf libcudnn.so libcudnn.so.8
sudo ln -s libcudnn.so.8.2.1 libcudnn.so.8
sudo ln -s libcudnn.so.8 libcudnn.so
sudo ldconfig -v
source /etc/profile
cat << EOF >> ~/.bashrc
# CUDA 11.3
export PATH=/usr/local/cuda-11.3/bin:$PATH
export LD_LIBRARY_PATH=/usr/local/cuda-11.3/lib64:$LD_LIBRARY_PATH
EOF
exec "$SHELL"