#!/bin/bash

#Atualizando repositorios
pacman -Syy reflector --noconfirm
reflector --verbose -l 40 --sort rate --save /etc/pacman.d/mirrorlist

#VARIAVEIS DE USUARIO
USUARIO='automa'
SENHA_USUARIO='4648'
SENHA_ROOT='4648'
HOSTNAME='black-arch'
DE='gnome'
GLOGIN='gdm'
DISCO='sda'
DISCO_BKP='sdc'

#CRIANDO TABELA DE PARTIÇÃO PARA DISCO
parted /dev/$DISCO mklabel gpt
#CRIANDO PARTIÇÃO /EFI
parted /dev/$DISCO mkpart primary fat32 0% 512MB
#CRIANDO PARTIÇÃO /
parted /dev/$DISCO mkpart primary ext4 512MB 100%
#CONFERINDO PARTIÇÕES
clear
parted /dev/$DISCO print
sleep 5
parted /dev/$DISCO_BKP print
#FORMATANDO ROOT
mkfs.ext4 /dev/${DISCO}2
#FORMATANDO EFI
mkfs.fat -F 32 /dev/${DISCO}1

#mkdir -p /mnt/boot/efi
mkdir /mnt/boot
mkdir /mnt/boot/efi
#montando partições
mount /dev/${DISCO}2 /mnt
mount /dev/${DISCO_BKP}1 /mnt/home
mount /dev/sda1 /mnt/boot/efi



#CONFIGURANDO O PACMAN.CONF
sed -i '/^#.*Color/s/^#//' /etc/pacman.conf
sed -i '/^#.*ParallelDownloads/s/^#//' /etc/pacman.conf
pacman -Sy
#INSTALANDO SISTEMA BASE
pacstrap /mnt base base-devel grub linux linux-firmware linux-headers efibootmgr nano dhcpcd \
networkmanager $DE $GLOGIN


genfstab -U /mnt >> /mnt/etc/fstab

#POS INSTALL
arch-chroot /mnt
echo $HOSTNAME >> /etc/hostname
ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
hwclock --systohc
sed -i '/^#.*pt_BR.UTF-8/s/^#//' /etc/locale.gen
locale-gen
echo 'LANG=pt_BR.UTF-8' >> /etc/locale.conf
echo 'FONT=Lat2-Terminus16' >> /etc/vconsole.conf
#configurando hostname 
printf '\n127.0.0.1	localhost\n::1		localhost\n127.0.1.1	$HOSTNAME.localdomain	$HOSTNAME' >> /etc/hosts
echo 'root:$SENHA_ROOT' | chpasswd
useradd -m -c "Cyber" -g users -G wheel,storage,power -s /bin/bash $USUARIO
echo '$USUARIO:$SENHA_USUARIO' | chpasswd
echo '$USUARIO ALL=(ALL) ALL' | tee -a /etc/sudoers
sed -i '/^#.*%wheel ALL=(ALL) ALL/s/^#//' /etc/sudoers
sed -i '/^#.*Color/s/^#//' /etc/pacman.conf
sed -i '/^#.*ParallelDownloads/s/^#//' /etc/pacman.conf
pacman -Syu
pacman -Sy git
git clone --depth 1 https://github.com/prasanthrangan/hyprdots ~/Hyprdots
cd ~/Hyprdots/Scripts
./install.sh
grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=arch --recheck
grub-mkconfig -o /boot/grub/grub.cfg
#video
systemctl enable NetworkManager.service $GLOGIN
mkinitcpio -P
clear
figlet "Sistema Instalado"
sleep 5
EOF

#umount -R /mnt
#reboot

