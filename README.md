# upload

Небольшая памятка как процедура загрузки происходит в Linux (взято [отсюда](https://max-ko.ru/12-ustranenie-nepoladok-pri-zagruzke-v-linux.html)).

1. Выполнение POST: машина включена. Из системного ПО, которым может быть UEFI или классический BIOS, выполняется самотестирование при включении питания (POST) и аппаратное обеспечение, необходимое для запуска инициализации системы.

2. Выбор загрузочного устройства: В загрузочной прошивке UEFI или в основной загрузочной записи находится загрузочное устройство.

3. Загрузка загрузчика: с загрузочного устройства находится загрузчик. На Red Hat/CentOS это обычно GRUB 2.

4. Загрузка ядра: Загрузчик может представить пользователю меню загрузки или может быть настроен на автоматический запуск Linux по умолчанию. Для загрузки Linux ядро загружается вместе с initramfs. Initramfs содержит модули ядра для всего оборудования, которое требуется для загрузки, а также начальные сценарии, необходимые для перехода к следующему этапу загрузки. На RHEL 7/CentOS  initramfs содержит полную операционную систему (которая может использоваться для устранения неполадок).

5. Запуск /sbin/init: Как только ядро загружено в память, загружается первый из всех процессов, но все еще из initramfs. Это процесс /sbin/init, который связан с systemd. Демон udev также загружается для дальнейшей инициализации оборудования. Все это все еще происходит из образа initramfs.

6. Обработка initrd.target: процесс systemd выполняет все юниты из initrd.target, который подготавливает минимальную операционную среду, в которой корневая файловая система на диске монтируется в каталог /sysroot. На данный момент загружено достаточно, чтобы перейти к установке системы, которая была записана на жесткий диск.

7. Переключение на корневую файловую систему: система переключается на корневую файловую систему, которая находится на диске, и в этот момент может также загрузить процесс systemd с диска.

8. Запуск цели по умолчанию (default target): Systemd ищет цель по умолчанию для выполнения и запускает все свои юниты. В этом процессе отображается экран входа в систему, и пользователь может проходить аутентификацию. Обратите внимание, что приглашение к входу в систему может быть запрошено до успешной загрузки всех файлов модуля systemd. Таким образом, просмотр приглашения на вход в систему не обязательно означает, что сервер еще полностью функционирует.




# Попасть в систему без пароля root
Основные способы входа в систему без пароля *root* (например для сброса пароля *root*)


## Способ *rd.break*
Параметр загрузки *rd.break* останавливает процедуру загрузки, пока она еще находится в стадии initramfs.
При загрузке заходим в меню *grub2* выбираем нужное нам ядро и заходим в меню параметров загрузки ядра (нажать *e*).
Прописываем аргумент *rd.break* в конце строки раздела *linux16/vmlinuz* и нажимаем Ctrl - x.

Выводим командой ``mount`` список смонтированных файловых систем, находим */sysroot* с параметром *ro*. В sysroot на данный момент монтирована корневая файловая система на диске.

``
#mount
``

Перемонтируем */sysroot* в режиме *rw* (чтение запись).

``  
#mount -o remount,rw /sysroot 
``

Проверяем командой *mount* что */sysroot* примонтирован в *rw* режиме.

``
#mount
``

Командой ``chroot`` заходим на корневую директорию */sysroot*

``
#chroot /sysroot
``


Теперь мы можем изменять необходимые нам файлы. Изменим пароль пользователя командой passwd.

Создаем файл .autorelabel для того чтобы запустить автоматическую перемаркировку файловой системы для SELinux. 

``
#touch /.autorelabel
``

Командой *exit* выходим из chroot. 
На всякий случай перемонтируем  в ro (read only) и проверим параметр монтирования.

``  
#mount -o remount,ro /sysroot
``

Проверяем все ли правильно примонтирвалось.
``
#mount
``

Перезагружаем систему и заходим с новым паролем.


## Способ *init=/bin/sh*
Прописывая аргумент init=/bin/sh или init=/bin/bash мы указываем, что оболочка shell или bash должна быть запущена сразу после загрузки ядра и initrd. Это полезный вариант, но не лучший, потому что в некоторых случаях мы потеряем консольный доступ или пропустим другие функции. В отличие от предыдущиего способа *rd.break* мы уже находимся в корневом каталоге, только файловая система при этом монтирована в режиме *ro* чтения (мы можем поменять аргумент *ro* на *rw* в конце строки, чтобы сразу включить режим чтение), что команда ``mount`` нам и покажет.

``
#mount
``


*/ on type xfs (ro,relatime,attr2,inode64,noquota)*


По аналогии с предыдущим способом перемонтируем корневую файловую систему в режиме *rw* чтения\запись.

``  
#mount -o remount,rw /
``

Аналогично как с *rd.break* изменяем пароль пользователя командой 
passwd.

Создаем файл .autorelabel для того чтобы запустить автоматическую перемаркировку файловой системы для SELinux.

``
#touch /.autorelabel
``

Перезагружаем систему и заходим с новым паролем.

Примечание: можно также использовать параметр *init=/sysroot/bin/sh*, который говорит загрузчику запускать оболочку sh от sysroot, где в этот момент временно смонтирована наша фс.

# Переименовать Volume Group в LVM
В папке scripts лежит скрипт rename_vg с комментариями

# Добавление модуля в initrd
В папке scripts лежит скрипт add_module с комментариями

