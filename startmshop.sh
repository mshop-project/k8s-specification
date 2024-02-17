#!/bin/bash

if [ $# -ne 1 ]; then
  echo "Użycie: $0 <numer-portu> na jaki aplikacja ma zostać udostępniona"
  exit 1
fi

kubectl apply -f mshop-deployment.yml
kubectl apply -f postgres-secrets.yml
kubectl apply -f mongodb-deployment.yml
kubectl apply -f mshop-service.yml
kubectl apply -f postgres-service.yml
kubectl apply -f mongodb-pv-claim.yml
kubectl apply -f postgres-deployment.yml
kubectl apply -f mongodb-service.yml
kubectl apply -f postgres-pv-claim.yml

while true; do
  PODS=$(kubectl get pods --selector=app=mshopclient -o jsonpath="{.items[*].status.phase}")

  if [[ $PODS =~ "Running" ]] && ! [[ $PODS =~ "Pending"|"ContainerCreating"|"Error"|"Unknown" ]]; then
    echo 
    echo "Wszystkie pody dla mshopclient-svc są uruchomione."
    echo "Uwaga! Nie oznacza to, że inne pody zostały uruchomione "
    echo
    break
  else
    echo "Czekanie na uruchomienie podów usługi mshopclient-svc w celu wykonania port-forwardingu..."
    sleep 5
  fi
done

kubectl port-forward svc/mshopclient-svc "$1":80
