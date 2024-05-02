#!/bin/bash

# style
export BORDER_FOREGROUND="#0F0"
export FOREGROUND="#AFA"
export CURSOR_FOREGROUND="#FF0"
export PADDING="1 5"
export MARGIN="1"
export BORDER="normal"
export CURSOR_MODE="blink"

# choose
export GUM_CHOOSE_CURSOR_FOREGROUND="$CURSOR_FOREGROUND"
export GUM_CHOOSE_HEADER_FOREGROUND="$BORDER_FOREGROUND"
export GUM_CHOOSE_SELECTED_FOREGROUND="$FOREGROUND"

# input
export GUM_INPUT_CURSOR_MODE="$CURSOR_MODE"
export GUM_INPUT_CURSOR_FOREGROUND="$CURSOR_FOREGROUND"
export GUM_INPUT_PROMPT_FOREGROUND="$FOREGROUND"

# confirm
export GUM_CONFIRM_PROMPT_FOREGROUND="$FOREGROUND"
export GUM_CONFIRM_SELECTED_BACKGROUND="$CURSOR_FOREGROUND"
# export GUM_CONFIRM_UNSELECTED_FOREGROUND="$FOREGROUND"

# write
export GUM_WRITE_HEADER_FOREGROUND="$FOREGROUND"

readonly KIND_CONFIGS="./config/kind"
readonly LB_POOL="./config/cni/cilium/lb-ipam.yaml"
readonly L2ANNOUNCEMENT_POLICY="./config/cni/cilium/l2announcements.yaml"
readonly CILIUM_CONFIG="./config/cni/cilium/cilium.yaml"
readonly APP="./config/samples"

back(){
  local yes="Yes, please"
  local no="Nothing thanks, I'm done"
  local answer=$(gum choose --header "Can I do something else for you?" "$yes" "$no")
  case $answer in
    "$no")
      echo "Bye folk, see you soon!"
      exit 0
      ;;
  esac
}

sure(){
  clear
  gum style "Sure, let's do that together my friend!"
}

createCluster(){
  sure
  local image=$(gum input --prompt "What node image would you like?" --value "kindest/node:v1.29.2")
  local name=$(gum input --prompt "What would be the name of your cluster?" --value "kind")
  local config=$(gum file "$KIND_CONFIGS")
  local f=$(gum write --header "Review and/or edit cluster configuration..." --height 15 < "$config")
  echo "$f" | kind create cluster --name "$name" --image "$image" --config -
  gum confirm "Install cilium CNI?" && installCilium 
}

deleteCluster(){
  sure
  local name=$(gum choose --header "Which one?" $(kind get clusters))
  gum confirm && kind delete cluster --name "$name"
}

installCilium(){
  sure
  k8sServiceHost=$(kubectl get nodes -l node-role.kubernetes.io/control-plane -o jsonpath='{.items[0].metadata.name}')
  echo "$k8sServiceHost"

  cilium install \
  --set kubeProxyReplacement="strict" \
  --set routingMode="native" \
  --set k8sServiceHost="$k8sServiceHost" \
  --set k8sServicePort=6443 \
  --set l2announcements.enabled=true \
  --set l2announcements.leaseDuration="3s" \
  --set l2announcements.leaseRenewDeadline="1s" \
  --set l2announcements.leaseRetryPeriod="500ms" \
  --set devices="{eth0,net0}" \
  --set externalIPs.enabled=true \
  --set autoDirectNodeRoutes=true \
  --set operator.replicas=2

  cilium status --wait
  kubectl apply -f "$LB_POOL"
  kubectl apply -f "$L2ANNOUNCEMENT_POLICY"
  gum confirm "Deploy sample app?" && deployApplication
}

deployApplication(){

  local config=$(gum file "$APP")
  kubectl apply -f $config
  checkService
}

checkService(){
  SERVICES=$(kubectl get svc -o=jsonpath='{range .items[?(@.spec.type=="LoadBalancer")]}{.metadata.name}{"\n"}{end}')
  SVC=$(gum choose --header "Which service you want to check ?"  $SERVICES)
  SVC_IP=$(kubectl get svc $SERVICES -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
  echo "Your service is exposed with Load balancer IP $SVC_IP"
  curl --connect-timeout 1 $SVC_IP
}

lobby(){
  clear
  gum style "Welcome, nice to meet you!"
  local create_cluster="I need a local cluster, can you create one for me?"
  local delete_cluster="Can you delete a local cluster for me?"
  local quit="Nothing thanks, I'm done"
  local command=$(gum choose --header "How can I help you?" "$create_cluster" "$delete_cluster" "$quit")
  case $command in
    "$create_cluster")
      createCluster
      ;;
    "$delete_cluster")
      deleteCluster
      ;;
    "$quit")
      echo "Bye folk, see you soon!"
      exit 0
      ;;
  esac
}

while true
do
  lobby
  back
done
