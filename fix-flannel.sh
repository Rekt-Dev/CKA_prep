NE-SHOT FLANNEL FIX FOR MASTER + WORKERS
# Run this on the MASTER node
#
MASTER_IP="192.168.1.110"
WORKERS=("192.168.1.111" "192.168.1.112")
USER="adminov"
#
echo "Step 1: Copy kubeconfig to all workers..."
for WORKER in "${WORKERS[@]}"; do
    scp /etc/kubernetes/admin.conf $USER@$WORKER:/home/$USER/kubeconfig
done

echo "Step 2: Setting KUBECONFIG on all workers..."
for WORKER in "${WORKERS[@]}"; do
    ssh $USER@$WORKER "echo 'export KUBECONFIG=/home/$USER/kubeconfig' >> ~/.bashrc && export KUBECONFIG=/home/$USER/kubeconfig"
done

echo "Step 3: Applying Flannel on MASTER..."
kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml

echo "Step 4: Setting Flannel env to point to MASTER..."
kubectl set env ds/kube-flannel-ds -n kube-flannel \
     KUBERNETES_SERVICE_HOST=$MASTER_IP \
     KUBERNETES_SERVICE_PORT=6443

echo "Step 5: Restarting Flannel daemonset..."
kubectl rollout restart ds kube-flannel-ds -n kube-flannel

echo "Step 6: Waiting for Flannel pods to be running..."
kubectl get pods -n kube-flannel -o wide --watch
#                 i

