#!/bin/bash
set -e

echo "Mise à jour initiale des paquets..."
sudo apt update -y

echo "Désactivation du pare-feu UFW..."
sudo ufw disable

echo "Installation des dépendances de base..."
sudo apt install -y ca-certificates curl gnupg

echo "Création du dossier pour les clés apt..."
sudo install -m 0755 -d /etc/apt/keyrings

echo "Ajout de la clé GPG officielle de Docker..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo "Ajout du dépôt Docker..."
ARCH=$(dpkg --print-architecture)
CODENAME=$(. /etc/os-release && echo "$VERSION_CODENAME")
echo "deb [arch=${ARCH} signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu ${CODENAME} stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

echo "Mise à jour après ajout du dépôt Docker..."
sudo apt update -y

echo "Installation des paquets Docker..."
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "Ajout de l'utilisateur actuel au groupe docker..."
sudo usermod -aG docker $USER

echo "⚠️ Pour prendre en compte l'ajout au groupe docker, merci de vous déconnecter puis reconnecter."

echo "Installation de kubectl..."
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm kubectl

echo "Installation de k3d..."
wget -q -O - https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

echo "Installation de ArgoCD..."
curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
rm argocd-linux-amd64

echo "Vérification des versions installées..."
k3d version
kubectl version --client

echo "Installation terminée."
