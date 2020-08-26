#!/bin/sh

# Создаем папку в 
mkdir /usr/lib/dracut/modules.d/01test

# Копируем необходимые нам скрипты в только что созданную папку
cp /vagrant/scripts/module-setup.sh /usr/lib/dracut/modules.d/01test
cp /vagrant/scripts/test.sh /usr/lib/dracut/modules.d/01test

# Пересобираем образ initrd
mkinitrd -f -v /boot/initramfs-$(uname -r).img $(uname -r)

# Выставляем нужные нам параметры при загрузке в grub.
# В данном случае нам необходимо убрать параметры quiet
# для того чтобы мы могли увидеть информационные сообщения
# при загрузке и rghb - графическую заставку redhat,
# которая тоже может скрыть нужные нам сообщения. 
# После мы можем увидеть наше информациооное сообщение в течении 10 секунд.