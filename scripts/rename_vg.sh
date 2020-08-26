# #!/bin/bash

# Авторизуемся для получения root прав
mkdir -p ~root/.ssh
cp ~vagrant/.ssh/auth* ~root/.ssh

# Переименовываем необходимую нам volume gruoup
vgrename VolGroup00 NewVolGroup00

# Заменяем имя группы в нужных нам конфигурационных файлах
sed 's/VolGroup00/NewVolGroup00/g' /etc/fstab > fstab
sed 's/VolGroup00/NewVolGroup00/g' /etc/default/grub > grub
sed 's/VolGroup00/NewVolGroup00/g' /boot/grub2/grub.cfg > grub.cfg

cp fstab /etc/fstab
cp grub /etc/default/grub
cp grub.cfg /boot/grub2/grub.cfg

# Пересоздаем initrd image с новым именем группы
mkinitrd -f -v /boot/initramfs-$(uname -r).img $(uname -r)
