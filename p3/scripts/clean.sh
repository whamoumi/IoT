#!/bin/bash
# Script de nettoyage pour Ubuntu : supprime Docker, kubectl, k3d, ArgoCD

set -e

echo "Arrêt et suppression des conteneurs Docker..."
sudo docker container stop $(sudo docker container ls -aq) 2>/dev/null || true
sudo docker system prune -af --volumes

echo "Suppression des paquets Docker..."
sudo apt-get purge -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo apt-get autoremove -y
sudo rm -rf /var/lib/docker /var/lib/containerd

echo "Suppression des fichiers liés à Docker..."
sudo rm -rf /etc/apt/keyrings/docker.gpg /etc/apt/sources.list.d/docker.list

echo "Suppression de kubectl..."
sudo rm -f /usr/local/bin/kubectl kubectl

echo "Suppression de k3d..."
if command -v k3d &> /dev/null; then
    k3d cluster delete --all || true
fi
sudo rm -f /usr/local/bin/k3d
rm -f k3d

echo "Suppression de ArgoCD..."
sudo rm -f /usr/local/bin/argocd argocd-linux-amd64

echo "Suppression des utilisateurs du groupe docker..."
sudo gpasswd -d $USER docker || true

echo "Nettoyage des paquets restants..."
sudo apt-get autoremove -y
sudo apt-get clean

echo "Script terminé. Redémarre la session ou la machine pour appliquer les changements."
