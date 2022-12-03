<!-- omit in toc -->
# Local Kubernetes setup

> 👋 This guide is mostly intented for Windows users. However, Linux and macOS users can easily skip or execute the equivalent steps to get the same result.

This repository contains the instructions and code to setup a local Kubernetes cluster. At the end, you'll get:

* A local Kubernetes cluster with TLS support for your services
* Command-line tools and completion for your terminal
* A configured nginx ingress controller with compression, web application firewall and extra security settings enabled
* A self-signed root certificate authority trusted by your OS, the cluster and your browsers
* Upgradeable Helm charts to easily customize this setup

**Table of contents**

- [🔧 Required setup](#-required-setup)
  - [Install WSL 2, Docker Desktop and Kubernetes](#install-wsl-2-docker-desktop-and-kubernetes)
  - [Install PowerShell Core 7](#install-powershell-core-7)
  - [Install Kubectl and Helm](#install-kubectl-and-helm)
  - [Install mkcert](#install-mkcert)
  - [Switch your kubectl context to docker-desktop](#switch-your-kubectl-context-to-docker-desktop)
- [✨ Recommended additional setup](#-recommended-additional-setup)
  - [Install Windows Terminal or Oh My Zsh](#install-windows-terminal-or-oh-my-zsh)
  - [Install PowerShell intellisense completion](#install-powershell-intellisense-completion)
  - [Install Powershell completion for Kubectl and Helm](#install-powershell-completion-for-kubectl-and-helm)
  - [Install k9s dashboard](#install-k9s-dashboard)
  - [Configure your WSL 2 memory and CPU settings](#configure-your-wsl-2-memory-and-cpu-settings)
- [🔥 Getting started](#-getting-started)
- [☁ Install nginx ingress controller](#-install-nginx-ingress-controller)
- [🔑 Install cert-manager to manage TLS certificates](#-install-cert-manager-to-manage-tls-certificates)
- [🚀 Deploy an ASP.NET Core example service](#-deploy-an-aspnet-core-example-service)
  - [Install a trusted self-signed TLS certificate for your ingress](#install-a-trusted-self-signed-tls-certificate-for-your-ingress)
  - [Deploy the service](#deploy-the-service)
- [🧷 Install Kubernetes dashboard](#-install-kubernetes-dashboard)


## 🔧 Required setup

### Install WSL 2, Docker Desktop and Kubernetes

> Installing [WSL 2 and an Ubuntu Linux distribution](https://learn.microsoft.com/en-us/windows/wsl/install) is only required on Windows.

Install Docker Desktop:
* Windows: https://docs.docker.com/desktop/install/windows-install/
* Linux: https://docs.docker.com/desktop/install/linux-install/
* macOS: https://docs.docker.com/desktop/install/mac-install/

Then, go to *Docker Desktop settings > Kubernetes* and check the *Enable Kubernetes*.

### Install PowerShell Core 7

[PowerShell Core 7](https://github.com/PowerShell/PowerShell#get-powershell) is cross-platform and only required on your OS and WSL 2 for one particular steps of this guide, which is coping the mkcert root certificate authority into the chart directory.

> You may look at the [content the script](https://github.com/asimmon/local-kubernetes-setup/blob/main/mkcert-local-setup/mkcert/Copy-Certificates.ps1) and do the equivalent on your own, without installing PowerShell Core.

### Install Kubectl and Helm

> https://kubernetes.io/docs/tasks/tools/

> https://helm.sh/docs/intro/install/

*On Windows, installing using Chocolatey is preferred.*

### Install mkcert

[mkcert](https://github.com/FiloSottile/mkcert) *(38k+⭐)* is a simple tool for making locally-trusted development certificates. It will be used here to allow Kubernetes to issue self-signed certificates that are trusted by your browser and Windows / WSL 2, using a root certificate authority (CA). Execute `mkcert -install` once installed.

**Reuse mkcert CA on WSL 2**

* Execute `mkcert -CAROOT` on both Windows and WSL 2 to print the directory of the root certificate authority files
* Copy the files from Windows to WSL 2
* Execute once again `mkcert -install` on WSL 2

> From Ubuntu, you can access Windows `C:\` drive using this mount `/mnt/c/`
>
> From Windows, you can access Ubuntu files using this mount `\\wsl$\Ubuntu\`

![image](https://user-images.githubusercontent.com/14242083/204668221-5a049d08-5e11-4b59-9b83-d0f3235057be.png)

### Switch your kubectl context to docker-desktop

This step changes the cluster targeted by commands such as `kubectl`, `helm`, `k9s`, etc. by modifying your [kubeconfig file](https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/). This file is located:
* On Windows: `%userprofile%\.kube\config`
* On Linux and macOS: `~/.kube/config`

Run this command to target your local cluster:
```
kubectl config use-context docker-desktop
```

> On Windows, you can also right click on Docker Desktop tray icon, then on Kubernetes and you should have access to a dropdown.
>
> If you also installed `kubectl` and on your WSL 2 distribution, then both Windows and WSL 2 will use different kubeconfig files.
> You can force WSL 2 to use Windows' kubeconfig file by editing your `~/.bashrc` and `~/.zshrc` (if applicable) and adding the following line at the end (insert your Windows username):
> `export KUBECONFIG=/mnt/c/Users/<WINDOWS-USERNAME>/.kube/config`.


## ✨ Recommended additional setup

> These steps will mostly enhance your tooling and development experience.

### Install Windows Terminal or Oh My Zsh

* Windows: https://aka.ms/terminal
* Linux and macOS: https://ohmyz.sh

![image](https://user-images.githubusercontent.com/14242083/204665666-06edce76-6ffe-476b-986c-a4f5dfaf823b.png)

### Install PowerShell intellisense completion

> https://github.com/PowerShell/PSReadLine

After installing the module **as an administrator**, open a normal terminal and edit your [profile](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_profiles?view=powershell-7.3) (`notepad $PROFILE`) to enable smart auto-complete by adding these lines:

```ps1
Import-Module PSReadLine

Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadlineOption -BellStyle None
```

### Install Powershell completion for Kubectl and Helm

Edit your [profile](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_profiles?view=powershell-7.3) (`notepad $PROFILE`) and add the following lines:

```ps1
kubectl completion powershell | Out-String | Invoke-Expression
helm completion powershell | Out-String | Invoke-Expression
```

> Follow [these](https://kubernetes.io/docs/tasks/tools/included/) and [these steps](https://helm.sh/docs/helm/helm_completion/) for Linux and macOS.

### Install k9s dashboard

> https://k9scli.io/topics/install/

*"K9s is a terminal based UI to interact with your Kubernetes clusters. The aim of this project is to make it easier to navigate, observe and manage your deployed applications in the wild. K9s continually watches Kubernetes for changes and offers subsequent commands to interact with your observed resources."*

![image](https://user-images.githubusercontent.com/14242083/204668596-29b17fa5-4f8e-49ab-bdb5-aeb0725386b7.png)

### Configure your WSL 2 memory and CPU settings

Modify the maximum CPU and memory used by WSL 2 by following [these steps](https://learn.microsoft.com/en-us/windows/wsl/wsl-config#wslconfig).

## 🔥 Getting started

* Clone this git repository
* Open a terminal into the cloned repository

* Then, copy mkcert's root certificate authority (CA) into the `mkcert-local-setup` chart directory:
```
pwsh ./mkcert-local-setup/mkcert/Copy-Certificates.ps1
```


## ☁ Install nginx ingress controller

> [Nginx ingress controller](https://kubernetes.github.io/ingress-nginx/) is used to route the incoming traffic of your browser/tools to the services inside the cluster. By default it uses the ports `80` and `433` so make sure you don't already have something using these ports, or edit the `values.yaml` file.

First, have a look at `.\nginx-ingress-setup\Chart.yaml` and `.\nginx-ingress-setup\values.yaml`. You'll see that we install `nginx-ingress` as a [chart dependency](https://helm.sh/docs/helm/helm_dependency/), which pins a specific version and makes it easy to upgrade. The `values.yaml` enables:

* Brotli and gzip compression
* Modsecurity web application firewall
* HSTS and secure headers

Now, run this command anytime you want to install or update the nginx ingress controller:

```
helm upgrade --install --wait --debug --dependency-update --namespace nginx-ingress --create-namespace nginx-ingress ./nginx-ingress-setup
```


## 🔑 Install cert-manager to manage TLS certificates

> [Cert-manager](https://cert-manager.io/) is used to automatically issue certificates for the hostnames used by your services using mkcert's root certificate authority.

First, have a look at `.\cert-manager-setup\Chart.yaml` and `.\cert-manager-setup\values.yaml`. It's installed as a chart dependency too.

```
helm upgrade --install --wait --debug --dependency-update --namespace cert-manager --create-namespace cert-manager ./cert-manager-setup
```

## 🚀 Deploy an ASP.NET Core example service

We'll deploy the service in a dedicated [Kubernetes namespace](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/). It's a way to group Kubernetes objects in logical units. In this example, we will create and use a namespace named `demo`.

We'll also deploy the service to the domain `aspnetcore.example.local`. Two things:
* Make sure to add this custom local domain to your hosts files ([instructions for Windows](https://www.wikihow.com/Edit-the-Hosts-File-on-Windows))
* `*.example.local` TLS support is pre-configured in the file `.\mkcert-local-setup\values.yaml`, so if you want to use another local domain please update this file too

### Install a trusted self-signed TLS certificate for your ingress

Issue a TLS certificate for `*.example.local` in the `demo` namespace by installing a release of this chart:
```
helm upgrade --install --wait --dependency-update --namespace demo --create-namespace demo-mkcert ./mkcert-local-setup
```

This will issue a TLS certificate stored in a secret named `<helm-release-name>-tls-secret`. In this case the release name was `demo-mkcert`, so created TLS secret is named `demo-mkcert-tls-secret`. This secret name is very important because it will be referenced by your ingress.

### Deploy the service

The chart `aspnetcore-service` exposes the [Microsoft ASP.NET Core sample Docker application](https://hub.docker.com/_/microsoft-dotnet-samples/). The `.\aspnetcore-service\values.yaml` ingress values are already configured to support the domain `aspnetcore.example.local` and the TLS secret created in the previous step:

```yaml
ingress:
  className: nginx
  hostname: aspnetcore.example.local # <-- Local domain covered by the TLS certificate
  # [...]
  tls:
    enabled: true # <-- Don't want HTTPS? Set this to false
    secretName: demo-mkcert-tls-secret # <-- Secret created in the previous step
```

Now, deploy the ASP.NET Core app to the `demo` namespace, next to the TLS secret:

```
helm upgrade --install --wait --debug --dependency-update --namespace demo --create-namespace demo-aspnetcore ./aspnetcore-service
```
The service should now be accessible at https://aspnetcore.example.local/

![image](https://user-images.githubusercontent.com/14242083/204666433-bc8d18ee-348b-4695-8d95-6624d444cbb9.png)


## 🧷 Install Kubernetes dashboard

[Kubernetes dashboard](https://github.com/kubernetes/dashboard) is similar to k9s. It's a web-based UI to manage your cluster.

* We'll deploy it in a new namespace `kubernetes-dashboard`
* It will be accessible at the URL https://kubernetes-dashboard.example.local, so modify your [hosts](https://www.wikihow.com/Edit-the-Hosts-File-on-Windows) file accordingly

Same as for the ASP.NET Core app, we first need a TLS certificate:

```
helm upgrade --install --wait --dependency-update --namespace kubernetes-dashboard --create-namespace kubernetes-dashboard-mkcert ./mkcert-local-setup
```

The `kubernetes-dashboard-setup` chart uses the [kubernetes-dashboard](https://artifacthub.io/packages/helm/k8s-dashboard/kubernetes-dashboard) subchart and is already configured for our custom domain and TLS certificate secret name.

```
helm upgrade --install --wait --debug --dependency-update --namespace kubernetes-dashboard --create-namespace kubernetes-dashboard ./kubernetes-dashboard-setup
```
The service should now be accessible at https://kubernetes-dashboard.example.local. Press the "Skip" button to sign-in, anonymous access should be enabled.

![image](https://user-images.githubusercontent.com/14242083/204666532-465ca73a-e939-4158-b992-7faf16110204.png)
