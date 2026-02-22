# Container Armada 🚢

A centralized, version-controlled repository for managing OCI stacks. 


My main goal with this repository is to have a centralized place to store my container configs. A lot of the time when trying to deploy based off of existing ones, there are small issues here and there that I have to figure out before getting a working stack going. The idea here is to keep *"working"* ones so that I can easily redeploy in the future, or if people need help with getting things set up, they can use my configs.

I mainly deploy these with Portainer (yes, I could use Kube, but I don't need that complexity yet), so having a public repo with these templates makes that easier for me. On changes, I can auto-deploy, etc.

## Pre-requisites
These stacks are built around the [OCI (Open Container Initiative)](https://opencontainers.org/about/overview/) standard. OCI is an open governance structure—originally established by Docker and other industry leaders—that creates universal, open industry standards for container formats and runtimes. Because of this standardization, any OCI-compliant container image can run on any OCI-compliant runtime without being locked into a single vendor's ecosystem.

The most common way to deploy these is using Docker and Docker Compose. However, because these are standard OCI containers, you can also easily use open-source alternatives like Podman, which is highly popular for its daemonless architecture and rootless container security.

To use these configs, you will need:

- A container runtime installed (like Docker or Podman).
- A basic understanding of how to use `docker-compose` or the equivalent in your chosen runtime.

## Structure
We have a few different categories of stacks, organized into folders:

* `/infra`
    - Core networking, proxy, and system services.
* `/apps` 
    - User-facing applications and services.
* `/databases`  
    - Standalone database instances.
* `/misc`       
    - Miscellaneous or experimental stacks.

Within these folders, each stack should be organized as follows:

```/stack-name
    ├── stack.yml 
    ├── .env.example (optional, for environment variable templates)
    └── README.md
```
## Contributing

Contributions are welcome! If you have a stack you'd like to share, please submit a pull request with the following:

1. A clear and descriptive name for the stack.
2. A `stack.yml` file with comments explaining key configurations, with more detailed explanations in the stack's `README.md`.
3. An optional `.env.example` file if your stack requires environment variables.
4. Be sure to test your stack before submitting to ensure it works as expected, and note if there are any hardware architecture limits when using the stack (e.g., ARM vs. x86/AMD64).
5. Add a `README.md` file that provides an overview of the stack, its purpose, and any special instructions for deployment or configuration.


> **Never commit real `.env` files or secrets in the repository.**
## License

This project is licensed under the MIT License, see the [LICENSE](LICENSE) file for details.
