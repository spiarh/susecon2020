# Secure your applications on SUSE CaaS Platform with Cilium

This repository stores all the content required to run the Lab
`HOL-1410 Secure your app on CaaSP with Cilium`. It is originally
made for SUSECON 2020 which was due to take place in Dublin but
was unfortunately canceled due to COVID-19.

Hopefully, we've adapted the Lab so it can be run on any
`SUSE CaaS Platform v4.1.2` !

1. **Environment preparation**

In the following document [documentation/DEPLOYMENT.md](documentation/DEPLOYMENT.md),
you can find all the information to deploy the environment.

Here is an overview:

![](documentation/susecon2020.png)

2. **Running the Lab**

Once you have the environment deployed, you'll find in the following document
[documentation/INSTRUCTIONS.md](documentation/INSTRUCTIONS.md), all the
information to run the Lab.

We'll create some `CiliumNetworkPolicy` to secure some workloads
and see how we can test an troubleshoot the policies.

Then, it's free to you to secure workloads which are not covered during
the Lab but don't worry! you can find a possible solution in
[network-security-policies/](network-security-policies)
