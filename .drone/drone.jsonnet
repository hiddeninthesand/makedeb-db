{
    name: "build-and-publish",
    kind: "pipeline",
    type: "docker",
    trigger: {branch: [a]},
    steps: [
        {
            name: "build-debian-package",
            image: "proget.hunterwittenborn.com/docker/hunter/makedeb:alpha",
            commands: [".drone/scripts/build.sh"]
        },

        {
            name: "publish-proget",
            image: "proget.hunterwittenborn.com/docker/hunter/makedeb:alpha",
            environment: {proget_api_key: {from_secret: "proget_api_key"}},
            commands: [".drone/scripts/publish.sh"]
        }
    ]
},

{
    name: "aur-publish",
    kind: "pipeline",
    type: "docker",
    volumes: [{name: "aur", temp: {}}],
    trigger: {branch: [b]},
    depends_on: ["build-and-publish"],

    steps: [
        {
            name: "clone-aur",
            image: "proget.hunterwittenborn.com/docker/hunter/makedeb:alpha",
            volumes: [{name: "aur", path: "/drone"}],
            commands: [".drone/scripts/aur.sh clone"]
        },

        {
            name: "configure-pkgbuild",
            image: "proget.hunterwittenborn.com/docker/hunter/makedeb:alpha",
            volumes: [{name: "aur", path: "/drone"}],
            commands: [".drone/scripts/aur.sh configure"]
        },

        {
            name: "push-pkgbuild",
            image: "proget.hunterwittenborn.com/docker/hunter/makedeb:alpha",
            volumes: [{name: "aur", path: "/drone"}],
            environment: {
                aur_ssh_key: {from_secret: "aur_ssh_key"},
                known_hosts: {from_secret: "known_hosts"}
            },
            commands: [".drone/scripts/aur.sh push"]
        }
    ]
}
