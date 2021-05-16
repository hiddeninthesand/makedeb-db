// Function - Set PKGBUILD functions for PKGBUILDs in src/PKGBUILDs
local configurePKGBUILD() = {
  name: "Configure PKGBUILDs",
  kind: "pipeline",
  type: "docker",
  clone: { disable: true },
  image_pull_secrets: [ "nexus_repository_docker_login" ],
  steps: [
    {
      name: "Clone",
      image: "docker.hunterwittenborn.com/hwittenborn/drone-git",
      settings: {
        action: "clone",
        ssh_known_hosts: { from_secret: "ssh_known_hosts" },
        ssh_key: { from_secret: "kavplex_github_ssh_key" }
      }
    },

    {
      name: "Set Variables in PKGBUILDs",
      image: "ubuntu",
      commands: [ "cd ${DRONE_REPO_NAME}", "scripts/pkgbuild_gen.sh" ]
    },

    {
      name: "Push Modified PKGBUILDs Back to GitHub",
      image: "docker.hunterwittenborn.com/hwittenborn/drone-git",
      settings: {
        action: "push",
        ssh_known_hosts: { from_secret: "ssh_known_hosts" },
        ssh_key: { from_secret: "kavplex_github_ssh_key" },
        message: "Updated version in PKGBUILDs [CI SKIP]"
      }
    }
  ]
};

// Function - Build and Publish
local buildAndPublish() = {
  name: "Build and Publish to APT Repository",
  kind: "pipeline",
  type: "docker",
  clone: { disable: true },
  image_pull_secrets: [ "nexus_repository_docker_login" ],
  depends_on: [ "Configure PKGBUILDs" ],
  trigger: {
    branch: "master"
  },
  steps: [
    {
      name: "Clone",
      image: "docker.hunterwittenborn.com/hwittenborn/drone-git",
      settings: {
        action: "clone",
        ssh_known_hosts: { from_secret: "ssh_known_hosts" },
        ssh_key: { from_secret: "kavplex_github_ssh_key" }
      }
    },

    {
      name: "Build",
      image: "ubuntu",
      environment: {
        DEBIAN_FRONTEND: "noninteractive"
      },
      commands: [ "cd ${DRONE_REPO_NAME}", "scripts/build.sh" ]
    },

    {
      name: "Publish",
      image: "ubuntu",
      environment: {
        nexus_repository_password: {
          from_secret: "nexus_repository_password"
        },
        DEBIAN_FRONTEND: "noninteractive"
      },
      commands: [ "cd ${DRONE_REPO_NAME}", "scripts/publish.sh" ]
    }
  ]
};

local publishAUR(pkgtitle) = {
  name: "Publish to AUR",
  kind: "pipeline",
  type: "docker",
  trigger: { branch: "master" },
  depends_on: [ "Build and Publish to APT Repository" ],
  clone: { disable: true },
  image_pull_secrets: [ "nexus_repository_docker_login" ],
  steps: [
    {
      name: "Clone",
      image: "docker.hunterwittenborn.com/hwittenborn/drone-git",
      settings: {
        action: "clone",
        ssh_known_hosts: { from_secret: "ssh_known_hosts" },
        ssh_key: { from_secret: "kavplex_github_ssh_key" }
      }
    },

    {
      name: "Pull Git repository from AUR",
      image: "docker.hunterwittenborn.com/hwittenborn/drone-aur",
      settings: {
        action: "clone",
        pkgname: "makedeb-db",
        ssh_known_hosts: { from_secret: "ssh_known_hosts" },
        ssh_key: { from_secret: "kavplex_aur_ssh_key" }
      }
    },

    {
      name: "Replace AUR PKGBUILD with PKGBUILD from GitHub",
      image: "ubuntu",
      commands: [ "makedeb-db/scripts/aur_pkgbuild_select.sh" ]
    },

    {
      name: "Push Release to AUR",
      image: "docker.hunterwittenborn.com/hwittenborn/drone-aur",
      settings: {
        action: "push",
        pkgname: "makedeb-db",
        ssh_known_hosts: { from_secret: "ssh_known_hosts" },
        ssh_key: { from_secret: "kavplex_aur_ssh_key" }
      }
    }
  ]
};

// Run Functions
[
  configurePKGBUILD(),
  buildAndPublish(),
  publishAUR("makedeb-db"),
]
