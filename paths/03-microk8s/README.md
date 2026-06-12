# Path 03 — Kubernetes with MicroK8s

For when your workloads (not just your monitoring) should run on Kubernetes.
[MicroK8s](https://microk8s.io/) is Canonical's low-ops Kubernetes: a single
snap, sane defaults, and one-command add-ons — including a complete
observability stack (kube-prometheus-stack: Prometheus, Grafana, Alertmanager,
node exporters, plus Loki and Tempo).

> **Honest advice:** if you only need *monitoring*, use [Path 01](../01-starter/)
> or [Path 02](../02-observability/). Kubernetes is worth it when you want
> declarative app deployments, rolling updates and multi-node scheduling.

## Prerequisites

- Ubuntu 22.04/24.04 (MicroK8s is a snap; other distros need snapd)
- 2+ vCPU, 4+ GB RAM per node, [security baseline](../../docs/security-baseline.md) applied
- For clusters: nodes can reach each other on ports `16443, 10250, 25000` (and more — see [MicroK8s ports doc](https://microk8s.io/docs/services-and-ports))

## Step 1 — Install (per node)

```bash
sudo bash setup.sh
# log out & back in so the group change applies, then:
microk8s status --wait-ready
```

The script installs MicroK8s from the 1.32 stable channel and enables:
`dns`, `hostpath-storage`, `ingress`, `cert-manager`, `metrics-server`.

## Step 2 — Enable observability

```bash
microk8s enable observability
```

This deploys kube-prometheus-stack + Loki + Tempo into the `observability`
namespace. Reach Grafana:

```bash
microk8s kubectl port-forward -n observability svc/kube-prom-stack-grafana 3000:80 --address 0.0.0.0
```

Login: `admin` / `prom-operator` — **change this immediately**
(Grafana → admin → profile → change password). You get ready-made dashboards
for nodes, pods, deployments and the cluster out of the box.

For permanent access, create an Ingress for Grafana instead of port-forwarding,
or reach it over [Tailscale](../../addons/vpn-tailscale/).

## Step 3 — Add nodes (optional)

On the first node:

```bash
microk8s add-node
```

Copy the printed `microk8s join …` command and run it on each new node
(installed via the same `setup.sh`). Three nodes make the datastore
highly available automatically.

## Step 4 — Deploy something

```bash
microk8s kubectl create deployment whoami --image=traefik/whoami
microk8s kubectl expose deployment whoami --port=80
microk8s kubectl get pods -w
```

Watch the pod appear in Grafana's *Kubernetes / Compute Resources / Namespace*
dashboard. That's your feedback loop from now on.

## Useful commands

```bash
microk8s kubectl get all -A          # everything in the cluster
microk8s status                      # addons & HA state
microk8s kubectl top nodes           # quick resource view (metrics-server)
alias kubectl='microk8s kubectl'     # put in ~/.bashrc, save keystrokes
```

## Updating

MicroK8s tracks its snap channel — `sudo snap refresh` handles patch updates.
For minor version jumps (1.32 → 1.33), read the
[MicroK8s release notes](https://microk8s.io/docs/release-notes) first, then
`sudo snap refresh microk8s --channel=1.33/stable` node by node.
