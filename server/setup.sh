sudo apt-get update
sudo apt-get install -y emacs
sudo apt-get install -y python-virtualenv
sudo apt-get install -y python-setuptools python-dev build-essential
sudo apt-get install -y libmysqlclient-dev
virtualenv /home/vagrant/raceday/venv
source /home/vagrant/raceday/venv/bin/activate
easy_install -U distribute
pip install -r raceday/requirements.txt
deactivate
# echo "source /home/vagrant/zyServer/venv/bin/activate" >> /home/vagrant/.bashrc
# echo "source /home/vagrant/zyServer/setup_env.sh" >> /home/vagrant/.bashrc
