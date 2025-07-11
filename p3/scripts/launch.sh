# 1. Créer le cluster k3d avec les bons ports exposés
k3d cluster create ArgocdDeployment

# 2. Créer les namespaces nécessaires
kubectl create namespace dev
kubectl create namespace argocd


kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.9.6/deploy/static/provider/kind/deploy.yaml

# 3. Installer Argo CD
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml


# 4. Attendre que tous les pods Argo CD soient prêts
kubectl wait --for=condition=Ready pod --all -n argocd --timeout=120s
kubectl wait --for=condition=Ready pod -l app.kubernetes.io/name=argocd-server -n argocd --timeout=180s

# 5. Déployer ton application

kubectl apply -n dev -f ../confs/deployment.yaml

# 6. Attendre que les pods et déploiements dans `dev` soient prêts
kubectl wait --for=condition=Ready pod --all -n dev --timeout=30s

kubectl wait --for=condition=Ready deployment --all -n dev --timeout=30s


# 7. Exposer les services en LoadBalancer (pour accès via localhost)
nohup sudo kubectl port-forward svc/argocd-server -n argocd 8080:443 >/dev/null 2>&1 &



sleep 5
# 8. Attendre que les services soient exposés
echo "⏳ Recherche du secret argocd-initial-admin-secret..."
# Récupération du mot de passe admin
PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
echo "🔑 Mot de passe admin Argo CD: $PASSWORD"
sleep 5
#Login à Argo CD
sudo argocd login localhost:8080 --username admin --password $PASSWORD --insecure --grpc-web
# 9. Login à Argo CD

# 10. Créer l'application Argo CD
sudo argocd app create development \
  --repo https://github.com/whamoumi/dev \
  --path manifests \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace dev \
  --sync-policy automated

# 11. Synchroniser l'application manuellement si nécessaire
# argocd app sync development

# 12. Afficher l'URL d'accès
echo "🔗 Argo CD: https://localhost:8080"
echo "🚀 App one: http://localhost:8888"